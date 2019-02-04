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
        git branch: 'demo', credentialsId: '5643a13a-8eb7-45d6-a68d-2718a89d189f', url: 'git@github.com:akann/browserslist-config-akann.git'
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
