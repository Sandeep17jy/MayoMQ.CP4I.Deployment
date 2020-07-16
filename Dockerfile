FROM cp.icr.io/cp/icp4i/mq/ibm-mqadvanced-server-integration:9.1.4.0-r1-amd64
# Add the admin user as a member of the mqm group and set their password
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
EXPOSE 5000 7600 7800 7843 1414 10100
ADD 30-adt.mqsc /etc/mqm/
ADD 10-ESB.RECEIVER.EXTERNALIZE /tmp/
ADD 10-ESB.RFH2CONFIG.EXTERNALIZE /tmp/
ADD 10-ESB.SENDER.EXTERNALIZE /tmp/
ADD 10-ESB.TRANSFORM.EXTERNALIZE /tmp/
ADD msg.dat /tmp/
ADD load_messages.bash /tmp/
ADD start_mq /tmp/
ENV LICENSE accept
