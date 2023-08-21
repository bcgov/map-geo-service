#!/bin/sh

echo "Copying prepared files into $GEOSERVER_DATA_DIR"

cp -r /prepare/* $GEOSERVER_DATA_DIR/.

# Do any copying of files into the 
exec /opt/startup.sh
