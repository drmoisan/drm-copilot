# prd-feature Gate: Pre-Change Verdict of the Coordinator Regression Case (issue #673, closing #672)

Timestamp: 2026-09-19T18-59

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-prd-precontrol.ps1` (route `a`). The script imports `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` and `.claude/lib/worktree-resolution/WorktreeResolution.psm1`, dot-sources `.claude/hooks/enforce-prd-feature-before-planner.ps1` in its still-unmodified state, and calls `Invoke-PrdFeatureBeforePlannerDecision` twice against one payload.

EXIT_CODE: 0

## The case

A coordinating session delegates `atomic-planner` for an item whose feature folder also exists in other worktrees, which is the normal state once a folder has merged. The payload is an `Agent` tool input whose `subagent_type` is `atomic-planner` and whose prompt cites the folder `docs/features/active/2026-09-13-synthetic-target-672` and carries a canonical issue-number line naming issue `901`.

Both the folder and the issue number are synthetic. A real one is deliberately not used, so that neither this artifact nor the run that produced it carries an identity signal for a live item.

## Control 1 — deterministic, acceptance-bearing

The injected resolution is built by `New-WorktreeResolutionTargetResult` with `Status` `Ambiguous`, `SessionRoot` `/synthetic-worktrees/coordinating-session`, `Signal` `FeatureFolderPath`, `SignalValue` the cited folder, an empty candidate list, and the detail `modelled multi-worktree placement of a merged feature folder`. It stands for the twelve-worktree placement the field observation recorded. Nothing about the host is read, so the control is deterministic.

| Observation | Value |
| --- | --- |
| `permissionDecision` | `deny` |
| Reason contains the value of `Get-WorktreeResolutionAmbiguityReasonCode` | True |
| Reason contains `is missing:` | False |

Reason, verbatim:

```
PRD_FEATURE_BLOCKED: TARGET_WORKTREE_AMBIGUOUS - modelled multi-worktree placement of a merged feature folder. Cite the target feature folder as an absolute path inside exactly one worktree so the gate can verify its prerequisites where the work actually lives.
```

This is the defect in one line. The delegation is refused, and the remedy the gate prescribes is to cite the folder as an absolute path inside exactly one worktree — an instruction that is host-dependent by construction and that a coordinating session cannot satisfy portably. The deny is a resolution failure, not a document failure: `is missing:` is absent, so no prerequisite was found wanting.

After the migration, the same call resolves by its canonical issue line to the one live worktree whose checkpoint records that issue, probes the prerequisites beneath it, and is allowed. `[P9-T9]` row 1 asserts that verdict.

## Control 2 — OBSERVATION ONLY, NOT AN ACCEPTANCE CONDITION

The same entrypoint was called with no injected resolution, letting the shipped folder-first derivation run against this host.

| Observation | Value |
| --- | --- |
| `permissionDecision` | `deny` |
| Reason contains the ambiguity code | True |
| Candidate count reported in the reason | none reported |

This control is labelled observation only because its outcome depends on how many checkouts of this repository exist on the running host. The reason string for this path does not render a candidate count, so none is recorded; that is a property of the reason template, not a failed measurement. No path is recorded from this control.

## Field observation, 2026-09-18

The plan's established facts record a direct observation of the same case on a real tree: a coordinating session delegating `atomic-planner` for an item whose feature folder had merged matched **twelve** candidate worktrees and was denied with the ambiguity code. Twelve is not a pathological number — it is the ordinary count of checkouts branched from `main` on that host — which is what makes the case the ordinary case rather than an edge case.

Output Summary: Both acceptance conditions hold. Control 1 records `permissionDecision` `deny` with a reason containing the ambiguity reason code and not containing `is missing:`, and is deterministic because the resolution is injected rather than derived. Control 2 records a decision value and a boolean and is explicitly labelled `OBSERVATION ONLY, NOT AN ACCEPTANCE CONDITION`. No path other than the synthetic literals and repository-relative paths appears anywhere in this artifact.
