# ci-cd-pipeline-docker
A barebone jenkins pipeline of a java app using docker

My intent was to create a local CI/CD pipeline to support development of a classic java app.
The dev cycle is to develop in Windows using several tools and at a command (in a browser in this case) run a pipeline that deploys the app in a local VM.
I use maven for compile/test/package
The application is deployed and run inside a docker container

I use jenkins to run the pipeline. Jenkins also runs in a docker container and all the steps in the pipeline are executed in containers. 
This arrangement avoids to install plugins for maven or other tools, docker downloads the images of the tools needed.
You only needs to install two plugins in Jenkins:
1. Pipeline 
2. File System SCM (or your favorite local source control tool)

In the pipeline configure the file system SCM to point to where you installed the app.

Files in this repo:\
Jenkinsfile. Describes the compile/test/package/deploy/run pipeline\
Jenkinsfile.mvn. A first attempt using maven as a plugin instead of a container\
Vagrantfile. I use vagrant and virtualbox to run my local VM. Very convenient as I can share folders between my Windows 10 host and my VM and do all the editing using Windows tools.\
src/... my simple java app\
util/jenkinsdockerfile. A docker file to build an image that has Jenkins and docker inside and allows to run containers from inside the container.\
util/appdockerfile. A docker file to pack the app in a docker image and run it as a container.\
util/ctool.sh A utility shellscript that I use to install docker, create the images, run Jenkins,... easy to follow.\

Enjoy!
