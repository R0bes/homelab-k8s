{{- define "ops.fullname" -}}
{{- printf "oauth2-proxy-%s" .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
