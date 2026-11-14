# Preflight Fixes (confirming preflight after the planner revision)

Timestamp: 2026-11-04T14-40
Plan: docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/plan.2026-10-30T18-38.md
Scope: [P0-T4] onward, single pass, against the branch tree at the revised plan commit.

## Fixes made in place (task text only; no task added, removed or reordered)

1. `## Execution Context` (Pytest gate bullet) | stale CI citation | `quality-checks7 / Code Quality & Tests (3.10)` through `(3.13)` replaced with `(3.11)` through `(3.13)`. `.github/workflows/_quality-checks.yml` runs the matrix `3.11`, `3.12`, `3.13`; no `(3.10)` check exists.
2. [P6-T4] | stale CI citation | same correction as fix 1 in the `CI:` note.
3. [P4-T2] | literal completeness (validator-blind) | the quoted `New-DocsDiagnostic` call now states the mandatory `-Message` (naming the reason token, as deviation 4 already requires) and no `-Blocking`. `New-DocsDiagnostic` in `.claude/lib/docs/DocsSurface.psm1` declares `-Message` mandatory and derives `blocking` from `-Severity`; the asserted values (`code`, `severity` `information`, `blocking` false) are unchanged.
4. [P4-T2] | validator-blind guard interaction | `Context.TestFile` is stated to be passed into a `[scriptblock]`-typed parameter or called through `.Invoke()`, never as `& $Context.TestFile`. `Get-PythonInvocationFinding` reports a command position that is not a literal constant (class 3), so the member form would fail `It 'reports no Python invocation beyond the allowlist across the guarded tree'` in [P4-T7]. The assertion is unchanged.
5. [P4-T4] | open concern resolved by probe; validator-blind test-seam detail | added the re-import probe result and the non-forcing `-ImportModule` seam for suites that import `LIB/DocsAnalyzerPythonNative.psm1` themselves. Production behavior and every assertion are unchanged.
6. [P4-T3] | same as fix 5 | the parity suite's `Invoke-DocsAnalyzer` calls with native rows use the non-forcing seam of [P4-T4].

## Re-import probe (planner open concern)

Command: sh SCRATCH/issue-1031-run.sh issue-1031-reentry-probe.ps1 issue-1031-reentry-probe.out
EXIT_CODE: 0
Output Summary: a copy of `.claude/lib` under SCRATCH with a stub `DocsAnalyzerPythonNative.psm1` (an inventory function that calls `Invoke-DocsAnalyzer` for a native row whose `Module` is its own file, then for the committed `python-cli` scanner row, then a private helper) and a stub caller module that imports it. No tracked file was edited.
- Default `-ImportModule` (`Import-Module -Force`), called through the caller module twice: both calls succeed; the running function keeps its module instance (load stamp unchanged before and after the native row), the native analyzer function runs from a new instance, the private helper and module state resolve.
- Default `-ImportModule`, module imported globally by the caller script: the first call succeeds; afterwards `Invoke-DocsPythonNativeInventory` no longer resolves globally (the forced re-import into the registry module scope removed the global import), so a second call fails with CommandNotFound.
- Non-forcing seam `{ param($Path) Import-Module -Name $Path -ErrorAction Stop }`: two calls with a global import succeed and the global import remains.
- No-op seam with the module imported only inside the caller module: fails, because the registry module scope cannot resolve the native analyzer function.
Classification: works for production; test-seam guidance added (fixes 5 and 6); no substantive defect from this concern.

## Substantive defect returned (not fixed in place)

- S10/U10 and S22/U22 assert the Python tests pass on a Python 3.10 CI matrix job, which no longer exists (`_quality-checks.yml` matrix `3.11`-`3.13`; `pyproject.toml` `python = ">=3.11,<4.0"`). The `## Acceptance Criteria Traceability` rows S10 and S22 and the `CI-only behavior` Pre-Mortem bullet depend on that job. The acceptance-criterion text cannot be changed by the executor, so this is returned to the planner.
