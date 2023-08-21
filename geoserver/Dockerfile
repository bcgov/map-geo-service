FROM docker.osgeo.org/geoserver:2.23.2 AS original

FROM tomcat:9-jdk11-corretto AS tomcat

ENV ORIG_CATALINA_HOME=/opt/apache-tomcat-9.0.75

RUN yum install -y unzip

## Reference: https://github.com/geoserver/docker/blob/master/Dockerfile

FROM tomcat as download

ARG GS_VERSION=2.23.2
ARG GS_BUILD=release
ARG WAR_ZIP_URL=https://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/geoserver-${GS_VERSION}-war.zip
ENV GEOSERVER_VERSION=$GS_VERSION
ENV GEOSERVER_BUILD=$GS_BUILD

WORKDIR /tmp

RUN echo "Downloading GeoServer ${GS_VERSION} ${GS_BUILD}" \
&& curl -L -o /tmp/geoserver.zip $WAR_ZIP_URL \
&& unzip geoserver.zip geoserver.war -d /tmp/ \
&& unzip -q /tmp/geoserver.war -d /tmp/geoserver \
&& rm /tmp/geoserver.war

FROM tomcat as install

ARG GS_VERSION=2.23.2
ARG GS_BUILD=release
ARG STABLE_PLUGIN_URL=https://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions
ARG COMMUNITY_PLUGIN_URL=''

ENV GEOSERVER_VERSION=$GS_VERSION
ENV GEOSERVER_BUILD=$GS_BUILD
ENV GEOSERVER_DATA_DIR=/opt/geoserver_data/
# ENV GEOSERVER_REQUIRE_FILE=$GEOSERVER_DATA_DIR/global.xml
ENV GEOSERVER_LIB_DIR=$CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
ENV ORIG_GEOSERVER_LIB_DIR=$ORIG_CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
ENV INSTALL_EXTENSIONS=false
ENV WAR_ZIP_URL=$WAR_ZIP_URL
ENV STABLE_EXTENSIONS=''
ENV STABLE_PLUGIN_URL=$STABLE_PLUGIN_URL
ENV COMMUNITY_EXTENSIONS=''
ENV COMMUNITY_PLUGIN_URL=$COMMUNITY_PLUGIN_URL
ENV ADDITIONAL_LIBS_DIR=/opt/additional_libs/
ENV ADDITIONAL_FONTS_DIR=/opt/additional_fonts/
ENV SKIP_DEMO_DATA=false
ENV ROOT_WEBAPP_REDIRECT=false

# see https://docs.geoserver.org/stable/en/user/production/container.html
ENV CATALINA_OPTS="\$EXTRA_JAVA_OPTS \
    -Djava.awt.headless=true -server \
    -Dfile.encoding=UTF-8 \
    -Djavax.servlet.request.encoding=UTF-8 \
    -Djavax.servlet.response.encoding=UTF-8 \
    -D-XX:SoftRefLRUPolicyMSPerMB=36000 \
    -Xbootclasspath/a:$CATALINA_HOME/lib/marlin.jar \
    -Dsun.java2d.renderer=sun.java2d.marlin.DMarlinRenderingEngine \
    -Dorg.geotools.coverage.jaiext.enabled=true"

WORKDIR /tmp

RUN echo "Installing GeoServer $GS_VERSION $GS_BUILD"

COPY --from=download /tmp/geoserver $CATALINA_HOME/webapps/geoserver

RUN mv $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/marlin-*.jar $CATALINA_HOME/lib/marlin.jar
#&& mkdir -p $GEOSERVER_DATA_DIR

#COPY --from=original $GEOSERVER_DATA_DIR $GEOSERVER_DATA_DIR
COPY --from=original $ORIG_GEOSERVER_LIB_DIR $GEOSERVER_LIB_DIR
COPY --from=original /usr/share/fonts/truetype/ /usr/share/fonts/truetype/

# cleanup
RUN rm -rf /tmp/*

# copy scripts
COPY --from=original /opt/*.sh /opt/
RUN chmod +x /opt/*.sh

# copy prepulation artifacts
COPY artifacts /prepare

COPY entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]

WORKDIR /opt