FROM alpine:3.8 AS cntlm-container

LABEL version="1.3"

RUN apk add --no-cache --virtual .build-deps curl gcc make musl-dev && \
    curl -o /cntlm-0.92.3.tar.gz http://kent.dl.sourceforge.net/project/cntlm/cntlm/cntlm%200.92.3/cntlm-0.92.3.tar.gz && \
    tar -xvzf /cntlm-0.92.3.tar.gz && \
    cd /cntlm-0.92.3 && ./configure && make && make install && \
    rm -Rf cntlm-0.92.3.tar.gz cntlm-0.92.3 && \
    apk del --no-cache .build-deps

ENV USERNAME   example
ENV PASSWORD   UNSET
ENV DOMAIN     example.com
ENV PROXY      example.com:3128
ENV LISTEN     0.0.0.0:3128
ENV PASSLM     UNSET
ENV PASSNT     UNSET
ENV PASSNTLMV2 UNSET
ENV NOPROXY    UNSET

EXPOSE 3128

ADD start.sh /start.sh
RUN dos2unix /start.sh
RUN chmod +x /start.sh

CMD /start.sh


# Pulling the base image
FROM python:alpine3.7 AS python-container

# Setting environment varibles
# PYTHONDONTWRITEBYTECODE ensures our console output looks familiar and is not buffered by Docker
# PYTHONUNBUFFERED means Python won’t try to write .pyc files
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Setting work directory
WORKDIR /code

# Installing dependencies
# Installing last versione of pip
# Installing pipenv
RUN pip install --upgrade pip
RUN pip install pipenv

#Copying our local file Pipfile onto Docker and running it to install our dependencies
COPY ./requirements.txt /code/requirements.txt

RUN pip install -r requirements.txt
EXPOSE 8000
#RUN pipenv install --deploy --system --skip-lock --dev

# Copy project
# COPY . /code/
