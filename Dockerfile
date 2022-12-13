FROM openjdk:11
ADD target/java-maven-app-1.1.0-SNAPSHOT.jar java-maven-app.jar
ENTRYPOINT ["java", "-jar", "java-maven-app.jar"]
EXPOSE 8080 
