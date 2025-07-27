import React from 'react';
import './App.css';

function App() {
  // 환경변수에서 배포 정보 가져오기
  const deploymentType = process.env.REACT_APP_DEPLOYMENT_TYPE || 'BLUE';
  const buildTime = process.env.REACT_APP_BUILD_TIME || new Date().toISOString();
  const version = process.env.REACT_APP_VERSION || '1.0.0';

  // 배포 타입에 따른 설정 (이미지는 정적)
  const getDeploymentConfig = () => {
    const config = {
      // 정적 이미지 경로 - 수동으로 변경 후 git push로 무중단 배포 테스트
      image: '/images/bluegreen2.png',
      description: '무중단 배포 테스트를 위한 React 애플리케이션입니다.'
    };

    // 배포 타입별 컨테이너 정보
    switch (deploymentType) {
      case 'GREEN':
        config.containerType = '🟢 GREEN';
        config.containerColor = '#4CAF50';
        break;
      case 'BLUE':
      default:
        config.containerType = '🔵 BLUE';
        config.containerColor = '#2196F3';
        break;
    }

    return config;
  };

  const config = getDeploymentConfig();

  return (
    <div className="App">
      {/* 오른쪽 상단 컨테이너 타입 표시 */}
      <div className="container-badge" style={{ backgroundColor: config.containerColor }}>
        {config.containerType}
      </div>
      
      <div className="container">
        <header className="header">
          <h1>🚀 Blue/Green 무중단 배포 데모</h1>
          <p className="description">{config.description}</p>
        </header>
        
        <main className="main">
          <div className="image-container">
            <img 
              src={config.image} 
              alt="무중단 배포 테스트 이미지" 
              className="deployment-image"
            />
            <p className="image-info">
              💡 이미지를 수동으로 변경하고 git push하여 무중단 배포를 테스트하세요!
            </p>
          </div>
          
          <div className="info-panel">
            <div className="info-item">
              <strong>현재 컨테이너:</strong> {deploymentType}
            </div>
            <div className="info-item">
              <strong>버전:</strong> {version}
            </div>
            <div className="info-item">
              <strong>빌드 시간:</strong> {new Date(buildTime).toLocaleString('ko-KR')}
            </div>
            <div className="info-item">
              <strong>환경:</strong> {process.env.NODE_ENV}
            </div>
          </div>
        </main>
        
        <footer className="footer">
          <p>🔄 Blue/Green 무중단 배포 시스템</p>
          <p>Docker + GitHub Actions로 구현된 CI/CD 파이프라인</p>
        </footer>
      </div>
    </div>
  );
}

export default App; 