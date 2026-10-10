# host-tools-manifest-and-bash-bootstrap-missing (Potential)

- Date captured: 2026-10-09
- Author: drmoisan
- Status: Draft
- Origin: issue #847 (PowerShell aggregate line coverage below floor), recorded as a pre-existing defect outside that issue's scope

## Problem / Why

`scripts/host-tools.manifest.json` is read by `scripts/dev-tools/bootstrap-host.ps1` (now through `scripts/dev-tools/HostBootstrap.psm1`) and by `scripts/dev-tools/verify-host.ps1` (now through `scripts/dev-tools/HostVerification.psm1`), but the file does not exist in the repository. Both scripts resolve the path as `scripts/dev-tools/../host-tools.manifest.json` and fail early on every host: bootstrap raises `Host tools manifest not found at <path>` and verify raises `Manifest not found at <path>`. Neither script can perform its documented work on any machine.

The bootstrap non-Windows precondition message reads `This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.`, but `scripts/bash/bootstrap-host.sh` does not exist either, so the message directs Linux and macOS users to a missing script.

Both defects predate #847. Issue #847 restructured these scripts into testable modules and preserved the existing behavior and messages unchanged, so the defects were recorded here instead of being fixed in that change.

## Proposed Behavior

- Restore `scripts/host-tools.manifest.json`, or relocate it and update the path returned by `Get-HostToolsManifestPath` in `scripts/dev-tools/HostTooling.psm1`, so that bootstrap and verify read a manifest that exists and contains the keys both modules read (`installPackages.windows.winget`, `powershellModules`, `projectRepositories`, `minimumVersions`, `requiredCommands`, `optionalCommands`, `pythonTools`).
- Either add `scripts/bash/bootstrap-host.sh` as the Linux and macOS bootstrap, or correct the non-Windows message in `Invoke-BootstrapHost` so it no longer names a missing script.

## Acceptance Criteria (early draft)

- [ ] A host tools manifest exists at the path `Get-HostToolsManifestPath` returns, and `verify-host.ps1` no longer fails with `Manifest not found at` on a supported host.
- [ ] `bootstrap-host.ps1` (dry run) no longer fails with `Host tools manifest not found at` on a supported Windows host.
- [ ] The manifest contains every key that `HostBootstrap.psm1` and `HostVerification.psm1` read, so neither module raises a StrictMode property error on it.
- [ ] The bootstrap non-Windows message names a script that exists, or `scripts/bash/bootstrap-host.sh` is added and covered by tests.
- [ ] A repository test fails if the manifest path returned by `Get-HostToolsManifestPath` does not exist.

## Constraints & Risks

- The manifest's original content is not in the repository; restoring it requires deciding the tool list and minimum versions rather than recovering a known file.
- Adding a bash bootstrap introduces a second implementation that must stay aligned with the PowerShell one; correcting the message is the smaller change.
- `scripts/dev-tools/HostTooling.psm1` path changes affect both bootstrap and verify; the existing #847 tests assert the unnormalized `dev-tools/../host-tools.manifest.json` form.

## Test Conditions to Consider

- [ ] Unit coverage areas: manifest schema validation against the keys the two modules read; the existence check for the resolved manifest path.
- [ ] Integration scenarios: `verify-host.ps1` run against the restored manifest on a CI runner with mocked or available tools.
- [ ] CLI/API examples: `./scripts/dev-tools/bootstrap-host.ps1` (dry run) and `./scripts/dev-tools/verify-host.ps1` exit codes with the manifest present.

## Next Step

- [ ] Promote to GitHub issue (bug report template), referencing #847
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
