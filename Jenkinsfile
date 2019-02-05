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
             sh 'git commit -m "version++"'
             
             def msg = sh(script: "git log --pretty=format:'%h : %an : %ae : %s' -1", returnStdout: true)
             sh "git tag -a v${localVersion} -m '${msg}'"
             sh "yarn version --no-git-tag-version --new-version \"${localVersion}-${BRANCH_NAME.toLowerCase().replaceAll('-', '')}\""
           }

           echo 'herex'

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
    publishers {
        git {
            pushOnlyIfSuccess()
            tag('origin', 'foo-PIPELINE_VERSION') {
                message('Release PIPELINE_VERSION')
                create()
            }
        }
    }


