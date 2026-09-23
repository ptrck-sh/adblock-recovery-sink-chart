# adblock-recovery-sink-chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Helm chart for [adblock-recovery-sink](https://gitlab.com/ptrck-sh/adblock-recovery-sink), which serves harmless replacements for known anti-adblock loader resources behind DNS rewrites that you manage on your LAN resolver.

The chart mounts no volumes. Application configuration is supplied only through environment variables.

## Routing

| Mode | Interception | Enrollment |
| --- | --- | --- |
| `traefik` | Traefik `IngressRouteTCP` with TLS passthrough | Traefik `IngressRoute` |
| `gateway` | Gateway API `TLSRoute` | Gateway API `HTTPRoute` |
| `ingress` | Expose the sink Service directly as `LoadBalancer` or `NodePort` | Standard Kubernetes `Ingress` |

Enrollment routes are created only when `enrollment.host` is set. They expose only the enrollment paths.

## PKI Secret

Set `pki.existingSecret` to an externally managed Secret containing `root.crt`, `intermediate.crt`, and `intermediate.key` by default. Override those key names with `pki.keys`. The chart never creates this Secret. Its values are consumed as individual environment variables. Secret changes require an explicit Deployment rollout.

## NetworkPolicy

NetworkPolicy is enabled by default. It allows ingress from the configured routing peers and denies all egress, including DNS.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| certificate.enabled | bool | `false` |  |
| certificate.issuerRef | object | `{}` |  |
| enrollment.host | string | `""` |  |
| enrollment.tls.secretName | string | `"adblock-recovery-sink-enrollment-tls"` |  |
| fullnameOverride | string | `""` |  |
| hpa.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `3` |  |
| hpa.minReplicas | int | `1` |  |
| hpa.targetCPUUtilizationPercentage | int | `80` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.gitlab.com/ptrck-sh/adblock-recovery-sink"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| interception.hosts[0] | string | `"html-load.com"` |  |
| logFormat | string | `"json"` |  |
| logLevel | string | `"info"` |  |
| nameOverride | string | `""` |  |
| networkPolicy.enabled | bool | `true` |  |
| networkPolicy.ingressFrom[0].namespaceSelector.matchLabels."kubernetes.io/metadata.name" | string | `"traefik"` |  |
| networkPolicy.metricsFrom | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| pdb.enabled | bool | `false` |  |
| pdb.minAvailable | int | `1` |  |
| pki.existingSecret | string | `""` |  |
| pki.keys.intermediateCert | string | `"intermediate.crt"` |  |
| pki.keys.intermediateKey | string | `"intermediate.key"` |  |
| pki.keys.rootCert | string | `"root.crt"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `65532` |  |
| podSecurityContext.runAsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| profiles[0] | string | `"adshield"` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"64Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| routing.gateway.httpParentRefs | list | `[]` |  |
| routing.gateway.tlsParentRefs | list | `[]` |  |
| routing.ingress.annotations | object | `{}` |  |
| routing.ingress.className | string | `""` |  |
| routing.mode | string | `"traefik"` |  |
| routing.traefik.annotations | object | `{}` |  |
| routing.traefik.entryPoints[0] | string | `"websecure"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| service.sink.annotations | object | `{}` |  |
| service.sink.externalTrafficPolicy | string | `""` |  |
| service.sink.loadBalancerIP | string | `""` |  |
| service.sink.type | string | `"ClusterIP"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| vpa.enabled | bool | `false` |  |
| vpa.maxAllowed | object | `{}` |  |
| vpa.minAllowed | object | `{}` |  |
| vpa.updateMode | string | `"Off"` |  |

## License

MIT
