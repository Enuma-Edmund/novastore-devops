pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPOSITORY = '123456789012.dkr.ecr.us-east-2.amazonaws.com/novastore-dev-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Gitleaks Secret Scan') {
            steps {
                sh 'gitleaks git . --redact'
            }
        }

        stage('Test') {
            steps {
                dir('app') {
                    sh 'mvn test'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('app') {
                    withSonarQubeEnv('novastore-sonarqube') {
                        sh '''
                            mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                              -Dsonar.projectKey=NovaStore
                        '''
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Package') {
            steps {
                dir('app') {
                    sh 'mvn clean package'
                }
            }
        }

                stage('Checkov IaC Scan') {
            agent {
                label 'security-agent'
            }
            steps {
                checkout scm

                sh '''
                    checkov -d terraform \
                      --framework terraform \
                      --check CKV_AWS_79,CKV_AWS_8 \
                      --compact
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh 'docker build -t ${ECR_REPOSITORY}:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Trivy Image Scan') {
            agent {
                label 'security-agent'
            }
            steps {
                checkout scm

                dir('app') {
                    sh 'mvn clean package'
                    sh 'docker build -t novastore-security-scan:${BUILD_NUMBER} .'
                }

                sh '''
                    trivy image \
                      --severity CRITICAL \
                      --exit-code 1 \
                      novastore-security-scan:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin \
                    123456789012.dkr.ecr.us-east-2.amazonaws.com

                    docker push ${ECR_REPOSITORY}:${BUILD_NUMBER}
                '''
            }
        }
    }
}
