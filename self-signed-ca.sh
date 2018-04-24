#!/bin/bash

source ./main.sh;

# START

log "Setting up a BigchainDB production node from scratch.";

# 1. Set Up a Self-Signed Certificate Authority.

./install-configure-easyrsa.sh "$BDB_NODE_CA_DIR" "ROOT-CA";

cd "$BDB_ROOT_DIR/$BDB_NODE_CA_DIR/EASYRSA_DIR/easyrsa3/";

./easyrsa build-ca;

# 5. Secure the CA.

#
# These are all optional manual steps. Go to the documentation for more information.
#