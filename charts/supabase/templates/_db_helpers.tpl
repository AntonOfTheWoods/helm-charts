{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Supabase image name
*/}}
{{- define "supabase.psql.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.psqlImage "global" .Values.global) }}
{{- end -}}

{{/*
Return the Postgres Hostname
*/}}
{{- define "supabase.database.host" -}}
{{- print .Values.externalDatabase.host -}}
{{- end -}}

{{/*
Return Postgres port
*/}}
{{- define "supabase.database.port" -}}
{{- print .Values.externalDatabase.port  -}}
{{- end -}}

{{/*
Return the Postgres Secret Name
*/}}
{{- define "supabase.database.secretName" -}}
{{- if .Values.externalDatabase.existingSecret -}}
    {{- print .Values.externalDatabase.existingSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "common.names.fullname" .) "externaldb" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Postgres Database Name
*/}}
{{- define "supabase.database.name" -}}
{{- print .Values.externalDatabase.database -}}
{{- end -}}

{{/*
Return the Postgres User
*/}}
{{- define "supabase.database.user" -}}
{{ default "supabase_admin" .Values.externalDatabase.user }}
{{- end -}}

{{/*
Retrieve key of the postgres secret
*/}}
{{- define "supabase.database.passwordKey" -}}
{{- if .Values.externalDatabase.existingSecret -}}
    {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- else -}}
        {{- print "password" -}}
    {{- end -}}
{{- else -}}
    {{- print "password" -}}
{{- end -}}
{{- end -}}

{{/*
reusable supabase db env vars
*/}}
{{- define "supabase.database.envvars" }}
- name: DB_NAME
  value: {{ include "supabase.database.name" . | quote }}
- name: DB_USER
  value: {{ include "supabase.database.user" . | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.database.secretName" . }}
      key: {{ include "supabase.database.passwordKey" . | quote }}
- name: DB_HOST
  value: {{ include "supabase.database.host" . | quote }}
- name: DB_PORT
  value: {{ include "supabase.database.port" . | quote }}

# vanilla postgres env vars
- name: PGDATABASE
  value: "$(DB_NAME)"
- name: PGUSER
  value: "$(DB_USER)"
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.database.secretName" . }}
      key: {{ include "supabase.database.passwordKey" . | quote }}
- name: PGHOST
  value: "$(DB_HOST)"
- name: PGPORT
  value: "$(DB_PORT)"

# studio specific vars
- name: POSTGRES_DATABASE
  value: "$(DB_NAME)"
- name: POSTGRES_DB
  value: "$(DB_NAME)"
- name: POSTGRES_USER_READ_WRITE
  value: "$(DB_USER)"
- name: POSTGRES_USER_READ_ONLY
  value: "$(DB_USER)"
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.database.secretName" . }}
      key: {{ include "supabase.database.passwordKey" . | quote }}
- name: POSTGRES_HOST
  value: "$(DB_HOST)"
- name: POSTGRES_PORT
  value: "$(DB_PORT)"

# pgmeta specific vars
- name: PG_META_DB_USER
  value: "$(DB_USER)"
- name: PG_META_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.database.secretName" . }}
      key: {{ include "supabase.database.passwordKey" . | quote }}
- name: PG_META_DB_HOST
  value: "$(DB_HOST)"
- name: PG_META_DB_PORT
  value: "$(DB_PORT)"
- name: PG_META_DB_NAME
  value: "$(DB_NAME)"
- name: PG_META_DB_SSL_MODE
  value: {{ .Values.dbSSL | quote }}
{{- end -}}

{{/*
reusable db check-db-ready
*/}}
{{- define "supabase.database.checkdbready" }}
- name: check-supabase-db-ready
  image: {{ template "supabase.psql.image" . }}
  imagePullPolicy: {{ .Values.psqlImage.pullPolicy }}
  {{- if .Values.auth.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.auth.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  command: ['sh', '-c',
    'until psql -c "select 1;";
    do echo waiting for database; sleep 2; done;']
  env:
    {{ include "supabase.database.envvars" . | indent 4 }}
{{- end -}}

{{/*
Return the Postgres Analyticsdb Hostname
*/}}
{{- define "supabase.analyticsdb.database.host" -}}
{{- print .Values.analyticsdb.host -}}
{{- end -}}

{{/*
Return postgres Analyticsdb port
*/}}
{{- define "supabase.analyticsdb.database.port" -}}
{{- print .Values.analyticsdb.port  -}}
{{- end -}}

{{/*
Return the Postgres Analyticsdb Secret Name
*/}}
{{- define "supabase.analyticsdb.database.secretName" -}}
{{- if .Values.analyticsdb.auth.existingSecret -}}
    {{- print .Values.analyticsdb.auth.existingSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "common.names.fullname" .) "analyticsdb-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Postgres Analyticsdb Database Name
*/}}
{{- define "supabase.analyticsdb.database.name" -}}
{{- print .Values.analyticsdb.database -}}
{{- end -}}

{{/*
Return the Analyticsdb Postgres User
*/}}
{{- define "supabase.analyticsdb.database.user" -}}
{{- print .Values.analyticsdb.auth.user -}}
{{- end -}}

{{/*
reusable supabase analyticsdb env vars
*/}}
{{- define "supabase.analyticsdb.database.envvars" }}
- name: PGUSER
  value: {{ include "supabase.analyticsdb.database.user" . | quote }}
- name: PGHOST
  value: {{ include "supabase.analyticsdb.database.host" . | quote }}
- name: PGPORT
  value: {{ include "supabase.analyticsdb.database.port" . | quote }}
- name: PGDATABASE
  value: {{ include "supabase.analyticsdb.database.name" . | quote }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.analyticsdb.database.secretName" . }}
      key: {{ include "supabase.analyticsdb.database.passwordKey" . | quote }}
{{- end -}}

{{/*
reusable db check-db-ready
*/}}
{{- define "supabase.analyticsdb.database.checkdbready" }}
- name: check-analyticsdb-db-ready
  image: {{ template "supabase.psql.image" . }}
  imagePullPolicy: {{ .Values.psqlImage.pullPolicy }}
  {{- if .Values.auth.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.auth.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  command: ['sh', '-c',
    'until psql -c "select 1;";
    do echo waiting for database; sleep 2; done;']
  env:
    {{ include "supabase.analyticsdb.database.envvars" . | indent 4 }}
{{- end -}}

{{/*
Retrieve key of the Analyticsdb postgres secret
*/}}
{{- define "supabase.analyticsdb.database.passwordKey" -}}
{{- if .Values.analyticsdb.auth.existingSecret -}}
    {{- if .Values.analyticsdb.auth.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.analyticsdb.auth.existingSecretPasswordKey -}}
    {{- else -}}
        {{- print "password" -}}
    {{- end -}}
{{- else -}}
    {{- print "password" -}}
{{- end -}}
{{- end -}}
