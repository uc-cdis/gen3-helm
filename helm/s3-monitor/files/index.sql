CREATE INDEX IF NOT EXISTS idx_s3_metadata_latest
  ON vectis.s3_metadata (bucket_name, file_key, detected_at DESC);
