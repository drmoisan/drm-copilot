# Follow-Up Issues — [P5-T1]

Timestamp: 2026-08-26T06-43

PostedAs: body

## Timestamp correction (NB-6)

The filename segment reads `07-05`. That is wrong: this artifact was committed in `2ae27c01`, whose
author date is `2026-08-26 06:44:29 -0400`, so a 07:05 capture time is 21 minutes after the commit
that introduced it. The `Timestamp:` field above has been corrected to `06-43`, which is inside the
window bounded by the preceding commit `c90d2587` (06:34) and the containing commit `2ae27c01`
(06:44), and matches when the four issues were actually filed.

The filename is deliberately NOT renamed, because `remediation-inputs.2026-08-26T06-55.md` and the
three review artifacts cite this file by path. The divergence is recorded here instead, per the
alternative the finding allows.

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

Those four promoted records are additions outside the plan's Declared write set. They violate no
acceptance criterion: every Scope Containment criterion names specific files that must remain
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
template stub. The exact body text submitted for each of the four issues is reproduced verbatim in the
final section of this artifact.

## Note recorded for the reader of #565, #566, and #567

The three sibling hooks share the defect but were not fixed here because the mandatory bundled mirrors
put a combined fix at eight production PowerShell files, over both the 3-production-file batch cap and
the 2-production-file direct-mode cap in `.claude/rules/powershell.md:37-40`. Each issue names the
reference implementation landed by this item so the fix does not have to be re-derived.

## Exact submitted body text (NB-2)

The [P5-T1] acceptance condition requires this artifact to carry the exact body text submitted
for each issue. An earlier revision claimed instead that the text was 'preserved verbatim' in the
promoted record under `docs/features/potential/promoted/`. That claim was inaccurate and is
withdrawn: the promoted record is a NEAR-COPY, not a verbatim preservation. It differs from the
submitted body in at least two ways — the promoted record carries a leading `# <name> (Potential
Bug)` title and the `> Automation note:` line that promotion strips, and three of the four promoted
records lack the `- Work Mode: full-bug` marker line that all four submitted bodies carry. Some
punctuation also differs, because promotion normalizes en-dashes to hyphens.

The four bodies below are the authoritative submitted text, retrieved with
`gh issue view <N> --json body` and reproduced without modification.

### Issue #565 — `epic-wave-barrier-resolves-nested-artifact-as-feature-folder`

URL: https://github.com/drmoisan/drm-copilot/issues/565

````markdown
- Work Mode: full-bug

## Summary
`.claude/hooks/enforce-epic-wave-barrier.ps1` resolves a feature folder from prompt text by longest match. When a delegation prompt cites a nested artifact path, the longest match is the artifact path rather than the feature folder, so the epic wave barrier issues a false block. This is the same defect fixed for `enforce-prd-feature-before-planner.ps1` under issue #518, which explicitly deferred this hook to its own issue.

## Environment
- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any agent delegation whose prompt cites a nested artifact path under a feature folder, for example `docs/features/active/<folder>/research/<file>.md`
- Data source or fixture: `.claude/hooks/enforce-epic-wave-barrier.ps1` line 99

## Steps to Reproduce
1. Prepare an active feature folder whose records legitimately satisfy the gate.
2. Issue a delegation whose prompt cites a nested artifact path under that folder - a `research/` or `evidence/<kind>/` path - rather than citing the feature folder alone.
3. Observe the hook's resolved folder.

## Expected Behavior
The hook resolves the feature folder to `docs/features/active/<folder>` for every prompt form, whether the prompt cites the folder alone, the folder plus a nested artifact, or a nested artifact alone. The decision is identical in all cases.

## Actual Behavior
The selection rule `Sort-Object -Property Length -Descending` at line 99 returns the longest matched token, which for a nested citation is the artifact path. The basename resolves to `research` or `evidence` instead of the feature folder, the record lookup fails, and the hook issues a false block.

## Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction and root-cause analysis recorded under issue #518 at `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`, sections "Repro & Evidence" and "Root Cause Analysis", and the research artifact in that folder's `research/` subtree, section 4, which enumerates all four affected hooks.

## Impact / Severity
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A false block halts a correctly-formed delegation. The failure is silent in the sense that the block reason names a folder the operator never cited, so the cause is not obvious from the message.

## Source
From: docs/features/potential/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder.md
````

### Issue #566 — `parallel-cohort-barrier-resolves-nested-artifact-as-feature-folder`

URL: https://github.com/drmoisan/drm-copilot/issues/566

````markdown
- Work Mode: full-bug

## Summary
`.claude/hooks/enforce-parallel-cohort-barrier.ps1` resolves a feature folder from prompt text by longest match. When a delegation prompt cites a nested artifact path, the longest match is the artifact path rather than the feature folder, so the parallel cohort barrier issues a false block. This is the same defect fixed for `enforce-prd-feature-before-planner.ps1` under issue #518, which explicitly deferred this hook to its own issue.

## Environment
- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any agent delegation whose prompt cites a nested artifact path under a feature folder, for example `docs/features/active/<folder>/research/<file>.md`
- Data source or fixture: `.claude/hooks/enforce-parallel-cohort-barrier.ps1` line 150

## Steps to Reproduce
1. Prepare an active feature folder whose records legitimately satisfy the gate.
2. Issue a delegation whose prompt cites a nested artifact path under that folder - a `research/` or `evidence/<kind>/` path - rather than citing the feature folder alone.
3. Observe the hook's resolved folder.

## Expected Behavior
The hook resolves the feature folder to `docs/features/active/<folder>` for every prompt form, whether the prompt cites the folder alone, the folder plus a nested artifact, or a nested artifact alone. The decision is identical in all cases.

## Actual Behavior
The selection rule `Sort-Object -Property Length -Descending` at line 150 returns the longest matched token, which for a nested citation is the artifact path. The basename resolves to `research` or `evidence` instead of the feature folder, the record lookup fails, and the hook issues a false block.

## Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction and root-cause analysis recorded under issue #518 at `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`, sections "Repro & Evidence" and "Root Cause Analysis", and the research artifact in that folder's `research/` subtree, section 4, which enumerates all four affected hooks.

## Impact / Severity
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A false block halts a correctly-formed delegation. The failure is silent in the sense that the block reason names a folder the operator never cited, so the cause is not obvious from the message.

## Source
From: docs/features/potential/2026-08-26-parallel-cohort-barrier-resolves-nested-artifact-as-feature-folder.md
````

### Issue #567 — `parallel-drift-gate-resolves-nested-artifact-as-feature-folder`

URL: https://github.com/drmoisan/drm-copilot/issues/567

````markdown
- Work Mode: full-bug

## Summary
`.claude/hooks/enforce-parallel-drift-gate.ps1` resolves a feature folder from prompt text by longest match. When a delegation prompt cites a nested artifact path, the longest match is the artifact path rather than the feature folder, so the parallel drift gate issues a false block. This is the same defect fixed for `enforce-prd-feature-before-planner.ps1` under issue #518, which explicitly deferred this hook to its own issue.

## Environment
- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any agent delegation whose prompt cites a nested artifact path under a feature folder, for example `docs/features/active/<folder>/research/<file>.md`
- Data source or fixture: `.claude/hooks/enforce-parallel-drift-gate.ps1` line 196

## Steps to Reproduce
1. Prepare an active feature folder whose records legitimately satisfy the gate.
2. Issue a delegation whose prompt cites a nested artifact path under that folder - a `research/` or `evidence/<kind>/` path - rather than citing the feature folder alone.
3. Observe the hook's resolved folder.

## Expected Behavior
The hook resolves the feature folder to `docs/features/active/<folder>` for every prompt form, whether the prompt cites the folder alone, the folder plus a nested artifact, or a nested artifact alone. The decision is identical in all cases.

## Actual Behavior
The selection rule `Sort-Object -Property Length -Descending` at line 196 returns the longest matched token, which for a nested citation is the artifact path. The basename resolves to `research` or `evidence` instead of the feature folder, the record lookup fails, and the hook issues a false block.

## Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction and root-cause analysis recorded under issue #518 at `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`, sections "Repro & Evidence" and "Root Cause Analysis", and the research artifact in that folder's `research/` subtree, section 4, which enumerates all four affected hooks.

## Impact / Severity
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A false block halts a correctly-formed delegation. The failure is silent in the sense that the block reason names a folder the operator never cited, so the cause is not obvious from the message.

## Source
From: docs/features/potential/2026-08-26-parallel-drift-gate-resolves-nested-artifact-as-feature-folder.md
````

### Issue #568 — `feature-folder-order-hook-work-mode-and-plan-filename-defects`

URL: https://github.com/drmoisan/drm-copilot/issues/568

````markdown
- Work Mode: full-bug

## Summary
`.claude/hooks/enforce-feature-folder-order.ps1` carries two independent defects: it demands the
`full-feature` prerequisite set unconditionally with no work-mode awareness, and its path regex
requires a literal `plan.md`, which the repository's prevailing timestamped plan-artifact convention
does not match. Both were found while scoping issue #518 and were recorded there as explicitly
excluded, to be filed separately.

## Environment
- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any plan write into an active feature folder
- Data source or fixture: `.claude/hooks/enforce-feature-folder-order.ps1` lines 62, 87, and 120

## Steps to Reproduce
Defect A - prerequisite set:

1. Prepare an active feature folder whose `issue.md` carries `- Work Mode: full-bug`, with `spec.md`
   present and `user-story.md` correctly absent.
2. Attempt a plan write to a file literally named `plan.md` in that folder.
3. Observe that the hook blocks, naming `user-story.md` as missing.

Defect B - plan filename:

1. Prepare any active feature folder.
2. Attempt a plan write to a timestamped artifact such as `plan.2026-08-23T23-22.md`.
3. Observe that the hook does not fire at all.

## Expected Behavior
Defect A: the hook resolves the required prerequisite set from the persisted `- Work Mode:` marker.
`minor-audit` requires `issue.md` alone; `full-bug` requires `issue.md` and `spec.md`;
`full-feature` requires all three. Legacy `full` normalizes to `full-feature`.

Defect B: the hook fires for the plan artifacts actually being written, including timestamped ones.

## Actual Behavior
Defect A: line 62 demands `issue.md`, `spec.md`, and `user-story.md` unconditionally. That set is
correct only for `full-feature`. It contradicts
`.claude/skills/feature-promotion-lifecycle/SKILL.md:111`, under which `minor-audit` expects
`issue.md` alone and `full-bug` expects `issue.md` and `spec.md` with `user-story.md` absent unless
explicitly justified. A correctly-formed `full-bug` or `minor-audit` plan write is therefore blocked.

Defect B: the path test at line 87 is a strictly anchored regex whose match must end in a literal
`plan.md`. A timestamped plan artifact does not match, so the hook is inert in the common case and
enforces nothing.

## Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet: recorded under issue #518 at
  `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`,
  section "Scope & Non-Goals", subsection "Explicitly excluded systems, integrations, or datasets".

## Impact / Severity
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Defect B currently masks Defect A, so neither is observed in normal operation. The severity is the
combined risk: a gate that enforces nothing today and would block correctly-formed work the moment
its regex is corrected.

## Source
From: docs/features/potential/2026-08-26-feature-folder-order-hook-work-mode-and-plan-filename-defects.md
````
