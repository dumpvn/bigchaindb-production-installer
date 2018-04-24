#!/bin/bash

# This is a setup script that will automatically create a BigchainDB 
# production node for you.
# https://docs.bigchaindb.com/projects/server/en/v2.0.0a2/production-deployment-template/index.html
#
# Artus Vranken

chmod +x ./main.sh;
chmod +x ./self-signed-ca.sh;
chmod +x ./install-configure-easyrsa.sh;
chmod +x ./server-cert-mongodb.sh;
chmod +x ./client-cert-mongodb.sh;

./self-signed-ca.sh &&
./server-cert-mongodb.sh &&
./client-cert-mongodb.sh;
