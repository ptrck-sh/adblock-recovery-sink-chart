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
{{- if not (has .Values.routing.mode (list "traefik" "gateway" "ingress")) -}}
{{- fail "routing.mode must be one of traefik, gateway, or ingress" -}}
{{- end -}}
{{- $_ := required "pki.existingSecret must name an externally managed Secret" .Values.pki.existingSecret -}}
{{- if eq .Values.routing.mode "traefik" -}}
{{- if not (.Capabilities.APIVersions.Has "traefik.io/v1alpha1") -}}
{{- fail "routing.mode=traefik requires the traefik.io/v1alpha1 API" -}}
{{- end -}}
{{- end -}}
{{- if eq .Values.routing.mode "gateway" -}}
{{- if not .Values.routing.gateway.tlsParentRefs -}}
{{- fail "routing.gateway.tlsParentRefs must not be empty when routing.mode=gateway" -}}
{{- end -}}
{{- if .Values.enrollment.host }}
{{- if not .Values.routing.gateway.httpParentRefs -}}
{{- fail "routing.gateway.httpParentRefs must not be empty when enrollment.host is set in gateway mode" -}}
{{- end -}}
{{- end -}}
{{- if not (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute") -}}
{{- fail "routing.mode=gateway requires the gateway.networking.k8s.io/v1alpha2/TLSRoute API" -}}
{{- end -}}
{{- if .Values.enrollment.host }}
{{- if not (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute") -}}
{{- fail "routing.mode=gateway with enrollment.host requires the gateway.networking.k8s.io/v1/HTTPRoute API" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if eq .Values.routing.mode "ingress" -}}
{{- if not (has .Values.service.sink.type (list "LoadBalancer" "NodePort")) -}}
{{- fail "routing.mode=ingress requires service.sink.type to be LoadBalancer or NodePort because standard Ingress cannot pass TLS through" -}}
{{- end -}}
{{- end -}}
{{- if .Values.serviceMonitor.enabled -}}
{{- if not (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") -}}
{{- fail "serviceMonitor.enabled=true requires the monitoring.coreos.com/v1 API" -}}
{{- end -}}
{{- end -}}
{{- if .Values.certificate.enabled -}}
{{- if not .Values.enrollment.host -}}
{{- fail "certificate.enabled=true requires enrollment.host" -}}
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
