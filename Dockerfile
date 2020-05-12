FROM python:3.7-alpine3.11

LABEL version="0.2"
LABEL maintainer="Ilya Stepanov <dev@ilyastepanov.com>"

COPY start.sh sync.sh get.sh /

RUN pip install s3cmd \
  && chmod +x /start.sh \
  && chmod +x /sync.sh \
  && chmod +x /get.sh

ENTRYPOINT ["/start.sh"]
CMD [""]