pipeline {
    agent {
        docker { image 'node:10' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version'
            }
        }
    }
}
