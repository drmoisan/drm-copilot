# Issue 554 amendment comment (verbatim mirror)

Timestamp: 2026-08-26T12-00
PostedAs: comment
URL: https://github.com/drmoisan/drm-copilot/issues/554#issuecomment-5425395081
RetrievedWith: gh issue view 554 --comments --json comments
Note: reproduced verbatim below. This mirror is read-only evidence; the
authoritative requirement source for work mode full-bug is spec.md.

---

Amendment (2026-08-26, from the maintainer's expanded work request). This issue as originally filed covers only Fault 2. The full defect is two composing faults, and one statement in the original Expected Behavior is corrected below. This change is the structural fix to the gate's decision procedure — the third defect in this hook after #535 and #539, which were both point patches to exemption lists; a fourth list entry is explicitly not the remedy.

## Fault 1 (previously unrecorded) — the delegation classifier is a 7-token substring match over the serialized payload

`Test-ImplementationDelegation` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:182-204`) exempts preparation mode and then falls through to:

```powershell
$payloadText = ($ToolInput | ConvertTo-Json -Depth 20 -Compress)
return $payloadText -match '(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)'
```

Classification therefore depends on prompt wording. `"execution"` does not contain the bare token `execute`; a kickoff phrased with "atomic execution" matches none of the seven tokens and is allowed, while a semantically identical prompt phrased with "execute" is denied.

**Measured evidence (TaskMaster, `quickfiler-bug-family` epic):** four `Agent(orchestrator)` epic-child delegations were denied verbatim on 2026-08-25; four structurally identical delegations were allowed on 2026-08-26 and wave 0 launched. The hook file was byte-identical on both dates; kickoff wording was the only difference. The pass was an incidental classifier miss, disclosed rather than relied on. No prompt was reworded to dodge the classifier, and the fix must not make rewording the remedy. This evidence is the regression case for Fault 1 (test matrix case 6b below).

## Correction to the original Expected Behavior — the caller must not name its own readiness file

The original body asks that readiness be evaluated "against the epic checkpoint the prompt itself names." That is retracted as a gate weakness. Corrected requirement: resolve the readiness source from the recognized mode marker via a fixed table, never from a path parsed out of the prompt. If the prompt-declared `epic_checkpoint_path` / `parallel_checkpoint_path` disagrees with the mode's canonical path, deny.

## Required fix (structural, both faults)

1. **Classify `Agent` delegations by structure, not substring.** `subagent_type` in the implementation-worker set (`atomic-executor`, the four typed engineers) is implementation regardless of prompt wording, read field-scoped via `Get-ClaudeHookToolInputString`. `subagent_type == 'orchestrator'` is implementation unless the field-scoped `prompt` carries a recognized non-implementation mode marker. Free-text tokens `implementation`/`execute` may remain only as a widening backstop that can never narrow a structural decision. Do not add `execution`/`executing` to the token list — that re-blocks every epic without fixing Fault 2.
2. **Polymorphic readiness source keyed on existing contract markers** (reuse verbatim, do not invent):
   - Preparation (`Preparation mode: true.` + `route_id: preparation.`, emitted by epic-plan SKILL.md:99 / parallel-plan SKILL.md:105) — exempt, unchanged.
   - Epic child (`Epic mode: true`, epic-orchestrate SKILL.md:118) — `artifacts/orchestration/epic-orchestrator-state.json`.
   - Parallel item (`Parallel mode: true`, parallel-orchestrate SKILL.md:244) — `artifacts/orchestration/parallel-orchestrator-state.json`.
   - No marker — `artifacts/orchestration/orchestrator-state.json`, unchanged.
   Markers are read from the named `prompt` field only, never the serialized payload — the property `Test-PreparationModeDelegation` already documents at lines 147-180. Precedent: `.claude/hooks/enforce-epic-wave-barrier.ps1` implements exactly this shape on the same `Agent` matcher; reuse its resolution approach so the two hooks agree.
3. **Epic readiness predicate** (new helper): `route_id == 'epic'`; `epic_feature_folder` non-empty; `epic_manifest_path` non-empty under `docs/features/epics/`; `integration_branch` non-empty; `features[]` present and non-empty; the target feature (resolved from the prompt by `feature_folder` or `issue_num`) exists as a record in `features[]`. Optional hardening, state in the PR whether included: require the target record's `merge_status` in a pre-merge state.
4. **Parallel readiness predicate**: mirror against `parallel-orchestrator-state.json` (`route_id == 'parallel'`, `parallel_slug`, `parallel_manifest_path`, non-empty items, target item resolvable). If scoped to epic mode only, say so explicitly and record the parallel gap as a follow-up issue.
5. **Diagnosability**: the block reason (line 328) is a fixed string naming `orchestrator-state.json` regardless of the source consulted. Make it name the checkpoint actually read and the predicate that failed.
6. **File-size cap**: the hook is 381 lines against the 500-line cap; put mode resolution and the new predicates in the existing dot-sourced helpers sibling.

## Non-goals and prohibitions

- Do not widen the seven-token regex as the fix; do not make prompt wording the discriminator in either direction.
- Do not accept preparation-mode literals inside an execution prompt as an escape hatch.
- Do not change the Edit/Write path leg (`Test-ImplementationPath`) or the Bash command leg (`Test-ImplementationCommand`), including the #539 staging exemption.
- Do not remove any checkpoint from the `$script:CheckpointPaths` WRITE exemption.
- Do not fail open on an unreadable envelope or missing checkpoint — deny-by-default is preserved.

## Scope and propagation

Only the `Agent`-matcher leg changes; Edit/Write and Bash legs are behaviorally unchanged, proved by the pre-existing suites passing unmodified. Propagate to all copies: `.claude/hooks/...` and `.codex/hooks/...` (both main and helpers), plus their `extensions/drm-copilot/resources/claude-customizations/` and `codex-and-agents-customizations/` mirrors, keeping each pair byte-identical per surface. After merge, push down to consumer repositories so TaskMaster picks up the fixed hook. Note per #555: `.codex/config.toml` registers no `Agent` matcher, so the epic denial does not manifest on Codex; #555's single-surface readiness for the file/command legs remains a separate issue and is not in scope here.

## Required test coverage (Pester, both surfaces, added to the existing suites)

1. Epic-mode delegation with ready epic checkpoint — allow.
2. Same with epic checkpoint absent — deny; reason names the epic checkpoint.
3. Same with `features[]` lacking the target record — deny.
4. Same with a prompt-declared `epic_checkpoint_path` other than canonical — deny.
5. `Epic mode: true` planted in a non-`prompt` field, prompt clean — not epic mode; falls back to singular source.
6. Wording-independence regression, both directions: (a) `subagent_type: atomic-executor`, prompt with none of the seven tokens, unready checkpoint — deny; (b) `subagent_type: orchestrator`, no markers, prompt containing "atomic execution"/"execution" but not "execute"/"implementation", unready singular checkpoint — deny (the case that incorrectly allows today).
7. Preparation-mode pair still exempt — allow.
8. Standalone orchestrator with ready singular checkpoint — allow; unready — deny.
9. Existing Edit/Write, Bash, absolute-path, and command-exemption suites pass unmodified on both surfaces.
10. Codex surface: the same matrix through the `apply_patch` transport.

## Acceptance criteria

- An epic-child `Agent(orchestrator)` delegation per the epic-orchestrate kickoff contract is allowed when, and only when, the epic checkpoint proves the epic prepared and the target feature is a real, not-yet-merged record in it.
- Reordering or rewording an execution prompt cannot change the gate's decision, in either direction, for any case in the test matrix.
- A denied delegation's reason names the checkpoint actually consulted and the failed predicate.
- Standalone orchestration, planner-surface writes, and the #539 staging exemption are behaviorally unchanged.
