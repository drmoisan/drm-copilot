# Remediation Inputs — poshqc-test-terminal-output-scan-config (#344)

- **Timestamp:** 2026-07-10T19-52
- **Produced by:** feature-review agent (initial review pass)
- **Source audit artifacts:**
  - `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/policy-audit.2026-07-10T19-52.md` (section 8, items R1–R3)
  - `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/code-review.2026-07-10T19-52.md` (Findings Table, three Blockers)
  - `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/feature-audit.2026-07-10T19-52.md` (AC16 PARTIAL)
- **Blocking finding count:** 3
- **Scope:** Coverage-evidence remediation only. No implementation-logic defects were found; do not rework delivered behavior.

## Enumerated Fixes (remediation required)

### R1 — Regenerate the TypeScript post-change coverage artifact at branch HEAD (Blocking)

- **Finding:** `extensions/drm-copilot/coverage/lcov.info` (mtime 2026-07-10 17:43) is stale relative to HEAD `2ed08b19`: it contains no records for `src/poshqc-scan-config.ts`, `src/poshqc-terminal-output.ts`, or `src/poshqc-folder-picker.ts`, and its totals (31877/32985 lines = 96.64%, 4056/4577 branches = 88.62%) equal the recorded baseline. The final gate log (`evidence/qa-gates/final-ts-test-coverage.md`) reports compliant per-file figures, but they are not corroborated by a machine-readable artifact.
- **Files:** `extensions/drm-copilot/coverage/lcov.info` (regenerated output); `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/qa-gates/coverage-comparison.md` and a refreshed final-ts-test-coverage evidence file (updates).
- **Expected behavior after fix:** The regenerated lcov at HEAD contains records for all four changed/new TypeScript modules; per-file line coverage >= 85% and branch coverage >= 75% for each; repo-wide figures show no regression versus the 96.64%/88.61% baseline. Refreshed numeric figures recorded in the feature evidence tree (canonical `<FEATURE>/evidence/qa-gates/` location only).
- **Verification commands:**
  - `cd extensions/drm-copilot && npm run test:coverage`
  - Parse `coverage/lcov.info` per-file `LH/LF` and `BRH/BRF` for `poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, `poshqc-folder-picker.ts`, `poshqc-command-registration.ts` and confirm thresholds.

### R2 — Bring the changed PowerShell production modules into coverage measurement, or record an approved exception (Blocking)

- **Finding:** The new production file `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` and the modified `PoshQC.Testing.psm1` / `PoshQC.psm1` have zero instrumented lines. Cause: `PoshQC.psm1` loads sub-modules via `. ([scriptblock]::Create((Get-Content <file> -Raw)))` — a fileless scriptblock with no on-disk path association, so Pester breakpoints never bind (empirically confirmed; independently confirmed in this review — no PoshQC module among the coverage XML's 16 sourcefiles). The new-file line >= 85% threshold therefore cannot be evidenced, and `.claude/rules/general-unit-test.md` (Coverage Exclusion Policy) prohibits excluding production files from measurement, prescribing refactoring for untestable lines. No approved exception is recorded.
- **Files:** `scripts/powershell/PoshQC/PoshQC.psm1` (loading mechanism), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`CodeCoverage.Path`), bundled mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/` (mechanical resync; parity gate must stay green), `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (unchanged set, gate re-run).
- **Expected behavior after fix (option a — preferred, per policy):** Sub-module loading refactored so coverage breakpoints bind to the `.psm1` files (e.g., dot-source by path) while preserving the module-scope behavior the current comment documents; the PoshQC module files added to `CodeCoverage.Path`; the coverage report then shows line coverage >= 85% for `PoshQC.ScanConfig.psm1` and no regression for the modified modules; all 1103 Pester tests still pass; parity gate still passes with mirrors resynced.
- **Expected behavior after fix (option b — fallback):** If the refactor is demonstrably infeasible without breaking the module-scope loading contract, record an explicit human-approved exception (naming the structural constraint, the affected files, and the behavioral-test mitigation) in the feature folder and reference it from the policy audit's Approved Exceptions section. Human approval is required; the executor cannot self-approve.
- **Verification commands:**
  - MCP `mcp__drm-copilot__run_poshqc_test` (confirm 0 failures and inspect `artifacts/pester/powershell-coverage.xml` for the module sourcefiles)
  - `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
  - MCP `run_poshqc_format` / `run_poshqc_analyze` (clean pass after any refactor)

### R3 — Produce the Python coverage artifact (Blocking)

- **Finding:** Python has a changed file on the branch (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`) but no coverage artifact exists at `artifacts/python/lcov.info`. Coverage verification is mandatory for every language with changed files; the test-only nature of the change lowers practical severity but does not waive the artifact requirement.
- **Files:** `artifacts/python/lcov.info` (new output); a Python coverage evidence file under `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/qa-gates/` (new).
- **Expected behavior after fix:** The artifact exists at `artifacts/python/lcov.info`; repo-wide Python line coverage >= 85% and branch coverage >= 75% (or, if the repo-wide Python figure is below threshold for pre-existing reasons, that state is documented with baseline comparison showing this branch introduces no regression — this branch changes no Python production code, so changed-line regression is structurally impossible); numeric figures recorded in the feature evidence tree.
- **Verification commands:**
  - `poetry run pytest --cov --cov-report=lcov:artifacts/python/lcov.info`
  - Confirm the artifact exists and record repo-wide totals.

## Non-blocking items carried for visibility (do NOT treat as remediation scope)

- **Bundled-wrapper self-test collision (code review CR-4, Major, non-blocking):** running `run-poshqc-test.ps1` inside this development repository reports 31 failures in PoshQC's own self-mocking tests (resident-module collision after the FR2.2 `RequiredModules` removal). Determination: non-blocking (AC2 discovered-set parity holds 1103=1103; authoritative task/MCP gate passes 0 failures; cannot occur in consumer repos). Recommended action: open a follow-up issue; do not fix inside this feature's remediation cycle and do not restore `RequiredModules` (would violate AC2 byte parity).
- **Terminal-per-invocation (code review CR-5, Minor):** optional future improvement; not remediation scope.
- **AC16 checkbox discrepancy:** AC16 is marked `[x]` in `spec.md` and `user-story.md` but evaluates PARTIAL; completing R1/R2 makes the mark accurate. If an approved exception (R2 option b) is taken instead, re-evaluate AC16 wording against the exception.

## Do-Not-Do List

- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not weaken or remove any existing test, assertion, or validation rule to satisfy coverage.
- Do not restore the bundled `RequiredModules` block or reintroduce `CodeCoverage.ExcludedPath` (violates FR2.2/AC2 and the Coverage Exclusion Policy).
- Do not exclude any production source path from coverage measurement.
- Do not write evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`; use the canonical `<FEATURE>/evidence/<kind>/` tree.
- Do not expand scope beyond R1–R3 (no refactors of unrelated modules, no UX changes, no dependency changes).
- Do not self-approve the R2 option-b exception; it requires explicit human approval.

## Handoff

Per `remediation-handoff-atomic-planner`, the orchestrator should route these inputs to `atomic-planner` for a remediation plan, followed by `atomic-executor` preflight/execution and a `feature-review` re-audit. Exit condition: blocking count 0 (R1–R3 resolved with evidence).
