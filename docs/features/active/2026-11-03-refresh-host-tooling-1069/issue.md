# refresh-host-tooling (Issue #1069)

- Date captured: 2026-11-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/refresh-host-tooling/ (Issue #1069)

- Issue: #1069
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1069
- Last Updated: 2026-11-04
- Work Mode: full-feature

## Problem / Why

The host was updated using winget, but repository tooling still declares older Node.js, Python, and PowerShell baselines. Both devcontainers and their shared verifier also retain older Poetry, Node.js, and shell-tool versions, so development and bootstrap results can differ across environments.

## Proposed Behavior

Synchronize the existing host manifest, host bootstrap and verification, both local and Codespaces devcontainers, development CI tooling, and current setup documentation with the verified environment. The development baseline is Python 3.13.17, Node.js 26.13.0 with npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, shfmt 3.14.1, ShellCheck 0.11.0, and actionlint 1.7.12 where applicable.

Bootstrap must detect managed tools below the manifest minimum, preview required changes without side effects, and install or upgrade them only with `-Apply`. Equal or newer installed versions remain unchanged. Preserve Python compatibility testing on 3.11 and 3.12, consumer package engine requirements, and platform-specific container settings.

## Acceptance Criteria (early draft)

- [x] AC1: `scripts/host-tools.manifest.json` declares Python 3.13.17, Node.js 26.13.0, PowerShell 7.6.9, and Poetry 2.3.2 minima; existing package IDs and command classifications remain valid.
- [x] AC2: Bootstrap installs missing managed tools and upgrades below-minimum managed tools only with `-Apply`; dry run performs no installation, and equal or newer versions are preserved without downgrades.
- [x] AC3: Bootstrap reports unreadable installed versions and native installation failures explicitly, propagates failure, and never reports an unverified managed tool as compliant; deterministic tests cover these errors and minimum-version boundaries.
- [ ] AC4: Both local and Codespaces images build and provide Python 3.13.17 or newer within 3.13, Node.js 26.13.0/npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, shfmt 3.14.1, ShellCheck 0.11.0, and actionlint 1.7.12; their shared verifier accepts that baseline and rejects stale required versions.
- [ ] AC5: Local mounts and Docker features, Codespaces resource settings, Python 3.11/3.12 compatibility testing, and consumer package engine requirements are preserved.
- [ ] AC6: Development CI pins, the shared container scripts, README development guidance, current devcontainer guides, and any affected execution-environment mirrors consistently describe the selected baseline and intentional compatibility differences.
- [ ] AC7: Changed behavior and configuration contracts pass the applicable ordered toolchains, coverage and isolation checks; actual build and runtime-verification results for both containers are recorded in canonical feature evidence.

## Constraints & Risks

Do not upgrade the host further or treat winget's available upgrades as installed versions. Use real, verified image tags and platform package versions: the registry does not list `3.13.17-bookworm`, so verify the actual Python runtime in the supported minor image and use a verified installation method if it is below the required patch.

Keep release-publishing runtime pins and unrelated CLI versions unchanged unless a development requirement depends on them. Do not add a configuration framework, change consumer compatibility, publish releases, or replace platform-specific devcontainer settings. No new dependency is required by the selected approach.

## Test Conditions to Consider

- [ ] Unit coverage areas: missing, below-minimum, equal, newer, unreadable, and failed-install cases for managed tools and Poetry; fixtures isolate native executable calls.
- [ ] Integration scenarios: real builds and version verification of both container images, plus development workflow/configuration parity checks.
- [ ] CLI/API examples: bootstrap dry-run output previews stale-tool work; `-Apply` uses the manifest minima without downgrading compliant tools.

## Next Step

- [x] Promote to GitHub issue (feature request template): issue #1069.
- [x] Create `docs/features/active/refresh-host-tooling/` folder from the template: `docs/features/active/2026-11-03-refresh-host-tooling-1069/`.

