pipeline {
    agent any

    stages {

        stage('Run Tests') {
            steps {
                sh 'mvn clean verify'
            }
        }

        stage('Copy History') {
            steps {
                script {
                    def historyPath = "target/allure-results/history"

                    if (fileExists("allure-report/history")) {
                        sh "cp -r allure-report/history ${historyPath}"
                    }
                }
            }
        }

        stage('Generate Allure Report') {
            steps {
                allure([
                    results: [[path: 'target/allure-results']]
                ])
            }
        }
    }
}
