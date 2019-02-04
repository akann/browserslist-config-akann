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

    stage('master') {
      when { branch 'master'}
      steps {
        sh 'git status'
      }
    }

    stage('feature') {
      when {
        not {
          branch 'master' 
        }
      }

      steps {
        def localVersion = sh(
            script: 'node -pe "require(\'./package.json\').version"',
            returnStdout: true
        ).trim().replace('"', '')

        def remoteVersion = sh(
          script: "npm info browserslist-config-akann@${localVersion} version",
          returnStdout: true
        ).trim().replace('"', '')

        sh 'npm publish --new-version ${localVersion}-${BRANCH_NAME} --dry-run'
      }
    }

    stage('publish') {
      steps {
        sh 'yarn install'
        echo sh(returnStdout: true, script: 'env')
      }
    }
  }
}
