pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.5-eclipse-temurin-17
    command: ["/bin/sh", "-c", "while true; do sleep 30; done"]
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/bin/sh", "-c", "while true; do sleep 30; done"]
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    - name: kaniko-cache
      mountPath: /kaniko/cache
  - name: trivy
    image: aquasec/trivy:latest
    command: ["/bin/sh", "-c", "while true; do sleep 30; done"]
  volumes:
  - name: maven-cache
    emptyDir: {}
  - name: kaniko-cache
    emptyDir: {}
  - name: docker-config
    emptyDir: {}
"""
        }
    }

    stages {
        stage('checkout') {
            steps {
                // github'dan kodu cek
                checkout scm
                // diger stage'ler icin kodu sakla
                stash name: 'source', includes: '**/*'
            }
        }

        stage('build & test & quality') {
            parallel {
                stage('compile & test') {
                    steps {
                        container('maven') {
                            // kodu geri al
                            unstash 'source'
                            // paralel build ile test calistir
                            sh 'mvn -B -T 2C test'
                            // test sonuclarini yayinla
                            publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                        }
                    }
                }

                stage('code quality') {
                    steps {
                        container('maven') {
                            // kodu geri al
                            unstash 'source'
                            // kod kalite analizi
                            sh 'mvn -B -T 2C spotbugs:spotbugs'
                            // html rapor yayinla
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site',
                                reportFiles: 'spotbugs.html',
                                reportName: 'SpotBugs Report'
                            ])
                        }
                    }
                }
            }
        }

        stage('build & push image') {
            steps {
                container('kaniko') {
                    // kodu geri al
                    unstash 'source'
                    // docker hub credential ile image build ve push
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "{\\"auths\\":{\\"https://index.docker.io/v1/\\":{\\"username\\":\\"$DOCKER_USER\\",\\"password\\":\\"$DOCKER_PASS\\"}}}" > /kaniko/.docker/config.json
                            /kaniko/executor --dockerfile=Dockerfile --context=. \
                                --destination=ilkerposul/vodafone:latest \
                                --cache=false
                        '''
                    }
                }
            }
        }

        stage('security scan') {
            steps {
                container('trivy') {
                    // image guvenlik taramas
                    sh '''
                        trivy image --format json --output trivy-report.json ilkerposul/vodafone:latest || true
                        trivy image --severity HIGH,CRITICAL --exit-code 0 ilkerposul/vodafone:latest || true
                    '''
                    // tarama raporu sakla
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('deploy') {
            steps {
                // kubernetes deploy
                withKubeConfig([credentialsId: 'mykubeconfig']) {
                    sh '''
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        kubectl rollout status deployment/hello-world --timeout=300s
                    '''
                }
            }
        }

        stage('health check') {
            steps {
                // k8s durumu kontrol et
                withKubeConfig([credentialsId: 'mykubeconfig']) {
                    sh '''
                        kubectl get deployment hello-world -o wide
                        kubectl get pods -l app=hello-world
                        kubectl get ingress hello-world-ingress
                    '''
                }

                // http health check
                timeout(time: 2, unit: 'MINUTES') {
                    waitUntil {
                        script {
                            try {
                                def response = httpRequest(
                                    url: 'http://vodafone-hello-world.local/health',
                                    timeout: 10,
                                    validResponseCodes: '200'
                                )
                                echo "health check ok: ${response.status}"
                                return true
                            } catch (Exception e) {
                                echo "health check failed, retrying..."
                                return false
                            }
                        }
                    }
                }

                echo "deployment successful!"
                echo "url: http://vodafone-hello-world.local"
            }
        }
    }
}
