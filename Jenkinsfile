pipeline {
    agent any

    environment {
        APP_NAME         = 'cicd-jenkins-app'
        IMAGE_NAME       = 'cicd-jenkins-app'
        IMAGE_TAG        = "v${BUILD_NUMBER}"
        CONTAINER_NAME   = 'cicd-jenkins-container'
        HOST_PORT        = '3000'
        GIT_CREDENTIALS  = 'github-pat-credentials'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo "========================================================="
                echo " Stage 1: Checking out source code using GitHub PAT"
                echo "========================================================="
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD || echo 'local'",
                        returnStdout: true
                    ).trim()
                }
                echo "Checkout completed at commit: ${env.GIT_COMMIT_SHORT}"
            }
        }

        stage('Code Quality & Tests') {
            steps {
                echo "========================================================="
                echo " Stage 2: Running Unit & Integration Tests"
                echo "========================================================="
                sh '''
                    echo "Checking Node.js environment..."
                    node -v || true
                    npm -v || true
                    
                    if [ -f "package.json" ]; then
                        npm install --silent
                        npm test
                    else
                        echo "No package.json found, skipping npm test."
                    fi
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo "========================================================="
                echo " Stage 3: Building Docker Image (${IMAGE_NAME}:${IMAGE_TAG})"
                echo "========================================================="
                sh """
                    chmod +x scripts/build.sh
                    ./scripts/build.sh "${IMAGE_NAME}" "${IMAGE_TAG}"
                """
            }
        }

        stage('Docker Deploy') {
            steps {
                echo "========================================================="
                echo " Stage 4: Deploying Docker Container (${CONTAINER_NAME})"
                echo "========================================================="
                sh """
                    chmod +x scripts/deploy.sh
                    ./scripts/deploy.sh "${IMAGE_NAME}" "${IMAGE_TAG}" "${CONTAINER_NAME}" "${HOST_PORT}"
                """
            }
        }

        stage('Smoke Test & Health Verification') {
            steps {
                echo "========================================================="
                echo " Stage 5: Verifying Application Health and Endpoints"
                echo "========================================================="
                sh """
                    echo "Pinging health endpoint at http://localhost:${HOST_PORT}/health..."
                    curl -s -f http://localhost:${HOST_PORT}/health | grep '"status":"UP"' || (echo "Health check failed!" && exit 1)
                    echo "Pinging info endpoint at http://localhost:${HOST_PORT}/api/info..."
                    curl -s -f http://localhost:${HOST_PORT}/api/info
                    echo ""
                    echo "✔ Deployment verification complete!"
                """
            }
        }
    }

    post {
        always {
            echo "========================================================="
            echo " Post-Build: Cleaning up dangling resources"
            echo "========================================================="
            sh '''
                chmod +x scripts/cleanup.sh || true
                ./scripts/cleanup.sh || true
            '''
        }
        success {
            echo "========================================================="
            echo " 🎉 CI/CD Pipeline Succeeded! Application is live on port ${HOST_PORT}"
            echo " Build Tag: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "========================================================="
        }
        failure {
            echo "========================================================="
            echo " ❌ CI/CD Pipeline Failed! Inspecting container logs..."
            echo "========================================================="
            sh """
                docker logs "${CONTAINER_NAME}" --tail 50 || true
            """
        }
    }
}
