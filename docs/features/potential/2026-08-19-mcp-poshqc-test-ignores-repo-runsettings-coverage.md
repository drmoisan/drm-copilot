# mcp-poshqc-test-ignores-repo-runsettings-coverage (Potential Bug)

- Date captured: 2026-08-19
- Author: Dan Moisan
- Status: Draft
- Severity: High — every coverage gate driven through the MCP tool measures a stale, bundled file set

## Summary

`mcp__drm-copilot__run_poshqc_test` does not consume the repository's
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. It resolves its own bundled copy from
inside the published MCP package. Consequently any module registered in the repository's
`CodeCoverage.Path` opt-in array is not measured when coverage is produced through the MCP tool, and
a coverage gate that relies on that path passes vacuously.

## Root cause

`.mcp.json` runs the server as `npx -y @danmoisan/drm-copilot-mcp`. Its template
`resources/templates/run-poshqc-test.ps1` imports `..\powershell\PoshQC\PoshQC.psd1` from inside the
published package, and `PoshQC.psm1:3` resolves `settings/pester.runsettings.psd1` relative to that
module root. The repository copy is never read, so repository-side edits to `CodeCoverage.Path` have
no effect on an MCP-produced coverage run.

## Reproduction

Observed in worktree `drm-copilot-wt/2026-08-19T08-39` during issue #491 preflight, using
`BlastRadiusNormalization.psm1` — a module registered in the repository runsettings by issue #489 —
as the probe.

1. Produce coverage through the MCP tool by calling `mcp__drm-copilot__run_poshqc_test`, then count
   occurrences in the emitted report:

   ```
   grep -c "BlastRadiusNormalization.psm1" artifacts/pester/powershell-coverage.xml
   ```

   Observed: 0.

2. Produce coverage through the repository module:

   ```
   pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"
   ```

   Then count again in the emitted report. Observed: 2.

Same repository, same registered module, same output path. The only variable is which runsettings
file was resolved.

## Impact

- Every module currently registered in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  under `CodeCoverage.Path` is unmeasured on the MCP path. This is not specific to one feature; the
  registrations added by issue #489 are affected identically.
- A plan or QA gate that registers a new file for coverage and then verifies coverage through the MCP
  tool cannot fail, because the file it registered is absent from the report it inspects. The gate
  reports success while measuring nothing.
- The divergence is silent. Both runs write `artifacts/pester/powershell-coverage.xml` and both
  report `ok: true`; nothing in either result signals which runsettings file was used.

## Workaround in use

Issue #491's plan takes coverage figures exclusively from the repository-module invocation above, in
both the baseline and the final run so the delta compares like methods, and states explicitly that
the MCP tool is never a coverage source. The MCP call is retained only as the policy-mandated gate.

## Proposed Fix

Options, in rough order of preference:

1. Have the MCP `run_poshqc_test` tool accept and prefer a workspace-resident runsettings file when
   one exists at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, falling back to the
   bundled copy only when absent.
2. Have the tool report which runsettings file it resolved, in its returned `summary` and in the
   emitted report, so a silent divergence becomes a visible one.
3. If the bundled-only behavior is intentional, document it in `.claude/rules/powershell.md` and in
   the PoshQC skill, and state that coverage registration is effective only for repository-module
   runs.

Option 2 is worth doing regardless of whether 1 or 3 is chosen, because the present failure mode is
indistinguishable from success at the call site.

## Test Conditions to Consider

- [ ] A module registered only in the repository runsettings appears in the coverage report produced
      by the MCP tool after the fix, or the tool's output states that the bundled runsettings was
      used.
- [ ] Baseline and final coverage runs performed through the same channel report the same file set.
- [ ] Negative control: a module absent from every `CodeCoverage.Path` entry does not appear in the
      report, so the fix does not simply measure everything.
- [ ] A repository with no local runsettings file still succeeds via the bundled copy.

## Next Step

- [ ] Promote to GitHub issue (bug template)
- [ ] Audit existing coverage gates that cite `CodeCoverage.Path` for vacuous-pass exposure, starting
      with those added by issue #489.
