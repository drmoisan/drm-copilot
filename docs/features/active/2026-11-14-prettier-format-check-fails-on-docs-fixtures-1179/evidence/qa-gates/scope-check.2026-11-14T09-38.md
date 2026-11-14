# Scope check (P2-T5)

Timestamp: 2026-11-14T09-38
Command: git diff --name-only origin/main...HEAD (merge-base form of origin/main and HEAD) ; git status --porcelain
EXIT_CODE: 0
Output Summary: Paths changed on the branch relative to the merge base:
- .github/workflows/_root-typescript-tests.yml
- tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json
- tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json
- tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json
- docs/features/active/2026-11-14-prettier-format-check-fails-on-docs-fixtures-1179/** (issue, spec, research, plan, evidence)
- docs/features/potential/promoted/2026-11-14-prettier-format-check-fails-on-docs-fixtures.md (promotion lifecycle record created by the promotion step before execution; not authored by this execution)
No additional file recorded in P1-T3 (none flagged). Absent from the list: .prettierignore, .github/workflows/ci.yml, package.json, any Prettier configuration. No .py file added. porcelain at check time: only the uncommitted plan checkbox edits and the new Phase 2 evidence files under FEATURE/.
