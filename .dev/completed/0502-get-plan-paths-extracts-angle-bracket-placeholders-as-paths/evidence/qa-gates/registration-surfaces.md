# QA Gate — Registration Surfaces — [P4-T6]

Timestamp: 2026-08-23T02-18

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P4-T6]
State captured: after all five Phase 4 mirror and registration edits

Three independent commands, one per registration surface. Each is recorded separately with its own
exit code, per the acceptance requirement.

## Command 1 — bundled resource contracts and PoshQC bundled parity

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`

EXIT_CODE: 0

Output Summary:

```text
...........                                                              [100%]
11 passed in 0.17s
```

11 passed, 0 failed. This covers the byte-identical bundled mirror of the new module ([P4-T1]) and
of the changed extraction module ([P4-T2]), and the PoshQC bundled-settings parity that [P4-T5]
depends on.

## Command 2 — Pester manifest membership

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to
`["tests/scripts/claude-lib/blast-radius"]`.

EXIT_CODE: 0

The tool returns only an ok flag and a short summary, so the outcome of
`tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` is read from
`artifacts/pester/pester-junit.xml`:

```xml
<testsuites ... name="Pester" tests="393" errors="0" failures="0" disabled="0" time="31.384">
<testsuite name="...\BlastRadius.Manifest.Tests.ps1" tests="4" errors="0" failures="0" ... time="0.178">
```

The manifest Pester file reports **4 tests, 0 errors, 0 failures**. The whole folder now reports 0
failures across 393 tests.

The two assertions that failed at [P3-T5] are the two this command closes:

| Test | [P3-T5] | [P4-T6] |
| --- | --- | --- |
| `Library coverage.lists every discovered library module in core.json paths` | FAILED | **Passed** ([P4-T3]) |
| `Bundled payload parity.ships a bundled counterpart for every library module` | FAILED | **Passed** ([P4-T1]) |

## Command 3 — pack-manifest-completeness suite

Command: `npm test` scoped to the pack-manifest-completeness suite, with `extensions/drm-copilot` as
the working directory. The suite's repository-relative path is
extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts and the argument
passed is that path with the extension-directory prefix removed.

EXIT_CODE: 0

Output Summary:

```text
Test Suites: 1 passed, 1 total
Tests:       15 passed, 15 total
Snapshots:   0 total
Time:        0.323 s, estimated 1 s
```

15 passed, 0 failed, matching the pre-change green state recorded at [P0-T10].

The suite path is named in prose rather than inline code deliberately: the working-directory-relative
spelling matches no repository path, so inline-coding it would inject a phantom entry into this
item's own derived radius, which is the class of defect this item repairs.

## Registration edits verified by this gate

| Surface | File | Verification |
| --- | --- | --- |
| bundled module mirror ([P4-T1]) | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | `diff` reports no difference; MD5 `5721d7de4cad8f96cb827a5825206e95` on both sides |
| bundled Extraction mirror ([P4-T2]) | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | `diff` reports no difference; MD5 `f381f17f9ed0b979a06a88f05d80dd88` on both sides |
| bundled pack manifest ([P4-T3]) | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | new path listed exactly once (fixed-string count = 1); file still parses as JSON |
| repo Pester coverage allow-list ([P4-T4]) | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` count 80 at `HEAD` versus 81 now, so exactly one entry added and none removed; `Import-PowerShellDataFile` confirms the list contains the new module |
| bundled Pester coverage allow-list ([P4-T5]) | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `diff` against the repository file reports no difference |

The adjacent comment in both runsettings files was updated from "split across six files" to "split
across seven files" and now records the reason for this addition: `CodeCoverage.Path` is an explicit
per-file allow-list, so without the entry the new production module and the lines relocated into it
would both sit outside the coverage denominator, which the Coverage Exclusion Policy forbids.

## No-reordering and no-removal conditions

[P4-T3]'s no-reordering condition and [P4-T4]'s no-removal condition are prior-state claims and
cannot be settled against a post-edit file alone. The entry-count comparison above (80 versus 81,
taken against `HEAD`) settles the no-removal half directly. Both are additionally backstopped by
[P8-T13], whose staged and `main`-anchored whole-tree diff records this manifest's and this
allow-list's hunks explicitly.

## Toolchain stages for this phase

| Stage | Command | Result |
| --- | --- | --- |
| format | `mcp__drm-copilot__run_poshqc_format` over the full default scope | ok; the four modified PowerShell files were re-diffed afterwards and both mirror pairs remain byte-identical |
| analyze | `mcp__drm-copilot__run_poshqc_analyze` over the full default scope | ok |
| test | the three commands above | all exit 0 |

## Output Summary

All three commands report exit code 0. The manifest Pester file reports zero failures in the JUnit
output, closing both assertions that failed mid-sequence at [P3-T5]. All five Phase 4 registration
edits are verified: two byte-identical bundled module mirrors, one pack-manifest entry listed exactly
once, and two byte-identical Pester coverage allow-lists with exactly one entry added and none
removed.
