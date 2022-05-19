FROM adoptopenjdk/maven-openjdk11

COPY ./build/libs/spring-music-1.0.jar /app/springmusic/spring-music-1.0.jar
COPY . /app/springmusic
WORKDIR /app/springmusic

EXPOSE 8686

CMD ["java","-javaagent:/app/springmusic/contrast.jar","-jar","/app/springmusic/spring-music-1.0.jar"]
