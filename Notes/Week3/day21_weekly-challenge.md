**Week 3, Day 21: The Weekly Challenge (The Legacy Migration)**

**The Scenario:** You just joined a startup. The lead developer hands you a "legacy" Python application that only runs on his laptop. He says: _"I need this running in Docker by end of day. It uses Redis to count hits. Make sure it's secure."_

**Your Mission:** You must create the Docker assets to run this application.

**Step 1: The Codebase**

Create a folder `legacy-app`. Inside, create these two files:

1. `requirements.txt`

```
flask
redis
```

2. `app.py`

```python
from flask import Flask
from redis import Redis
import os

app = Flask(__name__)
# NOTE: Hostname is 'redis', not localhost!
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
    return 'Hello World! I have been seen {} times.\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**Step 2: The Challenge Requirements**

You need to write two files.

**A.** `Dockerfile`

- Base image: `python:3.9-slim`
- Install dependencies (`pip install -r requirements.txt`).
- **Security:** Create a user `appuser` and run the app as that user (don't run as root).
- **Command:** Run `python app.py`.

**B.** `docker-compose.yml`

- **Service 1 (web):** Build from your Dockerfile. Map port `5000` (host) to `5000` (container).

- **Service 2 (redis):** Use the standard `redis:alpine` image.

- **Networking:** Ensure they can talk to each other (Compose does this by default, but you must name the service `redis` so the Python code finds it).

**Execute the mission.**

1. Write the files.
2. Run `docker-compose up --build -d`.
3. Test it with `curl localhost:5000`. Run it twice to see the counter increase.
