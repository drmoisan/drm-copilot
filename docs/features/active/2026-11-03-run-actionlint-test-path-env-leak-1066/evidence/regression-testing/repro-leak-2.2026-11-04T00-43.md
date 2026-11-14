# Baseline LK2: Leak Order over REPRO, Repeat (P0-T14)

Timestamp: 2026-11-04T00-43
Command: sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-leak.txt repro-leak-2.xml issue-1066-p0t14.log (new process; same 45-file Leak list as P0-T13; JUnit to RAW/repro-leak-2.xml); profile comparison by SCRATCH/issue-1066-junit-sets.ps1 -ProfileMode -First RAW/repro-leak-2.xml -Second RAW/repro-leak-1.xml
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester totals: Total=1048 Passed=629 Failed=417 Skipped=2 NotRun=0 FailedBlocks=7 FailedContainers=0.
- Container profile table: 45 containers with numeric fields; sums tests=1048 failed=417 blocks=7 container=0.
- Containers whose profile differs from LK1: none (`DIFFERING: 0`).
- Failing keys (information only): 209 distinct keys over 1055 testcases.

## File order

```text
ORDER: Set=Repro Mode=Leak Seed=0 Count=45
   1 tests/scripts/dev-tools/run-actionlint.Tests.ps1
   2 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
   3 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
   4 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
   5 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
   6 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
   7 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
   8 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
   9 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
  10 tests/scripts/dev-tools/activate.Tests.ps1
  11 tests/scripts/dev-tools/agents-attribution.Tests.ps1
  12 tests/scripts/dev-tools/bootstrap-host.Tests.ps1
  13 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
  14 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
  15 tests/scripts/dev-tools/HostBootstrap.Tests.ps1
  16 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
  17 tests/scripts/dev-tools/HostTooling.Tests.ps1
  18 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1
  19 tests/scripts/dev-tools/HostVerification.Tests.ps1
  20 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
  21 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
  22 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
  23 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
  24 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
  25 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
  26 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
  27 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
  28 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
  29 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
  30 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
  31 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
  32 tests/scripts/dev-tools/link-feature-docs.Tests.ps1
  33 tests/scripts/dev-tools/link-parent-child.Tests.ps1
  34 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
  35 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
  36 tests/scripts/dev-tools/new-potential-entry.Tests.ps1
  37 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
  38 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
  39 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
  40 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
  41 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
  42 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
  43 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
  44 tests/scripts/dev-tools/tree.Tests.ps1
  45 tests/scripts/dev-tools/verify-host.Tests.ps1
```

## Container profile table and differences from LK1

```text
PROFILE: Containers=45 Tests=1048 Failed=417 Blocks=7 Container=0
  P tests/scripts/dev-tools/run-actionlint.Tests.ps1 | tests=35 failed=0 blocks=0 container=0
  P tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=4 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=3 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=1 blocks=0 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=11 blocks=1 container=0
  P tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=51 blocks=1 container=0
  P tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=50 blocks=1 container=0
  P tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=43 blocks=1 container=0
  P tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=160 blocks=1 container=0
  P tests/scripts/dev-tools/activate.Tests.ps1 | tests=53 failed=13 blocks=0 container=0
  P tests/scripts/dev-tools/agents-attribution.Tests.ps1 | tests=1 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | tests=5 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | tests=5 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | tests=23 failed=16 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | tests=28 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | tests=32 failed=8 blocks=0 container=0
  P tests/scripts/dev-tools/HostTooling.Tests.ps1 | tests=22 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/HostVerification.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | tests=25 failed=3 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | tests=11 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | tests=23 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 | tests=12 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | tests=17 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | tests=18 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | tests=8 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | tests=21 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | tests=10 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | tests=21 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/link-parent-child.Tests.ps1 | tests=22 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | tests=35 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | tests=2 failed=2 blocks=0 container=0
  P tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | tests=44 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | tests=13 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | tests=18 failed=16 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | tests=13 failed=12 blocks=0 container=0
  P tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | tests=27 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | tests=20 failed=3 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | tests=4 failed=4 blocks=0 container=0
  P tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 | tests=6 failed=1 blocks=0 container=0
  P tests/scripts/dev-tools/tree.Tests.ps1 | tests=29 failed=0 blocks=0 container=0
  P tests/scripts/dev-tools/verify-host.Tests.ps1 | tests=3 failed=0 blocks=0 container=0
DIFFERING: 0
```

## Failing keys (information only)

```text
FIRST: Total=1055 Failed=209
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation [block]
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.records the narrowing as strictly conservative on the widened-radius row
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.reports unresolved on every non-conforming-timestamp row of the shared table
  F1 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.derivation helpers.Get-ParallelDriftGateUnresolvedState surfaces LatestAt for the latest event of each item
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697) [block]
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).derives 20 PreToolUse hooks and excludes 5 non-PreToolUse registrations from the bundle config
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).leaves no batch-budget state in the bundle
  F1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location
  F1 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1|enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1).exits 0 with no stdout for a benign Bash payload when the attestation is dormant
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits [block]
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 one registration returns an array of count one
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 zero registrations return an empty array that is not null
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-21 registration count assertion rejects a null result
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-21 registration count assertion rejects an empty array
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.DEV-2 wave barrier allows a benign payload for every admitted tool name when no local checkpoint text is supplied
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.fails closed with exit 2 for <Label> on every registered handler
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.leaves no Codex batch-budget state behind
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.parses at least three matcher groups and every registered handler from config.toml
  F1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.reports enforce-completion-consistency in its own stderr rather than its neighbour
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract [block]
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows a safe <ToolName> payload on every group handler
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows a well-formed apply_patch payload whose tool_input maps to no file edit (<Label>)
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows an apply_patch update that touches only ungoverned files with a missing source
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from <ToolName>
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for <HookName> on a forbidden <ToolName> payload
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a checkpoint write that does not assert completion
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a file path that is not the governed checkpoint
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows an unrelated mapped write through its own entrypoint
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows mapped tool_input that carries no file_path
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a checkpoint edit whose patch cannot be resolved
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a completion-asserting checkpoint write through its own entrypoint
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by <Label>
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for <Label>
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).reads issue-num and feature-folder from variables and reports ci_gate gaps
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string for a null checkpoint payload property lookup
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string when the checkpoint property value is null
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns null checkpoint content when the path is not a file
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns the file text when the checkpoint path resolves to a file
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).treats a null payload as asserting no completion
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 for <Label> on every group handler
  F1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 when a batch-budget payload omits session_id
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates [block]
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.fails closed on malformed Codex stdin JSON
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.allows a verified epic child merge
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.allows the matching final epic PR after a successful CI gate
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.denies a mismatched final PR number
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows both registered MCP server spellings identically for <Operation>
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows explicit planning-artifact staging and an ordinary commit
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows feature planning document edits
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows only preparation lifecycle MCP operations
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies <Label> exactly without changing checkpoint bytes
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies a preparation commit when staged paths include production code
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies commit pathspecs and broad push modes
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies deletion or route mutation of the canonical preparation checkpoint
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies non-repository MCP tools during preparation
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies path traversal, move destinations, and security receipt writes
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies PR creation and CI execution commands
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies production edits
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.fails closed for an attested preparation child before its checkpoint exists
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.fails closed when an attested preparation child changes its checkpoint route
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.requires explicit matching MCP workspace_root for an attested preparation child
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.allows a child after every dependency is merged
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.denies a child before an upstream merge
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.does not apply the execution barrier to preparation children
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.worktree removal gate.allows removal after merge
  F1 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.worktree removal gate.denies removal while the PR is open
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts [block]
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.allows exempt checkpoint writes and preparation-mode delegations (issue #535)
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.contains no legacy Claude environment-variable dependency in hooks or shared modules
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.denies preimplementation and batch-budget violations through their pure decisions
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.emits the current PreToolUse deny envelope for shell and patch violations
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a documentation file path without consulting the checkpoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a mapped Write of feature documentation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows an implementation path when the checkpoint is ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies <Label> as implementation command <Expected>
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies <Label> as implementation path <Expected>
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies a mapped Edit implementation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an apply_patch implementation through its own entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation command when the checkpoint is not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation delegation when the checkpoint is not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).detects an implementation delegation inside a serialized tool_input
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).reads the checkpoint from disk when no checkpoint text is supplied
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns empty checkpoint content when the checkpoint file is absent
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns the checkpoint file content when the checkpoint file is present
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a checkpoint missing lifecycle readiness as not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a complete checkpoint as ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null checkpoint payload as not ready
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null tool_input as no implementation delegation
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats an unrelated serialized tool_input as no delegation
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.fails closed when the canonical checkpoint is deleted or becomes invalid JSON
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.fails closed with exit 2 and stderr for malformed stdin on every hook
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.ignores poisoned Claude variables when safe Codex stdin payloads are supplied
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.lists every shared hook module in the core pack manifest
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.reads stdin in every hook entrypoint
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.reconstructs update patches in memory and includes move destinations
  F1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.uses one SubagentStop continuation and stops repeated continuation loops
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) [block]
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).includes each frozen discovery row in both wrapper populations
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case <id>
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case <id>
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the Python CLI for deployment case <id> through pwsh -File
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the Python CLI for topology case <id> through pwsh -File
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).resolves modules through the .claude/lib fallback inside drm-copilot
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case <id>
  F1 tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case <id>
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).derives the repo root from the venv parent and renders the at-root prompt (light background)
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background)
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).renders the prompt uncolored when the host background is null (Test Explorer host parity)
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Get-VenvAwarePrompt (prompt decision used by the shim).wraps the venv-active form in green when the background is dark
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).activates the venv and installs the prompt when a .venv ancestor exists
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).installs a prompt that delegates to the venv-aware builder
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).throws guidance when no .venv ancestor is found
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Invoke-VenvActivation (orchestration; seams mocked).throws when the resolved Activate.ps1 is missing
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).returns an empty string when no ancestor contains .venv
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).returns the nearest qualifying ancestor when multiple ancestors contain .venv
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).returns the start directory when it directly contains .venv
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).walks up from a deeper start regardless of depth
  F1 tests/scripts/dev-tools/activate.Tests.ps1|Resolve-RepoRoot (depth-robust ancestor walk).walks up from a two-level-deep start to the ancestor containing .venv
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.falls back to the absolute path when the location is outside the repo root
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.returns a repo-relative path with a leading backslash for nested folders
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Set-DrmCopilotPrompt.renders the requested prompt name with the repo-relative folder
  F1 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1|DrmCopilotPromptSupport.ps1.Start-DrmCopilotPromptSession.activates the virtual environment with the requested prompt name and installs the custom prompt
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.installs packages, modules, Graphite CLI, and clones projects
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.skips the project poetry install by request
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.warns and skips Graphite CLI when npm is missing
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.warns and skips verification when verify-host.ps1 is absent
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.apply.warns when pyproject.toml is absent
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.failure paths.propagates a terminating error raised by the verify script
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-APPLY-INVOKES-POETRY-INSTALL installs the poetry tool in apply mode
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-DRYRUN-INVOKES-POETRY-INSTALL routes the poetry tool install in dry-run mode
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-POETRY-INSTALL-ORDER installs poetry after the PATH refresh and before the project install
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.poetry tool install.AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL still installs the poetry tool when the project install is skipped
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
  F1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
  F1 tests/scripts/dev-tools/HostBootstrap.Tests.ps1|Install-PoetryWithPip.AC11-PIP-STREAMS installs poetry with -StreamToHost, emits no pip output, adds the poetry directory, and refreshes the session Path
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-ProjectRepoRoot.falls back to the drm-copilot folder name when the project target path is empty
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-ProjectRepoRoot.returns the drm-copilot project target path under the workspace
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-ProjectRepoRoot.returns the full form of an explicit repo root
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Resolve-WorkspaceRoot.returns the full form of an explicit path
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.clones the project through the git wrapper in apply mode
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.derives the target path from the url in dry run
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.reports the planned clone with an explicit target path in dry run
  F1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1|Sync-ProjectsFromManifest.skips a project that is already present
  F1 tests/scripts/dev-tools/HostTooling.Tests.ps1|Read-HostToolsManifest.returns the parsed manifest object when the file exists
  F1 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1|Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded.Get-NpmVersion (real reader).throws when the manifest has no version field
  F1 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1|Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded.git/npm/gh seam failures.returns 1 and does not open a PR when 'git push -u origin <branch>' fails
  F1 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1|Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded.release-branch derivation (pure function).derives release/full-<timestamp> from a fixed Now
  F1 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1|Invoke-MarketplacePublish.ps1 - Invoke-MarketplacePublishGuarded.Get-NpmVersion (real reader) and Get-ReleaseBranchName.derives release/extension-<timestamp> from a fixed Now
  F1 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1|Invoke-MarketplacePublish.ps1 - Invoke-MarketplacePublishGuarded.Get-NpmVersion (real reader) and Get-ReleaseBranchName.throws when the manifest has no version field
  F1 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1|Invoke-ReleaseTagPush.ps1 - Invoke-ReleaseTagPushGuarded.Get-NpmVersion (real reader).throws when the manifest has no version field
  F1 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1|new-claude-worktree-session.ps1 - Get-WorktreeGroupDirectory.Grouping directory derivation.returns <parent>/<repoName>-wt
  F1 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1|new-claude-worktree-session.ps1 - Invoke-GitWorktreeAdd.Git worktree add composition via injected scriptblock seam.composes 'worktree add <path> -b <branch>' through the InvokeGit seam
  F1 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1|new-potential-entry.ps1 - template root resolution.falls back to the workspace template when the supplied template root lacks the potential template
  F1 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1|new-potential-entry.ps1 - template root resolution.uses the supplied template root when the bundled potential template exists
  F1 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1|post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot.falls back deterministically to the repository root implied by the script path
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-BOUND-DEBUG-INFO-PROGRESS forwards bound -Debug, -InformationAction, and -ProgressAction
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-HIGH adds no Confirm key for an inherited ConfirmPreference of High
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-LOW forwards Confirm true for an inherited ConfirmPreference of Low
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-NONE forwards Confirm false for an inherited ConfirmPreference of None
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEBUG-INHERITED forwards Debug true for an inherited DebugPreference of Continue
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEFAULT-NO-WHATIF adds no WhatIf key under default preferences
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-VERBOSE-INHERITED forwards Verbose true for an inherited VerbosePreference of Continue
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-BOUND-FALSE-WINS forwards WhatIf false when -WhatIf:$false is bound under an inherited true preference
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-INHERITED forwards WhatIf true when WhatIfPreference is inherited and -WhatIf is unbound
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards -Verbose and -WarningAction and does not forward -ErrorAction
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards the switch parameters as passed
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
  F1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1|publish-sideloaded-extension.ps1 entry point - real orchestrator.AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS makes no state-changing seam call under an inherited WhatIfPreference
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.throws when no VS Code CLI command is found on PATH
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.adds --force to the install arguments and requests npm cleanup with -Force
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.creates the output directory through New-Item when it is absent
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.passes an explicit -CodeCommand to the CLI resolver
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.returns the VSIX path named from the -Now clock as its only output
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1|Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.throws when the extension package.json is missing
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-ProjectCompile.runs the npm compile script when package.json defines one
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-ProjectCompile.runs tsc when only tsconfig.json exists
  F1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1|Invoke-ProjectCompile.skips compilation when neither a compile script nor tsconfig.json exists
  F1 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1|sync-agents-from-instructions.ps1.Get-AgentContent ordering.emits general instruction files before language-specific instruction files in generated AGENTS.md output
  F1 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1|sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups
  F1 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1|sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile sorts normalized relative paths ordinally
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.dot-sources the claude-code probe through the default seam and reports a session without observations unsupported
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.dot-sources the codex probe through the default seam and reports a session without observations unsupported
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.dot-sources the github-copilot probe through the default seam and reports a session without observations unsupported
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1|Test-DiscoveryHostCapability.ps1 entry point.exits 2 and writes the unsupported document when the workspace has no installed probe
  F1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1|Test-DiscoveryHostCapability.ps1.exits 2 with an unsupported document when the host has no installed probe
```
