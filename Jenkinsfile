pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            // Using a relative path for the repo is often safer in Jenkins
            args '-v .m2:/root/.m2' 
        }
    }

    parameters {
        choice(
            name: 'TEST_ENV',
            choices: ['qa', 'stage', 'prod'],
            description: 'Select environment to run Karate tests'
        )
    }

    environment {
        GIT_URL = 'https://github.com/your-org/your-karate-repo.git'
        GIT_BRANCH = 'main'
        EMAIL_RECIPIENTS = 'poulomidas89@gmail.com'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_URL}"
            }
        }

        stage('Run Karate Tests') {
            steps {
                // Combined Maven Opts into the command for clarity
                sh """
                mvn clean test \
                -Dkarate.env=${params.TEST_ENV} \
                -DforkCount=2 \
                -DreuseForks=true \
                -Dmaven.test.failure.ignore=true
                """
            }
        }

        stage('Generate Allure Report') {
            steps {
                sh 'mvn io.qameta.allure:allure-maven:report'
            }
        }

        stage('Publish & Archive') {
            steps {
                // Publish to Jenkins UI
                allure includeProperties: false, results: [[path: 'target/allure-results']]
                
                // Native Jenkins zip step (doesn't need 'zip' installed in Docker)
                zip archive: true, 
                    dir: 'target/site/allure-maven-plugin', 
                    zipFile: 'allure-report.zip'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/**/*.log', allowEmptyArchive: true
            // Karate/Surefire reports
            junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
        }
        success {
            emailext(
                subject: "✅ Karate Tests Passed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Check report here: ${env.BUILD_URL}allure",
                attachmentsPattern: 'allure-report.zip',
                to: "${EMAIL_RECIPIENTS}"
            )
        }
        failure {
            emailext(
                subject: "❌ Karate Tests FAILED | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed. View logs: ${env.BUILD_URL}console",
                to: "${EMAIL_RECIPIENTS}"
            )
        }
    }
}
