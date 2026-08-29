# Code Review — atomic-preflight-convergence (Issue #586)

- Date: 2026-08-29
- Reviewer: feature-review
- Branch: `feature/atomic-preflight-convergence-586`
- Base branch: `origin/main`
- Merge-base SHA: `1ff27b874154405f22001ad8e1e34062bbec625f`
- Branch head SHA: `0ad354c12b351ea2972dcd2a11718a60989dbf3b`
- Scope: full branch diff vs merge-base — 24 files, +1450 / -0, all `.md`

## Executive Summary

This is a documentation-only change to two Claude skill-contract files plus their two byte-identical bundled mirrors. It adds four blocks of contract prose intended to reduce preflight round counts in the atomic-planner / atomic-executor remediation loop.

The change is well constructed on the dimensions that matter for a contract document. Every added rule states its failure mechanism rather than asserting a preference, which makes each rule auditable by a later reader. Every added block that touches an unchanged sibling statement explicitly names the statement it extends — the convergence paragraph names the two-value signal bullet it does not replace, and the iteration ceiling names both the three-value enumeration it extends and the repeat-until-clear behavior it bounds. That is the correct technique for an additive-only edit to a contract whose sibling lines cannot be reworded, and it is applied consistently.

The change is strictly additive (0 deletions in all four production files), both bundled mirrors are byte-identical to their targets, and the added prose complies with `.claude/rules/tonality.md` — which is a meaningful result here, since the change itself adds a rule requiring delta prose to satisfy the policy it enforces.

Four findings are recorded. None is a Blocker. The most consequential (F1) is that `.claude/agents/atomic-executor.md` restricts preflight to "format and structure validation" only, which excludes the content-level delta self-check that is this feature's primary mechanism for closing the failure class it targets. That conflict is documentation-level — no hook, validator, or test rejects the new behavior — and the issue author declared it out of scope in advance. It requires a follow-up issue rather than a change to this branch.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| High | `.claude/agents/atomic-executor.md` | line 87 | The agent definition restricts preflight to "perform **only** format and structure validation". The revised contract requires the executor to check its delta prose against every rule the plan enforces, including `.claude/rules/tonality.md` — a content-level check the word "only" excludes. Both documents are loaded together, since the agent preloads the `atomic-plan-contract` skill (frontmatter line 27), so the executor receives two mutually exclusive instructions about the same mode. | File a follow-up issue to replace "only format and structure validation" with wording that admits the content-level delta self-check, and update the bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` in the same change. Do not widen this branch. | Failure class 2 in the issue's Problem statement — a policy-compliance fix whose own prose violates the policy it enforces — is closed specifically by the delta self-check at `SKILL.md:170`. If the executor honors the agent file's "only", that mechanism does not fire and the feature's benefit is partially unrealized. | `.claude/agents/atomic-executor.md:87`; `.claude/skills/atomic-plan-contract/SKILL.md:170`; agent frontmatter line 27 lists `atomic-plan-contract` under `skills:`; `issue.md:45` declares the tension out of scope. |
| Medium | `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-planner-output.ps1` | lines 151 and 109 respectively | The branch adds three MUST-carry signal lines (`SELF-REVIEW: RE-DERIVED THIS PASS`, `CONVERGENCE: NO FURTHER ROUNDS EXPECTED`, `CONVERGENCE: FURTHER ROUNDS LIKELY`) with no corresponding hook assertion, while their sibling `PREFLIGHT:` signals are enforced by both hooks. An agent that omits the new lines produces output that both hooks accept. | Add presence assertions for the new signals to both hooks in the same follow-up as F1, with tests under `tests/scripts/claude-hooks/`. | This repository already treats a gate that cannot fail as a defect class in its own right (`.claude/rules/plan-acceptance-gates.md`). A required signal with no enforcement is advisory in practice, so the two-round convergence bar this feature introduces currently has no mechanical backstop. | `.claude/hooks/validate-executor-output.ps1:151` matches only `^\s*PREFLIGHT:\s*(ALL CLEAR\|REVISIONS REQUIRED)\s*$`; `.claude/hooks/validate-planner-output.ps1:109` applies the same pattern; neither file contains the string `CONVERGENCE` or `SELF-REVIEW`. |
| Medium | `.claude/agents/orchestrator.md` | lines 104 and 144 | Both lines state `preflight.final_status` "is one of `{clear, changes_requested, pending}`" as a closed set. `remediation-handoff-atomic-planner/SKILL.md:113` instructs the orchestrator to record a fourth value, `blocked_preflight_iteration_limit`. The orchestrator is the agent that writes this field, and its own definition tells it the set is closed at three. | Extend the enumeration at both lines in the follow-up issue, and mirror the edit into `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`, which carries the same text at the same two line numbers. | Verified to be documentation-level only, so it is not urgent: no code enforces the enumeration. Left unreconciled, however, an orchestrator that reads only its agent definition has no instruction covering the iteration-ceiling case, which is the terminating condition the feature adds. | `.claude/agents/orchestrator.md:104,144`; `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:113`; `scripts/dev_tools/validate_orchestrator_state.py:190` compares only `preflight_status != PREFLIGHT_CLEARED_STATUS` and does not enumerate permitted values, so the fourth value passes validation. |
| Low | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | line 86 | `### Cycle-Document Sweep Scope` names four cycle documents (`remediation-plan.md`, `code-review.md`, `feature-audit.md`, `policy-audit.md`). The `## Required Artifacts` section it sits under defines a cycle as exactly five artifacts; the fifth, `remediation-inputs.md`, is not named in the sweep scope and its exclusion is not explained. | Consider naming the fifth artifact in a future revision, or state explicitly why it is excluded. No change to this branch: acceptance criterion 4 enumerates exactly the four documents present, so the implementation matches its criterion. | `remediation-inputs.md` is orchestrator-authored prose and can carry the same self-referential rule violation the subsection exists to catch, so a sweep that skips it leaves a gap of the same kind, in the one cycle artifact the subsection does not cover. | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:86` lists four documents; the same file at lines 67-73 defines the five-artifact cycle including `remediation-inputs.md`; `issue.md:33` (AC 4) enumerates the same four. |
| Informational | `.agents/skills/`, `.github/skills/` | both skill paths | The Codex and Copilot surfaces carry separate copies of both skills that this branch does not update, so those runtimes retain the pre-change convergence behavior. | No action on this branch. | Not a parity break: the copies were already divergent at the merge-base, so they are surface-specific adaptations rather than mirrors, and the file set this branch touches matches the two most recent substantive changes to the same contract. | Merge-base blob hashes differ across surfaces for `atomic-plan-contract/SKILL.md`: `e3b2198e` (`.claude/`), `3ed1f086` (`.agents/`), `90bab03b` (`.github/`). Commits `88e7d5fc` (#519) and `04488789` (#486) each touched only `.claude/` plus the claude-customizations mirror. |

## Positive Observations

These are recorded because they are non-obvious choices that a later maintainer should preserve rather than simplify away.

1. **Additive-only reconciliation is done correctly and consistently.** The constraint at `issue.md:43` forbids weakening any existing rule, which means sibling statements contradicted by the new text could not be reworded. The change resolves this by having each new block name the statement it extends: line 178 states the convergence line "is not a third value of the signal set that the `Require one of the exact signals:` bullet above enumerates"; line 113 states the fourth status value "extend[s] the `clear|changes_requested|pending` enumeration stated above" and separately that the ceiling "bounds the repeat-until-clear behavior stated above it". Both files are internally consistent as a result, with zero contradictions across 28 headings.

2. **Every rule carries its failure mechanism.** Each added bullet explains why the rule exists in operational terms — "sibling invalidation" at line 149, "round inflation" at line 169, "self-referential rule violation" at line 86. This makes the rules auditable and lets a future reader judge edge cases rather than apply them literally.

3. **The delta self-check rule satisfies itself.** Line 170 adds a requirement that a fix's own prose comply with the rule it enforces. The 38 added lines were read against `.claude/rules/tonality.md` and contain no hyperbole, humor, or decorative metaphor. A change that introduced this rule while violating it would have been the exact defect it describes.

4. **Cross-file reference by pointer rather than restatement.** Line 109 of the remediation-handoff file points at the `## Preflight Validation (Planner ↔ Executor)` section of the plan contract and states the rules "are not restated here", avoiding a duplicated contract that would drift. The referenced heading was verified to exist at line 156 of the target file.

## Typed-Python Review

Not applicable. No Python file appears in the branch diff. The pytest module executed during this review (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) is pre-existing and unmodified on this branch.

## Blockers

None.

The High-severity finding F1 is not a blocker for this branch. Three facts support that classification, and each was verified rather than assumed:

1. No acceptance criterion fails. Criterion 5 scopes internal consistency to the two skill files, and both are internally consistent.
2. The conflict was declared out of scope in advance at `issue.md:45`, with the carve-out "unless required for internal consistency". Under the issue's own usage of that phrase in criterion 5, the carve-out does not trigger.
3. No runtime failure results. The SubagentStop hooks are presence-based, the orchestrator-state validator does not enumerate `final_status` values, and the payload-parity suite passes 10/10.

The correct disposition is a follow-up issue covering F1, F2, and F3 together, filed before the next remediation cycle depends on the new preflight behavior.
