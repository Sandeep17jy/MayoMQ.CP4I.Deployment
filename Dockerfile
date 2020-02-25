FROM cp.icr.io/cp/icp4i/mq/ibm-mqadvanced-server-integration:9.1.3.0-r4-amd64
ADD 30-adt.mqsc /etc/mqm/
ADD 10-ESB.RECEIVER.EXTERNALIZE /tmp/
ADD 10-ESB.RFH2CONFIG.EXTERNALIZE /tmp/
ADD 10-ESB.SENDER.EXTERNALIZE /tmp/
ADD 10-ESB.TRANSFORM.EXTERNALIZE /tmp/
ADD msg.dat /tmp
EXPOSE 5000 7600 7800 7843 1414 10100
ADD load_messages.bash /tmp/
ADD start_mq /tmp/
ENV LICENSE accept
ENTRYPOINT ["/tmp/start_mq"]
