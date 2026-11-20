# host-bootstrap-output-buffering-and-publish-whatif-forwarding (Issue #888)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/host-bootstrap-output-buffering-and-publish-whatif-forwarding/ (Issue #888)
- Origin: issue #847 (PR #871), code-review findings CR-N1 and CR-N2; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #888
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/888
- Last Updated: 2026-10-11
## Summary

The #847 restructuring of the host scripts into modules introduced two behavior changes that the spec did not accept: (1) `bootstrap-host.ps1` no longer streams native-command output live, because `Invoke-HostNativeCommand` captures it in a variable; (2) `publish-sideloaded-extension.ps1` forwards `-WhatIf` (and `-Confirm`, `-Verbose`) to its module only when the switch is bound on that script's own command line, so an inherited `$WhatIfPreference` no longer suppresses publish steps.

## Environment

- OS/version: Windows 11 (host bootstrap)
- Python version: n/a (PowerShell 7)
- Command/flags used: `./scripts/dev-tools/bootstrap-host.ps1`; a parent script run with `-WhatIf` that calls `./scripts/dev-tools/publish-sideloaded-extension.ps1` without `-WhatIf`
- Data source or fixture: main at 2ef8d361; `scripts/dev-tools/HostTooling.psm1`, `scripts/dev-tools/publish-sideloaded-extension.ps1`

## Steps to Reproduce

1. Run `bootstrap-host.ps1` on a host where winget, npm or pip installs take noticeable time; observe when output appears.
2. Write a wrapper script with `[CmdletBinding(SupportsShouldProcess)]`, run it with `-WhatIf`, and have it call `publish-sideloaded-extension.ps1` without passing `-WhatIf`.
3. Observe whether the publish steps execute.

## Expected Behavior

- Bootstrap streams install progress as before #847 (DR-1 accepted an output-timing change only for `verify-host.ps1`).
- An inherited `$WhatIfPreference = $true` suppresses the publish steps, as it did before the refactor.

## Actual Behavior

- `scripts/dev-tools/HostTooling.psm1:124-129` (`Invoke-HostNativeCommand`) assigns native output to a variable; output appears only after each process exits, and tools that detect redirected stdout may suppress progress bars. Callers: the winget, npm, wsl, git and poetry wrappers in `HostBootstrapWorkspace.psm1` and `HostBootstrap.psm1:144` (pip).
- `scripts/dev-tools/publish-sideloaded-extension.ps1:58-83` forwards only explicitly bound `-WhatIf`, `-Confirm`, `-Verbose` and `-WarningAction`; `-Debug`, `-InformationAction` and `-ErrorAction` are not forwarded.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/code-review.2026-10-10T01-41.md:92` (CR-N1): "`Invoke-HostNativeCommand` assigns native output to a variable, so bootstrap's long-running installs no longer stream progress ... The spec accepts an output-timing change only for `verify-host.ps1`, so this is an undocumented deviation from DR-1."
- Snippet: same file, line 93 (CR-N2): "an inherited `$WhatIfPreference = $true` (for example a parent script run with `-WhatIf` that calls this script without `-WhatIf`) no longer suppresses the steps."
- PR #871 lists both as "Accepted non-blocking review notes" but not under Follow-ups. Feature audit FA-N2 (`feature-audit.2026-10-10T01-41.md:87`) repeats CR-N1.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. The `-WhatIf` change can cause a dry run to perform real publish steps when the script is called from another script. The streaming change affects operator feedback only.

## Suspected Cause / Notes

- Output capture was introduced to make exit codes testable through a seam; the capture also buffers output.
- Forwarding uses `$PSBoundParameters` rather than the effective preference variables.
- Related low-severity notes from the same review: CR-N3 (modules imported without `-Force` stay loaded after a run) and CR-N4 (`HostTooling.psm1:131-134` reads a possibly stale global `$LASTEXITCODE`).
- The missing `scripts/host-tools.manifest.json` and `scripts/bash/bootstrap-host.sh` are a separate, pre-existing defect tracked in `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md`.

## Proposed Fix / Validation Ideas

- [ ] Stream through the pipeline (for example `& $FilePath @ArgumentList | ForEach-Object { $_ }`) and read the exit code afterward.
- [ ] Forward effective values: `WhatIf = $WhatIfPreference`, `Confirm` from `$ConfirmPreference`, `Verbose` from `$VerbosePreference`.
- [ ] Unit coverage areas: Pester tests asserting that a caller's `$WhatIfPreference` suppresses publish steps, and that native output is emitted to the pipeline as it is produced.
- [ ] Manual verification notes: run bootstrap on a clean host and confirm progress is visible during installs.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch