# Задание 1. Балансировка партиций и диагностика кластера

### Создание топика balanced_topic
```
docker exec -it kafka-0 kafka-topics.sh --create --topic balanced_topic --partitions 8 --replication-factor 3 --bootstrap-server kafka-0:9092
```

### Проверка текущего распределения партиций
```
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
```

### Запуск перераспределения

```
docker cp reassignment.json kafka-0:/tmp/reassignment.json
docker exec -it kafka-0 kafka-reassign-partitions.sh --bootstrap-server kafka-0:9092 --reassignment-json-file /tmp/reassignment.json --execute

Current partition replica assignment

{"version":1,"partitions":[{"topic":"balanced_topic","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":1,"replicas":[1,2,0],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":2,"replicas":[2,0,1],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":3,"replicas":[0,2,1],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":4,"replicas":[2,1,0],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":5,"replicas":[1,0,2],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":6,"replicas":[2,1,0],"log_dirs":["any","any","any"]},{"topic":"balanced_topic","partition":7,"replicas":[1,0,2],"log_dirs":["any","any","any"]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started partition reassignments for balanced_topic-0,balanced_topic-1,balanced_topic-2,balanced_topic-3,balanced_topic-4,balanced_topic-5,balanced_topic-6,balanced_topic-7
```

### Проверка статуса перераспределения

```
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
```

### Проверка нового распределения

```
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
```


### Остановка брокера kafka-1

```
docker stop kafka-1
```

### Проверка состояния топиков после сбоя

```
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

```

### Запуск брокера kafka-1

```
docker start kafka-1
```

### Проверка восстановления синхронизации реплик

```
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
```

# Задание 2. Настройка защищённого соединения и управление доступом

### Установка и настройка CA и генерация ключей

### Создадим корневой сертификат (Root CA)
```
openssl req -new -nodes \
   -x509 \
   -days 365 \
   -newkey rsa:2048 \
   -keyout ca.key \
   -out ca.crt \
   -config ca.cnf
```

### Создадим файл для хранения сертификата безопасности
```
cat ca.crt ca.key > ca.pem
```

### Создадим приватный ключ и запрос на сертификат (CSR)
```
openssl req -new \
    -newkey rsa:2048 \
    -keyout kafka-1-creds/kafka-1.key \
    -out kafka-1-creds/kafka-1.csr \
    -config kafka-1-creds/kafka-1.cnf \
    -nodes
```

### Создадим сертификат брокера, подписанный CA
```
openssl x509 -req \
    -days 3650 \
    -in kafka-1-creds/kafka-1.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out kafka-1-creds/kafka-1.crt \
    -extfile kafka-1-creds/kafka-1.cnf \
    -extensions v3_req
```

### Создадим PKCS12-хранилище с сертификатом брокера:
```
openssl pkcs12 -export \
    -in kafka-1-creds/kafka-1.crt \
    -inkey kafka-1-creds/kafka-1.key \
    -chain \
    -CAfile ca.pem \
    -name kafka-1 \
    -out kafka-1-creds/kafka-1.p12 \
    -password pass:your-password
```

### Создадим keystore для Kafka
```
keytool -importkeystore \
    -deststorepass your-password \
    -destkeystore kafka-1-creds/kafka.kafka-1.keystore.pkcs12 \
    -srckeystore kafka-1-creds/kafka-1.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass your-password
```

### Создадим truststore для Kafka
```
keytool -import \
    -file ca.crt \
    -alias ca \
    -keystore kafka-1-creds/kafka.kafka-1.truststore.jks \
    -storepass your-password \
     -noprompt
```

### Сохраним пароли
```
echo "your-password" > kafka-1-creds/kafka-1_sslkey_creds
echo "your-password" > kafka-1-creds/kafka-1_keystore_creds
echo "your-password" > kafka-1-creds/kafka-1_truststore_creds
```

### Повторим для двух других брокеров
```
mkdir -p kafka-2-creds kafka-3-creds

# Для kafka-2
openssl req -new \
    -newkey rsa:2048 \
    -keyout kafka-2-creds/kafka-2.key \
    -out kafka-2-creds/kafka-2.csr \
    -config kafka-2-creds/kafka-2.cnf \
    -nodes

# Для kafka-3
openssl req -new \
    -newkey rsa:2048 \
    -keyout kafka-3-creds/kafka-3.key \
    -out kafka-3-creds/kafka-3.csr \
    -config kafka-3-creds/kafka-3.cnf \
    -nodes


# Для kafka-2
openssl x509 -req \
    -days 3650 \
    -in kafka-2-creds/kafka-2.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out kafka-2-creds/kafka-2.crt \
    -extfile kafka-2-creds/kafka-2.cnf \
    -extensions v3_req

# Для kafka-3
openssl x509 -req \
    -days 3650 \
    -in kafka-3-creds/kafka-3.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out kafka-3-creds/kafka-3.crt \
    -extfile kafka-3-creds/kafka-3.cnf \
    -extensions v3_req


# Для kafka-2
openssl pkcs12 -export \
    -in kafka-2-creds/kafka-2.crt \
    -inkey kafka-2-creds/kafka-2.key \
    -chain \
    -CAfile ca.pem \
    -name kafka-2 \
    -out kafka-2-creds/kafka-2.p12 \
    -password pass:your-password

# Для kafka-3
openssl pkcs12 -export \
    -in kafka-3-creds/kafka-3.crt \
    -inkey kafka-3-creds/kafka-3.key \
    -chain \
    -CAfile ca.pem \
    -name kafka-3 \
    -out kafka-3-creds/kafka-3.p12 \
    -password pass:your-password

# Для kafka-2
keytool -importkeystore \
    -deststorepass your-password \
    -destkeystore kafka-2-creds/kafka.kafka-2.keystore.pkcs12 \
    -srckeystore kafka-2-creds/kafka-2.p12 \
    -deststoretype PKCS12 \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass your-password

# Для kafka-3
keytool -importkeystore \
    -deststorepass your-password \
    -destkeystore kafka-3-creds/kafka.kafka-3.keystore.pkcs12 \
    -srckeystore kafka-3-creds/kafka-3.p12 \
    -deststoretype PKCS12 \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass your-password

cp kafka-1-creds/kafka.kafka-1.truststore.jks kafka-2-creds/kafka.kafka-2.truststore.jks
cp kafka-1-creds/kafka.kafka-1.truststore.jks kafka-3-creds/kafka.kafka-3.truststore.jks

echo "your-password" > kafka-2-creds/kafka-2_sslkey_creds                                                                            
echo "your-password" > kafka-2-creds/kafka-2_keystore_creds
echo "your-password" > kafka-2-creds/kafka-2_truststore_creds

echo "your-password" > kafka-3-creds/kafka-3_sslkey_creds                                                                            
echo "your-password" > kafka-3-creds/kafka-3_keystore_creds
echo "your-password" > kafka-3-creds/kafka-3_truststore_creds
```



## Проверяем продьюсер
```
kafka-console-producer --broker-list localhost:9093 --topic test-topic --producer.config client-ssl.properties                       

>hi ivan
```

## Проверяем консьюмер
```
kafka-console-consumer --bootstrap-server localhost:9093 --topic test-topic --consumer.config client-ssl.properties --from-beginning 

hi ivan
```

## Проверяем консьюмеры других брокеров
```
# брокер 2
kafka-console-consumer --bootstrap-server localhost:9095 --topic test-topic --consumer.config client-ssl.properties --from-beginning

hi ivan

# брокер 3
kafka-console-consumer --bootstrap-server localhost:9097 --topic test-topic --consumer.config client-ssl.properties --from-beginning

hi ivan
```
