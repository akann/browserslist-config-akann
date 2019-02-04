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
          def localVersion = sh(
             script: 'node -pe "require(\'./package.json\').version"',
             returnStdout: true
           ).trim().replace('"', '')

           if (BRANCH_NAME != 'master') {
               git url: env.GIT_URL,
                  credentialsId: '5643a13a-8eb7-45d6-a68d-2718a89d189f',
                  branch: BRANCH_NAME
 
               sh 'yarn version:up'
               sh 'git diff package.json'
               sh 'git add package.json'
               sh 'git commit -m "version++" package.json'
               sh "git push origin ${BRANCH_NAME}"

             sh "yarn version --no-git-tag-version --new-version \"${localVersion}-${BRANCH_NAME.toLowerCase().replaceAll('-', '')}\""
             sh 'git diff package.json'
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
}
