release: python manage.py migrate --noinput
web: gunicorn python_heroku_task.wsgi --log-file -
