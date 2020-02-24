#!/usr/bin/bash

# check every 5 seconds for 3 minutes
# this should be more than enough time for the queue manager to start
INTERVAL=5
MAX_ITERATIONS=36
MESSAGE_DIR=/tmp/mq_messages

currentIteration=0
messages=$(ls ${MESSAGE_DIR} | sort -n)

# if there are no messages to process, don't bother
if [ ${?} -ne 0 ]; then
    exit 0
fi

# wait for MQ to be started
while [ ${currentIteration} -lt ${MAX_ITERATIONS} ]; do
    if [ $(dspmq | grep -i -c "(Running)") -eq 1 ]; then
        break
    fi

    echo "MQ not yet running. Sleeping for ${INTERVAL} seconds before trying again."
    sleep ${INTERVAL}
    (( currentIterations++ ))
done

qmName=$(dspmq | sed -e 's/.*QMNAME(\([^)]\+\)).*/\1/g')
echo "Determined QM name: '${qmName}'"
echo "Waiting for QM '${qmName}' to start before we load messages."

# check the message destination to see if it exists yet
echo "QM '${qmName}' ready."
echo "Checking queue readiness"

while [ ${currentIteration} -lt ${MAX_ITERATIONS} ]; do
    stillWaiting=0

    for message in ${messages}; do
        queueName=$(echo "${message}" | sed -e 's/[0-9]\+-//g')
        echo "Checking queue readiness '${queueName}' on '${qmName}'"
        echo "display qstatus(${queueName})" | runmqsc ${qmName} > /dev/null 2>&1

        if [ ${?} -ne 0 ]; then
            echo "Queue not ready yet."
            stillWaiting=1
        fi
    done

    if [ ${stillWaiting} -eq 0 ]; then
        break
    fi

    echo "Still waiting on queue creation. Sleeping for ${INTERVAL} seconds before trying again."
    sleep ${INTERVAL}
    (( currentIterations++ ))
done

echo "All queues ready, proceeding with message loads."

# put each message to queue
for message in ${messages}; do
    queueName=$(echo "${message}" | sed -e 's/[0-9]\+-//g')
    echo "Putting message '${message}' to queue '${queueName}' on '${qmName}'"
    /opt/mqm/bin/dmpmqmsg -m ${qmName} -o ${queueName} -f ${MESSAGE_DIR}/${message}

    if [ ${?} -ne 0 ]; then
        echo "Error putting message"
    fi
done

echo "Completed putting message to queues."
