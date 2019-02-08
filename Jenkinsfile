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

          sh "yarn version --no-git-tag-version --new-version ${remoteVersion}"
          sh 'yarn version:up'

          def localVersion = sh(
             script: 'node -pe "require(\'./package.json\').version"',
             returnStdout: true
          ).trim().replace('"', '')

          def newVersion = localVersion

          if (BRANCH_NAME != 'master') {
             newVersion = "${localVersion}-${BRANCH_NAME.toLowerCase().replaceAll('-', '')}"
          }

          sh "git checkout ${BRANCH_NAME}"
          sh "git remote get-url origin"

          def gitTag = sh(script:"git log --pretty=format:'%h : %an : %ae : %s' -1", returnStdout: true)

          withCredentials([
              usernamePassword(credentialsId: 'GHUSERPWD', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')
            ]) {
              sh "git tag -d -a v${newVersion} -m '${gitTag}'"
              sh "git push --tags ${env.GIT_URL.replace('github', '${GIT_USERNAME}:${GIT_PASSWORD}@github')}"
          }

          sh "yarn version --no-git-tag-version --new-version '${newVersion}'"

          sh "npm publish ./ --dry-run"
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

