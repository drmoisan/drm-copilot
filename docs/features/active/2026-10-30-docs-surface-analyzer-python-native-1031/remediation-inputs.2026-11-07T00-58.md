# Remediation Inputs - issue #1031 (review 2026-11-07T00-58)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Finding classes: F6 autonomous; F5 awaiting_ci. F1, F2, F3 and F4 of the 2026-11-05T23-18 review are closed. The cycle is proportionate: the F6 fix changes no acceptance criterion and no public interface, and stays within files already in the branch diff plus their tests and mirrors.

Scope note, for the coordinator to accept or decline: the cycle may also take in the non-blocking Minor items M1, M2 and M4 of the code review, because they sit in this item's own documents or task order. M5 lies outside the branch diff and is a coordinator decision.

Source review artifacts (this folder):

- `policy-audit.2026-11-07T00-58.md`
- `code-review.2026-11-07T00-58.md`
- `feature-audit.2026-11-07T00-58.md`

Branch: `feature/docs-surface-analyzer-python-native-1031-r2`, head `94b12db15`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `e3e4aa551`).

Isolation evidence for the next cycle, per the owner directive relayed by the coordinator (effective 2026-11-07): a passing `Invoke-PoshQCParallelTest` run and a passing `pytest -n auto` run. Single-process, seeded-shuffle and reversed-order runs are waived.

## Blocking Findings

### F5 - CI-dependent criteria

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC` and `quality-checks7 / Code Quality & Tests` (3.11, 3.12, 3.13) on the PR head; no pull request exists for head `94b12db15`. Local results at this head: Windows parallel Pester 16542 tests with 0 failures, and `pytest -n auto` 16350 passed.
- File: `spec.md` S10 and S22; `user-story.md` U10 and U22
- Symbol: not applicable (CI criteria)
- Rule: `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria`.
- Evidence: `gh pr list --head feature/docs-surface-analyzer-python-native-1031-r2 --state all` returns no pull request.
- Required change: none in a remediation cycle. After F6 is fixed, open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start). At S9 the item's own orchestrator run checks off S10, U10, S22 and U22 after green conclusions and re-runs the CI gate on the final head.

### F6 - Helper start depends on the current location, not the repository root

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The defect reproduces locally, the cause is in files already in the branch diff, and the fix needs no owner decision, external system or CI result.
- File: `.claude/lib/docs/Invoke-DocsCommand.ps1` (`Invoke-DocsProcess` line 213, `New-DocsCommandContext` line 369), `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` (`$script:DocsPythonNativeHelperPath`), and their bundle copies
- Symbol: `New-DocsCommandContext`, `Invoke-DocsProcess`, `Invoke-DocsPythonNativeInterpreter`, `Get-DocsPythonNativeResult`
- Rule: `spec.md` `### Interpreter discovery and invocation`: "The working directory is the repository root." The pack test is repository-root relative in the same section.
- Evidence: reviewer real-process probe on a scratch repository holding a copy of `.claude/lib` and three Python files, Python 3.13 on Windows. Run from the repository root: `-AnalysisMethod native` exit 0 with 10 native elements. Run from another directory with `-RepositoryRoot <repo>`: default method exit 0 with 10 scanner elements and `PYTHON_NATIVE_UNAVAILABLE` naming `exit-nonzero`; `-AnalysisMethod native` exit 3 with `DOCS_PYTHON_NATIVE_UNAVAILABLE` naming `exit-nonzero`, although the pack and interpreter are present. Cause: `Context.TestFile` resolves under `RepositoryRoot`, while `$invokeProcess` does not pass the root, so `Invoke-DocsProcess` defaults `WorkingDirectory` to `Get-Location` and the interpreter opens the relative helper path there. No committed test reaches this path: Pester replaces the seam, and `Invoke-DocsProcess` is documented as not executed by tests. MCP docs tools set the process `cwd` to the workspace root and are not affected.
- Impact: the same repository inventories different element sets depending on the caller's location, a pinned `native` run fails with a reason that does not name the cause, and the file checked by `TestFile` can differ from the file the interpreter opens.
- Required change: make the interpreter run with the repository root as its working directory, for example by having `New-DocsCommandContext` pass its root to `Invoke-DocsProcess -WorkingDirectory`. Update the `New-DocsCommandContext` help text, which says arguments are forwarded unchanged, and the `Invoke-DocsProcess` help text on caller location. Add a process-free Pester test that fails if the root does not reach the seam. Copy the changed files byte-identically to the bundle.
- Verification: repeat the probe from another directory and confirm exit 0 with native elements under both `auto` and `native`; run PSScriptAnalyzer and the formatter over the changed files; run the `Invoke-DocsCommand.Tests.ps1` and docs suites; run `Invoke-PoshQCParallelTest` and `pytest -n auto`; refresh `artifacts/pester/powershell-coverage.xml` and re-verify S9 and U9, since `Invoke-DocsCommand.ps1` is at 87.82%; re-run SHA-256 mirror parity.
- Do not: weaken the fallback, change `-AnalysisMethod` semantics, add a process-starting test, widen the guard allowlist, or change an acceptance-criteria checkbox or its text.
