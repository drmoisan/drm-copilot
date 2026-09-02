# blast-radius-mandate-reads-scripts-vscode-620 (Remediation Plan, cycle 1)

- **Issue:** #620
- **Feature folder:** `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/`
- **Remediation input:** `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/remediation-inputs.2026-09-02T12-02.md`
- **Trigger:** Blocking CI failure on PR #624, head SHA `7e74ed77b68695eae2b8de2a4179fc97c576e655`, required check `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`.
- **Status:** Draft

## Scope

Exactly one production/test change: add `"scripts/vscode/**"` as the eleventh entry of the
`mandate_reads` array in
`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, in the same array
position (immediately after `".agents/skills/**"`) as the already-correct real bundled file
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`. No other file is
touched. `config/blast-radius.json` (repo root) and
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` are already correct
and reviewed; neither is edited by this remediation.

**Documented residual (not remediated, per explicit scope constraint):** the doc comment above
`SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts` (current lines 83-84) reads "`mandate_reads`
carries the ten-entry read-by-mandate exclusion set." After this remediation the array carries eleven
entries. The remediation-inputs directive forbids touching any part of the file beyond the one added
array entry, so this comment is left stale by explicit instruction and is not a defect introduced by
this plan.

**Confirmed non-interaction:** `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`
declares its own independent `MANDATE_READS` constant (does not import `SOURCE_BLAST_RADIUS` from the
fixture file being edited), so this change cannot affect that file's assertions.

**Coverage note:** `extensions/drm-copilot/jest.config.cjs` scopes `collectCoverageFrom` to
`src/**/*.ts` only. This remediation touches exactly one file under `test/`, which is outside that
measurement scope by design (`.claude/rules/general-unit-test.md`: "Configure coverage tooling to
exclude test files... so metrics reflect application code, not tests"). No production source line is
added, changed, or removed, so there is no new/changed executable-code coverage delta for the Coverage
Evidence Contract to gate. No dedicated coverage-capture task is included for that reason; the
non-coverage `test:unit` runs in Phase 0 and Phase 2 fully exercise the changed fixture.

## Remediation Acceptance Criteria (this cycle)

- [x] **AC-R1** — `"scripts/vscode/**"` is the eleventh entry of `mandate_reads` in
  `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, positioned immediately
  after `".agents/skills/**"`.
- [x] **AC-R2** — No file other than `config-carriage.test-helpers.ts` is modified; no line other than the
  one added entry is modified within it.
- [x] **AC-R3** — `test/lib/push-down/claude-config-carriage.test.ts`'s test "keeps SOURCE_BLAST_RADIUS in
  step with the committed bundled blast-radius resource" passes.
- [x] **AC-R4** — `git diff HEAD` for this change touches only the one fixture file and only the one added
  line.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`,
  `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, and
  `.claude/rules/parallel-orchestration.md` (the mandate-read doctrine this remediation touches).
  Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/other/phase0-instructions-read.2026-09-02T12-02.md`
  containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: the
  artifact exists and lists all seven paths above in the order read.

- [x] [P0-T2] [expect-fail] Capture the pre-fix baseline failure of the target test file. Command (run
  from `extensions/drm-copilot`): `npm run test:unit -- test/lib/push-down/claude-config-carriage.test.ts --verbose`.
  Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/remediation-baseline/p0-t2-failing-test-baseline.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE` is nonzero;
  the recorded output contains the single-line token `1 failed, 16 passed, 17 total`, and contains the
  single-line diff token `-     "scripts/vscode/**",` (the exact removed-line text already captured in
  `remediation-inputs.2026-09-02T12-02.md` lines 30-37 from the PR #624 CI run).

- [x] [P0-T3] Capture the baseline format-check state of the fixture file (expected clean, since only
  the array-entry edit is pending). Command (run from `extensions/drm-copilot`):
  `npx prettier --check "test/lib/push-down/config-carriage.test-helpers.ts"`. Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/remediation-baseline/p0-t3-format-baseline.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and the
  output contains the single-line token `All matched files use Prettier code style!`.

- [x] [P0-T4] Capture the baseline lint state of the fixture file. Command (run from
  `extensions/drm-copilot`): `npx eslint --no-error-on-unmatched-pattern test/lib/push-down/config-carriage.test-helpers.ts`.
  Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/remediation-baseline/p0-t4-lint-baseline.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and stdout
  is empty (ESLint's default formatter prints nothing when zero problems are found).

- [x] [P0-T5] Capture the baseline type-check state. Command (run from `extensions/drm-copilot`):
  `npm run typecheck`. Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/remediation-baseline/p0-t5-typecheck-baseline.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and stdout
  is empty (`tsc -p ./ --noEmit` prints nothing on a clean compile).

---

### Phase 1 — Constrained Implementation (the one array-entry edit)

- [x] [P1-T1] Edit `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`:
  replace the two-line block

  ```
      ".claude/agent-memory/**",
      ".agents/skills/**",
  ```

  with

  ```
      ".claude/agent-memory/**",
      ".agents/skills/**",
      "scripts/vscode/**",
  ```

  inside the `mandate_reads` array of the `SOURCE_BLAST_RADIUS` constant, so `"scripts/vscode/**"`
  becomes the array's eleventh element, in the same relative position as the real bundled file. Do not
  modify any other line in this file, and do not modify any other file. Acceptance: the file contains
  the literal line `"scripts/vscode/**",` immediately following the `".agents/skills/**",` line inside
  `mandate_reads`, and every other line in the file is byte-identical to its pre-edit content. Checks
  off **AC-R1** once verified.

- [x] [P1-T2] Confirm the working-tree diff against `HEAD` touches exactly one tracked file. Commands
  (run from repo root): `git diff HEAD --stat` and `git status --porcelain`. Acceptance:
  `git diff HEAD --stat` names exactly one path,
  `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, with a `1 file changed`
  summary line; `git status --porcelain` output is exactly the single line
  ` M extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` (trimmed), with no
  other entries. Contributes to **AC-R2**.

- [x] [P1-T3] Confirm the diff of that one file against `HEAD` adds exactly one line and removes none.
  Command (run from repo root):
  `git diff HEAD -- extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`.
  Acceptance: `EXIT_CODE: 0`; the output contains exactly one `@@` hunk header; exactly one line
  prefixed `+` whose trimmed text is exactly `"scripts/vscode/**",`; and no line prefixed `-`.
  Contributes to **AC-R1** and **AC-R2**.

- [x] [P1-T4] Confirm the real bundled file is unmodified by this remediation (scope constraint: it is
  already correct and must not be touched again). Command (run from repo root):
  `git diff HEAD -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`.
  Acceptance: `EXIT_CODE: 0` and empty output. Contributes to **AC-R2**.

- [x] [P1-T5] Confirm the repo-root config file is unmodified by this remediation. Command (run from
  repo root): `git diff HEAD -- config/blast-radius.json`. Acceptance: `EXIT_CODE: 0` and empty
  output. Contributes to **AC-R2**.

---

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run the final format check (scoped, read-only; no `--write`). Command (run from
  `extensions/drm-copilot`): `npx prettier --check "test/lib/push-down/config-carriage.test-helpers.ts"`.
  Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t1-format-final.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and the
  output contains the single-line token `All matched files use Prettier code style!`. If `EXIT_CODE`
  is nonzero, halt and report; this plan's scope does not authorize any edit beyond the one line added
  in P1-T1.

- [x] [P2-T2] Run the final lint check (scoped, read-only). Command (run from `extensions/drm-copilot`):
  `npx eslint --no-error-on-unmatched-pattern test/lib/push-down/config-carriage.test-helpers.ts`.
  Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t2-lint-final.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and stdout
  is empty. If this step fails, restart Phase 2 from P2-T1.

- [x] [P2-T3] Run the final type-check. Command (run from `extensions/drm-copilot`): `npm run typecheck`.
  Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t3-typecheck-final.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and
  stdout is empty. If this step fails, restart Phase 2 from P2-T1.

- [x] [P2-T4] Run the specific previously-failing test file and confirm it now passes (directive
  verification requirement). Command (run from `extensions/drm-copilot`):
  `npm run test:unit -- test/lib/push-down/claude-config-carriage.test.ts --verbose`. Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t4-target-test-final.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0`; the
  recorded output contains the verbose per-test line
  `✓ keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource` under the
  `issue #462 AC6: the Claude push-down publishes the config tree` describe block, and the single-line
  summary token `Tests:       17 passed, 17 total`. If this step fails, restart Phase 2 from P2-T1.
  Checks off **AC-R3** once verified.

- [x] [P2-T5] Re-confirm, after all preceding Phase 2 steps (all read-only: no `--write`, no `--fix`,
  no `--noEmit`-violating writes, no Jest snapshot update), that the working-tree diff against `HEAD`
  still touches exactly one file and exactly one added line. Commands (run from repo root):
  `git diff HEAD --stat`, `git status --porcelain`, and
  `git diff HEAD -- extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`. Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t5-diff-scope-final.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `git diff HEAD --stat`
  names exactly one path (the fixture file) with a `1 file changed` summary line; `git status --porcelain`
  is exactly the single line
  ` M extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`; the scoped
  `git diff HEAD --` output contains exactly one `@@` hunk header and exactly one line prefixed `+`
  whose trimmed text is exactly `"scripts/vscode/**",`, with no line prefixed `-`. Checks off
  **AC-R4** once verified.

- [x] [P2-T6] Run the full extension unit-test suite as a regression check (no other test file was
  found to reference `SOURCE_BLAST_RADIUS`; this confirms that empirically rather than by citation
  alone). Command (run from `extensions/drm-copilot`): `npm run test:unit`. Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t6-full-suite-regression.2026-09-02T12-02.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (record the `Test Suites:` and
  `Tests:` summary lines verbatim). Acceptance: `EXIT_CODE: 0` (Jest returns nonzero on any failing
  test; a zero exit is a complete pass signal for the whole suite). If this step fails, restart Phase 2
  from P2-T1.

- [x] [P2-T7] Compare the Phase 0 baseline results (P0-T2 through P0-T5) against the Phase 2 final
  results (P2-T1 through P2-T4, P2-T6) and confirm the only change in outcome is the target test's
  result. Write
  `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t7-regression-delta.2026-09-02T12-02.md`
  recording, side by side: P0-T2 `EXIT_CODE` (nonzero) vs. P2-T4 `EXIT_CODE` (0); P0-T3 vs. P2-T1
  (both 0); P0-T4 vs. P2-T2 (both 0); P0-T5 vs. P2-T3 (both 0); and P2-T6's `EXIT_CODE` (0).
  Acceptance: the artifact records all six referenced `EXIT_CODE` values and states explicitly that no
  regression was introduced and that the target test is the only outcome that changed.

---

## Evidence Location

All evidence artifacts for this remediation cycle are written under
`docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/{other,remediation-baseline,qa-gates}/`,
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/baselines/`,
`artifacts/qa/`, or similar non-canonical path is used.

---

## Planner Self-Review

`SELF-REVIEW: RE-DERIVED THIS PASS`

- `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` lines 98-109 — read in
  this pass; confirms the current `mandate_reads` array carries ten entries ending at
  `".agents/skills/**",` on line 108, immediately before the closing `],` on line 109, with no
  `"scripts/vscode/**"` entry present.
- `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` lines 12-24 — read
  in this pass; confirms the real bundled file's `mandate_reads` array carries eleven entries, with
  `"scripts/vscode/**"` as the final (eleventh) entry on line 23, immediately after
  `".agents/skills/**"` on line 22.
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` lines 110-134 — read in
  this pass; confirms the test "keeps SOURCE_BLAST_RADIUS in step with the committed bundled
  blast-radius resource" performs a structural `toEqual` comparison between `JSON.parse(SOURCE_BLAST_RADIUS)`
  and the parsed real bundled file, which is the mechanism the CI failure in
  `remediation-inputs.2026-09-02T12-02.md` reports as failing.
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` — grep count of `it(`
  occurrences re-derived in this pass: 17 total, confirming the `Tests:  17 passed, 17 total` /
  `Tests:  1 failed, 16 passed, 17 total` literals asserted in P0-T2 and P2-T4.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` lines 110-120, 421-472 — read
  in this pass; confirms this file declares its own independent `MANDATE_READS` constant and does not
  import `SOURCE_BLAST_RADIUS` from `config-carriage.test-helpers.ts`, so it cannot be affected by this
  edit.
- `extensions/drm-copilot/package.json` lines 202-213 — read in this pass; confirms the `format`,
  `lint`, `typecheck`, `test`, `test:unit`, and `test:coverage` script definitions cited by Phase 0 and
  Phase 2 tasks.
- `extensions/drm-copilot/jest.config.cjs` lines 1-19 — read in this pass; confirms `collectCoverageFrom`
  is scoped to `src/**/*.ts` only, supporting the Scope section's coverage-note rationale.
- `extensions/drm-copilot/run-jest.cjs` — read in this pass; confirms `npm run test:unit -- <args>`
  forwards a bare positional test-path argument to Jest as a `testPathPatterns` match, and rejects only
  the three named prohibited flags, none of which appear in any task command in this plan.
- `extensions/drm-copilot/eslint.config.mjs` — existence re-confirmed in this pass via glob, supporting
  the scoped-lint commands in P0-T4 and P2-T2.
- `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/remediation-inputs.2026-09-02T12-02.md`
  lines 26-42 — read in this pass; the CI failure diff quoted verbatim in P0-T2's acceptance condition
  is copied from this file.

---

`PLANNER-INTERNAL-REVIEW: PASS`

`CITATION-TO-TREE: PASS`

`CITATION: extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts | lines 98-109 (mandate_reads array, 10 entries, no scripts/vscode/**)`
`CITATION: extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json | lines 12-24 (mandate_reads array, 11 entries, scripts/vscode/** at position 11)`
`CITATION: extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts | lines 110-134 (keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource)`
`CITATION: extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts | 17 total it() occurrences (grep count)`
`CITATION: extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts | lines 110-120, 421-472 (independent MANDATE_READS constant, no import of SOURCE_BLAST_RADIUS)`
`CITATION: extensions/drm-copilot/package.json | lines 202-213 (format, lint, typecheck, test:unit, test:coverage scripts)`
`CITATION: extensions/drm-copilot/jest.config.cjs | lines 1-19 (collectCoverageFrom: src/**/*.ts only)`
`CITATION: extensions/drm-copilot/run-jest.cjs | lines 1-39 (argv passthrough to jest --config jest.config.cjs)`
`CITATION: extensions/drm-copilot/eslint.config.mjs | file exists at repository root of extensions/drm-copilot`
`CITATION: docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/remediation-inputs.2026-09-02T12-02.md | lines 20-61 (finding, root cause, required change, scope constraint)`

`AC-TRACEABILITY: PASS`

`AC-INVENTORY: AC-R1, AC-R2, AC-R3, AC-R4`

`AC-MAPPING: AC-R1 | IMPLEMENTATION: P1-T1 | TESTS: P1-T3 | EVIDENCE: P1-T3`
`AC-MAPPING: AC-R2 | IMPLEMENTATION: P1-T1 | TESTS: P1-T2,P1-T3,P1-T4,P1-T5 | EVIDENCE: P1-T2`
`AC-MAPPING: AC-R3 | IMPLEMENTATION: P1-T1 | TESTS: P2-T4 | EVIDENCE: evidence/qa-gates/p2-t4-target-test-final.2026-09-02T12-02.md`
`AC-MAPPING: AC-R4 | IMPLEMENTATION: P1-T1 | TESTS: P2-T5 | EVIDENCE: evidence/qa-gates/p2-t5-diff-scope-final.2026-09-02T12-02.md`

`SCOPE-BOUNDARY: PASS`

`UNRESOLVED-GAPS: NONE`

---

## Handoff

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

This plan is ready for `atomic-executor` preflight review and for the
`mcp__drm-copilot__validate_orchestration_artifacts` validator gate (`artifact_type: "plan"`,
`artifact_path: docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/remediation-plan.2026-09-02T12-02.md`).
Neither tool is available to this planning agent in the current session; both are the calling
orchestrator's next step. This document does not self-issue a `PREFLIGHT: ALL CLEAR` /
`PREFLIGHT: REVISIONS REQUIRED` signal, since that signal belongs to the separate executor-preflight
role and this agent does not claim nested worker delegation from within planner execution.
