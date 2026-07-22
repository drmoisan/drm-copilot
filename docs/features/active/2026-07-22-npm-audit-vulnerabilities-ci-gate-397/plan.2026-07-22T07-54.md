# 2026-07-22-npm-audit-vulnerabilities-ci-gate-397 (Plan)

- **Issue:** #397
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-22T07-54
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Inputs:** `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md` (Approved, v0.2); `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/research/2026-07-22-npm-audit-fix-strategy.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

**Evidence location invariant:** All evidence artifacts produced while executing this plan MUST be written under `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/<kind>/`. No task in this plan names an `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/` path; any such instruction from an upstream caller must be rejected and replaced with the canonical path, recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.

**Scope reminder:** Exactly 6 files are in scope: `package.json` + `package-lock.json` in each of `.` (root), `extensions/drm-copilot/`, `packages/mcp-server/`. No source code changes. No workflow file changes. `@modelcontextprotocol/sdk` stays at `^1.29.0` everywhere. No `npm audit fix --force` anywhere.

### Phase 0 — Context, Policy Reads & Baseline Capture

- [x] [P0-T1] Confirm `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md` header shows `Status: Approved`; record the confirmation (file path + status line quoted) in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/phase0-instructions-read.md`.
- [x] [P0-T2] Read the required policy files in order — `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md` — and append the exact ordered file list plus a `Timestamp:` and `Policy Order:` field to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/phase0-instructions-read.md`.
- [x] [P0-T3] Capture the current git baseline: run `git status --porcelain` and `git rev-parse HEAD` and `git diff --stat -- package.json package-lock.json` at the repo root; write `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (branch name — expected `bug/npm-audit-vulnerabilities-ci-gate-397` — HEAD SHA, and confirmation that `package.json`/`package-lock.json` in all 3 manifests are clean/unmodified prior to Phase 1; the separate local `chore/npm-upgrade` branch is stale and unrelated to this fix and must not be merged with or reverted onto this branch) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/git-status-baseline.<timestamp>.md`.
- [x] [P0-T4] [expect-fail] Run `npm ci && npm audit --audit-level=moderate` in `.` (root) and confirm it exits non-zero; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (advisory count/severity from the audit report) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/npm-audit-baseline-root.<timestamp>.md`.
- [x] [P0-T5] [expect-fail] Run `npm ci && npm audit --audit-level=moderate` in `extensions/drm-copilot/` and confirm it exits non-zero; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/npm-audit-baseline-extensions.<timestamp>.md`.
- [x] [P0-T6] [expect-fail] Run `npm ci && npm audit --audit-level=moderate` in `packages/mcp-server/` and confirm it exits non-zero; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/npm-audit-baseline-mcp-server.<timestamp>.md`.
- [x] [P0-T7] Run `npm run compile` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/compile-baseline-root.<timestamp>.md`.
- [x] [P0-T8] Run `npm run test:unit` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-unit-baseline-root.<timestamp>.md`.
- [x] [P0-T9] Run `npm run test:unit:coverage` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the numeric line-coverage and branch-coverage percentages to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-coverage-baseline-root.<timestamp>.md`.
- [x] [P0-T10] Run `npm run compile` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/compile-baseline-extensions.<timestamp>.md`.
- [x] [P0-T11] Run `npm run test:unit` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-unit-baseline-extensions.<timestamp>.md`.
- [x] [P0-T12] Run `npm run test:coverage` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the numeric line-coverage and branch-coverage percentages to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-coverage-baseline-extensions.<timestamp>.md`.
- [x] [P0-T13] Run `npm run build` in `packages/mcp-server/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/build-baseline-mcp-server.<timestamp>.md`. Note in the artifact that `packages/mcp-server/package.json` defines no `test`/`test:unit` script, so no coverage baseline applies to this manifest.
- [x] [P0-T14] Perform a manual stdio smoke check of the current `packages/mcp-server/out/mcp-server.js` build: start the process, send a single MCP `initialize` JSON-RPC request over stdin, confirm a well-formed JSON-RPC response is received on stdout, then terminate the process; write `Timestamp:`, `Command:`, `EXIT_CODE:` (process exit/termination status), `Output Summary:` (whether a valid response was observed) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/stdio-smoke-baseline-mcp-server.<timestamp>.md`.

### Phase 1 — `package.json` Overrides Edit (root, `.`)

- [x] [P1-T1] In `package.json` (root), add `"@hono/node-server": "^2.0.5"` as a new key inside the existing `overrides` object; acceptance criterion: `grep -n "@hono/node-server" package.json` shows the added line with value `^2.0.5`.
- [x] [P1-T2] In `package.json` (root), change the existing `overrides.fast-uri` value from `^3.1.2` to `^3.1.4`; acceptance criterion: `grep -n "\"fast-uri\"" package.json` shows `^3.1.4`.
- [x] [P1-T3] In `package.json` (root), change the existing `overrides.hono` value from `^4.12.25` to `^4.12.27`; acceptance criterion: `grep -n "\"hono\"" package.json` shows `^4.12.27`.
- [x] [P1-T4] In `package.json` (root), change the existing `overrides.c8.brace-expansion` value from `^5.0.6` to `^5.0.7`; acceptance criterion: reading the `c8` block in `package.json` shows `"brace-expansion": "^5.0.7"`. Do not modify the `overrides.dependencies` entry for `@modelcontextprotocol/sdk` (it does not exist in this file — the SDK is a plain `dependencies` entry pinned at `^1.29.0` and must remain unchanged).

### Phase 2 — `package.json` Overrides Edit (`extensions/drm-copilot/`)

- [x] [P2-T1] In `extensions/drm-copilot/package.json`, add `"@hono/node-server": "^2.0.5"` as a new key inside the existing `overrides` object; acceptance criterion: `grep -n "@hono/node-server" extensions/drm-copilot/package.json` shows the added line with value `^2.0.5`.
- [x] [P2-T2] In `extensions/drm-copilot/package.json`, change the existing `overrides.fast-uri` value from `^3.1.2` to `^3.1.4`; acceptance criterion: `grep -n "\"fast-uri\"" extensions/drm-copilot/package.json` shows `^3.1.4`.
- [x] [P2-T3] In `extensions/drm-copilot/package.json`, change the existing `overrides.hono` value from `^4.12.25` to `^4.12.27`; acceptance criterion: `grep -n "\"hono\"" extensions/drm-copilot/package.json` shows `^4.12.27`.
- [x] [P2-T4] In `extensions/drm-copilot/package.json`, change the existing `overrides.c8.brace-expansion` value from `^5.0.6` to `^5.0.7`; acceptance criterion: reading the `c8` block in `extensions/drm-copilot/package.json` shows `"brace-expansion": "^5.0.7"`. Do not modify `dependencies["@modelcontextprotocol/sdk"]` (must remain `^1.29.0`).

### Phase 3 — `package.json` Overrides Edit (`packages/mcp-server/`)

- [x] [P3-T1] In `packages/mcp-server/package.json`, add `"@hono/node-server": "^2.0.5"` as a new key inside the existing `overrides` object; acceptance criterion: `grep -n "@hono/node-server" packages/mcp-server/package.json` shows the added line with value `^2.0.5`.
- [x] [P3-T2] In `packages/mcp-server/package.json`, change the existing `overrides.fast-uri` value from `^3.1.2` to `^3.1.4`; acceptance criterion: `grep -n "\"fast-uri\"" packages/mcp-server/package.json` shows `^3.1.4`.
- [x] [P3-T3] In `packages/mcp-server/package.json`, change the existing `overrides.hono` value from `^4.12.25` to `^4.12.27`; acceptance criterion: `grep -n "\"hono\"" packages/mcp-server/package.json` shows `^4.12.27`. Note: this manifest has no `c8`-scoped `brace-expansion` override to raise (confirmed absent in the current file) — do not add one. Do not modify `dependencies["@modelcontextprotocol/sdk"]` (must remain `^1.29.0`).

### Phase 4 — Lock File Regeneration

- [x] [P4-T1] Run `npm install` in `.` (root) to regenerate `package-lock.json` picking up the Phase 1 overrides; acceptance criterion: command exits 0 and `git diff --stat -- package-lock.json` (root) shows the file changed.
- [x] [P4-T2] Run `npm audit fix` (no `--force`) in `.` (root); acceptance criterion: command exits 0 and does not report an `isSemVerMajor` change to `@modelcontextprotocol/sdk`.
- [x] [P4-T3] Run `npm install` in `extensions/drm-copilot/` to regenerate `package-lock.json` picking up the Phase 2 overrides; acceptance criterion: command exits 0 and `git diff --stat -- extensions/drm-copilot/package-lock.json` shows the file changed.
- [x] [P4-T4] Run `npm audit fix` (no `--force`) in `extensions/drm-copilot/`; acceptance criterion: command exits 0 and does not report an `isSemVerMajor` change to `@modelcontextprotocol/sdk`.
- [x] [P4-T5] Run `npm install` in `packages/mcp-server/` to regenerate `package-lock.json` picking up the Phase 3 overrides; acceptance criterion: command exits 0 and `git diff --stat -- packages/mcp-server/package-lock.json` shows the file changed.
- [x] [P4-T6] Run `npm audit fix` (no `--force`) in `packages/mcp-server/`; acceptance criterion: command exits 0 and does not report an `isSemVerMajor` change to `@modelcontextprotocol/sdk`.

Evidence for this phase: write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each of P4-T1..P4-T6 to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/other/lock-regeneration-<manifest>.<timestamp>.md` (one artifact per manifest, covering both its `npm install` and `npm audit fix` steps).

### Phase 5 — Per-Manifest Acceptance Validation

- [x] [P5-T1] Run `npm ci && npm audit --audit-level=moderate` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-root.<timestamp>.md`.
- [x] [P5-T2] Run `npm ci && npm audit --audit-level=moderate` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-extensions.<timestamp>.md`.
- [x] [P5-T3] Run `npm ci && npm audit --audit-level=moderate` in `packages/mcp-server/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-mcp-server.<timestamp>.md`.
- [x] [P5-T4] Confirm `dependencies["@modelcontextprotocol/sdk"]` in `package.json` (root) is still `^1.29.0` and the resolved version recorded for `@modelcontextprotocol/sdk` in `package-lock.json` (root) is still `1.29.0` (not `1.24.3`); record the grep/read result inline in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-root.<timestamp>.md`.
- [x] [P5-T5] Confirm `dependencies["@modelcontextprotocol/sdk"]` in `extensions/drm-copilot/package.json` is still `^1.29.0` and the resolved version in `extensions/drm-copilot/package-lock.json` is still `1.29.0`; record the result inline in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-extensions.<timestamp>.md`.
- [x] [P5-T6] Confirm `dependencies["@modelcontextprotocol/sdk"]` in `packages/mcp-server/package.json` is still `^1.29.0` and the resolved version in `packages/mcp-server/package-lock.json` is still `1.29.0`; record the result inline in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-mcp-server.<timestamp>.md`.
- [x] [P5-T7] Run `git status --porcelain` and `git diff --stat` at the repo root and confirm the only modified/tracked files are the 6 in-scope files (`package.json` and `package-lock.json` in `.`, `extensions/drm-copilot/`, `packages/mcp-server/`); write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the exact file list) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/scope-confirmation.<timestamp>.md`.

### Phase 6 — Final QA Loop

- [x] [P6-T1] Write a rationale artifact explaining that toolchain stages 1–3 (Prettier formatting, ESLint linting, `tsc` type-checking) are not applicable as standalone gates for this change because the diff contains only `package.json`/`package-lock.json` (JSON manifest files, not `.ts` sources subject to `npm run format`/`npm run lint`/`npm run typecheck`); the `tsc` compile step is instead exercised indirectly via the `npm run compile` tasks below, which fail if the unchanged TypeScript sources no longer type-check against the refreshed dependency tree. Save to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/toolchain-stage-applicability.md`.
- [x] [P6-T2] Run `npm run compile` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/compile-final-root.<timestamp>.md`.
- [x] [P6-T3] Run `npm run test:unit` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts, matching P0-T8 counts) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-unit-final-root.<timestamp>.md`.
- [x] [P6-T4] Run `npm run test:unit:coverage` in `.` (root) and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the numeric line/branch coverage and an explicit delta comparison against the P0-T9 baseline coverage (expect zero regression since no source lines changed) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-coverage-final-root.<timestamp>.md`.
- [x] [P6-T5] Run `npm run compile` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/compile-final-extensions.<timestamp>.md`.
- [x] [P6-T6] Run `npm run test:unit` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts, matching P0-T11 counts) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-unit-final-extensions.<timestamp>.md`.
- [x] [P6-T7] Run `npm run test:coverage` in `extensions/drm-copilot/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the numeric line/branch coverage and an explicit delta comparison against the P0-T12 baseline coverage (expect zero regression) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-coverage-final-extensions.<timestamp>.md`.
- [x] [P6-T8] Run `npm run build` in `packages/mcp-server/` and confirm it exits 0; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/build-final-mcp-server.<timestamp>.md`.
- [x] [P6-T9] Repeat the manual stdio smoke check from P0-T14 against the rebuilt `packages/mcp-server/out/mcp-server.js`: start the process, send a single MCP `initialize` JSON-RPC request over stdin, confirm a well-formed JSON-RPC response is received on stdout, then terminate the process; write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/stdio-smoke-final-mcp-server.<timestamp>.md`.
- [x] [P6-T10] Run `git status --porcelain` restricted to the 6 in-scope files and confirm Phase 6's QA steps (P6-T2..P6-T9) produced no additional file changes beyond the 6 in-scope manifest files; if any Phase 6 step failed or altered an out-of-scope file, restart the toolchain loop from P6-T1. Write `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/final-qa-loop-integrity.<timestamp>.md`.

### Phase 7 — Documentation & Status

- [x] [P7-T1] Update the `## Acceptance Criteria` checkboxes in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md` to checked, for each criterion whose supporting evidence artifact from Phases 0/5/6 exists and passed; leave any criterion unchecked if its evidence artifact is missing or failed.
- [x] [P7-T2] Post an update comment on GitHub issue #397 summarizing the fix (overrides added/raised in the 3 manifests, lock files regenerated, `NPM Audit Gate` re-validated) and mirror the exact posted text to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/issue-updates/issue-397.<timestamp>.md` with `Timestamp:`, the posted text, `PostedAs: comment`, and the GitHub comment URL. Do not create a new local `issue.md` for this feature folder (none currently exists); the mirror artifact under `evidence/issue-updates/` is sufficient.

### Phase 8 — PR & Handoff

- [ ] [P8-T1] Prepare PR notes summarizing the change (the 6 files touched, the `@hono/node-server` override rationale, the raised override floors, confirmation that `@modelcontextprotocol/sdk` is unchanged, and links to the Phase 5/6 evidence artifacts) and open/update the PR referencing issue #397.
- [ ] [P8-T2] After the PR head SHA has a completed CI run, confirm the `NPM Audit Gate` required check reports a green/success conclusion for all three matrix legs on that SHA; write `Timestamp:`, `Command:` (e.g., `gh run view <run-id>` or equivalent), `EXIT_CODE:`, `Output Summary:` (conclusion per matrix leg) to `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-gate-ci-confirmation.<timestamp>.md`.

### Phase 9 — Rollout & Follow-up

- [x] [P9-T1] Record the residual-risk follow-up note (npm `overrides` do not protect downstream consumers of the published `@danmoisan/drm-copilot-mcp` package; track upstream `modelcontextprotocol/typescript-sdk` for a release that removes/bumps its unused `@hono/node-server`/`hono` dependency, then drop the local overrides) in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/other/follow-up-notes.md`, referencing the spec's `Risks & Mitigations` and `Rollout & Follow-up` sections.
- [x] [P9-T2] Record traceability links (issue #397, the merged/merging PR URL, `spec.md`, and the research artifact path) in `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/other/follow-up-notes.md`.

## Preflight Validation

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

This plan is submitted to `atomic-executor` for preflight-only validation before execution begins. Expected response is one of:
- `PREFLIGHT: ALL CLEAR`
- `PREFLIGHT: REVISIONS REQUIRED` (with a precise delta to apply to this same file, at this same path)

No implementation has been performed by this planning pass.
