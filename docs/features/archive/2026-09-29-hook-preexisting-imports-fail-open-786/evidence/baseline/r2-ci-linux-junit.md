# Remediation Cycle 2 Linux CI JUnit Evidence ([P0-T5])

Timestamp: 2026-10-10T20-24
Command: gh run download 38093728445 --repo drmoisan/drm-copilot --name poshqc-linux-hook-test-results --dir <SCRATCHPAD>/r2-ci-linux; then sh <SCRATCHPAD>/r.sh r2-ciartifact (R-CIARTIFACT reader over <SCRATCHPAD>/r2-ci-linux/**/pester-junit-linux-hooks.xml; writes <SCRATCHPAD>/r2-linux-order.list)
EXIT_CODE: 0
Output Summary: artifact downloaded (exit 0); root tests=5700, failures=18, errors=0; 18 CI-FAILED lines; per-suite counts 1, 1, 3, 1, 2, 10 as the plan expects; LINUX-ORDER has 200 containers; validate-orchestrator-output-resolution.Tests.ps1 at position 125 precedes hook-dependency-failure.Codex.Tests.ps1 at position 192.

Note: the command adds `--repo drmoisan/drm-copilot` to the R-CIARTIFACT form so the run identifier resolves against the PR repository regardless of the shell working directory; the artifact name and output directory are those of the plan.

DOWNLOAD_EXIT_CODE: 0
JUNIT-FILES: 1
ROOT: tests=5700 failures=18 errors=0
LINUX-ORDER-COUNT: 200
R6-POSITION: 192
VOOR-POSITION: 125

CI-FAILED: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | Codex enforce-codex-model-routing coverage (issue #786).entry point.falls back to the agent-id attestation scan | Expected 0, but got 2.
CI-FAILED: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | Codex enforce-epic-root-invocation coverage (issue #786).entry point.falls back to the agent-id attestation scan and denies missing provenance | Expected 0, but got 2.
CI-FAILED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | Codex enforce-epic-wave-barrier coverage (issue #786).entry point.exits 0 for a non-mutating tool with no local or launcher state | Expected 0, but got 2.
CI-FAILED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | Codex enforce-epic-wave-barrier coverage (issue #786).entry point.exits 0 without a deny for a ready execution child | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
CI-FAILED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | Codex enforce-epic-wave-barrier coverage (issue #786).entry point.writes the deny for an unready execution child | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
CI-FAILED: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Codex hook dependency-failure behaviour (issue #786).baseline mock interception probe | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
CI-FAILED: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | Codex validate-codex-subagent-routing coverage (issue #786).Find-CodexStopAttestationRaw.returns the attestation whose agent id matches and skips unreadable files | ParameterBindingException: A parameter cannot be found that matches parameter name 'File'.
CI-FAILED: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | Codex validate-codex-subagent-routing coverage (issue #786).Find-CodexStopAttestationRaw.returns nothing when no attestation matches | ParameterBindingException: A parameter cannot be found that matches parameter name 'File'.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.returns no audit when the active folder is absent | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.returns the most recently written audit | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.returns no language when the PR summary is absent | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.maps changed files to their languages | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes TypeScript to its report | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes Python to its report | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes PowerShell to its report | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes CSharp to its report | DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).entry point.exits 0 when the branch changes no tracked language | Expected 0, but got 2.
CI-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Codex validate-feature-review-coverage coverage (issue #786).entry point.requests a continuation when a changed language lacks a verdict | Expected 0, but got 2.

CI-FAILED-COUNT: 18
CI-FAILED-BY-SUITE: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 1
CI-FAILED-BY-SUITE: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 1
CI-FAILED-BY-SUITE: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 3
CI-FAILED-BY-SUITE: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 1
CI-FAILED-BY-SUITE: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 2
CI-FAILED-BY-SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 10
