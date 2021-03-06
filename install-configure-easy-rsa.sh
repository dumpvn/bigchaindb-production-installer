#!/bin/bash

INSTALL_DIRECTORY=$1;
ORGANIZATIONAL_UNIT=$2;

source ./main.sh;

# 1.1 Installing Easy-RSA dependencies.

title_block "Installing easy-rsa dependencies.";

if [ ! -d "$INSTALL_DIRECTORY" ]; then
  log "Creating $INSTALL_DIRECTORY";
  mkdir "$INSTALL_DIRECTORY";
else 
  log "$INSTALL_DIRECTORY already exists, skipping.";
fi

log "Checking if openssl is installed...";

DPKG_LINES_RESULT=$(dpkg -s openssl | grep -E "Status" | grep -E "installed|ok|install" | wc -l);
if [ "$DPKG_LINES_RESULT" = "1" ]; then
  log "Package openssl already installed, skipping installation.";
else
  log "Package openssl not yet installed, installing now...";
  sudo apt-get update;
  sudo apt-get install openssl;
fi;

cd $INSTALL_DIRECTORY;

# 1.2 Installing Easy-RSA.

title_block "Installing Easy-RSA.";

# Check if a previous run already installed easy-rsa.

if [ -d "$EASYRSA_DIR" ]; then
  warn "Easy-RSA is already downloaded in this directory.";
  warn "Do you want to redo the configuration steps?";
  line_empty;
  warn "THIS WILL REMOVE ALL PREVIOUS CONFIGURATIONS...";
  input "Redo configuration [y/n]" REDO_EASYRSA_CONF;
else
  REDO_EASYRSA_CONF="y";
fi;

if [ "$REDO_EASYRSA_CONF" = "y" ]; then

  rm $EASYRSA_DIR &> /dev/null;
  log "Installing Easy-RSA.";
  wget $EASYRSA_URL;
  tar xzf $EASYRSA_FILE;
  rm $EASYRSA_FILE;

  log "Checking if $EASYRSA_DIR directory exists."
  if [ -d "$EASYRSA_DIR" ]; then
    log "$EASYRSA_DIR directory exists, moving on.";
  else
    warn "$EASYRSA_DIR directory does not exist, something went wrong. Exiting...";
    exit 1;
  fi;

  if [ -d "$EASYRSA_DIR/easyrsa3" ]; then
    log "$EASYRSA_DIR/easyrsa3 directory exists, moving on.";
  else 
    warn "Missing $EASYRSA_DIR/easyrsa3 directory, something went wrong. Exiting...";
    exit 1;
  fi

# 1.3 Customize the Easy-RSA configuration.

  title_block "Customize the Easy-RSA configuration.";

  cd "$EASYRSA_DIR/easyrsa3";

  cp vars.example vars;

  # Copy the previous entered information into the vars file.
  while read -r line; do
    echo '$line' >> vars;
  done < "$BDB_ROOT_DIR/$EASYRSA_CONF";

  echo 'set_var EASYRSA_REQ_OU "'$ORGANIZATIONAL_UNIT'"' >> vars;

# 1.4 Maybe edit x509-types/server (?)

  title_block "Edit the x509-types/server.";

  input "Are you setting up a self-signed CA? [y,n] " IS_SELF_SIGNED_CA;


  if [ "$IS_SELF_SIGNED_CA" = "y" ]; then
    log "Changing extendedKeyUsage variable in x509-types/server...";
    sed -i -e "s/serverAuth/serverAuth,clientAuth/g" x509-types/server;
  fi;

elif [ "$REDO_EASYRSA_CONF" = "n" ]; then
  log "Skipping Easy-RSA installation and configuration...";
else
  warn "Answer not understood. Exiting...";
  exit 1;
fi;

cd $BDB_ROOT_DIR;

# 2. Create a Self-Signed CA.

title_block "Create a Self-Signed CA.";

if [ "$VERBOSE" = true ]; then
  info "You will be asked to enter a PEM passphrase.";
  info "Make sure to write down and securely store that PEM passphrase.";
  info "If you lose it, you will not be able to add or remove entities from";
  info "your public-key infrastructure in the future.";
  info "";
  info "You can accept all default values, you already entered them at the start.";
  info "";
  input "Press enter to continue...";
fi;

cd "$INSTALL_DIRECTORY/$EASYRSA_DIR/easyrsa3";
./easyrsa init-pki;

# 3. Create an Intermediate CA. (Not documented as of now)

# 4. Generate a certificate revocation list. (CRL)

title_block "Generate a certificate revocation list. (CRL)";

./easyrsa gen-crl;