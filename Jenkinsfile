pipeline {
  agent any

  tools {
    jdk 'jdk17'
    nodejs 'node18'
  }

  environment {
    SCANNER_HOME = tool 'sonar-scanner'
    REPO = 'devopscode44/starbucks'
    IMAGE_TAG = 'latest'
  }

  stages {

    stage('Clean Workspace') {
      steps {
        cleanWs()
      }
    }

    stage('Git Checkout') {
      steps {
        git branch: 'main', 
            url: 'git@github.com:Prasadrasal2002/Securely-Deploying-a-Starbucks-Clone-Using-DevSecOps-on-AWS.git', 
            credentialsId: 'github-ssh'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonar-server') {
          sh '''
            $SCANNER_HOME/bin/sonar-scanner \
              -Dsonar.projectName=starbucks-ci \
              -Dsonar.projectKey=starbucks-ci \
              -Dsonar.sources=.
          '''
        }
      }
    }

    stage('Code Quality Gate') {
      steps {
        script {
          waitForQualityGate abortPipeline: true, credentialsId: 'Sonar-token'
        }
      }
    }

    stage('Install NPM Dependencies') {
      steps {
        sh '''
          npm install
          # Optional: auto-fix vulnerabilities
          # npm audit fix || true
        '''
      }
    }

    stage('OWASP Dependency Check') {
      steps {
        withCredentials([string(credentialsId: 'nvd-api-key-id', variable: 'NVD_API_KEY')]) {
          dependencyCheck additionalArguments: "--format XML --project starbucks-ci --nvdApiKey ${env.NVD_API_KEY}", odcInstallation: 'DP-Check'
          dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        }
      }
    }

    stage('Trivy Vulnerability Scan') {
      steps {
        sh '''
          trivy fs . > trivy-fs-report.txt || true
          # Optional: Docker image scan
          # trivy image $REPO:$IMAGE_TAG > trivy-image-report.txt || true
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          echo "Building Docker image..."
          docker build -t $REPO:$IMAGE_TAG .
        '''
      }
    }

    stage('Docker Scout Scan') {
      steps {
        script {
          withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
            sh '''
              docker scout quickview $REPO:$IMAGE_TAG || true
              docker scout cves $REPO:$IMAGE_TAG || true
              docker scout recommendations $REPO:$IMAGE_TAG || true
            '''
          }
        }
      }
    }

    stage('Deploy to Docker Container') {
      steps {
        sh '''
          echo "Deploying container..."
          docker stop starbucks || true
          docker rm starbucks || true
          docker run -d --name starbucks -p 3000:80 $REPO:$IMAGE_TAG
        '''
      }
    }

    // New stage to push the Docker image to Docker Hub
    stage('Push Docker Image') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh '''
              echo "Pushing Docker image to Docker Hub..."
              docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
              docker push $REPO:$IMAGE_TAG
            '''
          }
        }
      }
    }
  }

  post {
    always {
      echo 'CI Pipeline execution completed.'
    }
    success {
      echo 'CI passed. Code is clean and image is built successfully.'
    }
    failure {
      echo 'CI pipeline failed. Please check logs and fix issues.'
    }
  }
}
