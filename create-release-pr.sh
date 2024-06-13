#!/bin/bash

# GitHubリポジトリの指定（例: owner/repo）
REPO="kenta-takeuchi/github-cli-demo-app"
PR_BASE_BRANCH="main" # デフォルトブランチ名
PR_TITLE="最新のリリース以降のhoge PRのリスト"
TEXT_FILE="pr_list.txt"

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
MERGED_PRS=$(gh pr list --repo "$REPO" --state merged --json number,title,mergedAt --jq '.[] | select(.mergedAt > "'"$LATEST_RELEASE_DATE"'") | select(.title | contains("hoge")) | "\(.number) \(.title)"')

# PRのリストをファイルに出力
if [ -z "$MERGED_PRS" ]; then
  echo "最新のリリース以降にマージされた、タイトルにhogeを含むPRはありません。" > $TEXT_FILE
else
  echo "最新のリリース以降にマージされた、タイトルにhogeを含むPR一覧:" > $TEXT_FILE
  while IFS= read -r PR; do
    PR_NUMBER=$(echo "$PR" | awk '{print $1}')
    PR_TITLE=$(echo "$PR" | awk '{$1=""; print $0}')
    echo "- [#$PR_NUMBER](https://github.com/$REPO/pull/$PR_NUMBER) $PR_TITLE" >> $TEXT_FILE
  done <<< "$MERGED_PRS"
fi

# 新しいブランチを作成
BRANCH_NAME="update-pr-list"
git checkout -b "$BRANCH_NAME"

# ファイルを追加してコミット
git add $TEXT_FILE
git commit -m "Update PR list after latest release"

# ブランチをプッシュ
git push origin "$BRANCH_NAME"

# PRを作成
PR_BODY=$(cat $TEXT_FILE)
gh pr create --repo "$REPO" --base "$PR_BASE_BRANCH" --head "$BRANCH_NAME" --title "$PR_TITLE" --body "$PR_BODY"

echo "Pull Requestを作成しました。"
