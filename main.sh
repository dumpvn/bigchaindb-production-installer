#!/bin/bash

# bigchaindb-production-installer "header" file.

# ENV

BDB_ROOT_DIR=$(pwd);
VERBOSE=true;

BREAK="================================================================================";

BDB_NODE_CA_DIR="bdb-node-ca";
MONGODB_SERVER_CERT_DIR="member-cert";
MONGODB_CLIENT_CERT_DIR="client-cert";

EASYRSA_URL="https://github.com/OpenVPN/easy-rsa/archive/3.0.1.tar.gz";
EASYRSA_FILE="3.0.1.tar.gz";
EASYRSA_DIR="easy-rsa-3.0.1";
EASYRSA_CONF="easyrsa.conf";

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