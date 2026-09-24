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

## Configuration

Defaults are cluster-neutral. Configure routing integrations and allowed network peers for the cluster where the chart runs.

A k3s installation using the bundled Traefik can restrict sink and ops access to Traefik in `kube-system`:

```yaml
networkPolicy:
  ingressFrom:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          app.kubernetes.io/name: traefik
```

If Traefik filters CRDs by ingress class, set its matching annotation:

```yaml
routing:
  traefik:
    annotations:
      kubernetes.io/ingress.class: traefik-example
```

For enrollment TLS, let Traefik resolve certificates or enable cert-manager with an issuer:

```yaml
routing:
  traefik:
    certResolver: example-resolver
```

```yaml
certificate:
  enabled: true
  issuerRef:
    name: example-issuer
    kind: ClusterIssuer
```

Supply additional application configuration with `extraEnv`:

```yaml
extraEnv:
  - name: ARS_LIMITS_SHUTDOWN_DELAY
    value: 10s
```

## PKI Secret

Set `pki.existingSecret` to an externally managed Secret containing `root.crt`, `intermediate.crt`, and `intermediate.key` by default. Override those key names with `pki.keys`. The chart never creates this Secret. Its values are consumed as individual environment variables. Secret changes require an explicit Deployment rollout.

## NetworkPolicy

NetworkPolicy is enabled by default. It allows ingress on the sink and ops ports from any source unless `networkPolicy.ingressFrom` is configured, and denies all egress, including DNS.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| certificate.enabled | bool | `false` |  |
| certificate.issuerRef | object | `{}` |  |
| containerPorts.ops | int | `8080` |  |
| containerPorts.sink | int | `8443` |  |
| enrollment.host | string | `""` |  |
| enrollment.tls.secretName | string | `""` |  |
| extraEnv | list | `[]` |  |
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
| livenessProbe.httpGet.path | string | `"/healthz"` |  |
| livenessProbe.httpGet.port | string | `"ops"` |  |
| logFormat | string | `"json"` |  |
| logLevel | string | `"info"` |  |
| nameOverride | string | `""` |  |
| networkPolicy.enabled | bool | `true` |  |
| networkPolicy.ingressFrom | list | `[]` |  |
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
| priorityClassName | string | `""` |  |
| profiles[0] | string | `"adshield"` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | string | `"ops"` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"64Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| revisionHistoryLimit | int | `3` |  |
| routing.gateway.httpParentRefs | list | `[]` |  |
| routing.gateway.tlsParentRefs | list | `[]` |  |
| routing.ingress.annotations | object | `{}` |  |
| routing.ingress.className | string | `""` |  |
| routing.mode | string | `"traefik"` |  |
| routing.traefik.annotations | object | `{}` |  |
| routing.traefik.certResolver | string | `""` |  |
| routing.traefik.enrollmentEntryPoints | list | `[]` |  |
| routing.traefik.entryPoints[0] | string | `"websecure"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| service.ops.annotations | object | `{}` |  |
| service.ops.labels | object | `{}` |  |
| service.ops.port | int | `8080` |  |
| service.sink.annotations | object | `{}` |  |
| service.sink.externalTrafficPolicy | string | `""` |  |
| service.sink.labels | object | `{}` |  |
| service.sink.loadBalancerIP | string | `""` |  |
| service.sink.port | int | `443` |  |
| service.sink.type | string | `"ClusterIP"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| strategy | object | `{}` |  |
| terminationGracePeriodSeconds | int | `30` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| vpa.enabled | bool | `false` |  |
| vpa.maxAllowed | object | `{}` |  |
| vpa.minAllowed | object | `{}` |  |
| vpa.updateMode | string | `"Off"` |  |

## License

MIT
