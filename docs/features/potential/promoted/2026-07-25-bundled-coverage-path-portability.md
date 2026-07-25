# bundled-coverage-path-portability (Issue #409)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bundled-coverage-path-portability/ (Issue #409)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #409
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/409
- Last Updated: 2026-07-25
## Summary

The MCP server's bundled PoshQC Pester configuration ships this repository's own `CodeCoverage.Path` list. When `mcp__drm-copilot__run_poshqc_test` runs against a different consumer repository, those paths do not exist, and the Pester run fails at RunStart even though test discovery succeeded.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- MCP server version: `@danmoisan/drm-copilot-mcp` 1.0.18
- Command/flags used: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` pointing at the TaskMaster repository
- Data source or fixture: TaskMaster repository checkout (external consumer repo, not drm-copilot)

## Steps to Reproduce

1. Install `@danmoisan/drm-copilot-mcp` 1.0.18 and register it as an MCP server.
2. Open a consumer repository that is not drm-copilot (observed with a repository named TaskMaster) containing PowerShell Pester suites.
3. Invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to that consumer repository root.
4. Observe that Pester discovers the consumer repo's tests (30 tests observed) and then fails during RunStart.

## Expected Behavior

`run_poshqc_test` runs the consumer repository's discovered Pester tests to completion. Coverage instrumentation is scoped to files that actually exist in the target workspace; coverage paths that do not exist in the target workspace do not abort the run.

## Actual Behavior

The run aborts during Pester RunStart. The bundled coverage configuration at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (mirrored into the MCP package as `resources/powershell/PoshQC/settings/pester.runsettings.psd1` by `packages/mcp-server/prepack.cjs`) enumerates drm-copilot-specific `CodeCoverage.Path` entries, including `scripts/powershell/Publish-DrmCopilotExtension.ps1`. `Invoke-PoshQCTest` joins each entry to the supplied `-Root` and passes the result to Pester without checking existence, so in TaskMaster every coverage path resolves to a nonexistent file.

Reported error text:

> MCP version 1.0.18 discovers 30 tests but fails during Pester RunStart because its bundled coverage configuration references the nonexistent TaskMaster path `scripts/powershell/Publish-DrmCopilotExtension.ps1`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: consumer-repo evidence artifact reported by the user at `docs/features/active/2026-07-21-quickfiler-folder-selector-dropdown-400/evidence/regression-testing/coverage-wrapper-poshqc-test-blocker-retry.2026-07-25T03-33.md` (path is inside the TaskMaster checkout, not this repository).

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The PowerShell test stage of the mandatory toolchain cannot run in any consumer repository through the MCP surface, which blocks orchestration runs in those repositories.

## Suspected Cause / Notes

- `scripts/powershell/PoshQC/PoshQC.psm1` line 3 resolves `$script:PesterSettings` to the module-relative `settings/pester.runsettings.psd1`, so the bundled repo-specific settings file is the default for every consumer repository.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (`Invoke-PoshQCTest`, `$ExpandCoveragePaths` and the coverage-enabled block) joins each configured `CodeCoverage.Path` entry to `-Root` with no existence filter and no fallback when the surviving set is empty.
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` locks `settings/pester.runsettings.psd1` to exact text parity between `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`, so the bundled copy cannot simply be given a different, repo-neutral coverage list without addressing that parity contract.
- Files to inspect: `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, the bundled mirrors of both, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `Invoke-PoshQCTest` coverage-path resolution — nonexistent-path pruning, empty-surviving-set behavior, and preservation of existing behavior when all paths exist.
- [x] Integration scenario to retest: run the bundled `run-poshqc-test.ps1` entry point against a workspace root that contains Pester tests but none of the configured coverage paths, and confirm the run completes.
- [x] Manual verification notes: confirm the drm-copilot repository's own coverage numbers are unchanged after the fix, since every configured path exists here.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
