FROM amazoncorretto:17-alpine

WORKDIR /app

COPY target/novastore-app-1.0.0.jar app.jar

RUN adduser -D -u 1001 appuser

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
