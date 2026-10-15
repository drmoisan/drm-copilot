# Dependency #405 Present (P0-T4)

Timestamp: 2026-09-30T13-47
Task: [P0-T4]
Location: worktree root
Branch: bug/promotion-gate-lacks-preexisting-issue-branch-exec-509

## 1. Tracked files

Command: git ls-files extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts tests/fixtures/orchestrator_state_promotion_type
EXIT_CODE: 0
Output Summary: 13 tracked paths — the module plus twelve fixtures (required: module plus twelve). Verbatim:

```
extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
tests/fixtures/orchestrator_state_promotion_type/absent-promotion-type-large-feature-tool.json
tests/fixtures/orchestrator_state_promotion_type/bug-epic-no-op.json
tests/fixtures/orchestrator_state_promotion_type/bug-large-bug-tool-declared-and-recorded.json
tests/fixtures/orchestrator_state_promotion_type/bug-large-feature-tool-only.json
tests/fixtures/orchestrator_state_promotion_type/bug-preparation-bug-tool-declared-and-recorded.json
tests/fixtures/orchestrator_state_promotion_type/bug-remediation-no-op.json
tests/fixtures/orchestrator_state_promotion_type/bug-small-bug-tool-declared-and-recorded.json
tests/fixtures/orchestrator_state_promotion_type/capitalized-bug-large-feature-tool.json
tests/fixtures/orchestrator_state_promotion_type/feature-large-feature-tool-declared-and-recorded.json
tests/fixtures/orchestrator_state_promotion_type/leading-space-bug-large-feature-tool.json
tests/fixtures/orchestrator_state_promotion_type/non-string-true-large-feature-tool.json
tests/fixtures/orchestrator_state_promotion_type/null-promotion-type-large-feature-tool.json
```

## 2. Name counts in `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`

Command: grep -c -w -F -e resolvePromotionEntryTools extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 0
Output Summary: `1` (required >= 1)

Command: grep -c -w -F -e FEATURE_PROMOTION_ENTRY_TOOL extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 0
Output Summary: `2` (required >= 1)

Command: grep -c -w -F -e BUG_PROMOTION_ENTRY_TOOL extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 0
Output Summary: `2` (required >= 1)

Command: grep -c -w -F -e BUG_PROMOTION_TYPE extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 0
Output Summary: `2` (required >= 1)

Command: grep -c -w -F -e PROMOTION_TYPE_KEY extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 0
Output Summary: `2` (required >= 1)

## 3. Routing-file call count

Command: grep -c -F -e "resolvePromotionEntryTools(" extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts
EXIT_CODE: 0
Output Summary: `1` (required exactly 1)

## 4. Three-dot name listing (branch-local changes to the #405 paths)

Command: git diff --name-only origin/epic/orchestrator-state-contract-correctness-integration...HEAD -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts extensions/drm-copilot/jest.config.cjs tests/fixtures/orchestrator_state_promotion_type
EXIT_CODE: 0
Output Summary: empty listing (required empty). The #405 files arrived through the integration base, not through a branch-local commit.

## 5. Porcelain listing for the #405 paths

Command: git status --porcelain -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts extensions/drm-copilot/jest.config.cjs tests/fixtures/orchestrator_state_promotion_type
EXIT_CODE: 0
Output Summary: empty listing (required empty). No uncommitted local copy stands in for the #405 files.

## Supplementary check (micro-action)

Command: git merge-base --is-ancestor 3f7c709c HEAD
EXIT_CODE: 0
Output Summary: the #405 merge commit `3f7c709c` (PR #800) is an ancestor of HEAD, consistent with orchestrator decision 2.

Result: all checks pass. No BLOCKED signal.
