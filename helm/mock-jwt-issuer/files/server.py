#!/usr/bin/env python3
"""Minimal, dependency-free JWKS server for testing token exchange.

Reads an RSA private key PEM (PKCS#1 "BEGIN RSA PRIVATE KEY" or PKCS#8
"BEGIN PRIVATE KEY"), derives the public key from it, and serves:

    GET /jwt/keys                         {"keys": [[kid, public_key_pem]]}
                                          (the fence / cdispyutils format)
    GET /jwks
    GET /.well-known/jwks
    GET /.well-known/jwks.json            RFC 7517 JWKS with n/e
    GET /.well-known/openid-configuration
    GET /_status

Only the public half of the key is ever served. Configuration comes from the
environment: KEY_PATH, KID, ALG, ISSUER, PORT.

Runs on the Python standard library only, so it needs no image build and no
network access at startup.
"""

import base64
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# SEQUENCE { OID 1.2.840.113549.1.1.1 (rsaEncryption), NULL }
RSA_ALG_ID = bytes.fromhex("300d06092a864886f70d0101010500")
RSA_OID = bytes.fromhex("06092a864886f70d010101")


# --- tiny DER reader ---------------------------------------------------------


def _read_tlv(buf, offset):
    """Read one DER tag-length-value at offset. Returns (tag, value, next_offset)."""
    tag = buf[offset]
    length = buf[offset + 1]
    offset += 2
    if length & 0x80:
        num_bytes = length & 0x7F
        length = int.from_bytes(buf[offset:offset + num_bytes], "big")
        offset += num_bytes
    return tag, buf[offset:offset + length], offset + length


def _pem_to_der(text):
    body = "".join(
        line.strip()
        for line in text.strip().splitlines()
        if line.strip() and not line.strip().startswith("-----")
    )
    return base64.b64decode(body)


def _pkcs1_numbers(der):
    """(n, e) from a PKCS#1 RSAPrivateKey: SEQUENCE { version, n, e, d, ... }."""
    tag, seq, _ = _read_tlv(der, 0)
    if tag != 0x30:
        raise ValueError("expected a DER SEQUENCE in the RSA private key")
    _, _, offset = _read_tlv(seq, 0)               # version
    _, modulus, offset = _read_tlv(seq, offset)
    _, exponent, _ = _read_tlv(seq, offset)
    return int.from_bytes(modulus, "big"), int.from_bytes(exponent, "big")


def rsa_public_numbers(pem_text):
    """(n, e) from a PKCS#1 or PKCS#8 RSA private key PEM."""
    der = _pem_to_der(pem_text)
    tag, seq, _ = _read_tlv(der, 0)
    if tag != 0x30:
        raise ValueError("private key does not start with a DER SEQUENCE")
    _, _, offset = _read_tlv(seq, 0)               # version
    tag, value, next_offset = _read_tlv(seq, offset)
    if tag == 0x30:
        # PKCS#8: version, AlgorithmIdentifier, privateKey OCTET STRING
        if RSA_OID not in value:
            raise ValueError("only RSA keys are supported; this PKCS#8 key is not RSA")
        tag, inner, _ = _read_tlv(seq, next_offset)
        if tag != 0x04:
            raise ValueError("unexpected PKCS#8 structure: no privateKey OCTET STRING")
        return _pkcs1_numbers(inner)
    if tag == 0x02:
        # PKCS#1: the integer after the version is the modulus
        _, exponent, _ = _read_tlv(seq, next_offset)
        return int.from_bytes(value, "big"), int.from_bytes(exponent, "big")
    raise ValueError("unrecognized private key format")


# --- tiny DER writer, for the SubjectPublicKeyInfo PEM ----------------------


def _der_len(length):
    if length < 0x80:
        return bytes([length])
    encoded = length.to_bytes((length.bit_length() + 7) // 8, "big")
    return bytes([0x80 | len(encoded)]) + encoded


def _der_tlv(tag, payload):
    return bytes([tag]) + _der_len(len(payload)) + payload


def _uint_bytes(value):
    return value.to_bytes((value.bit_length() + 7) // 8 or 1, "big")


def _der_uint(value):
    encoded = _uint_bytes(value)
    if encoded[0] & 0x80:
        encoded = b"\x00" + encoded
    return _der_tlv(0x02, encoded)


def public_key_pem(n, e):
    rsa_public_key = _der_tlv(0x30, _der_uint(n) + _der_uint(e))
    spki = _der_tlv(0x30, RSA_ALG_ID + _der_tlv(0x03, b"\x00" + rsa_public_key))
    encoded = base64.b64encode(spki).decode()
    wrapped = "\n".join(encoded[i:i + 64] for i in range(0, len(encoded), 64))
    return "-----BEGIN PUBLIC KEY-----\n" + wrapped + "\n-----END PUBLIC KEY-----\n"


def _b64u_uint(value):
    return base64.urlsafe_b64encode(_uint_bytes(value)).decode().rstrip("=")


# --- documents --------------------------------------------------------------


def build_documents(pem_text, kid, alg, issuer):
    n, e = rsa_public_numbers(pem_text)
    pem = public_key_pem(n, e)
    jwk = {
        "kty": "RSA",
        "alg": alg,
        "use": "sig",
        "kid": kid,
        "n": _b64u_uint(n),
        "e": _b64u_uint(e),
    }
    base = issuer.rstrip("/")
    openid_configuration = {
        "issuer": issuer,
        "jwks_uri": base + "/.well-known/jwks.json",
        "authorization_endpoint": base + "/authorize",
        "token_endpoint": base + "/token",
        "userinfo_endpoint": base + "/userinfo",
        "response_types_supported": ["code", "id_token", "token"],
        "grant_types_supported": ["authorization_code", "refresh_token"],
        "subject_types_supported": ["public"],
        "id_token_signing_alg_values_supported": [alg],
        "scopes_supported": ["openid", "profile", "email", "ga4gh_passport_v1"],
    }
    return {
        "/jwt/keys": {"keys": [[kid, pem]]},
        "/jwks": {"keys": [jwk]},
        "/.well-known/jwks": {"keys": [jwk]},
        "/.well-known/jwks.json": {"keys": [jwk]},
        "/.well-known/openid-configuration": openid_configuration,
        "/_status": {"status": "ok", "issuer": issuer, "kid": kid},
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "mock-jwt-issuer/1.0"
    documents = {}

    def _respond(self, status, payload):
        body = json.dumps(payload, indent=2).encode() + b"\n"
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def _route(self):
        path = self.path.split("?", 1)[0]
        if len(path) > 1:
            path = path.rstrip("/")
        document = self.documents.get(path)
        if document is None:
            self._respond(404, {"error": "not found", "paths": sorted(self.documents)})
        else:
            self._respond(200, document)

    def do_GET(self):
        self._route()

    def do_HEAD(self):
        self._route()

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)


def main():
    key_path = os.environ.get("KEY_PATH", "/jwt-keys/jwt_private_key.pem")
    kid = os.environ.get("KID", "test-kid-01")
    alg = os.environ.get("ALG", "RS256")
    issuer = os.environ["ISSUER"]
    port = int(os.environ.get("PORT", "8080"))

    with open(key_path) as handle:
        pem_text = handle.read()
    Handler.documents = build_documents(pem_text, kid, alg, issuer)

    print("mock-jwt-issuer serving issuer=%s kid=%s on port %d" % (issuer, kid, port), flush=True)
    print("paths: %s" % ", ".join(sorted(Handler.documents)), flush=True)
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()


if __name__ == "__main__":
    main()
