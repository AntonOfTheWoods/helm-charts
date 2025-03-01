{{/* vim: set filetype=mustache: */}}

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

{{- define "supabase.waitForDBInitContainer" -}}
# We need to wait for the postgres database to be ready in order to start with Supabase.
# As it is a ReplicaSet, we need that all nodes are configured in order to start with
# the application or race conditions can occur
- name: wait-for-db
  image: {{ template "supabase.psql.image" . }}
  imagePullPolicy: {{ .Values.psqlImage.pullPolicy }}
  {{- if .Values.auth.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.auth.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  command:
    - bash
    - -ec
    - |
      #!/bin/bash

      set -o errexit
      set -o nounset
      set -o pipefail

      . /opt/bitnami/scripts/liblog.sh
      . /opt/bitnami/scripts/libvalidations.sh
      . /opt/bitnami/scripts/libpostgresql.sh
      . /opt/bitnami/scripts/postgresql-env.sh

      info "Waiting for host $DB_HOST"
      psql_is_ready() {
          if ! PGCONNECT_TIMEOUT="5" PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "SELECT 1"; then
             return 1
          fi
          return 0
      }
      if ! retry_while "debug_execute psql_is_ready"; then
          error "Database not ready"
          exit 1
      fi
      info "Database is ready"
  env:
    - name: BITNAMI_DEBUG
      value: {{ ternary "true" "false" (or .Values.psqlImage.debug .Values.diagnosticMode.enabled) | quote }}
    {{ include "supabase.database.envvars" . | indent 4 }}
  volumeMounts:
    - name: empty-dir
      mountPath: /tmp
      subPath: tmp-dir
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
- name: DB_USER
  value: {{ include "supabase.database.user" . | quote }}
- name: DB_HOST
  value: {{ include "supabase.database.host" . | quote }}
- name: DB_PORT
  value: {{ include "supabase.database.port" . | quote }}
- name: DB_NAME
  value: {{ include "supabase.database.name" . | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.database.secretName" . }}
      key: {{ include "supabase.database.passwordKey" . | quote }}
- name: DB_SSL
  value: {{ .Values.dbSSL | quote }}

# vanilla postgres env vars
- name: PGDATABASE
  value: {{ include "supabase.database.name" . | quote }}
- name: PGUSER
  value: {{ include "supabase.database.user" . | quote }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "supabase.database.secretName" . }}
      key: {{ include "supabase.database.passwordKey" . | quote }}
- name: PGHOST
  value: {{ include "supabase.database.host" . | quote }}
- name: PGPORT
  value: {{ include "supabase.database.port" . | quote }}

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
{{- print .Values.externalDatabaseAnalyticsdb.host -}}
{{- end -}}

{{/*
Return postgres Analyticsdb port
*/}}
{{- define "supabase.analyticsdb.database.port" -}}
{{- print .Values.externalDatabaseAnalyticsdb.port  -}}
{{- end -}}

{{/*
Return the Postgres Analyticsdb Secret Name
*/}}
{{- define "supabase.analyticsdb.database.secretName" -}}
{{- if .Values.externalDatabaseAnalyticsdb.existingSecret -}}
    {{- print .Values.externalDatabaseAnalyticsdb.existingSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "common.names.fullname" .) "analyticsdb-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Postgres Analyticsdb Database Name
*/}}
{{- define "supabase.analyticsdb.database.name" -}}
{{- print .Values.externalDatabaseAnalyticsdb.database -}}
{{- end -}}

{{/*
Return the Analyticsdb Postgres User
*/}}
{{- define "supabase.analyticsdb.database.user" -}}
{{- print .Values.externalDatabaseAnalyticsdb.user -}}
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
{{- if .Values.externalDatabaseAnalyticsdb.existingSecret -}}
    {{- if .Values.externalDatabaseAnalyticsdb.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.externalDatabaseAnalyticsdb.existingSecretPasswordKey -}}
    {{- else -}}
        {{- print "password" -}}
    {{- end -}}
{{- else -}}
    {{- print "password" -}}
{{- end -}}
{{- end -}}
