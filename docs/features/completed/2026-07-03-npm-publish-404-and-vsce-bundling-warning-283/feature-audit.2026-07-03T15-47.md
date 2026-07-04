# Feature Audit: VS Code Extension Bundling Fix (Issue #283)

---

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283`
**Base Branch:** `main` (merge-base `9549ec3d102ff3ea1ee40120feebe863b810c4da`)
**Head Branch:** `drm-copilot-wt-2026-07-03-11-04` @ `d218ba078a70f64be3dab6a7c4f8349281cb96d0`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `9549ec3d102ff3ea1ee40120feebe863b810c4da`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-03-11-04` (commit `d218ba078a70f64be3dab6a7c4f8349281cb96d0`)
- **Merge base:** `9549ec3d102ff3ea1ee40120feebe863b810c4da`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/evidence/**`
  - Additional evidence: independent re-execution of `prettier --check`, `eslint`, `tsc --noEmit`, `npm run compile`, `npm run test -- --coverage`, and `npx @vscode/vsce ls` against the current branch head; direct parse of `extensions/drm-copilot/coverage/lcov.info`.
- **Feature folder used:** `docs/features/active/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283` (single active folder matching issue `#283`; no versioned subfolder present).
- **Requirements source:** `issue.md` only, per the persisted `- Work Mode: minor-audit` marker.
- **Work mode resolution note:** `issue.md` line 12 explicitly declares `- Work Mode: minor-audit`, which was used as the single source of truth per `acceptance-criteria-tracking`. The `## Acceptance Criteria` section is present in `issue.md` (lines 72-81) as required for `minor-audit`.
- **Scope note:** The diff also includes a human-exception runbook (`runbooks/npm-token-rotation.runbook.md`) covering Expected Behavior item 1 of `issue.md` (npm `E404` publish failure). That item is explicitly marked out of scope for the Acceptance Criteria set in `issue.md`'s own scope note and is not evaluated as an AC item here; it is addressed procedurally by the runbook, which is contract-conformant with `.claude/skills/human-exception-runbook/SKILL.md` (all five required sections present: Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/issue.md` — only source (`minor-audit` work mode)

### Acceptance criteria

1. `extensions/drm-copilot/esbuild-extension.cjs` exists and bundles `src/extension.ts` into `out/extension.js` via esbuild with `bundle: true`, `platform: "node"`, `target: "node18"`, and `external: ["vscode"]`.
2. `extensions/drm-copilot/package.json` `compile` and `build` scripts run `tsc -p ./ --noEmit` for type-checking, then `npm run bundle:extension` (new script wrapping `node esbuild-extension.cjs`), then the existing `npm run bundle:mcp-server`, and no longer invoke `tsc -p ./` in emit mode.
3. Running `npm --prefix extensions/drm-copilot run compile` succeeds and produces `extensions/drm-copilot/out/extension.js` and `extensions/drm-copilot/out/mcp-server.js`, with the total `.js` file count under `extensions/drm-copilot/out/` reduced from 128 to a documented small number, eliminating the "128 JavaScript files... bundle your extension" `vsce package` warning.
4. No file under `extensions/drm-copilot/test/**`, `extensions/drm-copilot/jest.config.cjs`, `.github/workflows/publish-extension.yml`, or `extensions/drm-copilot/.vscodeignore` depends on the previous one-file-per-source-file `out/*.js` layout; any dependency found during verification is updated as part of this fix.
5. `.github/workflows/publish-mcp-npm.yml` and all other workflow files remain unmodified by this fix.
6. The full TypeScript toolchain (format, lint, type-check, existing unit tests) passes cleanly after the change, per `.claude/rules/typescript.md` and `.claude/rules/general-code-change.md`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `esbuild-extension.cjs` exists with the specified esbuild config | PASS | `extensions/drm-copilot/esbuild-extension.cjs` (new, 22 lines) contains exactly `entryPoints: ["src/extension.ts"]`, `bundle: true`, `platform: "node"`, `target: "node18"`, `outfile: "out/extension.js"`, `allowOverwrite: true`, `external: ["vscode"]`. Confirmed by direct file read and by `git diff`. | `git diff 9549ec3d..HEAD -- extensions/drm-copilot/esbuild-extension.cjs` | Also independently ran `node esbuild-extension.cjs` and confirmed `out/extension.js` is produced and that `vscode` is correctly left unresolved at runtime (`node -e "require('./out/extension.js')"` throws `Cannot find module 'vscode'`, the expected/correct behavior outside the extension host). |
| 2 | `package.json` `compile`/`build` scripts rewired as specified | PASS | `package.json` `scripts` block: `"compile": "tsc -p ./ --noEmit && npm run bundle:extension && npm run bundle:mcp-server"`, `"build": "tsc -p ./ --noEmit && npm run bundle:extension && npm run bundle:mcp-server"`, `"bundle:extension": "node esbuild-extension.cjs"` — exact match to the criterion text. | `git diff 9549ec3d..HEAD -- extensions/drm-copilot/package.json` | Confirmed neither script invokes `tsc -p ./` in emit mode. |
| 3 | Compile succeeds, produces both bundle files, JS count reduced from 128 | PASS | Independently ran `npm run compile` (exit 0) then `find out -name "*.js" \| wc -l` = 2 (`out/extension.js`, `out/mcp-server.js`). Baseline of 128 independently corroborated via `evidence/baseline/baseline-compile-jscount.2026-07-03T15-27.md`. Independently ran `npx @vscode/vsce ls` (395 total packaged files, only 2 `.js` bundle outputs plus 1 `.cjs` script — well below the threshold that produced the original warning). | `npm --prefix extensions/drm-copilot run compile`; `find extensions/drm-copilot/out -name "*.js" \| wc -l`; `npx --yes @vscode/vsce ls` | The exact numeric warning threshold in `@vscode/vsce`'s internal logic was not independently re-derived, but the packaged-file evidence (2 real JS bundle files vs. the prior 128) is conclusive that the defect condition no longer holds. |
| 4 | No dependency on old `out/*.js` per-file layout in test/jest-config/workflow/vscodeignore | PASS | `evidence/other/out-layout-dependency-check.2026-07-03T15-27.md` documents grep results for all four locations: none found. Independently re-verified: `grep -rn -E "out/[a-zA-Z0-9_-]+\.js" extensions/drm-copilot/test` (no matches), `jest.config.cjs`'s `testPathIgnorePatterns` excludes `/out/` at the directory level, `.github/workflows/publish-extension.yml` has no `out/`-path references, `.vscodeignore` has no per-file `out/<name>.js` reference. | `Grep pattern="out/[a-zA-Z0-9_-]+\.js" path="extensions/drm-copilot/test"`; manual read of `jest.config.cjs`, `.github/workflows/publish-extension.yml`, `.vscodeignore` | Note (documented separately, not a violation of this specific criterion): `.vscodeignore` does not exclude the *new* `esbuild-extension.cjs` file from packaging, unlike its sibling `esbuild-mcp-server.cjs`. This is a completeness/consistency gap, not a dependency on the old per-file layout, so it does not affect this criterion's PASS status; it is recorded as a Minor code-review finding instead. |
| 5 | Workflow files unmodified | PASS | `git diff --name-only 9549ec3d..HEAD -- .github/workflows/` returns no output (independently re-run and confirmed empty). Matches `evidence/qa-gates/qc-workflow-untouched.2026-07-03T15-27.md`. | `git diff --name-only 9549ec3d102ff3ea1ee40120feebe863b810c4da..HEAD -- .github/workflows/` | Full branch diff (`git diff --stat`) independently confirms only `docs/features/active/.../**` and 3 files under `extensions/drm-copilot/` changed — no workflow files anywhere in the diff. |
| 6 | Full TypeScript toolchain passes cleanly | PASS | Independently re-ran all four stages against the current branch head: `npx prettier --check` (all files formatted), `npx eslint --no-error-on-unmatched-pattern src test` (0 errors/warnings), `npx tsc -p ./ --noEmit` (0 diagnostics), `npm run test -- --coverage` (122/122 suites, 1469/1469 tests, 96.88%/88.27% coverage, identical to the pre-change baseline — no regression). | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`; `npx eslint --no-error-on-unmatched-pattern src test`; `npx tsc -p ./ --noEmit`; `npm run test -- --coverage` | All four stages passed in a single clean pass with no auto-fixes required, matching the executor's recorded evidence exactly. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 6 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. All six acceptance criteria are independently verified with reproducible, current-branch-head evidence.

**Recommended follow-up verification steps:**

1. Optional, non-blocking: update `.vscodeignore` to also exclude `esbuild-extension.cjs` (consistency with `esbuild-mcp-server.cjs`'s existing exclusion) and refresh the stale header comment in `esbuild-mcp-server.cjs` describing the superseded `out/mcp-server.js` entry point. See `code-review.2026-07-03T15-47.md` findings CR-1 and CR-2.
2. Out of this feature's scope (already documented as such in `issue.md`): complete the human-exception runbook at `runbooks/npm-token-rotation.runbook.md` to resolve the separate npm `E404` publish failure, which requires manual `NPM_TOKEN` credential rotation outside repository automation.

---

## Acceptance Criteria Check-Off

All six criteria in `issue.md`'s `## Acceptance Criteria` section were already checked (`- [x]`) at the time of this review, and this audit's independent verification confirms each check-off is supported by evidence (Section "Acceptance Criteria Evaluation" above). No further check-off action was required in `issue.md`.

### AC Status Summary

- Source: `docs/features/active/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/issue.md` | 6 | 6 | 0 | Checkbox-backed; all 6 items were already `- [x]` prior to this review and are independently confirmed PASS with reproduced evidence. |
