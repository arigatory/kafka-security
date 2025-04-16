#!/bin/bash

# Allow all operations on topic-1
docker exec kafka-1 kafka-acls \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --add \
  --allow-principal User:'*' \
  --operation All \
  --topic topic-1 \
  --group '*'

# Allow produce only on topic-2
docker exec kafka-1 kafka-acls \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --add \
  --allow-principal User:'*' \
  --producer \
  --topic topic-2

# Deny consume on topic-2
docker exec kafka-1 kafka-acls \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --add \
  --deny-principal User:'*' \
  --consumer \
  --topic topic-2 \
  --group '*'

echo "Current ACLs:"
docker exec kafka-1 kafka-acls \
  --bootstrap-server kafka-1:9093 \
  --command-config /etc/kafka/secrets/client-ssl.properties \
  --list