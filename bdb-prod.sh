#!/bin/bash

# This is a setup script that will automatically create a BigchainDB 
# production node for you.
# https://docs.bigchaindb.com/projects/server/en/v2.0.0a2/production-deployment-template/index.html
#
# Artus Vranken

# ENV

BDB_ROOT_DIR=$(pwd);
VERBOSE=true;

BREAK="================================================================================";

BDB_NODE_CA_DIR="bdb-node-ca";

EASYRSA_URL="https://github.com/OpenVPN/easy-rsa/archive/3.0.1.tar.gz";
EASYRSA_FILE="3.0.1.tar.gz";
EASYRSA_DIR="easy-rsa-3.0.1";

# Functions

function log {
  if [ "$VERBOSE" = true ]; then
    echo "[LOG] $1";
  fi;
}

function info {
  if [ "$VERBOSE" = true ]; then
    echo "[INFO] $1";
  fi;
}

function warn {
  if [ "$VERBOSE" = true ]; then
    echo -e "\033[0;31m[WARNING] $1\033[0m";
  fi;
}

function input {
  read -p "$1 " $2;
}

function line_break {
  if [ "$VERBOSE" = true ]; then
    echo "$BREAK";
  fi;
}

function line_empty {
  if [ "$VERBOSE" = true ]; then
    echo;
  fi;
}

function block_divider {
  line_break;
  line_empty;
  line_break;
}

function title_block {
  line_break;
  line_empty;
  echo "$1";
  line_empty;
  line_break;
}

# START

log "Setting up a BigchainDB production node from scratch.";

# 1. Set Up a Self-Signed Certificate Authority.

# 1.1 Installing easy-rsa dependencies.

title_block "Installing easy-rsa dependencies.";

if [ ! -d "$BDB_NODE_CA_DIR" ]; then
  log "Creating $BDB_NODE_CA_DIR";
  mkdir "$BDB_NODE_CA_DIR";
else 
  log "$BDB_NODE_CA_DIR already exists, skipping.";
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

cd $BDB_NODE_CA_DIR;

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
  log "Installing Easy-RSA."
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

  echo 'set_var EASYRSA_DN "org"' >> vars;
  echo 'set_var EASYRSA_KEY_SIZE 4096' >> vars;

  input "Enter your 2-character country code (e.g. Belgium -> BE)" COUNTRY;
  input "Enter your province (e.g. Vlaams-Brabant)" PROVINCE;
  input "Enter your city (e.g. Leuven)" CITY;
  input "Enter your organization (e.g. Blockchain Ltd.)" ORGANIZATION;
  input "Enter your organizational unit (e.g. Fincance)" ORGANIZATIONAL_UNIT;
  input "Enter your email (e.g. some.email@some.real.provider.com)" EMAIL;

  echo 'set_var EASYRSA_REQ_COUNTRY "'$COUNTRY'"' >> vars;
  echo 'set_var EASYRSA_REQ_PROVINCE "'$PROVINCE'"' >> vars;
  echo 'set_var EASYRSA_REQ_CITY "'$CITY'"' >> vars;
  echo 'set_var EASYRSA_REQ_ORG "'$ORGANIZATION'"' >> vars;
  echo 'set_var EASYRSA_REQ_OU "'$ORGANIZATIONAL_UNIT'"' >> vars;
  echo 'set_var EASYRSA_REQ_EMAIL "'$EMAIL'"' >> vars;

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
  info "You will be prompted to enter the Distinguished Name (DN) information for";
  info "this CA. For each field, you can accept the default value by pressing ENTER.";
  info "";
  warn "Don't accept the default value of OU (IT). Instead, enter the value 'ROOT-CA'.";
  input "Press enter to continue...";
fi;

cd "$BDB_NODE_CA_DIR/$EASYRSA_DIR/easyrsa3";
./easyrsa init-pki;
./easyrsa build-ca;
