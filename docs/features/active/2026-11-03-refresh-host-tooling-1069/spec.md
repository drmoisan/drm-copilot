# 2026-11-03-refresh-host-tooling — Spec

- **Issue:** #1069
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03T20-52
- **Status:** Draft
- **Version:** 0.1

## Overview

Align repository development tooling and bootstrap behavior with the host environment verified after its winget update. Apply the same supported baseline to both local and Codespaces devcontainers while retaining their platform-specific configuration and existing consumer compatibility.

The supplied research at `research/2026-11-04T01-54-refresh-host-tooling-research.md` is sufficient to define this change. It identifies existing installation seams, affected assertions, and available Linux packages; actual image builds must establish the Python runtime before an image is accepted.


## Behavior

Use `scripts/host-tools.manifest.json` as the Windows authority for minima Python 3.13.17, Node.js 26.13.0, PowerShell 7.6.9, and Poetry 2.3.2. Bootstrap checks installed versions for these managed tools. Missing tools are installed and stale tools upgraded only in apply mode; dry run reports the intended work without invoking installation. Equal or newer versions remain unchanged. Tools without a declared minimum retain their current missing-command behavior.

An unreadable installed managed-tool version produces a clear diagnostic and failure rather than a false compliance result. Native installation failures propagate through the existing streamed-process seams. A successful bootstrap must meet the existing final host-verification checks; no downgrade is performed to reproduce a patch already exceeded by a host.

Both container images provide Python 3.13.17 or newer within the 3.13 series, Node.js 26.13.0 with npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, shfmt 3.14.1, ShellCheck 0.11.0, and actionlint 1.7.12. Shared verification checks the selected versions and rejects stale required tooling. Preserve local mounts and Docker features and Codespaces resource settings. Retain unrelated existing CLI pins.

Development CI uses the selected Node.js, Poetry, and shell-tool baseline. Existing Python 3.11 and 3.12 compatibility jobs and consumer package engines remain unchanged; release-publishing runtime pins are independent infrastructure and need no mechanical version replacement for this feature.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars): existing `bootstrap-host.ps1` flags, `scripts/host-tools.manifest.json`, both Dockerfiles/devcontainer configurations, and shared container scripts. Preserve existing flag names and meanings.
- Outputs (artifacts, logs, telemetry): explicit bootstrap compliance/change/error messages, updated image/tooling declarations, and build/runtime/test results under this feature's `evidence/<kind>/` directories. No new telemetry is required.
- Config keys and defaults: retain the manifest's existing keys; update `minimumVersions.python`, `.node`, and `.pwsh`; retain `.poetry` at 2.3.2. Shell-tool pins remain explicit at their existing installation sites.
- Versioning or backward-compatibility constraints: optional minimum-version parameters preserve existing callers; unmanaged commands keep existing behavior. Python package support, compatibility matrix entries, package engines, and unrelated release pins remain intact.

## API / CLI Surface

The public entry point remains `scripts/dev-tools/bootstrap-host.ps1`. Preserve `-Apply`, `-EnableAutoResumeAfterReboot`, `-WorkspaceRoot`, `-RepoRoot`, and `-SkipProjectPoetryInstall`; this feature adds no public command.

- Example invocations with expected outputs (concise): `pwsh -NoProfile -File scripts/dev-tools/bootstrap-host.ps1` previews missing/stale managed-tool work without installation; adding `-Apply` performs required installation or upgrades and runs existing verification. Existing workspace and Poetry-install options keep their meanings.
- Contracts and validation rules: compare parsed installed versions with manifest minima; preserve equal/newer versions, report unreadable versions explicitly, and propagate native failures. Do not infer an installed version from winget's available-upgrade column.

## Data & State

The existing manifest is read and its managed minima are passed to the existing bootstrap installation helpers. Existing verification consumes the same minima; container and development CI declarations are synchronized and guarded by relevant tests.

- Data transformations and invariants: command output is parsed to a version for comparison; unknown versions are not compliant. Apply mode alone changes installed tooling, compliant newer tools are not downgraded, and no package IDs are inferred from command names.
- Caching or persistence details: retain existing bootstrap workspace/resume behavior. Do not introduce a new state store or cache.
- Migration or backfill requirements (if any): no repository data migration. Existing host installations are evaluated against the new minima on the next bootstrap run.

## Constraints & Risks

Windows version strings and Linux package versions differ. The research verified amd64 NodeSource `26.13.0-1nodesource1` and Microsoft Debian `7.6.9-1.deb`; do not claim other architecture support without verification. Use the existing package/download mechanisms and preserve architecture handling where supported.

The supported Python minor image tag is `3.13-bookworm`; an exact `3.13.17-bookworm` tag was not found. Determine its actual runtime during validation and use a verified supported installation method if the image lags the required patch. Do not introduce an invented tag or a knowingly failing version assertion.

The shfmt update may change formatting of existing shell scripts. Include only required formatter changes and validate shared `.devcontainer` scripts explicitly because they are outside ordinary shell-QC discovery. Do not upgrade the host, change release behavior, or add unrelated tool dependencies.


## Implementation Strategy

- Implementation scope (what changes, not sequencing): host manifest and its asserting tests; `HostBootstrap.psm1` and affected bootstrap/verification tests; both Dockerfiles and shared verification/setup scripts; relevant development CI pins and workflow contracts; current README/devcontainer guides; affected execution-environment mirrors.
- New classes/functions/commands to add or update: extend existing `Install-WithWinget` and Poetry fallback behavior with optional manifest minimum handling through established command/version/native-process seams. Keep `bootstrap-host.ps1` thin; do not add a generic process framework.
- Dependency changes (new/removed packages) and rationale: no new library dependency; use existing winget, pip, apt, and release-download mechanisms to obtain verified versions.
- Logging/telemetry additions and locations: report installed version, required minimum, planned/performed change, and specific errors through existing bootstrap output. No telemetry service is added.
- Rollout plan (feature flags, staged deploys, fallback path): retain existing dry-run/apply control. Rebuild each devcontainer and run its runtime verifier. Development CI validates the branch without publishing releases.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos: AC1–AC7 in `issue.md` and `user-story.md`, with manifest/bootstrap tests, configuration checks, and actual image verification.
- [ ] Behavior matches acceptance criteria in all documented environments: Windows bootstrap and both local/Codespaces image builds meet AC1–AC5.
- [ ] Tests updated/added (unit/integration as applicable): manifest/version-selection and existing bootstrap assertions plus relevant workflow/container contracts cover AC1–AC6.
- [ ] Edge cases and error handling covered by tests: missing, below, equal, newer, unreadable, dry-run, and failed-install scenarios prove AC2–AC3.
- [ ] Docs updated (README, docs/features/active/... links): current development guidance and affected mirrors satisfy AC6 while describing intentional compatibility differences.
- [ ] Telemetry/logging added or updated (if applicable): existing bootstrap output identifies compliance, planned work, and errors for AC2–AC3; no new telemetry is needed.
- [ ] Toolchain pass completed (format → lint → type-check → test): applicable coverage/isolation checks and both actual image build/runtime results satisfy AC7 with canonical evidence.

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: managed-tool and Poetry minimum boundaries, unreadable output, native failure propagation, dry-run side effects, and unchanged unmanaged-command behavior.
- [ ] Integration scenarios: both actual Docker builds and shared runtime verification; development workflow and mirrored-document contracts.
- [ ] CLI/API examples: existing bootstrap dry run and `-Apply` retain their flags and report the selected manifest requirements.
