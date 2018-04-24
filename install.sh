#!/bin/bash

# This is a setup script that will automatically create a BigchainDB 
# production node for you.
# https://docs.bigchaindb.com/projects/server/en/v2.0.0a2/production-deployment-template/index.html
#
# Artus Vranken

chmod +x ./main.sh;
chmod +x ./intro.sh;
chmod +x ./easy-rsa-questions.sh;
chmod +x ./self-signed-ca.sh;
chmod +x ./install-configure-easy-rsa.sh;
chmod +x ./server-cert-mongodb.sh;
chmod +x ./client-cert-mongodb.sh;

./intro.sh &&

# Configure certificate variables.
./easy-rsa-questions.sh &&

# Create a CA.
./self-signed-ca.sh &&

# Create a server cert for MongoDB.
./server-cert-mongodb.sh &&

# Create a client cert for MongoDB.
./client-cert-mongodb.sh;
