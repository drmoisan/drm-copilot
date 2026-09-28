# Final QA — Coverage Denominator Completeness — P7-T7

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command:

```
grep -n "Invoke-Release" scripts/powershell/PoshQC/settings/pester.runsettings.psd1
pwsh -NoProfile -Command "[xml]$c = Get-Content artifacts/pester/powershell-coverage.xml -Raw; ..."
```

The second command enumerated every `package`/`sourcefile` pair carrying a `LINE` counter in the
document produced by the direct self-hosted PoshQC invocation.

EXIT_CODE: 0

## Confirmation 1 — both files are entries in `CodeCoverage.Path`

File inspected: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

| File | Present in `CodeCoverage.Path` | Line | Registered by |
|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | **yes** | 219 | P2-T8 |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | **yes** | 226 | P5-T2 |

Each entry carries a comment naming issue 526 as the reason and stating why registration is required
— `CodeCoverage.Path` is an explicit per-file allow-list, so an unregistered production file would
sit outside the coverage denominator, which the Coverage Exclusion Policy in
`.claude/rules/general-unit-test.md` forbids.

For reference, `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` was already registered at line 41 before
this change and required no new entry.

The bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
carries the same two entries at the same line numbers (219 and 226), so the in-repo copies are in
parity.

## Confirmation 2 — both files appear as measured files in the coverage report

Document inspected: `artifacts/pester/powershell-coverage.xml`, produced by the direct self-hosted
invocation
(`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path`).

Rows were located by keying on the enclosing `package` element (the full directory path), then
selecting the `sourcefile` by name within it — never on the bare `sourcefile` name.

| File | `package` | Measured row present | Covered | Total |
|---|---|---|---|---|
| `Invoke-ReleaseVerification.ps1` | `.../scripts/dev-tools` | **yes** | 83 | 92 |
| `Invoke-ReleaseReconciliation.ps1` | `.../scripts/dev-tools` | **yes** | 24 | 27 |

Total sourcefile rows in the document: **84**. The P0-T5 baseline document carried 82 rows. The
increase of exactly 2 accounts for these two files and nothing else.

### Note on the measurement route

The MCP tool `mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the installed
VS Code extension bundle rather than from either in-repo copy, so the document it produces carries
**82** rows and emits no row for either newly registered file. That absence is a tooling-path
artifact of where the MCP runner reads its settings from, not a failed registration and not a
coverage failure. The direct self-hosted invocation reads the self-hosted runsettings and honours
both entries in the same run, which is why the plan makes it the binding route for every per-file
coverage figure.

## Confirmation 3 — neither file was added to any exclusion list

A repository-wide search for both filenames across `.psd1`, `.json`, `.yml`, and `.yaml`
configuration files returned only these references:

- the two `CodeCoverage.Path` allow-list entries in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- the same two entries in the bundled mirror under `extensions/drm-copilot/resources/`
- three functional references to `Invoke-ReleaseReconciliation.ps1` in
  `.github/workflows/verify-published-releases.yml` (a `pull_request` path filter and two invocations)
- one path in the gitignored hook state file `.claude/state/powershell-batch-budget.default.json`,
  which is transient batch-budget bookkeeping and not a coverage setting

**No exclusion list of any kind contains either file.** `pester.runsettings.psd1` declares no
coverage exclusion key at all — its `CodeCoverage` block is an allow-list plus
`CoveragePercentTarget = 0` — so there is no exclusion surface in which either file could have been
placed.

Output Summary: Both `scripts/dev-tools/Invoke-ReleaseVerification.ps1` and
`scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` are confirmed present in both required places:
as `CodeCoverage.Path` allow-list entries at lines 219 and 226 of
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and as measured sourcefile rows in
`artifacts/pester/powershell-coverage.xml` with 83/92 and 24/27 lines respectively. Neither file was
added to any coverage exclusion list, and the settings file declares no exclusion key. The coverage
denominator grew from 82 to 84 sourcefiles, accounted for entirely by these two files. This satisfies
the second clause of AC24.
