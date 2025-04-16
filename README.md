# Задание 1. Балансировка партиций и диагностика кластера

Создание топика balanced_topic

docker exec -it kafka-0 kafka-topics.sh --create --topic balanced_topic --partitions 8 --replication-factor 3 --bootstrap-server kafka-0:9092

Проверка текущего распределения партиций

docker exec -it kafka-0 kafka-topics.sh --describe --topic balanced_topic --bootstrap-server kafka-0:9092

Topic: balanced_topic   TopicId: QUdbsfcmTkydyhe469GI2A PartitionCount: 8       ReplicationFactor: 3    Configs: 
        Topic: balanced_topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
        Topic: balanced_topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
        Topic: balanced_topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
        Topic: balanced_topic   Partition: 3    Leader: 0       Replicas: 0,2,1 Isr: 0,2,1
        Topic: balanced_topic   Partition: 4    Leader: 2       Replicas: 2,1,0 Isr: 2,1,0
        Topic: balanced_topic   Partition: 5    Leader: 1       Replicas: 1,0,2 Isr: 1,0,2
        Topic: balanced_topic   Partition: 6    Leader: 2       Replicas: 2,1,0 Isr: 2,1,0
        Topic: balanced_topic   Partition: 7    Leader: 1       Replicas: 1,0,2 Isr: 1,0,2

Запуск перераспределения

docker cp reassignment.json kafka-0:/tmp/reassignment.json
docker exec -it kafka-0 kafka-reassign-partitions.sh --bootstrap-server kafka-0:9092 --reassignment-json-file /tmp/reassignment.json --execute

Current partition replica assignment

{"version":1,"partitions":[{"topic":"balanced_topic","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":1,"replicas":[1,2,0],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":2,"replicas":[2,0,1],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":3,"replicas":[0,2,1],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":4,"replicas":[2,1,0],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":5,"replicas":[1,0,2],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":6,"replicas":[2,1,0],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":7,"replicas":[1,0,2],"log_dirs":["any","any","any"]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started partition reassignments for balanced_topic-0,balanced_topic-1,balanced_topic-2,balanced_topic-3,balanced_topic-4,balanced_topic-5,balanced_topic-6,balanced_topic-7

Проверка статуса перераспределения

docker exec -it kafka-0 kafka-reassign-partitions.sh --bootstrap-server kafka-0:9092 --reassignment-json-file /tmp/reassignment.json --verify

Status of partition reassignment:
Reassignment of partition balanced_topic-0 is completed.
Reassignment of partition balanced_topic-1 is completed.
Reassignment of partition balanced_topic-2 is completed.
Reassignment of partition balanced_topic-3 is completed.
Reassignment of partition balanced_topic-4 is completed.
Reassignment of partition balanced_topic-5 is completed.
Reassignment of partition balanced_topic-6 is completed.
Reassignment of partition balanced_topic-7 is completed.

Clearing broker-level throttles on brokers 0,1,2
Clearing topic-level throttles on topic balanced_topic

Проверка нового распределения

docker exec -it kafka-0 kafka-topics.sh --describe --topic balanced_topic --bootstrap-server kafka-0:9092
Topic: balanced_topic   TopicId: QUdbsfcmTkydyhe469GI2A PartitionCount: 8       ReplicationFactor: 3    Configs: 
        Topic: balanced_topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
        Topic: balanced_topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
        Topic: balanced_topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
        Topic: balanced_topic   Partition: 3    Leader: 0       Replicas: 0,2,1 Isr: 0,2,1
        Topic: balanced_topic   Partition: 4    Leader: 2       Replicas: 1,0,2 Isr: 2,1,0
        Topic: balanced_topic   Partition: 5    Leader: 1       Replicas: 2,1,0 Isr: 1,0,2
        Topic: balanced_topic   Partition: 6    Leader: 2       Replicas: 0,1,2 Isr: 2,1,0
        Topic: balanced_topic   Partition: 7    Leader: 1       Replicas: 1,2,0 Isr: 1,0,2


Остановка брокера kafka-1

docker stop kafka-1

Проверка состояния топиков после сбоя

docker exec -it kafka-0 kafka-topics.sh --describe --topic balanced_topic --bootstrap-server kafka-0:9092
Topic: balanced_topic   TopicId: QUdbsfcmTkydyhe469GI2A PartitionCount: 8       ReplicationFactor: 3    Configs: 
        Topic: balanced_topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,2
        Topic: balanced_topic   Partition: 1    Leader: 2       Replicas: 1,2,0 Isr: 2,0
        Topic: balanced_topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0
        Topic: balanced_topic   Partition: 3    Leader: 0       Replicas: 0,2,1 Isr: 0,2
        Topic: balanced_topic   Partition: 4    Leader: 2       Replicas: 1,0,2 Isr: 2,0
        Topic: balanced_topic   Partition: 5    Leader: 2       Replicas: 2,1,0 Isr: 0,2
        Topic: balanced_topic   Partition: 6    Leader: 2       Replicas: 0,1,2 Isr: 2,0
        Topic: balanced_topic   Partition: 7    Leader: 2       Replicas: 1,2,0 Isr: 0,2


Запуск брокера kafka-1

docker start kafka-1

Проверка восстановления синхронизации реплик

docker exec -it kafka-0 kafka-topics.sh --describe --topic balanced_topic --bootstrap-server kafka-0:9092

Topic: balanced_topic   TopicId: QUdbsfcmTkydyhe469GI2A PartitionCount: 8       ReplicationFactor: 3    Configs: 
        Topic: balanced_topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,2,1
        Topic: balanced_topic   Partition: 1    Leader: 2       Replicas: 1,2,0 Isr: 2,0,1
        Topic: balanced_topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
        Topic: balanced_topic   Partition: 3    Leader: 0       Replicas: 0,2,1 Isr: 0,2,1
        Topic: balanced_topic   Partition: 4    Leader: 2       Replicas: 1,0,2 Isr: 2,0,1
        Topic: balanced_topic   Partition: 5    Leader: 2       Replicas: 2,1,0 Isr: 0,2,1
        Topic: balanced_topic   Partition: 6    Leader: 2       Replicas: 0,1,2 Isr: 2,0,1
        Topic: balanced_topic   Partition: 7    Leader: 2       Replicas: 1,2,0 Isr: 0,2,1

# Задание 2. Настройка защищённого соединения и управление доступом

Генерация cертификатов

generate-certs.sh

Запуск кластера

docker compose up -d

Создание топиков

create-topics.sh

Настройка ACL

set-acl.sh