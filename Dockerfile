# Stage 1: Build with Maven
FROM maven:3.9.4-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Configure DNS to use Google's public DNS
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf

RUN --mount=type=cache,target=/root/.m2 mvn dependency:copy-dependencies
    
# Download dependencies only to cache them for later build stages
# Download dependencies to the target/dependency directory for later build stages

# Package the application as a fat jar or a standard jar
RUN --mount=type=cache,target=/root/.m2 mvn -X package -DskipTests

# Stage 2: Runtime with minimal JRE
FROM eclipse-temurin:21-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar studentmarkservice.jar
EXPOSE 8100
ENTRYPOINT ["java", "-jar", "studentmarkservice.jar"]
