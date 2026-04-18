# Week 2 — Networking & Web Servers

> How the internet actually works, and how to run a production web server on a single box. Everything cloudy in later weeks (Docker, K8s, HTTPS) traces back here.

## Roadmap

```mermaid
flowchart LR
  D8[Day 8<br/>DNS & HTTP codes]
  D9[Day 9<br/>Nginx]
  D10[Day 10<br/>Reverse Proxy]
  D11[Day 11<br/>SSL/TLS]
  D12[Day 12<br/>SSH]
  D13[Day 13<br/>Log Management]
  D14[Day 14<br/>Weekly Challenge]
  D8 --> D9 --> D10 --> D11 --> D12 --> D13 --> D14
```

## Index

- [Day 8 — DNS & HTTP Status Codes](day8_dns-and-http-codes.md)
- [Day 9 — Nginx (install, serve static, config layout)](day9_nginx.md)
- [Day 10 — Reverse Proxy (fronting an app server)](day10_reverse-proxy.md)
- [Day 11 — SSL/TLS (certs, HTTPS, Let's Encrypt)](day11_ssl-tls.md)
- [Day 12 — SSH (keys, agent, config, tunnels)](day12_ssh.md)
- [Day 13 — Log Management (journald, logrotate, tail -f)](day13_log.md)
- [Day 14 — Weekly Challenge: The Reverse Proxy Stack](day14_weekly-challenge.md)

## Related resources

Code for the weekly challenge lives in [`Resources/Week2/weekly_challenge/`](../../Resources/Week2/weekly_challenge/).
