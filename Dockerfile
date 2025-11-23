# Stage 1: Build with Maven
FROM maven:3.9.4-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Use Maven cache for faster builds
RUN --mount=type=cache,target=/root/.m2 mvn dependency:copy-dependencies

# Package the application
RUN --mount=type=cache,target=/root/.m2 mvn -X package -DskipTests

# Stage 2: Runtime with minimal JRE
FROM eclipse-temurin:21-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar studentmarkservice.jar
EXPOSE 8100
ENTRYPOINT ["java", "-jar", "studentmarkservice.jar"]
