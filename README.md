# IGTI-Desafio2

## Desafio do segundo modulo do Bootcamp de Professional DevOps

## Sobre

Pipeline de CI/CD para implantação de cluster Kubernetes Cloud Native (AKS) com Jenkins e Terraform. 

## Topologia

![alt text](https://willianromaocursos.blob.core.windows.net/public/IGTI-Desafio2-DevOps.png)

## Pipeline

```groovy
pipeline {
    agent any

    stages {
        stage('Git Clone') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/willianromao/IGTI-Desafio2-Jenkins.git'

            }
        }
        stage('Az Login') {
            steps {
                withCredentials([azureServicePrincipal('AZURE_CREDENTIAL')]) {
                sh "ssh root@Docker 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'"
                }

            }
        }
        stage('Terraform init') {
            steps {
                // Get some code from a GitHub repository
                withCredentials([azureServicePrincipal('AZURE_CREDENTIAL')]) {
                sh """
                ssh root@Docker 'export RD_AZURE_CLIENT_ID=$AZURE_CLIENT_ID && \
				export RD_AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET && \
				export RD_AZURE_TENANT_ID=$AZURE_TENANT_ID && \
				export RD_AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID && \
				envsubst < /root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation/main.tf > /root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation/main.tf.bak && \
				cp /root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation/main.tf.bak /root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation/main.tf && \
				terraform -chdir=/root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation init'
                """
                }
            }
        }
        stage('Terraform plan') {
            steps {
                // Get some code from a GitHub repository
                sh "ssh root@Docker 'terraform -chdir=/root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation plan'"

            }
        }
        stage('Terraform apply') {
            steps {
                // Get some code from a GitHub repository
                sh "ssh root@Docker 'terraform -chdir=/root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation apply -auto-approve'"

            }
        }
        stage('Docker Build') {
            steps {
                // Get some code from a GitHub repository
                sh "ssh root@Docker 'docker build -t docker.io/willianromao/azure-vote-front:v$BUILD_NUMBER /root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/azure-vote'"

            }
        }
        stage('Docker Push') {
            steps {
                // Get some code from a GitHub repository
                sh "ssh root@Docker 'docker push docker.io/willianromao/azure-vote-front:v$BUILD_NUMBER'"

            }
        }
        stage('Kubernetes Get-Credentials') {
            steps {
                // Get some code from a GitHub repository
                sh "ssh root@Docker 'az aks get-credentials --resource-group jenkins-lab --name IGTI-aks1 --overwrite-existing'"

            }
        }
        stage('Kubernetes Apply') {
            steps {
                // Get some code from a GitHub repository
                sh "ssh root@Docker 'export RD_IMAGE_BUILD='willianromao/azure-vote-front:v$BUILD_NUMBER' && envsubst < /root/compose/jenkins/jenkins_home/workspace/AzureVotingApp/automation/azure-vote-all-in-one-redis.yaml | kubectl apply -f -'"

            }
        }
    }

}
```
![alt text](https://willianromaocursos.blob.core.windows.net/public/IGTI-Desafio2-DevOps-Pipeline.jpg)
