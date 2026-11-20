# B4 Scoped Pester ([P4-T7])

Timestamp: 2026-09-27T07-16
Command: sh <SCRATCHPAD>/x707p2-rscoped.sh tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 (R-SCOPED body of plan section 5, launched by route sh with working directory <WORKSPACE_ROOT>)
EXIT_CODE: 0
Output Summary: PassedCount 121, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0 across six containers, each with failed=0. The six Suite C names (C1 to C6) appear on PASSED lines. The transport (56) and legacy (43) suites report the same passed values as evidence/qa-gates/b2-scoped-pester.md, so the D10 mocks add no test.

Run history: the first run at 2026-09-27T07-13 gave the same counts (121 passed, 0 failed, six containers with failed=0). [P4-T8] then found two PSReviewUnusedParameter warnings in Suite C and fixed them, and this task was re-run as [P4-T8] requires. The output below is from the re-run, which is the final state.

## Runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T07-16

Starting discovery in 6 files.
Discovery found 121 tests in 212ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1
 22.63s (22.21s|307ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1
 10.06s (9.98s|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1
 75ms (34ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1
 88ms (47ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1
 110ms (77ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1
 12.34s (12.3s|25ms)
Tests completed in 45.31s
Tests Passed: 121, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 121
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
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
PASSED: returns null edited content when the tool input carries no old_string
PASSED: returns null edited content when the on-disk checkpoint is empty
PASSED: returns null edited content when the old_string is absent from the checkpoint
PASSED: applies the old_string to new_string replacement in memory
PASSED: reads the governed checkpoint path through the injected reader
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
PASSED: does not intercept a completion-asserting Write to the epic checkpoint
PASSED: does not intercept a completion-asserting Edit to the epic checkpoint
PASSED: does not intercept an apply_patch Add of the epic checkpoint
PASSED: emits no mapped record for an apply_patch Update of the epic checkpoint
PASSED: still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/
PASSED: still denies a completion-asserting per-feature checkpoint that lacks ci_gate
PASSED: reports the whole pr_gate object as missing when the checkpoint has none
PASSED: names each absent pr_gate field individually
PASSED: requires the pr_gate head_sha to match the ci_gate head_sha
PASSED: reports no missing evidence when the pr_gate is complete and agrees with the ci_gate
PASSED: reports the whole ci_gate object as missing when the checkpoint has none
PASSED: does not require pr_gate evidence when the route opts out
PASSED: denies a governed checkpoint write whose content is not valid JSON
PASSED: allows a completion-asserting checkpoint that carries every required piece of evidence
PASSED: denies a completion-asserting checkpoint whose pr_gate evidence is incomplete
PASSED: emits the PreToolUse deny shape for a completion checkpoint with missing evidence
PASSED: uses the helper-backed route gate for bundled Codex resources
PASSED: keeps the bundled-mirror enforce-completion-consistency.ps1 byte-identical to the canonical hook
PASSED: keeps the bundled-mirror enforce-completion-helpers.ps1 byte-identical to the canonical helper
PASSED: derives 17 PreToolUse hooks and excludes 4 non-PreToolUse registrations from the bundle config
PASSED: returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location
PASSED: leaves no batch-budget state in the bundle
EXIT_CODE=0
```
