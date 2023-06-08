pipeline {
agent any
    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'dev', description: 'Environment to deploy to')
        booleanParam(name: 'ENABLE_TESTS', defaultValue: true, description: 'Enable running tests')
    }
    environment {
        REPO = "https://github.com/mirik12/kbot"
        BRANCH = 'main'
    }
    stages {

        stage ("clone") {
            steps {
            echo 'CLONE REPOSITORY'
                git branch: "${BRANCH}", url: "${REPO}"
            }
       }

        stage ("test") {
            steps {
                sh "make --version"
                echo 'TEST EXECUTION STARTED '
                sh 'make test'
            }
       }

        stage ("build") {
            steps {
                echo 'BUILD EXECUTION STARTED '
                sh 'make build'
            }
       }

        stage ("image") {
            steps {
                script {
                    echo 'TEST EXECUTION STARTED '
                    sh 'make image'
                }
            }
       }

        stage ("push") {
            steps {
                script {
                    docker.withRegistry ( '', 'dockerhub ') {
                    sh 'make push'
                    }
                }
            }
        }
    }
}