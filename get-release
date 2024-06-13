#!/bin/bash

# GitHubリポジトリの指定（例: owner/repo）
REPO="kenta-takeuchi/github-cli-demo-app"

# 正規表現パターン
PATTERN='^[0-9]+_hoge$'

# リリースの一覧を取得
RELEASES=$(gh release list --repo "$REPO" --json tagName --jq '.[] | .tagName')

echo "リリース一覧: $RELEASES"

# 正規表現にマッチする最新のリリースを検索
LATEST_RELEASE=""
for RELEASE in $RELEASES; do
  echo "リリース: $RELEASE"
  if [[ $RELEASE =~ $PATTERN ]]; then
    echo "正規表現にマッチしました。"
    LATEST_RELEASE=$RELEASE
    break
  fi
done

if [ -n "$LATEST_RELEASE" ]; then
  echo "最新のリリース: $LATEST_RELEASE"
else
  echo "指定された正規表現にマッチするリリースは見つかりませんでした。"
fi
