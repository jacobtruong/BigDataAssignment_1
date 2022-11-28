#!/bin/sh


echo "Starting Twitter Sink"
curl -s \
     -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d '{
  "name": "twittersink",
  "config":{
    "connector.class": "com.datastax.oss.kafka.sink.CassandraSinkConnector",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",  
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",
    "tasks.max": "10",
    "topics": "twittersink",
    "contactPoints": "cassandradb",
    "loadBalancing.localDc": "datacenter1",
    "topic.twittersink.kafkapipeline.twitterdata.mapping": "location=value.location, tweet_date=value.datetime, tweet=value.tweet, classification=value.classification",
    "topic.twittersink.kafkapipeline.twitterdata.consistencyLevel": "LOCAL_QUORUM"
  }
}'
echo "Starting Weather Sink"
curl -s \
     -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d '{
  "name": "weathersink",
  "config": {
    "connector.class": "com.datastax.oss.kafka.sink.CassandraSinkConnector",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",  
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",
    "tasks.max": "10",
    "topics": "weather",
    "contactPoints": "cassandradb",
    "loadBalancing.localDc": "datacenter1",
    "topic.weather.kafkapipeline.weatherreport.mapping": "location=value.location, forecastdate=value.report_time, description=value.description, temp=value.temp, feels_like=value.feels_like, temp_min=value.temp_min, temp_max=value.temp_max, pressure=value.pressure, humidity=value.humidity, wind=value.wind, sunrise=value.sunrise, sunset=value.sunset",
    "topic.weather.kafkapipeline.weatherreport.consistencyLevel": "LOCAL_QUORUM"
  }
}'
echo "Done."
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