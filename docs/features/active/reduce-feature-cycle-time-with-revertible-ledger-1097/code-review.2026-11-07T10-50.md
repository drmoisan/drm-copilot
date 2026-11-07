# Code Review: Light Remediation, Stage D (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `72e57cc7dfd4ba78579a2c86887aa0c77d5d9cef`, equal to `origin/main` after a fetch)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `d42515cf7ecf53842908d88bf1c9adf6e0b5c440`
**Review Type:** First review of PR D (stages A, B, and C merged; stage C as PR #1103, merge commit `72e57cc7d`)

---

## Executive Summary

The branch adds the light remediation path (reduction `0003`) and closes two stage C review items on the merge guard (R2 and R3, under reduction `0002`). It also back-fills the merge commit of entry `0002`.

Light remediation has three parts:

- **Validators.** Invariant 8 is added to the Python, TypeScript, and PowerShell validators in one commit (`33b80bd19`). A cycle whose `remediation_path` is exactly `light` is exempt from invariant 2 and is checked by invariant 8 instead. Each runtime holds the rules in one small pure function that receives the existing R11 predicate, so the predicate is not duplicated and no import cycle arises.
- **Corpus.** Fourteen new rows in the shared corpus `tests/fixtures/orchestrator_state_remediation_loop/` pin each rule in all three runtimes. No existing row changed.
- **Skill and agent text.** The review, orchestrate, rule, and agent copies state the threshold, the `Remediation-Path` and `Finding-Scope` lines, the `## Light Fix Tasks` section, and the D9 route.

The guard change caps the Claude shape read at the first 4 candidate numbers and corrects the header sentence that R2 found inexact.

The reviewer verified the main claims by execution, not by inspection alone:

- An 18-probe corpus ran through the public entry point of each runtime. The three runtimes agreed on 15 probes. The 3 that differ belong to two classes the branch did not introduce (N1, N2).
- The Python CLI route of D9 accepted `light_valid_accepted` and rejected `light_preflight_present` and `light_consecutive_light`, each with exit 1, so the route is not a no-op.
- A replay of the 37 revert blocks of entry `0003` reproduced the text of all 17 paths at the reduction commit's parent `86639cc5e`.

No Blocker. Two Minor items and two Nits follow; none stops the merge.

**What changed well:**
The invariant 2 exemption is one condition per runtime, keyed on the exact ordinal string, so a case variant or `null` keeps invariant 2 and also gets rule 1 (`path_value_case_variant`, `path_value_null`). Invariant 8 runs last in the accounting stage, so every existing message keeps its order, and a cycle without the key reaches no new rule. Rule 3 gates rules 4 to 6, so a light cycle with no valid opening review reports one error and does not index into an invalid outcome. The PowerShell port tests `-is [string]` before `-ceq` throughout, which avoids the array-filtering form of `-ceq`. The entry's `## Revert Steps` name the generator `--check` and the three corpus floors, so a revert does not depend on `git revert`.

**Top 3 risks:**
1. N1: the PowerShell port reads checkpoint keys without regard to case, through the unchanged helper `Get-CheckpointObjectMember`. A mis-cased `Remediation_Path` or `Scope` key is honored by the PowerShell stop hook and ignored by Python and TypeScript.
2. The guard copies are at 699 logical lines, one below the 700-line advisory tier. The next addition to the guard crosses it.
3. The installed MCP release (D9) lacks invariant 8. On Claude, the light path therefore depends on the orchestrator using the repository Python CLI for the detection step. The skill text states this, and the stage D route evidence shows the installed MCP rejecting the same checkpoint.

**PR readiness recommendation:** **Ready.** No code change is required before the pull request. CI run 42364201139 on this head was `in_progress` when this review was written, and S9 owns its conclusion.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` (through `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1`, unchanged) | `Get-RemediationLightCycleError`; `Get-RemediationCycleError` in `OrchestratorStateReceipts.psm1`; `Get-CheckpointObjectMember` | N1. Key lookup in the PowerShell port is not case-sensitive, because `Get-CheckpointObjectMember` tests presence with `-contains` and reads with `$Owner.$Name`. Invariant 8 inherits this. A cycle carrying `Remediation_Path: "light"` and no preflight passes the PowerShell validator, while Python and TypeScript report the invariant 2 error. A finding carrying `Scope: "contained"` passes PowerShell, while Python and TypeScript report `finding #0 scope is not contained.` | Add two corpus rows (mis-cased cycle key, mis-cased finding key) so the class is pinned, and either make the helper ordinal (`-ccontains` plus an exact-name property read) or record the class as a known exclusion in `.claude/rules/orchestrator-state.md`. | The helper is not in the branch diff, so the class pre-dates this branch and already applies to `execution_status`, `preflight`, and every other key. The orchestrator writes exact keys, so a truthful checkpoint validates the same in all three runtimes, and the criterion's byte-identical strings hold. The direction is permissive on the stop hook, which reads the PowerShell port. Remediability class if pursued: `autonomous`. | Reviewer probe through each public entry point: `validate_orchestrator_state_text`, `validateOrchestratorStateText` bundled with esbuild, and `Get-OrchestratorStateUnconditionalError` in a fresh `pwsh`. Probes `cycle_key_case_variant` and `finding_scope_key_case_variant`. |
| Minor | `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` | `opensRemediationReview` (R11 predicate reused by invariant 8) | N2. `opened_by_review: 0.0` passes TypeScript and fails Python with both the R11 and the invariant 8 rule 3 messages. PowerShell agrees with TypeScript. | None required. Optionally list the class in the rule next to the R11 text. | This is the known integral-float class: `JSON.parse` cannot tell `0.0` from `0`. It pre-dates the branch in R11 and cannot be fixed on the TypeScript side. Remediability class: none; record only. | Probe `opened_by_review_float`. |
| Nit | `.claude/hooks/enforce-epic-merge-gate-review.ps1` and its three copies | Whole file | N3. Each copy is 699 logical lines (`@(Get-Content).Count`), one below the 700-line advisory tier. No Warning row applies. | Place stage E to I guard logic in a new sibling, or split the scanner helpers out before the next addition. | The 500-line guidance tier is passed. The next added line produces an advisory Warning. Remediability class: none. | Reviewer line count over the 25 changed covered files. |
| Nit | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `.github/agents/orchestrator.agent.md`, and their copies | Mode-line sentence | N4. These still state `Remediation-Mode: proportionate` or `Remediation-Mode: design` only, while the orchestrate skill now names three values. Under the Claude contract a light cycle never reaches the handoff, and a fallback rewrites the line to `design` first, so no run breaks. The Copilot orchestrator ignores a reviewer's `Remediation-Path: light`, which moves the cycle heavier, as the skills allow. | Add the light value to the handoff skill's sentence when stage E lands the deferred wording, and record it in entry `0003` in that commit (K3). | Wording consistency only. Remediability class: none. | `git grep` of `Remediation-Mode` across the four surfaces. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. `config/file-size-baseline.json` is not in the branch diff.

### Prior findings (stage C review `code-review.2026-11-07T08-55.md`)

| Finding | Status | Evidence |
|---|---|---|
| R2 Read cost without the key | Closed | `$script:EpicMergeGateReviewCandidateCap = 4`. The rows `RG-SHAPE-CANDIDATE-CAP-BOUNDS-READS` (reads `11,12,13,14` only), `-SKIPS-KNOWN-NUMBER`, `-KEY-WITHIN-CAP-DENIES`, `-KEY-PAST-CAP-DISCLOSED`, and `-NOKEY-KEEPS-DECISION` each fail if the cap is removed or moved. The header now says the guard "starts no gh call" and names the capped Claude read. Candidates are distinct before the cap (`Get-EpicMergeGateReviewCandidatePrNumber`), so a repeated number does not use a slot. |
| R3 Trigger over-match | Closed by disclosure | D10, the rule, the guard header, and entry `0002` name `pr (#12)`, `pr $HOME`, and the trailing line feed or `;`. Shared rows `overmatch-*` pin the decisions in both runtimes. |
| R1 Brace and argv forms | Carried, owner-level | Not changed in stage D. The prior review graded the forms as inside the D10 limit on run-time composed text; that reading is still with the owner. |
| F2 Token mismatch on two stage C commits | Carried | Disclosed in entry `0002`; it cannot be corrected without a forced push. |

---

## Python

**What changed well:** `_orchestrator_state_light_cycle.py` is 190 lines of pure functions. It is called last from `_validate_remediation_accounting` with the R11 predicate passed in. `__all__` of the loop module is unchanged.

**Typing and API notes:** `validate_light_cycles(cycle_list, outcomes, opens_review)` takes `Sequence[object] | None`, `object`, and `Callable[[object, object], bool]`, with `TYPE_CHECKING` imports. The `cast` calls in `_opening_findings` rely on the predicate having proved the index. That is correct as called. A direct caller that passes a predicate which accepts `True` would index position 1, which the docstring rules out.

**Error handling:** none needed. Malformed shapes yield messages, and nothing raises.

Black, Ruff, and Pyright are clean on the four changed Python files (reviewer run). Coverage: 56 of 56 lines and 28 of 28 branches on the new module, and 140 of 140 and 74 of 74 on the loop module.

## TypeScript

**What changed well:** `orchestrator-state-light-cycle.ts` mirrors the Python order and message text, and it does not import the remediation module. `jest.config.cjs` adds its own threshold entry at 85 and 75.

**Type safety:** `unknown` is narrowed with `isObject` and `Array.isArray`, with no type assertion. The two branches not run (lines 78 and 79, the narrowing in `openingFindings`) cannot be reached after rule 3 has passed.

Prettier, ESLint, and `tsc -p tsconfig.jest.json --noEmit` exit 0 (reviewer run). Coverage: 193 of 193 lines and 35 of 37 branches (94.59%) on the new module, and 297 of 297 and 59 of 59 on `orchestrator-state-remediation.ts`.

## PowerShell

**What changed well:** `Get-RemediationLightCycleError` is a private function in the existing accounting module, so no manifest, export list, or pack entry changed. The function is an advanced function with `CmdletBinding`, `OutputType`, and `AllowNull` parameters. The guard cap is one filter and one `Select-Object -First`.

**Safety:** both runtimes are unchanged for a cycle without the key. The four guard copies and the two module bundle copies are byte-identical to their sources (`cmp`).

PSSA with the repository settings and `Invoke-Formatter` report 0 findings and 0 differences on the 12 changed non-bundle PowerShell files (reviewer run). Coverage: 100% on both modules (123 of 123 and 146 of 146 lines), 99.39% on the Claude guard, and 92.64% on the Codex guard. The one Claude guard line not run (641) is the `catch` assignment of the best-effort read, which stage D did not change.

## C#

No C# file changed.

---

## Test Quality

- **Corpus discrimination.** Each invariant 8 rule has a row that fails without it:
  - rule 1: `path_value_null` and `path_value_case_variant`;
  - rule 2: `light_preflight_present`;
  - rule 3: `light_opened_by_absent` and `light_opened_by_halt_outcome`;
  - rule 4: `light_four_findings`, with `light_three_findings_accepted` at the boundary;
  - rule 5: `light_non_autonomous_finding`;
  - rule 6: `light_design_scope` and `light_absent_scope`;
  - rule 7: `light_consecutive_light`;
  - the invariant 2 exemption: `light_valid_accepted` and `full_no_preflight_fails_invariant_2`.
- **Probes.** The reviewer ran 18 further probes through all three runtimes' public entry points. They covered a boolean, negative, and string `opened_by_review`; `preflight: null`; a trailing space, array, or number as `remediation_path`; non-list and non-object findings; four mixed findings; a non-object or case-variant prior cycle; a light, full, light sequence; and an `in_progress` light cycle. All agreed except the N1 and N2 classes.
- **Executor stop hook.** `validate-executor-output.LightRemediation.Tests.ps1` drives the unchanged hook with an inputs file as the plan path through two seams, `Get-PlanFileContent` and `ReadTranscriptHead`.
- **Skill contract.** `light-remediation-skill-contract.Tests.ps1` (74 cases) pins the threshold, the heavier-only rule, and the Claude CLI route and Codex unavailability statements in every copy.
- **Gap.** No row pins the N1 key-casing class. Under the owner's rule of one parallel run per gate, no mutant suite was run. Discrimination was judged by inspecting each row against the rule it names, and by the probe set.

## Security and Correctness

No command text is executed. The merge guard's deny surface is unchanged, except that the Claude shape read now resolves at most 4 numbers. D10, the rule, and the guard header disclose that cap.

---

**Review completed by:** feature-review agent
