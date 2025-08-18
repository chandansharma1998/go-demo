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

        stage('Static Analysis - GoSec & Lint') {
            steps {
                bat '''
                    go version
                    echo Running Gosec security scan...
                    gosec -fmt sarif -out gosec-report.sarif ./...
                    
                    echo Running golangci-lint...
                    golangci-lint run ./... --out-format sarif > golangci-lint-report.sarif
                '''
            }
        }

        stage('Dependency Vulnerability Scan - Govulncheck') {
            steps {
                bat '''
                    echo Checking Go module vulnerabilities...
                    govulncheck ./... > govulncheck-report.txt
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    bat '''
                        docker --version
                        docker login -u %DOCKERHUB_USER% -p %DOCKERHUB_PASS%
                        docker build -t %DOCKERHUB_USER%/%IMAGE_NAME%:latest .
                        docker push %DOCKERHUB_USER%/%IMAGE_NAME%:latest
                    '''
                }
            }
        }

        stage('Container Scan - Trivy') {
            steps {
                bat '''
                    echo Running Trivy scan...
                    trivy image --format sarif --output trivy-report.sarif %DOCKERHUB_USER%/%IMAGE_NAME%:latest
                '''
            }
        }

        stage('Upload SARIF Reports') {
            steps {
                archiveArtifacts artifacts: '*.sarif, *.txt', fingerprint: true
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
        always {
            echo 'Publishing SARIF reports...'
            recordIssues enabledForFailure: true, tools: [
                sarif(pattern: '**/*.sarif')
            ]
        }
        failure {
            echo 'Build failed. Rolling back...'
            bat '"C:\\Program Files (x86)\\kubectl-argo-rollouts\\kubectl-argo-rollouts.exe" undo go-demo'
        }
    }
}