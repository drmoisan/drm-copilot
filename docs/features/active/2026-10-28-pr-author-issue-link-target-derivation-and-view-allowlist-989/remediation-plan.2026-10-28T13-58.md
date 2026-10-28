# Remediation Plan: #989 cycle 1 (proportionate)

- Issue: 989
- Branch: `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989`
- Work Mode: full-bug
- Acceptance-criteria source: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md`
- Remediation inputs: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/remediation-inputs.2026-10-28T13-58.md`
- Scope: finding PA-B1 only. FA-B1 and FA-B2 are `awaiting_ci` and out of scope. `<FEATURE>` is `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989`.
- `SCRATCH` is `<session scratchpad>/issue-989/`; scratch file names start with `issue-989-`. Tool routes, launchers, and command-text restrictions follow the `execution-environment` skill.

## Problem Statement

`artifacts/pester/powershell-coverage.xml` reports 0 covered lines of 19185. A later architecture-guard run with coverage enabled overwrote the report written by the full `tests/scripts` run. No production code, test, or coverage configuration change is required. The cycle regenerates the report with one final coverage-enabled run and records the numbers.

## Acceptance Thresholds

- Failed tests in `artifacts/pester/pester-junit.xml`: 0.
- Report-level LINE coverage: at least 85%.
- LINE coverage of each changed hook file: at least 85%: `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.current-branch.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1`.
- A miss on any threshold fails the cycle. Thresholds are not lowered and no file is excluded from measurement.

## Phases

### Phase 0 — Policy Reads and Evidence

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/powershell.md` in that order. Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:`, and the four files listed as read.

### Phase 1 — Coverage-Disabled Guard Re-runs

- [x] [P1-T1] Run the suites `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` in one PowerShell 7 process with Pester code coverage disabled, through a `sh` launcher at `SCRATCH/issue-989-guards.sh`. The run passes no coverage-enabled configuration and writes no coverage report. Acceptance: `<FEATURE>/evidence/qa-gates/pester-guards.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with passed, failed, and skipped counts printed by the run; failed count is 0.

### Phase 2 — Final Coverage-Writing Run and Evidence

- [x] [P2-T1] As the last coverage-writing step, run one fresh PowerShell 7 process through a `sh` launcher at `SCRATCH/issue-989-pester-full.sh` that imports `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCTest` with `-Root` set to the worktree root and `-ScanFolders tests/scripts`, coverage enabled through `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. No coverage-enabled Pester invocation runs after this task. Acceptance: the launcher process exits and `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` have write times later than the Phase 1 evidence file.
- [x] [P2-T2] Read the report-level LINE counter from `artifacts/pester/powershell-coverage.xml` and compute the percentage as covered over covered plus missed. Acceptance: the percentage is a number recorded in the P2-T4 artifact; the report no longer shows 0 covered lines.
- [x] [P2-T3] Read the LINE counter of each of the four changed hook files named under Acceptance Thresholds from `artifacts/pester/powershell-coverage.xml`. Acceptance: four numeric percentages, one per file, recorded in the P2-T4 artifact.
- [x] [P2-T4] Read passed, failed, and skipped totals from `artifacts/pester/pester-junit.xml` and write `<FEATURE>/evidence/qa-gates/pester-full.<timestamp>.md`. Acceptance: the file contains `Timestamp:`, `Command:` (the launcher invocation and the `Invoke-PoshQCTest` call), `EXIT_CODE:`, and `Output Summary:`; the summary carries the report-level percentage, the four per-file percentages, and the pass, fail, and skip totals as numbers, with no host paths.
- [x] [P2-T5] Compare the recorded values with the Acceptance Thresholds. Acceptance: the `pester-full` artifact ends with a `Threshold Result:` line of PASS only when failed tests are 0, the report-level percentage is at least 85, and all four files are at least 85; otherwise FAIL, and the cycle is reported as failed with no threshold change and no exclusion added.

### Phase 3 — Final QA and Self-Review

- [x] [P3-T1] Confirm the branch diff against the merge base of `origin/main` and `HEAD` contains no change to production code, tests, or coverage configuration, using `git diff --name-only` with the merge-base ref and `git status --porcelain`. Acceptance: the only changed or untracked paths are under `<FEATURE>` or `artifacts/`; recorded in `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`.
- [x] [P3-T2] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. Acceptance: the file exists and has no FAIL row; a FAIL row is fixed and Phase 2 is re-run before the file is rewritten.

## Pre-Mortem

- Review checklists: the self-review in P3-T2 walks all three templates, and P3-T1 confirms the diff holds only evidence, so no checklist item can be raised against unchanged production code.
- Coverage: the plan changes no code; P2-T2 to P2-T5 record numeric report-level and per-file LINE values against the 85% threshold, PowerShell has no branch gate, and no exclusion is added.
- Mirror parity: not applicable, no mirrored, bundled, or execution-environment brief file is edited.
- File size: not applicable, no production, test, or script file is created or edited; the SCRATCH launchers are throwaway.
- Test isolation: P2-T1 is a fresh single-process run over `tests/scripts`, the CI shape, and the seeded shuffled runs of the touched suites already passed in the original execution; this cycle changes no test, so no new Jest, Python, or shuffle run is needed and none is performed.
- CI-only behavior: the Linux hook-suite leg and the `poshqc / PowerShell QC` shards are out of scope (FA-B1, FA-B2) and wait for the PR head; this cycle makes no claim about them.
- Evidence: P1-T1 runs before P2-T1 and with coverage disabled, so nothing can overwrite the report afterward; every artifact is under `<FEATURE>/evidence/qa-gates/` with the four required fields and no absolute paths.
