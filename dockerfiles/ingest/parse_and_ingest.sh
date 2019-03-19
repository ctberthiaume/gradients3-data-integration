#!/bin/bash -e
python3 /app/parse.py -i /mnt/inputs -m /app/metadata/${CURRENT_CRUISE} -o /mnt/outputs -v
python3 /app/ingest.py -c /mnt/outputs -m /app/metadata/${CURRENT_CRUISE} -v
