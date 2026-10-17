# Codex Suites ([P7-T7])

Timestamp: 2026-10-10T00-17
Command: R-SCOPED over tests/scripts/codex-hooks (every existing file under the folder, which includes hook-dependency-failure.Codex.Tests.ps1, hook-dependency-guard.Tests.ps1, legacy-codex-hook-contracts.Tests.ps1, and hook-import-failure-exemptions.FailClosed.Tests.ps1)
EXIT_CODE: 0
Output Summary: PassedCount 1556, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0 across 55 containers. The W-CONVERT line of exemption-decisions.md is `H7, H8` (it does not contain H2), so tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 is not excluded; it ran and passed (5 tests).

```text

Starting discovery in 55 files.
Discovery found 1556 tests in 1.72s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 876ms (458ms|305ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 223ms (102ms|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 15.66s (15.62s|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 215ms (138ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 375ms (329ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 737ms (696ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 318ms (232ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 99ms (45ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 253ms (182ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 265ms (162ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 443ms (356ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 232ms (139ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 34.92s (34.87s|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 24.57s (24.49s|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 214ms (126ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 302ms (207ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 195ms (117ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 122ms (74ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 145ms (91ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 130ms (81ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 98ms (51ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 118ms (71ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 484ms (413ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 292ms (235ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 276ms (213ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 385ms (310ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 682ms (591ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 211ms (158ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 1.62s (1.46s|119ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 487ms (383ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 538ms (474ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 809ms (701ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 320ms (215ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 283ms (173ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 186ms (128ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 167ms (113ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 425ms (348ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 322ms (261ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 140ms (93ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 111ms (71ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 346ms (298ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 197ms (130ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.49s (4.41s|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 256ms (202ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 147ms (109ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 176ms (95ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 214ms (138ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 191ms (96ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 3.45s (2.93s|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 90ms (47ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 299ms (264ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 11.49s (11.43s|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 126ms (80ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 436ms (346ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 125ms (85ms|28ms)
Tests completed in 110.37s
Tests Passed: 1556, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 1556
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | result=Passed | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | result=Passed | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | result=Passed | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | result=Passed | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | result=Passed | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | result=Passed | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | result=Passed | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | result=Passed | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | result=Passed | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | result=Passed | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | result=Passed | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | result=Passed | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | result=Passed | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | result=Passed | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | result=Passed | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | result=Passed | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | result=Passed | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | result=Passed | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Passed | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | result=Passed | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | result=Passed | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | result=Passed | passed=8 | failed=0
PASSED: builds a deny decision without state when no state is supplied
PASSED: attaches the state to a deny decision when state is supplied
PASSED: allows a path outside the language surface without recording state
PASSED: allows an already-counted file without consuming another slot
PASSED: consumes a production slot for a new production file
PASSED: allows when the mapped tool_input is empty
PASSED: denies when the mapped tool_input is malformed JSON
PASSED: allows when the mapped tool_input carries no file_path
PASSED: allows a mapped path outside the language surface
PASSED: probes the state directory through the default path-existence seam
PASSED: creates the state directory and records a new file when no state exists
PASSED: ignores an unreadable state file and starts from the default caps
PASSED: still allows when the state file cannot be written
PASSED: allows through its own entrypoint when the payload maps to no file edit
PASSED: allows through its own entrypoint for a mapped path outside the language surface
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: fails closed with exit 2 when its entrypoint receives no session_id
PASSED: builds a deny decision without state when no state is supplied
PASSED: attaches the state to a deny decision when state is supplied
PASSED: allows a path outside the language surface without recording state
PASSED: allows an already-counted file without consuming another slot
PASSED: consumes a production slot for a new production file
PASSED: allows when the mapped tool_input is empty
PASSED: denies when the mapped tool_input is malformed JSON
PASSED: allows when the mapped tool_input carries no file_path
PASSED: allows a mapped path outside the language surface
PASSED: probes the state directory through the default path-existence seam
PASSED: creates the state directory and records a new file when no state exists
PASSED: ignores an unreadable state file and starts from the default caps
PASSED: still allows when the state file cannot be written
PASSED: allows through its own entrypoint when the payload maps to no file edit
PASSED: allows through its own entrypoint for a mapped path outside the language surface
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: fails closed with exit 2 when its entrypoint receives no session_id
PASSED: keeps the Claude and Codex route helpers byte-identical
PASSED: loads the route functions from its own file
PASSED: defines exactly the three neutral route functions
PASSED: route_id large
PASSED: route_id remediation
PASSED: route_id preparation
PASSED: route_id small
PASSED: route_id blank
PASSED: route_id unknown
PASSED: route_id wrong case
PASSED: no route keys
PASSED: route_id null with path_selected large
PASSED: route_id non-string with path_selected large
PASSED: route_id small wins over path_selected large
PASSED: path_selected large without route_id
PASSED: path_selected small without route_id
PASSED: terminal next_step complete
PASSED: terminal S12_complete
PASSED: non-terminal completed steps
PASSED: malformed JSON
PASSED: array JSON
PASSED: string JSON
PASSED: empty text
PASSED: whitespace text
PASSED: selects large from {"route_id":"large","path_selected":"small"}
PASSED: selects  from {"route_id":null,"path_selected":"large"}
PASSED: selects remediation from {"path_selected":"remediation"}
PASSED: selects  from {not-json
PASSED: loads the route functions from its own file
PASSED: defines exactly the three neutral route functions
PASSED: route_id large
PASSED: route_id remediation
PASSED: route_id preparation
PASSED: route_id small
PASSED: route_id blank
PASSED: route_id unknown
PASSED: route_id wrong case
PASSED: no route keys
PASSED: route_id null with path_selected large
PASSED: route_id non-string with path_selected large
PASSED: route_id small wins over path_selected large
PASSED: path_selected large without route_id
PASSED: path_selected small without route_id
PASSED: terminal next_step complete
PASSED: terminal S12_complete
PASSED: non-terminal completed steps
PASSED: malformed JSON
PASSED: array JSON
PASSED: string JSON
PASSED: empty text
PASSED: whitespace text
PASSED: selects large from {"route_id":"large","path_selected":"small"}
PASSED: selects  from {"route_id":null,"path_selected":"large"}
PASSED: selects remediation from {"path_selected":"remediation"}
PASSED: selects  from {not-json
PASSED: derives 17 PreToolUse hooks and excludes 4 non-PreToolUse registrations from the bundle config
PASSED: returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location
PASSED: leaves no batch-budget state in the bundle
PASSED: reports the whole pr_gate object as missing when the checkpoint has none
PASSED: names each absent pr_gate field individually
PASSED: requires the pr_gate head_sha to match the ci_gate head_sha
PASSED: reports no missing evidence when the pr_gate is complete and agrees with the ci_gate
PASSED: reports the whole ci_gate object as missing when the checkpoint has none
PASSED: does not require pr_gate evidence when the route opts out
PASSED: denies a governed checkpoint write whose content is not valid JSON
PASSED: allows a completion-asserting checkpoint that carries every required piece of evidence
PASSED: denies a completion-asserting checkpoint whose pr_gate evidence is incomplete
PASSED: returns an empty string when git succeeds with no output (the detached-HEAD condition)
PASSED: returns an empty string when the git wrapper reports a non-zero exit code
PASSED: returns the trimmed branch name when git succeeds with output
PASSED: passes the repository root through to the git wrapper as a -C argument
PASSED: exits 0 with no stdout for a benign Bash payload when the attestation is dormant
PASSED: returns an empty string when git succeeds with no output (the detached-HEAD condition)
PASSED: throws the transport-blocked message when the git wrapper reports a non-zero exit code
PASSED: returns the trimmed branch name when git succeeds with output
PASSED: passes the repository root through to the git wrapper as a -C argument
PASSED: denies a push with an empty current branch while preparation is selected (RD-1b)
PASSED: allows a push with an empty current branch when the hook is dormant (RD-1b)
PASSED: exits 0 with no stdout for a benign Bash payload
PASSED: baseline mock interception probe
PASSED: uses the current nested command-handler hook schema
PASSED: registers root provenance, attestation, planning, wave, merge, worktree, and stop gates
PASSED: pins both epic personas to Sol with ultra reasoning
PASSED: pins both epic personas to Sol with ultra reasoning
PASSED: keeps the ordinary orchestrator out of the positive epic delegation surface
PASSED: preserves the merged planner lifecycle boundary
PASSED: keeps deterministic topology independent from C1-C4 deployment selection
PASSED: includes every epic runtime surface in the core pack manifest
PASSED: keeps root and tracked bundle runtime copies byte-identical
PASSED: keeps hook, config, and agent files within the 500-line limit
PASSED: treats artifacts/baselines as forbidden: True
PASSED: treats artifacts/qa-gates as forbidden: True
PASSED: treats artifacts/research as forbidden: True
PASSED: treats a Windows-separated forbidden path as forbidden: True
PASSED: treats a canonical feature evidence path as forbidden: False
PASSED: treats a permitted artifacts sub-path as forbidden: False
PASSED: builds a deny decision naming the offending path
PASSED: allows when the mapped tool_input is empty
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows when the mapped tool_input carries no file_path
PASSED: denies a forbidden evidence path
PASSED: allows a canonical evidence path
PASSED: returns 0 and writes a deny decision for a forbidden mapped path
PASSED: returns 0 with no output for an allowed mapped path
PASSED: evaluates both sides of an apply_patch rename
PASSED: returns 2 and writes the reason to stderr for empty stdin
PASSED: exits 0 and denies a forbidden mapped path
PASSED: exits 2 on empty stdin
PASSED: parses checkpoint JSON through the mockable wrapper
PASSED: maps an exact canonical step to canonical index 3
PASSED: maps an underscore variant to canonical index 3
PASSED: maps a dotted variant to canonical index 4
PASSED: maps a hyphen variant to canonical index 5
PASSED: maps a non-canonical entry to canonical index -1
PASSED: maps an empty entry to canonical index -1
PASSED: returns null when completed_steps are in canonical order
PASSED: returns null when the list holds only non-canonical entries
PASSED: returns the first out-of-order pair with its positions
PASSED: recognises an exact match for prefix matching: True
PASSED: recognises an underscore variant for prefix matching: True
PASSED: recognises an unrelated entry for prefix matching: False
PASSED: returns null when promotion and planning both precede an advanced step
PASSED: reports the advanced step and both missing prerequisites
PASSED: reports only the missing planning prerequisite when promotion is present
PASSED: recognises the governed checkpoint path
PASSED: allows when the mapped tool_input is empty
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows when the mapped tool_input carries no file_path
PASSED: allows a file path that is not the governed checkpoint
PASSED: denies an empty-content write to the governed checkpoint
PASSED: denies a checkpoint write whose content is not valid JSON
PASSED: allows a checkpoint write whose completed_steps are in canonical order
PASSED: allows a checkpoint write with an empty completed_steps list
PASSED: allows an out-of-order checkpoint when a rollback is recorded
PASSED: denies an out-of-order checkpoint with no rollback history
PASSED: denies an advanced step recorded without its prerequisites
PASSED: names only the missing planning prerequisite when promotion is recorded
PASSED: exits 0 and denies an out-of-order checkpoint write
PASSED: exits 0 with no output for an unrelated mapped write
PASSED: exits 2 on empty stdin
PASSED: returns null for empty input when the caller marks the document optional
PASSED: throws a blocked message for empty input when the document is required
PASSED: allows a read-only inspection command from the allowlist
PASSED: allows a read-only inspection command from the allowlist
PASSED: allows a read-only inspection command from the allowlist
PASSED: rejects a git add whose path list resolves to no tokens
PASSED: rejects a git commit when the staged set is empty
PASSED: denies a patch that advances an execution-through-CI step status
PASSED: denies a patch that identifies no artifact path at all
PASSED: denies a tool that preparation mode does not classify
PASSED: invokes Get-EpicPlanningRegisteredMcpTool from no top-level statement
PASSED: allows any tool with a missing registry when no checkpoint or attestation is present
PASSED: allows an mcp__ tool with a missing registry on a non-preparation route
PASSED: returns the committed-registry decision for apply_patch planning document edit (allow) with a missing registry
PASSED: returns the committed-registry decision for apply_patch production edit (deny) with a missing registry
PASSED: returns the committed-registry decision for apply_patch checkpoint delete (deny) with a missing registry
PASSED: returns the committed-registry decision for Bash git status (allow) with a missing registry
PASSED: returns the committed-registry decision for Bash git reset --hard (deny) with a missing registry
PASSED: allows lifecycle tool mcp__drm-copilot__new_potential_entry with a missing registry in preparation mode
PASSED: allows lifecycle tool mcp__drm-copilot__new_potential_bug_entry with a missing registry in preparation mode
PASSED: allows lifecycle tool mcp__drm-copilot__potential_to_issue with a missing registry in preparation mode
PASSED: allows lifecycle tool mcp__drm-copilot__new_active_feature_folder with a missing registry in preparation mode
PASSED: allows lifecycle tool mcp__drm-copilot__resolve_atomic_plan_prompt with a missing registry in preparation mode
PASSED: allows lifecycle tool mcp__drm-copilot__resolve_execute_hard_lock_prompt with a missing registry in preparation mode
PASSED: denies a lifecycle tool whose workspace_root differs from the attested cwd with a missing registry
PASSED: denies mcp__drm-copilot__validate_orchestration_artifacts with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm_copilot__validate_orchestration_artifacts with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm-copilot__resolve_orchestration_topology with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm_copilot__resolve_orchestration_topology with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm-copilot__resolve_provider_routing with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm_copilot__resolve_provider_routing with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm-copilot__transition_prepared_orchestration with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm_copilot__transition_prepared_orchestration with a reason naming the missing registry in preparation mode
PASSED: denies mcp__drm-copilot__unregistered_tool with a reason naming the missing registry in preparation mode
PASSED: allows semantic tool mcp__drm-copilot__validate_orchestration_artifacts with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm_copilot__validate_orchestration_artifacts with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm-copilot__resolve_orchestration_topology with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm_copilot__resolve_orchestration_topology with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm-copilot__resolve_provider_routing with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm_copilot__resolve_provider_routing with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm-copilot__transition_prepared_orchestration with the committed registry in preparation mode
PASSED: allows semantic tool mcp__drm_copilot__transition_prepared_orchestration with the committed registry in preparation mode
PASSED: throws for a semantic tool when the registry fixture is invalid
PASSED: exits 0 through the entrypoint for a benign Edit payload
PASSED: exits 2 through the entrypoint for malformed stdin
PASSED: throws the exact missing-registry message
PASSED: throws the exact invalid-operation message
PASSED: throws the exact invalid-transport-alias message
PASSED: route_id large
PASSED: route_id remediation
PASSED: route_id preparation
PASSED: route_id small
PASSED: route_id blank
PASSED: route_id unknown
PASSED: route_id wrong case
PASSED: no route keys
PASSED: route_id null with path_selected large
PASSED: route_id non-string with path_selected large
PASSED: route_id small wins over path_selected large
PASSED: path_selected large without route_id
PASSED: path_selected small without route_id
PASSED: terminal next_step complete
PASSED: terminal S12_complete
PASSED: non-terminal completed steps
PASSED: malformed JSON
PASSED: array JSON
PASSED: string JSON
PASSED: empty text
PASSED: whitespace text
PASSED: selects large from {"route_id":"large","path_selected":"small"}
PASSED: selects  from {"route_id":null,"path_selected":"large"}
PASSED: selects remediation from {"path_selected":"remediation"}
PASSED: selects  from {not-json
PASSED: allows the first three distinct production paths and denies the 4th with no checkpoint
PASSED: denies the 4th distinct production path when the checkpoint route is small
PASSED: names the routing target, counted paths, requested path, and observed route
PASSED: omits every prohibited remedy phrase and the state-file path from the deny reason
PASSED: allows a repeated production path without a state write
PASSED: enforces direct mode for a terminal large-route checkpoint
PASSED: large route allows six distinct production paths without a state write
PASSED: remediation route allows six distinct production paths without a state write
PASSED: preparation route allows six distinct production paths without a state write
PASSED: the decision with LargePathRoute allows without recording
PASSED: a path_selected-only large checkpoint allows the 4th production path
PASSED: allows five distinct test paths in direct mode without recording them
PASSED: allows a test path on the large path without a state write
PASSED: loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path
PASSED: a fresh state carries no test-file keys
PASSED: ConvertTo state ignores persisted prodCap, testCap, and testFiles
PASSED: the default reader yields direct mode when the checkpoint file is absent
PASSED: reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root
PASSED: treats a throwing checkpoint reader as direct mode without raising
PASSED: still denies malformed tool_input JSON when the checkpoint route is large
PASSED: does not read the checkpoint for a non-PowerShell path
PASSED: allows a Write payload for a production path under a large-route checkpoint without output or state write
PASSED: emits a deny envelope without a state property for the 4th production path in direct mode
PASSED: returns exit code 2 and writes stderr for an empty payload
PASSED: baseline mock interception probe
PASSED: allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: admits the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: admits the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the repo-relative spelling of a feature-folder .json artifact
PASSED: allows the forward-slash absolute spelling of a feature-folder .json artifact
PASSED: allows the backslash absolute spelling of a feature-folder .json artifact
PASSED: allows an absolute checkpoint path whose literal differs only in letter case
PASSED: denies an absolute path whose documentation prefix differs only in letter case
PASSED: denies a synthetic absolute path ending in a production .ps1 file
PASSED: denies a synthetic absolute path ending in a production .py file
PASSED: denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
PASSED: denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
PASSED: denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
PASSED: denies a repo-relative file-marker path for a production .ps1 file
PASSED: allows a repo-relative file-marker path for a checkpoint literal
PASSED: throws a hook-named error when the payload is an empty string
PASSED: throws a hook-named error when the payload is whitespace only
PASSED: throws a hook-named error when the payload is not valid JSON
PASSED: throws when the payload carries no tool_input property
PASSED: throws when tool_input is present but null
PASSED: throws when the payload is the JSON null literal
PASSED: throws when session_id is absent under -RequireSessionId
PASSED: throws when session_id is whitespace only under -RequireSessionId
PASSED: returns the parsed payload for a well-formed payload
PASSED: returns the parsed payload when -RequireSessionId is satisfied
PASSED: does not reject a payload whose hook_event_name is absent
PASSED: returns an empty array for a null payload
PASSED: returns an empty array when tool_input is null
PASSED: returns an empty array for an unadmitted tool name
PASSED: returns an empty array when file_path is whitespace only
PASSED: returns an empty array when tool_input carries neither file_path nor command
PASSED: returns an empty array when the command is whitespace only
PASSED: returns an empty array when the command contains no apply_patch file marker
PASSED: copies every supplied tool_input field onto the emitted record
PASSED: records the Write operation name for Write-shaped input
PASSED: emits the added lines for an Add operation
PASSED: excludes unified-diff +++ headers from the added-line text
PASSED: resolves a rename destination into file_path while keeping source_path
PASSED: emits empty content for a Delete operation
PASSED: emits one record per file for a multi-file patch
PASSED: returns false when the governed path is empty
PASSED: returns false when the candidate path is empty
PASSED: matches an absolute path that ends with the governed path
PASSED: does not match a path that merely shares a suffix mid-segment
PASSED: returns an empty string when the source file does not exist
PASSED: returns an empty string when the source file cannot be read
PASSED: returns an empty string when a hunk pre-image is absent from the source
PASSED: returns the source content unchanged for a hunk that is entirely pre-image
PASSED: substitutes the post-image when the pre-image is found in the source
PASSED: emits no record for an Update outside the governed path
PASSED: emits a governed Update record with empty content when reconstruction fails
PASSED: emits the added lines for an Update when reconstruction is not requested
PASSED: parses at least three matcher groups and every registered handler from config.toml
PASSED: allows every registered handler for every tool name its own matcher admits
PASSED: fails closed with exit 2 for empty stdin on every registered handler
PASSED: fails closed with exit 2 for invalid JSON on every registered handler
PASSED: reports enforce-completion-consistency in its own stderr rather than its neighbour
PASSED: leaves no Codex batch-budget state behind
PASSED: DEV-2 wave barrier allows a benign Bash payload when no local checkpoint text is supplied
PASSED: AC-20 one registration returns an array of count one
PASSED: AC-20 zero registrations return an empty array that is not null
PASSED: AC-21 registration count assertion rejects an empty array
PASSED: AC-21 registration count assertion rejects a null result
PASSED: allows a safe Edit payload on every group handler
PASSED: allows a safe Write payload on every group handler
PASSED: allows a safe apply_patch payload on every group handler
PASSED: allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'')
PASSED: allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'noop')
PASSED: fails closed with exit 2 when a batch-budget payload omits session_id
PASSED: allows an apply_patch update that touches only ungoverned files with a missing source
PASSED: emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden Edit payload
PASSED: denies a preimplementation-gate implementation path mapped from Edit
PASSED: denies a preimplementation-gate implementation path mapped from Write
PASSED: denies a preimplementation-gate implementation path mapped from apply_patch
PASSED: fails closed with exit 2 for a missing tool_input on every group handler
PASSED: fails closed with exit 2 for a null tool_input on every group handler
PASSED: returns null checkpoint content when the path is not a file
PASSED: returns the file text when the checkpoint path resolves to a file
PASSED: returns an empty string for a null checkpoint payload property lookup
PASSED: returns an empty string when the checkpoint property value is null
PASSED: treats a null payload as asserting no completion
PASSED: detects completion asserted by next_step
PASSED: detects completion asserted by completed_steps
PASSED: detects completion asserted by step8_status
PASSED: detects completion asserted by step9_status
PASSED: detects completion asserted by step10_status
PASSED: detects no completion assertion for an in-progress next_step
PASSED: detects no completion assertion for completed_steps without the terminal step
PASSED: detects no completion assertion for an empty completed_steps list
PASSED: detects no completion assertion for an in-progress step8_status
PASSED: allows when no mapped tool_input is supplied
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows mapped tool_input that carries no file_path
PASSED: allows a file path that is not the governed checkpoint
PASSED: denies a checkpoint edit whose patch cannot be resolved
PASSED: allows a checkpoint write that does not assert completion
PASSED: denies a completion-asserting checkpoint write through its own entrypoint
PASSED: allows an unrelated mapped write through its own entrypoint
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: reads issue-num and feature-folder from variables and reports ci_gate gaps
PASSED: allows the first three distinct production paths and denies the 4th with no checkpoint
PASSED: names the routing target, counted paths, requested path, and observed route
PASSED: omits every prohibited remedy phrase and the state-file path from the deny reason
PASSED: allows a repeated production path without a state write
PASSED: route_id small checkpoint enforces direct mode for the 4th production path
PASSED: terminal next_step complete checkpoint enforces direct mode for the 4th production path
PASSED: terminal S12_complete checkpoint enforces direct mode for the 4th production path
PASSED: null route_id with path_selected large checkpoint enforces direct mode for the 4th production path
PASSED: blank route_id with path_selected large checkpoint enforces direct mode for the 4th production path
PASSED: unknown route checkpoint enforces direct mode for the 4th production path
PASSED: malformed checkpoint enforces direct mode for the 4th production path
PASSED: non-object checkpoint enforces direct mode for the 4th production path
PASSED: empty checkpoint enforces direct mode for the 4th production path
PASSED: large route allows six distinct production paths without touching state
PASSED: remediation route allows six distinct production paths without touching state
PASSED: preparation route allows six distinct production paths without touching state
PASSED: the decision with LargePathRoute allows without recording
PASSED: a path_selected-only large checkpoint allows the 4th production path
PASSED: allows five distinct tests/ paths in direct mode without recording them
PASSED: allows a root-level test_ file after three production paths without recording it
PASSED: allows both test path forms on the large path without touching state
PASSED: loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path
PASSED: a persisted prodCap below the default does not lower the threshold
PASSED: a fresh state carries no test-file keys
PASSED: ConvertTo state ignores persisted prodCap, testCap, and testFiles
PASSED: the default reader yields direct mode when the checkpoint file is absent
PASSED: reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root
PASSED: treats a throwing checkpoint reader as direct mode without raising
PASSED: still denies malformed tool_input JSON when the checkpoint route is large
PASSED: does not read the checkpoint for a non-Python path
PASSED: does not read the checkpoint when tool_input carries no file_path
PASSED: allows a Write payload for a production path under a large-route checkpoint without output or state write
PASSED: emits a deny envelope without a state property for the 4th production path in direct mode
PASSED: returns exit code 2 and writes stderr for an empty payload
PASSED: recognises a tests tree module as a Python test path: True
PASSED: recognises a bare test_ module as a Python test path: True
PASSED: recognises a Windows-separated tests path as a Python test path: True
PASSED: recognises a production module as a Python test path: False
PASSED: recognises a PowerShell test as a Python test path: False
PASSED: returns no decision when the mapped tool_input is empty
PASSED: denies when the mapped tool_input is malformed JSON
PASSED: returns no decision when the mapped tool_input carries no file_path
PASSED: returns no decision for a path outside the Python test surface
PASSED: returns no decision when a Python test edit carries no content
PASSED: returns no decision when the proposed Python test content is pure
PASSED: denies a Write whose content introduces forbidden Python dependencies
PASSED: denies an Edit whose new_string introduces forbidden Python dependencies
PASSED: reports each violated rule once
PASSED: denies a mapped Write that violates Python test purity
PASSED: allows a mapped Write that is pure
PASSED: allows a well-formed payload that maps to no file edit
PASSED: fails closed with exit 2 on empty stdin
PASSED: recognises a tests tree script as a PowerShell test path: True
PASSED: recognises a Pester suffixed file as a PowerShell test path: True
PASSED: recognises a Windows-separated tests path as a PowerShell test path: True
PASSED: recognises a production script as a PowerShell test path: False
PASSED: recognises a Python test as a PowerShell test path: False
PASSED: returns no decision when the mapped tool_input is empty
PASSED: returns no decision when the mapped tool_input is malformed JSON
PASSED: returns no decision when the mapped tool_input carries no file_path
PASSED: returns no decision for a path outside the PowerShell test surface
PASSED: returns no decision when a PowerShell test edit carries no content
PASSED: returns no decision when the proposed PowerShell test content is pure
PASSED: denies a Write whose content introduces a timing hack
PASSED: denies an Edit whose new_string introduces a timing hack
PASSED: reports each violated rule once
PASSED: denies a mapped Write that violates PowerShell test purity
PASSED: allows a mapped Write that is pure
PASSED: allows a well-formed payload that maps to no file edit
PASSED: fails closed with exit 2 on empty stdin
PASSED: throws a blocked message when the raw payload is whitespace only
PASSED: throws a blocked message when the raw payload is malformed JSON
PASSED: resolves a relative path against the supplied base path
PASSED: classifies a shell tool as a mutation
PASSED: classifies a shell tool as a mutation
PASSED: classifies an unlisted read-only tool as a non-mutation
PASSED: short-circuits to false when the tool is not a mutation
PASSED: reports no error when the receipt, attestation, and hashes all match
PASSED: propagates every error the launch-receipt validator returns
PASSED: reports the validator as unavailable when it cannot be resolved
PASSED: reports a changed deployment profile hash
PASSED: reports a payload model that disagrees with the launch receipt
PASSED: reports a payload agent type that disagrees with the launch receipt
PASSED: reads the reasoning effort from model_reasoning_effort when that property is present
PASSED: falls back to reasoning_effort when model_reasoning_effort is absent
PASSED: accepts a matching reasoning effort supplied under either property name
PASSED: accepts a matching reasoning effort supplied under either property name
PASSED: allows a tool that is neither an MCP call nor a mutation
PASSED: denies a mutation when the launcher authorization receipt is missing
PASSED: denies an MCP tool outside the repository-scoped drm-copilot surface
PASSED: denies a nested Codex invocation from inside an epic child
PASSED: fixture precondition: the committed checkpoint fixtures still contain the expected tokens
PASSED: denies an Edit to complete on the non-empty fixture and names ci_gate
PASSED: allows an Edit to a non-completion value on the non-empty fixture
PASSED: denies the not_started to pending Edit as old_string-ambiguous without replace_all and allows it with replace_all true
PASSED: denies an Edit on the empty fixture as checkpoint-empty
PASSED: denies an Edit on a missing fixture path as checkpoint-missing
PASSED: denies an Edit on the invalid-JSON fixture whose patched content is not valid JSON as must remain valid JSON
PASSED: returns False from Get-EditReplaceAllFlag when replace_all is absent
PASSED: returns True from Get-EditReplaceAllFlag when replace_all is boolean true
PASSED: returns False from Get-EditReplaceAllFlag when replace_all is boolean false
PASSED: returns True from Get-EditReplaceAllFlag when replace_all is the string true
PASSED: returns True from Get-EditReplaceAllFlag when replace_all is the padded upper-case string TRUE
PASSED: returns False from Get-EditReplaceAllFlag when replace_all is the string false
PASSED: returns False from Get-EditReplaceAllFlag when replace_all is the string yes
PASSED: returns False from Get-EditReplaceAllFlag when replace_all is the integer 1
PASSED: resolves 0 occurrences without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 0 occurrences with replace_all false through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 0 occurrences with replace_all true through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 0 occurrences with replace_all string true through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 0 occurrences with replace_all string false through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 1 occurrence without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 1 occurrence with replace_all false through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 1 occurrence with replace_all true through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 1 occurrence with replace_all string true through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 1 occurrence with replace_all string false through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 2 occurrences without replace_all through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 2 occurrences with replace_all false through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 2 occurrences with replace_all true through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 2 occurrences with replace_all string true through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: resolves 2 occurrences with replace_all string false through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
PASSED: counts overlapping candidates once when replace_all is false
PASSED: keeps dollar sequences in new_string literal
PASSED: keeps regular-expression metacharacters literal
PASSED: matches CRLF text with an LF old_string
PASSED: emits LF line endings after normalizing CRLF text
PASSED: returns Failure no-old_string when old_string is empty
PASSED: denies an ambiguous patch without replace_all as old_string-ambiguous
PASSED: allows the same ambiguous patch when replace_all is boolean true
PASSED: allows the same ambiguous patch when replace_all is the string true
PASSED: denies the same ambiguous patch when replace_all is the string false
PASSED: evaluates a single-occurrence patch on the spliced content
PASSED: denies a patch whose old_string is absent as old_string-not-found
PASSED: returns a different decision for the same patch with and without replace_all
PASSED: evaluates a replace_all patch on the all-replaced content
PASSED: denies a completion-asserting Edit when the checkpoint exists only at the absolute targeted file_path
PASSED: derives a deny from the targeted file_path content when the relative literal holds different content
PASSED: derives an allow from the targeted file_path content when the relative literal holds a completion-asserting checkpoint
PASSED: passes an absolute POSIX file_path to the reader unchanged
PASSED: passes a relative file_path to the reader unchanged
PASSED: passes a backslash-spelled file_path to the reader unchanged
PASSED: declares CheckpointPath as a mandatory parameter of Resolve-EditedCheckpointContent
PASSED: returns Failure no-old_string when the tool input carries no old_string
PASSED: returns Failure checkpoint-empty when the reader returns an empty string
PASSED: returns Failure old_string-not-found when old_string is absent from the checkpoint
PASSED: applies the old_string to new_string replacement in memory and returns Content
PASSED: passes the supplied CheckpointPath to the injected reader
PASSED: returns Failure checkpoint-missing when the reader returns null
PASSED: returns Failure checkpoint-unreadable when the reader throws
PASSED: returns Failure old_string-ambiguous for two occurrences without replace_all
PASSED: replaces every occurrence when replace_all is true
PASSED: does not intercept a completion-asserting Write to the epic checkpoint
PASSED: does not intercept a completion-asserting Edit to the epic checkpoint
PASSED: does not intercept an apply_patch Add of the epic checkpoint
PASSED: emits no mapped record for an apply_patch Update of the epic checkpoint
PASSED: still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/
PASSED: still denies a completion-asserting per-feature checkpoint that lacks ci_gate
PASSED: denies an Edit as checkpoint-missing when the reader returns null
PASSED: denies an Edit as checkpoint-empty when the reader returns an empty string
PASSED: does not throw when the reader throws for the targeted checkpoint
PASSED: denies an Edit as checkpoint-unreadable when the reader throws
PASSED: denies an Edit as no-old_string when old_string is absent
PASSED: denies an Edit as no-old_string when old_string is empty
PASSED: denies a Write with an empty content property as write-content-empty
PASSED: denies an Edit as old_string-not-found when old_string is absent from the checkpoint
PASSED: allows a non-checkpoint file_path without invoking the reader
PASSED: allows a tool_input with no file_path without invoking the reader
PASSED: allows an epic checkpoint file_path without invoking the reader
PASSED: denies an Edit whose patched content is not valid JSON as must remain valid JSON
PASSED: allows a Write whose content does not assert completion
PASSED: baseline mock interception probe
PASSED: decides allow for a valid 691 record in the child checkpoint
PASSED: decides allow for a valid 691 record in the epic checkpoint
PASSED: decides deny for a record naming 777 only
PASSED: decides deny for no authorization key on either checkpoint
PASSED: decides deny for a blanket boolean block value
PASSED: decides deny for a session_id that differs from the payload
PASSED: decides deny for a payload carrying no session_id
PASSED: decides allow for the unchanged branch-1 child guard
PASSED: decides allow for the unchanged branch-2 epic guard
PASSED: decides allow for a squash merge of 691 with a valid 691 record
PASSED: denies an explicit PR with no record using both the gate token and the absent code
PASSED: keeps the existing deny text for a bare merge even with a valid record present
PASSED: still raises through the throw channel for a whitespace-only payload
PASSED: still raises through the throw channel for an unparseable payload
PASSED: denies a non-PR-specific block when the array is empty
PASSED: denies a non-PR-specific block when an entry is not an object
PASSED: denies a non-PR-specific block when an entry has no pr_number
PASSED: denies a non-PR-specific block when pr_number spells digits as a string
PASSED: denies a non-PR-specific block when pr_number is an array
PASSED: denies a malformed record naming pr_url when pr_url ends with a different pull number
PASSED: denies a malformed record naming issue_num when issue_num is a string
PASSED: denies a malformed record naming branch_name when branch_name is whitespace
PASSED: denies a malformed record naming authorized_by when authorized_by is empty
PASSED: denies a malformed record naming authorized_at when authorized_at is unparseable
PASSED: denies a malformed record naming basis when basis is shorter than twenty characters
PASSED: denies a malformed record naming run_slug when run_slug is present but blank
PASSED: allows a record whose authorized_at is a parseable non-ISO date-time
PASSED: spells the four reason codes identically in the Claude helpers file and the Codex hook
PASSED: baseline mock interception probe
PASSED: throws a named EPIC_MERGE_GATE_BLOCKED error for an empty required source
PASSED: returns null rather than throwing for an empty optional source
PASSED: returns null rather than throwing for a malformed optional source
PASSED: throws a named EPIC_MERGE_GATE_BLOCKED error for a malformed required source
PASSED: returns the parsed object for a well-formed required source
PASSED: reports not ready when the epic merge PR carries no ci_gate record
PASSED: reports not ready when the ci_gate conclusion is not success
PASSED: reports ready when the ci_gate succeeded and the command names no PR number
PASSED: reports not ready when epic_mode is the string true rather than the boolean
PASSED: reports not ready when step9_status is pending
PASSED: returns null for a Write payload without consulting either checkpoint
PASSED: writes nothing and exits 0 for a non-Bash payload on stdin
PASSED: writes the reason to stderr and exits 2 for malformed stdin
PASSED: baseline mock interception probe
PASSED: resolves 410 for the positional spelling gh pr merge 410 --merge
PASSED: resolves 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag
PASSED: returns null for a bare gh pr merge --merge that names no PR number
PASSED: allows a quoted mention of the gated merge phrase
PASSED: keeps a real gh pr merge --merge invocation in scope and denies it without a checkpoint
PASSED: R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument
PASSED: R2a-X2 still allows a commit message quoting the merge phrase and the merge flag
PASSED: baseline mock interception probe
PASSED: returns null rather than throwing for an empty optional source
PASSED: throws a named EPIC_WORKTREE_REMOVAL_BLOCKED error for an empty required source
PASSED: returns null rather than throwing for a malformed optional source
PASSED: throws a named EPIC_WORKTREE_REMOVAL_BLOCKED error for a malformed required source
PASSED: reports Indeterminate when the flag is present and no operand follows
PASSED: reports Indeterminate for a bare removal that names neither operand nor flag
PASSED: reports NoMatch for a subcommand that is not remove
PASSED: resolves a relative path against the supplied working directory
PASSED: keeps a rooted path and trims a trailing separator
PASSED: returns null for a null checkpoint
PASSED: returns null for a checkpoint that carries no features array
PASSED: skips a feature record whose worktree_path is blank and reports no match
PASSED: returns the matching feature record when the normalized paths agree
PASSED: returns null for a non-Bash payload
PASSED: denies an in-scope removal that names no operand at all
PASSED: falls back to the current location when the payload carries no cwd
PASSED: allows a removal whose feature record reports worktree_removed
PASSED: writes nothing and exits 0 for a non-Bash payload on stdin
PASSED: writes the deny envelope and exits 0 for a removal no epic checkpoint authorizes
PASSED: writes the reason to stderr and exits 2 for malformed stdin
PASSED: baseline mock interception probe
PASSED: CW-01 allows R-824-ADD1
PASSED: CW-02 allows R-742-1
PASSED: CW-37 allows the fixture AC-19 list command
PASSED: CW-38 denies the fixture AC-19 wrapped removal
PASSED: CW-39 denies the CW-01 command when substring presence is reinstated
PASSED: CW-40 returns no decision for an in-scope command when the target resolver reports NoMatch
PASSED: CW-03 denies F1 for P
PASSED: CW-04 denies F2 for P
PASSED: CW-05 denies F3 for P
PASSED: CW-06 denies F4 for P
PASSED: CW-07 denies F5 for P
PASSED: CW-13 denies Q then P naming P
PASSED: CW-18 denies W5 naming P
PASSED: CW-19 denies W6 naming P
PASSED: CW-14 denies W1 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-15 denies W2 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-16 denies W3 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-17 denies W4 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-08 allows F1
PASSED: CW-09 allows F2
PASSED: CW-10 allows F3
PASSED: CW-11 allows F4
PASSED: CW-12 allows F5
PASSED: CW-21 denies the unbalanced quote spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-22 denies the PowerShell parse error spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-23 denies the decode failure spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-24 denies the depth limit spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-25 denies the dynamic position spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-26 denies the not proven inert spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-27 denies the no operand spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-28 denies the two operands spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-29 denies the X1 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-30 denies the X2 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-31 denies the X3 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-32 denies the X4 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-33 denies the X7 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-34 denies the X8 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-35 denies the X10 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-36 denies the B5 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: CW-20 allows the removal of Q and P
PASSED: baseline mock interception probe
PASSED: denies git -C /repo/main worktree remove against a checkpoint with no authorizing record
PASSED: resolves the operand when --force precedes the path
PASSED: resolves the same operand when --force follows the path
PASSED: allows a command whose quoted text merely mentions the removal phrase
PASSED: keeps git worktree list out of scope
PASSED: baseline mock interception probe
PASSED: allows staging an epic document under the epics tree
PASSED: allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: allows a quoted operand under the active feature tree
PASSED: denies a backslash-spelled operand (D4 row 18 reversed by issues #732 and #735)
PASSED: allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: allows a chained two-segment line whose every segment is independently exempt
PASSED: allows staging a lifecycle record under the potential feature tree
PASSED: denies an exempt operand paired with a .ps1 production operand
PASSED: denies an exempt operand paired with a .py production operand
PASSED: denies an exempt operand paired with a .ts production operand
PASSED: denies an exempt operand paired with a .cs production operand
PASSED: denies D4 row 1 - bare staging with zero operands
PASSED: denies D4 row 2a - the tree-wide short all flag
PASSED: denies D4 row 2b - the tree-wide long all flag
PASSED: denies D4 row 2c - the update short flag with an exempt operand
PASSED: denies D4 row 2d - the update long flag
PASSED: denies D4 row 2e - the no-all flag with an exempt operand
PASSED: denies D4 row 3a - the dot whole-tree operand
PASSED: denies D4 row 3b - the colon-slash whole-tree operand
PASSED: denies D4 row 4 - a pathless message-only integration invocation
PASSED: denies D4 row 5a - the content-widening short all option
PASSED: denies D4 row 5b - the content-widening long all option
PASSED: denies D4 row 5c - the include short option
PASSED: denies D4 row 5d - the include long option
PASSED: denies D4 row 5e - the interactive long option
PASSED: denies D4 row 5f - the patch short option
PASSED: denies D4 row 5g - the history-rewriting amend option
PASSED: denies D4 row 6a - pathspecs supplied from a file
PASSED: denies D4 row 6b - the nul-delimited pathspec file option
PASSED: denies D4 row 7 - a double-dash separator with nothing after it
PASSED: denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: denies D4 row 9a - the exclude pathspec magic operand
PASSED: denies D4 row 9b - the bang shorthand exclude operand
PASSED: denies D4 row 9c - the top pathspec magic operand
PASSED: denies D4 row 9d - the glob pathspec magic operand
PASSED: denies D4 row 9e - the icase pathspec magic operand
PASSED: denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: denies D4 row 12b - a backtick substitution inside an operand
PASSED: denies D4 row 12c - an output redirection in the segment
PASSED: denies D4 row 12d - an input redirection in the segment
PASSED: denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: denies D4 row 14c - a git-dir option before the subcommand
PASSED: denies D4 row 14d - a work-tree option before the subcommand
PASSED: denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: denies a message-body payload that merely contains the staging literal
PASSED: denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: denies issue #671 LACS L1a - attached selector spelling
PASSED: denies issue #671 LACS L1b - config-injection selector
PASSED: denies issue #671 LACS L2 - repeated selector
PASSED: denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: denies issue #671 LACS L4a - bare relative selector
PASSED: denies issue #671 LACS L4b - UNC selector
PASSED: denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: denies issue #671 LACS L6 - wildcard in the selector
PASSED: denies issue #671 LACS L7 - stray colon in the selector
PASSED: denies issue #732 LACS allow 3 reversed - backslash-spelled absolute selector
PASSED: denies issue #671 LACS L8 - empty selector value
PASSED: denies issue #671 selector followed by an unmodelled subcommand
PASSED: denies issue #671 selector with a non-exempt pathspec operand
PASSED: denies issue #671 selector with the tree-wide all flag
PASSED: denies issue #671 selector with an absolute pathspec operand
PASSED: denies issue #671 selector with an output redirection
PASSED: denies issue #671 cd chain into the target worktree
PASSED: allows issue #671 empty commit message beside an exempt operand
PASSED: denies issue #671 empty token beside a non-exempt operand
PASSED: denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: denies issue #671 trailing empty token after a non-exempt operand
PASSED: denies issue #671 empty commit message beside a non-exempt operand
PASSED: accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: rejects issue #671 predicate L1a - single token segment
PASSED: rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: rejects issue #671 predicate L2 - repeated selector
PASSED: rejects issue #671 predicate L3a - no token after the selector value
PASSED: rejects issue #671 predicate L3b - option token after the selector value
PASSED: rejects issue #671 predicate L4a - relative selector
PASSED: rejects issue #671 predicate L4b - UNC selector
PASSED: rejects issue #671 predicate L5a - parent-directory segment
PASSED: rejects issue #671 predicate L5b - current-directory segment
PASSED: rejects issue #671 predicate L6 - wildcard
PASSED: rejects issue #671 predicate L7 - stray colon
PASSED: rejects issue #671 predicate L8 - empty selector value
PASSED: returns false when segment classification raises an error
PASSED: issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: issue #663 exempts a single-quoted message carrying angle brackets
PASSED: issue #663 denies the single-quoted apostrophe idiom
PASSED: issue #663 denies a command substitution inside a double-quoted message
PASSED: issue #663 denies a variable expansion inside a double-quoted message
PASSED: issue #663 denies a backtick substitution inside a double-quoted message
PASSED: issue #663 denies a pathless commit whose message carries angle brackets
PASSED: issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: issue #663 remediation denies a backslash inside a double-quoted message
PASSED: baseline mock interception probe
PASSED: resolves reason epic-scope for the session-root HEAD matching integration_branch
PASSED: resolves reason epic-scope for a -C selector worktree whose HEAD matches integration_branch
PASSED: resolves reason session-root-unresolved for a session root outside any worktree
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an absent epic checkpoint
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an unparseable epic checkpoint
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an array-shaped epic checkpoint
PASSED: resolves reason route_id for a route_id other than epic
PASSED: resolves reason integration_branch for an empty integration_branch
PASSED: resolves reason selector-unresolved for a -C selector outside any worktree
PASSED: resolves reason branch-mismatch for an effective HEAD that differs from integration_branch
PASSED: resolves reason branch-mismatch for a detached HEAD
PASSED: reports MergeInProgress True when the MERGE_HEAD probe returns True
PASSED: reports MergeInProgress False when the MERGE_HEAD probe returns False
PASSED: composes an absolute checkpoint path from the resolved session root
PASSED: consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied
PASSED: declares the fixed head-match signature without Text or MatchWorktreeHead parameters
PASSED: returns null checkpoint text when the checkpoint file is absent
PASSED: returns the checkpoint text when the checkpoint file exists
PASSED: reads the HEAD branch of a linked worktree through its gitdir file
PASSED: reads the HEAD branch of a main checkout through its git directory
PASSED: resolves a relative gitdir target against the worktree root
PASSED: returns no HEAD branch for a detached HEAD
PASSED: returns no git directory for a missing git entry
PASSED: returns no git directory for a gitdir file without a gitdir line
PASSED: returns no git directory for a relative worktree root
PASSED: probes MERGE_HEAD in the worktree git directory and reports True
PASSED: probes MERGE_HEAD in the worktree git directory and reports False
PASSED: reports no merge in progress when the worktree has no git directory
PASSED: finds the worktree root by ascending to the first level that carries a git directory
PASSED: finds a linked worktree root whose git entry is a gitdir file
PASSED: returns no worktree root for a relative start path
PASSED: returns no worktree root for an ascent that reaches the filesystem root without a git entry
PASSED: normalises backslashes, repeated separators, a leading dot segment, and a trailing slash
PASSED: returns a null normalised path for blank input
PASSED: rejects a relative worktree root when composing a path
PASSED: returns null from the checkpoint parser for null text
PASSED: returns null from the checkpoint parser for whitespace text
PASSED: returns null from the checkpoint parser for a JSON scalar
PASSED: command-leg readiness passes for a ready epic checkpoint while a merge is in progress
PASSED: command-leg readiness names checkpoint-absent for a null checkpoint
PASSED: command-leg readiness names route_id for a route_id other than epic
PASSED: command-leg readiness names epic_feature_folder for a missing epic_feature_folder
PASSED: command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
PASSED: command-leg readiness names integration_branch for a missing integration_branch
PASSED: command-leg readiness names features for an empty features array
PASSED: command-leg readiness names merge-in-progress for no merge in progress
PASSED: command-leg readiness reports the earliest failed conjunct when several fail
PASSED: command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree
PASSED: baseline mock interception probe
PASSED: denies a second segment that targets a different not-ready worktree
PASSED: denies a relative -C selector in epic scope
PASSED: denies an unresolvable -C selector in epic scope
PASSED: denies a directory-changing segment in epic scope
PASSED: denies a wrapper-led git segment in epic scope
PASSED: denies a target outside the epic scope of the session root
PASSED: denies an apply_patch absolute file marker into a not-ready epic worktree
PASSED: evaluates every value of a repeated -C selector
PASSED: allows when every target is epic scope and ready
PASSED: keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: keeps the single-feature decision for a directory change outside epic scope
PASSED: resolves a segment without -C to the session root
PASSED: denies an ambiguous epic target
PASSED: baseline mock interception probe
PASSED: epic scope allows the command leg of a production path while a merge is in progress
PASSED: epic scope allows the apply_patch leg of a production path while a merge is in progress
PASSED: epic scope allows the path leg of a production path while a merge is in progress
PASSED: epic scope denies the command leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies the apply_patch leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies the path leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies the command leg when epic_feature_folder is missing and names it and the epic checkpoint
PASSED: epic scope denies the command leg when epic_manifest_path is missing and names it and the epic checkpoint
PASSED: epic scope denies the command leg when features is missing and names it and the epic checkpoint
PASSED: the epic-scope decision names route_id and the epic checkpoint when the resolved scope carries an invalid route_id
PASSED: the epic-scope decision names epic_feature_folder and the epic checkpoint when the resolved scope carries an invalid epic_feature_folder
PASSED: the epic-scope decision names epic_manifest_path and the epic checkpoint when the resolved scope carries an invalid epic_manifest_path
PASSED: the epic-scope decision names integration_branch and the epic checkpoint when the resolved scope carries an invalid integration_branch
PASSED: the epic-scope decision names features and the epic checkpoint when the resolved scope carries an invalid features
PASSED: epic scope decides a -C selector command by the selector worktree HEAD and allows it
PASSED: a -C selector command whose selector HEAD differs is denied as target-mixed when the session-root HEAD matches (issue #738)
PASSED: with no epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: with no epic checkpoint the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with no epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the command leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the path leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the command leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the path leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the command leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the path leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the command leg is allowed by a ready single-feature checkpoint
PASSED: without an epic checkpoint the apply_patch leg is allowed by a ready single-feature checkpoint
PASSED: without an epic checkpoint the path leg is allowed by a ready single-feature checkpoint
PASSED: a bookkeeping path operand stays exempt without reading the epic checkpoint
PASSED: a bookkeeping command operand stays exempt without reading the epic checkpoint
PASSED: the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: the epic-scope selector returns the selector path for a leading git -C selector
PASSED: the epic-scope selector returns no selector for a command without a selector
PASSED: the epic-scope selector returns no selector for an unbalanced command line
PASSED: resolves every Codex epic-scope seam name as a function after dot-sourcing the gate
PASSED: keeps enforce-orchestration-preimplementation-gate.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 byte-identical to its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 byte-identical to its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate.ps1 or its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-scope.ps1 or its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-resolution.ps1 or its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: baseline mock interception probe
PASSED: M1: allows the target folder cited alone at decision level
PASSED: M2a: allows the target folder cited together with a research artifact
PASSED: M2b: allows the target folder cited together with an evidence artifact
PASSED: M3a: allows a research artifact cited alone
PASSED: M3b: allows an evidence artifact cited alone
PASSED: M4e: prunes a cited epic dependency and reports no readiness failure
PASSED: M4p: reports target-ambiguous for a parallel target cited with another item and no issue number
PASSED: M4q: resolves a parallel target cited with another item through the declared issue number
PASSED: M5: denies with target-ambiguous naming both candidates
PASSED: M5r: denies with target-ambiguous for the reversed order with the longer slug first
PASSED: M6a: falls back to the keyed issue number when the bare token yields no candidate
PASSED: M6b: reports target-record when the token yields no candidate and no issue number is cited
PASSED: M7: resolves feature 621 and does not fail the merge_status predicate
PASSED: M7d: allows the 621 launch at decision level
PASSED: M8: resolves the record by the keyed issue number when the folder record was renamed
PASSED: M9: returns no target folder and a feature-folder-resolution-import readiness failure
PASSED: M10p: denies a parallel delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M10e: denies an epic delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M11p: selects the terminal parallel target through the keyed issue number despite a bare #302 sibling reference
PASSED: M11e: selects the terminal epic target through the keyed issue number despite a bare #302 sibling reference
PASSED: M12a: returns no keyed issue number when only a bare hash form is present
PASSED: M12b: returns the keyed issue number and ignores a bare hash form
PASSED: M12c: keeps the bare hash form as the default issue-number source
PASSED: M8h: allows a zero-candidate delegation through the bare hash D3 fallback
PASSED: M8m: denies a zero-candidate delegation with no issue number as target-record
PASSED: baseline mock interception probe
PASSED: resolves the preparation mode for its marker prompt
PASSED: resolves the epic mode for its marker prompt
PASSED: resolves the parallel mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: resolves the preparation mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: maps the preparation mode to its canonical checkpoint path
PASSED: maps the epic mode to its canonical checkpoint path
PASSED: maps the parallel mode to its canonical checkpoint path
PASSED: maps the single-feature mode to its canonical checkpoint path
PASSED: returns an empty checkpoint path for a mode name that is not in the table
PASSED: accepts the declared checkpoint path for epic mode
PASSED: accepts the declared checkpoint path for epic mode
PASSED: rejects the declared checkpoint path for epic mode
PASSED: accepts the declared checkpoint path for parallel mode
PASSED: rejects the declared checkpoint path for parallel mode
PASSED: returns nothing for a prompt carrying no feature-folder token
PASSED: returns the parent basename for a token ending in a Markdown file
PASSED: returns the basename for a bare directory token
PASSED: returns the basename for a token followed by sentence punctuation
PASSED: returns nothing for a prompt carrying no issue number
PASSED: returns the numeric string for a keyed issue number
PASSED: returns the numeric string for a bare-hash issue number
PASSED: builds an epic deny reason naming the epic checkpoint and the failed predicate
PASSED: builds a parallel deny reason naming the parallel checkpoint and the failed predicate
PASSED: names route_id as the failed conjunct
PASSED: names epic_feature_folder as the failed conjunct
PASSED: names epic_manifest_path as the failed conjunct
PASSED: names integration_branch as the failed conjunct
PASSED: names features as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: reports ready for the epic readiness wrapper
PASSED: denies the terminal-merged worktree_removed status for the epic readiness wrapper
PASSED: allows the failure status blocked_conflict_loop_limit for the epic readiness wrapper
PASSED: returns false from the wrapper for a null checkpoint
PASSED: names route_id as the failed conjunct
PASSED: names parallel_slug as the failed conjunct
PASSED: names parallel_manifest_path as the failed conjunct
PASSED: names items as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: reports ready for the parallel readiness wrapper
PASSED: denies the terminal-merged worktree_removed status for the parallel readiness wrapper
PASSED: allows the blocked status blocked_drift, adding no enum member for the parallel readiness wrapper
PASSED: returns false from the wrapper for a null checkpoint
PASSED: classifies atomic-executor as implementation: True
PASSED: classifies powershell-typed-engineer as implementation: True
PASSED: classifies task-researcher as implementation: False
PASSED: classifies orchestrator as implementation: False
PASSED: classifies orchestrator as implementation: True
PASSED: returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface
PASSED: returns true for an orchestrator carrying both preparation markers on the Codex surface
PASSED: registers no PreToolUse matcher admitting an Agent or Task tool name
PASSED: baseline mock interception probe
PASSED: allows an epic-mode delegation against an injected ready epic checkpoint
PASSED: denies an epic-mode delegation and names integration_branch as the failed predicate
PASSED: denies an epic-mode delegation whose injected checkpoint text is malformed JSON
PASSED: denies an epic-mode delegation whose injected checkpoint text is empty
PASSED: denies an epic-mode delegation that declares a non-canonical checkpoint path
PASSED: allows a parallel-mode delegation against an injected ready parallel checkpoint
PASSED: denies a parallel-mode delegation and names parallel_slug as the failed predicate
PASSED: denies a parallel-mode delegation whose injected checkpoint declares the epic route
PASSED: denies an epic-mode delegation against the canonical epic checkpoint read seam
PASSED: denies a parallel-mode delegation against the canonical parallel checkpoint read seam
PASSED: allows a research delegation that carries the epic marker
PASSED: baseline mock interception probe
PASSED: denies the issue 732 brace-expansion shape without an authorizing checkpoint
PASSED: denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
PASSED: baseline mock interception probe
PASSED: allows a quoted mention of the staging invocation inside an echo argument
PASSED: allows a heredoc body that quotes the staging invocation in prose
PASSED: allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: allows prose containing the English word black
PASSED: allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: denies a relocating git add carrying a directory global option
PASSED: denies a relocating git commit carrying a git-dir global option
PASSED: denies a relocating git add carrying a work-tree global option
PASSED: denies an unmodeled dash-leading token between git and its subcommand
PASSED: denies the subshell spelling of a staging command
PASSED: denies the command-substitution spelling of a staging command
PASSED: does not classify git log --grep add as a staging command
PASSED: wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: still classifies an apply_patch add of a production script
PASSED: still declines to classify an apply_patch add of feature documentation
PASSED: still classifies an apply_patch rename onto a production script
PASSED: still declines to classify an apply_patch update of feature documentation
PASSED: reports true for a genuine promotion-script invocation
PASSED: reports false for an ordinary read command
PASSED: falls back to the legacy promotion-script reason when no reason is supplied
PASSED: carries the supplied reason verbatim when one is supplied
PASSED: carries hookEventName PreToolUse and permissionDecision allow with no reason key
PASSED: allows when the mapped tool_input is absent
PASSED: allows when the mapped tool_input carries no command text
PASSED: throws a named error for malformed mapped tool_input JSON
PASSED: throws for payload text that is only whitespace
PASSED: throws for malformed JSON
PASSED: throws when tool_input is absent from an otherwise well-formed envelope
PASSED: throws when the envelope is not a PreToolUse event
PASSED: throws when the tool name is not Bash
PASSED: returns the parsed payload for a well-formed PreToolUse Bash envelope
PASSED: writes the deny envelope and exits 0 for a gh issue create on stdin
PASSED: writes nothing and exits 0 for an allowed command on stdin
PASSED: writes the reason to stderr and exits 2 for malformed stdin
PASSED: fails closed with exit 2 and the empty-input reason for whitespace-only stdin
PASSED: allows a heredoc whose JSON body names promotion tools as receipt values
PASSED: denies a genuine promotion-script invocation
PASSED: denies the adjacent gh issue create spelling
PASSED: denies the adjacent gh issue new spelling
PASSED: denies a single-segment gh api issues write with an explicit POST method
PASSED: denies a relocating gh issue create carrying a repo global option
PASSED: denies a relocating gh issue new carrying the short repo global option
PASSED: allows a relocating gh issue list
PASSED: requires the launch-authority result in the routed SubagentStart attestation
PASSED: does not require external launch authority for standalone routing
PASSED: accepts a session-bound launch receipt for epic_preparation_child
PASSED: accepts a session-bound launch receipt for epic_execution_child
PASSED: rejects epic-child routing without inherited launcher environment
PASSED: rejects a launch receipt bound to another Codex session
PASSED: rejects drift in an inherited launch field
PASSED: rejects a different inherited root delegation id
PASSED: rejects case drift in an inherited root model identity
PASSED: rejects an expired active receipt
PASSED: rejects a checkpoint that does not match the epic child context
PASSED: rejects a receipt outside the trusted launch-artifact root
PASSED: keys the same generated profile independently for each exact worktree
PASSED: requires lowercase artifact identifiers to prevent case-only filesystem collisions
PASSED: rejects a partial execution wave but excludes terminal features
PASSED: requires every planner feature once regardless of execution wave
PASSED: requires conjunctive delegation and model receipt identity
PASSED: rejects non-active or placeholder feature-folder identities
PASSED: rejects duplicate checkpoint feature identities before exactly-once coverage
PASSED: rejects a string-shaped issue number even when every binding repeats it
PASSED: requires an active unexpired receipt bound to the exact session
PASSED: uses inline project trust, ignores user config, and denies Codex install paths
PASSED: builds resume with the exact sealed session and runtime controls
PASSED: uses CreateNew receipts, an exclusive wave lock, and the checked-in resume wrapper
PASSED: preflights the elevated Windows sandbox from an isolated CODEX_HOME
PASSED: kills a sandbox probe that exceeds the bounded timeout
PASSED: removes an owned isolated home when authentication copy fails
PASSED: treats completed receipt evidence as durable while active authorization expires
PASSED: repeats the exact terminal receipt timestamp under the matching status key
PASSED: denies direct nested Codex execution and requires the payload session id
PASSED: requires same-repository ancestry, a clean worktree, and trusted instruction surfaces
PASSED: accepts a feature, delegation, branch, worktree, model receipt, and profile that all match
PASSED: rejects a missing exact delegation receipt
PASSED: rejects model, reasoning, permission, and worktree branch drift
PASSED: requires bounded parallelism to match the checkpoint and remain at most eight
PASSED: launches all planner preparations in one batch after final identity promotion
PASSED: rejects execution prompts missing required epic identity, branch, or PR-base markers
PASSED: rejects a prepared execution prompt without its plan path and atomic-execution resume text
PASSED: rejects a planner prompt without the literal preparation marker
PASSED: extracts the exact executable agent profile values
PASSED: builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree
PASSED: requires clean child-worktree customizations before bypassing hook trust
PASSED: extracts the exact Codex session id from JSONL for resume continuity
PASSED: allows a launch-authorized mutation in the exact worktree and branch
PASSED: denies a mismatched working directory, branch, spec hash, or environment attestation
PASSED: denies a mismatched working directory, branch, spec hash, or environment attestation
PASSED: denies a mismatched working directory, branch, spec hash, or environment attestation
PASSED: denies a mismatched working directory, branch, spec hash, or environment attestation
PASSED: requires explicit matching workspace_root on every drm-copilot MCP call
PASSED: denies mutation of launch authorization and committed customizations
PASSED: denies mutation of launch authorization and committed customizations
PASSED: denies mutation of launch authorization and committed customizations
PASSED: does not affect a session that was not started by the launcher
PASSED: fails closed on malformed Codex stdin JSON
PASSED: allows feature planning document edits
PASSED: denies production edits
PASSED: denies PR creation and CI execution commands
PASSED: denies PR creation and CI execution commands
PASSED: denies PR creation and CI execution commands
PASSED: denies PR creation and CI execution commands
PASSED: denies PR creation and CI execution commands
PASSED: denies PR creation and CI execution commands
PASSED: allows explicit planning-artifact staging and an ordinary commit
PASSED: allows explicit planning-artifact staging and an ordinary commit
PASSED: allows explicit planning-artifact staging and an ordinary commit
PASSED: denies deletion or route mutation of the canonical preparation checkpoint
PASSED: denies deletion or route mutation of the canonical preparation checkpoint
PASSED: denies deletion or route mutation of the canonical preparation checkpoint
PASSED: denies deletion or route mutation of the canonical preparation checkpoint
PASSED: denies deletion or route mutation of the canonical preparation checkpoint
PASSED: denies path traversal, move destinations, and security receipt writes
PASSED: denies path traversal, move destinations, and security receipt writes
PASSED: denies path traversal, move destinations, and security receipt writes
PASSED: fails closed for an attested preparation child before its checkpoint exists
PASSED: fails closed when an attested preparation child changes its checkpoint route
PASSED: requires explicit matching MCP workspace_root for an attested preparation child
PASSED: denies a preparation commit when staged paths include production code
PASSED: allows only preparation lifecycle MCP operations
PASSED: allows both registered MCP server spellings identically for validate_orchestration_artifacts
PASSED: allows both registered MCP server spellings identically for resolve_orchestration_topology
PASSED: allows both registered MCP server spellings identically for resolve_provider_routing
PASSED: allows both registered MCP server spellings identically for transition_prepared_orchestration
PASSED: denies malformed MCP id exactly without changing checkpoint bytes
PASSED: denies unrelated MCP server exactly without changing checkpoint bytes
PASSED: denies unregistered MCP operation exactly without changing checkpoint bytes
PASSED: denies approximate MCP operation exactly without changing checkpoint bytes
PASSED: denies shell edit exactly without changing checkpoint bytes
PASSED: denies production patch exactly without changing checkpoint bytes
PASSED: denies non-repository MCP tools during preparation
PASSED: denies commit pathspecs and broad push modes
PASSED: denies commit pathspecs and broad push modes
PASSED: denies commit pathspecs and broad push modes
PASSED: denies commit pathspecs and broad push modes
PASSED: denies commit pathspecs and broad push modes
PASSED: denies commit pathspecs and broad push modes
PASSED: allows a child after every dependency is merged
PASSED: denies a child before an upstream merge
PASSED: does not apply the execution barrier to preparation children
PASSED: allows a verified epic child merge
PASSED: allows the matching final epic PR after a successful CI gate
PASSED: denies a mismatched final PR number
PASSED: allows removal after merge
PASSED: denies removal while the PR is open
PASSED: recognizes the three explicit root epic entry skills
PASSED: recognizes the three explicit root epic entry skills
PASSED: recognizes the three explicit root epic entry skills
PASSED: does not mint a receipt for a non-epic prompt
PASSED: does not authorize negated or explanatory epic persona references
PASSED: does not authorize negated or explanatory epic persona references
PASSED: does not authorize negated or explanatory epic persona references
PASSED: derives the epic slug from a committed kickoff path
PASSED: authorizes an epic planner start once with the exact forced model
PASSED: rejects stale and previously consumed root receipts
PASSED: rejects stale and previously consumed root receipts
PASSED: rejects a minimal fabricated root receipt
PASSED: rejects altered repository, prompt, entry, and kickoff bindings
PASSED: rejects altered repository, prompt, entry, and kickoff bindings
PASSED: rejects altered repository, prompt, entry, and kickoff bindings
PASSED: rejects altered repository, prompt, entry, and kickoff bindings
PASSED: rejects altered repository, prompt, entry, and kickoff bindings
PASSED: stores authority receipts and attestations outside the repository workspace
PASSED: rejects a CODEX_HOME authority store inside the repository
PASSED: binds a routed child to the deployment profile model
PASSED: rejects a base alias when the receipt requires a generated deployment profile
PASSED: binds a planner child to its per-feature Codex routing receipt
PASSED: denies epic mutation with the canonical origin marker
PASSED: denies an identified epic persona mutation when its attestation is missing
PASSED: denies mutation after a model mismatch attestation
PASSED: rechecks the live PreToolUse model against a valid stored attestation
PASSED: denies an identified routed agent mutation when its attestation is missing
PASSED: requests one continuation when an epic subagent stops without attestation
PASSED: uses documented stdin instead of Claude environment variables
PASSED: baseline mock interception probe
PASSED: blocks the first mutation before a local child checkpoint exists
PASSED: allows mutation after every dependency is durably merged
PASSED: allows mutation after every dependency worktree is removed
PASSED: fails closed when the launcher receipt is bound to another session
PASSED: fails closed when final issue and feature-folder identity do not match
PASSED: does not apply execution-wave gating to a preparation child
PASSED: classifies every built-in file mutation tool as a wave mutation
PASSED: classifies every built-in file mutation tool as a wave mutation
PASSED: classifies every built-in file mutation tool as a wave mutation
PASSED: does not gate a non-mutating read tool
PASSED: S01: truncates a research artifact path to its feature folder
PASSED: S02: truncates an evidence artifact path with a kind segment to its feature folder
PASSED: S03: removes repeated citations while preserving first-occurrence order
PASSED: S04: accepts a backslash-separated token
PASSED: S05: reads the folder from an absolute-prefixed token (drive letter)
PASSED: S05: reads the folder from an absolute-prefixed token (rooted)
PASSED: S06: trims a trailing sentence character (.) from the folder segment
PASSED: S06: trims a trailing sentence character (,) from the folder segment
PASSED: S06: trims a trailing sentence character (;) from the folder segment
PASSED: S06: trims a trailing sentence character (:) from the folder segment
PASSED: S07: yields no candidate for a bare docs/features/active/ token
PASSED: S08: yields no candidate for a docs/features/active/. token
PASSED: S09: yields no candidate for null text
PASSED: S09: yields no candidate for empty text
PASSED: B01: normalizes docs/features/active/b to b
PASSED: B01: normalizes active/b to b
PASSED: B01: normalizes completed/b to b
PASSED: B01: normalizes b/ to b
PASSED: B01: normalizes docs\features\active\b\ to b
PASSED: B01: normalizes docs/features/active to 
PASSED: B01: normalizes . to 
PASSED: B01: normalizes  to 
PASSED: R01: matches an integer reference against issue_num
PASSED: R02: matches a numeric-string reference against issue_num
PASSED: R03: matches a bare folder basename
PASSED: R04: matches a record value recorded with an active/ prefix
PASSED: R05: matches a record value recorded with a docs/features/active/ prefix
PASSED: R06: returns $null when no record matches
PASSED: R07: returns $null when several records match
PASSED: R08: returns $null for a null reference, null records, or a reference with no folder segment
PASSED: T01: resolves one matched candidate with its record
PASSED: T02: resolves one unmatched candidate with a null record
PASSED: T03: reports NoTarget for zero candidates
PASSED: T04: reports Ambiguous for two non-dependency candidates
PASSED: T05: prunes a cited dependency with -DependencyAware
PASSED: T06: prunes a transitive dependency (A depends on B depends on C; A and C cited)
PASSED: T07: prunes neither candidate of a dependency cycle
PASSED: T08: resolves two remaining candidates through -DeclaredIssueNumber
PASSED: T09: does not let -DeclaredIssueNumber select a record outside the cited set
PASSED: T10: resolves zero candidates through -FallbackIssueNumber
PASSED: T11: reports NoTarget when -FallbackIssueNumber names no record
PASSED: T12: does not prune a cited dependency without -DependencyAware
PASSED: O01: reports Ambiguous for both orders and either longer slug (short first)
PASSED: O01: reports Ambiguous for both orders and either longer slug (long first)
PASSED: O01: reports Ambiguous for both orders and either longer slug (long second slug first)
PASSED: O01: reports Ambiguous for both orders and either longer slug (short second slug first)
PASSED: M01: resolves minor-audit to the expected mode
PASSED: M01: resolves full-bug to the expected mode
PASSED: M01: resolves full-feature to the expected mode
PASSED: M01: resolves legacy full to the expected mode
PASSED: M01: resolves a missing marker to the expected mode
PASSED: M01: resolves empty content to the expected mode
PASSED: M01: resolves a malformed marker to the expected mode
PASSED: M01: resolves an unrecognized marker to the expected mode
PASSED: M01: resolves a missing marker with an empty -UnresolvedMode to the expected mode
PASSED: M01: resolves null content with an empty -UnresolvedMode to the expected mode
PASSED: P01: maps minor-audit to issue.md
PASSED: P01: maps full-bug to issue.md|spec.md
PASSED: P01: maps full-feature to issue.md|spec.md|user-story.md
PASSED: P01: maps unknown to issue.md|spec.md|user-story.md
PASSED: H01: the Claude and Codex copies of the resolver have equal SHA256 hashes
PASSED: classifies a relocating git add carrying a directory global option
PASSED: classifies a relocating git commit carrying a git-dir global option
PASSED: classifies a relocating git add carrying a work-tree global option
PASSED: classifies an unmodeled dash-leading token between git and its subcommand
PASSED: does not classify git log --grep add, because a non-dash non-target token stops the scan
PASSED: classifies the plain adjacent spelling
PASSED: skips VAR=value prefixes and transparent wrappers before the command word
PASSED: classifies gh pr create carrying a repo global option in the equals form
PASSED: classifies gh issue create carrying a short repo global option
PASSED: does not classify gh issue list as gh issue create
PASSED: returns the worktree path for the flag-before-path spelling
PASSED: returns the worktree path for the flag-after-path spelling
PASSED: takes operands from the matched segment only, so a chained cd contributes nothing
PASSED: consumes a modeled option-with-argument pair rather than returning its value
PASSED: treats a token after a bare double-dash separator as an operand
PASSED: returns an empty array when no segment matched
PASSED: returns the pull-request number for the anchored gh pr merge spelling
PASSED: recognises the separated form
PASSED: recognises the equals form
PASSED: resolves the number across a chained cd, which is the issue #591 fix
PASSED: returns null for an absent flag
PASSED: returns null for a present flag with no following value
PASSED: returns null when the following token is itself dash-leading
PASSED: distinguishes an absent flag from a valueless present flag
PASSED: distinguishes --body from --body-file
PASSED: reports a flag present in the equals form
PASSED: returns true only when the invocation predicate returns false
PASSED: returns false for a genuine invocation
PASSED: returns false when the text does not contain the words at all
PASSED: classifies a wrapper-led segment whose payload invokes the command
PASSED: classifies a live-substitution segment by the same wrapper rule
PASSED: classifies an unbalanced segment, because its structure could not be resolved
PASSED: classifies the subshell and command-substitution spellings
PASSED: does not classify a quoted mention in a non-wrapper segment
PASSED: exposes exactly the five transparent wrappers of D2 Piece 3 step 2
PASSED: exposes exactly the modeled git global options
PASSED: exposes exactly the modeled gh global options
PASSED: exposes exactly the modeled npx global options
PASSED: returns two empty lists for an unmodeled command word, which is fail-closed
PASSED: returns an empty array for null input
PASSED: returns an empty array for empty input
PASSED: returns an empty array for whitespace-only input
PASSED: splits on a semicolon
PASSED: splits on an ampersand
PASSED: splits on a pipe
PASSED: splits on a newline
PASSED: treats the subshell opener and closer as delimiters
PASSED: treats the group opener and closer as delimiters
PASSED: treats the substitution opener as a delimiter
PASSED: treats the backtick as a delimiter
PASSED: masks a single-quoted span
PASSED: masks a double-quoted span
PASSED: preserves nothing of the masked content, so mask length equals span length
PASSED: yields one token per double-quoted span with the delimiting quotes removed
PASSED: produces no adjacent token pair equal to the recursive-remove literal
PASSED: keeps a quoted span attached to the token it sits in
PASSED: emits an empty token for an empty quoted string
PASSED: collapses runs of whitespace between tokens
PASSED: masks the body of a plain heredoc
PASSED: masks the body of a tab-stripping heredoc whose terminator is tab-indented
PASSED: masks the body of a heredoc whose delimiter is quoted
PASSED: consumes multiple pending heredocs on one physical line in order
PASSED: masks an unterminated heredoc body to end of text and reports it unbalanced
PASSED: does not treat a three-angle here-string as a heredoc
PASSED: forces a raw scan when the heredoc delimiter is produced by expansion
PASSED: returns the first token when there is no env-assignment prefix
PASSED: skips VAR=value env-assignment prefixes
PASSED: returns the empty string when the segment carries only assignments
PASSED: sets IsWrapperLed for a wrapper-led segment
PASSED: clears IsWrapperLed for a non-wrapper segment
PASSED: sets HasLiveSubstitution for a dollar-paren inside a double-quoted span
PASSED: sets HasLiveSubstitution for a backtick inside a double-quoted span
PASSED: clears HasLiveSubstitution for an inert double-quoted span
PASSED: sets Unbalanced for an unterminated quote span
PASSED: clears Unbalanced for a balanced segment
PASSED: clause 1 selects RawText for an unbalanced or live-substitution segment
PASSED: clause 1 outranks clause 3, so a masked-eligible segment still scans raw
PASSED: clause 2 selects RawText for a wrapper-led segment
PASSED: clause 3 selects MaskedText for every other segment
PASSED: exposes exactly the fourteen members named by D2 Piece 2
PASSED: R2-P1 reports true for a wrapper-led segment
PASSED: R2-P2 reports true for a segment carrying a live substitution
PASSED: R2-P3 reports true for an unbalanced segment
PASSED: R2-P4 reports false for a masked quoted mention in a non-wrapper segment
PASSED: R2-P5 reports false for a null segment
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-agent-profile-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-python-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-checkpoint-monotonic.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Codex hook and no other
PASSED: X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X1: .codex/hooks/enforce-epic-child-worktree-binding.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
PASSED: X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
PASSED: X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:
PASSED: H1: records a dependency failure by name
PASSED: H2: reports no failure before any record
PASSED: H3: reports a failure after a record
PASSED: H4: builds the reason from the prefix, the dependency name, and the first exception line
PASSED: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape
PASSED: H6: returns a SubagentStop result carrying exit code 2 and the reason
PASSED: H7: returns null from the decision builder when nothing failed
PASSED: H8: keeps earlier records when the helper is dot-sourced again
PASSED: H9: writes nothing to any output stream when recording a failure
PASSED: H10: contains no Import-Module and no dot-source
PASSED: H12: stays within 500 lines
PASSED: baseline mock interception probe
PASSED: H2 control: codex preimplementation gate allows a ready epic delegation when feature-folder-resolution.ps1 loads
PASSED: H2 control: codex preimplementation gate allows a ready parallel delegation when feature-folder-resolution.ps1 loads
PASSED: H2 codex preimplementation gate denies that epic delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load
PASSED: H2 codex preimplementation gate denies that parallel delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load
PASSED: parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: keeps the canonical hooks byte-identical to their bundled copies
PASSED: reads stdin in every hook entrypoint
PASSED: contains no legacy Claude environment-variable dependency in hooks or shared modules
PASSED: lists every shared hook module in the core pack manifest
PASSED: ignores poisoned Claude variables when safe Codex stdin payloads are supplied
PASSED: fails closed with exit 2 and stderr for malformed stdin on every hook
PASSED: emits the current PreToolUse deny envelope for shell and patch violations
PASSED: fails closed when the canonical checkpoint is deleted or becomes invalid JSON
PASSED: denies preimplementation and batch-budget violations through their pure decisions
PASSED: allows exempt checkpoint writes and preparation-mode delegations (issue #535)
PASSED: reconstructs update patches in memory and includes move destinations
PASSED: uses one SubagentStop continuation and stops repeated continuation loops
PASSED: classifies a feature documentation path as implementation path False
PASSED: classifies the orchestrator checkpoint as implementation path False
PASSED: classifies a production script as implementation path True
PASSED: classifies a plain text file as implementation path False
PASSED: classifies an empty command as implementation command False
PASSED: classifies an apply_patch add of a script as implementation command True
PASSED: classifies an apply_patch add of documentation as implementation command False
PASSED: classifies an apply_patch rename onto a script as implementation command True
PASSED: classifies a git commit as implementation command True
PASSED: classifies a pytest run as implementation command True
PASSED: classifies an unrelated command as implementation command False
PASSED: treats a null tool_input as no implementation delegation
PASSED: detects an implementation delegation inside a serialized tool_input
PASSED: treats an unrelated serialized tool_input as no delegation
PASSED: treats a null checkpoint payload as not ready
PASSED: treats a checkpoint missing lifecycle readiness as not ready
PASSED: treats a complete checkpoint as ready
PASSED: returns empty checkpoint content when the checkpoint file is absent
PASSED: returns the checkpoint file content when the checkpoint file is present
PASSED: allows when no mapped tool_input is supplied
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows a documentation file path without consulting the checkpoint
PASSED: denies an implementation command when the checkpoint is not ready
PASSED: denies an implementation delegation when the checkpoint is not ready
PASSED: allows an implementation path when the checkpoint is ready
PASSED: reads the checkpoint from disk when no checkpoint text is supplied
PASSED: denies an apply_patch implementation through its own entrypoint
PASSED: denies a mapped Edit implementation through its own entrypoint
PASSED: allows a mapped Write of feature documentation through its own entrypoint
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: parses and hashes the exact checked-in generated profile
PASSED: persists the receipt and profile model-reasoning binding
PASSED: rejects a routing receipt whose reasoning differs from the profile
PASSED: rejects a receipt that omits the exact generated deployment agent
PASSED: requires the exact task-researcher C3 receipt before its first mutation
PASSED: rejects task-researcher C3 model reasoning profile-path and SHA mismatches
PASSED: rehashes the current profile before allowing a routed mutation
PASSED: rejects profile path traversal before reading a file
PASSED: rejects missing profiles and a stored path that differs from the current profile
PASSED: reports a run that begins part way through the token list
PASSED: reports no run when the pattern tokens are present but not contiguous
PASSED: reports no run when the token list is shorter than the pattern
PASSED: reports no run when the last candidate start position fails on its final token
PASSED: returns the rm -rf literal for a whole-token match
PASSED: returns the Remove-Item literal for its three-token spelling
PASSED: returns the four-token git push origin --force literal ahead of any structural value
PASSED: returns null for an empty command without scanning a segment
PASSED: returns null for a null command
PASSED: matches a literal carried on the second segment of a chained command
PASSED: returns the git push -f literal for a relocating short force spelling
PASSED: returns the git reset --hard literal for a relocating hard reset
PASSED: allows a relocating soft reset because --hard is the conjoined flag
PASSED: allows a relocating push that carries no force flag
PASSED: reports no structural match directly for a non-git command word
PASSED: names the matched pattern in the reason text
PASSED: returns null for a safe command
PASSED: carries hookEventName PreToolUse, permissionDecision deny, and the supplied reason
PASSED: carries no legacy top-level decision or reason key
PASSED: reads the command from well-formed mapped tool_input JSON
PASSED: falls back to the positional input when the tool_input JSON carries an empty command
PASSED: treats unparseable raw tool input as the command text itself
PASSED: returns an empty string when no transport carries a command
PASSED: returns a deny decision for a blocked command in the mapped tool_input
PASSED: returns null for a safe command in the mapped tool_input
PASSED: returns null when every transport is empty
PASSED: denies a blocked command supplied only through the positional transport
PASSED: throws for payload text that is only whitespace
PASSED: throws for malformed JSON
PASSED: throws when tool_input is absent from an otherwise well-formed envelope
PASSED: throws when the envelope is not a PreToolUse Bash event
PASSED: throws when the tool name is not Bash
PASSED: returns the parsed payload for a well-formed PreToolUse Bash envelope
PASSED: writes the deny envelope and exits 0 for a blocked command on stdin
PASSED: writes nothing and exits 0 for a safe command on stdin
PASSED: writes the reason to stderr and exits 2 for malformed stdin
PASSED: fails closed with exit 2 and the empty-input reason for whitespace-only stdin
PASSED: AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force
PASSED: AT-9 denies a relocating git push --force carrying a directory global option
PASSED: AT-10 allows a commit message that quotes a dangerous pattern in prose
PASSED: R1-X1 denies rm -rf carried inside a bash -c quoted argument
PASSED: R1-X2 denies git reset --hard carried inside an sh -c quoted argument
PASSED: R1-X3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument
PASSED: R1-X4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led
PASSED: R1-X5 denies rm -rf carried inside an unterminated quoted span
```
