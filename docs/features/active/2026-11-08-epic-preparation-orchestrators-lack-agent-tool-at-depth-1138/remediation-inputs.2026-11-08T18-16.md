# Remediation Inputs — Issue 1138

Timestamp: 2026-11-08T18-16
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Source review artifacts:
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/policy-audit.2026-11-08T18-16.md`
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/code-review.2026-11-08T18-16.md`
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/feature-audit.2026-11-08T18-16.md`
Head reviewed: `08e400844373251892289ce0c7562b1daff6af0e` (merge base `a90d522c6ac239bca858d7bc800d52860e823219`)
Prior cycle: none (first review).

## Findings requiring remediation

### F1 — Coordinator agents give no instruction for a NESTING_DEPTH_INSUFFICIENT deny of their own Agent(orchestrator) call

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix adds one sentence to four agent files already in the branch diff, their bundle copies, one literal in an existing contract test, and one pinned digest in an existing test file; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `.claude/agents/epic-planner.md`, `.claude/agents/epic-orchestrator.md`, `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`; their copies under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`; `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1`; `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`, `epic-orchestrator.md` entry).
- Problem: all six coordinator skills run with `context: fork` and an `agent:` value, so the coordinator is not started by an `Agent` tool call and the hook's main-thread case does not apply to it. At a configured limit of 2 the coordinator keeps the Agent tool, passes its preflight, and its `Agent(orchestrator)` call is denied by the hook with a reason beginning `NESTING_DEPTH_INSUFFICIENT:`. The preflight paragraph covers only an absent Agent tool and a child's `AGENT_TOOL_UNAVAILABLE:` line, so the coordinator has no instruction to halt on the deny, and may do the child's work itself, which is the failure mode reported in the issue.
- Required change: in the `## Startup Protocol` lead paragraph of each of the four coordinator agents, after the child-halt sentence, add: "When an `Agent(orchestrator)` call is denied with a reason beginning `NESTING_DEPTH_INSUFFICIENT:`, halt with that reason and record `spawn_agent_unavailable` in the same way; do not do the child's work in its place." Copy the four files byte-identically to the bundle. Add `NESTING_DEPTH_INSUFFICIENT:` to the literals asserted by the "coordinators halt on child AGENT_TOOL_UNAVAILABLE" `It` (or a sibling `It`) over live and bundle copies. Re-baseline the `epic-orchestrator.md` digest in `PINNED_FROZEN_SURFACE_HASHES`, extending the existing #1138 comment block.
- Verification required: PoshQC format and analyze on the edited test file; one `Invoke-PoshQCParallelTest` run with 0 failures; one `pytest -n auto` run with 0 failures, including `test_frozen_epic_surface_matches_pinned_baseline_digest` and the push-down resource parity tests; Black, Ruff, and Pyright on the edited Python file.

## Light Fix Tasks

- [ ] [P0-T1] `.claude/agents/epic-planner.md`, `epic-orchestrator.md`, `parallel-planner.md`, `parallel-orchestrator.md`, their bundle copies, `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1`, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (F1): add the `NESTING_DEPTH_INSUFFICIENT:` halt sentence to the four coordinator preflights, mirror them, assert the literal in the contract test, re-baseline the `epic-orchestrator.md` pin, and run the PowerShell and Python gates once each.
- [ ] [P0-T2] `.claude/hooks/epic-invocation-nesting-depth.ps1`, its bundle copy, and `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` (related non-blocking Low item, added by the orchestrator): parse the trimmed value with `[long]::TryParse` (invariant culture, integer style) instead of `[int]::TryParse`, so an integer above the Int32 range such as `99999999999` is treated as an integer at or above 3 and allowed, and a value below the Int64 range is still an integer below 3 and denied; add `99999999999` to the cases of the "allows at or above 3" It. Keep the helper at 100% line coverage. Run this task before the gates of P0-T1 so one PowerShell gate run covers both tasks.

## Non-remediation items (record only)

- Low: a limit value above the Int32 range (for example `99999999999`) denies with "is not an integer"; fail-closed and unlikely in practice.
- Info: the main-session fallback does not say how the main session obtains the coordinator's delegation prompt once the coordinator halts; spec non-goal (research option C2).
- Info: no hook-level allow `It` for `orchestrator` to a specialist at limit 2; covered at helper level and confirmed by the reviewer's real-process probe.
- AC9 CI confirmation on the PR head is pending-CI, owned by the orchestrator at S9; no PR exists yet. It is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run.
- Tests create no files and set no environment variables.
- Edit only the files named in F1 and in P0-T2; do not change spec acceptance-criterion text.
- Any commit makes this review stale, so a re-review follows.
