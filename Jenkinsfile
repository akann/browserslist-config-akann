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
      steps {
        script {
          def remoteVersion = sh(
            script: "npm info browserslist-config-akann version",
            returnStdout: true
          ).trim().replace('"', '')

          sh "git checkout ${BRANCH_NAME}"
          sh "git remote get-url origin"
          sh "git ls-remote origin"
          sh "git status"

          sh "yarn version --no-git-tag-version --new-version ${remoteVersion}"
          sh 'yarn version:up'

          def localVersion = sh(
             script: 'node -pe "require(\'./package.json\').version"',
             returnStdout: true
          ).trim().replace('"', '')

          if (BRANCH_NAME != 'master') {
             sh "yarn version --no-git-tag-version --new-version \"${localVersion}-${BRANCH_NAME.toLowerCase().replaceAll('-', '')}\""
          }

          sh "npm publish ./ --dry-run"
        }
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

