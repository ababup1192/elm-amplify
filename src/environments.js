export const environment = {
  production: false,
  amplify: {
    // AWS Amplify(Auth)の設定
    Auth: {
      region: 'ap-northeast-1',
      userPoolId: 'ap-northeast-1_hxMO793lW',
      userPoolWebClientId: '3ki2rs0t3rfo4m940q2uc3oscm'
    }
  },
  // API Gatewayのエンドポイントの設定
  apiBaseUrl: 'https://5zn8musjr1.execute-api.ap-northeast-1.amazonaws.com/test',
  // Localstorageの設定
  localstorageBaseKey: 'CognitoIdentityServiceProvider.3ki2rs0t3rfo4m940q2uc3oscm.'
};
