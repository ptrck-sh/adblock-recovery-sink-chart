# adblock-recovery-sink-chart

![Version: 0.3.0-rc.1](https://img.shields.io/badge/Version-0.3.0--rc.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.0-rc.1](https://img.shields.io/badge/AppVersion-0.2.0--rc.1-informational?style=flat-square)

Helm chart for [adblock-recovery-sink](https://gitlab.com/ptrck-sh/adblock-recovery-sink), which serves harmless replacements for known anti-adblock loader resources behind DNS rewrites that you manage on your LAN resolver.

Setup, PKI and enrollment, DNS rewrites, Chrome Local Network Access and troubleshooting are covered in the [application documentation](https://ptrck-sh.gitlab.io/adblock-recovery-sink). This README documents the chart values only.

The chart mounts no volumes. Application configuration is supplied only through environment variables.

## Intercepted hosts

`interception.hosts` lists every known Ad-Shield loader host. It drives the passthrough routes and `ARS_HOSTS`. The sink serves only the hosts its CA name constraints permit and logs the rest as skipped, so a CA created for `html-load.com` alone keeps working and covers `html-load.com` and its subdomains. Create a CA for all loader domains to cover the full list, and add a DNS rewrite for each host you want intercepted.

## Toast

`toast.enabled` appends a small notice to each served loader that appears in the top-right corner when the sink answers the page's handshake. `toast.details` adds the host and path of the neutralized script. Both default to `false`.

## Routing

TLS interception and the public web hostname are configured separately. The sink listens on TLS port 443; the plain HTTP ops listener is port 8443. The chart sets `net.ipv4.ip_unprivileged_port_start` to the lowest container port below 1024 so the non-root container can bind it. Additional pod sysctls can be set with `podSecurityContext.sysctls`.

The ops Service exposes `/status`, `/install`, `/ca.crt`, `/ca.pem`, `/ca-chain.pem`, and `/fingerprint`; every public web route uses those exact paths. `/metrics`, `/healthz`, and `/readyz` are never exposed externally.

Defaults use Traefik `IngressRoute` and TLS passthrough for intercepted hosts. When `ingress.hosts` is empty, the web route uses `hostname` when it is set.

```yaml
hostname: status.example.com
ingress:
  kind: IngressRoute
  entryPoints:
    - websecure
  certResolver: example-resolver
```

For nginx, choose `Ingress` and enable its SSL passthrough annotation. nginx must also run with `--enable-ssl-passthrough`.

```yaml
hostname: status.example.com
ingress:
  kind: Ingress
  className: nginx
  passthrough:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
  tls:
    - secretName: status-tls
      hosts:
        - status.example.com
```

If a standard Ingress does not terminate interception traffic, leave passthrough disabled and expose the sink with a LoadBalancer or NodePort.

```yaml
ingress:
  kind: Ingress
  passthrough:
    enabled: false
service:
  sink:
    type: LoadBalancer
```

Gateway API routes are configured independently. A TLSRoute is created only when `tlsRoute.parentRefs` is set; an HTTPRoute is created only when `httpRoute.parentRefs` is set. Disable ingress when Gateway API is the selected route provider.

```yaml
hostname: status.example.com
ingress:
  enabled: false
gateway:
  enabled: true
  tlsRoute:
    parentRefs:
      - name: shared-gateway
        sectionName: tls
  httpRoute:
    parentRefs:
      - name: shared-gateway
        sectionName: https
```

To create a certificate, enable cert-manager and set an issuer. The Certificate uses `hostname` and writes `certificate.secretName`, or `<fullname>-tls` when it is empty. Reference that Secret explicitly from `ingress.tls` or from your Gateway listener.

```yaml
hostname: status.example.com
certificate:
  enabled: true
  secretName: status-tls
  issuerRef:
    name: example-issuer
    kind: ClusterIssuer
```

## Configuration

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

If Traefik filters CRDs by ingress class, set `ingress.className`:

```yaml
ingress:
  className: traefik-example
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
| certificate.secretName | string | `""` |  |
| containerPorts.ops | int | `8443` |  |
| containerPorts.sink | int | `443` |  |
| extraEnv | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| gateway.annotations | object | `{}` |  |
| gateway.enabled | bool | `false` |  |
| gateway.httpRoute.parentRefs | list | `[]` |  |
| gateway.tlsRoute.parentRefs | list | `[]` |  |
| hostname | string | `""` |  |
| hpa.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `3` |  |
| hpa.minReplicas | int | `1` |  |
| hpa.targetCPUUtilizationPercentage | int | `80` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/ptrck-sh/adblock-recovery-sink"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.certResolver | string | `""` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `true` |  |
| ingress.entryPoints[0] | string | `"websecure"` |  |
| ingress.hosts | list | `[]` |  |
| ingress.kind | string | `"IngressRoute"` |  |
| ingress.passthrough.annotations | object | `{}` |  |
| ingress.passthrough.enabled | bool | `false` |  |
| ingress.tls | list | `[]` |  |
| interception.hosts[0] | string | `"html-load.com"` |  |
| interception.hosts[10] | string | `"css-load.com"` |  |
| interception.hosts[11] | string | `"d37j8pfxu2iogi.cloudfront.net"` |  |
| interception.hosts[1] | string | `"fb.html-load.com"` |  |
| interception.hosts[2] | string | `"1.s.html-load.com"` |  |
| interception.hosts[3] | string | `"3.s.html-load.com"` |  |
| interception.hosts[4] | string | `"8.s.html-load.com"` |  |
| interception.hosts[5] | string | `"content-loader.com"` |  |
| interception.hosts[6] | string | `"fb.content-loader.com"` |  |
| interception.hosts[7] | string | `"1.content-loader.com"` |  |
| interception.hosts[8] | string | `"2.content-loader.com"` |  |
| interception.hosts[9] | string | `"js-loader.com"` |  |
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
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| service.ops.annotations | object | `{}` |  |
| service.ops.labels | object | `{}` |  |
| service.ops.port | int | `8443` |  |
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
| toast.details | bool | `false` |  |
| toast.enabled | bool | `false` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| vpa.enabled | bool | `false` |  |
| vpa.maxAllowed | object | `{}` |  |
| vpa.minAllowed | object | `{}` |  |
| vpa.updateMode | string | `"Off"` |  |

## License

MIT
