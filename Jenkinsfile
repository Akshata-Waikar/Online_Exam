pipeline {
    agent any

    stages {

        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }

        stage('Clone Code from GitHub') {
            steps {
                script {
                    echo 'Cloning repository...'
                    withCredentials([usernamePassword(
                        credentialsId: 'git-creds',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_TOKEN'
                    )]) {
                        bat """
                        if exist project rmdir /s /q project
                        git clone https://%GIT_USER%:%GIT_TOKEN%@github.com/Akshata-Waikar/Online_Exam.git project
                        """
                    }
                }
            }
        }

        stage('Optional: Test SonarScanner') {
            steps {
                echo 'Checking if SonarScanner CLI is available...'
                bat 'C:\\sonar-scanner-7.3.0.5189-windows-x64\\bin\\sonar-scanner -v || echo "SonarScanner not found"'
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    withSonarQubeEnv('sonar-local') {
                        withCredentials([string(credentialsId: 'Online_Exam', variable: 'SONAR_TOKEN')]) {
                            bat """
                            cd project
                            C:\\sonar-scanner-7.3.0.5189-windows-x64\\bin\\sonar-scanner ^
                              -Dsonar.projectKey=Online_Exam ^
                              -Dsonar.sources=. ^
                              -Dsonar.host.url=%SONAR_HOST_URL% ^
                              -Dsonar.login=%SONAR_TOKEN%
                            """
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') { // wait max 5 min for Quality Gate
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
                        } else {
                            echo "Quality Gate passed: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-Hub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        bat """
                        echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USER% --password-stdin
                        docker build -t akshu072/online_exam:latest project
                        docker push akshu072/online_exam:latest
                        """
                    }
                }
            }
        }

        stage('Optional: Test Application') {
            steps {
                echo 'You can add any application tests here if needed'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            bat 'docker logout'
        }

        success {
            echo 'Build Succeeded! Sending email...'
            withCredentials([string(credentialsId: 'email-recipient', variable: 'EMAIL_TO')]) {
                emailext(
                    subject: "SUCCESS: Jenkins Build ${currentBuild.fullDisplayName}",
                    body: """<p>Good news! Your Jenkins build succeeded.</p>
                             <p>Build URL: ${env.BUILD_URL}</p>""",
                    to: "${EMAIL_TO}"
                )
            }
        }

        failure {
            echo 'Build Failed! Sending email...'
            withCredentials([string(credentialsId: 'email-recipient', variable: 'EMAIL_TO')]) {
                emailext(
                    subject: "FAILURE: Jenkins Build ${currentBuild.fullDisplayName}",
                    body: """<p>Oops! Your Jenkins build failed.</p>
                             <p>Check console output here: ${env.BUILD_URL}</p>""",
                    to: "${EMAIL_TO}"
                )
            }
        }
    }
}
