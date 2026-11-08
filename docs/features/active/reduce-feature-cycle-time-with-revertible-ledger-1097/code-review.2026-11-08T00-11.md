# Code Review: Stage F, G13 Guideline with a Zone-Aware Cutoff (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `1e47be8de2807849576c2f335f99a42488e54055`
- **Base:** `main`, merge base `1850596d9a7a8f092ac2dc3f8ff7461985751685` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff, 52 files, 24 commits; reduction commit `39824bd35`, authorized fix `5a750bf0c`
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **The G13 change is correct and the two runtimes agree.**
  - `plan_file_stamp` and `planFileStamp` read the four K4 shapes and return the zone that `PLAN_STAMP_ZONES` assigns. `plan_size_guideline` and `planSizeGuideline` compare the stamp with its own zone's entry. The message renders the applied pair.
  - The two runtimes use different matching techniques: Python splits the path into segments and uses `fullmatch`, while TypeScript uses anchored regular expressions over the path end. A reviewer probe ran the bundled worktree TypeScript and the worktree Python over 37 adversarial paths, with no divergence. The paths covered trailing separators, embedded line feed and NUL, non-ASCII digits, case variants, doubled separators, a `remediation` prefix that is not a full segment, drive-relative paths, and non-calendar stamps.
- **The cutoff is a single instant.** The reduction commit's author and committer dates are `2026-11-07T23:31:26Z`. New York is UTC-5 on that date, so `18-31` and `23-31` name the same minute. `test_cutoff_value_is_identical_in_rule_file_and_both_validators` pins the three copies and the zone conversion.
- **No older stamped plan changes result.** Across all 636 tracked stamped plan files under `docs/features/`, the head rule and the legacy pair give the same G13 outcome. This agrees with the executor's 146-entry result check, which also covered Epic #1019 plans on every remote ref. The stamp zones agree with the commit history: each `remediation-plan.<stamp>.md` in this folder was first committed within about an hour after its stamp read as UTC (for example, stamp `04-19`, first commit `04:24Z`), and each `plan.<stamp>.md` within about an hour after its stamp read as New York time.
- **K5 holds.** The path reaches G13 by its own parameter in both runtimes, and the TypeScript cases prove it with absent and full wiring.
- **The revert chain holds with `0008`.** The stored patch is byte-identical to a regeneration, `git apply -R --check` exits 0, and the in-memory chain is valid. The chain fails on an edit inside a `0008` hunk or created file and stays green on an edit outside every region.
- **The authorized G5 fix.** It changes no behavior, because `G5_SEVERITY` is the warning value. It does leave the two runtimes structurally different (CR1).

No blocking finding.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | `evaluateLiteral`, final push; `G5_SEVERITY` declaration | CR1. After `5a750bf0c`, the TypeScript G5 finding is pushed to `report.warnings` directly, and `G5_SEVERITY` no longer selects the channel. Python `_evaluate_literal_rules` still selects the channel from `G5_SEVERITY`. The rule file says the G5 severity "is a single constant in each runtime". That remains literally true, but in TypeScript the constant now has no effect on the channel. If a later feature flips both constants after a fresh measurement, Python moves G5 to the blocking channel and TypeScript does not. The G5 rows of `plan-gate-parity.test.ts` would then fail, because they derive the expected channel from `G5_SEVERITY`, so the divergence would not go unnoticed. | Optional: route G5 through a severity-to-channel helper that both values exercise, as `channelFor` does for G11 to G13. Alternatively, add a JSDoc sentence to `G5_SEVERITY` stating that a change to it must restore the channel choice in `evaluateLiteral`. | Non-blocking. The behavior is unchanged and a flip would be caught by tests. The fix was made to satisfy the plan's whole-file "not below baseline" condition after a V8 branch-count shift, which policy did not require: policy requires no regression on changed lines. | `git show 5a750bf0c`; `scripts/dev_tools/plan_gate_discrimination.py` channel choice; `.claude/rules/plan-acceptance-gates.md` `### G5`; `evidence/qa-gates/stage-f-typescript-test.2026-11-07T23-45.md`. |
| Minor | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/qa-gates/self-review.2026-11-07T23-59.md` | Policy Audit Rows, `Error handling` | CR2. The row states "Unreadable stamps keep the legacy guideline". Both runtimes give an unrecognized or absent stamp the current pair of 20 and 250, as the spec, rule file, and tests state. | Correct the row in the next feature-folder commit, or note the correction in the stage G self-review. | Evidence accuracy only; the code and tests are correct. | `plan_size_guideline` docstring; `test_plan_file_stamp_rejects_other_names`; `test_guideline_without_path_is_new`. |
| Nit | `.claude/rules/plan-acceptance-gates.md` | `### G13` paragraph on stamps | CR3. Three committed plan files with no stamp in their names now report G13 under the new pair, but not under the legacy pair: `docs/features/archive/2026-10-16-planning-process-churn-964/evidence/other/replan-962/plan.md` (38 tasks), `.../replan-962/attempt-2/plan.md` (38 tasks, 295 lines), and `docs/features/completed/2026-07-04-release-flow-wait-for-ci-310/plan.md` (37 tasks). They lie outside the result-check scope, which the plan's `## Open Questions / Notes` declares, and no sweep validates them. The statement that no plan written before the rule changes its result therefore holds for stamped plans and for the in-flight scope, but not for these three historical files. | None required. Optionally, add a sentence to the rule file stating that unstamped historical plan files use the current pair if they are pointed at. | Owner Condition 4 concerns in-flight items. `## Scope of Invocation` states that no sweep exists. | Reviewer corpus probe. |
| Nit | `scripts/dev_tools/plan_gate_document.py`; `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` | `plan_file_stamp`, `planFileStamp` | CR4. The stamp pattern checks digit positions, not calendar values, so `plan.0000-00-00T00-00.md` keeps the legacy pair. An older-stamped plan also keeps the legacy pair after it is rewritten: `plan.2026-11-07T12-43.md` was refreshed after the cutoff and still receives 40 and 400, although it fits 20 and 250. The rule file's argument that the stamp is not a suppression surface rests on the feature-folder tooling and the Plan-Path Continuity Contract. | None required. If the guideline is tightened again, consider basing the cutoff on the plan's first-commit time instead of its name. | The design is accepted in spec D2; this records its limit. | Reviewer parity probe; `git log --diff-filter=A` on the plan files. |
| Nit | `docs/engineering/process-reductions/0008-g13-guideline-cutoff.md` | `## Summary`, `Merge commit:` | CR5. `pending (PR #1097)` uses the issue number as a stand-in until the PR exists. The planned replacement after PR creation edits a path under `docs/engineering/`, outside the feature folder. Under the D4 currency rule, that makes this reviewed head non-current, and K8 places merge-commit back-fills before review. The branch has used this sequence for `0004` to `0007` (`41caab5a1`, `cf2b4e074`). | Orchestrator: after the PR-number commit, re-confirm review currency for the new head as the run's review mode requires. | Process sequencing; no code effect. | `git show 41caab5a1`, `cf2b4e074`; spec D4, K8. |
| Nit | `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` | Threaded reader arc | CR6 (carries N2). The Python repo-wide raw branch ratio is 94.1696% against a baseline of 94.1720%. The difference is one timing-dependent partial arc in a file outside the diff. P3-T3 recorded it, and the totals are equal at two decimals. | None required in this PR. | Changed-line coverage did not regress; the arc is a known timing effect. | `evidence/qa-gates/stage-f-python-test.2026-11-07T23-43.md`. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/qa-gates/` | Stage F gate records | CR7. After the fix commit, the Jest and Pester gates were re-run with new artifacts, but the format-lint artifact was not rewritten. The self-review states that ESLint and Prettier were clean after the fix. The reviewer re-ran Prettier, ESLint, and `tsc` on the changed TypeScript files at head, all clean. | None required; this review records the re-run. | Toolchain-loop record completeness. | Reviewer commands in `## Verification Performed`. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` | Header block | N3 (carried). `Last Updated` and `Version` are unchanged after the D2 correction. | Update with the next spec edit. | Record only. | `spec.md` header. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `scripts/dev_tools/validate_orchestration_artifacts.py` at 503 logical lines (guidance tier only). `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Stamp reading and guideline selection

- Python `plan_file_stamp` splits on both separators, tries the three name shapes with `fullmatch`, and handles the folder form by exact segment checks. TypeScript `planFileStamp` uses four patterns anchored at the start or a separator and at the end of the string. Neither pattern can span a separator, so both accept the same set of paths, as the probe confirms.
- The selector compares strings. A zone with no cutoff entry compares with the empty string, so it receives the current pair; `test_guideline_for_a_zone_without_a_cutoff_entry_is_new` pins this.
- `validate_plan_text` keeps its signature and applies the current pair. Only tests call it.
- The MCP service call passes the joined workspace path as `artifactPath`, so the stamp is read from the file name whatever the prefix.

### The G5 fix

The removed ternary could take only one value while `G5_SEVERITY` is the warning value. Removing it changes no finding: the Jest count and every expectation are unchanged. Removing the arm also removed the branch-count drop that V8 reported for `plan-gate-discrimination.ts`. The `0008` patch was regenerated, so reverting `0008` also restores the arm. That is consistent, because the fix commit carries the `0008` token, and the reviewer's probe confirms the chain records it. CR1 records the structural asymmetry.

### Mirrors and wording

The three contract sources, the two agents, and the rule file have the same blob ids as their six bundle copies. No surface outside these still states 40 tasks or 400 lines as the current guideline. `PCW-SIZE-GUIDELINE-<Copy>` and `PCW-SIZE-AGENT-<Id>` pin the new text and forbid the superseded clause.

### Security and correctness

No I/O was added to the validators. The path is parsed as text only. The regular expressions are linear and have no backtracking risk on bounded stamp text.

## Verification Performed

- `git fetch`, merge base, `merge-tree` (exit 0), `log` and `diff` over `1850596d9..HEAD`; first-commit times of every plan file in the feature folder against their stamps.
- Stored-patch regeneration and `cmp` (identical); `git apply -R --check` (exit 0).
- In-memory chain at head, full and `-StopBefore` for each of 8 entries; four mutant probes and one control on `0008` regions.
- Cross-runtime parity probe over 37 paths (esbuild bundle of the worktree TypeScript under Node; worktree Python under `poetry`).
- G13 corpus probe over 636 stamped and 22 unstamped plan-like files.
- Python CLI validation of `plan.2026-11-07T06-17.md` (19 tasks, 168 lines) and `plan.2026-11-07T12-43.md` (20 tasks, 165 lines): both pass.
- Prettier, ESLint, and `tsc -p tsconfig.jest.json --noEmit` on the changed TypeScript files; Black and Ruff on the changed Python files: all clean.
- One Jest run from the worktree root (`node run-jest.cjs --coverage`, 334 suites, 5414 tests, 0 failed), which wrote the root `coverage/lcov.info` that the coverage stop hook reads. Its per-file figures for the three changed TypeScript files equal those of the executor's extension report.
- Coverage artifact parsing for Python, TypeScript, and PowerShell; logical line counts; `validate_evidence_locations` exit 0; `gh run view 42427888335` (in progress on this head).

## PR Readiness

**Ready to merge once CI is green.** No blocking finding. CI run 42427888335 on this head is read by the orchestrator at S9. CR1 and CR2 are optional follow-ups.
