FROM nginx:1.19.6-alpine

ENV TZ=Asia/Shanghai
ENV WORK_PATH /usr/share/nginx/html
ENV LANG C.UTF-8

ENV PORT 80

EXPOSE $PORT

RUN rm /usr/share/nginx/html/index.html && \
    rm /usr/share/nginx/html/50x.html

ADD app.tar $WORK_PATH/

WORKDIR $WORK_PATH

ENTRYPOINT ["/docker-entrypoint.sh"]
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]


