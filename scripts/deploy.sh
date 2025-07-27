#!/bin/bash

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 환경 변수 설정
VERSION=${1:-$(date +%Y%m%d-%H%M%S)}
BUILD_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CURRENT_ENV=${2:-BLUE}

log_info "배포 시작 - 버전: $VERSION, 환경: $CURRENT_ENV"

# 현재 활성 환경 확인
if [ "$CURRENT_ENV" = "BLUE" ]; then
    TARGET_ENV="GREEN"
    TARGET_ENV_LOWER="green"
    TARGET_PORT="3002"
    CURRENT_PORT="3001"
else
    TARGET_ENV="BLUE"
    TARGET_ENV_LOWER="blue"
    TARGET_PORT="3001"
    CURRENT_PORT="3002"
fi

log_info "현재 환경: $CURRENT_ENV (포트: $CURRENT_PORT)"
log_info "대상 환경: $TARGET_ENV (포트: $TARGET_PORT)"

# 1. 새로운 환경 빌드 및 배포
log_info "새로운 환경($TARGET_ENV) 빌드 중..."
export VERSION=$VERSION
export BUILD_TIME=$BUILD_TIME
export REACT_APP_DEPLOYMENT_TYPE=$TARGET_ENV

# 환경변수 설정
export REGISTRY=${REGISTRY:-ghcr.io}
export IMAGE_NAME=${IMAGE_NAME:-cozyrim/image-change}
export VERSION=${VERSION:-latest}

docker-compose build app-$TARGET_ENV_LOWER

# 기존 컨테이너가 있으면 완전히 제거
log_info "기존 컨테이너 정리 중..."
docker-compose stop app-$TARGET_ENV_LOWER 2>/dev/null || true
docker-compose rm -f app-$TARGET_ENV_LOWER 2>/dev/null || true

# 새 컨테이너 시작
docker-compose up -d app-$TARGET_ENV_LOWER

# 2. 헬스체크
log_info "새로운 환경 헬스체크 중..."
for i in {1..30}; do
    if curl -f http://localhost:$TARGET_PORT/health > /dev/null 2>&1; then
        log_success "새로운 환경이 정상적으로 시작되었습니다."
        break
    fi
    
    if [ $i -eq 30 ]; then
        log_error "새로운 환경 헬스체크 실패"
        exit 1
    fi
    
    log_info "헬스체크 재시도 중... ($i/30)"
    sleep 2
done

# 3. 트래픽 전환
log_info "트래픽을 새로운 환경으로 전환 중..."

# Nginx 설정 업데이트
cat > nginx-active.conf << EOF
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    upstream blue_backend {
        server app-blue:80;
    }

    upstream green_backend {
        server app-green:80;
    }

    # 현재 활성 환경
    map \$http_x_active_environment \$active_backend {
        default ${TARGET_ENV_LOWER}_backend;
        "GREEN" green_backend;
        "BLUE" blue_backend;
    }

    server {
        listen 80;
        server_name 3.39.46.208;

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        location /active {
            access_log off;
            return 200 "\$active_backend\n";
            add_header Content-Type text/plain;
        }

        location / {
            proxy_pass http://\$active_backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

# Nginx 재시작 (컨테이너가 없으면 생성)
log_info "app-active 컨테이너 재시작 중..."
docker-compose stop app-active 2>/dev/null || true
docker-compose rm -f app-active 2>/dev/null || true
docker-compose up -d app-active

# 4. 최종 헬스체크
log_info "최종 헬스체크 중..."
sleep 5

if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    log_success "배포가 성공적으로 완료되었습니다!"
    log_info "새로운 환경: $TARGET_ENV (포트: $TARGET_PORT)"
    log_info "애플리케이션 URL: http://localhost:3000"
    log_info "Blue 환경: http://localhost:3001"
    log_info "Green 환경: http://localhost:3002"
    log_info "Traefik 대시보드: http://localhost:8080"
else
    log_error "최종 헬스체크 실패"
    exit 1
fi 