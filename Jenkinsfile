pipeline {

    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
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
        GIT_URL = 'https://github.com/your-org/your-karate-repo.git'
        GIT_BRANCH = 'main'
        EMAIL_RECIPIENTS = 'qa-team@company.com'
        MAVEN_OPTS = '-Dmaven.repo.local=/root/.m2/repository'
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

        stage('Verify Tools') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
            }
        }

        stage('Run Karate Tests (Parallel)') {
            steps {
                sh """
                mvn clean test \
                -Dkarate.env=${params.TEST_ENV} \
                -DforkCount=2 \
                -DreuseForks=true \
                -Dparallel=methods \
                -Dmaven.test.failure.ignore=true
                """
            }
        }

        stage('Generate Allure Report') {
            steps {
                sh 'mvn io.qameta.allure:allure-maven:report'
            }
        }

        stage('Publish Allure Report') {
            steps {
                allure includeProperties: false,
                       results: [[path: 'target/allure-results']]
            }
        }

        stage('Zip Allure Report') {
            steps {
                sh '''
                if [ -d "target/site/allure-maven-plugin" ]; then
                    cd target/site
                    zip -r allure-report.zip allure-maven-plugin
                fi
                '''
            }
        }
    }

    post {

        success {
            emailext(
                subject: "✅ Karate Tests Passed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Successful 🚀</h2>

                <b>Environment:</b> ${params.TEST_ENV} <br>
                <b>Project:</b> ${env.JOB_NAME} <br>
                <b>Build Number:</b> ${env.BUILD_NUMBER} <br><br>

                <b>Allure Report:</b><br>
                <a href="${env.BUILD_URL}allure">View Report</a><br><br>

                <b>Console Logs:</b><br>
                <a href="${env.BUILD_URL}console">Open Logs</a>
                """,
                attachmentsPattern: 'target/site/allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        failure {
            emailext(
                subject: "❌ Karate Tests FAILED | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Failed ❌</h2>

                <b>Environment:</b> ${params.TEST_ENV} <br>
                <b>Project:</b> ${env.JOB_NAME} <br>
                <b>Build Number:</b> ${env.BUILD_NUMBER} <br><br>

                <b>Check Console Logs:</b><br>
                <a href="${env.BUILD_URL}console">Open Logs</a>
                """,
                attachmentsPattern: 'target/site/allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        always {
            archiveArtifacts artifacts: 'target/**/*.log', allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
