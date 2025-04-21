FROM homeassistant/amd64-base:latest

RUN apk add --no-cache python3 py3-pip bash curl

COPY run.sh /run.sh
COPY update_ip.py /update_ip.py

RUN chmod a+x /run.sh

RUN pip3 install requests

CMD ["/run.sh"]

