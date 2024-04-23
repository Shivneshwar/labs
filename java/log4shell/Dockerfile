FROM tomcat:8.0.36-jre8

EXPOSE 8080 
ADD netcat-traditional_1.10-41.1_amd64.deb /usr/share
RUN dpkg -i /usr/share/netcat-traditional_1.10-41.1_amd64.deb
RUN rm -rf /usr/local/tomcat/webapps/*
ADD target/language-based-sec-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]
