FROM maven:3.9.7-eclipse-temurin-21-alpine AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine
COPY --from=build /home/app/target/coursemanagementsystembackend-0.0.1-SNAPSHOT.jar /usr/local/lib/coursemanagementsystembackend-0.0.1-SNAPSHOT.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/usr/local/lib/coursemanagementsystembackend-0.0.1-SNAPSHOT.jar"]
