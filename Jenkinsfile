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

          sh "npm version --no-git-tag-version --allow-same-version --new-version ${remoteVersion}"
          sh 'npm --no-git-tag-version version patch'

          withCredentials([
              usernamePassword(credentialsId: 'GHUSERPWD', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')
            ]) {
              def newVersion = sh( script: 'node -pe "require(\'./package.json\').version"', returnStdout: true).trim()

              sh "git checkout ${BRANCH_NAME}"
              def gitTag = sh(script:"git log --pretty=format:'%h : %an : %ae : %s' -1", returnStdout: true)

              sh "git tag -f -a v${newVersion} -m '${gitTag}'"
              sh "git push -f --tags ${env.GIT_URL.replace('github', '${GIT_USERNAME}:${GIT_PASSWORD}@github')}"
          }

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

