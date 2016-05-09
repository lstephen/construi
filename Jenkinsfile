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

stage 'Package'
construi_on_node 'package'


