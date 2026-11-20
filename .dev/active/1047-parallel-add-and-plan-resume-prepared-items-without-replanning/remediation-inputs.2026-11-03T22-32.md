# Remediation Inputs - Issue #1047 (cycle 3, orchestrator-opened)

Remediation-Mode: proportionate

- Feature folder: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- Branch: `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `fb83d2f05`; PR #1064 into `main`.
- Base: `origin/main`; merge base `01706c697`.
- Source review: `code-review.2026-11-03T21-58.md` (verdict PASS, zero blocking findings).
- Why this cycle exists: CI was green on `16f6b0460` (25 of 25 checks). The S9 acceptance-criterion check-off commit `fb83d2f05` touches allowlisted documentation only, so `ci.yml` took the docs-only path. On that path, eight required contexts of ruleset 15241672 report no check run under their expanded names, and the PR is `BLOCKED`: the three `NPM Audit Gate / npm audit (...)` contexts, the two `root-typescript-tests / Root TypeScript Tests (...)` contexts, and `poshqc / PowerShell QC shard 1` to `shard 3`. That is a repository CI defect outside this item, reported to the coordinator. Within this item, the one remaining Minor finding is a real non-documentation change, so fixing it in-item also produces the full CI run that the ruleset requires.
- Mode reason: the fix stays inside a file already in the branch diff, plus its tests and bundle mirror. It changes no acceptance-criterion text and adds no option, subcommand, or output field.
- This is the third completed attempt allowed by the termination guard. Keep the change minimal.

## In-Cycle Item

### B1 - Validate the receipt base_commit before it reaches git

- Source: `code-review.2026-11-03T21-58.md` Findings Table, Minor row for `Get-ParallelAdmissionAssessStaleness` and the `assess` receipt read in `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`.
- Finding: the receipt field `base_commit` is passed to `git merge-base --is-ancestor` and `git diff --name-only --no-renames <base> <main>` without a format check; a value beginning with `-` would be read by git as an option.
- Required action: accept a receipt `base_commit` only when it is a 40- or 64-character lowercase or uppercase hexadecimal object name; treat any other value exactly as an absent `base_commit` (the existing absent-field path), so no git call receives it. Add Pester cases in `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` (table-driven where possible; keep the file at or under 700 logical lines) for an option-shaped value, a short or non-hex value, and a valid 40-character value; assert through the existing git seam that no `merge-base` or `diff` call receives the rejected value. Update the bundle copy byte-for-byte.

## Verification Expectations

- Targeted Pester runs of the six parallel-admission suites plus `ClaudeLibModuleConvention.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1` show zero failures. Seeded shuffled file-order runs use seeds 11, 23, and 47. PSScriptAnalyzer reports zero findings, and the formatter changes nothing.
- Coverage of `Invoke-ParallelAdmission.ps1` is at or above 96.48%, read from `artifacts/pester/powershell-coverage.xml` written at the final head. Do not make a zero-failure full scan an acceptance condition, because full scans on this Linux host fail in host-fixture suites outside the item, as the earlier cycle evidence records.
- The pytest contract set and the mirror contract tests pass serially under the strict addopts.
- The final self-review under `evidence/qa-gates/self-review.<timestamp>.md` has no FAIL row.

## Do Not Do

- Do not edit `.github/workflows/`, `config/ci-docs-only-paths.json`, or any CI script; the docs-only defect is out of scope.
- Do not change any acceptance-criterion text, coverage configuration, thresholds, or `pyproject.toml`. Do not commit anything under `artifacts/`.
