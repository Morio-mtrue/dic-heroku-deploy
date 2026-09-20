# dic-heroku-deploy

Deployment to Heroku series assignment.

The `python_heroku_task` blog application, prepared for Heroku.

## What was added

| File | Purpose |
| --- | --- |
| `Procfile` | `release` runs the migrations on every deploy, `web` serves the app with gunicorn |
| `.python-version` | Pins the Python runtime |
| `requirements.txt` | Django, gunicorn, psycopg, dj-database-url, whitenoise |
| `.gitignore` | Keeps `__pycache__`, the sqlite file and `staticfiles/` out of the repo |

### settings.py

- `SECRET_KEY` and `DEBUG` come from the environment. `DJANGO_DEBUG` is left
  unset on Heroku, so debug stays off there while local development is
  unchanged.
- `ALLOWED_HOSTS` accepts `.herokuapp.com` plus localhost, and
  `CSRF_TRUSTED_ORIGINS` trusts the Heroku domain.
- `DATABASE_URL`, which Heroku sets when Postgres is attached, replaces the
  local database settings. SSL is required only for Postgres URLs so a local
  sqlite URL still works.
- WhiteNoise serves static files from the dyno, with `STATIC_ROOT` and the
  compressed manifest storage backend.
- With debug off the app also sets `SECURE_PROXY_SSL_HEADER`,
  `SECURE_SSL_REDIRECT`, secure session and CSRF cookies and HSTS.

`python manage.py check --deploy` reports no issues.

## Deploy

```
heroku login
heroku create your-app-name
heroku addons:create heroku-postgresql:essential-0
heroku config:set DJANGO_SECRET_KEY="$(python3 -c 'import secrets;print(secrets.token_urlsafe(50))')"
git push heroku main
heroku open
```

The `release` process runs `migrate` automatically, so the blog list is
available at `/blog/` as soon as the deploy finishes.

## Run locally

```
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
createdb python_heroku_task
python manage.py migrate
python manage.py runserver
```

Then open <http://localhost:8000/blog/>.

## Verified

Full CRUD exercised against the production settings (debug off, SSL redirect,
secure cookies, WhiteNoise, `dj-database-url`):

| Step | Result |
| --- | --- |
| List | 200 |
| Create form | 200 |
| Create post | 302 to `/blog/`, row written |
| List after create | article shown |
| Detail | 200, body correct |
| Edit | 302, title and body updated |
| Delete | 302, 0 rows left |
