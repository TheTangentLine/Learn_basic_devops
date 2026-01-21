**Week 3, Day 16: Multi-Stage Builds (The Diet)**

**The Scenario:** A standard `node` or `python` image is often 800MB+. This is slow to download and full of security holes (why do you have a compiler in production?). **The Solution:** Build in one container, copy **only what you need** to a second, tiny container, and throw the first one away.

---

**Day 16 Mission: The 95% Reduction**

We will use **Go (Golang)** for this example because the size difference is shocking (800MB -> 5MB). You don't need to know Go, just copy the code.

**1. The App** Create a file named `main.go`:

```go
package main
import "fmt"
func main() {
    fmt.Println("I am a tiny container!")
}
```

**2. The "Fat" Dockerfile (Bad Way)** Create a file` Dockerfile.bad`:

```dockerfile

FROM golang:1.21
WORKDIR /app
COPY main.go .
RUN go build -o myapp main.go
CMD ["./myapp"]
```

**3. The Multi-Stage Dockerfile (Good Way)** Create a file `Dockerfile`:

```dockerfile

# STAGE 1: The Builder (Heavy, has all tools)
FROM golang:1.21 AS builder
WORKDIR /app
COPY main.go .
# Compile the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o myapp main.go

# STAGE 2: The Runner (Tiny, just enough to run)
FROM alpine:latest
WORKDIR /root/
# Copy ONLY the binary from the builder stage
COPY --from=builder /app/myapp .
CMD ["./myapp"]
```

**4. Build & Compare** Run these commands:

```bash
# Build the fat one
docker build -f Dockerfile.bad -t fat-app .

# Build the skinny one
docker build -t tiny-app .
```

**Your Task:** Run `docker images` and look at the SIZE column for `fat-app` and `tiny-app`.

**Paste the two sizes here.** (Approximations are fine).
