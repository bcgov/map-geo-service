#!/bin/bash

envsubst </overrides/webapps/gwc/WEB-INF/geowebcache-core-context.xml > /usr/local/tomcat/webapps/gwc/WEB-INF/geowebcache-core-context.xml
envsubst </overrides/webapps/gwc/WEB-INF/geowebcache-wmsservice-context.xml > /usr/local/tomcat/webapps/gwc/WEB-INF/geowebcache-wmsservice-context.xml

catalina.sh "run"