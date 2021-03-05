FROM python:3.9.1-slim

WORKDIR /usr/src/app

RUN pip install requests
RUN pip install boto3

COPY . .

CMD ["python", "app.py"]