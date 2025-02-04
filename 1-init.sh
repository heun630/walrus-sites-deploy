# 모든 릴리스 정보를 가져와서 testnet으로 시작하는 태그를 찾기
LATEST_TESTNET_VERSION=$(curl -s https://api.github.com/repos/MystenLabs/sui/releases | jq -r '.[] | .tag_name' | grep -o 'testnet-[^"]*' | head -n 1)

# 최신 테스트넷 버전 출력
echo "최신 테스트넷 버전: $LATEST_TESTNET_VERSION"

# 다운로드 URL 생성
DOWNLOAD_URL="https://github.com/MystenLabs/sui/releases/download/${LATEST_TESTNET_VERSION}/sui-${LATEST_TESTNET_VERSION}-ubuntu-x86_64.tgz"

# 파일 다운로드 및 설치
wget $DOWNLOAD_URL -O /usr/local/bin/sui-latest.tgz && \
cd /usr/local/bin && \
tar -xvf sui-latest.tgz && \
rm -rf sui-latest.tgz

echo "Sui testnet 최신 버전 설치 완료: $LATEST_TESTNET_VERSION"