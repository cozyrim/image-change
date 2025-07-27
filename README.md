# Blue/Green 무중단 배포 데모

이 프로젝트는 Blue/Green 배포 전략을 사용한 무중단 배포를 시연하기 위한 React 애플리케이션입니다. 이미지가 바뀌는 것을 통해 배포가 성공적으로 이루어졌는지 쉽게 확인할 수 있습니다.

## 🚀 기능

- **Blue/Green 배포**: 두 개의 동일한 환경을 번갈아가며 배포
- **무중단 서비스**: 배포 중에도 서비스 중단 없음
- **시각적 피드백**: 배포 타입에 따른 색상과 이미지 변경
- **자동화된 CI/CD**: GitHub Actions를 통한 자동 배포
- **헬스체크**: 배포 전후 상태 확인

## 📁 프로젝트 구조

```
blue-green-deployment/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD
├── public/
│   └── index.html              # HTML 템플릿
├── scripts/
│   └── deploy.sh               # 배포 스크립트
├── src/
│   ├── App.js                  # 메인 React 컴포넌트
│   ├── App.css                 # 스타일
│   ├── index.js                # 진입점
│   └── index.css               # 기본 스타일
├── docker-compose.yml          # Docker Compose 설정
├── Dockerfile                  # Docker 이미지 설정
├── nginx.conf                  # Nginx 설정
├── nginx-active.conf           # 활성 환경 Nginx 설정
├── package.json                # Node.js 의존성
└── README.md                   # 프로젝트 문서
```

## 🛠️ 기술 스택

- **Frontend**: React 18
- **Container**: Docker & Docker Compose
- **Web Server**: Nginx
- **Load Balancer**: Traefik
- **CI/CD**: GitHub Actions
- **Registry**: GitHub Container Registry

## 🚀 로컬 실행 방법

### 1. 사전 요구사항

- Docker & Docker Compose
- Node.js 18+
- Git

### 2. 프로젝트 클론

```bash
git clone <repository-url>
cd blue-green-deployment
```

### 3. 로컬 개발 서버 실행

```bash
npm install
npm start
```

### 4. Docker로 실행

```bash
# 전체 환경 실행
docker-compose up -d

# 특정 환경만 실행
docker-compose up -d app-blue
docker-compose up -d app-green
```

## 🌐 접속 URL

- **메인 애플리케이션**: http://localhost:3000
- **Blue 환경**: http://localhost:3001
- **Green 환경**: http://localhost:3002
- **Traefik 대시보드**: http://localhost:8080

## 🔄 Blue/Green 배포 방법

### 수동 배포

```bash
# Blue에서 Green으로 배포
./scripts/deploy.sh v1.1.0 BLUE

# Green에서 Blue로 배포
./scripts/deploy.sh v1.1.0 GREEN
```

### 자동 배포 (GitHub Actions)

1. `main` 브랜치에 코드를 푸시
2. GitHub Actions가 자동으로 실행
3. 테스트 통과 후 자동 배포

## 📊 배포 상태 확인

### 헬스체크

```bash
# 메인 애플리케이션
curl http://localhost:3000/health

# Blue 환경
curl http://localhost:3001/health

# Green 환경
curl http://localhost:3002/health
```

### 현재 활성 환경 확인

```bash
curl http://localhost:3000/active
```

## 🔧 환경 변수

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `REACT_APP_DEPLOYMENT_TYPE` | 배포 타입 (BLUE/GREEN) | BLUE |
| `REACT_APP_VERSION` | 애플리케이션 버전 | 1.0.0 |
| `REACT_APP_BUILD_TIME` | 빌드 시간 | 현재 시간 |

## 🐳 Docker 명령어

```bash
# 이미지 빌드
docker build -t blue-green-demo .

# 컨테이너 실행
docker run -p 3000:80 blue-green-demo

# 로그 확인
docker-compose logs -f app-blue
docker-compose logs -f app-green

# 컨테이너 상태 확인
docker-compose ps
```

## 🔍 문제 해결

### 포트 충돌

```bash
# 사용 중인 포트 확인
lsof -i :3000
lsof -i :3001
lsof -i :3002

# 컨테이너 중지
docker-compose down
```

### 이미지 빌드 실패

```bash
# 캐시 없이 재빌드
docker-compose build --no-cache

# 특정 서비스만 재빌드
docker-compose build app-blue
```

### 헬스체크 실패

```bash
# 컨테이너 로그 확인
docker-compose logs app-blue
docker-compose logs app-green

# 컨테이너 재시작
docker-compose restart app-blue
```

## 📝 배포 시나리오

1. **초기 배포**: Blue 환경에 첫 번째 버전 배포
2. **새 버전 배포**: Green 환경에 새 버전 배포
3. **트래픽 전환**: Nginx 설정을 통해 트래픽을 Green으로 전환
4. **검증**: 새 버전이 정상 작동하는지 확인
5. **롤백**: 문제 발생 시 Blue 환경으로 즉시 롤백 가능

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 이슈를 생성해주세요. # image-change
