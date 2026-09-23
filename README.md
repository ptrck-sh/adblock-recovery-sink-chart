# adblock-recovery-sink-chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Helm chart for [adblock-recovery-sink](https://gitlab.com/ptrck-sh/adblock-recovery-sink), which serves harmless replacements for known anti-adblock loader resources behind DNS rewrites that you manage on your LAN resolver.

Scaffold only. No resources are rendered yet.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.gitlab.com/ptrck-sh/adblock-recovery-sink"` |  |
| image.tag | string | `""` |  |
| nameOverride | string | `""` |  |

## License

MIT
