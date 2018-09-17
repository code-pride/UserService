FROM openjdk:8-jdk-alpine as builder

RUN mkdir -p /gradle

ADD  build.gradle /gradle
ADD  settings.gradle /gradle
ADD  src /gradle/src
ADD  gradlew /gradle
ADD  gradle /gradle/gradle
WORKDIR /gradle
RUN ./gradlew build

FROM adoptopenjdk/openjdk8-openj9:x86_64-alpine-jdk8u181-b13_openj9-0.9.0-slim

ENV CASSANDRA_HOSTS localhost
ENV CASSANDRA_PORT 9042
ENV CASSANDRA_KEYSPACE daily3
ENV REDIS_PORT 6379
ENV REDIS_HOST localhost
ENV EUREKA_URL localhost:8761
ENV SERVER_PORT 8092
ENV FACEBOOK_CLIENT_ID clientId
ENV FACEBOOK_CLIENT_SECRET clientSecret
ENV GOOGLE_CLIENT_ID clientId
ENV GOOGLE_CLIENT_SECRET clientSecret
ENV SRING_MAIL_USERNAME mailserver
ENV SPRING_MAIL_PASSWORD password
ENV XMX 128m


RUN mkdir -p /app
COPY --from=builder /gradle/build/libs/user-service.jar /app/

CMD ["java", \
    "-Xmx${XMX}", "-XX:+IdleTuningGcOnIdle", "-Xtune:virtualized", "-Xscmx128m", "-Xscmaxaot100m", "-Xshareclasses:cacheDir=/opt/shareclasses", \
    "-jar", "user-service.jar", \
    "--spring.data.cassandra.keyspace-name=${CASSANDRA_KEYSPACE}", \
    "--spring.data.cassandra.contact-points=${CASSANDRA_HOSTS}", \
    "--spring.data.cassandra.port=${CASSANDRA_PORT}", \
    "--spring.redis.host=${REDIS_HOST}", \
    "--spring.redis.port=${REDIS_PORT}", \
    "--server.port=${SERVER_PORT}", \
    "--eureka.client.serviceurl.defaultzone=http://${EUREKA_URL}/eureka/", \
    "--facebook.client.clientId=${FACEBOOK_CLIENT_ID}", \
    "--facebook.client.clientSecret=${FACEBOOK_CLIENT_SECRET}", \
    "--google.client.clientId=${GOOGLE_CLIENT_ID}", \
    "--google.client.clientSecret=${GOOGLE_CLIENT_SECRET}", \
    "--spring.mail.username=${SRING_MAIL_USERNAME}", \
    "--spring.mail.password=${SPRING_MAIL_PASSWORD}" \
]