# Day 63: Weekly Challenge — Observable Guestbook

> **Goal**: Make the Week 7 Guestbook fully observable: custom metrics, a Grafana dashboard covering the RED method, and an Alertmanager rule that fires on a 5xx spike.

## The Challenge

Take the Guestbook from Week 7 (or your Helm chart from Week 8) and wire it into the full observability stack. By the end you should be able to answer any of these questions from Grafana alone — without touching `kubectl logs`:

- Is the Guestbook healthy right now?
- What is the current request rate and error ratio?
- What is the p99 response time over the last hour?
- Are there any error log lines in the last 10 minutes?
- If error rate spikes above 5%, am I alerted?

---

## Deliverables

Place everything under `Resources/Week9/weekly_challenge/`:

```
Resources/Week9/weekly_challenge/
├── helm/
│   └── guestbook/            # Updated Helm chart (from Week 8) with /metrics port
├── k8s/
│   ├── service-monitor.yaml  # ServiceMonitor for guestbook
│   └── alert-rules.yaml      # PrometheusRule with 3+ alert rules
├── grafana/
│   └── dashboard.json        # Exported Grafana dashboard JSON
└── README.md                 # How to deploy + screenshot of dashboard
```

---

## Step-by-Step Guide

### Step 1 — Expose `/metrics` from the Frontend

If the guestbook frontend is a simple app that doesn't expose Prometheus metrics, wrap it with an **nginx-prometheus-exporter** sidecar, or replace the frontend image with one that does. For the challenge, add a sidecar:

```yaml
# In your Helm chart's deployment.yaml template
containers:
  - name: frontend
    image: gcr.io/google-samples/gb-frontend:v5
    ports:
      - containerPort: 80
        name: http

  - name: nginx-exporter
    image: nginx/nginx-prometheus-exporter:0.11.0
    args:
      - "-nginx.scrape-uri=http://localhost:80/nginx_status"
    ports:
      - containerPort: 9113
        name: metrics
```

Enable `nginx_status` in the frontend's nginx config via a ConfigMap:

```nginx
server {
  location /nginx_status {
    stub_status on;
    allow 127.0.0.1;
    deny all;
  }
}
```

### Step 2 — Add the `metrics` Port to the Service

```yaml
# service.yaml (in Helm chart)
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
    - name: metrics
      port: 9113
      targetPort: 9113
```

### Step 3 — Create the ServiceMonitor

```yaml
# k8s/service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: guestbook
  namespace: monitoring
  labels:
    release: kube-prom
spec:
  namespaceSelector:
    matchNames:
      - default
  selector:
    matchLabels:
      app: guestbook
  endpoints:
    - port: metrics
      interval: 15s
      path: /metrics
```

Verify: `Prometheus UI → Status → Targets` should show `guestbook` as UP.

### Step 4 — Write the PrometheusRule

```yaml
# k8s/alert-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: guestbook-alerts
  namespace: monitoring
  labels:
    release: kube-prom
spec:
  groups:
    - name: guestbook.red
      interval: 30s
      rules:
        # Recording rules (pre-compute for dashboard performance)
        - record: guestbook:nginx_requests:rate5m
          expr: rate(nginx_http_requests_total{service="guestbook-frontend"}[5m])

        - record: guestbook:nginx_errors:ratio5m
          expr: |
            rate(nginx_http_requests_total{service="guestbook-frontend", status=~"5.."}[5m])
              / rate(nginx_http_requests_total{service="guestbook-frontend"}[5m])

        # Alert: high error rate
        - alert: GuestbookHighErrorRate
          expr: guestbook:nginx_errors:ratio5m > 0.05
          for: 2m
          labels:
            severity: critical
            service: guestbook
          annotations:
            summary: "Guestbook error rate above 5%"
            description: >
              Error ratio is {{ $value | humanizePercentage }} for service guestbook.
              This has been above 5% for 2 minutes.
            runbook_url: "https://github.com/yourname/devops-course/wiki/guestbook-high-errors"

        # Alert: no traffic (potential outage)
        - alert: GuestbookNoTraffic
          expr: guestbook:nginx_requests:rate5m == 0
          for: 5m
          labels:
            severity: warning
            service: guestbook
          annotations:
            summary: "Guestbook is receiving no traffic"
            description: "No requests in the last 5 minutes — app may be down or unreachable."

        # Alert: pod not ready
        - alert: GuestbookPodNotReady
          expr: |
            kube_pod_status_ready{namespace="default", condition="true"}
              * on (pod) group_left()
            kube_pod_labels{namespace="default", label_app="guestbook"} == 0
          for: 3m
          labels:
            severity: critical
            service: guestbook
          annotations:
            summary: "Guestbook pod {{ $labels.pod }} not ready"
```

### Step 5 — Build the Grafana Dashboard

Create a dashboard called **"Guestbook — RED"** with these panels:

| Row | Panel | Query |
|-----|-------|-------|
| Overview | Request Rate (time series) | `guestbook:nginx_requests:rate5m` |
| Overview | Error Ratio (stat, red if > 1%) | `guestbook:nginx_errors:ratio5m` |
| Overview | Active Connections (gauge) | `nginx_connections_active{service="guestbook-frontend"}` |
| Health | Pod Ready Count (stat) | `count(kube_pod_status_ready{namespace="default",condition="true"} * on(pod) kube_pod_labels{label_app="guestbook"})` |
| Logs | Error logs (Logs panel, Loki) | `{namespace="default", pod=~"guestbook.*"} \|= "error"` |

Add a `$pod` variable backed by `label_values(kube_pod_labels{label_app="guestbook"}, pod)` so each panel can be filtered to a single pod.

Export the dashboard: Dashboard → Share → Export → Save to file → commit as `grafana/dashboard.json`.

### Step 6 — Trigger and Verify Alerts

```bash
# Simulate high error rate: send traffic with deliberate bad requests
# (e.g. if your app has an /error endpoint, or scale down the backend)
kubectl scale deployment guestbook-redis-follower --replicas=0

# Watch alert transition: pending → firing
kubectl -n monitoring port-forward svc/kube-prom-kube-prometheus-stack-prometheus 9090:9090
# Prometheus UI → Alerts — watch GuestbookHighErrorRate go pending → firing

# Verify Alertmanager received it
kubectl -n monitoring port-forward svc/kube-prom-kube-prometheus-stack-alertmanager 9093:9093
# http://localhost:9093 → Alerts

# Restore
kubectl scale deployment guestbook-redis-follower --replicas=2
```

---

## Acceptance Criteria

- [ ] `kubectl -n monitoring get servicemonitors guestbook` returns the resource
- [ ] Prometheus UI → Targets shows `guestbook` as UP with `State: UP`
- [ ] Prometheus UI → Alerts shows all three rules in `guestbook.red` group
- [ ] Grafana has a "Guestbook — RED" dashboard with at least 4 panels
- [ ] Loki logs panel shows guestbook pod logs
- [ ] `GuestbookNoTraffic` alert transitions to `firing` when you scale the frontend to 0 replicas for 5 minutes
- [ ] Dashboard JSON committed to `Resources/Week9/weekly_challenge/grafana/dashboard.json`

---

## Model Answer: Architecture Diagram

```mermaid
flowchart TB
  subgraph guestbook [Guestbook (namespace: default)]
    fe["Frontend Pod<br/>(nginx + sidecar exporter :9113)"]
    redis["Redis Leader"]
    follower["Redis Follower"]
    fe --> redis
    fe --> follower
  end

  subgraph monitoring [Monitoring Stack (namespace: monitoring)]
    prom["Prometheus"]
    am["Alertmanager"]
    grafana["Grafana"]
    loki["Loki"]
    promtail["Promtail (DaemonSet)"]
  end

  sm["ServiceMonitor<br/>(guestbook)"] -->|"scrape config"| prom
  prom -->|"GET :9113/metrics"| fe
  promtail -->|"tail pod logs"| loki
  prom -->|"fire alert"| am
  am -->|"Slack notify"| slack["#alerts-backend"]
  grafana -->|"PromQL"| prom
  grafana -->|"LogQL"| loki
  you["You"] -->|":3000"| grafana
```

---

## Interview Questions (Capstone Review)

**Q: A new engineer asks why you're running both Prometheus metrics and Loki logs. Can't you just use one?**
A: They answer different questions. Metrics (Prometheus) tell you *how much* and *how fast* — they're cheap, aggregatable, and great for dashboards and SLOs. Logs (Loki) tell you *what exactly happened* — the error message, the stack trace, the request ID. During an incident you use metrics to detect and scope the problem, then jump to logs to diagnose the root cause. They're complementary, not redundant.

**Q: Your `GuestbookHighErrorRate` alert keeps flapping — firing for 1 minute then resolving. How do you fix it?**
A: Increase the `for` duration (e.g. `for: 5m`) so the condition must be sustained. Also widen the `rate()` window (e.g. `rate(...[10m])`) to smooth out short spikes. Finally, check whether the spike is a real issue or a transient burst that resolves on its own — if the latter, it may not need an alert at all.

**Q: How would you extend this setup to alert on SLO burn rate rather than raw error ratio?**
A: Instead of `error_ratio > 0.05`, implement multi-window burn rate alerting: alert when `error_ratio[1h] > 14.4 * (1 - SLO)` AND `error_ratio[5m] > 14.4 * (1 - SLO)`. This fires only when you're burning the error budget at 14.4x the sustainable rate — meaning you'll exhaust the monthly budget in about 2 days. This is the Google SRE approach to SLO-based alerting.

## 6. Further Reading

- [Google SRE Workbook — Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [nginx-prometheus-exporter](https://github.com/nginxinc/nginx-prometheus-exporter)
- [kube-prometheus-stack values reference](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- Course complete — you now have a production-grade observability stack. Next steps: distributed tracing with OpenTelemetry + Tempo, GitOps with Argo CD, or service mesh with Istio.
