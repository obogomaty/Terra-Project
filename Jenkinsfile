pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'githublogin', url: 'https://github.com/obogomaty/terra-project']]])      

          }
        }

        stage ("terraform init") {
            steps {
                sh ('terraform init') 
            }
        }

        stage ("terraform Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('terraform ${action} --auto-approve') 
           }
        }
    }
}
