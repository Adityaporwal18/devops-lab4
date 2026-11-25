pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Secure Secret Management') {
            steps {
                withCredentials([string(credentialsId: 'lab4-api-key', variable: 'API_KEY')]) {
                    sh '''
                        test -n "$API_KEY"
                        echo "API credential loaded from the Jenkins credential store"
                        echo "Length of the secret: ${#API_KEY} characters"
                        echo "Printing the secret on purpose to show masking: $API_KEY"
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv .jenkins-venv
                    .jenkins-venv/bin/python -m pip install -q -r requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '.jenkins-venv/bin/python -m pytest -v tests/test_unit.py'
            }
        }

        stage('Integration Tests') {
            steps {
                sh '.jenkins-venv/bin/python -m pytest -v tests/test_integration.py'
            }
        }

        stage('Deployment Gate') {
            steps {
                echo 'All tests passed. Deployment approved.'
            }
        }
    }

    post {
        success {
            echo 'Lab 4 CI/CD pipeline SUCCESS'
        }
        failure {
            echo 'Tests failed. Deployment BLOCKED.'
        }
    }
}
