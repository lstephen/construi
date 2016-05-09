#!groovy

properties(
  [ [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', daysToKeepStr: '30'] ]
  , [$class: 'GithubProjectProperty', projectUrlStr: 'http://github.com/lstephen/docker-jenkins']
  ])

def construi(target) {
  wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
    sh "construi ${target}"
  }
}

stage 'Test'
node('construi') {
  checkout scm
  construi 'test'
}

stage 'Analyze'
node ('construi') {
  checkout scm
  construi 'flake8'
}

stage 'Package'
node ('construi') {
  checkout scm
  construi 'package'
}


