// jenkins-shared-library/
// ├── vars/
// │   ├── nodejsPipeline.groovy     # Encapsulates the entire end-to-end pipeline
// │   ├── trivyScan.groovy          # Modular reusable step
// │   └── ecrPush.groovy            # Modular reusable step
// ├── src/
// │   └── com/roboshop/Utils.groovy # Standard Groovy classes (optional helper methods)
// └── resources/                    # Configuration templates, JSON schemas, etc.

def call (){
pipeline {
    agent any

    environment {
        APP_ENV = 'staging'
        BUILD_TAG = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Compiling application for build ${BUILD_TAG}..."
                
            }
        }

        stage('Test') {
            steps {
                echo "Running unit and integration tests..."
                
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${APP_ENV} environment..."
                
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline succeeded! Artifacts ready."
        }
        failure {
            echo "Build failed. Dispatching notification to alerts channel..."
        }
    }
}
}