pipeline {
    agent any

    environment {
        IMAGE_NAME = 'go-test'
        DOCKERHUB_USER = 'sharmachandan487'
    }

    stages {
        stage('Source') {
            steps {
                git branch: 'main', url: 'https://github.com/chandansharma1998/go-demo.git'
            }
        }

        stage('Docker build and push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    bat '''
                        docker --version
                        docker login -u %DOCKERHUB_USER% -p %DOCKERHUB_PASS%
                        docker build -t %DOCKERHUB_USER%/%IMAGE_NAME%:%BUILD_NUMBER% .
                        docker push %DOCKERHUB_USER%/%IMAGE_NAME%:%BUILD_NUMBER%
                    '''
                }
            }
        }

        stage('Deploy Canary') {
            steps {
                sh 'kubectl apply -f rollout.yaml'
                sh 'kubectl apply -f service.yaml'
                sh 'kubectl apply -f virtualservice.yaml'
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    def GATEWAY_IP = sh(script: "minikube service istio-ingress -n istio-system --url", returnStdout: true).trim()
                    sh "curl ${GATEWAY_IP}"
                }
            }
        }

        stage('Approval to Promote') {
            steps {
                input message: 'Promote to full rollout?'
            }
        }

        stage('Promote') {
            steps {
                sh 'kubectl argo rollouts promote demo-app'
            }
        }
    }

    post {
        failure {
            echo 'Rolling back...'
            sh 'kubectl argo rollouts undo demo-app'
        }
    }
}
