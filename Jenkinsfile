#!/usr/bin/env groovy

// Import some library 
import groovy.json.JsonOutput
import groovy.json.JsonSlurper 

// Beautify display
def seperator60 = '\u2739' * 60
def seperator20 = '\u2739' * 20


node('misc') {
      echo "${seperator60}\n${seperator20} Inbuilt tools \n${seperator60}"
      ansiColor('xterm') {
          // Just some echoes to show the ANSI color.
          stage "CheckOut"
          checkout scm 
          sh "hostname -f"
          sh "pwd"
          sh "ls -lart ."
      }
    
      deploy_aws() 
      deploy_app()

      echo "${seperator60}\n${seperator20} Makefile Introduced \n${seperator60}"
      stage('Intro to Makefile'){
        try {
          sh "make test-build"
          sh "make calc-compile" 
        }
        catch (exc) {
            echo "Something failed with makefile"
        }
        check_tools_ver()
      }
}

// CUSTOM DSL METHODS 
def deploy_aws() {
    stage('AWS Creds'){
      withCredentials([usernamePassword(credentialsId: 'cicd-skeleton', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID' )]){
        sh """
           terraform init
           terraform plan -out=create.tfplan
           terraform apply create.tfplan
        """
      }
    }
}

def deploy_app(){
    stage('AppVersion Update'){
        sh "./deploy_app.sh"
    }
    
    stage ('Check EB'){
        try {
          timeout(time: 900, unit: 'MINUTES') {
            input message: 'Proceed to next stage?'
          }
        }
        catch (err) {
            echo "Aborted by user!"
            currentBuild.result = 'ABORTED'
            error('Job Aborted')
        }
    }

    stage ('Destroy instance'){
      withCredentials([usernamePassword(credentialsId: 'cicd-skeleton', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]){
        sh """
           terraform destroy -force
        """
      }
    }
}


def check_tools_ver() {
    stage('Checking Tools version'){
        sh "aws --version"
        sh "terraform --version"
        sh "ansible --version"
    }
}


def check_branch() {
      stage('DSL syntax'){
        if (env.BRANCH_NAME == 'develop'){
            echo "I am develop branch"
        } else {
            echo "Xren znaet kto vui: I am not develop " //TODO
        }
      }
}

