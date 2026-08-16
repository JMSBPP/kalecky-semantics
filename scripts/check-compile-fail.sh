#!/usr/bin/env bash
# UNIT-04 negative boundary: every file under test-kalecky/should-fail/
# MUST fail to type-check against the kalecky sublibrary. Exits 0 only
# if all files are rejected. (Excluded-source convention — see
# 02-RESEARCH.md: should-not-typecheck conflicts with -Werror.)
set -uo pipefail
cd "$(dirname "$0")/../kalecky-spec"
fail=0
for f in test-kalecky/should-fail/*.hs; do
  out=$(printf ':load %s\n' "$f" | cabal repl kalecky --repl-options=-fno-code -v0 2>&1)
  if printf '%s' "$out" | grep -q "error:"; then
    echo "ok:   $f rejected by the type checker"
  else
    echo "FAIL: $f type-checked — the boundary is broken"
    fail=1
  fi
done
exit $fail
