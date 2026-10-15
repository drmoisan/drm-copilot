# Handoff notes for issue #405

Timestamp: 2026-09-30T08-01

## Fix summary
- New pure resolver module `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` exporting `resolvePromotionEntryTools(tools, state)` (exact-match `promotion-type === "bug"` substitution).
- One wired call in `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`: the resolved list is computed once and used for both the `required_mcp_tools` equality check and the receipt-presence loop.
- Per-file jest coverage threshold (85 lines, 75 branches) for the new module in `extensions/drm-copilot/jest.config.cjs`.

## Validation performed (artifacts under docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/)
- qa-gates: ts-format.2026-09-30T07-41.md, ts-lint.2026-09-30T07-41.md, ts-typecheck.2026-09-30T07-41.md, ts-coverage.2026-09-30T07-42.md, py-black.2026-09-30T07-42.md, py-ruff.2026-09-30T07-43.md, py-pyright.2026-09-30T07-43.md, py-routing-coverage.2026-09-30T07-43.md, py-pytest-coverage.2026-09-30T07-45.md, ps-format.2026-09-30T07-46.md, ps-analyze.2026-09-30T07-46.md, ps-parity-pass.2026-09-30T07-48.md, ps-test-coverage.2026-09-30T07-56.md, ts-coverage-delta / py-coverage-delta / ps-coverage-delta (2026-09-30T07-56), file-size-gate.2026-09-30T07-57.md, diff-scope.2026-09-30T07-57.md, jest-threshold-entry.2026-09-30T07-38.md.
- regression-testing: ts-parity-expect-fail.2026-09-30T07-35.md, ts-routing-contract-expect-fail.2026-09-30T07-35.md, ts-regression-pass-after.2026-09-30T07-37.md, ts-resolver-unit-tests.2026-09-30T07-37.md, ts-module-purity.2026-09-30T07-39.md, ts-single-resolution.2026-09-30T07-39.md, ts-validate-dir-pass-after.2026-09-30T07-39.md, py-parity-authority-pass.2026-09-30T07-32.md, ps-parity-authority-pass.2026-09-30T07-33.md, bundle-and-authority-unchanged.2026-09-30T07-39.md.
- Results: Jest 3357 passed (baseline 3315); Pytest 5712 passed, 6 skipped (baseline 5697); Pester 6097 passed, 2 failed (baseline 6082 passed, same 2 failed). Coverage did not regress in any language.

## Parity corpus
- Location: `tests/fixtures/orchestrator_state_promotion_type/*.json` (12 files). Three readers: Python `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py`, TypeScript `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts`, Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1`.

## Unchanged surfaces
- No PowerShell production file, Python production file, bundled mirror under `extensions/drm-copilot/resources/`, or hook file changed.

## Known baseline failures (pre-existing, unchanged by this work)
- `enforce-pr-author-skill.ps1` allowed-commands test (`gh pr create --body-file artifacts/pr_body_12.md when context exists`) and the Codex PreToolUse handler integration test. Both driven by ambient checkpoint state; MCP test status is `failure` for that reason.

## Follow-ups (both untouched)
- Issue #509: extend `resolvePromotionEntryTools` for pre-existing-issue evidence.
- Issue #343: `pr_gate`/`ci_gate` parity.

## Open item
- The text of issue #405 was read from `issue.md` only; reconfirm the five issue criteria against the GitHub issue body when `gh` is available.
- Branch note: work is pushed to `bug/ts-validator-promotion-type-parity-gap-405` from the local branch `worktree-agent-aabf208274ce507ac`; origin/main moved from ae7c7779 to 6e6ccd62 during execution (see qa-gates/diff-scope.2026-09-30T07-57.md).
