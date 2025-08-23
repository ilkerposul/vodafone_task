# İlker Poşul - Vodafone  CI/CD Task

Spring Boot "hello world" uygulamasını Jenkins ile Kubernetes'e deploy eden CI/CD pipeline

## Gereksinimler

### Altyapı
- K8s
- Jenkins
- ihtiyaç durumunda loadbalancer

### Jenkins Pluginleri
- Kubernetes Plugin
- Kubernetes CLI Plugin
- Pipeline Plugin
- Git Plugin
- HTML Publisher Plugin
- HTTP Request Plugin
- JUnit Plugin

### Jenkins Credentials
- 'docker-hub-credentials': dockerhub username ve token
- 'mykubeconfig': kubernetes config dosyasi
- 'github-credentials' scm polling için

## Proje Yapısı

    src
        main/java/com/vodafone/helloworld
            HelloWorldApplication.java
            HelloController.java
        test/java/com/vodafone/helloworld
            HelloControllerTest.java
    k8s
        deployment.yaml
        service.yaml
        ingress.yaml
    Dockerfile
    Jenkinsfile
    pom.xml


## Pipeline Stageleri

1. checkout: githubdan kod çekme
2. build & test & quality: paralel test ve kod kalite analizi
3. build & push image: docker image oluşturma ve push
4. security scan: image guvenlik taraması
5. deploy: kubernetese deployment
6. health check: HTTP endpoint testi


## Özellikler

- Paralel build ve test
- Kod kalite kontrolü (SpotBugs)
- Güvenlik taramasi (Trivy)
- Kubernetes deployment
- Health check monitoring
- Test raporları
- Maven cache optimizasyonu
