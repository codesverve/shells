ARG BASEIMAGES=3.15
FROM alpine:${BASEIMAGES} AS builder

LABEL maintainer="chaiyd <chaiyd.cn@gmail.com>"

ADD Yearning-v3.0.1-linux-amd64.zip /
RUN unzip /Yearning-v3.0.1-linux-amd64.zip && \
    mv /Yearning/* /opt && \
    rm -rf /Yearning


FROM alpine:${BASEIMAGES}

LABEL maintainer="chaiyd <chaiyd.cn@gmail.com>"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update  \
    && apk add --no-cache ca-certificates bash tree tzdata libc6-compat dumb-init \
    && cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

COPY --from=builder /opt/Yearning /opt/Yearning
COPY --from=builder /opt/conf.toml /opt/conf.toml

WORKDIR /opt/

EXPOSE 6666

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/Yearning", "run"]
