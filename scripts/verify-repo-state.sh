#!/usr/bin/env bash
# INFRA-01 verifier — Phase 1: Project Hygiene & Build Isolation
#
# Asserts:
#   1. Every core source path is tracked in git
#   2. No dangling gitlink (mode 160000 with no .gitmodules entry) exists
#   3. Every declared submodule is initialized
#   4. No untracked paths remain except the deliberately-deferred CI workflow
#
# Exit 0 = INFRA-01 satisfied. Exit 1 = not satisfied (details on stdout).
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0

echo "== 1. core sources tracked =="
for p in kalecky-spec kalecky-plank notes test foundry.toml remappings.txt; do
  n=$(git ls-files -- "$p" | wc -l)
  if [ "$n" -eq 0 ]; then
    echo "FAIL: '$p' is not tracked (0 files in the index)"
    fail=1
  else
    echo "ok:   $p ($n files tracked)"
  fi
done

echo "== 2. no dangling gitlinks =="
declared=$(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}')
while IFS=$'\t' read -r meta path; do
  mode=${meta%% *}
  [ "$mode" = "160000" ] || continue
  if printf '%s\n' "$declared" | grep -qxF "$path"; then
    echo "ok:   gitlink $path declared in .gitmodules"
  else
    echo "FAIL: dangling gitlink at '$path' (mode 160000, no .gitmodules entry)"
    fail=1
  fi
done < <(git ls-files -s)

echo "== 3. submodules initialized =="
if git submodule status --recursive 2>/dev/null | grep -q '^-'; then
  echo "FAIL: uninitialized submodule(s):"
  git submodule status --recursive | grep '^-'
  fail=1
else
  echo "ok:   all submodules initialized"
fi

echo "== 4. no stray untracked paths =="
# .github/workflows/test.yml is a DEFERRED idea (CI is out of scope for Phase 1).
stray=$(git status --porcelain=v1 | grep '^??' | grep -v '^?? \.github/' || true)
if [ -n "$stray" ]; then
  echo "FAIL: untracked paths remain:"
  echo "$stray"
  fail=1
else
  echo "ok:   no untracked paths (except deferred .github/)"
fi

echo "== 5. remappings.txt targets resolve =="
while IFS='=' read -r alias target; do
  [ -n "$target" ] || continue
  if [ -e "$target" ]; then
    echo "ok:   $alias -> $target"
  else
    echo "FAIL: remapping '$alias' points at missing path '$target'"
    fail=1
  fi
done < remappings.txt

if [ "$fail" -eq 0 ]; then
  echo "INFRA-01: PASS"
else
  echo "INFRA-01: FAIL"
fi
exit "$fail"
