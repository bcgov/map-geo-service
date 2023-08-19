FROM tomcat:9-jdk11-corretto AS BUILD

RUN yum install -y unzip

RUN mkdir /usr/local/tomcat/webapps/gwc 
WORKDIR /usr/local/tomcat/webapps/gwc

RUN curl -o /geowebcache.war "https://cfhcable.dl.sourceforge.net/project/geowebcache/geowebcache/1.23.1/geowebcache-1.23.1-war.zip"
RUN unzip /geowebcache.war

################################# DEPLOYMENT
FROM tomcat:9-jdk11-corretto

RUN yum install -y gettext

COPY --from=BUILD /usr/local/tomcat/webapps/gwc /usr/local/tomcat/webapps/gwc

COPY overrides /overrides/.

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]