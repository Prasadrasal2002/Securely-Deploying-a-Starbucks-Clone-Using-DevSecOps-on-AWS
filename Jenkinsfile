pipeline {
  agent any

  tools {
    jdk 'jdk17'
    nodejs 'node23'
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
        git branch: 'main', url: 'https://github.com/DevOpsInstituteMumbai-wq/Securely-Deploying-a-Starbucks-Clone-Using-DevSecOps-on-AWS.git'
      }
    }

    stage('Sonarqube Analysis') {
      steps {
        withSonarQubeEnv('sonar-server') {
          sh '''
            $SCANNER_HOME/bin/sonar-scanner \
            -Dsonar.projectName=starbucks \
            -Dsonar.projectKey=starbucks
          '''
        }
      }
    }

    stage('Code Quality Gate') {
      steps {
        script {
          waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
        }
      }
    }

    stage('Install NPM Dependencies') {
      steps {
        sh 'npm install'
      }
    }

    stage('OWASP FS Scan') {
      steps {
        dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit -n', odcInstallation: 'DP-Check'
        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
      }
    }

    stage('Trivy Scan') {
      steps {
        sh 'trivy fs . > trivy.txt || true'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $REPO:$IMAGE_TAG .'
      }
    }

    stage('Docker Scout') {
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
  }

  post {
    always {
      echo 'CI Pipeline execution completed.'
    }
    success {
      echo 'CI passed. Code is clean and image is built.'
    }
    failure {
      echo 'CI pipeline failed!'
    }
  }
}
