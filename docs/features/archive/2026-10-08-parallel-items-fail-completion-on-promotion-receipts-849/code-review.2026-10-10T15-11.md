# Code Review: parallel-items-fail-completion-on-promotion-receipts (Issue #849)

- Issue: #849
- Branch: bug/parallel-items-fail-completion-on-promotion-receipts-849
- Head: 5cbc47a0c3e846172300fd301af26db0ddfc94db
- Base: origin/main @ 0ea7978a79b2ef5b237043923bff299e2b45cddf
- Diff anchor: `git diff origin/main...HEAD`
- Review timestamp: 2026-10-10T15-11 (UTC)

## Executive Summary

The change is small, symmetric across the three runtimes, and well tested. Each runtime adds a `RECORD_OPTIONAL_ORIGINS` constant and a single early-return guard at the top of the rule-9 helper that applies only when the `potential_record` key is absent and `origin` is a string in the optional set. Key presence is computed with the idiomatic primitive for each runtime (`"potential_record" in adoption`, `Object.prototype.hasOwnProperty.call`, `Get-CheckpointObjectMember(...).Present`), so a present JSON `null` continues to be validated, matching rule 1's treatment of a present `issue_adoption: null`. Error strings, rule order, the rule-8 precondition, and fail-closed behavior are unchanged; the reviewer confirmed that no error literal appears in the production diff.

The skill text changes are targeted: one intake bullet and one conditional delegation line in `parallel-plan`, an extension of kickoff element 4 in `parallel-orchestrate` (no new element), and one-sentence updates in `orchestrate`, `feature-promotion-lifecycle`, and the rule document. The new skill-contract test pins the added text and guards hook-relevant properties (no mode marker, no issue-number shape, no active feature-folder path, unchanged kickoff line, five kickoff elements).

Verdict: **APPROVE**. Blocking findings: 0. Non-blocking findings: 6.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (minor) | extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts | `potentialRecordErrors`, lines 238-243; call site lines 311-318 | The new `recordPresent: boolean` is a positional boolean argument following an `unknown` argument. The Python authority declares `origin` and `record_present` keyword-only, so the call site is self-describing there; the TypeScript call site relies on argument order. | Optionally pass `{ origin, recordPresent }` as an options object in a later change. No action required for this PR. | Positional booleans are easy to transpose; the risk is low because the function is module-private and covered at 100%. | Diff of `orchestrator-state-issue-adoption.ts`; reviewer re-run 100% line/branch. |
| Non-blocking (minor) | .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | `Get-AdoptionPotentialRecordError` param block, lines 287-294 | `-Origin` is optional while `-RecordPresent` is mandatory. If a future caller omits `-Origin`, the guard evaluates `$null -is [string]` as false and rule 9 is enforced, which is the safe default. The asymmetry is acceptable but undocumented as intentional. | No change required; the safe default is correct. | Fail-closed default when origin is not supplied. | Diff of the `.psm1`; Pester case "reports the origin error and rule 9 when origin is invalid". |
| Non-blocking (cosmetic) | .claude/skills/parallel-plan/SKILL.md | Line 154 (`**Collected per child at termination:**` paragraph) | The reflowed paragraph leaves one line at 129 characters while the surrounding text wraps near 100 columns. | Re-wrap in a later documentation edit; must be mirrored to the bundled copy if changed. | Consistency only; Markdown rendering is unaffected. | `awk` length check on the line. |
| Non-blocking (evidence hygiene) | docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-analyze.2026-10-09T01-33.md | Line 9 | States analyzer counts "come from the H1 Source A analyzer output read in P8-T5", but P8-T5 used Source B (CI run 38060952234), which writes no analyzer output file. | Correct the sentence to reference the Source B `AnalyzeStep: success` line in `qa-gates/poshqc-local/run-record.md`. | The substantive result is valid (`Invoke-PoshQCAnalyze` throws on any finding); only the cross-reference is stale. | `ps-test-coverage.2026-10-09T01-33.md` "Analyzer" section; `PoshQC.Analyzer.psm1:181-184`. |
| Non-blocking (evidence hygiene) | docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-coverage-delta.2026-10-09T01-33.md (and ts-/ps-coverage-delta, other/follow-up-parallel-add) | `Timestamp:` lines | Recorded timestamps 15-08 through 15-17 are later than the creation time of the commit that adds the files (5cbc47a0c at 2026-10-10T15:07:07Z). | Record timestamps from the clock at write time. | Evidence timestamps are used to order runs; inaccurate values reduce their audit value. | `git log -1 --format=%cI 5cbc47a0c`. |
| Non-blocking (scope residual) | .claude/skills/parallel-add/SKILL.md | Preparation delegation prompt | `/parallel-add` preparation children for issue-number items do not receive the issue-adoption line. Documented as out of scope (overlap with #843). | File the follow-up item described in `evidence/other/follow-up-parallel-add.2026-10-09T01-33.md` after #843 lands. | The execution child is covered by `parallel-orchestrate` element 4 and the validator relaxation applies to all checkpoints, so the residual is limited to preparation children admitted mid-run. | `spec.md` Out of Scope; follow-up evidence file. |

## Design Review

- **Correctness of the guard.** The guard requires all three conditions: key absent, `origin` is a string, and `origin` is in the optional set. An invalid origin (for example `imported`) produces both the rule-4 origin error and the rule-9 error, which is the conservative outcome and is pinned by a test in each runtime.
- **Parity.** Constant names, guard order, and semantics match across runtimes. The shared corpus now has 34 fixtures (29 baseline + 5 new); all pass in Python, TypeScript, and Pester. The parity floors were raised to 34 in all three readers, which keeps the anti-vacuous-pass guard aligned with the corpus.
- **Fixture immutability.** All five fixture changes are additions (`A`); no existing fixture was modified.
- **Purity.** No I/O was introduced. The spec's decision not to check file existence for `potential_record` keeps the resolver modules pure; the rule document now states explicitly that a record under `docs/features/potential/promoted/` satisfies the path rule because only prefix and suffix are checked.
- **Hook interaction.** The added `parallel-plan` line has no digits, no mode marker, and no active feature-folder path, so preimplementation-gate target resolution and mode classification are unchanged; this is enforced by the new contract tests and by the unchanged `enforce-orchestration-preimplementation-gate.Tests.ps1` results (35 tests, 0 failures in CI).
- **Security / waiver widening.** Relaxing rule 9 removes one audit pointer for `transferred` and `filed_before_orchestration` adoptions. The waiver still requires a read-only verification record (`verified_via`, `verified_at`, `evidence`) and `potential_to_issue` in `waived_tools`; non-waivable tools still need receipts. The spec records this risk. No further mitigation is required for this change.

## Test Quality Review

- Tests cover positive, negative, null, invalid-path, invalid-origin, and preparation-route cases in each runtime, and every test asserts both `errors` and the waived set.
- The skill-contract test reads files inside test bodies only, raises explicit `AssertionError` messages for structural lookups, and uses shared helpers from `parallel_orchestrator_surface_test_support`.
- Regression evidence shows fail-before (Python parity: D1, D2, D3 fail with the rule-9 and missing-receipt errors; skill contracts: 8 of 11 fail) and pass-after in all three runtimes.

## Files Reviewed

- scripts/dev_tools/_orchestrator_state_issue_adoption.py
- extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts
- .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 (and bundled mirror, byte-identical)
- .claude/skills/parallel-plan/SKILL.md, .claude/skills/parallel-orchestrate/SKILL.md, .claude/skills/orchestrate/SKILL.md, .claude/skills/feature-promotion-lifecycle/SKILL.md, .claude/rules/orchestrator-state.md (and bundled mirrors, byte-identical)
- tests/fixtures/orchestrator_state_issue_adoption/ (five added fixtures)
- tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py, test_orchestrator_state_issue_adoption_parity.py, test_parallel_issue_adoption_skill_contracts.py
- extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts, orchestrator-state-issue-adoption-parity.test.ts
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1, OrchestratorStateIssueAdoption.Parity.Tests.ps1
- docs/features/potential/promoted/2026-10-08-parallel-items-fail-completion-on-promotion-receipts.md
- Feature folder evidence under evidence/{baseline,regression-testing,other,qa-gates}
