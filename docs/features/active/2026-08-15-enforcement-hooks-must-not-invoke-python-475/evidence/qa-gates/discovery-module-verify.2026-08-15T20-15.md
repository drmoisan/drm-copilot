# QA Gate — Discovery-Validation Module Verification (P2-T8) — Issue #475

Timestamp: 2026-08-15T20-15

Command:
1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/discovery-validation", "tests/scripts/claude-lib/discovery-validation"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/discovery-validation"]`
4. `Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib/discovery-validation') -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`

`scan_folders` is narrowed to the discovery-validation test folder so the guard's repository-scan `It`s — legitimately red from Phase 1 until Phase 11 — are not pulled into this gate. The default scan set in `config/poshqc-scan.json` includes `tests/scripts`, which would have included them.

EXIT_CODE: 0

Output Summary:

- **Format**: clean, and idempotent on re-run (zero files changed).
- **Analyze**: **0 findings**. Two findings raised during authoring were corrected, not suppressed: `PSUseOutputTypeCorrectly` on `Get-DiscoverySchemaArtifactType`, and `PSUseShouldProcessForStateChangingFunctions` on a test helper (resolved by renaming `New-ValidEvidenceReferenceJson` to `Get-ValidEvidenceReferenceJson`).
- **Tests**: **53 passed, 0 failed, 0 skipped**, across the two suites in the folder (`DiscoveryValidation.Tests.ps1` and the authorized sibling split `DiscoveryValidation.VersionFloor.Tests.ps1`). This includes all P2-T6 version-floor `It`s.
- **Coverage** (read from `artifacts/pester/powershell-coverage.koverage.xml`, the repo-relative conversion of `artifacts/pester/powershell-coverage.xml`, not inferred from the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | LINE | 102 | 6 | **94.44%** | >= 85% | Met (9.44 points headroom) |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | INSTRUCTION | 136 | 6 | 95.77% | — | — |

Branch coverage is NOT emitted by this toolchain. Pester 5's JaCoCo exporter records no `BRANCH` counter and leaves every `<line>` `mb`/`cb` attribute at zero; this was established with proof in `evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. The 75% branch floor therefore cannot be measured from this instrument. No threshold is relaxed; the figure is unavailable at the instrument level.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline reference points P15-T10 compares against.

```
.claude/lib/discovery-validation/DiscoveryValidation.psm1 = A8E5F29517ECF5391A6C266B1CF4E11B27F22B663F85590DA6E30933E3D1FDD3
```

No sibling helper `.psm1` was created under the pre-authorized production split; the module was kept to a single file at 500 lines.

## Coverage-Target Registration (P2-T7) and a Required Mirror Edit

`[P2-T7]` registered the module as a coverage target in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

The MCP `run_poshqc_test` tool resolves its Pester settings from bundled extension resources rather than from the repository working tree, so the module did not appear in the coverage report produced by that tool even after registration. Two consequences were handled:

1. **Required mirror edit.** `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` asserts that `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is byte-identical to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Registering the coverage target in only the repo copy would have broken that test. The bundled copy was therefore updated to match byte-for-byte (`diff` confirms identity). This is a mechanically required consequence of P2-T7, not additional scope: leaving the two out of sync would introduce a regression.
2. **Authoritative measurement.** The numeric coverage above was produced by invoking the repository's own PoshQC entry point with the repository's settings file, which writes the canonical `artifacts/pester/powershell-coverage.xml`. An independent direct `Invoke-Pester` probe scoped to the single module agreed: 1 file analyzed, 95.77% command coverage, 53 tests passing.

## Acceptance

- Suite green: yes (53/53).
- Numeric coverage recorded from the coverage XML: yes (94.44% line).
- Floors met: line floor met; branch unmeasurable by this instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by this gate: yes.
