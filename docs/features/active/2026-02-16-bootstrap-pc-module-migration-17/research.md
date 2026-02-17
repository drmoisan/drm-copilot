# Task Research Notes: Bootstrap host tooling migration to BootstrapPC module

## Scope and Outcome

This research covers a no-shim migration of host bootstrap tooling from legacy script locations into `scripts/powershell/BootstrapPC`, with all callers/tests/tasks redirected to the new canonical location.

### In-Scope

- Re-home PowerShell bootstrap + verify implementation and helpers into `scripts/powershell/BootstrapPC`.
- Relocate manifest ownership from `scripts/host-tools.manifest.json` into module-local assets.
- Redirect all task, doc, test, and script references.
- Remove legacy entry points (no compatibility wrappers/shims in `scripts/dev-tools`).

### Out-of-Scope

- New host bootstrap features.
- Changes to package/version policy semantics in the manifest beyond path relocation.

## Current State Summary (Observed)

- `scripts/powershell/BootstrapPC` exists but is currently empty.
- Legacy implementation is active in:
  - `scripts/dev-tools/bootstrap-host.ps1`
  - `scripts/dev-tools/bootstrap-host.helpers.ps1`
  - `scripts/dev-tools/verify-host.ps1`
  - `scripts/host-tools.manifest.json`
- PowerShell and Bash task wiring still points to legacy script/manifest paths via `.vscode/tasks.json`.
- Unit tests are still anchored to `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` with hardcoded legacy path expectations.
- Docs still instruct users to run legacy script paths in `docs/developer-tooling.md`.

## Affected Files

## Source of truth and runtime scripts

- Migrate from:
  - `scripts/dev-tools/bootstrap-host.ps1`
  - `scripts/dev-tools/bootstrap-host.helpers.ps1`
  - `scripts/dev-tools/verify-host.ps1`
  - `scripts/host-tools.manifest.json`
- Migrate to (recommended target set):
  - `scripts/powershell/BootstrapPC/BootstrapPC.psm1`
  - `scripts/powershell/BootstrapPC/BootstrapPC.psd1`
  - `scripts/powershell/BootstrapPC/bootstrap-host.ps1`
  - `scripts/powershell/BootstrapPC/verify-host.ps1`
  - `scripts/powershell/BootstrapPC/host-tools.manifest.json`

## Task wiring

- Update `.vscode/tasks.json`:
  - `Dev: Host Bootstrap (PowerShell)` path arg currently targets `scripts/dev-tools/bootstrap-host.ps1`.
  - `Dev: Host Verify (PowerShell)` path arg currently targets `scripts/dev-tools/verify-host.ps1`.
  - Task `detail` strings currently mention `scripts/host-tools.manifest.json`.

## Bash host tooling integration

- Update manifest references in:
  - `scripts/bash/bootstrap-host.sh`
  - `scripts/bash/verify-host.sh`
- Both scripts currently compute `MANIFEST_PATH` as `${SCRIPT_DIR}/../host-tools.manifest.json`; this must point to the new module-local manifest.

## Tests

- Move and retarget:
  - from `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`
  - to `tests/scripts/powershell/BootstrapPC/bootstrap-host.Tests.ps1`
- Update test assumptions and mocks that hardcode legacy paths:
  - `...\scripts\dev-tools\bootstrap-host.ps1`
  - `...\scripts\dev-tools\verify-host.ps1`
  - `...\scripts\host-tools.manifest.json`
- Preserve Pester coverage attribution for migrated entry points/module functions.

## Documentation

- Update user guidance in `docs/developer-tooling.md` to new PowerShell paths and new manifest location statement.
- Update active feature docs (`issue.md`, `spec.md`, `user-story.md`) if they need to reflect final concrete paths once implementation stabilizes.

## Scripts and user-facing text

- Update legacy recommendation string in `scripts/dev-tools/verify-host.ps1` currently showing `Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply` (or remove file entirely when decommissioned).

## Suggested Migration Sequence (No-Shim)

1. **Freeze and baseline references**
   - Capture `grep` baseline for `bootstrap-host.ps1`, `verify-host.ps1`, and `host-tools.manifest.json` references across `scripts/`, `tests/`, `.vscode/`, and `docs/`.
   - Record expected deletions/redirects before touching code.

2. **Create module contract first**
   - Define exported command surface in `BootstrapPC.psm1`/`BootstrapPC.psd1`.
   - Move helper logic from `bootstrap-host.helpers.ps1` into internal module functions.
   - Keep command names stable where possible (`Invoke-BootstrapHost`, verify helpers).

3. **Relocate manifest ownership**
   - Move `scripts/host-tools.manifest.json` into `scripts/powershell/BootstrapPC/host-tools.manifest.json`.
   - Replace relative path assumptions with a module-local manifest resolver used by both new PowerShell entry points.

4. **Re-home entry point scripts**
   - Create module-hosted script entry points at:
     - `scripts/powershell/BootstrapPC/bootstrap-host.ps1`
     - `scripts/powershell/BootstrapPC/verify-host.ps1`
   - Ensure they import/call module commands and preserve existing CLI parameters/exit behavior.

5. **Redirect all invocations**
   - Update `.vscode/tasks.json` PowerShell task paths + detail text.
   - Update Bash scripts to consume the relocated manifest path.
   - Update docs to only advertise new paths.

6. **Migrate tests before deletion**
   - Move `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` to module test folder.
   - Update path mocks and assertions to new locations/messages.
   - Verify Pester passes against module-hosted scripts/functions.

7. **Remove legacy files (no shim policy enforcement point)**
   - Delete:
     - `scripts/dev-tools/bootstrap-host.ps1`
     - `scripts/dev-tools/bootstrap-host.helpers.ps1`
     - `scripts/dev-tools/verify-host.ps1`
     - `scripts/host-tools.manifest.json`
   - Do not add wrappers that forward from old to new paths.

8. **Post-migration reference gate**
   - Run search gate to ensure no active references remain to removed paths (exclude archived artifacts if needed).
   - Resolve any remaining docs/tests/task strings.

## No-Shim Enforcement Rules

- Legacy path scripts must be physically removed, not converted to forwarding wrappers.
- Any new reference to legacy paths should fail review.
- Add a CI/review checklist item: “0 active references to removed host-tooling paths outside historical artifacts.”

## Risk List and Mitigations

1. **Hidden references break tooling after deletion**
   - Mitigation: run targeted repo-wide searches before and after deletion; treat `.vscode/tasks.json`, docs, and tests as mandatory update targets.

2. **Manifest relocation breaks Bash scripts**
   - Mitigation: update both `scripts/bash/bootstrap-host.sh` and `scripts/bash/verify-host.sh` in the same change; smoke test both scripts in dry-run/verify modes.

3. **Behavior drift while moving helper functions**
   - Mitigation: migrate tests early and keep function contracts + output messages stable unless intentionally changed.

4. **Coverage attribution and test loading regressions**
   - Mitigation: keep explicit dot-source/import strategy in Pester tests and verify coverage output still maps to the new source files.

5. **Windows resume command path becomes stale**
   - Mitigation: update RunOnce command construction to point at new `bootstrap-host.ps1` location and add/adjust dedicated tests.

6. **Documentation drift after path migration**
   - Mitigation: update `docs/developer-tooling.md` in the same PR and re-check for old-path strings.

## QA Checklist (Implementation Exit Criteria)

## Functional checks

- [ ] PowerShell bootstrap task executes new path (`Dev: Host Bootstrap (PowerShell)`).
- [ ] PowerShell verify task executes new path (`Dev: Host Verify (PowerShell)`).
- [ ] Bash bootstrap/verify still function with relocated manifest path.
- [ ] `-EnableAutoResumeAfterReboot` resume flow points to new script path.

## No-shim and reference checks

- [ ] Legacy files deleted (no forwarding wrappers in `scripts/dev-tools`).
- [ ] No active references remain to:
  - `scripts/dev-tools/bootstrap-host.ps1`
  - `scripts/dev-tools/verify-host.ps1`
  - `scripts/host-tools.manifest.json`
- [ ] Docs and task details reference only new canonical locations.

## Required PowerShell toolchain loop (repo policy)

Run in order, and restart from step 1 if any step changes files or fails:

1. `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
2. `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
3. `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

## Broader regression checks (because tasks/docs are edited)

- [ ] Validate `.vscode/tasks.json` formatting/validity using repo JSON tooling.
- [ ] Re-run any impacted cross-language checks if migration touches shared scripts/docs consumed by non-PowerShell workflows.

## Recommended PR Review Checklist

- [ ] New canonical runtime path is clearly documented and used everywhere.
- [ ] Legacy paths are absent in live code/tests/tasks/docs.
- [ ] Bootstrap/verify behavior remains feature-equivalent to pre-migration implementation.
- [ ] Policy-required PowerShell format/analyze/test loop is green in one final pass.
