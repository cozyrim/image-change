import React from 'react';
import './App.css';

function App() {
  // 환경변수에서 배포 정보 가져오기
  const deploymentType = process.env.REACT_APP_DEPLOYMENT_TYPE || 'BLUE';
  const buildTime = process.env.REACT_APP_BUILD_TIME || new Date().toISOString();
  const version = process.env.REACT_APP_VERSION || '1.0.0';

  // 배포 타입에 따른 색상과 이미지 설정
  const getDeploymentConfig = () => {
    switch (deploymentType) {
      case 'GREEN':
        return {
          backgroundColor: '#4CAF50',
          title: '🟢 Green 배포',
          image: '/images/bluegreen2.png',
          description: '새로운 버전이 성공적으로 배포되었습니다!'
        };
      case 'BLUE':
      default:
        return {
          backgroundColor: '#2196F3',
          title: '🔵 Blue 배포',
          image: '/images/bluegreen1.png',
          description: '안정적인 현재 버전이 실행 중입니다.'
        };
    }
  };

  const config = getDeploymentConfig();

  return (
    <div className="App">
      <div className="container" style={{ backgroundColor: config.backgroundColor }}>
        <header className="header">
          <h1>{config.title}</h1>
          <p className="description">{config.description}</p>
        </header>
        
        <main className="main">
          <div className="image-container">
            <img 
              src={config.image} 
              alt="배포 상태 이미지" 
              className="deployment-image"
            />
          </div>
          
          <div className="info-panel">
            <div className="info-item">
              <strong>배포 타입:</strong> {deploymentType}
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
          <p>Blue/Green 무중단 배포 데모 애플리케이션</p>
          <p>이미지가 바뀌면 새로운 배포가 성공적으로 완료된 것입니다!</p>
        </footer>
      </div>
    </div>
  );
}

export default App; 