#!/bin/bash

# 중단된 경우 즉시 종료
set -e

echo "🚀 시작: Sui & Walrus & Site Builder 자동 설치 스크립트"
echo "-------------------------------------------"

# 📌 운영체제(OS) 확인
OS_TYPE=$(uname -s)
if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "🖥️ MacOS 환경 감지됨"
    CONFIG_PATH="$HOME/.config"
else
    echo "🖥️ Linux 환경 감지됨"
    CONFIG_PATH="/root/.config"
fi
echo "📂 설정 경로: $CONFIG_PATH"
echo "-------------------------------------------"

# 📌 Step 1-1: Sui 설치 여부 확인
echo "📌 [Step 1-1] Sui 설치 확인"
if command -v sui &> /dev/null; then
    echo "✅ Sui가 이미 설치되어 있습니다. 설치 과정을 건너뜁니다."
else
    echo "🔍 Sui가 설치되지 않았습니다. 최신 버전을 다운로드하여 설치합니다..."

    # 최신 Sui testnet 버전 가져오기
    echo "🔄 최신 Sui testnet 버전 가져오는 중..."
    LATEST_TESTNET_VERSION=$(curl -s https://api.github.com/repos/MystenLabs/sui/releases | jq -r '.[] | .tag_name' | grep -o 'testnet-[^"]*' | head -n 1)

    if [[ -z "$LATEST_TESTNET_VERSION" ]]; then
        echo "❌ 오류: 최신 Sui testnet 버전을 가져오지 못했습니다."
        exit 1
    fi

    echo "✅ 최신 Sui testnet 버전: $LATEST_TESTNET_VERSION"

    # MacOS와 Linux용 Sui 바이너리 URL 설정
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        DOWNLOAD_URL="https://github.com/MystenLabs/sui/releases/download/${LATEST_TESTNET_VERSION}/sui-${LATEST_TESTNET_VERSION}-macos-arm64.tgz"
    else
        DOWNLOAD_URL="https://github.com/MystenLabs/sui/releases/download/${LATEST_TESTNET_VERSION}/sui-${LATEST_TESTNET_VERSION}-ubuntu-x86_64.tgz"
    fi

    echo "⬇️ Sui 바이너리 다운로드 중..."
    if ! sudo curl -L $DOWNLOAD_URL -o /usr/local/bin/sui-latest.tgz; then
        echo "❌ 오류: Sui 다운로드 실패!"
        exit 1
    fi

    # 압축 해제 및 설치
    echo "📦 Sui 바이너리 압축 해제 중..."
    cd /usr/local/bin
    if ! sudo tar -xvf sui-latest.tgz; then
        echo "❌ 오류: 압축 해제 실패!"
        sudo rm -f sui-latest.tgz
        exit 1
    fi
    sudo rm -rf sui-latest.tgz
    sudo chmod +x /usr/local/bin/sui
    echo "🎉 ✅ Sui 설치 완료!"
fi
echo "-------------------------------------------"

# 📌 Step 1-2: Sui 설치 확인
echo "📌 [Step 1-2] Sui 설치 확인"
if sui --version; then
    echo "🎉 ✅ Sui 정상 실행됨!"
else
    echo "❌ 오류: Sui가 실행되지 않습니다."
    exit 1
fi
echo "-------------------------------------------"

# 📌 Step 2: Sui 지갑 생성
echo "📌 [Step 2] Sui 지갑 생성"
if sui client new-address ed25519; then
    echo "🎉 ✅ Sui 지갑 생성 완료!"
else
    echo "❌ 오류: Sui 지갑 생성 실패!"
    exit 1
fi
echo "-------------------------------------------"

# 📌 Step 3: Walrus 설치
echo "📌 [Step 3] Walrus 설치 확인"
if command -v walrus &> /dev/null; then
    echo "✅ Walrus가 이미 설치되어 있습니다."
else
    echo "🔍 Walrus가 설치되지 않았습니다. 최신 버전을 다운로드합니다..."

    # MacOS와 Linux용 Walrus 바이너리 URL 설정
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        WALRUS_URL="https://storage.googleapis.com/mysten-walrus-binaries/walrus-testnet-latest-macos-arm64"
    else
        WALRUS_URL="https://storage.googleapis.com/mysten-walrus-binaries/walrus-testnet-latest-ubuntu-x86_64"
    fi

    echo "⬇️ Walrus 다운로드 중..."
    if ! sudo curl -L $WALRUS_URL -o /usr/local/bin/walrus; then
        echo "❌ 오류: Walrus 다운로드 실패!"
        exit 1
    fi

    sudo chmod +x /usr/local/bin/walrus
    echo "🎉 ✅ Walrus 설치 완료!"
fi
echo "-------------------------------------------"

# 📌 Step 4-1: Site Builder 설치
echo "📌 [Step 4-1] Site Builder 설치 확인"
if command -v site-builder &> /dev/null; then
    echo "✅ Site Builder가 이미 설치되어 있습니다."
else
    echo "🔍 Site Builder가 설치되지 않았습니다. 최신 버전을 다운로드합니다..."

    SITE_BUILDER_URL="https://storage.googleapis.com/mysten-walrus-binaries/site-builder-testnet-latest-ubuntu-x86_64"
    echo "⬇️ Site Builder 다운로드 중..."

    if ! sudo curl -L $SITE_BUILDER_URL -o /usr/local/bin/site-builder; then
        echo "❌ 오류: Site Builder 다운로드 실패!"
        exit 1
    fi

    sudo chmod +x /usr/local/bin/site-builder
    echo "🎉 ✅ Site Builder 설치 완료!"
fi
echo "-------------------------------------------"

# 📌 Step 4-2: Site Builder Config 설정
echo "📌 [Step 4-2] Site Builder 설정 적용"
mkdir -p "$CONFIG_PATH/walrus"
cat <<EOL > "$CONFIG_PATH/walrus/sites-config.yaml"
module: site
portal: walrus.site
package: 0xdf9033cac39b7a9b9f76fb6896c9fc5283ba730d6976a2b1d85ad1e6036c3272
general:
   rpc_url: https://fullnode.testnet.sui.io:443
   wallet: $HOME/.sui/sui_config/client.yaml
   walrus_binary: /usr/local/bin/walrus
   walrus_config: $CONFIG_PATH/walrus/client_config.yaml
   gas_budget: 500000000
EOL
echo "🎉 ✅ Site Builder 설정 완료!"
echo "-------------------------------------------"

# 📌 Step 5: 현재 활성화된 Sui 주소 확인 및 입금 요청 안내
echo "📌 [Step 5] 활성화된 Sui 주소 확인"
ACTIVE_ADDRESS=$(sui client active-address 2>/dev/null)

if [[ -z "$ACTIVE_ADDRESS" ]]; then
    echo "❌ 오류: 활성화된 Sui 주소를 찾을 수 없습니다."
    echo "🔹 먼저 'sui client new-address ed25519' 명령어로 지갑을 생성하세요."
    exit 1
fi

echo "✅ 현재 활성화된 Sui 주소: $ACTIVE_ADDRESS"
echo "💰 이 주소로 입금을 진행하세요."
echo "📢 테스트넷 Sui 토큰을 얻으려면 공식 Discord 또는 Faucet 서비스를 이용하세요."
echo "🔗 Faucet: https://discord.com/invite/sui"
echo "-------------------------------------------"

echo "🚀 모든 과정이 완료되었습니다! 🎉"
