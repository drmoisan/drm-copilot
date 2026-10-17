---
name: remediation-handoff-atomic-planner
description: 'Reusable remediation trigger and atomic_planner handoff steps. Use when audits require remediation inputs and a delegated remediation plan.'
---

# Remediation Handoff to atomic_planner

Shared remediation workflow and handoff expectations for agents that delegate to `atomic_planner`.

## When to Use This Skill

Use this skill when:
- Audit findings require remediation.
- You must create remediation inputs and delegate plan creation to `atomic_planner`.

## Trigger Conditions (Generic)

Trigger remediation when any of these are true:
- Audit artifacts contain FAIL or meaningful PARTIAL findings.
- Toolchain checks fail.
- Acceptance criteria are not met.

## Required Remediation Inputs

Create `remediation-inputs.<timestamp>.md` with:
- Enumerated fix list with file paths, expected behavior, and verification commands.
- A “do not do” list (no scope creep, no policy weakening, no silent skips).
- Exactly one mode line, `Remediation-Mode: proportionate` or `Remediation-Mode: design`. The cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; otherwise it is design. CI-failure findings are normally proportionate.

Proportionate cycle: one `atomic_planner` delegation writes a short plan with a `## Pre-Mortem` section and a final self-review task, and one `atomic_executor` delegation runs single-pass preflight with in-place trivial fixes and then executes it; `preflight: {iterations: 1, final_status: "clear"}` is recorded before `execution_status`. A substantive preflight defect stops that run with `BLOCKED at preflight (before [P0-T1])` and no checked task, and the cycle converts to design mode (the mode line is rewritten to `Remediation-Mode: design`) for one planner revision. Design cycle: the handoff below runs with the at-most-one-return rule.

## Plan Creation and Handoff

1) Create a remediation plan target file using the repo’s plan template.
2) Delegate to `atomic_planner` with:
   - `${spec}` pointing to remediation inputs (authoritative)
   - `${file}` pointing to the remediation plan target file
3) Require `atomic_planner` to output a deterministic, atomic plan with phases and `[P#-T#]` IDs.
4) Require the same `${file}` path to be updated in place across all remediation-plan revisions in the same remediation loop.
5) The caller owns the downstream clearance step:
   - hand the resulting remediation plan to `atomic_executor` in preflight-validation mode, with the preflight directive in the delegation prompt and never in the plan file; preflight is single-pass and fixes trivial defects in place,
   - if preflight returns `PREFLIGHT: REVISIONS REQUIRED`, re-delegate to `atomic_planner` once against the same `${file}` path with the full `PREFLIGHT-DEFECT:` list, then run one confirming preflight,
   - if the confirming preflight still reports a substantive defect, record `final_status: "blocked_preflight_iteration_limit"` and halt the cycle,
   - execute the remediation plan only after `PREFLIGHT: ALL CLEAR`.

## Context Package (When Required)

If the calling agent requires a context package, inline the specified audit artifacts, PR context artifacts, and any relevant plan files in the delegated prompt.
