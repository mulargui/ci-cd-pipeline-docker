pipeline {
	agent any
	stages {
        stage('Compile') {
			agent {
				docker { 
					image 'maven:3.5.3-jdk-10'
					args '-v $HOME/.m2:/root/.m2'
					reuseNode true
				}
			}
            steps {
                sh 'mvn validate compile'
            }
		}
        stage('Test') {
			agent {
				docker { 
					image 'maven:3.5.3-jdk-10'
					args '-v $HOME/.m2:/root/.m2'
					reuseNode true
				}
			}
            steps {
                sh 'mvn test'
            }
        }
        stage('Package') {
			agent {
				docker { 
					image 'maven:3.5.3-jdk-10'
					args '-v $HOME/.m2:/root/.m2'
					reuseNode true
				}
			}
            steps {
                sh 'mvn package'
            }
        }
        stage('Deploy') {
            steps {
				script {
					docker.build("my-app:${env.BUILD_ID}", "-f ./infrastructure/appdockerfile .").tag("latest")
					/*sh '''
						set +e		# Disable exit on non 0
						docker rmi -f $(docker images | grep my-app | grep -v "latest" | awk '{print $3}')
						exit 0
					'''*/
				}
            }
        }
        stage('Run') {
            steps {
				sh '''
					set +e		# Disable exit on non 0
					docker stop MYAPP
					docker rm -f MYAPP
					set -e
					docker run -d --name MYAPP my-app:$BUILD_ID
				'''
            }
		}
    }
}
