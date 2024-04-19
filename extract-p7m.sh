#!/bin/sh

openssl smime -decrypt -verify -inform DER -in "${1}.p7m" -noverify -out "$1"
