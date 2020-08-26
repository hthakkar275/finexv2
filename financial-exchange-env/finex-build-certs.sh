#!/bin/bash

function showUsage() {
    echo "    " >&2
    echo "$(basename $0) -c target -p password -i -P -s -h" >&2
    echo "    " >&2
    echo "    -t Target service for wich to build TLS private key, certificate and keystore  " >&2
    echo "          internal-ca - Internal certificate authority " >&2
    echo "          ilb - Internal AWS Application Load Balancer " >&2
    echo "          elb - Internet-facing AWS Elastic Load Balancer " >&2
    echo "          product | participant | order | orderbook | trade - Finex services " >&2
    echo "  "  >&2
    echo "    -p Password for private key and keystore for the specified target  " >&2
    echo "  "  >&2
    echo "    -i Internal CA alias used to sign the CSR of dedicated service  " >&2
    echo "          Required only for dedicated service and not for the internal-ca itself " >&2
    echo "          It is assumed that the private key and certificate of the internal CA have name prefix matching this value " >&2
    echo "          Example: If this argument is 'myca' then it is assumed that there is a myca-key.pem and myca.crt files in current directory " >&2
    echo "  "  >&2
    echo "    -P Password for internal CA private key. This is used for sigining the deciated service CSR with internal CA  " >&2
    echo "   " >&2
    echo "    -s Optional AWS S3 bucket URI (example: s3://finex-security) where to place the keystore. (Optional) " >&2
    echo "          If not provided, the TLS artifacts are placed in current directory " >&2
    echo "          If provided, it is assumed that " >&2 
    echo "              the local machine has the AWS CLI installed and CLI credentials (access and secret key) are configured " >&2 
    echo "              the S3 bucket URI is already created with appropriate access restrictions " >&2 
    echo "   " >&2
    echo "    -h show usage  " >&2
    echo "   " >&2
}

# ---------------------------------------------------------------------------
# Create a self-signed certificate that will serve as the internal certificate 
# authority. This internal-ca certificate will sign the certificates of the
# individual services. The internal-ca certificate will be imported as trusted
# certificate into the Java SE cacerts so that services can communicate with 
# one another without having to import all individual certificates into Java
# cacerts file
# ---------------------------------------------------------------------------
function createInternalCA() {
    # Private key for internal certificate authority
    openssl req -newkey rsa:2048 -keyout $FINEX_TLS_TARGET-key.pem -out $FINEX_TLS_TARGET.csr -passout pass:$FINEX_TLS_PASSWORD \
    -subj "/C=US/ST=Illinois/L=Chicago/O=Acme Inc/OU=Administration/CN=Acme Certificate Authority"

    # Extensions configuration file to add BasicConfiguration designating
    # the certificate as a CA certificate
    touch $FINEX_TLS_TARGET-extensions.cnf
    echo "basicConstraints=critical,CA:TRUE" >> $FINEX_TLS_TARGET-extensions.cnf

    # Create empty serial number file. This file will be used to create serial numbers
    # for signing certificate requets
    touch $FINEX_TLS_TARGET-serial.ser 
    echo "10B9342AB325ED00" > $FINEX_TLS_TARGET-serial.ser 

    # Self-sign the CA certificate
    openssl x509 -req -in $FINEX_TLS_TARGET.csr -passin pass:$FINEX_TLS_PASSWORD -days 365 -signkey $FINEX_TLS_TARGET-key.pem \
    -CAserial $FINEX_TLS_TARGET-serial.ser -out $FINEX_TLS_TARGET.crt -extfile $FINEX_TLS_TARGET-extensions.cnf

    echo "Completed TLS artificats for Internal CA."
    echo "The target name and password used for this Internal CA must be specified "
    echo "as '-i' and '-P' argument, respectively when creating service certificates"

}

# ---------------------------------------------------------------------------
# 1. Create a private key and CSR 
# 2. Sign the service CSR with internal-ca certificate
# 3. Import the service certificate into dedicated service PKCS12 keystore
# ---------------------------------------------------------------------------
function createService() {
    # Private key and CSR
    openssl req -newkey rsa:2048 -keyout finex-$FINEX_TLS_TARGET-key.pem -out finex-$FINEX_TLS_TARGET.csr -passout pass:$FINEX_TLS_PASSWORD \
    -subj "/C=US/ST=Illinois/L=Chiago/O=NaperIlTech/OU=Finex/CN=*.$FINEX_TLS_TARGET.finex.com"

    # Extensions configuration file to add DNS names for which 
    # this certificate is applicable
    touch finex-$FINEX_TLS_TARGET-extensions.cnf
    echo "subjectAltName=DNS:*.$FINEX_TLS_TARGET.finex.com" >> finex-$FINEX_TLS_TARGET-extensions.cnf

    # Sign the service certificate request (csr) using the Internal CA certificate
    openssl x509 -req -in finex-$FINEX_TLS_TARGET.csr -passin pass:$FINEX_INTERNAL_CA_PASSWORD -days 365 -CA $FINEX_INTERNAL_CA.crt -CAkey $FINEX_INTERNAL_CA-key.pem \
    -CAserial $FINEX_INTERNAL_CA-serial.ser -out finex-$FINEX_TLS_TARGET.crt -extfile finex-$FINEX_TLS_TARGET-extensions.cnf

    # PKCS12 keystore with service certificate chain that includes the Internal CA certificate.
    openssl pkcs12 -export -in finex-$FINEX_TLS_TARGET.crt -inkey finex-$FINEX_TLS_TARGET-key.pem -passin pass:$FINEX_TLS_PASSWORD \
    -name $FINEX_TLS_TARGET -CAfile $FINEX_INTERNAL_CA.crt -caname $FINEX_INTERNAL_CA -chain -out finex-$FINEX_TLS_TARGET.p12 -passout pass:$FINEX_TLS_PASSWORD

    echo "$FINEX_TLS_PASSWORD" > ./$FINEX_TLS_TARGET.txt

    echo "Completed TLS artificats for $FINEX_TLS_TARGET."
}

# ---------------------------------------------------------------------------
# Copy to S3 bucket
# ---------------------------------------------------------------------------
function copyToS3() {
    if [[ "$FINEX_TLS_TARGET" == "internal-ca" ]]; then 
        if [[ -f "internal-ca.crt" ]]; then
            aws s3 cp ./$FINEX_TLS_TARGET.crt $FINEX_S3_BUCKET
            echo "Copied k$FINEX_TLS_TARGET.crt to $FINEX_S3_BUCKET on AWS account $AWS_ACCOUNT"
        fi
    else 
        if [[ -f "finex-$FINEX_TLS_TARGET.p12" ]]; then 
            aws s3 cp ./finex-$FINEX_TLS_TARGET.p12 $FINEX_S3_BUCKET
            aws s3 cp ./$FINEX_TLS_TARGET.txt $FINEX_S3_BUCKET
            rm finex-$FINEX_TLS_TARGET*
            rm $FINEX_TLS_TARGET.txt
            echo "Copied keystore file finex-$FINEX_TLS_TARGET.p12 and password file $FINEX_TLS_TARGET.txt to $FINEX_S3_BUCKET on AWS account $AWS_ACCOUNT"
        fi
    fi
}

while getopts ":t:p:i:P:s:h" opt; do
  case ${opt} in
    t )
      FINEX_TLS_TARGET=$OPTARG
      ;;
    p )
      FINEX_TLS_PASSWORD=$OPTARG
      ;;
    s )
      FINEX_S3_BUCKET=$OPTARG
      ;;
    i )
      FINEX_INTERNAL_CA=$OPTARG
      ;;
    P )
      FINEX_INTERNAL_CA_PASSWORD=$OPTARG
      ;;
    h )
      showUsage
      exit 0
      ;;
    \? )
      echo "****** Invalid argument $opt"
      showUsage
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;  
  esac
done

VALID_ARGUMENTS="true"
if [[ -z "$FINEX_TLS_TARGET" ]]; then
    VALID_ARGUMENTS="false"
    echo "Missing target for TLS certificate artifacts. Must be one of [internal-ca, ilb, elb, apigateway, discovery, config, product, participant, order, orderbook, trade]"
else 
    case "$FINEX_TLS_TARGET" in
        ilb|elb|apigateway|discovery|config|product|participant|order|orderbook|trade)
            echo "Building TLS artificats for $FINEX_TLS_TARGET ..."
            if [[ -z "$FINEX_INTERNAL_CA"  || -z "$FINEX_INTERNAL_CA_PASSWORD"  ]]; then 
                VALID_ARGUMENTS="false"
                echo "Must specify internal CA alias and password for service targert"
            fi
            ;;
        internal-ca)
            ;;
        *)
            VALID_ARGUMENTS="false"
            echo "$FINEX_TLS_TARGET is an invalid target"
            ;;
    esac
fi

if [[ -z "$FINEX_TLS_PASSWORD" ]]; then
    VALID_ARGUMENTS="false"
    echo "Missing password for TLS private key and keystore"
fi

if [[ -n "$FINEX_S3_BUCKET" ]]; then
    AWS_CLI_CHECK=`aws sts get-caller-identity 2> /dev/null`
    if [[ "$AWS_CLI_CHECK" == *"Account"* ]]; then
        AWS_ACCOUNT=`aws sts get-caller-identity | grep Account | awk -F: '{print $2}' | tr '"' ' ' | tr ',', ' '`
    else
        VALID_ARGUMENTS="false"
        echo "AWS CLI is not installed or local machine is improperly credentialed"
    fi
fi

if [[ "$VALID_ARGUMENTS" == "false" ]]; then
    showUsage
    exit 1
fi

case "$FINEX_TLS_TARGET" in
    internal-ca)
        createInternalCA
        ;;
    ilb|elb|apigateway|discovery|config|product|participant|order|orderbook|trade)
        createService
        ;;
esac
 
if [[ -n "$FINEX_S3_BUCKET" ]]; then
    copyToS3
fi
