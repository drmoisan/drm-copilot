# Remediation Plan — Pack-Manifest Completeness (Issue #334)

- Cycle: 2
- Entry timestamp: 2026-07-09T15-57
- Source: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/remediation-inputs.2026-07-09T15-57.md`
- Scope: register three already-bundled `.claude` files in the `paths` array of
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
  No `.claude/**` source file, no bundled `.claude` payload file, and no test file
  (including the `PRE_EXISTING_UNRELATED_EXCEPTIONS` set) is modified.

## Blocking Finding Addressed

- Failing test: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
- Check that would fail in CI: `drm-copilot-extension-tests` (required).
- Root cause: three bundled files are present on disk under
  `extensions/drm-copilot/resources/claude-customizations/.claude/` but are not
  referenced by any `pack-manifests/*.json` `paths` array, so
  `computePublishedPaths()` would silently drop them from a manifest-scoped
  push-down:
  - `.claude/hooks/persist-session-id.ps1`
  - `.claude/skills/identify-session-id/SKILL.md`
  - `.claude/skills/show-my-agent-tree/SKILL.md`

## Target File and Ordering Convention

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
lists `.claude`-relative paths as one string per line, 2-space indented, one
trailing comma per entry except the last, grouped by top-level directory
(`agents/`, then `hooks/`, then `rules/`, then `skills/`, then `lib/`) and
alphabetically ordered by filename within each `hooks/` and `skills/` group.
Verified current neighbors (as of this file's baseline read):

- Hooks group: `.claude/hooks/enforce-promotion-mcp-only.ps1` immediately
  precedes `.claude/hooks/validate-bash.ps1`. `persist-session-id.ps1` sorts
  alphabetically between them (`enforce-` < `persist-` < `validate-`).
- Skills group: `.claude/skills/human-exception-runbook/SKILL.md` immediately
  precedes `.claude/skills/make-skill-template/SKILL.md`.
  `identify-session-id/SKILL.md` sorts alphabetically between them
  (`human-` < `identify-` < `make-`).
- Skills group: `.claude/skills/review-staged/SKILL.md` immediately precedes
  `.claude/skills/skill-canonical-location-audit/SKILL.md`.
  `show-my-agent-tree/SKILL.md` sorts alphabetically between them
  (`review-` < `show-` < `skill-`).

---

### Phase 0 — Baseline Capture and Policy Read

- [x] [P0-T1] Read `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, and `.claude/rules/typescript-suppressions.md` in that order (repo root has no `CLAUDE.md`, confirmed in the Cycle 1 Phase 0 read at `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/phase0-instructions-read.md`), then write `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/phase0-instructions-read.2026-07-09T15-57.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of the four files read. Acceptance: the file exists with both fields populated and all four file paths listed in the stated order.
- [x] [P0-T2] `[expect-fail]` From `extensions/drm-copilot`, run `npm run test -- --testPathPattern claude-pack-manifest-completeness` and write the fail-before result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/regression-testing/fail-before-manifest-completeness.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the three missing paths reported by the `missing` array assertion. Acceptance: `EXIT_CODE` is non-zero and the `Output Summary` lists the three paths from the Blocking Finding section above as the reported `missing` entries.
- [x] [P0-T3] From `extensions/drm-copilot`, run `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/ts-format-baseline.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists with all four fields populated and `EXIT_CODE` recorded exactly as returned.
- [x] [P0-T4] From `extensions/drm-copilot`, run `npm run lint` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/ts-lint-baseline.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists with all four fields populated and `EXIT_CODE` recorded exactly as returned.
- [x] [P0-T5] From `extensions/drm-copilot`, run `npm run typecheck` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/ts-typecheck-baseline.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists with all four fields populated and `EXIT_CODE` recorded exactly as returned.
- [x] [P0-T6] From `extensions/drm-copilot`, run `npm run test:coverage` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/ts-jest-coverage-baseline.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the numeric total statement/line coverage percent, the numeric total branch coverage percent, the total pass/fail test counts, and a note identifying `claude-pack-manifest-completeness.test.ts` as the one known failing suite (per P0-T2). Acceptance: the artifact exists with all four fields populated, both numeric coverage values are present (not placeholders), and the one expected failing suite is identified by name.
- [x] [P0-T7] From `extensions/drm-copilot`, run `node -e "console.log(JSON.parse(require('fs').readFileSync('resources/claude-customizations/pack-manifests/core.json','utf8')).paths.length)"` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/core-json-paths-count-baseline.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the printed integer count. Acceptance: `EXIT_CODE` is `0` and the `Output Summary` states the exact integer printed.
- [x] [P0-T8] From the repository root, run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/python-contract-test-baseline.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the pass count. Acceptance: `EXIT_CODE` is `0` and every test in the file is reported as passed, confirming the Python `.claude` byte-parity contract test is unaffected by this remediation's scope before any change is made.

### Phase 1 — Register the Three Bundled Paths in `core.json`

- [x] [P1-T1] In `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, insert the line `".claude/hooks/persist-session-id.ps1",` immediately after the `".claude/hooks/enforce-promotion-mcp-only.ps1",` line and immediately before the `".claude/hooks/validate-bash.ps1",` line, matching the file's existing 2-space indentation and trailing-comma style exactly. Do not modify any other line. Acceptance: the file contains the new line at that exact position and no other line in the file differs from its prior content.
- [x] [P1-T2] In `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, insert the line `".claude/skills/identify-session-id/SKILL.md",` immediately after the `".claude/skills/human-exception-runbook/SKILL.md",` line and immediately before the `".claude/skills/make-skill-template/SKILL.md",` line, matching the file's existing 2-space indentation and trailing-comma style exactly. Do not modify any other line. Acceptance: the file contains the new line at that exact position and no other line in the file differs from its prior content (other than the P1-T1 insertion).
- [x] [P1-T3] In `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, insert the line `".claude/skills/show-my-agent-tree/SKILL.md",` immediately after the `".claude/skills/review-staged/SKILL.md",` line and immediately before the `".claude/skills/skill-canonical-location-audit/SKILL.md",` line, matching the file's existing 2-space indentation and trailing-comma style exactly. Do not modify any other line. Acceptance: the file contains the new line at that exact position and no other line in the file differs from its prior content (other than the P1-T1 and P1-T2 insertions).
- [x] [P1-T4] From `extensions/drm-copilot`, run `node -e "const p=JSON.parse(require('fs').readFileSync('resources/claude-customizations/pack-manifests/core.json','utf8'));console.log(p.paths.length, new Set(p.paths).size, p.paths.includes('.claude/hooks/persist-session-id.ps1'), p.paths.includes('.claude/skills/identify-session-id/SKILL.md'), p.paths.includes('.claude/skills/show-my-agent-tree/SKILL.md'))"` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/other/core-json-post-edit-validation.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the printed array length, the printed unique-entry count, and the three printed boolean membership checks. Acceptance: `EXIT_CODE` is `0`, the printed array length equals the P0-T7 baseline count plus `3`, the printed unique-entry count equals the printed array length (no duplicates introduced), and all three printed booleans are `true`.

### Phase 2 — Verification and Final QA Loop

- [x] [P2-T1] From `extensions/drm-copilot`, run `npm run test -- --testPathPattern claude-pack-manifest-completeness` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/remediation-targeted-test.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE` is `0` and both `it` blocks in the suite are reported as passed.
- [x] [P2-T2] From `extensions/drm-copilot`, run `npm run format` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-format.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating whether any file was reformatted. If any file was reformatted, restart this Phase 2 loop from P2-T2 after the reformat. Acceptance: a final recorded run has `EXIT_CODE` `0` and reports zero files reformatted.
- [x] [P2-T3] From `extensions/drm-copilot`, run `npm run lint` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-lint.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If this step reports any error, restart this Phase 2 loop from P2-T2. Acceptance: a final recorded run has `EXIT_CODE` `0` and zero lint errors.
- [x] [P2-T4] From `extensions/drm-copilot`, run `npm run typecheck` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-typecheck.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If this step reports any type error, restart this Phase 2 loop from P2-T2. Acceptance: a final recorded run has `EXIT_CODE` `0` and zero type errors.
- [x] [P2-T5] From `extensions/drm-copilot`, run `npm run test:coverage` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-jest-coverage.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the total pass/fail test counts, the numeric total statement/line coverage percent, and the numeric total branch coverage percent, and confirming `claude-pack-manifest-completeness.test.ts` is now reported as fully passed. If any test fails, restart this Phase 2 loop from P2-T2. Acceptance: a final recorded run has `EXIT_CODE` `0`, all test suites pass, and both numeric coverage values are present.
- [x] [P2-T6] Compare the baseline coverage from `evidence/baseline/ts-jest-coverage-baseline.2026-07-09T15-57.md` (P0-T6) against the final coverage from `evidence/qa-gates/final-ts-jest-coverage.2026-07-09T15-57.md` (P2-T5) and write the comparison to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T15-57.md` with `Timestamp:`, the baseline statement/line and branch percentages, the final statement/line and branch percentages, and an explicit note that zero `.ts` production or test lines were changed in this remediation (only `pack-manifests/core.json`, a JSON data file, was edited), so a changed-code coverage figure is not applicable. Acceptance: the artifact records both numeric coverage pairs and shows no regression (final >= baseline for both statement/line and branch percentages).
- [x] [P2-T7] Confirm the Phase 2 toolchain loop (P2-T2 through P2-T5) completed in a single clean pass with zero restarts; record this confirmation, or the restart count and the evidence filenames of each restart iteration if any occurred, in `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-jest-coverage.2026-07-09T15-57.md`'s `Output Summary:` field. Acceptance: the restart count is explicitly stated as an integer (0 or greater).
- [x] [P2-T8] From the repository root, run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-python-contract-test.2026-07-09T15-57.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the pass count. Acceptance: `EXIT_CODE` is `0` and every test in the file is reported as passed, confirming the `core.json` manifest edit produced no regression in the `.claude` byte-parity contract test.

---

## Verification Summary (restated from remediation inputs)

- `cd extensions/drm-copilot && npm run test` passes (Jest, including `claude-pack-manifest-completeness`) — covered by P2-T5.
- Full TypeScript toolchain (format -> lint -> type-check -> test) clean — covered by P2-T2 through P2-T5.
- Full Python toolchain remains clean (no manifest impact on `.claude` parity) — covered by P0-T8 (before) and P2-T8 (after).
- Re-run of the CI gate (S9) against the new PR head SHA is outside the scope of local plan execution; it is performed by downstream review/PR workflow steps once this remediation is committed and pushed, not by an atomic-executor task in this plan.
