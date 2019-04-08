#!/bin/bash -e
python3 /app/parse.py
python3 /app/ingest.py
/app/export.sh
