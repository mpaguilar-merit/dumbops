FROM python:3.10-buster

COPY ./install /opt/install
COPY ./app /opt/app

WORKDIR /opt/app

RUN chmod +x /opt/install/*.sh && /opt/install/install.sh
ENV PATH="$PATH:/root/.local/bin"

EXPOSE 8000

CMD ["/opt/install/run_webserver.sh"]
