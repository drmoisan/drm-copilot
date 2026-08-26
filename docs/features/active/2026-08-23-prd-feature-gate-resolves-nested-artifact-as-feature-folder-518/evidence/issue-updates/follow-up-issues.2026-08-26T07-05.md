# Follow-Up Issues — [P5-T1]

Timestamp: 2026-08-26T07-05

PostedAs: body

Task: [P5-T1]

## Result

Four follow-up issues were filed, satisfying the Scope Containment requirement in `spec.md`: one for
each of the three sibling prompt-scanning hooks, and one for the two `enforce-feature-folder-order.ps1`
defects.

| Issue | URL | Subject |
| --- | --- | --- |
| #565 | https://github.com/drmoisan/drm-copilot/issues/565 | `enforce-epic-wave-barrier.ps1` line 99 — nested artifact resolved as feature folder |
| #566 | https://github.com/drmoisan/drm-copilot/issues/566 | `enforce-parallel-cohort-barrier.ps1` line 150 — same defect |
| #567 | https://github.com/drmoisan/drm-copilot/issues/567 | `enforce-parallel-drift-gate.ps1` line 196 — same defect |
| #568 | https://github.com/drmoisan/drm-copilot/issues/568 | `enforce-feature-folder-order.ps1` — work-mode-blind prerequisite set (line 62) and `plan.md`-literal regex (line 87) |

Titles as created:

- #565 `Bug: epic-wave-barrier-resolves-nested-artifact-as-feature-folder`
- #566 `Bug: parallel-cohort-barrier-resolves-nested-artifact-as-feature-folder`
- #567 `Bug: parallel-drift-gate-resolves-nested-artifact-as-feature-folder`
- #568 `Bug: feature-folder-order-hook-work-mode-and-plan-filename-defects`

## Deviation from the task text, and why

[P5-T1] specifies `gh issue create` and states that the task writes "no repository file other than the
evidence mirror". Neither clause survived contact with the repository's own enforcement.

`gh issue create` is blocked by a PreToolUse hook:

```text
PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation via `gh` bypasses the approved
drm-copilot MCP promotion path (`mcp__drm-copilot__new_potential_entry` ->
`mcp__drm-copilot__potential_to_issue` -> `mcp__drm-copilot__new_active_feature_folder`).
Use those MCP tools instead.
```

The approved MCP route was used instead: `mcp__drm-copilot__new_potential_bug_entry` followed by
`mcp__drm-copilot__potential_to_issue` with `promotion_type=bug` and `work_mode=full-bug`, once per
issue. That route necessarily writes repository files — a potential entry under
`docs/features/potential/`, which promotion then relocates to `docs/features/potential/promoted/` —
so the "no repository file" clause is unsatisfiable through the only permitted path.

Four files are added, not eight: `potential_to_issue` MOVES the potential entry to
`docs/features/potential/promoted/` rather than copying it, so only the promoted record survives.
Verified by `git status --porcelain`, which reports four additions under
`docs/features/potential/promoted/` and no residual file under `docs/features/potential/`:

```text
A  docs/features/potential/promoted/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder.md
A  docs/features/potential/promoted/2026-08-26-feature-folder-order-hook-work-mode-and-plan-filename-defects.md
A  docs/features/potential/promoted/2026-08-26-parallel-cohort-barrier-resolves-nested-artifact-as-feature-folder.md
A  docs/features/potential/promoted/2026-08-26-parallel-drift-gate-resolves-nested-artifact-as-feature-folder.md
```

`mcp__drm-copilot__new_active_feature_folder` was deliberately NOT invoked for any of the four. These
are follow-up reports, not work being started, so no active feature folder is created and no branch is
cut. The lifecycle stops at the promoted record.

The four files added under `docs/features/potential/` and four under
`docs/features/potential/promoted/` are additions outside the plan's Declared write set. They violate
no acceptance criterion: every Scope Containment criterion names specific files that must remain
UNMODIFIED, and none of those files is touched.

## Secondary reason the task could not run as delegated

[P5-T1] was assigned to the plan executor, but `atomic-executor` has no `gh` in its tool allowlist, so
it could not have filed these issues even had the hook permitted it. The orchestrator executed the
task directly. This is recorded as a delegation bypass in
`artifacts/orchestration/orchestrator-state.json`.

## Verification

```text
gh issue list --limit 5 --json number,title
```

EXIT_CODE: 0

Output Summary: All four issues are present and open, numbered 565 through 568, with the titles listed
above. `gh issue view 565 --json body` confirms the submitted body carries the full bug-report
template content — Summary, Environment, Steps to Reproduce, Expected Behavior, Actual Behavior, Logs,
Impact, Suspected Cause, Proposed Fix, and the `- Work Mode: full-bug` marker — rather than the unfilled
template stub. The exact body text submitted for each issue is preserved verbatim in that issue's
promoted record under `docs/features/potential/promoted/`, which is committed on this branch.

## Note recorded for the reader of #565, #566, and #567

The three sibling hooks share the defect but were not fixed here because the mandatory bundled mirrors
put a combined fix at eight production PowerShell files, over both the 3-production-file batch cap and
the 2-production-file direct-mode cap in `.claude/rules/powershell.md:37-40`. Each issue names the
reference implementation landed by this item so the fix does not have to be re-derived.
