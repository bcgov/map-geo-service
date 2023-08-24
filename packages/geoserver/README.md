# GeoServer

## Running Locally

```
docker build --tag gs .
ddocker run -ti --rm --net=host --name geoserver \
 -v `pwd`/_tmp:/opt/geoserver_data \
 gs
```

Go to: http://localhost:8080/geoserver/index.html

`U: admin, P: geoserver`

/opt/apache-tomcat-9.0.75/webapps/geoserver/data
