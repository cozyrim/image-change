#!/bin/bash

# Ubuntu 서버 설정 스크립트
# 이 스크립트를 Ubuntu 서버에서 실행하세요

set -e

echo "🚀 Ubuntu 서버 설정을 시작합니다..."

# 1. 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y

# 2. Docker 설치
echo "🐳 Docker 설치 중..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker 설치 완료"
else
    echo "Docker가 이미 설치되어 있습니다"
fi

# 3. Docker Compose 설치
echo "📋 Docker Compose 설치 중..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose 설치 완료"
else
    echo "Docker Compose가 이미 설치되어 있습니다"
fi

# 4. SSH 키 설정
echo "🔑 SSH 키 설정 중..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 공개키를 authorized_keys에 추가
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+iaxW6JmObrhWbxGEXq/w+iMwYuVHA/iPFodVPsQulScA0UsIanU07+EVrbxINpY7UcD05yXQqG58VC0166gqcURt+4KiOVI47XFZaEUcpQ0MtzFEkxK5TfZbUPrJh/aTf312G5+8SxgAOyWvHnHmURnQGZDxWw1HAlf2v4J5v+YLDZHylzP2lnFhjJuvb+735SQ1z1U/MsfA4u1EZe+gKWmKAG+KvwMqp/RuDXsfBB1Z9hJVum+QNf+nepHxotV1ozJOf1T1RZtIhOiaNhVVl/K1vPjvK9SA6TOhwJdHc3LMhHph0/8upP34Sl1x5p0BUzn1fP8wvvlRAXZ2zbrKqMrdTrcYFMf5JRijaH+LwE0+XYRN2aMQrzAaY2ibPp1S3gvQg3pA/vaa00QJnsgXlKssGa7OlJpspPK++871oxR4Sgdr9PgG2ErYMb+neDwJE7KpbCgnf6oc1iyvTZZUiJslP5FrI+QaY2pmp1oFAFVZ8aZ9Rg/d/P3sfdmD4CsUIPI0v9ItP4sJgm0IBOKS5gs5vUd9Jq86CYDTh0h6UWiB3dW8uUOItn/AluSyu7H7QriBPL2Eui9rdVQFXLbDRethitGjStp7/BspRwa+8irYnJ7HGZTmQ6iBGmfwKrVAnbXQrm+zTBwBYqG93VEaCVt3q2UBxOeYkTqkULnvIw== deploy@example.com" >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
echo "SSH 키 설정 완료"

# 5. 프로젝트 디렉토리 생성
echo "📁 프로젝트 디렉토리 생성 중..."
sudo mkdir -p /opt/blue-green-deployment
sudo chown $USER:$USER /opt/blue-green-deployment
echo "프로젝트 디렉토리 생성 완료"

# 6. 방화벽 설정
echo "🔥 방화벽 설정 중..."
sudo ufw --force enable
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3000
sudo ufw allow 3001
sudo ufw allow 3002
sudo ufw allow 8080
echo "방화벽 설정 완료"

# 7. Git 설치
echo "📚 Git 설치 중..."
sudo apt install git -y

# 8. Node.js 설치 (선택사항 - 로컬 개발용)
echo "📦 Node.js 설치 중..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "✅ Ubuntu 서버 설정이 완료되었습니다!"
echo ""
echo "📋 다음 단계:"
echo "1. GitHub 저장소에서 시크릿 설정 (SSH_KEY, HOST, USERNAME)"
echo "2. 로컬에서 git push 실행"
echo "3. GitHub Actions에서 자동 배포 확인"
echo ""
echo "🌐 접속 URL (설정 완료 후):"
echo "- 메인 애플리케이션: http://YOUR_SERVER_IP:3000"
echo "- Blue 환경: http://YOUR_SERVER_IP:3001"
echo "- Green 환경: http://YOUR_SERVER_IP:3002"
echo "- Traefik 대시보드: http://YOUR_SERVER_IP:8080" 