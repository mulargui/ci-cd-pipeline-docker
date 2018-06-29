#!/usr/bin/env bash

set -x
export DEBIAN_FRONTEND=noninteractive
export APP-DIR=/vagrant

# select which components to provision
OS_REFRESH=N
DOCKER=N
CLEAR=N
CLEANUP=N
KUBE=N
MVN=N
APP=N
JENKINS=N

# you can also set the flags using the command line
for var in "$@"
do
	if [ "OS_REFRESH" == "$var" ]; then OS_REFRESH=Y 
	fi
	if [ "DOCKER" == "$var" ]; then DOCKER=Y 
	fi
	if [ "CLEAR" == "$var" ]; then CLEAR=Y 
	fi
	if [ "CLEANUP" == "$var" ]; then CLEANUP=Y 
	fi
	if [ "KUBE" == "$var" ]; then KUBE=Y 
	fi
	if [ "MVN" == "$var" ]; then MVN=Y 
	fi
	if [ "APP" == "$var" ]; then APP=Y 
	fi
	if [ "JENKINS" == "$var" ]; then JENKINS=Y 
	fi
	if [ "ALL" == "$var" ]; then 
		OS_REFRESH=Y 
		DOCKER=Y 
		# KUBE=Y 
		# JENKINS=Y 
	fi
done

# keep the OS fresh
if [ "${OS_REFRESH}" == "Y" ]; then
	sudo apt-get -qq update
	sudo apt-get -qq -fy install
	sudo apt-get -qq -y upgrade
	sudo apt-get -qq -y autoremove
fi

# install docker
if [ "${DOCKER}" == "Y" ]; then
	sudo apt-get remove docker docker-engine
	sudo apt-get -qq update
	#Trusty only: sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
	sudo apt-get -qq update
	sudo apt-get -y install curl apt-transport-https ca-certificates software-properties-common
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get -qq update
	sudo apt-get -y install docker-ce
	# sudo usermod -aG docker vagrant
fi

# clean up all containers
if [ "${CLEAR}" == "Y" ]; then
	v=$(sudo docker ps -aq)
	sudo docker stop $v
	sudo docker kill $v
	sudo docker rm -f $v
fi

# clean up all images
if [ "${CLEANUP}" == "Y" ]; then
	sudo docker rmi -f $(sudo docker images -aq)
fi

# install kubernetis
if [ "${KUBE}" == "Y" ]; then
	# install minikube
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.28.0/minikube-linux-amd64 && \
		chmod +x minikube && \
		sudo mv minikube /usr/local/bin/

	# install kubectl
	sudo apt-get update && sudo apt-get install -y apt-transport-https
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	sudo touch /etc/apt/sources.list.d/kubernetes.list 
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubectl
fi

# run maven container
if [ "${MVN}" == "Y" ]; then
	sudo docker stop MVN
	sudo docker rm -f MVN
	sudo docker run --name MVN -ti -v $(APP-DIR):/my-app -v ~/.m2:/root/.m2 maven:3.5.3-jdk-10 /bin/bash
fi

# create empty maven app
if [ "${APP}" == "Y" ]; then
	sudo docker run -ti \
		-v $(APP-DIR):/app-root \
		-v ~/.m2:/root/.m2 \
		-w /app-root \
		maven:3.5.3-jdk-10 mvn \
			-B archetype:generate \
			-DarchetypeGroupId=org.apache.maven.archetypes \
			-DgroupId=com.mycompany.app \
			-DartifactId=my-app
	mkdir $(APP-DIR)/util
	cp Jenkinsfile Vagrantfile $(APP-DIR)
	cp ctool.sh jenkinsdockerfile $(APP-DIR)/util
fi

# run jenkins container
if [ "${JENKINS}" == "Y" ]; then
	# create  container image if needed
	if [ "$(sudo docker images | grep dockerjenkins)" == "" ]; then
		sudo docker build \
			--build-arg HOST_DOCKER_GROUP_ID="`getent group docker | cut -d':' -f3`" \
			-t dockerjenkins \
			-f $(APP-DIR)/util/jenkinsdockerfile \
			.
	fi

	if [ ! -d "$HOME/jenkins_home" ]; then
		sudo mkdir $HOME/jenkins_home
		sudo chmod -R 777 $HOME/jenkins_home
	fi 

	sudo docker stop JENKINS
	sudo docker rm -f JENKINS
	sudo docker run -d \
		--name JENKINS \
		-p 8080:8080 -p 50000:50000 \
		-v ~/jenkins_home:/var/jenkins_home \
		-v $(APP-DIR):/my-app \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /usr/bin/docker:/usr/bin/docker \
		dockerjenkins
fi
