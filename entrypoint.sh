#!/bin/sh

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic

# Set the external host and port
if [ ! -z "$ADVERTISED_HOST" ]; then
	echo "advertised host: $ADVERTISED_HOST"
	if grep -q "^advertised.host.name" $KAFKA_HOME/config/server.properties; then
		sed -r -i "s/#(advertised.host.name)=(.*)/\1=$ADVERTISED_HOST/g" $KAFKA_HOME/config/server.properties
	else
		echo "advertised.host.name=$ADVERTISED_HOST" >> $KAFKA_HOME/config/server.properties
	fi
fi
if [ ! -z "$ADVERTISED_PORT" ]; then
	echo "advertised port: $ADVERTISED_PORT"
	if grep -q "^advertised.port" $KAFKA_HOME/config/server.properties; then
		sed -r -i "s/#(advertised.port)=(.*)/\1=$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
	else
		(echo "" ; echo "advertised.port=$ADVERTISED_PORT") >> $KAFKA_HOME/config/server.properties
		(echo "" ; echo "log.cleaner.dedupe.buffer.size=30485760") >> $KAFKA_HOME/config/server.properties
	fi
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
	echo "log retention hours: $LOG_RETENTION_HOURS"
	sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
	echo "log retention bytes: $LOG_RETENTION_BYTES"
	sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
	echo "default number of partition: $NUM_PARTITIONS"
	sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
	echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
	echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

# Run Kafka
#Reduced Kafka memory footprint to 64MB, if this isn't enough remove the KAFKA_HEAP_OPTS to default back to 1G.
#Reduced dedupe buffersize from 128MB down to ~30MB.
#Remove above as well to reset back to 128MB.
#log.cleaner.dedupe.buffer.size=30485760
KAFKA_HEAP_OPTS="-Xmx64M -Xms64M" $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
