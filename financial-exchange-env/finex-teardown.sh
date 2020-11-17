#!/bin/bash

function showUsage() {
    echo "    " >&2
    echo "$(basename $0) -b delete-target "
    echo "    " >&2
    echo "               -b delete-target  required argument   " >&2
    echo "                               business | middleware | infra | all " >&2
    echo "                               business - delete application, api gateway, discover and config services   " >&2
    echo "                               middleware - delete cassandra, kafka, zookeeper and zipking services" >&2
    echo "                               infra - delete load balancers and nat gateways " >&2
    echo "                               all - delete business, middleware and infra  " >&2
    echo "   " >&2
}

function delete_business_services_stacks() {
    for STACK in "finex-dns-us-east-2" \
    "finex-application-services-us-east-2-zone1" \
    "finex-apigateway-service-us-east-2-zone1" \
    "finex-discovery-service-us-east-2-zone1" \
    "finex-config-service-us-east-2-zone1" \
    "finex-zipkin-services-us-east-2-zone1"; do
       aws cloudformation delete-stack --stack-name $STACK   
    done

    for i in {1..10}; do
        echo "Deleting application, api gateway, discover and config services stacks ..."
        sleep 30
    done
    echo "Exiting delete_business_services_stacks"
}

function delete_middleware_services_stacks() {

    for MSTACK in "finex-kafka-services-us-east-2" \
    "finex-cassandra-services-us-east-2"; do
        echo "Deleting $MSTACK..."
        aws cloudformation delete-stack --stack-name $MSTACK   
    done

    for i in {1..10}; do
        echo "Deleting kafka and cassandra stacks ..."
        sleep 30
    done
    echo "Exiting delete_middleware_services_stacks"

}

function delete_infra_services_stacks() {

    for ESTACK in "finex-nat-gateway-us-east-2-zone1" \
    "finex-nat-gateway-us-east-2-zone2" \
    "finex-external-alb-us-east-2" \
    "finex-internal-alb-us-east-2"; do
        aws cloudformation delete-stack --stack-name $ESTACK
    done

    for i in {1..10}; do
        echo "Deleting load balancers and nat gateway stacks ..."
        sleep 30
    done
    echo "Exiting delete_infra_services_stacks"

}

function delete_all() {
    delete_business_services_stacks
    delete_middleware_services_stacks
    delete_infra_services_stacks
}

while getopts "b:h" opt; do
  case ${opt} in
    b )
      FINEX_DELETE_TARGET=$OPTARG
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

if [[ -z "$FINEX_DELETE_TARGET" ]]; then
    echo "Missing delete target. Must be one of [business, middleware, infra, all]"
    exit 1
fi

if [[ "$FINEX_DELETE_TARGET" == "business" ]]; then
    delete_business_services_stacks
fi 

if [[ "$FINEX_DELETE_TARGET" == "middleware" ]]; then
    delete_middleware_services_stacks
fi 

if [[ "$FINEX_DELETE_TARGET" == "infra" ]]; then
    delete_infra_services_stacks
fi 

if [[ "$FINEX_DELETE_TARGET" == "all" ]]; then
    delete_all
fi 