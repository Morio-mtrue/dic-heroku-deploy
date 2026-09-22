#!/usr/bin/env bash
# Render build step. Free instances have no shell and no pre-deploy hook,
# so the migrations run here, after the dependencies and static files.
set -o errexit

pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate --noinput
