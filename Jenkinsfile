pipeline {
  agent any
  stages {
    stage('') {
      steps {
        sh 'pip install s1-shift-left-cli'
        sh 's1-cns-cli config --service-user-api-token $S1_SERVICE_USER_API_TOKEN --management-console-url https://$CONSOLE.sentinelone.net --scope-type ACCOUNT --scope-id $S1_SCOPE_ID --tag $TAG'
        sh 's1-cns-cli scan secret -d .'
      }
    }
  }
}
