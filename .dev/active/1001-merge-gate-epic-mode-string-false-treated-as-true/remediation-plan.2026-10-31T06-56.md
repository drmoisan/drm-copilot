# Remediation Plan (Issue #1001), cycle 1

Remediation-Mode: proportionate
Source: `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/remediation-inputs.2026-10-31T06-56.md`
FEATURE: `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001`
SCRATCH: `<session scratchpad>/issue-1001/` (scratch file names start with `issue-1001-`)

Scope: finding F1 (PA-1) only. The fix is evidence-only. No hook, mirror, test, configuration, policy, or `.codex/` file changes. Tool routes follow the `execution-environment` skill (PowerShell through a `sh` launcher script under `SCRATCH`; PoshQC MCP results carry no output, so counts come from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`).

### Phase 0 — Policy reads and scope anchor

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md` in that order and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, and the list of files read. Acceptance: the artifact exists and names all four files.
- [x] [P0-T2] Confirm the input facts by reading `FEATURE/remediation-inputs.2026-10-31T06-56.md` heading `F1 (PA-1)` and the existing `FEATURE/evidence/qa-gates/pester-coverage.*.md` (greatest stamp), and record in `FEATURE/evidence/baseline/prior-coverage-scope.<timestamp>.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`) that the prior report came from a `tests/scripts/claude-hooks` only run. Acceptance: the artifact exists with all four fields.

### Phase 1 — Full-suite coverage run and evidence

- [x] [P1-T1] Write a launcher `SCRATCH/issue-1001-run-coverage.sh` (outside the worktree, so no batch-budget slot) that invokes PowerShell 7 from inside the script file, imports `scripts/powershell/PoshQC/PoshQC.psd1`, and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` with the default coverage configuration derived from `config/poshqc-coverage.json` (not edited), and run it with `sh`. Acceptance: the run completes and regenerates `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`; the observed exit code is recorded for P1-T3.
- [x] [P1-T2] Read from `artifacts/pester/pester-junit.xml` the root totals of tests, failures, and errors, and from `artifacts/pester/powershell-coverage.xml` the report-level LINE counter (covered, missed, percent) and the per-file LINE counters of `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, and `.claude/hooks/enforce-model-routing-receipt.ps1`. Acceptance: all values are numeric and the XML generation time is later than the P1-T1 start.
- [x] [P1-T3] Write `FEATURE/evidence/qa-gates/pester-coverage-full.<timestamp>.md` (UTC write-time stamp read from the clock) carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, the JUnit totals, repo-wide covered/missed/percent, the three per-file figures, and `Output Summary:`, using repository-relative paths only and the token `SCRATCH` for scratch locations. Acceptance: the file exists and every field is numeric, not a placeholder.
- [x] [P1-T4] Evaluate the gate from the P1-T3 artifact: JUnit failures and errors are 0, repo-wide line percent is at least 85, and each of the three hooks is at least 85 (expected 100.00, 93.55, 96.43 or higher). Acceptance: the artifact records `Gate: PASS`. Stop condition: if the repo-wide figure is below 85, record `Gate: FAIL`, the measured figure, and the per-file list of the largest uncovered files in the same artifact, make no code or configuration edit and add no coverage exclusion, skip all later tasks, and report the shortfall to the caller as a blocked outcome.

### Phase 2 — Final verification and self-review

- [x] [P2-T1] Verify no source or test file changed: run `git diff --name-only` against the merge base of `origin/main` and `HEAD` (derived with `git merge-base`) for the tree and `git status --porcelain` for untracked files, and record in `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` that the only new paths are under `FEATURE/evidence/`. Acceptance: no path outside `FEATURE/` appears as new or modified relative to the state before this cycle, and `config/poshqc-coverage.json` is untouched.
- [x] [P2-T2] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item, including a PASS row for the coverage item citing the P1-T3 artifact. Acceptance: no FAIL row; a FAIL row is corrected and the affected evidence regenerated before the self-review is rewritten.

## Pre-Mortem

- Review checklists: P2-T2 walks all three audit templates; the single blocking item F1 is closed by P1-T4 with a recorded PASS.
- Coverage: the plan exists to establish the repo-wide and per-hook line figures from a full `tests/scripts` run; PowerShell has no branch gate, and no exclusion is added. A below-85 result stops the plan rather than editing code.
- Mirror parity: not applicable, no mirrored, bundled, or brief file changes, so no execution-environment brief update task is needed.
- File size: not applicable, only new Markdown evidence files are created.
- Test isolation: no test file is added or changed, so no shuffled-order runs are scheduled; the P1-T1 run is a single-process `tests/scripts` run, which is the CI shape, and any failure in it is reported rather than worked around.
- CI-only behavior: the run is local on Windows; CI shards merge coverage separately, so the local figure is evidence for this review and the `poshqc / PowerShell QC` check remains the CI authority.
- Evidence: all artifacts live under `FEATURE/evidence/<kind>/` with write-time UTC stamps; counts come from the `artifacts/pester` files, never from PoshQC MCP result text; `artifacts/pester/powershell-coverage.xml` is left in place for re-review.

## Planner Internal Review

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/remediation-inputs.2026-10-31T06-56.md | F1 (PA-1) - Repo-wide PowerShell line coverage not established from a full-suite run
CITATION: config/poshqc-coverage.json | coverage population
CITATION: .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate
CITATION: .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | enforce-pr-author-skill.epic-base-branch
CITATION: .claude/hooks/enforce-model-routing-receipt.ps1 | enforce-model-routing-receipt
AC-TRACEABILITY: PASS
AC-INVENTORY: F1
AC-MAPPING: F1 | IMPLEMENTATION: P1-T1, P1-T2, P1-T3 | TESTS: full tests/scripts Pester run with coverage (P1-T1) | EVIDENCE: pester-coverage-full artifact (P1-T3, P1-T4)
SCOPE-BOUNDARY: PASS
UNRESOLVED-GAPS: NONE
SELF-REVIEW: RE-DERIVED THIS PASS
- docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/remediation-inputs.2026-10-31T06-56.md | F1 (PA-1) heading and Fix steps
- docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/evidence/qa-gates | pester-coverage.2026-10-31T06-32.md exists
- .claude/hooks/enforce-epic-merge-gate.ps1 | path exists per remediation inputs
