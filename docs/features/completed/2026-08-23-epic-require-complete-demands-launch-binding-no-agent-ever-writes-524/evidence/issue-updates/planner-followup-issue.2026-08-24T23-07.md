# Planner Follow-Up Issue — Latent `require_ready_for_execution` Launch-Binding Defect [P5-T4]

Timestamp: 2026-08-24T23-07

Task: [P5-T4]
Parent issue: #524
Filed issue: **#543**
PostedAs: body
Issue URL: https://github.com/drmoisan/drm-copilot/issues/543
Issue title: `Bug: epic-planner-ready-gate-demands-codex-only-launch-binding`
Issue state at time of record: OPEN
Verification command: `gh issue view 543 --json number,title,url,state`

## Filing Route

Direct `gh issue create` is blocked in this repository by
`.claude/hooks/enforce-promotion-mcp-only.ps1`. The issue was therefore filed through the approved
MCP promotion path, which writes a promotion record at
`docs/features/potential/promoted/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding.md`.
That promotion record is the mandated by-product of this task in this repository and is an
authorized addition to the changed-path set (see [P6-T11]).

## Exact Text Filed

The exact text filed as the issue body is reproduced verbatim below.

---

# epic-planner-ready-gate-demands-codex-only-launch-binding (Issue #543)

- Date captured: 2026-08-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-planner-ready-gate-demands-codex-only-launch-binding/ (Issue #543)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #543
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/543
- Last Updated: 2026-08-25
## Summary

`scripts/dev_tools/validate_epic_planner_state.py` carries the same structural defect that issue #524 fixes on the epic-orchestrator side, one layer up: under `require_ready_for_execution` it demands Codex-only launch evidence that no Claude-runtime producer ever writes, so the gate cannot pass on the Claude runtime. The defect is latent because no Claude surface passes that flag today.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `validate_epic_planner_state_text(text, require_ready_for_execution=True)`, reachable via the `epic-planner-state` artifact type with `--require-ready-for-execution`
- Data source or fixture: any Claude-prepared epic planner checkpoint at `artifacts/orchestration/epic-planner-state.json`

## Steps to Reproduce

1. Prepare an epic on the Claude runtime so that `artifacts/orchestration/epic-planner-state.json` records a fully prepared feature set.
2. Validate that checkpoint with `require_ready_for_execution=True`.
3. Observe launch-binding errors for every feature, none of which any Claude agent can satisfy.

## Expected Behavior

The ready gate validates the structural readiness properties it owns, and requires per-feature launch evidence only when the caller is asserting a Codex enforcement flag or when the feature actually carries launch path keys — matching the correction landed for the epic-orchestrator gate in #524.

## Actual Behavior

Inside the `require_ready_for_execution` block (`validate_epic_planner_state.py:320`), the call at line 331 is unconditional:

```python
    if require_ready_for_execution:
        ...
        errors.extend(validate_epic_planner_child_launch_bindings(features))
```

`validate_epic_planner_child_launch_bindings` calls `_validate_launch_bindings` with `skip_not_started=False` and `require_generated_orchestrator=True`, which produces two independent failures:

1. Every feature must carry `launch_receipt_path` and `launch_status_path` under `artifacts/orchestration/epic-child-launches/`. The sole production writer of that evidence is `.codex/scripts/launch-epic-child-wave.ps1` on the Codex runtime; the Claude runtime has no producer. This is the identical unsatisfiable-gate shape recorded in #524.
2. `require_generated_orchestrator=True` restricts `delegation_receipt.agent_name` to the five Codex-generated persona names `orchestrator-c1`, `orchestrator-c2`, `orchestrator-c3`, `orchestrator-c3-elevated`, and `orchestrator-c4` (`_GENERATED_ORCHESTRATOR_AGENTS`). None exists in the Claude runtime, which delegates preparation to the single `orchestrator` agent. Even a checkpoint that somehow carried launch paths would still fail this check.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: the error family is the same one #524 reproduced against the orchestrator gate, of the form `Epic planner checkpoint features[N] launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Latent today. A repository-wide search across `.claude/**` for `require_ready_for_execution` returns matches only for the parallel planner (`validate_parallel_planner_state.py`, documented in `.claude/rules/parallel-orchestration.md` and `.claude/skills/parallel-plan/SKILL.md`). No Claude surface passes the flag for the `epic-planner-state` artifact type, so the gate never runs on the Claude runtime. It becomes live the moment any Claude skill, agent, hook, or MCP call starts passing it.

## Suspected Cause / Notes

The planner gate was authored against the Codex runtime, where the launcher writes the evidence and the generated orchestrator personas exist. The generic readiness flag was then admitted into an activation set that is Codex-specific in practice — the same category of error as #524, where the generic `require_complete` flag was admitted into a Codex-specific activation set.

Files to inspect:

- `scripts/dev_tools/validate_epic_planner_state.py` (lines 320-332)
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (`validate_epic_planner_child_launch_bindings`, `_GENERATED_ORCHESTRATOR_AGENTS`)
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (the parity twin, governed by a TypeScript/Python parity test)

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` and its Jest twin
- [x] Integration scenario to retest: validate a Claude-prepared epic planner checkpoint with `require_ready_for_execution=True` and confirm zero launch-binding errors, while a Codex-shaped checkpoint keeps its existing behaviour
- [x] Manual verification notes: the `require_launch_paths` keyword added to `_validate_launch_bindings` by #524 already provides the seam. `validate_epic_planner_child_launch_bindings` currently passes `require_launch_paths=False` explicitly, so the planner path was left unchanged by that fix and this issue decides its final behaviour.

Separately, decide whether `require_generated_orchestrator=True` should remain unconditional or become Codex-flag-scoped. That is a policy question about whether the epic planner surface is Codex-only by design, and it should be answered explicitly rather than inherited.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

Related: issue #524, feature folder `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/`. That folder's `plan.2026-08-23T23-24.md` declares this defect explicitly out of scope in its "Explicitly out of scope" section and mandates this filing in task P5-T4.

---

## Required Content Checklist ([P5-T4])

| Required element | Where it appears in the filed text |
| --- | --- |
| Defect shape: `validate_epic_planner_child_launch_bindings` called unconditionally inside the `require_ready_for_execution` block | `## Actual Behavior`, first paragraph and code block |
| Defect shape: additionally sets `require_generated_orchestrator=True`, restricting `agent_name` to five Codex-generated persona names absent from the Claude runtime | `## Actual Behavior`, numbered item 2 |
| Reason it is latent: no Claude skill or agent passes that flag | `## Impact / Severity`, second paragraph |
| Reference to issue #524 | `## Summary`, `## Expected Behavior`, `## Suspected Cause / Notes`, and the closing `Related:` line |
| Reference to this feature folder | Closing `Related:` line |
