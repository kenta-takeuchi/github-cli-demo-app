#!/bin/bash

# GitHubリポジトリの指定（例: owner/repo）
REPO="kenta-takeuchi/github-cli-demo-app"


# コミットログの一覧を取得
COMMITS=$(gh api repos/$REPO/commits --jq '.[] | "\(.sha) \(.commit.message)"')

# コミットログを表示
echo "コミットログ一覧:"
echo "$COMMITS"