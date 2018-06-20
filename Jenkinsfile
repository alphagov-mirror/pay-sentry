#!/usr/bin/env groovy

pipeline {
  agent any

  options {
    ansiColor('xterm')
    timestamps()
  }

  libraries {
    lib("pay-jenkins-library@master")
  }

  stages {
    stage('Docker Build') {
      steps {
        script {
          buildAppWithMetrics{
            app = "sentry"
          }
        }
      }
      post {
        failure {
          postMetric("sentry.docker-build.failure", 1)
        }
      }
    }
    stage('Docker Tag') {
      steps {
        script {
          dockerTagWithMetrics {
            app = "sentry"
          }
        }
      }
      post {
        failure {
          postMetric("sentry.docker-tag.failure", 1)
        }
      }
    }
    stage('Deploy') {
      when {
        branch 'master'
      }
      steps {
        deployEcs("sentry")
      }
    }
    stage('Complete') {
      failFast true
      parallel {
        stage('Tag Build') {
          when {
            branch 'master'
          }
          steps {
            tagDeployment("sentry")
          }
        }
        stage('Trigger Deploy Notification') {
          when {
            branch 'master'
          }
          steps {
            triggerGraphiteDeployEvent("sentry")
          }
        }
      }
    }
  }
  post {
    failure {
      postMetric(appendBranchSuffix("sentry") + ".failure", 1)
    }
    success {
      postSuccessfulMetrics(appendBranchSuffix("sentry"))
    }
  }
}
