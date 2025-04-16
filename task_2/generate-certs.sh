#!/bin/bash

# Generate CA
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -subj "/CN=ca.kafka" -nodes

# Create truststore
keytool -keystore kafka.truststore.jks -alias CARoot -import -file ca-cert -storepass password -noprompt

# Generate broker certificates
for i in 1 2 3; do
  # Create keystore
  keytool -keystore kafka.kafka-$i.keystore.pkcs12 -alias kafka-$i -storetype PKCS12 \
    -validity 365 -genkey -keyalg RSA -storepass password -keypass password \
    -dname "CN=kafka-$i" -ext SAN=DNS:kafka-$i,DNS:localhost

  # Create CSR
  keytool -keystore kafka.kafka-$i.keystore.pkcs12 -alias kafka-$i -certreq \
    -file kafka-$i.csr -storepass password

  # Sign certificate
  openssl x509 -req -CA ca-cert -CAkey ca-key -in kafka-$i.csr -out kafka-$i.crt \
    -days 365 -CAcreateserial

  # Import CA and signed certificate
  keytool -keystore kafka.kafka-$i.keystore.pkcs12 -alias CARoot -import \
    -file ca-cert -storepass password -noprompt
  keytool -keystore kafka.kafka-$i.keystore.pkcs12 -alias kafka-$i -import \
    -file kafka-$i.crt -storepass password -noprompt

  # Create credential files
  echo "password" > kafka-${i}-creds/kafka-${i}_keystore_creds
  echo "password" > kafka-${i}-creds/kafka-${i}_sslkey_creds
  echo "password" > kafka-${i}-creds/kafka-${i}_truststore_creds

  # Copy truststore and keystore
  cp kafka.truststore.jks kafka-${i}-creds/
  cp kafka.kafka-$i.keystore.pkcs12 kafka-${i}-creds/
done

# Create client properties
cat > client-ssl.properties <<EOF
security.protocol=SSL
ssl.truststore.location=/etc/kafka/secrets/kafka.truststore.jks
ssl.truststore.password=password
ssl.keystore.location=/etc/kafka/secrets/kafka.client.keystore.pkcs12
ssl.keystore.password=password
ssl.key.password=password
EOF

chmod -R a+rw kafka-*-creds
