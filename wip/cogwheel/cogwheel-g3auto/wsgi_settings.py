DEBUG = False
SQLALCHEMY_DATABASE_URI = "postgresql://{{ .Values.postgres.username }}:{{ .Values.postgres.password }}@{{ Host}}/{{ DBname }}"