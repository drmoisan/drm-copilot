# Bundled-mirror SHA-256 parity and delivery registrations

Timestamp: 2026-09-17T13-56

Tasks: `[P3-T4]` (remediation gate 4) and `[P3-T6]` of `remediation-plan.2026-09-17T12-29.md`
Batch: R-C

Command:

- **C6**, per pair:
  `Get-FileHash -LiteralPath '<repository copy>' -Algorithm SHA256; Get-FileHash -LiteralPath '<bundled copy>' -Algorithm SHA256`
  with the two `Hash` values compared with `-ceq`, plus a `Compare-Object` over the two files' content.
- For `[P3-T6]`:
  `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1' -Path '<file>'`
  run against the pack manifest and both `pester.runsettings.psd1` copies.

EXIT_CODE: 0 for every invocation.

Output Summary:

## `[P3-T4]` — SHA-256 equality for both repository-to-bundle pairs

### Pair 1 — `enforce-prd-feature-before-planner.ps1`

| side | path | SHA-256 |
| --- | --- | --- |
| repository | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | `D87B0E0DAA34023019630E22AD9C1C80059AEF2BF5531B3162221B30B4080B32` |
| bundled | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | `D87B0E0DAA34023019630E22AD9C1C80059AEF2BF5531B3162221B30B4080B32` |

`-ceq` comparison result: **True**. Both hash strings measure 64 characters.
`Compare-Object` difference-object count: **0**.

### Pair 2 — `enforce-prd-feature-before-planner-helpers.ps1`

| side | path | SHA-256 |
| --- | --- | --- |
| repository | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | `6529667B99D64205DB53AA43A0D895BAE164824C283E158012C6B027D82E123D` |
| bundled | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | `6529667B99D64205DB53AA43A0D895BAE164824C283E158012C6B027D82E123D` |

`-ceq` comparison result: **True**. Both hash strings measure 64 characters.
`Compare-Object` difference-object count: **0**.

All four hash values are recorded in full above, read from the run rather than written from memory, so a third
party can re-verify each by running `Get-FileHash` against the named path. Both `-ceq` comparisons are true.

### How the mirrors were re-synchronised — `[P3-T2]` and `[P3-T3]`

Each bundled copy was overwritten with the **byte content** of its repository counterpart, read and written
with `[System.IO.File]::ReadAllBytes` and `[System.IO.File]::WriteAllBytes`. A byte-level copy was used rather
than a text round-trip so that no line-ending or encoding normalisation could be introduced between the two
sides, which is what makes the SHA-256 equality above achievable rather than merely an equal line count.

Byte lengths written: 21,005 for pair 1 and 11,823 for pair 2.

`[P3-T2]` and `[P3-T3]` each require `Compare-Object` over the two files' content to produce **zero**
difference objects, and each does, as recorded per pair above. An equal line count alone is not accepted as
evidence of text identity, and none is offered: the evidence is the zero difference-object count plus the
byte-for-byte identical SHA-256.

## `[P3-T6]` — delivery registrations unchanged by this remediation

This remediation adds no file, so the registrations delivered earlier must be intact and unduplicated.

| # | file | occurrence count of `enforce-prd-feature-before-planner-helpers.ps1` | match line | required |
| --- | --- | --- | --- | --- |
| 1 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | **1** | 48 | exactly 1 |
| 2 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | **1** | 243 | exactly 1 |
| 3 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | **1** | 243 | exactly 1 |

Row 1 confirms the manifest `paths` entry criterion 33 requires. Rows 2 and 3 confirm both
`CodeCoverage.Path` registrations criterion 34 requires, at the same line number in each copy, which is
consistent with the two settings files being in parity.

The single match in row 2 is also what makes the `[P0-T6]` and `[P4-T3]` coverage reads well defined: the
allow-list registers the helpers sibling exactly once and registers no `claude-customizations` path, so no
bundled mirror is measured and no duplicate `sourcefile` leaf name can arise. `[P0-T6]` measured a
`sourcefile` match count of exactly 1 for each of the two leaf names, which confirms that property by
observation as well as by reading the settings file.

Acceptance for `[P3-T4]`: both comparisons are true and all four hash strings are recorded in full.
Satisfied.
Acceptance for `[P3-T6]`: each of the three searches returns exactly 1 match, recorded above and named beside
this task. Satisfied.
