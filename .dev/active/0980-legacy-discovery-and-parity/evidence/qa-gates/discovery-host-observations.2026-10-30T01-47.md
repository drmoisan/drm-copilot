# P16-T7 Per-host observation table without launcher-supplied identity

Timestamp: 2026-10-30T01-47
Task: [P16-T7] Record the per-host observation table without launcher-supplied identity.
Command: sh SCRATCH/issue-980-pester.sh tests/scripts/claude-hooks/discovery-capability.Tests.ps1 tests/scripts/codex-hooks/discovery-capability.Tests.ps1 tests/scripts/copilot-hooks/discovery-capability.Tests.ps1 tests/scripts/claude-lib/discovery-validation/DiscoveryObservation.Tests.ps1 tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 (the fixture suites that prove the probe and observation behavior per host; no host was driven by the executor)
EXIT_CODE: 0
Output Summary: `Tests Passed: 91, Failed: 0, Skipped: 0` across the six suites (the three per-host probe suites, the observation module, the capability module and the operator entry point). No row below claims a host observation: every host is `not exercised in this cycle` by the executor, the VS Code legacy Local harness row reads `unsupported`, and each row names the source that proves its hook behavior by fixture. The executor exported no identity variable and wrote no observation by hand.

## How a host row becomes an observation

The executor runs as an isolated subagent whose hooks execute in its own worktree context, so it cannot launch `discovery-capability-sentinel` as a non-isolated delegation of the session under test; the orchestrator (the session's main thread) can. For a host the orchestrator drives, the row is replaced by the probe status, the observation field names present and the doctor result, with the observation documents cited; host paths and session values are not recorded.

Launch instructions (orchestrator, Claude Code, from this worktree, with the P16-T6 wheel installed and the workspace activated):

1. Delegate `discovery-capability-sentinel` as a non-isolated subagent of the current session with `workspace_root` set to this worktree and a fresh sentinel identifier. The agent calls `discovery_capability_sentinel` once and runs the single forbidden sentinel command; both PreToolUse events are recorded by `.claude/hooks/enforce-discovery-artifact-gate.ps1` as `host-observation` records under the session's `observations/` partition.
2. Call `run_discovery_doctor` with the same `workspace_root`. The tool gate writes the root grant for the call; the doctor reports the session's capability from the probe's attestation.
3. Record, in a new `discovery-host-observations.<timestamp>.md`: the probe `status`, the set of observation field names present on the recorded records (`agent_id`, `agent_type`, `tool_use_id`), the doctor `summary.message` and capability finding codes, and the repository-relative names of the observation documents cited. Do not record session identifiers, store paths or host paths.
4. For Codex and the Copilot harness the same two steps run from a local session of that host with the rebuilt packages pushed down; without such a session the row stays `not exercised in this cycle`.

## Per-host table

| Host | Status in this cycle | Observation field names present | Doctor result | Source |
|---|---|---|---|---|
| Claude Code | not exercised in this cycle (isolated-subagent hook context: the executor's PreToolUse events are attributed to its own worktree session, not to a non-isolated sentinel delegation of the session under test) | none recorded by the executor | not run against a sentinel session by the executor | `tests/scripts/claude-hooks/discovery-capability.Tests.ps1` ("observes the registered Claude handlers, hashes them and proves attribution from the recorded sentinel observation pair"; "persists the observation as the protected session capability attestation"; the unsupported cases), `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` ("allows a root prepare with a one-use root grant bound to this session"), `tests/scripts/claude-lib/discovery-validation/DiscoveryObservation.Tests.ps1`, `DiscoveryCapability.Tests.ps1` |
| Codex | not exercised in this cycle (no local Codex session) | none recorded by the executor | not run by the executor | `tests/scripts/codex-hooks/discovery-capability.Tests.ps1` ("observes the registered Codex handlers and proves attribution from the recorded sentinel observation pair"; the unsupported cases), `tests/scripts/codex-hooks/discovery-pre-tool.Tests.ps1` ("allows every non-grant tool for a root Codex payload without an agent identity"; "grants a root Codex doctor call once with a root grant bound to the codex host") |
| Copilot harness | not exercised in this cycle (no local Copilot session) | none recorded by the executor | not run by the executor | `tests/scripts/copilot-hooks/discovery-capability.Tests.ps1` ("observes the registered Copilot handlers from discovery.json and proves attribution from the recorded sentinel observation pair"; "registers the four Copilot hooks in the documented version-1 shape with powershell and bash commands and no Claude matcher"), `tests/scripts/copilot-hooks/discovery-pre-tool.Tests.ps1` ("allows a root Copilot session without an agent identity"; "binds a Copilot specialist at its first controlled call when the harness supplied no start identity") |
| VS Code legacy Local harness | `unsupported` | none: its PreToolUse carries no agent identity, so no observation can be attributed | n/a | `docs/engineering/legacy-discovery-and-parity/enforcement.md` (`## Identity source`, `## Capability probe`); the research record `research/2026-10-29T13-16-host-identity-sources-research.md` (`### 6.1 Identity source per host`) |

## What the fixture suites prove

The per-host probe suites feed the probe real-shaped payload records written through the gate's own observation writer (`Add-GateSentinelObservation` in the shared test support) and assert that `supported` requires an attributed sentinel tool observation and an attributed denial recorded by the current handler hash inside the attestation window, that a session without observations is `unsupported`, and that the probe makes no in-process sentinel decision. They prove the decision logic, not what a live host places in its payload; only an orchestrator-driven run can prove the latter, and this record claims none.

Result: PASS (no unproven claim; every row cites its source)
