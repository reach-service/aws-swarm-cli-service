FROM alpine:latest

RUN apk add --no-cache py-pip jq

RUN pip install -U pip && \
  pip install awscli

COPY entry.sh /
WORKDIR /

RUN chmod a+x /entry.sh

CMD ["/entry.sh"]
