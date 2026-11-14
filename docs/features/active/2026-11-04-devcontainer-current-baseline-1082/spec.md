# 2026-11-04-devcontainer-current-baseline-1082 (Spec)

- **Issue:** #1082
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-04T21-35
- **Status:** Draft
- **Version:** 0.1

## Context

Local Docker used a separately seeded persistent Git checkout, which could be incomplete or differ from the host source. A missing-`HEAD` repair addressed the immediate startup error but left outdated pins and missing tools. Both configurations must produce the complete user-supplied development baseline and run shared setup against their actual workspace.

- Observed environment(s): Windows host checkout with Docker Desktop Linux containers; Debian Bookworm container; local and Codespaces configurations.
- Customer impact and severity (who is affected, how often, how bad): High; the user cannot rely on a rebuilt environment containing current source and the required tools.
- First observed date and version(s) impacted: Reported 2026-11-04 on the `fix/dev-container` branch; see [issue #1082](https://github.com/drmoisan/drm-copilot/issues/1082).

## Repro & Evidence

- Steps to reproduce (with data/flags/inputs): Rebuild `.devcontainer/local/devcontainer.json`, inspect the mounted workspace and installed tools, and compare them with the user's supplied baseline.
- Expected vs actual behavior: Rebuild should expose current source and install the complete selected baseline. The separate workspace initially had no valid `HEAD`; after recovery, the user still reported incorrect dependencies. The old verifier checked an outdated subset.
- Logs/screenshots/error snippets: `fatal: ambiguous argument 'HEAD': unknown revision or path not in the working tree.` The promoted report records the user's follow-up and required versions.
- Frequency / determinism (always, intermittent, data-dependent): Missing `HEAD` depends on an interrupted seed; stale source depends on persistent-volume state. Missing and outdated image tools follow deterministically from the current Dockerfiles and version contracts.

## Scope & Non-Goals

- In scope: Both container builds/configurations; direct local source mounting; isolated Linux dependencies; shared setup and complete verification; relevant host bootstrap, CI and documentation contracts; Pester 6.2.0 migration; regression, runtime and coverage evidence.
- Out of scope / non-goals: Replacing application dependencies unrelated to the tool baseline, altering consumer compatibility, changing orchestration behavior, or adding a new container platform.
- Explicitly excluded systems, integrations, or datasets: Host source/data deletion, removal of the previous workspace volume, migration of user credentials, and changes to published VS Code engine ranges or the Python 3.11/3.12 compatibility jobs.

## Root Cause Analysis

- Current hypothesis or confirmed root cause: The local bootstrap treated persistent Git state as a source of truth separate from the host. Both images and the verifier retained an older baseline; omitted tools could not fail checks that never inspected them.
- Signals/evidence supporting it: The reported exit 128, root's inspection of the incomplete volume, user rejection of the older dependency list, identical old Dockerfile pins, and verified current-base/runtime metadata. Research also identifies explicit Pester 5 ceilings and removed Pester 6 APIs.
- Affected components/modules (paths, services, pipelines): Both `.devcontainer` configuration trees, shared setup/verifier, shared version predicate, manifest/bootstrap, PoshQC installation/testing/settings, development CI, mirrors and asserting tests.

## Proposed Fix

### Design summary (what changes where):

Use the supplied pinned devcontainer base in both Dockerfiles, retain its verified Python runtime, install the selected tool versions, and preserve repository-specific tools. Local Docker directly mounts the host checkout and overlays `.venv` plus the three `node_modules` paths with Linux named volumes. Both configurations call the same `.devcontainer/post-create.sh`, which installs locked project dependencies and runs complete verification before its success message.

### Boundaries and invariants to preserve:

- Host and container share source files, including uncommitted changes; Linux package directories remain separate from host packages.
- Empty or interrupted dependency-volume initialization is recoverable without deleting the mount root or host data.
- The previous workspace volume remains available for recovery of container-only work.
- Git trust applies to the workspace path; container-specific file-monitor settings do not rewrite host `.git/config`.
- Container tool selections are exact pins except the explicitly documented Git minimum and Python patch policy within the selected minor. Host bootstrap preserves equal or newer compliant installations.
- Existing test selection, result propagation, coverage population and thresholds remain enforced during the Pester migration.

### Dependencies or blocked work:

Actual release artifacts and the pinned base tag must resolve before build validation. Research confirmed the selected base for amd64/arm64, Python 3.13.18 and Git 2.56.0 in that base, and availability of the supplied updated tool releases. Full Pester 6 compatibility remains an implementation and validation obligation. An unavailable artifact or incompatible behavior must be reported with evidence; silently reverting to an older pin is prohibited.

Research sufficiency: The [completed research report](research/2026-11-05T02-42-devcontainer-current-baseline-research.md) is sufficient to define this fix and its validation. No requested artifact was proven unavailable. Release availability and configuration construction are not substitutes for successful installation, actual Pester invocation or complete runtime evidence.

### Implementation strategy (what changes, not sequencing):

Keep a shared runtime-version contract and use it for complete container verification. Update the existing installation/import boundaries that reject Pester 6, adapt removed Pester APIs and output formats, and maintain the existing coverage and CI contracts. Use full configurations, including features and lifecycle commands, for runtime acceptance.

#### Files/modules to change:

- `.devcontainer/local/Dockerfile`, `.devcontainer/codespaces/Dockerfile`, both `devcontainer.json` files, `.devcontainer/post-create.sh`, and `.devcontainer/verify-container.sh`.
- `scripts/bash/container_versions.sh`, `scripts/host-tools.manifest.json`, and relevant `scripts/dev-tools/HostBootstrap.psm1` behavior/tests.
- `scripts/powershell/PoshQC/PoshQC.psm1`, `PoshQC.Testing.psm1`, and `settings/pester.runsettings.psd1`; corresponding bundled runtime/settings copies where present.
- `.github/workflows/_poshqc.yml` and other workflow pins that consume the updated development baseline.
- Existing host/environment, shell version, PoshQC and workflow contract tests, including `tests/scripts/dev_tools/test_host_environment_contracts.py`, `tests/shell/test_container_versions.bats`, and `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`.
- `.devcontainer/README.md`, `QUICKSTART.md`, `TROUBLESHOOTING.md`, relevant root documentation, and all six `execution-environment/SKILL.md` source/bundle mirrors.

#### Functions/classes/CLI commands impacted:

`container_tool_version_supported`, `read_container_tool_version`, `check_container_tool_version`, `Install-PoshQCTool`, and `Invoke-PoshQCTest` carry the version and module boundaries. `Invoke-BootstrapHost` consumes manifest minima. Existing `PoshQC.ScanFolders.Tests.ps1` assertions using the removed `Assert-MockCalled` API require equivalent `Should -Invoke` assertions.

#### Data flow and validation changes:

Build installs pinned system tools and user-accessible CLI entrypoints. Post-create prepares only dependency mount ownership, installs Poetry/npm lock-file dependencies, resolves supported PowerShell modules, and verifies the complete runtime contract. Verification records each tool/module version and exits nonzero for missing, unreadable, unsupported or failed version probes. Pester 6 uses supported JaCoCo coverage output while preserving the merge population and downstream coverage schema.

#### Error handling and logging updates:

Failure messages name the missing or mismatched tool/module and expected baseline. Setup stops before `Dev Container Setup Complete!` when verification fails. Native installation/version-command failures remain visible and propagate nonzero results. No new telemetry or credential logging is required.

#### Rollback/feature-flag considerations (if applicable):

No feature flag is required. Revert configuration/build changes to restore the prior layout if necessary; retain the previous named workspace volume throughout. Recover volume-only work before a human elects to remove that volume.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Inputs are the two configurations and Dockerfiles, approved release pins, repository lock files, host manifest and workspace files. Outputs are complete images, isolated Linux dependency directories, native tool/module version diagnostics, existing test/coverage report formats, and feature evidence in this folder's canonical evidence directories.

Selected baseline:

| Component | Required selection |
|---|---|
| Base image | `mcr.microsoft.com/devcontainers/python:3.3.2-3.13-bookworm` |
| Python | Base-provided `3.13.18`; retain the selected 3.13 minor policy |
| Git | Minimum `2.56.0` |
| PowerShell | `7.6.9` |
| Poetry | `2.5.1` |
| GitHub CLI | `2.103.3` |
| Node.js / npm | `26.13.0` / `11.20.0` |
| .NET SDK | `10.0.403` |
| actionlint | `1.7.12` |
| Pester | `6.2.0` |
| PSScriptAnalyzer | `1.25.0` |
| uv | `0.13.7` |
| Claude Code | `2.1.318` |
| claude-swap | `0.29.0` |
| Codex | `0.166.0` |
| shfmt / ShellCheck / kcov | Existing `3.14.1` / `0.11.0` / `v43` selections |

Preserve bashdb, Bats, Graphite, GitHub Copilot CLI and existing supporting tools. Preserve exact existing CLI pins where one already exists, and verify their availability in the complete environment.

#### Required configuration keys and defaults:

Both `postCreateCommand` values use `bash .devcontainer/post-create.sh`. Local `workspaceMount` binds `${localWorkspaceFolder}` at `/workspaces/drm-copilot`; dependency volume mounts use `volume-nocopy`. Preserve the background worktree volume and environment path. Set `.NET` telemetry/root and container Python bytecode-cache configuration from the supplied baseline. Disable pinned CLI automatic-update behavior and prepare root-owned Codex system configuration without writing credentials or user state into the image. Prepare `.claude`, claude-swap and `.codex` state directories with the container user's ownership.

#### Backward-compatibility expectations:

Preserve Poetry project compatibility with Python 3.11/3.12/3.13, consumer engine metadata and existing tool command names. Update development CI pins without removing compatibility jobs. Migrate Pester 5-only assertions to the Pester 6 contract rather than skipping or weakening their behavior checks.

#### Performance constraints (latency/throughput/memory):

Keep dependency I/O in Linux volumes locally. Host source changes require no seeding or rebuild to become visible. A Windows bind mount may remain slower for source traversal; document the WSL filesystem option. Validate that Git status does not wait on the host's enabled file-monitor daemon; no numeric throughput guarantee is introduced.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access): Docker Desktop Linux containers and Dev Containers tooling are available; release registries are reachable; the supplied versions are authorized additions/updates.
- Constraints (budget, performance, compatibility): Apply repository code/test policy and evidence rules; preserve source/data and compatibility; verify real feature-inclusive builds. The user baseline takes precedence over the former Pester 5-only environment guidance.
- External dependencies (services, libraries, releases): Microsoft Container Registry, official CLI/runtime releases, npm/PyPI/PowerShell Gallery, and existing dependency lock files. Research provides release provenance; runtime tests establish installation compatibility.

## Data / API / Config Impact

- User-facing or API changes: Local files are edited directly through the mounted checkout; required tools and module versions are available after setup. Shared setup rejects incomplete environments.
- Data or migration considerations: Local `.venv` and `node_modules` use container-owned volumes; existing host dependencies and the old workspace volume are retained.
- Logging/telemetry updates (if any): Report complete version diagnostics, disable .NET telemetry as requested, and avoid credentials in logs.
- Compatibility notes (CLI flags, config schemas, versioning): Preserve existing command names, consumer compatibility and report consumers; reconcile Pester 6 output/import APIs explicitly.

## Test Strategy

- Regression tests to add or update: Existing host/environment contract tests must assert new pins, complete verifier coverage, shared setup, local dependency isolation, preserved Codespaces resources and independent consumer compatibility. Expand `test_container_versions.bats` positive/negative/boundary cases for the full managed tool list.
- Unit tests (pytest) for the fixed behavior and boundaries: Update `test_container_installations_match_managed_host_minimums`, `test_shared_predicate_declares_each_selected_pin`, `test_local_workspace_uses_live_source_and_isolated_linux_dependencies`, and `test_containers_share_setup_and_verify_before_reporting_success`; retain compatibility tests.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): Missing/unreadable CLI/module versions, failed version commands, unsupported Python minor or Git minimum, stale exact pins, fresh/interrupted dependency volumes, repeated setup, host uncommitted edits and file-monitor settings.
- Error handling and logging verification: Assert failure exits prevent the setup success banner and name the failed baseline requirement. Update PoshQC RunSettings RS01/RS04 coverage-format checks and RS03/RS05 through RS09 module-range/import checks; preserve their negative-path coverage under the new contract. Update affected `PoshQC.Comprehensive.Tests.ps1` and `PoshQC.TestingOutputPath.Tests.ps1` configuration fixtures.
- Coverage impact and targets for changed lines/modules: Preserve repository thresholds and coverage population; new executable logic targets at least 90% coverage. Validate Pester 6 JaCoCo reports and coverage merges without exclusions or denominator reduction.
- Toolchain commands to run (format → lint → type-check → test): Use the applicable complete repository loops and execution-environment guidance. Include shell, Python, PowerShell, workflow/contract checks, mirror validation, and both feature-inclusive container lifecycle runs.
- Manual validation steps (if required): No manual-only gate is introduced. Automate the local full configuration build, post-create and repeat setup; automate the corresponding Codespaces configuration lifecycle with its required features.

## Acceptance Criteria

- [x] AC1: Both configurations run the shared post-create command against their actual workspace; local Docker exposes host uncommitted source changes immediately without a seeded Git checkout, and neither setup nor migration deletes host source/data or the former workspace volume.
- [x] AC2: Local `.venv` and all three `node_modules` paths use independent Linux dependency volumes with `volume-nocopy`; fresh and interrupted initialization plus repeated setup succeed without deleting mount roots or changing host dependency contents.
- [x] AC3: Both full images select the exact base image and required versions in the selected baseline table, including its Python 3.13.18 runtime and Git minimum, and preserve the repository's additional tools; no unavailable artifact is replaced silently.
- [x] AC4: Automatic verification checks every selected runtime, CLI and PowerShell module, required supporting tools, operating system/configuration and Linux virtual environment; missing, unreadable, failed or unsupported probes produce a nonzero exit and prevent the setup completion banner.
- [x] AC5: PoshQC installation/import boundaries, settings, CI and asserting tests support Pester 6.2.0, use supported coverage output and assertion APIs, and pass the applicable real test and coverage runs without weakening test selection, failure propagation, coverage population or thresholds.
- [x] AC6: Git commands in the local container trust only the intended workspace path and avoid the host file-monitor delay; the container-specific handling leaves host repository configuration unchanged.
- [x] AC7: Codex, Claude Code and claude-swap entrypoints are available to the container user at their selected versions; required state directories have that user's ownership, pinned CLI update handling is configured, and the image contains no user credential material or destructive state initialization.
- [x] AC8: Both complete devcontainer configurations build with their required features, finish post-create, and pass version/module verification; repeated setup succeeds, with the actual commands and results recorded as feature evidence.
- [x] AC9: Relevant host manifest/bootstrap and development CI contracts match the selected baseline, retain minimum-aware host handling for newer compliant installations, and preserve Python compatibility jobs and published consumer engine ranges.
- [x] AC10: Regression, contract and applicable format/lint/type/test loops pass for changed behavior, with numeric baseline/final coverage evidence where required and no regression in changed-code coverage or report compatibility.
- [x] AC11: Active container guides, relevant repository documentation, and all six execution-environment source/bundle mirrors describe the implemented baseline, workspace/dependency storage and recovery behavior consistently; mirror/contract validation passes.
- [x] AC12: Every GitHub check on the final pull-request head passes or is skipped according to repository rules, and CI-dependent acceptance evidence records that exact head.

## Risks & Mitigations

- Technical or operational risks: Pester 6 changes coverage and assertion APIs; release assets may differ by architecture; source bind mounts inherit host Git settings; persistent dependency volumes can retain incompatible environments; pin lists and bundled documentation can drift.
- Mitigations and rollbacks: Use verified release artifacts and full builds; test Pester 6 behavior and merged coverage; scope container Git overrides; exercise fresh/interrupted/repeated setup; validate all mirrors and contract tests. Report blockers with evidence instead of selecting older versions. Retain prior source/dependency state and previous workspace volume for recovery.

## Rollout & Follow-up

- Release/rollout steps: Deliver through the active bug branch, required review and final-head CI. Rebuild using the selected local/Codespaces configuration to apply image and mount changes.
- Post-fix monitoring or clean-up tasks: Inspect complete setup diagnostics on first use. The former workspace volume is unused; recover any container-only work before a separate user decision to remove it.
- Links: [Issue #1082](https://github.com/drmoisan/drm-copilot/issues/1082), [promoted report](../../potential/promoted/2026-11-04-devcontainer-current-baseline.md), and this folder's research and evidence artifacts.
