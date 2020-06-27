#!/bin/bash

# Delete all but the finex-application-services and finex-internal-alb stacks
# These two stacks are dependencies for other stacks whereby output exported by
# these two stacks are cross-stack-referened. So we need to wait a while before 
# the "child" stacks are well underway for deletion. The instance id values
# exported by finex-application-services is used by the finex-internal-alb-listener
# and finex-external-alb-listener for creating target groups. The ARN of ALB
# created by finex-internal-alb and finex-external-alb are used by their 
# respective listnner stacks.

for STACK in "finex-dns" "finex-external-alb-listener" "finex-internal-alb-listener" \
 "finex-config-service" "finex-nat-gateway"; do
    aws cloudformation delete-stack --stack-name $STACK   
done

# Wait 30 seconds for the dependent stacks to be well underway in the deletion
# before proceeding to issue delete stack commands on their dependencies
sleep 30

for STACK in "finex-external-alb" "finex-internal-alb" "finex-application-services"; do
    aws cloudformation delete-stack --stack-name $STACK   
done
