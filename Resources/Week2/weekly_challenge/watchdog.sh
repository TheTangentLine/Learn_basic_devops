#!/bin/bash

STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" http://internal-tool.local)

if [ $STATUS = "200" ]; then
    echo "✅ System Online"
else
    echo "🚨 ALERT: System Down! (Status: $STATUS)"
    exit 1
fi