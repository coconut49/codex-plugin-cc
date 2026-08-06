#!/usr/bin/env bash
# 不变式:main ≡ 上游 release tag + patch 栈 + 栈顶恰好一个版本 commit(标题以
# VERSION_PREFIX 开头)。patch 栈内不得含版本字段改动——本脚本靠丢弃/重建栈顶版本
# commit 来避免与上游 version bump 的 rebase 冲突。本地开发同理:先 reset 掉栈顶
# 版本 commit,提交你的 patch,再 bump 并重建版本 commit 与 -fork.N tag。
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

VERSION_PREFIX="chore(fork): version "

[ "$(git symbolic-ref --short HEAD)" = "main" ] || {
  echo "请在 main 分支上运行" >&2
  exit 1
}

[ -z "$(git status --porcelain)" ] || {
  echo "工作树不干净,先提交或清理" >&2
  exit 1
}

git fetch upstream --tags

LATEST=$(git tag --list 'v*.*.*' | grep -v -- '-fork\.' | sort -V | tail -n 1)
BASE=$(git describe --tags --exact-match --exclude '*-fork.*' "$(git merge-base main upstream/main)")
echo "上游最新 ${LATEST},当前 base ${BASE}"

case "$(git log -1 --format=%s)" in
  "$VERSION_PREFIX"*) HAS_VERSION_COMMIT=1 ;;
  *) HAS_VERSION_COMMIT=0 ;;
esac

if [ "$BASE" = "$LATEST" ] && [ "$HAS_VERSION_COMMIT" = 1 ]; then
  echo "已是最新"
  exit 0
fi

if [ "$HAS_VERSION_COMMIT" = 1 ]; then
  git reset --hard HEAD~1
fi

if [ "$BASE" != "$LATEST" ]; then
  git rebase --onto "$LATEST" "$BASE" main
fi

npm test

LAST_N=$(git tag --list "${LATEST}-fork.*" | sed 's/.*-fork\.//' | sort -n | tail -n 1)
N=$(( ${LAST_N:-0} + 1 ))
VERSION="${LATEST#v}-fork.${N}"

node scripts/bump-version.mjs "$VERSION"
git add -A
git commit -m "${VERSION_PREFIX}${VERSION}"
git tag -a "${LATEST}-fork.${N}" -m "sync to ${LATEST}"

echo "完成 ${VERSION},人工推送:"
echo "  git push --force-with-lease origin main && git push origin ${LATEST}-fork.${N}"
