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

parallel(
  'Python 2.7': {
      stage 'Test Python 2.7'
      construi_on_node 'test_py27'
    },
  'Python 3.4': {
    stage 'Test Python 3.4'
    construi_on_node 'test_py34'
  })



stage 'Analyze'
construi_on_node 'flake8'

stage 'Package'
construi_on_nocde 'package'


