pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            // Maps the Maven cache to speed up subsequent runs
            args '-v $HOME/.m2:/root/.m2'
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
        GIT_URL = 'https://github.com/Poulomi0789/KarateAdvanced.git'
        GIT_BRANCH = 'main'
        EMAIL_RECIPIENTS = 'qa-team@company.com'
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
                sh """
                mvn clean test \
                -Dkarate.env=${params.TEST_ENV} \
                -DforkCount=2 \
                -DreuseForks=true \
                -Dmaven.test.failure.ignore=true
                """
            }
        }

        stage('Generate & Zip Report') {
            steps {
                // 1. Generate the report
                sh 'mvn io.qameta.allure:allure-maven:report'
                
                // 2. Install zip and create the archive (Fixes the previous error)
                sh '''
                apt-get update && apt-get install -y zip
                if [ -d "target/site/allure-maven-plugin" ]; then
                    cd target/site/allure-maven-plugin
                    zip -r ../../../allure-report.zip .
                else
                    echo "Allure report directory not found!"
                    exit 1
                fi
                '''
            }
        }

        stage('Publish to Jenkins') {
            steps {
                // This requires the Allure Jenkins Plugin
                allure includeProperties: false, results: [[path: 'target/allure-results']]
            }
        }
    }

    post {
        always {
            // Archive logs and JUnit results for the Jenkins UI
            archiveArtifacts artifacts: 'target/**/*.log', allowEmptyArchive: true
            junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
        }

        success {
            emailext(
                subject: "✅ Karate Tests Passed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Successful 🚀</h2>
                <b>Environment:</b> ${params.TEST_ENV} <br>
                <b>Allure Report:</b> <a href="${env.BUILD_URL}allure">View Online</a>
                """,
                attachmentsPattern: 'allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        failure {
            emailext(
                subject: "❌ Karate Tests FAILED | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Failed ❌</h2>
                <b>Check Logs:</b> <a href="${env.BUILD_URL}console">Console Output</a>
                """,
                attachmentsPattern: 'allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECI
