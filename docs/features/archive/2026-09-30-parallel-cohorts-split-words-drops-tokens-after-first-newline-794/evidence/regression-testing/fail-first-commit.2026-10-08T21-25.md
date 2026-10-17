# Fail-first commit (P1-T7)

Timestamp: 2026-10-09T07-04
Command: git add tests/shell/parallel_cohorts.bats ; git commit -m "test(794): add separator-parity rows (expect-fail)" -- tests/shell/parallel_cohorts.bats ; git rev-parse HEAD ; git diff --name-only HEAD~1 HEAD ; git status --porcelain -- tests/shell/parallel_cohorts.bats .claude/lib/bash/parallel-cohorts.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh
EXIT_CODE: 0
Output Summary: tests-only commit created; TEST_SHA is 36795b64b4daf8e84d3d6e8e8a1fb8e239a395ed; name-only diff lists exactly tests/shell/parallel_cohorts.bats; porcelain output empty.

TEST_SHA: 36795b64b4daf8e84d3d6e8e8a1fb8e239a395ed
git diff --name-only HEAD~1 HEAD: tests/shell/parallel_cohorts.bats
git status --porcelain (three code paths): (empty)

Note: the operator-required Co-Authored-By trailer was appended after the fixed subject line.
