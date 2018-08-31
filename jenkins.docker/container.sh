#!/usr/bin/env bash

#
# NOTE: There is a dependency in other repos using MySQLDB to link to MySQL container.
#

set -x
export DEBIAN_FRONTEND=noninteractive
# Absolute path to this repo
SCRIPTPATH=$(readlink -f "$0")
export REPOPATH=$(dirname "$SCRIPTPATH")/..

# what you can do
CLEAR=N
CLEANUP=N
BUILD=N
RUN=N
INTERACTIVE=N
APP=N

# you can also set the flags using the command line
for var in "$@"
do
	if [ "CLEAR" == "$var" ]; then CLEAR=Y 
	fi
	if [ "CLEANUP" == "$var" ]; then CLEANUP=Y 
	fi
	if [ "BUILD" == "$var" ]; then BUILD=Y 
	fi
	if [ "RUN" == "$var" ]; then RUN=Y 
	fi
	if [ "INTERACTIVE" == "$var" ]; then INTERACTIVE=Y 
	fi
	if [ "APP" == "$var" ]; then APP=Y 
	fi
done

# clean up all containers
if [ "${CLEAR}" == "Y" ]; then
	sudo docker stop JENKINS MVN
	sudo docker kill JENKINS MVN
	sudo docker rm -f JENKINS MVN
fi

# clean up all images
if [ "${CLEANUP}" == "Y" ]; then
	$0 CLEAR
	sudo docker rmi -f maven myjenkins
fi

# create images
if [ "${BUILD}" == "Y" ]; then
	$0 CLEAR
	$0 CLEANUP
	sudo docker pull maven:3.5.3-jdk-10
	sudo docker build \
		--build-arg HOST_DOCKER_GROUP_ID="`getent group docker | cut -d':' -f3`" \
		-t myjenkins \
		-f $REPOPATH/jenkins.docker/dockerfile \
		.
fi

# run jenkins
if [ "${RUN}" == "Y" ]; then
	$0 CLEAR
	if [ "$(sudo docker images | grep myjenkins)" == "" ]; then
		$0 BUILD
	fi
	
	if [ ! -d "$HOME/jenkins_home" ]; then
		sudo mkdir $HOME/jenkins_home
		sudo chmod -R 777 $HOME/jenkins_home
	fi 
	
	sudo docker run -d \
		--name JENKINS \
		-p 8080:8080 -p 50000:50000 \
		-v ~/jenkins_home:/var/jenkins_home \
		-v $REPOPATH:/my-app \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /usr/bin/docker:/usr/bin/docker \
		myjenkins
fi

# interactive maven
if [ "${INTERACTIVE}" == "Y" ]; then
	#./$0 CLEAR
	if [ "$(sudo docker images | grep maven)" == "" ]; then
		$0 BUILD
	fi
	sudo docker run --name MVN -ti -v $REPOPATH:/my-app \
		-v ~/.m2:/root/.m2 maven:3.5.3-jdk-10 /bin/bash
fi

# create empty maven app
if [ "${APP}" == "Y" ]; then
	sudo docker run -ti \
		-v $REPOPATH:/app-root \
		-v ~/.m2:/root/.m2 \
		-w /app-root \
		maven:3.5.3-jdk-10 mvn \
			-B archetype:generate \
			-DarchetypeGroupId=org.apache.maven.archetypes \
			-DgroupId=com.mycompany.app \
			-DartifactId=my-app
fi

