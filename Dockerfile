FROM cp.icr.io/cp/icp4i/mq/ibm-mqadvanced-server-integration:9.1.3.0-r4-amd64
USER root
RUN useradd admin -G mqm \
    && echo admin:passw0rd | chpasswd \
# Create the mqclient group
    && groupadd mqclient \
# Create the app user as a member of the mqclient group and set their password
    && useradd app -G mqclient \
    && echo app:passw0rd | chpasswd
# Copy the configuration script to /etc/mqm where it will be picked up automatically
USER mqm
ADD 30-adt.mqsc /etc/mqm
RUN mkdir /tmp/mq_messages
ADD 10-ESB.RECEIVER.EXTERNALIZE /tmp/mq_messages/
ADD 10-ESB.RFH2CONFIG.EXTERNALIZE /tmp/mq_messages/
ADD 10-ESB.SENDER.EXTERNALIZE /tmp/mq_messages/
ADD 10-ESB.TRANSFORM.EXTERNALIZE /tmp/mq_messages/
EXPOSE 5000 7600 7800 7843 1414 10100
ADD load_messages.bash /tmp/
ADD start_mq /tmp
ENV LICENSE accept
ENTRYPOINT ["/tmp/start_mq"]
