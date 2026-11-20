# Remediation Inputs - Issue #1047 (cycle 2, orchestrator-opened from Minor findings)

Remediation-Mode: proportionate

- Feature folder: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- Branch: `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `64e8cfe91`
- Base: `origin/main`; merge base `01706c697`.
- Source review: `code-review.2026-11-03T21-04.md` (verdict PASS, zero blocking findings). The orchestrator brings its two Minor findings into this item under the repository practice of fixing related findings inside the item before merge. Neither changes the blocking count of that review.
- Mode reason: both fixes stay inside files already in the branch diff plus their tests and bundle mirrors, change no acceptance-criterion text, and add no option, subcommand, or output field.

## In-Cycle Items

### N1 - Reject option-shaped ref values

- Source: `code-review.2026-11-03T21-04.md` Findings Table, Minor row for `Get-ParallelAdmissionUsageError` (`-Ref`, `-Branch`, `-Main`).
- Finding: `-Ref`, `-Branch`, and `-Main` reach `git show`, `git ls-tree`, `git rev-parse`, `git merge-base`, and `git diff` without rejecting a value that begins with `-`; `-Main` is a bare argument of `git diff --name-only --no-renames <base> <main>`.
- Required action: in `Get-ParallelAdmissionUsageError` of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, reject a non-empty `-Ref`, `-Branch`, or `-Main` value that begins with `-` as a usage error (exit 2) with a message naming the option and the value. Add Pester cases in `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` for each option, and confirm that existing valid ref values still pass. Update the bundle copy of the script byte-for-byte.

### N2 - Name the JSON helper module in the spec design

- Source: `code-review.2026-11-03T21-04.md` Findings Table, Minor row for `spec.md`.
- Required action: add `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` to the design or architecture description of `spec.md` (the section that lists the helper files). Do not edit any `## Acceptance Criteria` line.

## Verification Expectations

- The touched Pester suites, `ClaudeLibModuleConvention.Tests.ps1`, and `FileSizePolicy.RepoGate.Tests.ps1` pass with zero failures; PSScriptAnalyzer reports zero findings and the formatter changes nothing on the touched files.
- Seeded shuffled file-order runs (seeds 11, 23, 47) of the six parallel-admission suites pass.
- PowerShell line coverage for `Invoke-ParallelAdmission.ps1` at the final head is at or above 96.44%, and `artifacts/pester/powershell-coverage.xml` describes the final head. On this Linux host, the full-scan Pester runs fail in host-fixture suites that are outside this item and that the cycle 1 evidence records. Coverage may therefore be produced by a branch-current `Invoke-PoshQCTest` run whose coverage population comes from `config/poshqc-coverage.json`. The pass and fail counts of the item's suites are read from that run's JUnit file, or from the targeted run when the full-run JUnit export is truncated. The windows-latest CI shards remain the authoritative full-suite gate.
- No Python file changes. The pytest contract set still passes under the strict addopts, and the bundle-mirror contract tests pass.
- Final self-review under `evidence/qa-gates/self-review.<timestamp>.md` with no FAIL row.

## Do Not Do

- Do not change any acceptance-criterion text, coverage configuration, thresholds, `config/poshqc-coverage.json`, or `pyproject.toml`.
- Do not commit anything under `artifacts/`.
- Do not edit the unrelated `tests/scripts/dev-tools/run-actionlint.Tests.ps1` PATH leak; it is outside this item and is reported to the coordinator.
