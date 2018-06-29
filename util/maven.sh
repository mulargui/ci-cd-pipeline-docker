sudo docker stop MVN
sudo docker rm -f MVN
sudo docker run -ti \
	--name MVN \
	-v /vagrant:/my-app \
	-v ~/.m2:/root/.m2 \
	-w /my-app \
	maven:3.5.3-jdk-10 mvn clean compile test
exit

mvn clean compile
cd ./target/classes && java com.mycompany.app.App

mvn \
  -B archetype:generate \
  -DarchetypeGroupId=org.apache.maven.archetypes \
  -DgroupId=com.mycompany.app \
  -DartifactId=my-app

  <properties>
    <maven.compiler.source>1.6</maven.compiler.source>
    <maven.compiler.target>1.6</maven.compiler.target>
  </properties>
  
mvn package
java com.mycompany.app.App

validate: validate the project is correct and all necessary information is available
compile: compile the source code of the project
test: test the compiled source code using a suitable unit testing framework. These tests should not require the code be packaged or deployed
package: take the compiled code and package it in its distributable format, such as a JAR.
integration-test: process and deploy the package if necessary into an environment where integration tests can be run
verify: run any checks to verify the package is valid and meets quality criteria
install: install the package into the local repository, for use as a dependency in other projects locally
deploy: done in an integration or release environment, copies the final package to the remote repository for sharing with other developers and projects.
clean: cleans up artifacts created by prior builds
site: generates site documentation for this project