#!/bin/bash

source ./main.sh;

title_block "Generating a server certificate for MongoDB.";

# 1. Install & Configure Easy-RSA.

title_block "Install & configure Easy-RSA.";
./install-configure-easy-rsa.sh "$MONGODB_SERVER_CERT_DIR" "MongoDB-Instance";

# 2. Create the Server Private Key and CSR.

warn "The instance ID of your node should be provided by the organisation managing the cluster.";
input "Enter the MongoDB instance number:" MONGODB_INSTANCE_ID;

line_empty;
info "Aside: You need to provide the DNS:localhost SAN during certificate generation for";
info "using the localhost exception in the MongoDB instance. All certificates can have";
info "this attribute without compromising security as the localhost exception works";
info "only the first time.";
line_empty;

title_block "Generating MongoDB Private Key and CSR";
cd "$BDB_ROOT_DIR/$MONGODB_SERVER_CERT_DIR/$EASYRSA_DIR/easyrsa3/";
./easyrsa --req-cn=mdb-instance-$MONGODB_INSTANCE_ID --subject-alt-name=DNS:localhost,DNS:mdb-instance-$MONGODB_INSTANCE_ID gen-req mdb-instance-$MONGODB_INSTANCE_ID nopass;