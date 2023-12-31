FROM tomcat:9-jdk11-corretto AS BUILD

RUN yum install -y unzip

RUN mkdir /usr/local/tomcat/webapps/gwc 
WORKDIR /usr/local/tomcat/webapps

RUN curl -o /geowebcache.war "https://master.dl.sourceforge.net/project/geowebcache/geowebcache/1.14.3/geowebcache-1.14.3-war.zip?viasf=1"
RUN unzip -d war /geowebcache.war
RUN unzip -d gwc war/geowebcache.war

################################# DEPLOYMENT
FROM tomcat:9-jdk11-corretto

RUN yum install -y gettext

COPY --from=BUILD /usr/local/tomcat/webapps/gwc /usr/local/tomcat/webapps/gwc

RUN cp -r /usr/local/tomcat/webapps.dist/manager /usr/local/tomcat/webapps/manager

COPY overrides /overrides/.

COPY /overrides/conf/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY /overrides/conf/server.xml /usr/local/tomcat/conf/server.xml

COPY /overrides/webapps/manager/META-INF/context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml

COPY entrypoint.sh /

ENV GWC_DISKQUOTA_DISABLED=true
ENV GEOWEBCACHE_CACHE_DIR=/geowebcache/cache

RUN chmod -R 777 /usr/local/tomcat/webapps/gwc/WEB-INF

ENTRYPOINT [ "/entrypoint.sh" ]