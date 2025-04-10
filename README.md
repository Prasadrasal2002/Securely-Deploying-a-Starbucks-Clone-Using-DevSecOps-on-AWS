# Securely-Deploying-a-Starbucks-Clone-Using-DevSecOps-on-AWS

**Initial Setup and Deployment:**

Launch an Instance (Ubuntu, 24.04, t2.large, 25 GB)
Connect to the instance (Add port : 22 (inbound rule))

**Update the packages**

```bash
sudo su
sudo apt update -y
```

**Install Docker:**


```bash
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER  # Replace with your system's username, e.g., 'ubuntu'
newgrp docker
sudo chmod 777 /var/run/docker.sock
```

**Install Jenkins for Automation:**
- Install Jenkins on the EC2 instance to automate deployment:

**Install Java:**
    
```bash
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)
```

**Install jenkins:**

```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

```bash
jenkins --version
```

**Access Jenkins:**

- Add port : 8080 (inbound rule)
- In a web browser using the public IP of your EC2 instance.
publicIp:8080

**Install SonarQube and Trivy**
- Install SonarQube and Trivy on the EC2 instance to scan for vulnerabilities.
  
```bash
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

```bash
sonar-scanner --version
```
              
**To access:**
Add port : 9000 (inbound rule)
publicIP:9000 (by default username & password is admin)

**Integrate SonarQube and Configure:**
**1)** Create Project:
Steps:

```bash
Go to sonarqube dashboard--->click on project:--->create--->add project name & project key (remember this values to used in jenkins pipeline)
```

**2)** Create Webhook:

Steps:

```bash
Go to sonarqube dashboard--->click on Configuration--->Create---(add name = jenkins)---->{ url = http://<pub-ip/elastic-ip>:8080/sonarqube-webhook/ }---Save
```

**3)** add Sonarqube Url on jenkins:

steps:

```bash
Go to sonarqube dashboard--->click on Manage Jenkins--->system--->Name = sonar-server (remember this values to used in jenkins pipeline)--->server Url = http://http://<pub-ip/elastic-ip>:9000
 ```

**To install Trivy:**

```bash
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy        
```

**Verifiy Trivy installation:**

```bash
trivy --version
```


**Install Yarn:**

```bash
npm install -g yarn
```

**Download Docker Scout:**

(make sure to login to DockerHub account in browser)
Go inside server on mobaxterm--->Login to dockerHub--->docker login -u <DockerHub-username>--->click enter--->password of dockerhub--->lets install Docker Scout)

```bash
curl -sSfL https://github.com/docker/scout-cli/releases/download/v1.17.0/docker-scout_1.17.0_linux_amd64.tar.gz -o ~/.docker/cli-plugins/docker-scout.tar.gz
```

**Extract the tar file:**

```bash
tar -xvzf ~/.docker/cli-plugins/docker-scout.tar.gz -C ~/.docker/cli-plugins
```

**Make the file executable:**

```bash
chmod +x ~/.docker/cli-plugins/docker-scout
```

**Verify the installation:**

```bash
docker scout version
```

**install plugins on Jenkins dashboard:**

Steps:

```bash
Go to "Dashboard" in your Jenkins web interface--->Navigate to "Manage Jenkins"--->"Manage Plugins."--->Click on the "Available" tab and search below listest plugins (depend on projects requirements)
```
**plugins:**

```bash

1) Eclipse Temurin Installer (Install without restart)-------#jdk17.0.8.1
2) SonarQube Scanner (Install without restart)---#6.2.1.46109
3) NodeJs Plugin (Install Without restart)
4) OWASP Dependency-Check.
5) Docker, docker commons,docker pipeline, docker API, Docker-Build step

Click on the "Install without restart" button to install these plugins.
```

**Configure Tools:**

After installing  plugin, you need to configure the tool.

**Steps:**

```bash
Go to "Dashboard"--->"Manage Jenkins"--->"Global Tool Configuration."--->Find the section for tools--->Add the tool's name, e.g., "DP-Check."--->Save your settings.
```

**Tools:**
{ remember this tools name to used in jenkins pipeline }
```bash
()
nodejs(18)
Install jdk(17)
sonar-scanner
Dp-Check
docker
```

**Credentials:**
To securely handle credentials in Jenkins pipeline:

**DockerHub credentials:**

```bash
(Username = docker-hub-username and Password = password-dockerhub) and give the credentials an ID (e.g., "docker")
```

**sonarqube credentials:**

```bash
Go to sonar qube dashboard ---Administration---security---user---click token---generate----then copy---Add credential on Jenkins------select "secret-text" and add this token
```









  

