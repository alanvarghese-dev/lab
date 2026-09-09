FROM python:3.12

WORKDIR /app

COPY . .

RUN apt-get update
RUN apt-get install -y curl git vim

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
