# Post-Change Direct Repo-Root Module Run (AC-4 invariance harness, issue #409)

Timestamp: 2026-07-25T11-30

Command:
1. Direct repo-root module run of the fixed code (identical invocation to the [P0-T5] baseline):
   `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest"`
   (run from the repository root; `-Root` omitted so it defaults to the absolute `$PWD.ProviderPath`)
2. Copy to the evidence tree:
   `pwsh -NoLogo -NoProfile -Command "Copy-Item artifacts/pester/powershell-coverage.xml docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml -Force"`

EXIT_CODE: 0 (direct run: 0; copy: 0)

Post-change production state:
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` — git blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`, 463 lines.
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` — same blob hash.

Output Summary:
- Run result: **1345 passed, 0 failed, 9 skipped, 0 inconclusive, 0 not-run**, completed in 36.51 s. The [P0-T5] baseline direct run recorded 1341 passed; the increase of exactly 4 is the new test file.
- Replayed coverage headline: `Covered 89.68% / 0%. 3,266 analyzed Commands in 31 Files.` (baseline direct run: `Covered 89.64% / 0%. 3,253 analyzed Commands in 31 Files.`)
- Numeric line coverage: **90.22%** (report-level `LINE`: covered 2150, missed 233). Baseline 90.19% (covered 2143, missed 233).
- Numeric command/instruction coverage: **89.68%** (covered 2929, missed 337). Baseline 89.64% (covered 2916, missed 337).
- **Prune-message count in the run log: 0.** Verified with `grep -c "Pruned nonexistent code coverage path:"` against the captured run log. Disable-message count: 0. This is the required result: every one of this repository's configured coverage paths exists, so the fixed module prunes nothing here and behavior is unchanged.
  - Corroborated independently in [P3-T2]: `Import-PowerShellDataFile` over `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` reported `configured entries (raw): 32`, `configured entries (unique): 31`, `missing under repo root: 0`.
- Changed-file coverage, `scripts/powershell/PoshQC/PoshQC.Testing.psm1`:
  - LINE **100.00%** (covered 202, missed 0). Baseline: covered 195, missed 0. The 7 newly covered lines are the added pruning lines; none are missed.
  - INSTRUCTION **98.57%** (covered 276, missed 4). Baseline: covered 263, missed 4. The missed count is unchanged at 4 (pre-existing, not introduced by this change), so there is no coverage regression on changed lines.
- Post-change coverage XML preserved at `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml`.

Harness-parity statement: this run and the [P0-T5] baseline run used the **identical** direct-module invocation string, differing only in the content of `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (blob `53756b61a31c0a90b11e51e96f099fb6375c0af4` before, `e8d9a396aae9ed36645239f98ea08b62fd0bee93` after). The [P4-T5] comparison therefore isolates the code change and is not confounded by a harness difference. Neither run used the MCP tool, whose npx-cached 1.0.18 bundle would have executed pre-fix coverage-path resolution in both directions.
