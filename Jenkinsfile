pipeline {
  agent {
    dockerfile true
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  environment {
    SLS_DEBUG = "*"
    HOME = "${env.WORKSPACE}"
    BRANCH_NAME = env.GIT_BRANCH.substring(env.GIT_BRANCH.lastIndexOf('/') + 1, env.GIT_BRANCH.length())
  }

  stages {

    stage('build') {
      steps {

          sh "git checkout ${BRANCH_NAME}"
          sh "git remote get-url origin"
          sh "git ls-remote origin"
          sh "git status"
      }
    }

    stage('demo') {
      steps {
        echo sh(returnStdout: true, script: 'env')
      }
    }
  }

  post { 
    cleanup { 
      cleanWs()
    }
  }

}

