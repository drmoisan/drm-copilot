# docs-prose-markdown-lint - Remediation Plan (cycle 3, finding R4)

- **Issue:** #1219
- **Parent (optional):** Epic #1217 (documentation-estate-families), child docs-prose-markdown-lint
- **Branch:** feature/docs-prose-markdown-lint-1219
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Remediation-Mode:** design
- **Requirements:** `remediation-inputs.2026-11-23T14-11.md` (R4), `spec.md`, original plan `plan.2026-11-23T00-38.md`

## Required References and Execution Directives

- Policies: `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`. Tool routes, launchers, the batch budget, and command-text restrictions are owned by the `execution-environment` skill; this plan does not restate them.
- Evidence follows `evidence-and-timestamp-conventions`: every artifact is `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md` with the write-time UTC stamp from the clock, carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and is append-only: no existing evidence or review file is edited, back-dated, or deleted. `<FEATURE>` is `.dev/active/1219-docs-prose-markdown-lint`. No artifact records an absolute path or a host name.
- `SCRATCH` is `<session scratchpad>/issue-1219/`; every helper script lives under it and artifacts record the token `SCRATCH`.
- Coordinator directives: autonomous mode (take the recommended option and record it in `<FEATURE>/evidence/other/decisions.<timestamp>.md`); no new Python; parallel-only test runs through the launcher (no serial, single-process, shuffled, or reversed run); no temporary files in tests; harness-generator parity with no hand edit to a generated file; 800-line limit; pre-mortem and self-review before every push.
- Scope boundary: one tracked file is edited, `.dev/engineering/documentation-estate/README.md`, in one table cell. No production module, template, skill surface, bundle copy, `spec.md`, `user-story.md`, other engineering page, test file, or existing evidence or review record is edited.
- Test-read determination (searched this pass, in the branch tree): `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` is the only test naming the engineering folder. It reads `README.md` as one of five pages (`PageName`): the existence assertion over all pages, the consumer-identifier digest scan (`It 'finds no consumer-identifier digest in the template pair or the onboarding pages'`), and the synthetic-identifier detection (`It 'detects a synthetic identifier injected into an in-memory page'`). None asserts the row text, "optional", or "linting" for `README.md`; the linting assertions read `consumer-onboarding.md` only. The inputs file states that no test reads the README; that statement is superseded by this search. The task check and the final Pester gate therefore run, and the gate is the last Pester run of the cycle, so it also refreshes `artifacts/pester/` coverage.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Record the pre-edit state: a case-insensitive proximity search with pattern `optional[^.\n]{0,40}lint|lint[^.\n]{0,40}optional` over `.dev/engineering/documentation-estate/`, `.claude/lib/docs/`, `.claude/skills/docs-*`, `.agents/skills/docs-*`, and `extensions/drm-copilot/resources/`. The Pester coverage baseline is the existing `evidence/baseline/pester-gate.2026-11-23T07-39.md` and is not recaptured.
  - Acceptance: `<FEATURE>/evidence/baseline/readme-linting-row.<timestamp>.md` records each command, exit code, and per-path match counts: exactly one match, in `.dev/engineering/documentation-estate/README.md`, and none in the other four paths.

### Phase 1 — README Correction and Final QA

- [x] [P1-T1] In `.dev/engineering/documentation-estate/README.md`, in the `## Topic Pages` table row for `consumer-onboarding.md`, replace the words "optional linting" with "linting" and change no other character. The resulting cell reads "Prerequisites, the optional python pack, linting, adoption steps, consumer CI and the epic template"; "the optional python pack" stays. Asserting tests, found by searching `tests/` for the folder path, the file name, and the cell text: `DocumentationEstateOnboarding.Tests.ps1` is unchanged because its README assertions (page existence, digest scan, synthetic injection) hold no row text and the new text holds no identifier; no other test names the path.
  - Acceptance: the proximity search of P0-T1 over the five paths returns no match; `git diff` against the merge base of `origin/main` and `HEAD` restricted to the README shows one changed line (the edited row), and a `git status --porcelain` span lists no other changed tracked file for this task.
- [x] [P1-T2] Run the task check for P1-T1 through the launcher `pester` suite with `-TestPath` on `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/other/task-check.P1-T2.<timestamp>.md` records the changed file, the selection and the rule that produced it (the only test that reads the changed path), exit code 0 with 0 failures, and the disposition unchanged for each asserting test. A launcher exit 75 is re-run and recorded as a queue timeout. This is a task check, not a gate; it measures no coverage.
- [x] [P1-T3] Run the one full parallel Pester gate through the launcher (`pester` suite, no `-TestPath`), as the last Pester run of this cycle; no Pester selection or gate run follows it. No PowerShell file changes, so format and analyzer stages are N/A and recorded as such in the self-review.
  - Acceptance: `<FEATURE>/evidence/qa-gates/pester-gate.<timestamp>.md` (a new file; the cycle-2 gate file stays unchanged) records launcher exit code 0, JUnit counts read from `artifacts/pester/pester-junit.xml` with 0 failed, repo-wide line coverage and the per-file line coverage of `.claude/lib/docs/DocsPagePlaceholder.psm1`, `.claude/lib/docs/DocsLedgerCommands.psm1`, and `.claude/lib/docs/DocsProfileCommands.psm1` read from `artifacts/pester/powershell-coverage.xml`, each compared with `evidence/baseline/pester-gate.2026-11-23T07-39.md`: repo-wide at least 85% and no drop, `DocsPagePlaceholder.psm1` at least 85%, the other two modules no drop, no newly failing test. A launcher exit 75 is a queue timeout: re-run after the holder finishes and record it; a failure is fixed and the gate re-run once.
- [x] [P1-T4] Walk `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from the merge base of `origin/main` and `HEAD`, and check R4 against its evidence.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` (a new file) holds one PASS, FAIL, or N/A row per checklist item and for R4, records the edited row and the search and gate results, and records that only the README changed in this cycle; a FAIL row is fixed and P1-T3 re-run before the file is written; no FAIL row remains.

## Pre-Mortem

- Review checklists: a reviewer would flag a surviving "optional" statement beside linting; P0-T1 records the pre-edit state with the proximity search in both word orders and P1-T1 asserts it returns no match over the five paths, and P1-T4 walks the three audit templates.
- Coverage: no production or test file changes; P1-T3 is the single full gate, compared with the `Phase 0 baseline` for repo-wide and per-file figures of the three docs modules, with the 85% threshold.
- Mirror parity: the README is neither generated nor mirrored (no harness source, parity-matrix entry, or bundle copy), so one file is edited and no generator or bundle task is needed. No execution-environment brief fact changes, so no brief task is needed.
- File size: the README is Markdown and exempt; no code file changes.
- Test isolation: gates are parallel only through the launcher: one `Invoke-PoshQCParallelTest` run (P1-T3, re-run only after a fix, with no Pester run after it); the P1-T2 selection is a task check before the gate, not a gate. No pytest or Jest run: no Python or TypeScript changes. Tests create no temporary files.
- CI-only behavior: the Onboarding suite reads the README by `Join-Path` and a repository-relative path, so no drive-letter, case, or line-ending difference arises; the file is not code, so CI treatment follows the change-scope decision for the branch as a whole.
- Evidence: every artifact is a new append-only `<name>.<timestamp>.md` with write-time clock stamps and the `SCRATCH` token; no existing evidence or review file is touched, and the cycle-2 gate file stays as history.
