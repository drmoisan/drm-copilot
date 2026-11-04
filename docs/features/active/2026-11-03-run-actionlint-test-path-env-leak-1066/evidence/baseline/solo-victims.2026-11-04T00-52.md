# Solo Victim Runs (P0-T18)

Timestamp: 2026-11-04T00-52
Command: sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-solo-parity.txt solo-parity.xml issue-1066-p0t18a.log; sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-solo-transport.txt solo-transport.xml issue-1066-p0t18b.log (each runs SCRATCH/issue-1066-run-list.ps1 in its own new process over one file)
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` alone (RAW/solo-parity.xml): Total=160 Passed=86 Failed=74 FailedBlocks=0; profile tests=160 failed=74 blocks=0 container=0; exit 1 (pre-existing host failures).
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` alone (RAW/solo-transport.xml): Total=51 Passed=47 Failed=4 FailedBlocks=0; profile tests=51 failed=4 blocks=0 container=0; exit 1 (pre-existing host failures).
- Both profiles have numeric fields. Failing-key lists (information only) follow.

## Resolve-CodexRouting.Parity profile

```text
PROFILE: Containers=1 Tests=160 Failed=74 Blocks=0 Container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=74 blocks=0 container=0
```

## Resolve-CodexRouting.Parity failing keys (information only)

```text
FIRST: Total=160 Failed=74
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-c1-standalone
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-c3-epic-execution-c4-ceiling
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-ceiling-below-band
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-commit-steward
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-c3-c4-ceiling
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-c3-epic-c4-ceiling
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-ceiling-below-band
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-legacy-parity-analyst-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-migration-coverage-reviewer-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-profile-is-not-logical-role
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-requirements-reconciler-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c1
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c2
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-c4
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-discovery-runtime-characterization-analyst-epic-c3
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-feature-review-alias-epic-preparation
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-forced-epic-planner
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-invalid-choice
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-missing-required
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case dep-unsupported-agent
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-cross-cutting
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-adjudicate-unspecified-behavior
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-alias-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-characterize-runtime-behavior
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-cross-cutting
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-empty-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-epic_execution_child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-epic_preparation_child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-epic-root-refused
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-extract-feature-contract
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-generate-acceptance-scenarios
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-initialize-discovery-workspace
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-inventory-legacy-system
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-production-negative
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-production-positive
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-reconcile-parity-matrix
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-review-discovery-coverage
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-root-override
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-test-count
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-unknown-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-validate-discovery-artifacts
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-discovery-whitespace-skill
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-empty-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-epic-execution-child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-epic-preparation-child
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-explicit-ordinary-small
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-missing-required
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-non-ascii-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-non-integer-count
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-ordinary-skill-default
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-ordinary-skill-explicit
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-powershell-budget-exceeded
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-repeated-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case topo-standalone-small
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).resolves modules through the .claude/lib fallback inside drm-copilot
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case dep-commit-steward
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case dep-invalid-choice
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case dep-unsupported-agent
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case topo-empty-language
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case topo-standalone-small
```

## codex-pretooluse-transport profile

```text
PROFILE: Containers=1 Tests=51 Failed=4 Blocks=0 Container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=4 blocks=0 container=0
```

## codex-pretooluse-transport failing keys (information only)

```text
FIRST: Total=51 Failed=4
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from apply_patch
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from Edit
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from Write
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows mapped tool_input that carries no file_path
```
