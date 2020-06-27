#!/bin/bash

# Doing maven builds on all services
function maven_build_all_services() {
    FAILED_MAVEN_BUILD_COUNT=0
    for SVC in "config" "discovery" "apigateway" "products" "participants" "orders" "orderbooks" "trades"; do
        POM_PATH=$PATH_TO_SOURCE_CODE/financial-exchange-$SVC/pom.xml
        echo "Building $SVC service ..."
        MAVEN_BUILD_STATUS=`mvn -f $POM_PATH clean package | grep BUILD | awk '{print $3}'`
        if [[ $MAVEN_BUILD_STATUS == "SUCCESS" ]]; then
            echo "$SVC service build successful"
        else 
            echo "$SVC service build failed"
            (( FAILED_MAVEN_BUILD_COUNT++ ))
        fi  
    done
    if [[ $FAILED_MAVEN_BUILD_COUNT -eq 0 ]]; then
        echo "All services built successfully. Will proceed with docker builds"
    else 
        echo "Not all services built successfully. Will not proceed with docker builds"
        exit 1
    fi
}

# Build docker image for Configuation Service and push to docker hub
# The git repo URI and credentials must be declared as environment variables
# GIT_URI, GIT_USER and GIT_PASSWORD
function docker_build_config_service() {

    # Doing docker build and docker push on config service
    DOCKER_BUILD_STATUS_OUTPUT=`docker build \
    -f $PATH_TO_SOURCE_CODE/financial-exchange-config/dockerfile.configserver \
    --build-arg GIT_URI_ARG=$FINEX_GIT_REPO \
    --build-arg GIT_USER_ARG=$FINEX_GIT_USER \
    --build-arg GIT_PASSWORD_ARG=$FINEX_GIT_PASSWORD \
    -t ${FINEX_DOCKER_USERNAME}/finex-config-server \
    $PATH_TO_SOURCE_CODE/financial-exchange-config | grep "Successfully tagged"`
    DOCKER_BUILD_STATUS=`echo $DOCKER_BUILD_STATUS_OUTPUT  | awk '{print $1, $2}'`
    if [[ $DOCKER_BUILD_STATUS == "Successfully tagged" ]]; then
        echo "Config service docker build successful"
        echo "Pushing Config service docker image to docker hub"
        DOCKER_TAG=`echo $DOCKER_BUILD_STATUS_OUTPUT  | awk '{print $3}'`
        DOCKER_PUSH_OUTPUT=`docker push $DOCKER_TAG | grep "latest"`
        if [[ "$DOCKER_PUSH_OUTPUT" =~ "latest" ]]; then
            echo "Config service docker image pushed to dockerhub successfully"
        else 
            echo "Something is not right. Config service docker image push may have failed"
        fi
    else 
        echo "Config service docker build failed. Exiting"
        exit 1
    fi
}

# Build docker image for all Application Services and push to docker hub
function docker_build_non_config_services() {
    for SVC in "apigateway" "discovery" "products" "participants" "orders" "orderbooks" "trades"; do
        DOCKER_BUILD_STATUS_OUTPUT=`docker build \
        -f $PATH_TO_SOURCE_CODE/financial-exchange-$SVC/dockerfile.$SVC \
        -t ${FINEX_DOCKER_USERNAME}/finex-$SVC-aws:latest \
        $PATH_TO_SOURCE_CODE/financial-exchange-$SVC | grep "Successfully tagged"`

        DOCKER_BUILD_STATUS=`echo $DOCKER_BUILD_STATUS_OUTPUT  | awk '{print $1, $2}'`
        if [[ $DOCKER_BUILD_STATUS == "Successfully tagged" ]]; then
            echo "$SVC service docker build successful"
            echo "Pushing $SVC service docker image to docker hub"
            DOCKER_TAG=`echo $DOCKER_BUILD_STATUS_OUTPUT  | awk '{print $3}'`
            DOCKER_PUSH_OUTPUT=`docker push $DOCKER_TAG | grep "latest"`
            if [[ "$DOCKER_PUSH_OUTPUT" =~ "latest" ]]; then
                echo "$SVC service docker image pushed to dockerhub successfully"
            else 
                echo "Something is not right. $SVC service docker image push may have failed"
                exit 2
            fi
        else 
            echo "$SVC service docker build failed"
        fi
    done
}

# Maven build all services
maven_build_all_services 

# docker build configuration service
docker_build_config_service  

# docker build for application services
docker_build_non_config_services

