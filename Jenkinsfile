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
        withNPM(npmrcConfig: 'npmrc') { 
        }
      }
    }

    stage('build') {
      steps {
        sh 'yarn install'
      }
    }

    stage('test') {
      steps {
        sh 'yarn test'
      }
    }

    stage('publish') {
      when {
        branch 'master'
      }
      steps {
        script {
          def remoteVersion = sh(script: "npm info browserslist-config-akann version", returnStdout: true).trim()
          sh "npm version --no-git-tag-version --new-version ${remoteVersion}"
          sh 'npm --no-git-tag-version version patch'
          sh "npm publish ./"
        }
      }
    }
  }

  post { 
    cleanup { 
      cleanWs()
    }
  }

}

