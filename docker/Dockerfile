FROM python:2.7-slim
WORKDIR /forseti-security/

COPY requirements.txt .
COPY setup.py ./
COPY google ./google
COPY install ./install

RUN pip install -q --upgrade pip==9.0.3 && \
	pip install --upgrade setuptools wheel && \
	pip install --upgrade -r requirements.txt

RUN apt-get update && apt-get install -y default-libmysqlclient-dev gcc && \
	python setup.py install && \
	apt-get autoremove --purge -y gcc && \
	apt-get autoclean -y
