{{/*
Expand the name of the chart.
*/}}
{{- define "assetcore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "assetcore.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "assetcore.labels" -}}
app.kubernetes.io/name: {{ include "assetcore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "assetcore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "assetcore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
{{- end }}

{{/*
Generate standard security context
*/}}
{{- define "assetcore.securityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 65534
runAsGroup: 65534
{{- end }}

{{/*
Generate standard pod security context
*/}}
{{- define "assetcore.podSecurityContext" -}}
runAsNonRoot: true
runAsUser: 65534
runAsGroup: 65534
fsGroup: 65534
seccompProfile:
  type: RuntimeDefault
{{- end }}