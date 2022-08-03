FROM adoptopenjdk/maven-openjdk11

RUN curl -o ./contrast.jar https://repo1.maven.org/maven2/com/contrastsecurity/contrast-agent/3.18.1/contrast-agent-3.18.1.jar'
COPY ./build/libs/spring-music-1.0.jar /app/springmusic/spring-music-1.0.jar
COPY . /app/springmusic
WORKDIR /app/springmusic

EXPOSE 8686

CMD ["java","-javaagent:/app/springmusic/contrast.jar","-jar","/app/springmusic/spring-music-1.0.jar"]
