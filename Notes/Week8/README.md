# Week 8 — Helm (The Kubernetes Package Manager)

> If Week 7 taught you how to hand-write every manifest, Week 8 teaches you how to stop. Helm packages, parameterises, versions, and safely rolls back Kubernetes releases.

## Roadmap

```mermaid
flowchart LR
  D50["Day 50<br/>Why Helm?"]
  D51["Day 51<br/>Install a chart"]
  D52["Day 52<br/>Your first chart"]
  D53["Day 53<br/>Dependencies"]
  D54["Day 54<br/>Upgrade & Rollback"]
  D55["Day 55<br/>Templates & Logic"]
  D56["Day 56<br/>Weekly Challenge"]
  D50 --> D51 --> D52 --> D53 --> D54 --> D55 --> D56
```

## Index

- [Day 50 — Why Helm?](day50_helm-intro.md)
- [Day 51 — Installing Your First Chart (Bitnami MariaDB)](day51_helm.md)
- [Day 52 — Your First Chart (`helm create`)](day52_first-chart.md)
- [Day 53 — Chart Dependencies (sub-charts, lockfile)](day53_chart-dependencies.md)
- [Day 54 — Upgrade & Rollback (the safety net)](day54_helm-upgrade-and-rollback.md)
- [Day 55 — Templates & Logic (`if`, `range`, helpers, Sprig)](day55_templates.md)
- [Day 56 — Weekly Challenge: Production-Ready Chart](day56_weekly-challenge.md)

## Related resources

- `Resources/Week8/weekly_challenge/` — place your final `my-guestbook` chart there.

## Cheat-sheet

```bash
# Repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo <name>
helm show values <repo>/<chart>

# Install / uninstall
helm install NAME CHART [--set k=v] [-f file.yaml]
helm upgrade --install NAME CHART --atomic --wait --timeout 10m
helm uninstall NAME

# Inspect
helm list [-A]
helm status NAME
helm history NAME
helm get values NAME --revision N
helm get manifest NAME

# Revert
helm rollback NAME [REVISION]

# Develop locally
helm create mychart
helm lint ./mychart
helm template ./mychart [--set k=v]
helm dependency update ./mychart

# Common flags
--dry-run --debug       # preview without applying
--atomic                # roll back automatically on fail
--wait                  # block until resources ready
--cleanup-on-fail       # delete resources created by a failed upgrade
--create-namespace      # create the NS if missing
```
