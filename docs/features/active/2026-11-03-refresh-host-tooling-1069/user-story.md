# `2026-11-03-refresh-host-tooling` — User Story

- Issue: #1069
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-03T20-52

## Story Statement

- As a repository maintainer, I want bootstrap and verification to use the installed host's supported toolchain baseline, so that a machine with older tools receives a clear preview and a controlled upgrade path.
- As a local or Codespaces contributor, I want both devcontainers and development CI to use consistent tooling, so that validation results are comparable across supported development environments.

## Problem / Why

The host was updated using winget while repository manifests, container installations, and shared checks still contain older versions. Bootstrap currently skips existing commands without establishing that their versions meet the selected minimum. Synchronizing declarations and version-aware behavior makes the supported environment explicit while preserving consumer compatibility.


## Personas & Scenarios

- Persona: repository maintainer working on Windows.
  - Cares about using the verified Python, Node.js, PowerShell, and Poetry baseline without unnecessary host changes.
  - Needs dry-run visibility, explicit failure reporting, and preservation of equal/newer installed tools.
- Persona: contributor using either local Docker or Codespaces.
  - Needs the same development tools while retaining local mounts/Docker access or Codespaces resource settings.
- Scenario: after the host tool update, a maintainer runs bootstrap without `-Apply`, reviews missing/stale managed-tool output, and uses `-Apply` only when changes are needed. Compliant tools remain unchanged; an unreadable version or native installation failure is reported explicitly. A contributor rebuilds either container and runs the shared verifier, which reports the selected supported versions; development validation uses matching pins while older Python compatibility jobs remain available.


## Acceptance Criteria

- [x] AC1: `scripts/host-tools.manifest.json` declares Python 3.13.17, Node.js 26.13.0, PowerShell 7.6.9, and Poetry 2.3.2 minima; existing package IDs and command classifications remain valid.
- [x] AC2: Bootstrap installs missing managed tools and upgrades below-minimum managed tools only with `-Apply`; dry run performs no installation, and equal or newer versions are preserved without downgrades.
- [x] AC3: Bootstrap reports unreadable installed versions and native installation failures explicitly, propagates failure, and never reports an unverified managed tool as compliant; deterministic tests cover these errors and minimum-version boundaries.
- [ ] AC4: Both local and Codespaces images build and provide Python 3.13.17 or newer within 3.13, Node.js 26.13.0/npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, shfmt 3.14.1, ShellCheck 0.11.0, and actionlint 1.7.12; their shared verifier accepts that baseline and rejects stale required versions.
- [ ] AC5: Local mounts and Docker features, Codespaces resource settings, Python 3.11/3.12 compatibility testing, and consumer package engine requirements are preserved.
- [ ] AC6: Development CI pins, the shared container scripts, README development guidance, current devcontainer guides, and any affected execution-environment mirrors consistently describe the selected baseline and intentional compatibility differences.
- [ ] AC7: Changed behavior and configuration contracts pass the applicable ordered toolchains, coverage and isolation checks; actual build and runtime-verification results for both containers are recorded in canonical feature evidence.


## Non-Goals

Further host upgrades, consumer engine changes, removal of Python 3.11/3.12 compatibility jobs, release publishing, unrelated CLI upgrades, a new configuration framework, and replacement of platform-specific devcontainer settings are excluded. Release-publishing runtime pins may remain independent of the development baseline.
