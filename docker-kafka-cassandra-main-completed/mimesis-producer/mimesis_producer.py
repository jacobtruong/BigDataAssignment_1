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
