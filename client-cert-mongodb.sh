#!/bin/bash

source ./main.sh;

title_block "Generating a client certificate for MongoDB.";

# 1. Install and configure Easy-RSA.

title_block "Install & configure Easy-RSA.";
./install-configure-easy-rsa.sh "$MONGODB_CLIENT_CERT_DIR" "BigchainDB-Instance";
cd "$BDB_ROOT_DIR/$MONGODB_CLIENT_CERT_DIR/$EASYRSA_DIR/easyrsa3/";