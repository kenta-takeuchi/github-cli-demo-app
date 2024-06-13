#!/bin/bash

# GitHubリポジトリの指定（例: owner/repo）
REPO="kenta-takeuchi/github-cli-demo-app"

# 正規表現パターン
PATTERN='^[0-9]+_hoge$'

# 正規表現にマッチする最新のリリースを取得
LATEST_RELEASE=""
LATEST_RELEASE_DATE=""

# リリースの一覧を取得してフィルタリング
RELEASES=$(gh release list --repo "$REPO" --json tagName,publishedAt --jq '.[] | {tagName, publishedAt}')

for RELEASE in $(echo "$RELEASES" | jq -c '.'); do
  TAG_NAME=$(echo "$RELEASE" | jq -r '.tagName')
  PUBLISHED_AT=$(echo "$RELEASE" | jq -r '.publishedAt')

  if [[ $TAG_NAME =~ $PATTERN ]]; then
    LATEST_RELEASE=$TAG_NAME
    LATEST_RELEASE_DATE=$PUBLISHED_AT
    break
  fi
done

if [ -z "$LATEST_RELEASE" ]; then
  echo "指定された正規表現にマッチするリリースは見つかりませんでした。"
  exit 1
else
  echo "最新のリリース: $LATEST_RELEASE"
  echo "リリース日: $LATEST_RELEASE_DATE"
fi

# 最新のリリースの作成日時以降にマージされた、タイトルにhogeを含むPRの一覧を取得
MERGED_PRS=$(gh pr list --repo "$REPO" --state merged --json number,title,mergedAt --jq '.[] | select(.mergedAt > "'"$LATEST_RELEASE_DATE"'") | select(.title | contains("hoge")) | "- \(.number) \(.title)"')

# マージされたPRを表示
if [ -z "$MERGED_PRS" ]; then
  echo "最新のリリース以降にマージされた、タイトルにhogeを含むPRはありません。"
else
  echo "最新のリリース以降にマージされた、タイトルにhogeを含むPR一覧:"
  echo "$MERGED_PRS"
fi