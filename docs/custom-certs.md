# Steps for adding custom TLS certs to the Gen3 Helm deployment

In this example we'll be using `service.crt` as the signed certificate and `service.key` as the private key.

## 1) Encode in Base64

The first step involves encoding each file into their base64 representation. To do do we'll `cat` out the files, pipe the output through `base64`, and capture the results in temporary files for use in step 2 --

```sh
cat service.crt | base64> /tmp/crt
cat service.key | base64> /tmp/key
```

## 2) Add the certs to the Kubernetes managed secretes

Next we'll use the `kubectl` command to edit the `gen3-certs` secret. This command will open the yaml file containing the TLS cert information in your default editor.

```sh
kubectl edit secrets gen3-certs
```

Note: You can change the editor for this step using the `KUBE_EDITOR` environmental variable. For example you may choose to use VS Code to edit the secrets by running the following:

```sh
export KUBE_EDITOR="code -w"
```

## 3) Verify that the new certs are being used


```sh
echo | openssl s_client -showcerts -servername aced-training.compbio.ohsu.edu -connect aced-training.compbio.ohsu.edu:443 2>/dev/null | openssl x509 -inform pem -noout -text
```

## 4) Delete the temporary files 

Finally we'll clean up the temporary files we created in step 1 --

```sh
rm /tmp/crt
rm /tmp/key
```
