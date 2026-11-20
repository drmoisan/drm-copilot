<!-- markdownlint-disable-file -->

# Task Research Notes: Complete pinned devcontainers and direct local workspace

## Research Executed

### File Analysis

- `.devcontainer/local/Dockerfile` and `.devcontainer/codespaces/Dockerfile`
  - Identical older images copy Python 3.13.17 over the base, install Poetry 2.3.2, Claude Code 2.1.316 and claude-swap 0.28.0, and restrict Pester below 6.
  - Codex, uv and .NET SDK installations are absent.
- `.devcontainer/local/devcontainer.json`, `.devcontainer/post-create.sh`
  - Root’s uncommitted changes already implement the live host bind, Linux dependency volumes, shared post-create command, ownership handling and verification before completion.
- `scripts/bash/container_versions.sh`, `.devcontainer/verify-container.sh`
  - Version verification covers only part of the required baseline. Several supporting CLIs are checked only for presence; Codex, uv, .NET and PowerShell module versions are omitted.
- `scripts/powershell/PoshQC/PoshQC.psm1`
  - `Install-PoshQCTool` requires Pester >=5.9.0 and <6.0.0 and PSSA >=1.22.0.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1`
  - `Invoke-PoshQCTest` supplies its `EnsureModule` seam the range 5.9.0–5.99.99.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  - Uses `CodeCoverage.OutputFormat = 'CoverageGutters'`, which Pester6 rejects.
- `.github/workflows/_poshqc.yml`
  - Shard completeness discovery and Linux hook tests explicitly import Pester <=5.99.99.
- `scripts/host-tools.manifest.json`, `.github/workflows/_quality-checks.yml`, `_build-check.yml`, `_security-scan.yml`
  - Manifest and Python CI use Poetry 2.3.2. Manifest module minima remain Pester5.9.0 and PSSA1.22.0.

### Code Search Results

- `CoverageGutters`
  - Actual settings and bundled settings require JaCoCo.
  - Direct assertions: `PoshQC.RunSettings.Tests.ps1` RS01 and RS04.
  - Related fixtures: `PoshQC.Comprehensive.Tests.ps1`, `PoshQC.TestingOutputPath.Tests.ps1`.
- `Assert-MockCalled`
  - Three actual uses in `PoshQC.ScanFolders.Tests.ps1`; replace with `Should -Invoke`.
- Pester5 range
  - `PoshQC.RunSettings.Tests.ps1` RS03 and RS05–RS09 assert the old installer/import restriction and require updated expectations.
- Environment mirrors
  - PoshQC runtime/settings have bundled counterparts under `extensions/drm-copilot/resources/powershell/PoshQC/`.
  - `execution-environment/SKILL.md` has six synchronized source/bundle copies.
  - Root README and active `.devcontainer` guides describe the older baseline.

### External Research

- #githubRepo:"pester/Pester 6.2.0 migration"
  - Official release exists. Actual host module 6.2.0 is installed and importable.
- #fetch:https://pester.dev/docs/migrations/v5-to-v6
  - Pester6 retains classic `Should -Be`, but removes legacy mock assertions and CoverageGutters output.
  - Per-file discovery/run, strict unmatched filtered mocks and configuration validation can expose existing test assumptions.
- #fetch:https://github.com/pester/Pester/releases/tag/6.2.0
  - Actual invocation must be tested; configuration construction alone does not establish validity.
- #fetch:https://code.visualstudio.com/remote/advancedcontainers/improve-performance
  - Supported pattern: bind source and use targeted named volumes for dependency directories, with ownership adjustment for non-root users.
- #fetch:https://git-scm.com/docs/git-config
  - Indexed GIT_CONFIG environment pairs override repository configuration without modifying shared `.git/config`.

Actual artifact checks:
- `docker manifest inspect mcr.microsoft.com/devcontainers/python:3.3.2-3.13-bookworm` succeeded for amd64 and arm64.
- An ephemeral container from that exact image reported Python3.13.18, Git2.56.0 and available pipx.
- HTTP200: Poetry2.5.1 and claude-swap0.29.0 PyPI metadata; Codex0.166.0 and Claude2.1.318 npm metadata; uv0.13.7 installer; Node26.13.0 checksums; .NET10.0.403 archive; PowerShell7.6.9 .deb; gh2.103.3 .deb; actionlint1.7.12 archive; Git2.56.0 source.
- `Find-Module Pester -RequiredVersion 6.2.0` succeeded.
- Official Gallery page confirms PSSA1.25.0.
- Generic MCR and Gallery API HTTP HEAD requests returned misleading 404s; successful Docker resolution, Gallery lookup and published package pages supersede those results.

### Project Conventions

- Follow AGENTS.md, execution-environment, research-issue and evidence-and-timestamp-conventions.
- Research only; no production/test changes, no nested delegation and no silent version substitutions.
- Research write was blocked by conflicting generated-profile and evidence-hook location rules; parent must persist this report under the tracked research root.

## Key Discoveries

### Project Structure

Image installation, workspace dependency installation, runtime verification, host minimums, CI selection and bundled PoshQC are separate contracts. Updating Dockerfiles alone leaves the old installer and verifier capable of selecting or accepting an incomplete environment.

### Implementation Patterns

The selected base already supplies Python3.13.18 and Git2.56.0. Remove the old Python3.13.17 copy stage because it would downgrade the requested base.

Existing coverage merge logic consumes JaCoCo-shaped package/sourcefile/line data. Changing the output name to JaCoCo preserves the report family, but real generated paths and denominator parity still require validation.

### Complete Examples

```powershell
Import-Module Pester -RequiredVersion 6.2.0 -Force
$settings = Import-PowerShellDataFile scripts/powershell/PoshQC/settings/pester.runsettings.psd1
$config = New-PesterConfiguration -Hashtable $settings
$config.Run.Exit = $false
$config.Run.Throw = $true
$config.Run.Path = @('research-no-tests.Tests.ps1')
Invoke-Pester -Configuration $config
```

Observed before discovery:
`CodeCoverage.OutputFormat must be 'JaCoCo' or 'Cobertura', but it was 'CoverageGutters'.`

Configuration construction alone succeeded. No test files were created or executed by this experiment.

### API and Schema Documentation

Required supplied baseline: pinned base3.3.2-3.13-bookworm; Python3.13.18 from that base; Git>=2.56.0; PowerShell7.6.9; Poetry2.5.1; gh2.103.3; Node26.13.0; .NET SDK10.0.403; actionlint1.7.12; Pester6.2.0; PSSA1.25.0; uv0.13.7; Claude2.1.318; claude-swap0.29.0; Codex0.166.0.

Preserve repository-specific npm, shfmt, ShellCheck, kcov, bats, bashdb, Graphite and Copilot capabilities. Existing consumer Python compatibility remains independent.

### Configuration Examples

```json
{
  "containerEnv": {
    "GIT_CONFIG_COUNT": "1",
    "GIT_CONFIG_KEY_0": "core.fsmonitor",
    "GIT_CONFIG_VALUE_0": "false",
    "PYTHONPYCACHEPREFIX": "/tmp/pycache"
  },
  "postCreateCommand": "bash .devcontainer/post-create.sh"
}
```

Container-only fsmonitor override addresses observed Windows-bind Git delays without editing host Git configuration.

### Technical Requirements

No requested version was proven unavailable. Endpoint success establishes availability, not installation or full compatibility.

Pester migration must update real installer/import bounds, JaCoCo settings, removed mock assertions, direct tests and bundled copies. Preserve current process-level sharding; experimental Pester6 parallel execution and wholesale assertion rewriting are unnecessary.

Full Pester6 suite compatibility was not tested during research and remains an execution gate.

## Recommended Approach

Use the supplied pinned base and versions for both images, retain direct local source plus isolated Linux dependency volumes, and make the shared final verifier check all required CLIs and modules. Add missing Codex, uv and .NET. Migrate actual PoshQC runtime/settings and update host/CI/docs/mirrors together.

Rejected alternatives: seed synchronization retains a second source state and missing-HEAD/staleness risks; binding host dependency directories introduces Windows package incompatibility and slower package I/O. A manually cloned isolated source volume remains a performance alternative but does not match the requested live workspace behavior.

Acceptance mapping:
- Complete environment: exact installed CLI/module outputs and native execution.
- Current workspace: live host bind and matching uncommitted file content.
- Linux isolation: all four dependency mountpoints and Linux executables.
- Shared setup: identical command and successful repeated lifecycle.
- Pester6: actual runtime/config/API compatibility, full suite and coverage.
- Synchronization: matching bootstrap/CI/docs/bundles and exact-head CI.

## Implementation Guidance

- **Objectives**: complete requested baseline, preserve supporting tools, use actual source and verify before completion.
- **Key Tasks**: update Dockerfiles, predicate/verifier, local Git/bytecode settings, PoshQC installer/import/settings, asserting tests, manifest, three Poetry CI pins, container guides and six environment mirrors.
- **Dependencies**: Codex, uv and .NET are user-authorized development tools; no new application library is needed.
- **Success Criteria**: both full configurations build; fresh/reused lifecycle succeeds; every requested version/import passes; native binaries execute; all tests, coverage and isolation gates pass.

Tests:
- Update `test_host_environment_contracts.py` to assert new base/install design instead of the removed Python-copy stage.
- Extend `test_container_versions.bats` for every managed tool and Git minimum boundaries.
- Update PoshQC RunSettings tests RS01/RS03–RS09 and affected configuration fixtures.
- Change the three removed assertions in ScanFolders tests.
- Retain synthetic legacy bootstrap fixture values where their purpose is compatibility; update tests that consume committed manifest data.

Gates: execution-environment tool routes; Python format/lint/type/test; shell format/lint/Bats with explicit devcontainer instrumentation; PoshQC format/analyze/full Pester coverage; bundle contracts; both full feature-enabled devcontainer builds and post-create execution. Isolation: reversed touched Python module order, three seeded touched-Pester file orders, complete single-process tests/scripts, concurrent Pester shards, pytest-xdist, and required exact-head CI. Preserve coverage population/thresholds.

## Pre-Mortem

- Review checklists: old presence-only verification can accept omissions; enumerate requested CLIs/modules and execute native binaries.
- Coverage: changed Pester output or omitted devcontainer entrypoints can shrink coverage; preserve JaCoCo population and instrument changed shell paths.
- Mirror parity: update PoshQC bundles/settings and all six environment mirrors; run resource contracts.
- File size: inspect logical counts and respect the 800-line hard gate.
- Test isolation: per-file discovery and strict mocks can expose leaks; run all required serial, seeded and shard checks.
- CI-only behavior: Linux case sensitivity, Windows mocks, hidden-file discovery and workflow imports require full OS checks.
- Evidence: distinguish metadata availability from actual runtime success; store executed gates under canonical feature evidence paths and preserve command/result provenance.
