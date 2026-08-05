CREATE TABLE IF NOT EXISTS vectis.s3_metadata (
  id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  bucket_name          TEXT NOT NULL,
  file_key             TEXT NOT NULL,
  file_name            TEXT GENERATED ALWAYS AS (
                         split_part(file_key, '/', -1)
                       ) STORED,
  folder_path          TEXT GENERATED ALWAYS AS (
                         CASE WHEN position('/' in file_key) > 0
                           THEN left(file_key, length(file_key) - length(split_part(file_key, '/', -1)) - 1)
                           ELSE ''
                         END
                       ) STORED,
  current_size_bytes   BIGINT NOT NULL,
  previous_size_bytes  BIGINT,
  size_delta_bytes     BIGINT GENERATED ALWAYS AS (
                         CASE WHEN previous_size_bytes IS NOT NULL
                           THEN current_size_bytes - previous_size_bytes
                           ELSE NULL
                         END
                       ) STORED,
  etag                 TEXT,
  md5_checksum         TEXT,
  storage_class        TEXT NOT NULL DEFAULT 'STANDARD',
  content_type         TEXT,
  event_type           TEXT NOT NULL CHECK (event_type IN ('CREATED', 'UPDATED')),
  s3_last_modified     TIMESTAMPTZ NOT NULL,
  detected_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  job_run_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_to_mq      BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (bucket_name, file_key, detected_at)
);
