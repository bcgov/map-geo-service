FROM tomcat:9-jdk11-corretto AS BUILD

RUN yum install -y unzip

RUN mkdir /usr/local/tomcat/webapps/gwc 
WORKDIR /usr/local/tomcat/webapps

RUN curl -o /geowebcache.war "https://cfhcable.dl.sourceforge.net/project/geowebcache/geowebcache/1.23.1/geowebcache-1.23.1-war.zip"
# RUN unzip /geowebcache.war
RUN unzip -d war /geowebcache.war
RUN ls -l war
RUN unzip -d gwc war/geowebcache.war
RUN ls -l gwc
################################# DEPLOYMENT
FROM tomcat:9-jdk11-corretto

RUN yum install -y gettext

COPY --from=BUILD /usr/local/tomcat/webapps/gwc /usr/local/tomcat/webapps/gwc

RUN cp -r /usr/local/tomcat/webapps.dist/manager /usr/local/tomcat/webapps/manager

COPY overrides /overrides/.

COPY entrypoint.sh /

ENV GWC_DISKQUOTA_DISABLED=true
ENV GEOWEBCACHE_CACHE_DIR=/geowebcache/cache

ENTRYPOINT [ "/entrypoint.sh" ]