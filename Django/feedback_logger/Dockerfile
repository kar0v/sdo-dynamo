FROM python:3.13-slim

WORKDIR /app 
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1 

COPY Pipfile Pipfile.lock /app/

RUN pip install --upgrade pip && \
  pip install pipenv && \
  pipenv install --deploy --ignore-pipfile; \
  mkdir -p /data/efs/media; \
  touch /app/application.log; \
  ln -sf /dev/stdout /app/application.log

COPY . /app/
# Expose the application port
EXPOSE 8000
ENTRYPOINT ["sh", "-c", "pipenv run python manage.py makemigrations && pipenv run python manage.py migrate && pipenv run python manage.py runserver 0.0.0.0:8000"]
