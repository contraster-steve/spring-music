pipeline {
  agent any

  // Configure BitBucket and Black Duck server locations
  environment {
    BITBUCKET_URL = 'https://bitbucket.org/steve-work/'
    // This username will be combined with the access token configured in Jenkins
    BITBUCKET_USERNAME = 'saleen.447@gmail.com'
    BLACKDUCK_URL = 'https://poc09.blackduck.synopsys.com'
  }

  tools {
    jdk "JDK17"
  }

when {
  changeRequest() // is an open gerrit code review
  environment name: 'CHANGE_TARGET', value: 'master'
}  
  
  stages {
      
    stage('Download Source') {
        steps{
            script{
                echo "Clean first"
                sh 'rm -rf *'
                echo "Download from source."
                sh 'git clone https://github.com/razermuse/spring-music'
                }
            }
        }           
    stage('Build') {
        steps{
            script{
                dir('./spring-music/') {
                sh './gradlew clean assemble'
                    }
                }
            }
        }   

    // Run a Black Duck Rapid Scan on pull requests and subsequent commits to open pull requests,
    // and push code insights into BitBucket.
    stage('Black Duck Rapid Scan') {
      when {
        expression { return env.CHANGE_TARGET ==~ /(master|stage|release)/ }
      }

      steps {
        script {
          BITBUCKET_PROJECT = scm.getUserRemoteConfigs()[0].getUrl().tokenize('/')[2].split("\\.")[0]
          BITBUCKET_REPO = scm.getUserRemoteConfigs()[0].getUrl().tokenize('/')[3].split("\\.")[0]
          BITBUCKET_REF = env.GIT_COMMIT
          BITBUCKET_BRANCH = env.CHANGE_BRANCH
          BITBUCKET_PULL_NUMBER = env.CHANGE_ID
        }

        withCredentials([string(credentialsId: 'bitbucket-token', variable: 'BITBUCKET_PASSWORD')]) {
          withCredentials([string(credentialsId: 'blackduck-token', variable: 'blackduck-token')]) {
            // NOTE: Change path to blackduck-scan.py
            echo "EXEC: /home/ubuntu/tools/bitbucket/blackduck-bitbucket-integration/blackduck-scan.py --bb-url ${BITBUCKET_URL} --blackduck-url ${URL}"
            sh "/home/ubuntu/tools/bitbucket/blackduck-bitbucket-integration/blackduck-scan.py --bb-url ${BITBUCKET_URL} --blackduck-url ${URL}"
          }
        }
      }
    }

    // Run a Black Duck Intelligent Scan on pushes to main branch
    stage('Black Duck Intelligent Scan') {
      when {
        expression { return !CHANGE_TARGET }
      }
      steps {
        script {
          BITBUCKET_PROJECT = scm.getUserRemoteConfigs()[0].getUrl().tokenize('/')[2].split("\\.")[0]
          BITBUCKET_REPO = scm.getUserRemoteConfigs()[0].getUrl().tokenize('/')[3].split("\\.")[0]
          BITBUCKET_REF = env.GIT_COMMIT
          BITBUCKET_BRANCH = env.CHANGE_BRANCH
          BITBUCKET_PULL_NUMBER = env.CHANGE_ID
        }

        withCredentials([string(credentialsId: 'bitbucket-token', variable: 'BITBUCKET_PASSWORD')]) {
          withCredentials([string(credentialsId: 'blackduck-token', variable: 'blackduck-token')]) {
            // NOTE: Change path to blackduck-scan.py
            echo "EXEC: /home/ubuntu/tools/bitbucket/blackduck-bitbucket-integration/blackduck-scan.py --bb-url ${BITBUCKET_URL} --blackduck-url ${URL}"
            sh "/home/ubuntu/tools/bitbucket/blackduck-bitbucket-integration/blackduck-scan.py --bb-url ${BITBUCKET_URL} --blackduck-url ${URL}"
          }
        }
      }
    }
  }
}
