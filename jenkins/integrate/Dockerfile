FROM openjdk:8

ENV TZ=Asia/Shanghai
ENV WORK_PATH /opt/runtime
ENV LANG C.UTF-8

ARG var_profile=dev
ARG var_port=8080
ENV PROFILE $var_profile
ENV PORT $var_port

WORKDIR $WORK_PATH

COPY startup.sh $WORK_PATH/startup.sh
COPY app.jar $WORK_PATH/app.jar

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    mkdir $WORK_PATH/logs && \
    chmod 777 $WORK_PATH/logs && \
    chmod a+x $WORK_PATH/startup.sh


# CMD [ "bash" ]
CMD [ "./startup.sh", "--pause" ]
# ENTRYPOINT ["./startup.sh"]
