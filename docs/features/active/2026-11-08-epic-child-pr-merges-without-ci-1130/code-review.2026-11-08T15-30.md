# Code Review: Epic-Child PR Merges Without CI (Issue #1130)

- **Branch:** `bug/epic-child-pr-ci-required` @ `03d222c55e3724bbd1d92db549e0017d02c306be`
- **Base:** `main`, merge base `cdcff3871765396183590128e142a929cf78327b` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff, 66 files
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **The gate is not weakened, and every stage fails closed.**
  - Stage 1: a non-integer `pr_gate.pr_number`, a mismatch between the command number and the recorded number, and a bare command with no recorded number each deny.
  - Stage 2: an absent `ci_gate`, a conclusion other than exactly `success`, and a head that is not a lowercase 40- or 64-character id each deny.
  - Stage 3: a failed, non-zero, unparseable, or malformed `gh pr view` result returns `$null` and denies; a live head that differs from `ci_gate.head_sha` denies.
  - Stage 4: a failed or non-array `gh run list` result denies; no run named exactly `CI` on the head denies; a matching run with an unreadable `createdAt` denies.
  - Stage 5: the newest `CI` run must be `pull_request` or `workflow_dispatch`, `completed`, and `success`; a `push` run denies.
  - Stage 6: a `workflow_dispatch` run must carry the id recorded in `ci_gate.dispatch_run_id`; any other dispatch run denies.
  - The entry catches an unexpected error and returns a deny, so the helper never throws.
- **No fall-through.** In both gates the child branch returns a deny decision directly when the helper does not verify. The Claude rows assert zero reads of the epic and parallel checkpoints; the Codex rows supply an epic checkpoint that would allow PR 42 and still observe a deny.
- **Ordering.** The #1097 review guard decision still precedes the child branch in both gates, and both review helpers are unchanged. A failed dot-source of the new helper registers through `Add-HookDependencyFailure`, which both gates check first.
- **No Python.** Neither the helper nor either gate invokes Python.
- **Real-process probe.** The helper, dot-sourced with `hook-docs-only-diff.ps1` and run with real `gh` against merged PR #1124, resolved the live head, parsed `createdAt` as `System.DateTime`, selected the `CI` `pull_request` run, and returned `Verified=True`. This confirms the field names and parsing that the mocked tests assume.
- **Mirrors.** Four helper copies share one SHA-256; both gates equal their bundle copies; skill, rule, and brief bundle copies equal their sources; the six brief copies share one SHA-256; the frozen pin equals the skill digest.

One blocking finding, F1: the Codex `ci-workflows` skill text that carries the `epic/**` trigger requirement is in no Codex pack manifest, so push-down does not deliver it, and its statement that destinations receive it through push-down is inaccurate.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; `.agents/skills/ci-workflows/SKILL.md` | Codex `core.json` `paths`; skill section `## Epic Integration-Branch Trigger (Required When Epic Branches Are Used)` | F1. The new section requires `epic/**` in the `CI` workflow trigger and states "Destination repositories receive this rule only through push-down, so a destination needs a push-down refresh before it applies." The file is in no Codex pack manifest; `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` lists it in `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`, and that module documents that `compute_published_paths()` publishes only manifest-listed files. A push-down refresh therefore never delivers this guidance to a Codex destination. The Claude rule `.claude/rules/ci-workflows.md` is in the Claude `core.json` and is delivered. | Add `.agents/skills/ci-workflows/SKILL.md` to the `paths` of `codex-and-agents-customizations/pack-manifests/core.json` and remove it from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`; then run the pytest gate (manifest completeness, dependency closure, bundle parity). If the owner prefers not to ship the skill, correct the sentence in the skill and its bundle copy to state that Codex destinations do not receive it. | The issue's intent is that destinations learn to add `epic/**` to their trigger. The branch delivers that guidance by text alone, so the text must reach the destination and describe its own delivery accurately. The gate still fails closed without it, and the dispatch fallback in the pushed-down `.agents/skills/orchestrate/SKILL.md` still gives a legitimate path, so this is not a gate weakness. | `grep -n ci-workflows` over both pack-manifest directories (Claude `core.json` line 119 only); `sed -n 94,130p` of the completeness test |
| Minor | `.codex/hooks/enforce-epic-merge-gate.ps1` | `Invoke-CodexEpicMergeDecision`, `Test-CodexChildMergeReady` branch | CR2. When the repository root holds a ready epic-child checkpoint for PR 43 and the command names PR 42, the Codex gate now denies at stage 1 and does not reach the epic or standalone branch. The Claude gate's existing binding predicate makes the same case fall through to later branches. Before this change the Codex gate allowed that merge regardless of PR number. | None required for this item. If Codex epic roots can hold a child checkpoint, consider binding the Codex child branch by PR number, as Claude does, in a later item. | The spec directs this behavior (`RGC-CHILD-CI-STAGE1-PR-MISMATCH`), and it fails closed. Recorded so the runtime difference is known. | Codex suite row `RGC-CHILD-CI-STAGE1-PR-MISMATCH`; Claude direct row comment "through the gate Test-ChildCheckpointPrGateBinding rejects this first" |
| Minor | `.claude/skills/orchestrate/SKILL.md`; `.agents/skills/orchestrate/SKILL.md` | `## Step S9 — CI Green Gate`, dispatch fallback | CR3. After the dispatch, S9 polls through `gh pr checks`. The spec lists as an assumption "to be confirmed during execution" that `gh pr checks` lists the check runs of a `workflow_dispatch` run on the PR head; no evidence artifact records the confirmation. The reviewer found no dispatched run on a current PR head in this repository to probe. | On the first epic run after release, record whether `gh pr checks` shows the dispatched `CI` checks; the spec's `## Rollout & Follow-up` already names this check. | If the assumption fails, S9 stays `pending` and the child blocks; the merge gate itself reads `gh run list`, which the reviewer confirmed against real data. The failure mode is a stall, not a weaker gate. | `research.2026-11-08T13-40.md` line 67; `gh run list --workflow CI --event workflow_dispatch` (dispatched heads differ from current PR heads) |
| Nit | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and five other existing suites | Branch-1 allow rows | CR4. Several existing suites mock the entry `Get-EpicMergeGateChildCiDecision` to `Verified` instead of the two seams. The plan (P3-T3, P3-T5) allows either, and each mock carries a stated reason; no assertion was removed or weakened. | None required. | These suites test other behavior; the two new suites cover the helper. | Diff of the existing suites; plan P3-T3 and P3-T5 |
| Nit | `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | C11 | CR5. The load-failure case covers the Claude gate only. The Codex gate uses the same guarded pattern, which `hook-dependency-guard-completeness.Tests.ps1` checks statically, but no row drives a Codex load failure of the new helper. | Optional: add the Codex counterpart in a later change. | The pattern is shared and statically checked, so the gap is small. | Diff of the SpecialCases suite |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `.claude/hooks/enforce-epic-merge-gate.ps1` and its bundle copy at 500 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Helper

`Get-EpicMergeGateChildCiFailureDetail` evaluates the stages in the order the spec states, and each `return` names its stage. Comparisons use case-sensitive operators (`-cne`, `-ceq`, `-cnotcontains`), so `ci`, `Success`, or `Pull_Request` do not pass. `Test-EpicMergeGateChildCiPositiveInteger` accepts `[int]` and `[long]` only, so a digit string, a float, and zero are rejected; the probe confirmed that an 11-digit run id parses as `Int64` and is accepted. `Select-EpicMergeGateChildCiRun` filters on exact `CI` and exact head before ordering, orders by `createdAt` then `databaseId`, and refuses the whole selection when a matching entry has an unreadable timestamp. `Get-EpicMergeGateChildCiRunList` uses `-NoEnumerate` and requires an array, so a single object or `null` document denies, and `[]` yields an empty selection and a stage 4 deny.

### Gate wiring

The Claude gate passes `$sessionRoot` as the gh root and the item checkpoint from the resolved item worktree. `gh pr view <number>` resolves the same repository from either root, so the root choice does not change the result. The Claude gate grows to 500 logical lines, which is the cap of `session-root-reads-850.Constraints.Tests.ps1`; any later line added to it requires a split first.

### Skill and rule text

The S9 dispatch fallback, `ci_gate.dispatch_run_id` schema entry, step 6 gate statement, `epic-orchestrate` paragraph and fan-in step 6, `epic-run` pointer, orchestrator-state section, and brief bullets agree with the helper's behavior. The `epic-run` pointers name the heading under which each `epic-orchestrate` copy places the paragraph (`## Merge-on-Green Kickoff Parameter` in `.claude`, `## Fan-In and Conflict Handling` in `.agents`); the reviewer confirmed both headings.

### Push-down statement (caller focus 5)

The statement "no file in this repository writes a destination CI workflow trigger" is accurate: a search of `extensions/drm-copilot/src`, `scripts`, `packages`, `.claude/lib`, `.claude/skills`, and the bundles for a `pull_request:` writer found none. The statement that the push-down obligation is carried by pushed-down rule and skill text is accurate for the Claude runtime only. The Claude rule is delivered, but it is path-scoped to `.github/workflows/**`, so an agent loads it only while editing a workflow file; nothing prompts a destination to add the trigger after a refresh. The Codex skill is not delivered at all (F1). The brief and orchestrate text that is delivered to both runtimes describes the dispatch fallback but not the trigger requirement.

### Security and correctness

gh arguments are passed as an array to the existing wrapper, and no string is evaluated. No secret or credential is added. The residual race (a push after the live-head lookup) is disclosed in `.claude/rules/orchestrator-state.md`.

## Recommendation

Fix F1 in a light cycle. CR2 to CR5 need no change in this item.
