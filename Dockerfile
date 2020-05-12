FROM python:3.7-alpine3.11

LABEL version="0.2"
LABEL maintainer="Ilya Stepanov <dev@ilyastepanov.com>"

COPY s3cfg start.sh sync.sh get.sh /

ADD s3cfg /root/.s3cfg

RUN pip install s3cmd \
  && mv /s3cfg /root/.s3cfg \
  && chmod +x /start.sh \
  && chmod +x /sync.sh \
  && chmod +x /get.sh

ENTRYPOINT ["/start.sh"]
CMD [""]