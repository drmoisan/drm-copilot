# QA gate — Post-fix live in-session merge-gate probe (AC-10) (#501)

Timestamp: 2026-08-22T00-55

Task: [P7-T6]

Counterpart to: `evidence/baseline/2026-08-21T21-58-merge-gate-inert-in-session-probe.md`

## Session provenance (stated so the before/after comparison is accurate)

The two probes were issued from different sessions of the same Claude Code installation on the same
machine and branch:

- **Pre-fix baseline**: captured by the **orchestrator, main session**, 2026-08-21T21:58Z.
- **Post-fix probe (this artifact)**: issued by the **atomic-executor subagent session**,
  2026-08-22T00:55.

The hook path is identical in both cases. `.claude/settings.json` registers
`enforce-epic-merge-gate.ps1` on the `Bash` matcher for the session, and a subagent's Bash tool
calls traverse the same `PreToolUse` registration as the main session's; nothing in the hook or its
registration is session-scoped. The comparison is therefore valid. Two independent in-session
observations recorded during this execution corroborate that subagent Bash calls do traverse these
hooks: `enforce-parallel-abandon-gate.ps1` denied a tool call whose text carried the abandon
disposition token, and `enforce-pr-author-skill.ps1` denied a tool call whose text carried a
`gh pr create --body-file` invocation. Both denials came from hooks migrated earlier in this same
execution.

## Preconditions (identical to the baseline)

```
artifacts/orchestration contents: orchestrator-state.json
epic_mode = False
step9_status = pending
branch: bug/pretooluse-hooks-parse-flat-payload-501
```

No `artifacts/orchestration/epic-orchestrator-state.json` and no
`artifacts/orchestration/parallel-orchestrator-state.json` are present. No allow-branch of the gate
is satisfiable, so a working gate must deny.

## Command issued

```text
gh pr merge 999999 --merge
```

The same non-existent pull-request number as the baseline, so a gate failure would be observable
without any possibility of merging a real pull request.

EXIT_CODE: the tool call was DENIED before execution; no process ran, so no exit code was produced.

## Observed result, verbatim

```text
EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.
```

## Pre-fix baseline result, verbatim (for comparison)

```text
GraphQL: Could not resolve to a PullRequest with the number of 999999. (repository.pullRequest)
```

## Before/after comparison

| | Pre-fix baseline (main session, 21:58Z) | Post-fix probe (executor session, 00:55) |
| --- | --- | --- |
| Tool call | `gh pr merge 999999 --merge` | `gh pr merge 999999 --merge` |
| Checkpoint state | no allow-branch satisfiable | no allow-branch satisfiable (identical) |
| Hook decision emitted | none | `deny` |
| Reason | none | begins `EPIC_MERGE_GATE_BLOCKED:` |
| Reached the `gh` CLI | **yes** — the GraphQL error proves `gh` executed | **no** — the call was denied before execution |

The baseline's GraphQL error is the decisive discriminator: it can only be produced by the `gh`
binary, so the pre-fix command demonstrably executed. The post-fix result carries no GraphQL error
and no `gh` output of any kind, only the hook's deny reason, so the command demonstrably did not
execute. The result is the exact opposite of the baseline, which is what AC-10 requires.

## Output Summary

The live in-session tool call `gh pr merge 999999 --merge` is DENIED by
`enforce-epic-merge-gate.ps1` with a reason beginning `EPIC_MERGE_GATE_BLOCKED:`, and the command
does not reach the `gh` CLI. The pre-fix baseline recorded the same command reaching `gh` with no
hook decision emitted. This is the end-to-end proof that the `PreToolUse` enforcement surface is
live again under the payload the Claude Code harness actually sends. AC-10 satisfied.
