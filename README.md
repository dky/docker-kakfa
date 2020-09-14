# Kafka Docker container

To spin up a local instance for testing:

```
docker run -p 9092:9092 -p 2181:2181 -e ADVERTISED_HOST=127.0.0.1 -e ADVERTISED_PORT=9092 dkyio/kafka
```


# Installing Kafka MacOS

We will only be using the client since we already have this container.

```
brew cask install homebrew/cask-versions/adoptopenjdk8
brew install kafka
```
