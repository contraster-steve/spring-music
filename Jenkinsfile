pipeline {
  agent any
  environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
	    }
  tools {
        jdk "JDK 17"
    }
    stages {
      stage('1: Download') {
        steps{
            script{
                echo "Clean first"
                sh 'rm -rf *'
                echo "Download from source."
                sh 'git clone https://github.com/contraster-steve/spring-music'
                }
            }
        }
      stage('2: Contrast') {
        steps{
            withCredentials([string(credentialsId: 'AUTH_HEADER', variable: 'auth_header'), string(credentialsId: 'API_KEY', variable: 'api_key'), string(credentialsId: 'SERVICE_KEY', variable: 'service_key'), string(credentialsId: 'USER_NAME', variable: 'user_name')]) {
                script{
                    echo "Build YAML file."
                    sh 'echo "api:\n  url: https://apptwo.contrastsecurity.com/Contrast\n  api_key: ${api_key}\n  service_key: ${service_key}\n  user_name: ${user_name}\nagent:\n  java:\n    standalone_app_name: SpringMusic\napplication:\n  session_metadata: "buildNumber=${BUILD_NUMBER}, committer=Steve Smith"\n  version: ${JOB_NAME}-${BUILD_NUMBER}" >> ./spring-music/contrast_security.yaml'
                    sh 'chmod 755 ./spring-music/contrast_security.yaml'
                    echo "Download Agent"
                    sh 'curl -o ./spring-music/contrast.jar https://repo1.maven.org/maven2/com/contrastsecurity/contrast-agent/4.3.0/contrast-agent-4.3.0.jar'
                }
            }
        }
      }            
      stage('3: Build Images') {
        steps{
            script{
                echo "Build Spring Music."
                dir('./spring-music/') {
                sh './gradlew clean assemble'
                sh 'docker-compose build'
                    }
                }
            }
        }        
      stage('4: Deploy') {
        steps{
            script{
            echo "Run Dev here."
            dir('./spring-music/') {
                sh 'docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d'
                    }
            echo "Deploy and run on QA server."
            sh 'sudo scp -i /home/ubuntu/steve.pem -r spring-music/* ubuntu@syn.contrast.pw:/home/ubuntu/webapps/spring-music/'
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@syn.contrast.pw sudo docker-compose -f /home/ubuntu/webapps/spring-music/docker-compose.yml -f /home/ubuntu/webapps/spring-music/docker-compose.qa.yml up -d' 
            echo "Deploy and run on Prod server."
            sh 'sudo scp -i /home/ubuntu/steve.pem -r spring-music/* ubuntu@ack.contrast.pw:/home/ubuntu/webapps/spring-music'
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@ack.contrast.pw sudo docker-compose -f /home/ubuntu/webapps/spring-music/docker-compose.yml -f /home/ubuntu/webapps/spring-music/docker-compose.prod.yml up -d' 
                }
            }
        }
      stage('5: Dependency Tree') {
        steps{
            withCredentials([string(credentialsId: 'AUTH_HEADER', variable: 'auth_header'), string(credentialsId: 'API_KEY', variable: 'api_key'), string(credentialsId: 'SERVICE_KEY', variable: 'service_key'), string(credentialsId: 'USER_NAME', variable: 'user_name')]) {
                script{
                    echo "Generate Tree."
                    dir('./spring-music/') {
                        sh '/usr/local/bin/contrast-cli --api_key ${api_key} --authorization ${auth_header} --organization_id f7602ec5-41d9-4e32-87d1-71b8ebd183c9 --host https://apptwo.contrastsecurity.com --language JAVA --application_id 441bfc82-3fb0-4e8d-8288-1e80f26e4ec3 '
                    }
                }
            }
        }
      }
      stage('6: Contrast Scan') {
        steps{
            withCredentials([string(credentialsId: 'AUTH_HEADER', variable: 'auth_header'), string(credentialsId: 'API_KEY', variable: 'api_key'), string(credentialsId: 'SERVICE_KEY', variable: 'service_key'), string(credentialsId: 'USER_NAME', variable: 'user_name')]) {
                script{
                    echo "Generate Scan."
                    dir('./spring-music/') {
                        sh '/usr/local/bin/contrast-cli --api_key ${api_key} --authorization ${auth_header} --organization_id f7602ec5-41d9-4e32-87d1-71b8ebd183c9 --host https://apptwo.contrastsecurity.com --language JAVA --application_id 441bfc82-3fb0-4e8d-8288-1e80f26e4ec3 --tags ${BUILD_NUMBER},test --metadata bU:PS,committer:steve.smith@contrastsecurity.com --scan ./build/libs/spring-music-1.0.jar --project_name "Spring Music" --save_scan_results --wait_for_scan --report'
                    }
                }
            }
        }
      }      
    }
}    
