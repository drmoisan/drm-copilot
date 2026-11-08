# Feature Audit: Stage F, G13 Guideline with a Zone-Aware Cutoff (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `1e47be8de2807849576c2f335f99a42488e54055`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`, supplied by the caller and confirmed by `artifacts/pr_context.summary.txt`, which resolves `origin/main` @ `1850596d9a7a8f092ac2dc3f8ff7461985751685` for head `1e47be8de`.
- Merge base: `1850596d9a7a8f092ac2dc3f8ff7461985751685`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `1850596d9..1e47be8de`, 52 files, 24 commits, no merge commit.
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: this PR carries stage F per `spec.md` `## Delivery Stages`, so the three `[F]` criteria are owed here. Criteria tagged `[A]` to `[R]` were delivered by earlier PRs and were re-checked for regression. Criteria tagged `[G]` to `[J]` are owed by later stages and are not judged in this PR.
- Decision applied: D2 as corrected in `768f5fec9` (one instant, compared per stamp zone). That commit changes only the D2 line of `spec.md`, and no `[F]` criterion text changed.

## Acceptance Criteria Inventory

Stage F criteria, identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion (abridged) |
|---|---|
| F1 | G13 reports at the new guideline of 20 tasks and 250 physical lines in both validators, with parity, at the guideline and one above it, with and without a justification. |
| F2 | Parity tests run both sides of `PLAN_GUIDELINE_CUTOFF` and the no-path case, cover each stamp shape in K4, and prove that a plan with absent repository wiring keeps its stamp result. |
| F3 | The finding message states the guideline that applied, the rule file's scope section describes the cutoff, and G13 lands as its own commit with its entry. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| F1 | PASS | `PLAN_TASK_GUIDELINE` is 20 and `PLAN_LINE_GUIDELINE` is 250 in both modules, and `test_guideline_constants_match_typescript` pins the four values in both runtimes. The existing G13 cases in `test_plan_gate_document.py` and `plan-gate-document.test.ts` are sized from those constants. They pass no path, so the new pair applies. They prove no finding at 20 tasks and 250 lines, a finding at 21 tasks and at 251 lines, exoneration by a non-empty justification, and no exoneration by a heading-only justification. Parity: the `g13` rows of both parity suites assert the byte-identical new-pair message, and `test_typescript_suite_carries_identical_rows` keeps the cutoff row tables identical. Gates: pytest 16270 passed, Jest 5397 passed, both with 0 failures. |
| F2 | PASS | Both runtimes carry `test_guideline_boundary_rows`: in each zone, the minute before the injected entry keeps 40 and 400, and the entry minute and the minute after use 20 and 250. `test_guideline_k4_shape_rows` covers each of the four K4 shapes on both sides of its zone's entry. `test_utc_stamp_is_not_read_against_new_york_cutoff` covers a UTC stamp between the New York entry and the instant. `test_guideline_without_path_is_new` and the no-path message row cover the no-path case. K5: the TypeScript `test_plan_path_reaches_g13_without_a_context` validates a 25-task plan with an older `artifactPath` and no `fs`, `root`, or `runner`, and finds no G13 finding; the full-wiring case gives the same result, and the no-path case reports one. The Python test of the same name passes `context=None`. The committed pair is pinned across the rule file and both modules by `test_cutoff_value_is_identical_in_rule_file_and_both_validators`. Reviewer probes: 37 adversarial paths gave identical stamp and guideline results in both runtimes, and 636 stamped committed plans keep their G13 outcome under the committed pair. |
| F3 | PASS | Message: `plan_size_message` and `planSizeMessage` render the applied pair; `test_g13_message_states_the_guideline_that_applied` asserts the legacy and new strings. Rule file: `## Scope of Invocation — no exemption marker` describes the dated G13 exception, and `### G13` states the shapes, zones, strict comparison, and the pair `PLAN_GUIDELINE_CUTOFF` (America/New_York `2026-11-07T18-31`, UTC `2026-11-07T23-31`). The bundle copy is byte-identical. Own commit: `39824bd35` carries `reduction: 0008`, all code, tests, wording, entry `0008`, its README row, and its stored patch. It contains no other reduction. Its author and committer dates equal the cutoff reading. The later `5a750bf0c` with the same token regenerates the patch in the same commit, and the reviewer confirmed the stored patch matches a regeneration byte for byte. |

Earlier criteria, re-checked for regression:

- `[A]` to `[D]`: the ledger, stage timing, and guard suites pass unchanged in the stage F gates (Pester 16132 tests and pytest 16270, both with 0 failures; Jest 5397 with 0 failures).
- `[E]` and `[E2]`: stage F's Phase 0 captured one parallel baseline per language. The final gate compared its figures and results with that baseline: per-file and total figures sit beside their Phase 0 values in each `stage-f-*-test` artifact, and no serial, seeded, reversed, or comparison run was made. This is the comparison as E2 defined it. Older plans still validate: the stage F plan, the stage G plan, and the corpus probe all confirm it.
- `[R]`: the in-memory chain over 8 entries is valid, and each `-StopBefore` replay is valid. Reviewer mutant probes show the chain failing on an unrecorded edit inside a `0008` region or to a `0008`-created file, and staying green on an edit outside every region. `0008` reverts first and restores the `0001` and `0006` context lines.

## Summary

Stage F delivers the lowered G13 guideline with a zone-aware, single-instant cutoff in both validators, the rule file, the six contract copies, and the four planner-agent copies, as one reduction commit with entry `0008`. All three `[F]` criteria pass, and no earlier criterion regressed. Coverage for every changed file meets 85% line and 75% branch, and no file falls below its Phase 0 figure. The PowerShell change is a test file only.

No blocking finding. Non-blocking items: CR1 (the TypeScript G5 channel no longer reads `G5_SEVERITY`), CR2 (one inaccurate self-review row), and Nits CR3 to CR7 and N3. Verdict: PASS. `ci.yml` run 42427888335 on this head is pending-CI and is read by the orchestrator at S9. No stage F criterion depends on it.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 38 per file
- Remaining (unchecked): 19 per file
- Items remaining: the criteria tagged `[G]` (4), `[H]` (2), `[I]` (7), and `[J]` (6), which later stages owe.

## Acceptance Criteria Check-off

- F1, F2, and F3 were checked off by the executor in `af6d4ee03`. This review evaluates each as PASS, so they stay checked in both files.
- No criterion was newly checked or unchecked by this review. No criterion was added and no criterion text was changed.
