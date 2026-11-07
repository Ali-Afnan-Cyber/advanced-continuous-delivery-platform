{{/*
Env vars shared by the worker and the scheduler.
They use the same image as the api and must see the same secrets and URLs.
Values come from the api block, so nothing is copied.
PUBLIC_URL and ENABLE_SSL are not here: only the api uses them.
DB_PASSWORD must come before DATABASE_URL, because Kubernetes only expands
$(DB_PASSWORD) when it is defined earlier in the env list.
Call it with the root context:  include "saleor.celeryEnv" .
*/}}
{{- define "saleor.celeryEnv" -}}
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.api.secrets.appSecretName }}
      key: {{ .Values.api.secrets.secretKeyKey }}
- name: RSA_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.api.secrets.appSecretName }}
      key: {{ .Values.api.secrets.rsaKey }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.credentials.secretName }}
      key: {{ .Values.postgres.credentials.passwordKey }}
- name: DATABASE_URL
  value: {{ printf "postgres://%s:$(DB_PASSWORD)@%s:%v/%s" .Values.postgres.user .Values.postgres.name .Values.postgres.port .Values.postgres.database | quote }}
- name: CELERY_BROKER_URL
  value: {{ printf "redis://%s:%v/1" .Values.cache.name .Values.cache.port | quote }}
- name: DEBUG
  value: {{ .Values.api.env.DEBUG | quote }}
- name: ALLOWED_CLIENT_HOSTS
  value: {{ .Values.api.env.ALLOWED_CLIENT_HOSTS | quote }}
{{- end }}