# Discovery-Hook Coverage Remediation — Targeted Verification ([P16-T4])

Timestamp: 2026-08-15T19-01

Command:
- `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afc9f4fd25ec235a5` and `scan_folders = ["tests/scripts/claude-hooks"]`
- Coverage read: `[xml](Get-Content artifacts/pester/powershell-coverage.xml -Raw)` — `report.package.class` LINE counters for the two discovery hooks
- Result read: `[xml](Get-Content artifacts/pester/pester-junit.xml -Raw)` — `testsuites` attribute summary

EXIT_CODE: 0

## Output Summary

Targeted run scope: 42 test suites (all of `tests/scripts/claude-hooks`), 799 tests, **0 failures, 0 errors**. This scope executes both new sibling real-dispatch suites AND every existing hook suite, so all 26 pinned `Invoke-DiscoveryValidatorExe` references (15 `Mock` registrations plus 11 `Should -Invoke` assertions) passed alongside the real-dispatch tests.

Both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and the bundled
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` were confirmed byte-identical (`diff` reported no differences), so the MCP tool's bundled Pester settings carry the same coverage-target list as the repository settings. Both discovery hooks remain registered as coverage targets (lines 91-92); no coverage target was removed and `CoveragePercentTarget = 0` is unchanged.

### Line coverage, read numerically from `artifacts/pester/powershell-coverage.xml`

| File | Pre-change baseline | Failing post-change state (P15-T3) | This run | Floor (85%) |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 87.27% (48/55) | 82.76% (48/58) | **91.38% (53/58)** | MET |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 87.93% (51/58) | 83.61% (51/61) | **91.80% (56/61)** | MET |

Raw counter values from the JaCoCo-format XML:
- `enforce-discovery-artifact-gate.ps1` — LINE covered=53, missed=5 (total 58)
- `validate-discovery-artifact-gate.ps1` — LINE covered=56, missed=5 (total 61)

Each hook gained exactly the 5 previously-unexecuted statements of the replacement
`Invoke-DiscoveryValidatorExe` body (module-path `Join-Path` resolution, the `Test-Path`
guard, the module-not-found early return, `Import-Module`, and the delegation call).
Covered-line counts moved 48 -> 53 and 51 -> 56; total line counts are unchanged at 58 and 61.

### Branch coverage

The Pester toolchain does not emit a `BRANCH` counter in
`artifacts/pester/powershell-coverage.xml`; the JaCoCo-format output produced by
`scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` carries `LINE` counters only.
This is recorded as a factual limitation of the emitted artifact. No threshold was
relaxed, no coverage target was dropped, and the 75% branch floor remains in force as
repository policy; it is simply not measurable from this toolchain's output.

### Remediation mechanism (no production change)

The plan's PRIMARY approach was sufficient. Each new suite drives the seam's
module-not-found branch with a Context-scoped `Mock Test-Path { $false }` carrying a
`-ParameterFilter` limited to the `DiscoveryValidation.psm1` literal path, and drives the
delegation path with a real, unmocked seam invocation. The recorded FALLBACK — a minimal
injectable module-path seam on the hooks — was NOT taken. No production file was modified.

Constraints honored: no temporary file; no `$env:PATH` mutation; no live `python` probe;
no shadow `function python`; no `$PSVersionTable` mutation; no existing test, mock
registration, or `Should -Invoke` assertion modified; no check, error-string template, or
threshold weakened; no Python invocation added.

## QA Loop Restart — 2026-08-15T19-25

After this targeted gate, a comment-only correction was applied to both new suites so that a
literal grep for the token sequence `Mock` + `Invoke-DiscoveryValidatorExe` returns **0** in
each file (the header prose describing the prohibition previously contained the sequence). No
executable line changed. The full toolchain was restarted and the per-hook coverage values are
unchanged: `enforce-discovery-artifact-gate.ps1` 53/58 (91.38%),
`validate-discovery-artifact-gate.ps1` 56/61 (91.80%). See
`phase16-final-poshqc-test.2026-08-15T19-10.md`.

## Gate Hashes

Gate Hashes: no production file modified in Phase 16
