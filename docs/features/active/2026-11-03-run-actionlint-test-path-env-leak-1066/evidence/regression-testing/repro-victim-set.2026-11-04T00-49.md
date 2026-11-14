# REPRO Victim Set (P0-T17)

Timestamp: 2026-11-04T00-49
Command: pwsh -NoProfile -File SCRATCH/issue-1066-derive.ps1 -Root <worktree root> -Lk1 RAW/repro-leak-1.xml -Lk2 RAW/repro-leak-2.xml -Ct1 RAW/repro-control-1.xml -Ct2 RAW/repro-control-2.xml -OutDir SCRATCH
EXIT_CODE: 0
Output Summary:
- Inputs: LK1 and LK2 (45 containers each, P0-T13, P0-T14); CT1 and CT2 (44 containers each, P0-T15, P0-T16).
- U (containers whose profile differs between CT1 and CT2 or between LK1 and LK2): none (0).
- VS (containers whose PL_min failed, blocks, or container exceeds PC): 8 containers, listed below with PL_min beside PC.
- Summed excess over VS: failed=237, blocks=7.
- VS equals VICTIMS: True.
- TARGET profile in LK1: tests=35 failed=0 blocks=0 container=0.
- V_key (keys failing in both Leak runs and in neither control run; information only): 105 keys.
- Base = PC for every container except TARGET, and the LK1 profile of TARGET (tests=35 failed=0 blocks=0 container=0). PL_min equals PL_max because U is empty.
- Acceptance: VS is non-empty and TARGET failed is 0, so the reproduction occurred; no fail-before exception dossier is written.
- Derived sets are stored under SCRATCH as issue-1066-PL_min.json, issue-1066-PL_max.json, issue-1066-PC.json, issue-1066-Base.json, issue-1066-VS.json, issue-1066-V_key.txt, and issue-1066-CR4-subtract.txt for the CR comparisons.

## Derivation output (U, VS with PL_min beside PC, V_key, PC table with PL_min and PL_max)

```text
COUNTS: LK1=45 LK2=45 CT1=44 CT2=44 containers
U (0):
VS (8):
  VS tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | PL_min tests=26 failed=4 blocks=1 container=0 | PC tests=26 failed=3 blocks=0 container=0
  VS tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | PL_min tests=3 failed=3 blocks=1 container=0 | PC tests=3 failed=0 blocks=0 container=0
  VS tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | PL_min tests=12 failed=1 blocks=0 container=0 | PC tests=12 failed=0 blocks=0 container=0
  VS tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | PL_min tests=11 failed=11 blocks=1 container=0 | PC tests=11 failed=0 blocks=0 container=0
  VS tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | PL_min tests=51 failed=51 blocks=1 container=0 | PC tests=51 failed=4 blocks=0 container=0
  VS tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | PL_min tests=50 failed=50 blocks=1 container=0 | PC tests=50 failed=2 blocks=0 container=0
  VS tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | PL_min tests=43 failed=43 blocks=1 container=0 | PC tests=43 failed=3 blocks=0 container=0
  VS tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | PL_min tests=160 failed=160 blocks=1 container=0 | PC tests=160 failed=74 blocks=0 container=0
VS-EXCESS: failed=237 blocks=7
VS-EQUALS-VICTIMS: True
TARGET-LK1: tests=35 failed=0 blocks=0 container=0
V_KEY (105):
  K tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation [block]
  K tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1|enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.records the narrowing as strictly conservative on the widened-radius row
  K tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697) [block]
  K tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).derives 20 PreToolUse hooks and excludes 5 non-PreToolUse registrations from the bundle config
  K tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).leaves no batch-budget state in the bundle
  K tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1|Bundled Codex PreToolUse hooks run from the bundle location (issue #697).returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location
  K tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1|enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1).exits 0 with no stdout for a benign Bash payload when the attestation is dormant
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits [block]
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 one registration returns an array of count one
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 zero registrations return an empty array that is not null
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-21 registration count assertion rejects a null result
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-21 registration count assertion rejects an empty array
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.DEV-2 wave barrier allows a benign payload for every admitted tool name when no local checkpoint text is supplied
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.fails closed with exit 2 for <Label> on every registered handler
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.leaves no Codex batch-budget state behind
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.parses at least three matcher groups and every registered handler from config.toml
  K tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1|Every registered Codex PreToolUse handler accepts every tool name its matcher admits.reports enforce-completion-consistency in its own stderr rather than its neighbour
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract [block]
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows a safe <ToolName> payload on every group handler
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows a well-formed apply_patch payload whose tool_input maps to no file edit (<Label>)
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.allows an apply_patch update that touches only ungoverned files with a missing source
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from <ToolName>
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for <HookName> on a forbidden <ToolName> payload
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a checkpoint write that does not assert completion
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a file path that is not the governed checkpoint
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows an unrelated mapped write through its own entrypoint
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a checkpoint edit whose patch cannot be resolved
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a completion-asserting checkpoint write through its own entrypoint
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by <Label>
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for <Label>
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).reads issue-num and feature-folder from variables and reports ci_gate gaps
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string for a null checkpoint payload property lookup
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string when the checkpoint property value is null
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns null checkpoint content when the path is not a file
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns the file text when the checkpoint path resolves to a file
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).treats a null payload as asserting no completion
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 for <Label> on every group handler
  K tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1|Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 when a batch-budget payload omits session_id
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates [block]
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.fails closed on malformed Codex stdin JSON
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.allows a verified epic child merge
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.merge gate.allows the matching final epic PR after a successful CI gate
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows both registered MCP server spellings identically for <Operation>
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows explicit planning-artifact staging and an ordinary commit
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows feature planning document edits
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.allows only preparation lifecycle MCP operations
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies <Label> exactly without changing checkpoint bytes
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies a preparation commit when staged paths include production code
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies commit pathspecs and broad push modes
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies deletion or route mutation of the canonical preparation checkpoint
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies non-repository MCP tools during preparation
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies path traversal, move destinations, and security receipt writes
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies PR creation and CI execution commands
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.denies production edits
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.fails closed for an attested preparation child before its checkpoint exists
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.preparation route.fails closed when an attested preparation child changes its checkpoint route
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.allows a child after every dependency is merged
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.denies a child before an upstream merge
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.wave barrier.does not apply the execution barrier to preparation children
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.worktree removal gate.allows removal after merge
  K tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1|Codex epic preparation, wave, merge, and worktree gates.worktree removal gate.denies removal while the PR is open
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts [block]
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.allows exempt checkpoint writes and preparation-mode delegations (issue #535)
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.contains no legacy Claude environment-variable dependency in hooks or shared modules
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.emits the current PreToolUse deny envelope for shell and patch violations
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a documentation file path without consulting the checkpoint
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a mapped Write of feature documentation through its own entrypoint
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows an implementation path when the checkpoint is ready
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies <Label> as implementation command <Expected>
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies <Label> as implementation path <Expected>
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies a mapped Edit implementation through its own entrypoint
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation delegation when the checkpoint is not ready
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).detects an implementation delegation inside a serialized tool_input
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).reads the checkpoint from disk when no checkpoint text is supplied
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns empty checkpoint content when the checkpoint file is absent
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns the checkpoint file content when the checkpoint file is present
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a checkpoint missing lifecycle readiness as not ready
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a complete checkpoint as ready
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null checkpoint payload as not ready
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null tool_input as no implementation delegation
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats an unrelated serialized tool_input as no delegation
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.fails closed when the canonical checkpoint is deleted or becomes invalid JSON
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.fails closed with exit 2 and stderr for malformed stdin on every hook
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.ignores poisoned Claude variables when safe Codex stdin payloads are supplied
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.lists every shared hook module in the core pack manifest
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.reads stdin in every hook entrypoint
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.reconstructs update patches in memory and includes move destinations
  K tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1|Legacy Codex hooks use native lifecycle contracts.uses one SubagentStop continuation and stops repeated continuation loops
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) [block]
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).includes each frozen discovery row in both wrapper populations
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for deployment case <id>
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the corpus in process for topology case <id>
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the Python CLI for deployment case <id> through pwsh -File
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).matches the Python CLI for topology case <id> through pwsh -File
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexDeployment entry block in process for case <id>
  K tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1|Codex routing PowerShell wrappers match the Python CLI corpus (issue #697).runs the Resolve-CodexTopology entry block in process for case <id>
PC table:
  PC tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | tests=26 failed=3 blocks=0 container=0 | PL_min tests=26 failed=4 blocks=1 container=0 | PL_max tests=26 failed=4 blocks=1 container=0
  PC tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | tests=3 failed=0 blocks=0 container=0 | PL_min tests=3 failed=3 blocks=1 container=0 | PL_max tests=3 failed=3 blocks=1 container=0
  PC tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | tests=12 failed=0 blocks=0 container=0 | PL_min tests=12 failed=1 blocks=0 container=0 | PL_max tests=12 failed=1 blocks=0 container=0
  PC tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | tests=11 failed=0 blocks=0 container=0 | PL_min tests=11 failed=11 blocks=1 container=0 | PL_max tests=11 failed=11 blocks=1 container=0
  PC tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | tests=51 failed=4 blocks=0 container=0 | PL_min tests=51 failed=51 blocks=1 container=0 | PL_max tests=51 failed=51 blocks=1 container=0
  PC tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | tests=50 failed=2 blocks=0 container=0 | PL_min tests=50 failed=50 blocks=1 container=0 | PL_max tests=50 failed=50 blocks=1 container=0
  PC tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | tests=43 failed=3 blocks=0 container=0 | PL_min tests=43 failed=43 blocks=1 container=0 | PL_max tests=43 failed=43 blocks=1 container=0
  PC tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | tests=160 failed=74 blocks=0 container=0 | PL_min tests=160 failed=160 blocks=1 container=0 | PL_max tests=160 failed=160 blocks=1 container=0
  PC tests/scripts/dev-tools/activate.Tests.ps1 | tests=53 failed=13 blocks=0 container=0 | PL_min tests=53 failed=13 blocks=0 container=0 | PL_max tests=53 failed=13 blocks=0 container=0
  PC tests/scripts/dev-tools/agents-attribution.Tests.ps1 | tests=1 failed=0 blocks=0 container=0 | PL_min tests=1 failed=0 blocks=0 container=0 | PL_max tests=1 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | tests=5 failed=0 blocks=0 container=0 | PL_min tests=5 failed=0 blocks=0 container=0 | PL_max tests=5 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | tests=5 failed=4 blocks=0 container=0 | PL_min tests=5 failed=4 blocks=0 container=0 | PL_max tests=5 failed=4 blocks=0 container=0
  PC tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | tests=23 failed=16 blocks=0 container=0 | PL_min tests=23 failed=16 blocks=0 container=0 | PL_max tests=23 failed=16 blocks=0 container=0
  PC tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | tests=28 failed=1 blocks=0 container=0 | PL_min tests=28 failed=1 blocks=0 container=0 | PL_max tests=28 failed=1 blocks=0 container=0
  PC tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | tests=32 failed=8 blocks=0 container=0 | PL_min tests=32 failed=8 blocks=0 container=0 | PL_max tests=32 failed=8 blocks=0 container=0
  PC tests/scripts/dev-tools/HostTooling.Tests.ps1 | tests=22 failed=1 blocks=0 container=0 | PL_min tests=22 failed=1 blocks=0 container=0 | PL_max tests=22 failed=1 blocks=0 container=0
  PC tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 | tests=10 failed=0 blocks=0 container=0 | PL_min tests=10 failed=0 blocks=0 container=0 | PL_max tests=10 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/HostVerification.Tests.ps1 | tests=22 failed=0 blocks=0 container=0 | PL_min tests=22 failed=0 blocks=0 container=0 | PL_max tests=22 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | tests=25 failed=3 blocks=0 container=0 | PL_min tests=25 failed=3 blocks=0 container=0 | PL_max tests=25 failed=3 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | tests=11 failed=0 blocks=0 container=0 | PL_min tests=11 failed=0 blocks=0 container=0 | PL_max tests=11 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 | tests=22 failed=0 blocks=0 container=0 | PL_min tests=22 failed=0 blocks=0 container=0 | PL_max tests=22 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | tests=23 failed=0 blocks=0 container=0 | PL_min tests=23 failed=0 blocks=0 container=0 | PL_max tests=23 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 | tests=12 failed=0 blocks=0 container=0 | PL_min tests=12 failed=0 blocks=0 container=0 | PL_max tests=12 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | tests=17 failed=0 blocks=0 container=0 | PL_min tests=17 failed=0 blocks=0 container=0 | PL_max tests=17 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | tests=18 failed=2 blocks=0 container=0 | PL_min tests=18 failed=2 blocks=0 container=0 | PL_max tests=18 failed=2 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | tests=8 failed=0 blocks=0 container=0 | PL_min tests=8 failed=0 blocks=0 container=0 | PL_max tests=8 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | tests=21 failed=1 blocks=0 container=0 | PL_min tests=21 failed=1 blocks=0 container=0 | PL_max tests=21 failed=1 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | tests=3 failed=0 blocks=0 container=0 | PL_min tests=3 failed=0 blocks=0 container=0 | PL_max tests=3 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | tests=29 failed=0 blocks=0 container=0 | PL_min tests=29 failed=0 blocks=0 container=0 | PL_max tests=29 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | tests=10 failed=0 blocks=0 container=0 | PL_min tests=10 failed=0 blocks=0 container=0 | PL_max tests=10 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | tests=21 failed=0 blocks=0 container=0 | PL_min tests=21 failed=0 blocks=0 container=0 | PL_max tests=21 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/link-parent-child.Tests.ps1 | tests=22 failed=0 blocks=0 container=0 | PL_min tests=22 failed=0 blocks=0 container=0 | PL_max tests=22 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | tests=35 failed=2 blocks=0 container=0 | PL_min tests=35 failed=2 blocks=0 container=0 | PL_max tests=35 failed=2 blocks=0 container=0
  PC tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | tests=2 failed=2 blocks=0 container=0 | PL_min tests=2 failed=2 blocks=0 container=0 | PL_max tests=2 failed=2 blocks=0 container=0
  PC tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | tests=44 failed=0 blocks=0 container=0 | PL_min tests=44 failed=0 blocks=0 container=0 | PL_max tests=44 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | tests=13 failed=1 blocks=0 container=0 | PL_min tests=13 failed=1 blocks=0 container=0 | PL_max tests=13 failed=1 blocks=0 container=0
  PC tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | tests=18 failed=16 blocks=0 container=0 | PL_min tests=18 failed=16 blocks=0 container=0 | PL_max tests=18 failed=16 blocks=0 container=0
  PC tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | tests=13 failed=12 blocks=0 container=0 | PL_min tests=13 failed=12 blocks=0 container=0 | PL_max tests=13 failed=12 blocks=0 container=0
  PC tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | tests=27 failed=4 blocks=0 container=0 | PL_min tests=27 failed=4 blocks=0 container=0 | PL_max tests=27 failed=4 blocks=0 container=0
  PC tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | tests=20 failed=3 blocks=0 container=0 | PL_min tests=20 failed=3 blocks=0 container=0 | PL_max tests=20 failed=3 blocks=0 container=0
  PC tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | tests=4 failed=4 blocks=0 container=0 | PL_min tests=4 failed=4 blocks=0 container=0 | PL_max tests=4 failed=4 blocks=0 container=0
  PC tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 | tests=6 failed=1 blocks=0 container=0 | PL_min tests=6 failed=1 blocks=0 container=0 | PL_max tests=6 failed=1 blocks=0 container=0
  PC tests/scripts/dev-tools/tree.Tests.ps1 | tests=29 failed=0 blocks=0 container=0 | PL_min tests=29 failed=0 blocks=0 container=0 | PL_max tests=29 failed=0 blocks=0 container=0
  PC tests/scripts/dev-tools/verify-host.Tests.ps1 | tests=3 failed=0 blocks=0 container=0 | PL_min tests=3 failed=0 blocks=0 container=0 | PL_max tests=3 failed=0 blocks=0 container=0
```
