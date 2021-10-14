pipeline {
    agent none
    options {
        disableConcurrentBuilds()
    }
    stages {
        stage('Terraform deploy us-east-1') {
            agent { 
                label 'AG-USE1'
            }
            environment {
                AWS_DEFAULT_REGION="us-east-1"
            }
            steps {
                dir('src') {
                    sh "terraform init && terraform plan"
                }
            }
            post {
                success {
                    dir('src') {
                        sh 'terraform apply -auto-approve && python3 ssm_autoupdater.py --autoscaling-group-name "$(terraform output asg)"'
                    }
                }
            }
        }
        stage('Terraform deploy us-west-2') {
            agent { 
                label 'AG-USW2'
            }
            environment {
                AWS_DEFAULT_REGION="us-west-2"
            }
            steps {
                dir('src') {
                    sh "terraform init && terraform plan"
                }
            }
            post {
                success {
                    dir('src') {
                        sh 'terraform apply -auto-approve && python3 ssm_autoupdater.py --autoscaling-group-name "$(terraform output asg)"'
                    }
                }
            }
        }
        stage('Terraform deploy eu-west-1') {
            agent { 
                label 'AG-EUW1'
            }
            environment {
                AWS_DEFAULT_REGION="eu-west-1"
            }
            steps {
                dir('src') {
                    sh "terraform init && terraform plan"
                }
            }
            post {
                success {
                    dir('src') {
                        sh 'terraform apply -auto-approve && python3 ssm_autoupdater.py --autoscaling-group-name "$(terraform output asg)"'
                    }
                }
            }
        }
    }    
}
