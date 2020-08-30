#!/bin/bash

./finex-build-certs.sh -t internal-ca -p internalca -s s3://finex-security
./finex-build-certs.sh -t product -p product -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t participant -p participant -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t order -p order -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t orderbook -p orderbook -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t trade -p trade -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t apigateway -p apigateway -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t discovery -p discovery -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t config -p config -i internal-ca -P internalca -s s3://finex-security
./finex-build-certs.sh -t ilb -p ilb -i internal-ca -P internalca -r us-east-2 -s s3://finex-security
./finex-build-certs.sh -t elb -p elb -i internal-ca -P internalca -f finex.naperiltech.com -s s3://finex-security
rm internal-ca*
