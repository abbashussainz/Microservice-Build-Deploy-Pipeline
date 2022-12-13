pipeline{

    agent any 

    tools{
        maven "Maven"
    }

    stages{
        stage("build & SonarQube analysis"){
            steps{
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn clean package sonar:sonar'
                }
            }
        }

        stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
        }

        stage("Maven Packaging"){
          steps{
           sh 'mvn package'
          }
        }

        stage("Build Image") {
            steps{
                sh 'docker build -t java-maven-app:$BUILD_NUMBER .'
            }
        }

        

        stage("Logging Into ECR"){
            steps{
                sh 'aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 266454083192.dkr.ecr.ap-northeast-1.amazonaws.com'
            } 
        }

        stage("Pushing Image To ECR"){
            steps{
                sh 'docker tag java-maven-app:$BUILD_NUMBER 266454083192.dkr.ecr.ap-northeast-1.amazonaws.com/maven-app:$BUILD_NUMBER'
                sh 'docker push 266454083192.dkr.ecr.ap-northeast-1.amazonaws.com/maven-app:$BUILD_NUMBER'
            }
        }
        
        stage("Logging into Helm repository "){
            steps{
                sh 'aws ecr get-login-password --region ap-northeast-1 | helm registry login --username AWS --password-stdin 266454083192.dkr.ecr.ap-northeast-1.amazonaws.com'
            }
        }

        stage("Update image tag in helm value file"){
            steps{
                sh "sed -i ' s/tag/'$BUILD_NUMBER'/ ' ./HELM-CHART/values.yaml "
                sh "cat ./HELM-CHART/values.yaml "

            }
        }

        stage("pushing helm package into ECR"){
            steps{
                sh "helm package HELM-CHART "
                sh "helm push helm-repo-0.1.0.tgz oci://266454083192.dkr.ecr.ap-northeast-1.amazonaws.com "
            }
        }

        stage ('Invoke_pipelineA') {
            steps {
                build job: 'pipelineA', parameters: [
                string(name: 'param1', value: "value1")
                ]
            }
        }
        
    }
}