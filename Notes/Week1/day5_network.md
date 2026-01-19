**Week 1, Day 5: Networking CLI (The Eyes & Ears)**

**The Scenario:** Your app is down. You need to know: Is the server offline? Is the firewall blocking the port? Or is the API just returning a 500 error?

You need to troubleshoot the layers of the network stack.

**The Tools**

1. `ping <host>` **(Layer 3 - IP)**:
   - "Is the machine even reachable?"
   - Uses ICMP protocol. Note: Some servers block ICMP but still serve web traffic.
2. `telnet <host> <port>` or `nc -vz <host> <port>` **(Layer 4 - TCP)**:
   - "Is the door open?"
   - Crucial for checking Firewalls. If `ping` works but `telnet` times out, a firewall is blocking the port.
3. `curl <url>` **(Layer 7 - HTTP)**:
   - "Is the application talking correctly?"
   - The Swiss Army knife of HTTP requests.

---

**Day 5 Mission: The HTTP Detective**

We are going to dissect a request to Google. Most developers just look at the body (the HTML/JSON). DevOps engineers look at the **Headers** (Status codes, Caching, Server info).

**The Flags:**

- `-I` (Head): Fetch only the headers, not the body.

- `-v` (Verbose): Show the entire handshake (DNS lookup, TCP connect, TLS handshake, Headers).

- `-L` (Location): Follow redirects (if you get a 301/302).

**Your Task:**

1. Run a verbose curl request to `google.com`.
   - Command: `curl -v https://google.com`

2. Look at the output. Find the section starting with `> GET / HTTP/2`. This is what you sent.

3. Find the section starting with `< HTTP/2 200`. This is the reply.

**The Question:** Run the command. Look at the output lines starting with `<`. **What is the specific `content-type` that Google returned?**(e.g., text/html, application/json, etc.)

**Answer:**

Content: `text/html; charset=ISO-8859-1` (or similar) is the standard response for a web page
