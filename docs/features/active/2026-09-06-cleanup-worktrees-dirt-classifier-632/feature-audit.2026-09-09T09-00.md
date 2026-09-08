# Feature Audit — issue #632, remediation cycle 3 EXIT REAUDIT

Timestamp: 2026-09-09T09-00
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` @ `8afb0611`
Resolved base: `epic/cleanup-merged-worktrees-hardening-integration`, merge-base `4ffe680e`
Work mode: `full-bug` -> acceptance-criteria source is `spec.md` **only**

## Acceptance-Criteria Derivation

Section-scoped, per the caller's specified derivation and the
`acceptance-criteria-tracking` skill:

```
awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' spec.md | grep -c '^- \['      -> 49
awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' spec.md | grep -c '^- \[x\]'   -> 49
awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' spec.md | grep -c '^- \[ \]'   ->  0
```

The section holds **49 criteria, all checked**, matching the expected count exactly.

Whole-file checkbox count is 57. The 8-line excess is the severity radio block under
`## Context`, which is not acceptance criteria and is correctly excluded by the
section-scoped derivation. `spec.md` headings confirm the section boundaries:
`## Acceptance Criteria` at line 678, next heading `## Risks & Mitigations` at 949.

Work-mode marker: `issue.md:12` — `- Work Mode: full-bug`. `user-story.md` exists in the
feature folder but is **not** an AC source under `full-bug` and was not consulted for
criteria.

## Cycle 3's Criteria Delta

Cycle 3 added exactly two criteria and checked both:

```
git diff fcefa802..8afb0611 -- .../spec.md | grep -E '^[+-]- \['
+- [x] AC-48 — When a porcelain status entry's X column and Y column both carry a content-bearing ...
+- [x] AC-49 — `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` admits exactly two row ...
```

No criterion was removed, reworded, or unchecked. 47 + 2 = 49. These are legitimate
remediation criteria for the two blocking findings, not phantom criteria: each states a
property, not a task.

## Verification of the Two New Criteria

### AC-48 — PASS

Stated property: when X and Y both carry a content-bearing letter (`M A R C T U`), rung 4's
tracked half and rung 5 do not resolve a disposable verdict and the entry falls through to
`UNIQUE`; `AD` and `MD` are unaffected; rung 3 is unaffected because
`dirt_is_build_artifact` reads the cached diff as well as the worktree diff.

Verified by reproduction, not by reading (full detail in
`code-review.2026-09-09T09-00.md` Part 1):

- Implementation at `scripts/bash/cleanup_worktrees_dirt_lib.sh:297`, gating `:321-325` and
  `:370-374`.
- Pinned by four tests in `test_cleanup_worktrees_dirt_failclosed.bats` (tests 12-15)
  against the checked-in `dirt_index_and_worktree_delta` scenario, covering the rung-4
  direction (`MM`), the rung-5 direction (`MM`), the unmerged shape (`UU`), and the
  positive control (`M `).
- Neutralizing the guard flips tests 12, 13, 14. Disabling the rung flips tests 9 and 15,
  so the criterion is pinned in both directions.
- The `AD` exemption is separately pinned by test 8 and the rung-3 exemption verified
  against `dirt_is_build_artifact:202-231`, which requires both the worktree diff and the
  `cached` diff to be HintPath-confined.

Residual: the `T` member of the class is not exercised by any checked-in scenario
(finding NF-1, non-blocking). AC-48's stated behaviour is nonetheless implemented for `T`.

### AC-49 — PASS

Stated property: the registry admits exactly two row kinds; a row carrying any other kind
fails on `INVARIANT-8 inadmissible kind:` and, when its scenario exists, on
`OBLIGATION-5 channel comparison failed:`; both admissible kinds require an observed
difference, which is possible only if the guard executed.

Verified by reproduction:

- `EXEMPT` is absent from both the suite and the registry (`grep -n 'EXEMPT'` -> no matches).
- Registry shape is as stated: 42 rows, 40 `SEPARATED` + 2 `ARGV`, 40 distinct ids, against
  40 markers derived from the library.
- Writing the exact cycle-2 parked row produces all three named literals
  (`INVARIANT-8 inadmissible kind:`, `OBLIGATION-5 channel comparison failed:`,
  `PINS NOT SATISFIED:`), reproducing
  `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md` independently.
- Extended beyond the recorded evidence: relabelling the same parked row as `SEPARATED`
  still fails Obligation 5, and as `ARGV` fails Obligations 5 and the pin floor. The fix
  did not merely rename the loophole.

## Regression Check Against Prior Criteria

The 47 criteria carried from earlier cycles were verified as still satisfied at
`8afb0611`, primarily through the CI evidence and local suite reruns rather than by
re-deriving each one.

| Criterion group | Evidence | Verdict |
|---|---|---|
| AC-39 (rung 1 Y-column gate, R1) | `test_..._failclosed.bats` tests 1-2 pass; neutralizing the gate flips the content-locations gate | PASS |
| AC-40, AC-41 (payload split, diff-header skip; R2/R5) | registered guards `rename-payload-split-gate`, `diff-header-skip`, both `SEPARATED`-pinned under the raised floor | PASS |
| AC-42 (`STAGED_TREE_IS_COMMIT` in five directions) | `test_..._failclosed.bats` tests 1-5 pass | PASS |
| AC-45 (classifier kcov line coverage) | 163/173 = 94.22% recomputed from the CI kcov artifact; was 160/170 = 94.12% at cycle-3 entry, so no regression | PASS |
| AC-46 (rung 4 `CONTENT_ON_MAIN` only when the path is in main; N1) | `test_..._failclosed.bats` tests 8-9 pass; neutralizing `guard:rung4-tracked-path-in-main` flips both the failclosed suite and the content-locations gate | PASS |
| AC-47 (every guard-shaped line marked and registered) | registry suite `1..3` green; 40 markers all pinned | PASS |
| AC-32 (no shell file over 500 lines) | classifier 495, `cleanup_worktrees_lib.sh` 496, all changed `.bats` under 440 | PASS |
| AC-31 (green `_shell-coverage.yml` dispatch against the pushed head) | run 34255859868, `success`, head `5ad0ef09`, TAP `1..417`, 0 `not ok` | PASS |
| AC-33..AC-36 (SKILL.md contract sections and the mirror) | `diff` of `.claude/skills/cleanup-merged-worktrees/SKILL.md` against the `extensions/.../claude-customizations` mirror reports no difference | PASS |
| AC-26 (report mode non-mutating), AC-16..AC-22 (records, aggregate, CLI) | `test_..._regression.bats` 12/12, `test_..._clear.bats` 14/14, `test_..._classify.bats` 24/24 green locally | PASS |

No prior criterion regressed. The branch adds 6 net tests over the 411-test Phase 0
baseline (417 in CI) and breaks none.

## Evidence Commit Integrity

`git diff --name-only 5ad0ef09..8afb0611` returns five paths, all under the feature folder
(four `evidence/qa-gates/*.md` and `remediation-plan.2026-09-08T23-30.md`). The evidence
commit is documentation only, so the CI result at `5ad0ef09` is valid for `8afb0611`. The
caller's statement to that effect is confirmed rather than assumed.

The caller's caution that a PR based on the epic integration branch runs essentially no CI
is consistent with what I observed: the dispatched run is the verification, and it is the
one this audit relies on.

## Plan Task State

- Cycle 3 plan (`remediation-plan.2026-09-08T23-30.md`): 48 tasks, **48 checked, 0
  unchecked**.
- Cycle 2 plan: 5 tasks deliberately unchecked, adjudicated in
  `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`. Reviewed and accepted as
  environmental (2 tree-digest tasks denied by the isolation guard to every agent including
  this one) or pre-existing (3 push-down contract legs failing on issue #510 identically at
  baseline and post-change). Neither class is attributable to this change.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md
- Total AC items: 49
- Checked off (delivered): 49
- Remaining (unchecked): 0
- Items remaining: none
```

No criterion required check-off by this reviewer; all 49 were already checked by the
executor and each was found to be supported by evidence.

## Verdict

All 49 acceptance criteria PASS. No criterion is UNVERIFIED. No remediation inputs are
produced, because there are no FAIL or blocking-PARTIAL findings.

Blocking findings: 0.
