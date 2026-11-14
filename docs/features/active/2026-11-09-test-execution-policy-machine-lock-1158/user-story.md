# `2026-11-09-test-execution-policy-machine-lock` — User Story

- Issue: #1158
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09T21-50

## Story Statement

- As an agent operator running several features in parallel worktrees on one machine, I want test suites to run one at a time through a single recognizable launcher, without the local integration and golden lanes, so that each suite finishes in minutes instead of contending for the CPU for over an hour.
- As a repository owner, I want the test-execution policy to be configurable, validated, enforced by a hook, and described in the planning and QA skills, so that agents follow it consistently in this repository and in destination repositories after push-down.

## Problem / Why

Several features ran full test suites at the same time on one machine, each with one worker per core and each including the slow integration and golden suites under coverage. Machine load reached about four to five times the core count, and individual suite runs took over 100 minutes where the same suite alone takes a few minutes. Agents also ran suites through scratch wrapper scripts, which process-based checks could not see. There is no lane split, no machine-wide serialization, and no enforcement point today.

## Personas & Scenarios

- Persona: Agent operator (orchestrator, atomic executor, or planner)
  - Runs QA gates (Pester, pytest, Jest, bats) inside an agent-isolated worktree while other features run concurrently on the same machine.
  - Cares about gate results that arrive within the tool-call timeout and that reflect the branch under test.
  - Constrained by the Bash tool timeout, the worktree isolation guard, and the repository hooks; has no PowerShell tool.
  - Frustrated by suites that take over 100 minutes under contention and by ambiguous failures that are really load-induced timeouts.
  - Motivated to finish the item's gates and record evidence that reviewers accept.
- Persona: Repository owner
  - Maintains the harness, its hooks and skills, and the push-down to destination repositories.
  - Cares about predictable machine load, auditable policy, and settings that a destination repository can override locally.
  - Constrained by the language rules (pushed-down logic in PowerShell or bash, no new Python) and by mirror-parity contract tests.
  - Frustrated by agents that bypass process-based checks through wrapper scripts.
  - Motivated to make the policy enforceable rather than advisory.
- Scenario: Two executors reach their Pester gate at the same time
  - Executor A runs `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`; the launcher acquires the machine lock, writes the holder record, and runs `Invoke-PoshQCParallelTest` with its normal worker count and the integration and golden lanes excluded.
  - Executor B runs the same command in another worktree; the launcher finds the lock busy, polls every 2000 ms, and after 90000 ms exits 75 with `TEST_EXECUTION_QUEUE_TIMEOUT:` naming executor A's suite and pid.
  - Executor B records the queue timeout as a non-failure and re-runs the gate after A finishes; B's run then acquires the lock.
- Scenario: An executor tries to bypass the launcher
  - The executor writes a `SCRATCH` `sh` script that runs `Invoke-PoshQCParallelTest`, or runs `poetry run pytest -n auto` directly.
  - The PreToolUse hook denies the call with `TEST_EXECUTION_POLICY_BLOCKED:`, naming the test-execution policy and the launcher command to use instead.
- Scenario: A plan step would run an integration test locally
  - The planner, following the updated atomic-plan-contract, cites the CI integration job as evidence and records a non-blocking deviation under `evidence/other/` instead of running the lane locally.
  - If an executor passes an integration-suffixed path to the launcher, the launcher (and the hook) refuse with exit 2 and a message that the local integration lane is CI-only evidence.
- Scenario: A destination repository overrides a default
  - The owner of a destination repository adds `config/test-execution-policy.json` with additional lane suffixes or a longer `waitMilliseconds` within the validated range.
  - An invalid value stops the launcher with exit 2 and a message naming the file and field; the hook denies test commands with the same naming until the file is fixed.

## Acceptance Criteria

### Agent operator

- [x] (AC2) A suite started through `run-test-suite.sh` while another suite holds the machine lock exits 75 with a `TEST_EXECUTION_QUEUE_TIMEOUT:` message naming the holder's suite and pid, proven by the busy-lock case in `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` and by the live Linux two-process proof recorded under `evidence/other/`.
- [x] (AC2) A suite started through the launcher runs with its configured worker options unchanged (`-n auto` for pytest, `Invoke-PoshQCParallelTest` without `-WorkerCount` for Pester), proven by the worker-token cases in `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`.
- [x] (AC2) The launcher propagates the suite's exit code and releases the lock and deletes the holder record when the suite fails or throws, proven by `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`.
- [x] (AC3) The queue waits only through injected `Clock` and `Sleep` seams in tests, and returns `Timeout` exactly when the injected clock reaches the configured wait bound, proven by `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1`.
- [x] (AC4) A direct runner invocation, a runner inside `sh -c` or `pwsh -Command` or `pwsh -EncodedCommand`, and a hidden `sh`, `pwsh -File`, or `.py` wrapper that runs a suite are denied with `TEST_EXECUTION_POLICY_BLOCKED:` naming the test-execution policy and the launcher command, proven by `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` and `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1`.
- [x] (AC4) The PoshQC MCP test and suite tools are denied with `TEST_EXECUTION_POLICY_BLOCKED:` naming the holder while the lock is held, and allowed when it is free, proven by the MCP cases in `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1`.
- [x] (AC4) A launcher invocation that names an integration-suffixed path, a lane marker, a lane tag, or a worker-reduction token is refused with exit 2 by the launcher and denied by the hook with `TEST_EXECUTION_POLICY_BLOCKED:`, proven by `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` and `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1`.
- [x] (AC5) The execution-environment brief and the atomic executor agent name the launcher command, the exit 75 re-run rule, and the MCP gap until the extension release, proven by `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, the push-down resource contract tests, and the Codex generator `--check` passing.

### Repository owner

- [x] (AC1) `.claude/skills/test-execution-policy/SKILL.md` and its mirrors document every configuration key with its default and validation rule, the lock location, the holder record, exit codes 75 and 2, and both message prefixes, proven equal across copies by `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`.
- [x] (AC1) With no configuration file the policy excludes the integration and golden lanes, enables the machine lock with a 90000 ms wait and 2000 ms poll, and requires the launcher; every validation rule returns an error naming its field, proven by `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`.
- [x] (AC1) The committed `config/test-execution-policy.json` validates and classifies the repository's integration-named test files, proven by `tests/scripts/claude-hooks/test-execution-policy.RepoConfig.Tests.ps1`.
- [x] (AC2) `fix_all`, the atomic executor QC runner, and the VS Code test tasks run suites through `Invoke-TestSuite.ps1`, proven by the updated assertions in `tests/scripts/dev_tools/test_fix_all_branches.py` and `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` passing in the pytest gate.
- [x] (AC2) PoshQC excludes lane tags and lane file suffixes only when the new parameters are supplied and behaves as today when they are omitted, and the MCP templates take the lock only when the workspace helper exists, proven by `tests/scripts/powershell/PoshQC/PoshQC.TestingLaneExclusion.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.McpTemplateLock.Tests.ps1`, and `test_poshqc_bundled_parity.py`.
- [x] (AC3) The lock-decision, lane-classification, and launcher tests use injected clock, process, and filesystem seams with no temporary files and no real waits, and `Invoke-PoshQCLeakScan` passes in the gate run.
- [ ] (AC4) The hook reaches each of `Bash`, `mcp__drm-copilot__run_poshqc_test`, and `mcp__drm-copilot__run_poshqc_suite` exactly once as a member of the four `pretooluse-dispatch.json` registries (`.claude/hooks/`, `.codex/hooks/`, and their bundle copies), with no direct entry for a dispatched name; the Codex dispatcher `timeout` in `.codex/config.toml` and its bundle copy equals the sum of its member timeouts; and the new files are in both `core.json` manifests, proven by `tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1`, `test_push_down_pack_manifest_dependency_closure.py`, both pack-manifest completeness tests, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passing.
- [x] (AC5) The execution-environment, atomic-plan-contract, python-qa-gate, powershell-qa-gate, csharp-qa-gate, invoke-python-engineer, invoke-powershell-engineer, and invoke-csharp-engineer copies and the typescript-engineer agent copies state "CI integration and golden lanes are evidence", "non-blocking deviation", and "machine test-suite lock", proven by the new rows in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` passing.

## Non-Goals

- Reducing the parallel worker count of a running suite, or any per-suite worker throttling.
- Running the integration or golden lanes locally; they remain CI evidence, and CI job definitions are not changed by this item.
- A lock shared across users, across a devcontainer and its host, or across machines.
- Changing the MCP tools' TypeScript behavior; the MCP lock applies through the PowerShell templates after an extension release and reinstall.
- Consolidating hooks into a single dispatcher (issue #1159) or changing hook root resolution (issue #1163).
- Making the hook a security control; it is a policy-level guard that allows unreadable or oversized wrapper files.
- Adding new Python files or a pytest plugin.
