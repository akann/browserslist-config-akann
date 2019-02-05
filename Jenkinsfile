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
          sh "git checkout ${BRANCH_NAME}"
          sh 'yarn version:up'

          def localVersion = sh(
             script: 'node -pe "require(\'./package.json\').version"',
             returnStdout: true
           ).trim().replace('"', '')

           if (BRANCH_NAME != 'master') {
             sh 'git diff'

             sh 'git diff'
             sh 'git add package.json'
             sh 'git commit -m "version++" package.json'
             
             sshagent(credentials: ['d76aa6e6-c911-4491-9c38-9712b1a81743']) {
               sh "git push --set-upstream origin HEAD:${BRANCH_NAME}"
             }

             sh "yarn version --no-git-tag-version --new-version \"${localVersion}-${BRANCH_NAME.toLowerCase().replaceAll('-', '')}\""
           }

           echo 'here'

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
}
