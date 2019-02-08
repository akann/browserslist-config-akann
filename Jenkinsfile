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
      steps {
        script {
          def remoteVersion = sh(script: "npm info browserslist-config-akann version", returnStdout: true).trim()

          sh "npm version --no-git-tag-version --allow-same-version --new-version ${remoteVersion}"
          if (BRANCH_NAME == 'master') {
            sh 'npm --no-git-tag-version version patch'
          }

          def localVersion = sh( script: 'node -pe "require(\'./package.json\').version"', returnStdout: true).trim()

          def newVersion = localVersion

          if (BRANCH_NAME != 'master') {
             newVersion = "${localVersion}-${BRANCH_NAME.toLowerCase().replaceAll('[^A-Za-z0-9]', '')}.${BUILD_NUMBER}"
          }

          sh "git checkout ${BRANCH_NAME}"
          def gitTag = sh(script:"git log --pretty=format:'%h : %an : %ae : %s' -1", returnStdout: true)

          withCredentials([
              usernamePassword(credentialsId: 'GHUSERPWD', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')
            ]) {
              sh "git tag -f -a v${newVersion} -m '${gitTag}'"
              sh "git push -f --tags ${env.GIT_URL.replace('github', '${GIT_USERNAME}:${GIT_PASSWORD}@github')}"
          }

          sh "npm version --no-git-tag-version --allow-same-version --new-version '${newVersion}'"

          if (BRANCH_NAME == 'master') {
            sh "npm publish ./"
          } else {
            sh "npm publish ./ --tag beta"
          }
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

