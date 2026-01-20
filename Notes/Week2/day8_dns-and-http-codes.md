**Week 2, Day 8: DNS & HTTP Codes**

**The Scenario:** A user complains your website is "down."

- Is it **DNS**? (The phonebook can't find the number).

- Is it **Network**? ( The call won't connect).

- Is it **Application**? (Someone picked up but hung up on you).

To debug this, you must speak **HTTP Status Codes** fluently.

**The Cheat Sheet:**

- **2xx (Success)**: `200 OK` (Good).

- **3xx (Redirection)**: `301 Moved Permanently` (Go here instead).

- **4xx (Client Error - You messed up)**:
  - `400 Bad Request` (Your syntax is wrong).

  - `401 Unauthorized` (Who are you? Log in).

  - `403 Forbidden` (I know who you are, but you can't come in).

  - `404 Not Found` (It's not here).

- **5xx (Server Error - We messed up):**
  - `500 Internal Server Error` (Code crashed).

  - `502 Bad Gateway` (Upstream server—like Python/Node—didn't reply to Nginx).

---

**Day 8 Mission: The Status Code Hunter**

I want you to use `curl` to intentionally trigger three specific errors using a real site (we'll use `httpbin.org`, a tool made for testing).

1. **Trigger a 200 (Success):**
   - `curl -I https://httpbin.org/status/200`

2. **Trigger a 404 (Not Found):**
   - Try to curl a page that definitely doesn't exist, like `https://google.com/this-page-is-fake-12345.`

3. **Trigger a 301 (Redirect):**
   - `curl -I http://google.com` (Notice `http` not `https`).

**Your Task:** Run the command for step 3 (`curl -I http://google.com`). Look at the output. There is a `Location:` header telling you where to go next. **What is the exact URL in the `Location` header?**

**Answer:**
The server said: "I am here, but you should be talking to me over the secure line." It pointed you to `https://www.google.com`.
