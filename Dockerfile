ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Kopiere Skripte
COPY run.sh /run.sh
COPY update_ip.py /update_ip.py

RUN chmod +x /run.sh

CMD [ "/run.sh" ]
