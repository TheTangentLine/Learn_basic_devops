# Day 15: Dockerfiles Deep Dive

> **Goal**: Learn the core Dockerfile instructions and bake security (non-root user) into an image from day one.
> **Prereqs**: Week 2 (containers vs images, `docker run`, image layers).

## 1. Scenario & Why It Matters

You already know how to *consume* images with `docker run`. That's only half the job. To ship your own software you have to *author* images — and the quality of the Dockerfile is the single biggest lever on image size, startup speed, and blast radius after a compromise.

A sloppy Dockerfile pulls `python:3.9` (~900 MB), runs the process as root, copies the entire repo (including `.git/` and secrets), and rebuilds every layer on the smallest code change. A good Dockerfile picks a slim base (`python:3.9-slim`, ~120 MB), creates a dedicated non-root user, orders instructions to maximise layer cache hits, and is boringly reproducible.

The non-root detail is the one juniors miss most. If an attacker gets RCE inside a container running as UID 0, they have root inside the namespace — and combined with a kernel CVE or a bad `--privileged` flag, that's root on the host. Switching to a dedicated user is a 2-line change that closes a whole class of exploits.

## 2. Concept Deep-Dive

Each instruction in a Dockerfile produces a read-only *layer*. Docker stacks layers into the final image and caches each step by its inputs — which is why instruction **order** matters for build speed.

| Instruction | Purpose | Typical mistake |
|---|---|---|
| `FROM` | Base image | Using `:latest` (non-reproducible) |
| `WORKDIR` | `cd` into a path (creates it if missing) | Using `RUN cd /app` (doesn't persist) |
| `COPY` | Host → image file copy | Copying source before installing deps (cache miss on every code change) |
| `RUN` | Execute a command at build time | Chaining with `&&` forgotten, producing many fat layers |
| `USER` | Switch the runtime UID | Omitting it — container runs as root |
| `CMD` | Default process when container starts | Using shell form when exec form is safer for signals |

```mermaid
flowchart LR
  A[FROM python:3.9-slim] --> B[RUN groupadd/useradd]
  B --> C[WORKDIR /app]
  C --> D[COPY . .]
  D --> E[RUN chown appuser]
  E --> F[USER appuser]
  F --> G[CMD python app]
```

The flow above is deliberate: create the user *before* `COPY`, then `chown` the copied files, then `USER` — after that point every subsequent command runs unprivileged.

## 3. Hands-On Mission

Create `docker-lab/Dockerfile`:

```dockerfile
FROM python:3.9-slim

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app
COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["python3", "-c", "import time; print('Running as user...'); time.sleep(100)"]
```

Build and run:

```bash
docker build -t secure-app .
docker run -d --name my-secure-app secure-app
```

## 4. Your Task — Answer

**Q:** Verify that the process is **NOT** running as root. Run `docker exec my-secure-app whoami` and paste the output.

**Sample answer**:

```bash
$ docker exec my-secure-app whoami
appuser
```

The output is `appuser` because the `USER appuser` instruction switches the default UID for all subsequent layers *and* for the runtime `CMD`. If the instruction were missing, or placed before the user was created, `whoami` would print `root` and every write, network socket, and syscall would run with UID 0 inside the container.

## 5. Q&A (Concepts Check)

**Q1: Why does order of instructions affect build speed?**
Docker caches each layer by its inputs. If you `COPY . .` before `RUN pip install`, any code change invalidates the install layer and forces a re-download of every dependency. Copy `requirements.txt` first, install, *then* copy the source.

**Q2: What's the difference between `CMD` and `ENTRYPOINT`?**
`ENTRYPOINT` is the executable; `CMD` is the default args. Anything after `docker run image …` overrides `CMD` but is appended to `ENTRYPOINT`. Use `ENTRYPOINT` when you want the image to behave like a single binary.

**Q3: Why prefer exec form `CMD ["python","app.py"]` over shell form `CMD python app.py`?**
Shell form spawns `/bin/sh -c` as PID 1, which doesn't forward signals. `docker stop` then waits 10s and kills the container. Exec form runs your process directly as PID 1 and handles `SIGTERM` cleanly.

**Q4: Does `USER appuser` make the container secure by itself?**
No. It removes UID 0 *inside the namespace*, but the container still shares the host kernel. You also want a read-only root FS, dropped capabilities (`--cap-drop=ALL`), a seccomp profile, and no `--privileged`.

**Q5: Why use `python:3.9-slim` instead of `python:3.9`?**
`-slim` drops build tools, man pages, and locales. You save ~600 MB of pull time and shrink the CVE surface. If you need to compile C extensions, install only the specific `build-essential` packages you need and remove them in the same `RUN` layer.

## 6. Further Reading

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- Next: [Day 16: Multi-Stage Builds](./day16_multi-stage-builds.md)
