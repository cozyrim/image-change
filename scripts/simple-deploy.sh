#!/bin/bash

set -e

echo "🚀 Simple Blue/Green Deployment 시작"

# 현재 활성 환경 확인
if grep -q "app-blue:80" nginx-simple.conf; then
    CURRENT="BLUE"
    TARGET="GREEN"
    TARGET_SERVICE="app-green"
else
    CURRENT="GREEN"
    TARGET="BLUE" 
    TARGET_SERVICE="app-blue"
fi

echo "📍 현재 환경: $CURRENT → 대상 환경: $TARGET"

# 1. 새 환경 빌드 및 시작
echo "🔨 $TARGET 환경 빌드 중..."
docker-compose build $TARGET_SERVICE
docker-compose up -d $TARGET_SERVICE

# 2. 헬스체크 (30초 대기)
echo "🏥 헬스체크 중..."
for i in {1..15}; do
    if [ "$TARGET" = "BLUE" ]; then
        PORT=3001
    else
        PORT=3002
    fi
    
    if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
        echo "✅ $TARGET 환경이 정상 작동 중"
        break
    fi
    
    if [ $i -eq 15 ]; then
        echo "❌ $TARGET 환경 헬스체크 실패"
        exit 1
    fi
    
    echo "⏳ 헬스체크 재시도... ($i/15)"
    sleep 2
done

# 3. Nginx 설정 변경 (트래픽 전환)
echo "🔄 트래픽을 $TARGET 환경으로 전환 중..."

if [ "$TARGET" = "BLUE" ]; then
    sed -i 's/server app-green:80;/# server app-green:80;/' nginx-simple.conf
    sed -i 's/# server app-blue:80;/server app-blue:80;/' nginx-simple.conf
else
    sed -i 's/server app-blue:80;/# server app-blue:80;/' nginx-simple.conf  
    sed -i 's/# server app-green:80;/server app-green:80;/' nginx-simple.conf
fi

# 4. Nginx 재시작
docker-compose restart nginx

# 5. 최종 확인
echo "🔍 최종 헬스체크 중..."
sleep 3

if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "🎉 배포 완료! $TARGET 환경으로 전환됨"
    echo "🌐 접속 URL: http://3.39.46.208"
    echo "📊 Blue: http://3.39.46.208:3001"
    echo "📊 Green: http://3.39.46.208:3002"
else
    echo "❌ 최종 헬스체크 실패"
    exit 1
fi 