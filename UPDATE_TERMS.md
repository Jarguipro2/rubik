# Create a new docker network

docker network create rubik_network

# Link the network in the docker-compose file

```yml

networks:
rubik_network:
    external: true
    name: rubik_network
```

# Run a standalone docker container with connection to the network

docker run --rm --network "rubik_network" --env-file '.env' anthonybrochu/rubik rails db:create db:migrate

# Run the command to generate the schedules

## To generate all schedules

docker run --rm --network "rubik_network" --env-file '.env' anthonybrochu/rubik rails ets_pdf:etl

## To generate only the schedules for a specific term

Adjust the values:

docker run --rm --network "rubik_network" --env-file '.env' \
    -v '/home/anthony/dev/rubik/db/raw/ets/2022/ete/:/rubik/db/raw/ets/2022/ete/' \
    anthonybrochu/rubik:latest rails ets_pdf:etl

Also adjust the env file for this value:
```
PDF_FOLDER=db/raw/ets/2022/ete/**/*
```

## When pdf has been converted to pdf, make sure that you have the rights on the new txt files in order to modify them:

sudo chown $USER *.txt
sudo chgrp $USER *.txt


# Push sur le serveur

- Push sur Git
- Push sur docker hub
    - ```docker build -t "anthonybrochu/rubik:latest"```
    - ```docker push anthonybrochu/rubik:latest```


# Run on the server

## Pull the values

```
docker pull anthonybrochu/rubik:latest
```

## Update the value

```
DOCKER_GATEWAY_HOST="$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')" docker-compose -f production.yml up -d
```

## Run the ets_pdf:etl utility

1. Also adjust the env file for this value:

```
PDF_FOLDER=db/raw/ets/2022/ete/**/*
```

2. Run this command

```
docker run --rm --env-file '.env' anthonybrochu/rubik:latest rails ets_pdf:etl
```
