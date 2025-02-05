#!/bin/bash

# 중단된 경우 즉시 종료
set -e

echo "🚀 Walrus Site 자동 배포 시작..."
echo "-------------------------------------------"

# 📌 Step 1: 필수 바이너리 체크 (Sui, Walrus, Site Builder)
echo "📌 [Step 1] 필수 도구 확인 중..."
if ! command -v sui &> /dev/null; then
    echo "❌ 오류: Sui가 설치되어 있지 않습니다. 먼저 Sui를 설치하세요."
    exit 1
fi

if ! command -v walrus &> /dev/null; then
    echo "❌ 오류: Walrus가 설치되어 있지 않습니다. 먼저 Walrus를 설치하세요."
    exit 1
fi

if ! command -v site-builder &> /dev/null; then
    echo "❌ 오류: Site Builder가 설치되어 있지 않습니다. 먼저 Site Builder를 설치하세요."
    exit 1
fi

echo "✅ 모든 필수 도구가 정상적으로 설치되어 있습니다!"
echo "-------------------------------------------"

# 📌 Step 2: Git 저장소 클론
REPO_DIR="example-walrus-sites"
echo "📌 [Step 2] Git 저장소 확인 중..."

if [ -d "$REPO_DIR" ]; then
    echo "🔄 기존 저장소 폴더가 존재합니다. 최신 상태로 업데이트합니다..."
    cd "$REPO_DIR" && git pull && cd ..
else
    echo "⬇️ Git 저장소를 클론 중..."
    if ! git clone https://github.com/MystenLabs/example-walrus-sites.git; then
        echo "❌ 오류: Git 저장소 클론 실패!"
        exit 1
    fi
    echo "✅ Git 저장소가 성공적으로 클론되었습니다!"
fi
echo "-------------------------------------------"

# 📌 Step 3: 배포할 사이트 디렉토리 확인
echo "📌 [Step 3] 배포할 사이트 디렉토리 확인 중..."
cd example-walrus-sites

if [ ! -d "walrus-snake" ]; then
    echo "❌ 오류: 'walrus-snake' 디렉토리를 찾을 수 없습니다."
    exit 1
fi
echo "✅ 배포할 사이트 디렉토리가 확인되었습니다!"
echo "-------------------------------------------"

# 📌 Step 4: Site Builder를 사용하여 사이트 배포
echo "📌 [Step 4] Walrus Site 배포 중..."
if site-builder publish ./walrus-snake --epochs 100; then
    echo "🎉 ✅ Walrus Site가 성공적으로 배포되었습니다!"
else
    echo "❌ 오류: Walrus Site 배포 실패!"
    exit 1
fi
echo "-------------------------------------------"

echo "🚀 모든 과정이 성공적으로 완료되었습니다! 🎉"
