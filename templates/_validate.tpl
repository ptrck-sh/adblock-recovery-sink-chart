{{- define "ars.validateHostname" -}}
{{- $host := . -}}
{{- if not $host -}}
{{- fail "hostname must be a non-empty lowercase hostname" -}}
{{- end -}}
{{- if contains "*" $host -}}
{{- fail (printf "hostname %q must not contain a wildcard" $host) -}}
{{- end -}}
{{- if hasPrefix "." $host -}}
{{- fail (printf "hostname %q must not begin with a dot" $host) -}}
{{- end -}}
{{- if not (contains "." $host) -}}
{{- fail (printf "hostname %q must contain a dot" $host) -}}
{{- end -}}
{{- if ne $host (lower $host) -}}
{{- fail (printf "hostname %q must be lowercase" $host) -}}
{{- end -}}
{{- if not (regexMatch "^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$" $host) -}}
{{- fail (printf "hostname %q must be an exact hostname" $host) -}}
{{- end -}}
{{- end -}}

{{- define "ars.validate" -}}
{{- if not .Values.interception.hosts -}}
{{- fail "interception.hosts must contain at least one hostname" -}}
{{- end -}}
{{- range $host := .Values.interception.hosts -}}
{{- if not $host -}}
{{- fail "interception.hosts entries must be non-empty lowercase hostnames" -}}
{{- end -}}
{{- if contains "*" $host -}}
{{- fail (printf "interception.hosts entry %q must not contain a wildcard" $host) -}}
{{- end -}}
{{- if hasPrefix "." $host -}}
{{- fail (printf "interception.hosts entry %q must not begin with a dot" $host) -}}
{{- end -}}
{{- if not (contains "." $host) -}}
{{- fail (printf "interception.hosts entry %q must contain a dot" $host) -}}
{{- end -}}
{{- if ne $host (lower $host) -}}
{{- fail (printf "interception.hosts entry %q must be lowercase" $host) -}}
{{- end -}}
{{- if not (regexMatch "^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$" $host) -}}
{{- fail (printf "interception.hosts entry %q must be an exact hostname" $host) -}}
{{- end -}}
{{- end -}}
{{- if .Values.hostname -}}
{{- include "ars.validateHostname" .Values.hostname -}}
{{- end -}}
{{- if and .Values.ingress.enabled (not .Values.ingress.hosts) (not .Values.hostname) -}}
{{- fail "ingress.enabled=true requires ingress.hosts or hostname" -}}
{{- end -}}
{{- range $entry := .Values.ingress.hosts -}}
{{- include "ars.validateHostname" $entry.host -}}
{{- end -}}
{{- if and .Values.gateway.enabled .Values.gateway.httpRoute.parentRefs (not .Values.hostname) -}}
{{- fail "gateway.httpRoute.parentRefs requires hostname" -}}
{{- end -}}
{{- $_ := required "pki.existingSecret must name an externally managed Secret" .Values.pki.existingSecret -}}
{{- range .Values.extraEnv -}}
{{- if hasPrefix "ARS_PKI_" (default "" .name) -}}
{{- fail "extraEnv entries must not use names beginning with ARS_PKI_" -}}
{{- end -}}
{{- end -}}
{{- if .Values.interception.traefik.enabled -}}
{{- if not (.Capabilities.APIVersions.Has "traefik.io/v1alpha1") -}}
{{- fail "interception.traefik.enabled=true requires the traefik.io/v1alpha1 API" -}}
{{- end -}}
{{- end -}}
{{- if and .Values.gateway.enabled .Values.gateway.tlsRoute.parentRefs -}}
{{- if not (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute") -}}
{{- fail "gateway.tlsRoute.parentRefs requires the gateway.networking.k8s.io/v1alpha2/TLSRoute API" -}}
{{- end -}}
{{- end -}}
{{- if and .Values.gateway.enabled .Values.gateway.httpRoute.parentRefs -}}
{{- if not (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute") -}}
{{- fail "gateway.httpRoute.parentRefs requires the gateway.networking.k8s.io/v1/HTTPRoute API" -}}
{{- end -}}
{{- end -}}
{{- if not (or .Values.interception.traefik.enabled (and .Values.gateway.enabled .Values.gateway.tlsRoute.parentRefs) (has .Values.service.sink.type (list "LoadBalancer" "NodePort"))) -}}
{{- fail "intercepted TLS must reach the sink unterminated" -}}
{{- end -}}
{{- if .Values.serviceMonitor.enabled -}}
{{- if not (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") -}}
{{- fail "serviceMonitor.enabled=true requires the monitoring.coreos.com/v1 API" -}}
{{- end -}}
{{- end -}}
{{- if .Values.certificate.enabled -}}
{{- if not .Values.hostname -}}
{{- fail "certificate.enabled=true requires hostname" -}}
{{- end -}}
{{- if not (.Capabilities.APIVersions.Has "cert-manager.io/v1") -}}
{{- fail "certificate.enabled=true requires the cert-manager.io/v1 API" -}}
{{- end -}}
{{- $_ := required "certificate.issuerRef.name is required when certificate.enabled=true" .Values.certificate.issuerRef.name -}}
{{- end -}}
{{- if .Values.vpa.enabled -}}
{{- if not (.Capabilities.APIVersions.Has "autoscaling.k8s.io/v1") -}}
{{- fail "vpa.enabled=true requires the autoscaling.k8s.io/v1 API" -}}
{{- end -}}
{{- end -}}
{{- if and .Values.hpa.enabled .Values.vpa.enabled (ne .Values.vpa.updateMode "Off") -}}
{{- fail "hpa.enabled and vpa.enabled require vpa.updateMode to be Off" -}}
{{- end -}}
{{- end -}}
