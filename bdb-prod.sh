#!/bin/bash

# This is a setup script that will automatically create a BigchainDB 
# production node for you.
# https://docs.bigchaindb.com/projects/server/en/v2.0.0a2/production-deployment-template/index.html
#
# Artus Vranken

# ENV

LOGGING=true
BDB_NODE_CA_DIR="bdb-node-ca";

# Functions

function log {
  if [ $LOGGING = true ]; then
    echo $1;
  fi;
}


# 1. Set Up a Self-Signed Certificate Authority.

if [ ! -d $BDB_NODE_CA_DIR ]; then
  log "Creating $BDB_NODE_CA_DIR";
  mkdir $BDB_NODE_CA_DIR;
else log "$BDB_NODE_CA_DIR already exists, skipping.";
fi
