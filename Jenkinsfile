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
    stage('npmrc') {
      steps {
        withNPM(npmrcConfig: 'npmrc') { }
      }
    }

    stage('gitsc') {
      steps {
        sh 'git status'
      }
    }

    stage('test') {
      steps {
        sh 'npm publish . --dry-run'
        sh 'yarn install'
        echo sh(returnStdout: true, script: 'env')
      }
    }
  }
}
