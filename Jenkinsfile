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
            url: 'https://github.com/Prasadrasal2002/Securely-Deploying-a-Starbucks-Clone-Using-DevSecOps-on-AWS.git',
            credentialsId: 'github-ssh'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonar-server') {
          sh '''
            echo "Running SonarQube analysis..."
            $SCANNER_HOME/bin/sonar-scanner \
              -Dsonar.projectName=starbucks-sonar \
              -Dsonar.projectKey=starbucks-sonar \
              -Dsonar.sources=.
          '''
        }
      }
    }

    stage('Code Quality Gate') {
      steps {
        script {
          echo "Waiting for SonarQube Quality Gate result..."
          waitForQualityGate abortPipeline: true, credentialsId: 'Sonar-token'
        }
      }
    }

    stage('Install NPM Dependencies') {
      steps {
        sh '''
          echo "Installing NPM dependencies..."
          npm install
        '''
      }
    }

    stage('OWASP Dependency Check') {
      steps {
        withCredentials([string(credentialsId: 'nvd-api-key-id', variable: 'NVD_API_KEY')]) {
          echo "Running OWASP Dependency Check..."
          dependencyCheck additionalArguments: "--format XML --project starbucks-ci --nvdApiKey ${env.NVD_API_KEY}", odcInstallation: 'DP-Check'
          dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        }
      }
    }

    stage('Trivy Vulnerability Scan') {
      steps {
        sh '''
          echo "Running Trivy filesystem scan..."
          trivy fs . > trivy-fs-report.txt || true
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
          withDockerRegistry(credentialsId: 'docker') {
            sh '''
              echo "Running Docker Scout analysis..."
              docker scout quickview $REPO:$IMAGE_TAG || true
              docker scout cves $REPO:$IMAGE_TAG || true
              docker scout recommendations $REPO:$IMAGE_TAG || true
            '''
          }
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh '''
              echo "Pushing Docker image to Docker Hub..."
              echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
              docker push $REPO:$IMAGE_TAG
            '''
          }
        }
      }
    }

    stage('Deploy to Docker Container') {
      steps {
        sh '''
          echo "Deploying container locally..."
          docker stop starbucks || true
          docker rm starbucks || true
          docker run -d --name starbucks -p 3000:80 $REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Set up Kubeconfig') {
      steps {
        withCredentials([
          string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            echo "Setting up kubeconfig for EKS..."
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            aws eks --region ap-south-1 update-kubeconfig --name prasad-eks-BFwiEALc
          '''
        }
      }
    }

    stage('Deploy to EKS with Helm') {
      steps {
        withCredentials([
          string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            echo "Deploying to EKS with Helm..."
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            helm upgrade --install starbucks ./starbucks-chart --namespace default --set image.tag=latest
          '''
        }
      }
    }
  }

  post {
    always {
      echo 'CI/CD Pipeline execution completed.'
    }
    success {
      echo '✅ CI/CD passed. Code is clean, image built, and deployed successfully.'
    }
    failure {
      echo '❌ CI/CD pipeline failed. Please check logs and fix the issues.'
    }
  }
}
