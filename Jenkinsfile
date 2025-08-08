pipeline {
    agent any

    environment {
        IMAGE_NAME = 'go-demo'
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
                bat '''
                    kubectl apply -f rollout.yaml
                    kubectl apply -f service.yaml
                    kubectl apply -f virtualservice.yaml
                '''
            }
        }

        stage('Approval to Promote') {
            steps {
                input message: 'Promote to full rollout?'
            }
        }

        stage('Promote Canary to Stable') {
            steps {
                bat '"C:\\Program Files (x86)\\kubectl-argo-rollouts\\kubectl-argo-rollouts.exe" promote go-demo'
            }
        }
    }

    post {
        failure {
            echo 'Rolling back...'
            bat 'kubectl-argo-rollouts undo go-demo'
        }
    }
}
