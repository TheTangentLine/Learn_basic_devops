# Day 13: Log Management (The Black Box)

> **Goal**: Mine Nginx access logs with `awk`, `sort`, and `uniq -c` to count HTTP status codes and answer operational questions quickly.
> **Prereqs**: Day 9-10 (Nginx running with some traffic), basic shell pipes.

## 1. Scenario & Why It Matters

An engineer who cannot answer "how many 500s did we serve in the last hour?" in under a minute is not doing operations. Production systems continuously write access logs, error logs, auth logs, and audit logs — and every outage post-mortem starts by reading them. The logs are the black box that survives the crash and tells you what actually happened.

Nginx's default access log captures one line per HTTP request: client IP, timestamp, request line, status code, bytes sent, referrer, user-agent. That single file is enough to answer an enormous fraction of real incident questions: which IP is hammering us, which endpoints 404 the most, when did the 500s start, which client versions are failing. You just need a handful of POSIX tools to mine it.

Today you will wire together the single most useful one-liner in operations: extract a column, sort, `uniq -c`. This same pipeline answers "top 10 IPs," "top 10 404 URLs," "error rate by hour," and more — by changing only which column you extract.

## 2. Concept Deep-Dive

### The Nginx default log format

```
192.168.1.5 - - [17/Jan/2026:10:00:00 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.88.0"
   $1       $2 $3         $4-$5                 $6    $7  $8  $9  $10    ...
```

Columns (as `awk` sees them, whitespace-separated):

| Col   | Content                                |
| ----- | -------------------------------------- |
| `$1`  | Remote IP                              |
| `$4`  | `[timestamp`                           |
| `$6`  | `"METHOD` (quoted, first word)         |
| `$7`  | URL path                               |
| `$9`  | **HTTP status code**                   |
| `$10` | Response size in bytes                 |

### The "one-liner" pipeline

```mermaid
flowchart LR
  Log[/var/log/nginx/access.log] -->|awk print col| Codes[list of codes]
  Codes -->|sort| Sorted[sorted codes]
  Sorted -->|uniq -c| Counted[count+code pairs]
  Counted -->|sort -rn| Ranked[top to bottom]
```

Each stage does one job. `uniq -c` only collapses **adjacent** duplicates, which is why the `sort` stage in the middle is mandatory.

### Core log-mining tools

| Tool       | One-line purpose                                            |
| ---------- | ----------------------------------------------------------- |
| `tail -f`  | Follow a log live, like scrolling Matrix code               |
| `grep`     | Filter lines by substring or regex                          |
| `awk`      | Split into columns and operate on them                      |
| `cut`      | Lighter column splitter when the delimiter is simple        |
| `sort`     | Alphabetic or numeric ordering                              |
| `uniq -c`  | Count adjacent duplicates (requires sorted input)           |
| `wc -l`    | Count lines                                                 |
| `jq`       | Same idea as `awk`, but for structured JSON logs            |

### Log levels (when you graduate to `error.log`)

| Level    | Use when                                      |
| -------- | --------------------------------------------- |
| `debug`  | Trace-level, noisy                            |
| `info`   | Normal operational info                       |
| `notice` | Significant but not abnormal                  |
| `warn`   | Something odd, not yet broken                 |
| `error`  | Request-level failure                         |
| `crit`   | Severe, needs attention                       |
| `alert`  | Immediate action required                     |
| `emerg`  | System unusable                               |

Set `error_log /var/log/nginx/error.log warn;` in production — `info` is usually too noisy.

## 3. Hands-On Mission

Generate some traffic so there is data to mine:

```bash
for i in 1 2 3 4 5; do
  curl -I localhost/nonexistent     # 404s
  curl -I localhost                 # 200s
done
```

See just the status codes:

```bash
sudo awk '{print $9}' /var/log/nginx/access.log
```

Count each status code, most common first:

```bash
sudo awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

Bonus one-liners worth memorizing:

```bash
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head
sudo awk '$9 == "404" {print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head
sudo tail -f /var/log/nginx/access.log
```

## 4. Your Task — Answer

**Q:** Run this specific pipeline and interpret the output:

```bash
sudo awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c
```

**Sample answer**:

```
      5 200
      5 404
```

(Exact counts depend on how many curls you ran.)

**Why**: Left column is the count, right column is the status code, sorted lexicographically. `awk '{print $9}'` pulled the 9th whitespace-separated field — the status code — from every log line. `sort` grouped identical codes adjacent, which `uniq -c` then needed to collapse them with counts. The same 4-stage pattern (extract → sort → uniq-c → sort-rn) answers "top 10 IPs", "top 404 URLs", "error counts by user-agent" just by changing the `awk` column or adding a filter.

## 5. Q&A (Concepts Check)

**Q: Why do we need `sort` before `uniq -c`?**
A: `uniq` only collapses **adjacent** duplicate lines. Without sorting, `200, 404, 200, 200, 404` stays as five separate groups. Sorting rearranges it to `200, 200, 200, 404, 404`, which `uniq -c` correctly collapses to `3 200` and `2 404`.

**Q: What is the difference between `tail -n 100` and `tail -f`?**
A: `tail -n 100` prints the last 100 lines and exits. `tail -f` prints recent lines and then *follows* the file, streaming new lines as they are written. Use `-f` when you need to watch a live incident. `tail -F` (capital F) also re-opens the file after rotation, which is what you want on a production box with `logrotate`.

**Q: What is log rotation and why does it matter?**
A: `logrotate` (usually cron-driven) periodically renames `access.log` to `access.log.1`, gzips older ones, and truncates the active file. Without rotation, a busy Nginx fills the disk in days. With rotation, you also need tools like `tail -F` or `zcat old.log.gz | awk ...` to handle rotated files transparently.

**Q: When should you switch from plain-text logs to structured (JSON) logs?**
A: As soon as you ship logs to an aggregator (Loki, Elasticsearch, Datadog) or have any field containing spaces/quotes. Nginx's `log_format` directive can emit JSON, which `jq` parses reliably; `awk` on free-form logs breaks the moment user-agent strings include spaces or quoted substrings.

**Q: What is the fastest way to count 5xx errors in the last hour?**
A: Combine `awk` on the timestamp and status. A practical approach: `grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" access.log | awk '$9 ~ /^5/' | wc -l`. For anything beyond ad-hoc, push the log into a time-series aggregator and query there — raw-file math becomes expensive at scale.

**Q: How do you find the top 10 IPs hitting a specific URL?**
A: `sudo awk '$7 == "/api/login" {print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10`. This is the same pipeline with an `awk` *filter* (`$7 == ...`) in front of the column extract. The pattern generalizes to any column pair.

## 6. Further Reading

- `awk` one-liners (classic Eric Pement list): <https://www.pement.org/awk/awk1line.txt>
- Nginx `log_format` docs: <https://nginx.org/en/docs/http/ngx_http_log_module.html>
- `logrotate` manual: <https://linux.die.net/man/8/logrotate>
- Next: [Day 14: Weekly Challenge](day14_weekly-challenge.md)
