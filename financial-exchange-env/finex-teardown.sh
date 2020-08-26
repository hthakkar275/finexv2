#!/bin/bash

# Delete all but the finex-application-services and finex-internal-alb stacks
# These two stacks are dependencies for other stacks whereby output exported by
# these two stacks are cross-stack-referened. So we need to wait a while before 
# the "child" stacks are well underway for deletion. The instance id values
# exported by finex-application-services is used by the finex-internal-alb-listener
# and finex-external-alb-listener for creating target groups. The ARN of ALB
# created by finex-internal-alb and finex-external-alb are used by their 
# respective listnner stacks.

for STACK in "finex-dns-us-east-2" \
"finex-application-services-us-east-2-zone1" \
"finex-apigateway-service-us-east-2-zone1" \
"finex-discovery-service-us-east-2-zone1" \
"finex-config-service-us-east-2-zone1"; do
    aws cloudformation delete-stack --stack-name $STACK   
done

# Wait 30 seconds for the dependent stacks to be well underway in the deletion
# before proceeding to issue delete stack commands on their dependencies
sleep 600

echo "Deleting load balancer stacks"

for ESTACK in "finex-nat-gateway-us-east-2" \
"finex-external-alb-us-east-2" \
"finex-internal-alb-us-east-2"; do
    aws cloudformation delete-stack --stack-name $ESTACK
done
