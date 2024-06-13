#!/bin/bash

BASE_BRANCH="main"

PR_TITLE="test create pr"
PR_BODY="test create pr body"

BRANCH_NAME="feature/test"

# Branchを作成もしくは存在していたらチェックアウト
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  git checkout "$BRANCH_NAME"
else
  git checkout -b "$BRANCH_NAME"
fi

# sampleファイルを作成してコミット
echo "test" > sample.txt
git add sample.txt
git commit -m "test commit"

# PRを作成
gh pr create --base "$BASE_BRANCH" --head "$CURRENT_BRANCH" --title "$PR_TITLE" --body "$PR_BODY"

echo "Pull Requestを作成しました。"
