<!-- markdownlint-disable-file -->

# Task Research Notes: Refresh host tooling (issue #1069)

## Research Executed

### File Analysis

- `scripts/host-tools.manifest.json`
  - Canonical manifest has six winget packages and minima Python 3.13.12, Node 24.14.0, PowerShell 7.6.6, Poetry 2.3.2. Parent live inventory verifies Python 3.13.17, Node 26.13.0/npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, ShellCheck 0.11.0, shfmt 3.14.1, actionlint 1.7.12, Git 2.53.0, gh 2.103.3, uv 0.13.7, Docker client 29.9.2/Desktop 4.98.0. Git 2.56.0.4 was available, not installed.
- `scripts/dev-tools/HostBootstrap.psm1`, `HostBootstrapWorkspace.psm1`, `HostTooling.psm1`, `HostVerification.psm1`, and `bootstrap-host.ps1`
  - Bootstrap skips existing commands without checking versions. Poetry fallback similarly skips existing Poetry and otherwise runs unpinned pip installation. Verification already compares four core versions with manifest minima. Native process calls have mockable wrappers, streamed output, and failure propagation. Entry script is thin wiring. Main bootstrap module is 465 logical lines.
- `.devcontainer/local/Dockerfile` and `.devcontainer/codespaces/Dockerfile`
  - Both use Python 3.13 Bookworm and Poetry 2.2.1. Local uses Debian Node/npm, unpinned PowerShell, Pester >=5.0, unpinned actionlint and kcov `latest`, and an unrelated WORKDIR. Codespaces uses NodeSource Node 20, PowerShell 7.6.*, shfmt 3.8.0, Pester 5.9–5.x, actionlint 1.7.12 and source-built kcov v43; it also provides Claude and claude-swap required by shared verification.
- `.devcontainer/local/devcontainer.json`, `.devcontainer/codespaces/devcontainer.json`, `.devcontainer/post-create.sh`, `.devcontainer/verify-container.sh`
  - Preserve local volume mounts/Docker-outside-of-Docker and Codespaces host requirements. Post-create requires Pester 5.9 and PSScriptAnalyzer 1.22. Shared verification still requires Poetry 2.2.x, Node 20.x, shfmt 3.8.0, and PowerShell 7.6.x; Codespaces messages mention the obsolete root-level configuration path.
- `.github/workflows/_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`, `_root-typescript-tests.yml`, `_npm-audit-gate.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`, `verify-published-releases.yml`
  - Shell CI downloads shfmt 3.8.0 and uses apt ShellCheck. Node consumers use 20 except npm publishing, which uses 24 and installs npm 11.18.0. `_quality-checks.yml`, `_build-check.yml`, `_security-scan.yml` install Poetry `latest`.
- `tests/scripts/host-tools.manifest.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`, `HostBootstrap.Invoke.Tests.ps1`
  - Manifest tests pin exact minima and matching fixtures. Bootstrap tests assert exact install argv/output, existing-command skips, pip args, and dry-run behavior. Invoke fixtures sometimes lack `minimumVersions`; retain compatibility or explicitly update fixtures.
- `pyproject.toml`, `README.md`, root/extension package manifests
  - Python supports >=3.11,<4.0 and CI tests 3.11/3.12/3.13. README development guidance recommends Node 20, while consumer guidance allows Node 18+. These compatibility contracts should remain distinct from the new development baseline.

### Code Search Results

- `2.2.1`, `3.8.0`, `NODE_MAJOR`, `node-version`
  - Found both Dockerfiles, shared verifier, active container guides, shell CI and Node workflow consumers listed above.
- `24.14.0`, `3.13.12`, `7.6.6`
  - Found manifest minima and exact assertions/mocks in `tests/scripts/host-tools.manifest.Tests.ps1`.
- `verify-container`, `codespaces/Dockerfile`, `SHFMT_VERSION` in tests
  - No dedicated container/verifier baseline suite found. Existing `test_clean_devcontainer.py` concerns cleanup behavior. `test_quality_checks_workflow_contracts.py` pins quality workflow step conditions and Python coverage matrix.

### External Research

- #githubRepo:"PowerShell/PowerShell v7.6.9"
  - Official release exists; independently confirmed Debian package availability.
- #fetch:https://packages.microsoft.com/debian/12/prod/dists/bookworm/main/binary-amd64/Packages
  - Direct read found PowerShell `7.6.9-1.deb`, amd64. Exact apt pins need this full package version.
- #fetch:https://nodejs.org/en/download/archive/v26.13.0
  - Official archive lists Node 26.13.0, bundled npm 11.20.0 and Linux x64/arm64 artifacts.
- #fetch:https://deb.nodesource.com/node_26.x/dists/nodistro/main/binary-amd64/Packages
  - Direct read found Node `26.13.0-1nodesource1`, amd64; existing NodeSource installation pattern remains usable.
- #fetch:https://pypi.org/pypi/poetry/2.3.2/json
  - Poetry 2.3.2 exists, requires Python >=3.10,<4.0, and supports the current Python CI matrix.
- #fetch:https://github.com/mvdan/sh/releases/tag/v3.14.1
  - Official shfmt 3.14.1 release exists; architecture-specific Linux binaries follow the existing download pattern.
- #fetch:https://github.com/koalaman/shellcheck/releases/tag/v0.11.0
  - Official ShellCheck 0.11.0 release exists. Unpinned Bookworm apt installation does not prove matching the host version.
- #fetch:https://mcr.microsoft.com/v2/devcontainers/python/tags/list
  - Registry lists `3.13-bookworm`, but no exact `3.13.17-bookworm` tag. Preserve the real minor tag and verify actual Python version during build.

### Project Conventions

- Standards referenced: `AGENTS.md`, research-issue, execution-environment, evidence-and-timestamp-conventions and ci-workflows skills.
- Instructions followed: research only in supplied tracked root; no source changes, test execution, or nested delegation. Host versions came from parent live inventory; remote release/package availability was independently checked. Initial research write was denied because checkpoint lacked canonical Boolean `lifecycle_ready`; parent reconciled it against successful lifecycle receipts before this write.

## Key Discoveries

### Project Structure

The host manifest is the existing Windows authority; two Dockerfiles, shared verification, and workflow consumers encode their baselines separately. Synchronize these sites without a new dependency or configuration framework.

### Implementation Patterns

Extend `Install-WithWinget` with an optional minimum version. Keep existing behavior for unmanaged commands such as Git/VS Code; for managed commands, parse installed versions through `Get-CommandVersion`, preserve equal/newer versions, and explicitly handle below-minimum or unparseable versions. Dry run previews without invoking install; apply upgrades through the existing winget wrapper and propagates failures. Thread known manifest minima into the loop with StrictMode-safe property handling.

Apply equivalent optional minimum handling to Poetry fallback. Keep compliant Poetry; preview missing/stale installation in dry run; apply a version-constrained pip upgrade using existing streaming/PATH/error seams. Avoid a generic process abstraction. Do not downgrade a newer installed tool.

### Complete Examples

```powershell
# Existing HostVerification.psm1 version-check pattern:
$actual = Get-CommandVersion -Command $check.Name -VersionArgs $check.Args
if (Test-VersionAtLeast -Actual $actual -Minimum $check.Minimum) {
    # report compliance
}
```

### API and Schema Documentation

Keep seven existing manifest keys, package IDs and command classifications unless deliberately adding optional shell tool installation. Preserve optional new parameters for current callers and update test mocks with exact production signatures. Python package/runtime support and older CI compatibility legs remain intact.

### Configuration Examples

```json
{
  "minimumVersions": {
    "node": "26.13.0",
    "poetry": "2.3.2",
    "pwsh": "7.6.9",
    "python": "3.13.17"
  }
}
```

### Technical Requirements

- Match development Node 26.13.0/npm 11.20.0, Python 3.13.17, Poetry 2.3.2, PowerShell 7.6.9, shell tooling versions; preserve Python 3.11/3.12 compatibility testing and consumer engines.
- Align both Dockerfiles using existing Codespaces installation patterns while preserving JSON mount/resource differences. Retain unrelated CLI pins; no evidence calls for upgrading Claude/Graphite/Copilot/claude-swap.
- Docker Desktop versions are host facts, not Linux package versions. Remote package checks here prove amd64 availability only; verify arm64 separately before claiming it. ShellCheck and shfmt architecture naming differs.
- **The exact `3.13.17-bookworm` image tag is unavailable in the authoritative registry listing.** Use the real minor image with actual build-version verification or a separately verified real immutable image; never invent a tag.

## Recommended Approach

Synchronize existing manifest and explicit installation sites; add bounded minimum-aware bootstrap behavior through existing seams. Reuse Codespaces tool-install structure for local; update shared verification and deterministic parity tests. Pin primary CI Node/Poetry/shfmt/ShellCheck consistently without changing package compatibility.

Rejected alternatives: declaration-only changes leave stale existing tools skipped by bootstrap; broad package/runtime upgrades change unrelated compatibility; merging both configuration JSON files risks losing platform-specific mounts/resources.

## Implementation Guidance

- **Objectives**: reproducible current development baseline across repo, both containers and bootstrap; no further host upgrades.
- **Key Tasks**:
  1. Update manifest and pinned manifest tests; extend `HostBootstrap.psm1` managed-tool/Poetry handling. Update `HostBootstrap.Tests.ps1`, `HostBootstrap.Invoke.Tests.ps1`; review `bootstrap-host.Tests.ps1`, `HostTooling.Tests.ps1`, `HostVerification.Tests.ps1`, `HostVerification.Invoke.Tests.ps1`, `verify-host.Tests.ps1` for affected fixtures.
  2. Update both Dockerfiles and verifier. Update active `.devcontainer/README.md`, `CONFIG-GUIDE.md`, `CODESPACES-SETUP.md`, `RECREATE-CODESPACE.md`, and affected `QUICKSTART.md`/`TROUBLESHOOTING.md` commands. Preserve mounts/features.
  3. Update Node workflow consumers listed above; npm publishing pin if selected; three Poetry workflow installers; shell CI pins. Modified publishing workflows require safe nonpublishing branch validation. Parent confirmed `ci.yml` supports branch dispatch; that validates reusable CI consumers, but release-specific workflows still need their own safe validation when changed.
  4. Update README development baseline and all six execution-environment mirrors when changing stated facts. Preserve historical artifacts and generic unrelated version examples.
  5. Add focused configuration parity and verifier runtime coverage where needed. No dedicated baseline suite currently exists. Tests must not depend on ambient host versions, network or temporary files.
- **Dependencies**: existing winget/pip/apt/download mechanisms suffice; Docker daemon availability was verified by parent and actual image builds are feasible.
- **Success Criteria**: compliant newer tools preserved, stale tools handled, dry-run side effects absent, both image builds/reporting validated, ordered toolchains pass and current PR-head checks pass.
- **Validation commands**: canonical PoshQC format/analyze/test with measured output and targeted suites; required seeded/serial/sharded isolation checks; root/extension npm format/lint/typecheck/tests for changed Node CI baseline; Python Black/Ruff/Pyright/Pytest and mirror/workflow contracts when tests change; shell-qc check/test coverage, actionlint and both actual container builds. Shfmt upgrade may reformat discovered scripts: measure the actual affected file set before finalizing plan. `.devcontainer` scripts are outside shell-qc's `scripts/`/`tools/` discovery and need explicit checks.

## Pre-Mortem

- Review checklists: template acceptance criteria or unvalidated modified publishing workflows can block review; populate concrete requirements and arrange safe branch-head workflow execution.
- Coverage: new bootstrap branches need missing/below/equal/above/unparseable version and install-error tests through mocked seams; preserve changed-line coverage.
- Mirror parity: execution brief changes require all six mirrors and resource/generator contract checks.
- File size: HostBootstrap.psm1 starts at 465 logical lines; keep functions focused and split cohesive logic if required before hard thresholds.
- Test isolation: new version calls may expose unmocked ambient resolution; register wrapper mocks first with signature parity and run required shuffled/serial isolation checks.
- CI-only behavior: Linux package versions differ from Windows versions and unsafe release dispatch can publish; verify full apt versions/architectures and use nonpublishing validation.
- Evidence: record actual QA/build/current-head results in canonical feature evidence directories with write-time UTC stamps; configuration edits do not prove successful execution.
