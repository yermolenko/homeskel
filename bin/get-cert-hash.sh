#!/bin/bash

certfile=${1:?Cert filename is required}

openssl x509 -hash -in "$certfile" -noout
