#!groovy

properties(
  [ [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', daysToKeepStr: '30'] ]
  , [$class: 'GithubProjectProperty', projectUrlStr: 'http://github.com/lstephen/construi']
  ])

def construi(target) {
  wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
    sh "construi ${target}"
  }
}

def construi_on_node(target) {
  node('construi') {
    checkout scm
    construi target
  }
}

stage 'Test'
parallel(
  'Python 2.7': {
    construi_on_node 'test_p27'
  },
  'Python 3.4': {
    construi_on_node 'test_p34'
  })

stage 'Analyze'
construi_on_node 'flake8'


if (env.BRANCH_NAME == 'master') {
  stage 'Release'
  node('construi') {
    checkout scm

    construi 'versiune'
    currentBuild.description = "Release v${readFile('VERSION')}"

    withCredentials(
      [
        [ $class: 'UsernamePasswordMultiBinding'
        , usernameVariable: 'TWINE_USERNAME'
        , passwordVariable: 'TWINE_PASSWORD'
        , credentialsId: '61468eb2-a59e-4291-866d-6d038ce5e418'
        ]
      , [ $class: 'FileBinding'
        , variable: 'GIT_SSH_KEY'
        , credentialsId: 'cfbecb37-737f-4597-86f7-43fb2d3322cc' ]
      ]) {
        construi 'release'
    }
  }

  build job: '../docker-construi/master', wait: false
} else {
  stage 'Package'
  construi_on_node 'package'
}



