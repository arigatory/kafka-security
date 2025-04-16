#!/bin/bash

# Create topic-1 with 3 partitions and replication factor 3
docker exec kafka-1 kafka-topics \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --create \
  --topic topic-1 \
  --partitions 3 \
  --replication-factor 3

# Create topic-2 with 3 partitions and replication factor 3
docker exec kafka-1 kafka-topics \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --create \
  --topic topic-2 \
  --partitions 3 \
  --replication-factor 3

# List all topics
echo "Topics created:"
docker exec kafka-1 kafka-topics \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --list