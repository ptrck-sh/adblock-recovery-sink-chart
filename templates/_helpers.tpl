{{- define "ars.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ars.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ars.labels" -}}
app.kubernetes.io/name: {{ include "ars.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "ars.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ars.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "ars.image" -}}
{{- if .Values.image.digest -}}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest -}}
{{- else -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "ars.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "ars.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "ars.sniMatch" -}}
{{- range $index, $host := .Values.interception.hosts -}}
{{- if $index }} || {{ end -}}HostSNI(`{{ $host }}`)
{{- end -}}
{{- end -}}

{{- define "ars.enrollmentMatch" -}}
Host(`{{ .Values.enrollment.host }}`) && (Path(`/install`) || Path(`/ca.crt`) || Path(`/ca.pem`) || Path(`/ca-chain.pem`) || Path(`/fingerprint`))
{{- end -}}
