<H1>README!!!</H1>

<H3>By Tri Truong - s3878145</H3>


Link to Demo Video: https://youtu.be/pAF88rHaeEQ

<H1>1. 3rd API used</H1>For this project, Mimesis, a high-performance fake data generator for Python was used for Task 3. This API is similar to Faker API, but is vastly more performant when generating data, as well as holding a higher rate of uniqueness compared to Faker API. It is very easy to use, supports many languages, and could also generate data by schemas of any complexity.

<br/>

<H1>2. Data Visualisation</H1> For the Data Visualisation task, I created a total of 5 charts:
- 2 Line Charts showing the changes in temperature of London and Tokyo through time
- 3 pie charts showing the composition of Education Level (Bachelor, Master, and PhD) of 3 different age groups: <=25, 26 - 50, and >=51. It was found that with a larger number of records, the random generation and distribution of the Education Level seemed to be quite equal across all age groups (This can be seen on the "blog-visuals.ipynb" file included in the "Task 4" folder)

<br/>

<H1>3. Detailed guide</H1> 
<H3>IMPORTANT: TO ENSURE THAT THERE ARE NO CONFLICTS WITH THIS IMPLEMENTATION, PLEASE USE A FRESH TEMPLATE FROM THIS [GITHUB](https://github.com/vnyennhi/docker-kafka-cassandra) AND RESET YOUR CASSANDRA DB</H3>

<br/>

<H2>Task 1:</H2>

Step 1: Change the API key to your API key for OpenWeatherMap in [YourLocalDir]\owm-producer\openweathermap_service.cfg

Step 2: Create Kafka and Cassandra Docker Networks with the following commands using Terminal/Command Prompt

- docker network create kafka-network

- docker network create cassandra-network

Step 3: Navigate to the main folder, start Cassandra and Kafka containers with the following commands using Terminal/Command Prompt

- docker-compose -f cassandra/docker-compose.yml up -d --build
- docker-compose -f kafka/docker-compose.yml up -d --build

Step 4: Go to Kafka UI FE at http://localhost:9000 and add a Data Pipeline Cluster. (User: admin Password: bigbang)

Step 5: Go to [YourLocalDir]\owm-producer\openweathermap_producer.py, and change the location to Tokyo and London.

Step 6: Navigate to the main folder, start OWM Producer container with the following command using Terminal/Command Prompt

- docker-compose -f owm-producer/docker-compose.yml up -d --build

Step 7: Navigate to the main folder, start the consumer for OWM with the following commands using Terminal/Command Prompt

- cd consumers
- docker build -t twitterconsumer .
- cd ..
- docker-compose -f consumers/docker-compose.yml up --build

Step 8: Check the data in Cassandra DB:
- In a Terminal/CMD, run: docker exec -it cassandra bash
- Then execute Cassandra QL Shell: cqlsh --cqlversion=3.4.4 127.0.0.1

In Cassandra QL Shell, run: 
- use kafkapipeline;
- select * from weatherreport;

<br/>
<H2>Task 2 (Continue from Task 1)</H2>


Step 9: Create table for Faker API using the following commands:

```
CREATE TABLE IF NOT EXISTS kafkapipeline.fakerdata (
	name TEXT,
	spousename TEXT,
	phone TEXT,
	address TEXT,
	email TEXT,
	ssn TEXT,
	creditcardnumber TEXT,
	creditcardexp TEXT,
	creditcardsecuritycode TEXT,
	creditcardprovider TEXT,
	PRIMARY KEY (name, phone)
);
```

Step 10: Modify the [YourLocalDir]\kafka\connect\create-cassandra-sink.sh file by adding the following to the end

```
echo "Starting Faker Sink"
curl -s \
     -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d '{
  "name": "fakersink",
  "config": {
    "connector.class": "com.datastax.oss.kafka.sink.CassandraSinkConnector",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",  
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",
    "tasks.max": "10",
    "topics": "faker",
    "contactPoints": "cassandradb",
    "loadBalancing.localDc": "datacenter1",
    "topic.faker.kafkapipeline.fakerdata.mapping": "name=value.name, spousename=value.spousename, phone=value.phone, address=value.address, email=value.email, ssn=value.ssn, creditcardnumber=value.creditcardnumber, creditcardexp=value.creditcardexp, creditcardsecuritycode=value.creditcardsecuritycode, creditcardprovider=value.creditcardprovider",
    "topic.faker.kafkapipeline.fakerdata.consistencyLevel": "LOCAL_QUORUM"
  }
}'
echo "Done."
```

Step 11: Remove Kafka container in Docker

Step 12: Navigate to the main folder, rebuild the Kafka container with the following command using Terminal/Command Prompt

- docker-compose -f kafka/docker-compose.yml up -d --build

Step 13: Go to Kafka UI FE at http://localhost:9000 and add a Data Pipeline Cluster again. (User: admin Password: bigbang)

Step 14: Duplicate the owm-producer folder, rename it to faker-producer. Delete the "openweathermap_service.config" file and rename "openweathermap_producer.py" to "faker_producer.py"

Step 15: Replace the content of "faker_producer.py" with the following:
```
"""Produce fake content to 'faker' kafka topic."""
import asyncio
import configparser
import os
import time
from collections import namedtuple
from kafka import KafkaProducer
from faker import Faker
import json

KAFKA_BROKER_URL = os.environ.get("KAFKA_BROKER_URL")
TOPIC_NAME = os.environ.get("TOPIC_NAME")
SLEEP_TIME = int(os.environ.get("SLEEP_TIME", 5))

fake = Faker()

def get_registered_user():
    return {
        "name": fake.name(),
        "spousename": fake.name(),
        "phone": fake.phone_number(),
        "address": fake.address(),
        "email": fake.email(),
        "ssn": fake.ssn(),
        "creditcardnumber": fake.credit_card_number(),
        "creditcardexp": fake.credit_card_expire(),
        "creditcardsecuritycode": fake.credit_card_security_code(),
        "creditcardprovider": fake.credit_card_provider(),
    }


def run():
    iterator = 0
    print("Setting up Faker producer at {}".format(KAFKA_BROKER_URL))
    producer = KafkaProducer(
        bootstrap_servers=[KAFKA_BROKER_URL],
        # Encode all values as JSON
        value_serializer=lambda x: json.dumps(x).encode('utf-8'),
    )

    while True:
        sendit = get_registered_user()
        # adding prints for debugging in logs
        print("Sending new faker data iteration - {}".format(iterator))
        producer.send(TOPIC_NAME, value=sendit)
        print("New faker data sent")
        time.sleep(SLEEP_TIME)
        print("Waking up!")
        iterator += 1


if __name__ == "__main__":
    run()
```

Step 16: In the same folder, find:
- requirements.txt and replace "dataprep" with "faker"
- Dockerfile and rename the python file to "faker_producer.py"
- docker-compose.yml, update line 4, 5, and 9 to "faker", and update SLEEP_TIME to 5
<br/>
After you are done with the edits, navigate to the main folder and build the new faker producer:

- docker-compose -f faker-producer/docker-compose.yml up -d --build

Step 17: Duplicate the "consumers/python/weather_consumer.py" file and rename it to "faker_consumer.py". Replace the content of that file with the following:

from kafka import KafkaConsumer
import os, json

```
if __name__ == "__main__":
    print("Starting Faker Consumer")
    TOPIC_NAME = os.environ.get("FAKER_TOPIC_NAME", "faker")
    KAFKA_BROKER_URL = os.environ.get("KAFKA_BROKER_URL", "localhost:9092")
    CASSANDRA_HOST = os.environ.get("CASSANDRA_HOST", "localhost")
    CASSANDRA_KEYSPACE = os.environ.get("CASSANDRA_KEYSPACE", "kafkapipeline")

    print("Setting up Kafka consumer at {}".format(KAFKA_BROKER_URL))
    consumer = KafkaConsumer(TOPIC_NAME, bootstrap_servers=[KAFKA_BROKER_URL])
    
    print('Waiting for msg...')
    for msg in consumer:
        msg = msg.value.decode('utf-8')
        jsonData=json.loads(msg)
        # add print for checking
        print(jsonData)
```

Step 18: Find the "consumers/docker-compose.yml" file, add the following into the file (be careful with indentation): 
```
  fakerconsumer:
    container_name: fakerconsumer
    image: twitterconsumer
    environment:
      KAFKA_BROKER_URL: broker:9092
      TOPIC_NAME: faker
      CASSANDRA_HOST: cassandradb
      CASSANDRA_KEYSPACE: kafkapipeline
    command: ["python", "-u","python/faker_consumer.py"]
```

Step 19: Navigate to the main folder, rebuild the consumers container with the following command using Terminal/Command Prompt

- docker-compose -f consumers/docker-compose.yml up --build

Step 20: Check the data in Cassandra DB:
- In a Terminal/CMD, run: docker exec -it cassandra bash
- Then execute Cassandra QL Shell: cqlsh --cqlversion=3.4.4 127.0.0.1

In Cassandra QL Shell, run: 
- use kafkapipeline;
- select * from fakerdata;

<br/>
<H2>Task 3 (Continue from Task 2)</H2>

Step 21: Create table for Mimesis API using the following commands:
```
CREATE TABLE IF NOT EXISTS kafkapipeline.mimesisdata (
	name TEXT,
	spousename TEXT,
	phone TEXT,
	age INT,
	nationality TEXT,
	email TEXT,
	education TEXT,
	bloodtype TEXT,
	height FLOAT,
	weight FLOAT,
	PRIMARY KEY (name, phone)
);
```
Step 22: Modify the [YourLocalDir]\kafka\connect\create-cassandra-sink.sh file by adding the following to the end
```
echo "Starting Mimesis Sink"
curl -s \
     -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d '{
  "name": "mimesissink",
  "config": {
    "connector.class": "com.datastax.oss.kafka.sink.CassandraSinkConnector",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",  
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",
    "tasks.max": "10",
    "topics": "mimesis",
    "contactPoints": "cassandradb",
    "loadBalancing.localDc": "datacenter1",
    "topic.mimesis.kafkapipeline.mimesisdata.mapping": "name=value.name, spousename=value.spousename, phone=value.phone, age=value.age, nationality=value.nationality, email=value.email, education=value.education, bloodtype=value.bloodtype, height=value.height, weight=value.weight",
    "topic.mimesis.kafkapipeline.mimesisdata.consistencyLevel": "LOCAL_QUORUM"
  }
}'
echo "Done."
```
Step 23: Remove Kafka container in Docker

Step 24: Navigate to the main folder, rebuild the Kafka container with the following command using Terminal/Command Prompt

- docker-compose -f kafka/docker-compose.yml up -d --build

Step 25: Go to Kafka UI FE at http://localhost:9000 and add a Data Pipeline Cluster again. (User: admin Password: bigbang)

Step 26: Duplicate the faker-producer folder, rename it to mimesis-producer. Rename "faker_producer.py" to "mimesis_producer.py"

Step 27: Replace the content of "mimesis_producer.py" with the following:
```
"""Produce fake content to 'mimesis' kafka topic."""
import asyncio
import configparser
import os
import time
from collections import namedtuple
from kafka import KafkaProducer
from mimesis import Person
import json

KAFKA_BROKER_URL = os.environ.get("KAFKA_BROKER_URL")
TOPIC_NAME = os.environ.get("TOPIC_NAME")
SLEEP_TIME = int(os.environ.get("SLEEP_TIME", 5))

person = Person('en')

def get_registered_user():
    return {
        "name": person.full_name(),
	"spousename": person.full_name(),
	"phone": person.telephone(),
	"age": person.age(),
	"nationality": person.nationality(),
	"email": person.email(),
	"education": person.academic_degree(),
	"bloodtype": person.blood_type(),
	"height": float(person.height()),
	"weight": float(person.weight())
    }


def run():
    iterator = 0
    print("Setting up Mimesis producer at {}".format(KAFKA_BROKER_URL))
    producer = KafkaProducer(
        bootstrap_servers=[KAFKA_BROKER_URL],
        # Encode all values as JSON
        value_serializer=lambda x: json.dumps(x).encode('utf-8'),
    )

    while True:
        sendit = get_registered_user()
        # adding prints for debugging in logs
        print("Sending new mimesis data iteration - {}".format(iterator))
        producer.send(TOPIC_NAME, value=sendit)
        print("New mimesis data sent")
        time.sleep(SLEEP_TIME)
        print("Waking up!")
        iterator += 1


if __name__ == "__main__":
    run()

```
Step 28: In the same folder, find:
- requirements.txt and replace "faker" with "mimesis"
- Dockerfile and rename the python file to "mimesis_producer.py"
- docker-compose.yml, update line 4, 5, and 9 to "mimesis"
<br/>
After you are done with the edits, navigate to the main folder and build the new mimesis producer:

docker-compose -f mimesis-producer/docker-compose.yml up -d --build

Step 29: Duplicate the "consumers/python/faker_consumer.py" file and rename it to "mimesis_consumer.py". Replace the content of that file with the following:
```
from kafka import KafkaConsumer
import os, json

if __name__ == "__main__":
    print("Starting Mimesis Consumer")
    TOPIC_NAME = os.environ.get("MIMESIS_TOPIC_NAME", "mimesis")
    KAFKA_BROKER_URL = os.environ.get("KAFKA_BROKER_URL", "localhost:9092")
    CASSANDRA_HOST = os.environ.get("CASSANDRA_HOST", "localhost")
    CASSANDRA_KEYSPACE = os.environ.get("CASSANDRA_KEYSPACE", "kafkapipeline")

    print("Setting up Kafka consumer at {}".format(KAFKA_BROKER_URL))
    consumer = KafkaConsumer(TOPIC_NAME, bootstrap_servers=[KAFKA_BROKER_URL])
    
    print('Waiting for msg...')
    for msg in consumer:
        msg = msg.value.decode('utf-8')
        jsonData=json.loads(msg)
        # add print for checking
        print(jsonData)
```
Step 30: Find the "consumers/docker-compose.yml" file, add the following into the file (be careful with indentation): 
```
  mimesisconsumer:
    container_name: mimesisconsumer
    image: twitterconsumer
    environment:
      KAFKA_BROKER_URL: broker:9092
      TOPIC_NAME: mimesis
      CASSANDRA_HOST: cassandradb
      CASSANDRA_KEYSPACE: kafkapipeline
    command: ["python", "-u","python/mimesis_consumer.py"]
```
Step 31: Navigate to the main folder, rebuild the consumers container with the following command using Terminal/Command Prompt

docker-compose -f consumers/docker-compose.yml up --build

Step 32: Check the data in Cassandra DB:
- In a Terminal/CMD, run: docker exec -it cassandra bash
- Then execute Cassandra QL Shell: cqlsh --cqlversion=3.4.4 127.0.0.1

In Cassandra QL Shell, run: 
- use kafkapipeline;
- select * from mimesisdata;

Task 4: Visualisation
Step 33: Copy the 2 files "blog-visuals.ipynb" and "cassandrautils.py" from the "Task 4" folder and paste them into [YourLocalDir]\data-vis\python

Step 34: Find the "data-vis\docker-compose.yml" file, add into the file the following lines:
      FAKER_TABLE: fakerdata
      MIMESIS_TABLE: mimesisdata

Step 35: Navigate to the main folder, build the visualisation container with the following command using Terminal/Command Prompt

docker-compose -f data-vis/docker-compose.yml up -d --build

Step 36: Go to http://localhost:8888/lab/tree/blog-visuals.ipynb and enjoy the data visualisation