FROM alpine:latest

RUN apk add --no-cache py-pip jq

RUN pip install -U pip && \
  pip install awscli

ENV AWS_ACCESS_KEY_ID ""
ENV AWS_SECRET_ACCESS_KEY ""
ENV AWS_DEFAULT_REGION "us-east-1"
