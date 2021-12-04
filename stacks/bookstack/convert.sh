#!/bin/sh

kompose convert -f bookstack-original-compose.yaml

mv bookstack-service.yaml kompose/
mv mysql-service.yaml kompose/
mv bookstack-deployment.yaml kompose/
mv uploads-persistentvolumeclaim.yaml kompose/
mv storage-uploads-persistentvolumeclaim.yaml kompose/
mv mysql-deployment.yaml kompose/
mv mysql-data-persistentvolumeclaim.yaml kompose/
