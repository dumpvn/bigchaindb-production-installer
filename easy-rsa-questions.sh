#!/bin/bash

source ./main.sh;

title_block "Configuring certificate paramets."

input "Enter your 2-character country code (e.g. Belgium -> BE)" COUNTRY;
input "Enter your province (e.g. Vlaams-Brabant)" PROVINCE;
input "Enter your city (e.g. Leuven)" CITY;
input "Enter your organization (e.g. Blockchain Ltd.)" ORGANIZATION;
input "Enter your organizational unit (e.g. Fincance)" ORGANIZATIONAL_UNIT;
input "Enter your email (e.g. some.email@some.real.provider.com)" EMAIL;

echo 'set_var EASYRSA_DN "org"' >> vars;
echo 'set_var EASYRSA_KEY_SIZE 4096' >> vars;

echo 'set_var EASYRSA_REQ_COUNTRY "'$COUNTRY'"' >> $EASYRSA_CONF;
echo 'set_var EASYRSA_REQ_PROVINCE "'$PROVINCE'"' >> $EASYRSA_CONF;
echo 'set_var EASYRSA_REQ_CITY "'$CITY'"' >> $EASYRSA_CONF;
echo 'set_var EASYRSA_REQ_ORG "'$ORGANIZATION'"' >> $EASYRSA_CONF;
echo 'set_var EASYRSA_REQ_EMAIL "'$EMAIL'"' >> $EASYRSA_CONF;