# Feature Audit — issue #631 (cleanup-worktrees report-mode visibility gaps)

- Timestamp: 2026-09-07T14-40
- Branch: `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
- Baseline: `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
- Work mode: `full-bug` -> AC source is **`spec.md` only** (`## Acceptance Criteria`)
- AC skill applied: `acceptance-criteria-tracking`
- Verdict: **changes requested**

## Method

Each of the 11 acceptance criteria was evaluated against primary evidence — the `.bats`
`@test` bodies, the checked-in fixture files they consume, the production sources, and the
CI run logs cited in the evidence artifacts — rather than against the plan's task
check-offs or the pre-existing `[x]` marks. Where a criterion's stated property could be
falsified by tracing the fixture data through the production code, that trace is recorded.

The bash toolchain cannot be executed in this session (`wsl` denied by the
worktree-isolation guard; no `bats`/`kcov` on the Windows PATH), so test *outcomes* are
taken from the CI run of record and test *logic* is verified by reading the `@test` blocks
against their fixtures. This distinction is noted per criterion where it matters.

## Evaluation

| # | Acceptance criterion (abbreviated) | Verdict | Primary evidence |
|---|---|---|---|
| 1 | `ORPHAN_DIR` emitted / absent, +/- bats pair | **PASS** | `test_cleanup_worktrees_report_records.bats:46-60`; fixtures `orphan_dir_present`, `orphan_dir_absent` |
| 2 | `STALE_REF` generic detection, +/- bats pair | **PASS** | same file `:30-44`; fixtures use `upstream`, not `child` |
| 3 | `CHILD_OF` +/- pair with argv-log, "alongside an **unchanged** `BRANCH` line" | **PARTIAL** | `test_cleanup_worktrees_classification.bats:153-190`; falsified clause traced below |
| 4 | `WARN|registration-lost` +/- bats pair | **PASS** | `test_cleanup_worktrees_report_records.bats:62-75` |
| 5 | Outcome-preservation invariant, properties (a) and (b) | **FAIL** | traced below |
| 6 | `for-each-ref` stub edit backward compatible, verified *before* new fixtures | **PARTIAL** | `evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md` |
| 7 | SKILL.md contract + byte-identical mirror | **PASS** | `diff` empty; md5 `c6353060b287c20249addf4d3d2175ea` on both copies |
| 8 | `cleanup_worktrees_lib.sh` <= 500 lines | **PASS** | 491 lines counted directly |
| 9 | Full toolchain loop, line coverage >= 85% | **PASS** | CI run 34151370364: format/check/test/coverage all exit 0; `Bash coverage (lines): 93.4%` |
| 10 | No automatic deletion introduced | **PASS** | code inspection + `test_cleanup_worktrees_deletion.bats` |
| 11 | No fixed historical numeric count asserted | **PASS** | every new fixture carries exactly one canned record |

### AC1 — `ORPHAN_DIR` — PASS

The positive test drives `scan_orphan_dirs` against `orphan_dir_present`
(`scan-dirs.out` = `.claude/worktrees/agent-old|0|NA|128K`, `worktree-list.out` naming a
different path) and asserts the exact line
`ORPHAN_DIR|.claude/worktrees/agent-old|128K`. The negative drives `orphan_dir_absent`
(`/repo-wt/feat|1|1|64K`, registered in `worktree-list.out`) and asserts empty output. The
`has_gitfile == 0` filter and the `normalize_wt_path`-normalized registration lookup in
`scan_orphan_dirs:218-227` match the criterion's wording exactly.

Noted for follow-up, not counted against this AC: CR-04 in the code review shows the
`.claude/worktrees` scan root is CWD-relative, so in production the record may not be
reached at all when the tool runs from a session worktree. The AC as written concerns
emission verified by a bats pair, which is satisfied; the production-reach gap is carried
as remediation item R-04.

### AC2 — `STALE_REF` — PASS

`scan_stale_refs` builds the configured-remote set from `git remote` and emits any
`refs/remotes/<name>/*` whose `<name>` is absent from it
(`cleanup_worktrees_report_records_lib.sh:89-103`). No literal `child` appears anywhere in
the implementation. The positive fixture uses `upstream`
(`stale_ref_present/for-each-ref.refs_remotes_.out`, with `remote.out` listing only
`origin`); the negative adds `upstream` to `remote.out` and expects empty output. The
"general rather than hardcoded" clause is directly verified.

### AC3 — `CHILD_OF` — PARTIAL (unchecked)

Satisfied clauses: the positive test asserts both `BRANCH|feature-child|NOT_MERGED` and
`CHILD_OF|feature-child|feature-parent`; the negative (`child_of_merged_equivalent`,
ancestor resolves `MERGED_EQUIVALENT`) asserts no `CHILD_OF|` line and proves the full
ladder ran via `cherry main feature-child` appearing in the argv log; the positive asserts
the absence of `cherry main feature-child`, of the tip sha `cccc4444`, and of the
`rev-list --reverse --no-merges` rung. The argv-log mechanism works because the
`classify_all()` helper deliberately omits `2>/dev/null`, which is documented in the
helper's comment.

Unsatisfied clause: "**alongside an unchanged `BRANCH|<branch>|NOT_MERGED` line**." Under
the positive fixture, the unchanged ladder does not produce `NOT_MERGED` for
`feature-child`. `child_of_not_merged/` supplies no `diff-quiet.feature-child.rc`, so the
stub exits 0 for `git diff --quiet main...feature-child`
(`stub-bin/git:159-177` -> `respond "diff-quiet.feature-child"` -> no file -> rc 0), which
`classify_content_neutral` (`cleanup_worktrees_lib.sh:141-153`) maps to
`MERGED_CONTENT_NEUTRAL`. The short-circuit therefore replaces a delete-eligible verdict
with `NOT_MERGED` in the criterion's own positive case. The word "unchanged" is not
verified and is in fact contradicted.

**Check-off action:** unchecked in `spec.md`.

### AC5 — outcome-preservation invariant — FAIL (unchecked)

Property (a) — "the report-mode `BRANCH|<branch>|NOT_MERGED` line's value is unchanged
whether or not the short-circuit fires."

The test that claims to verify this compares `feature-child` under `child_of_not_merged`
against `feature-unmerged` under the unrelated `unmerged` scenario. Two different branches
in two different fixtures. It establishes that the record *shape* is consistent, which was
never at issue; it does not hold the branch and fixture fixed while varying only whether
the short-circuit ran, which is what the property states. The test is vacuous with respect
to the property it names.

Worse, the property is false as implemented. `classify_all_branches` inherits `NOT_MERGED`
from any direct ancestor-target that resolved `NOT_MERGED`, with no check on the subject
branch's own relationship to `main`
(`cleanup_worktrees_report_records_lib.sh:431-447`). A branch that is fully merged into
`main` and is also a git ancestor of an unmerged branch — the ordinary state of this
repository after any PR merge, since `main` sits at merge commit `0542c92a` — is a
counterexample. The full trace is recorded as CR-01 in
`code-review.2026-09-07T14-40.md`.

Property (b) — "the apply-mode allowlist decision for a `CHILD_OF`-short-circuited branch
is unchanged (no deletion `ACTION` emitted)."

The apply-mode test asserts no `ACTION|delete|feature-child|` and no
`branch -D feature-child`. Both assertions pass, but under the same fixture the
un-short-circuited ladder resolves `feature-child` to `MERGED_CONTENT_NEUTRAL`, which *is*
on the allowlist (`cleanup_worktrees_actions_lib.sh:409`) and *would* produce a deletion.
The allowlist decision therefore did change; the test pins the changed decision in place
rather than detecting it.

Both properties fail. This is the feature's single blocking defect.

**Check-off action:** unchecked in `spec.md`.

### AC6 — `for-each-ref` stub backward compatibility — PARTIAL (unchecked)

The substantive property is verified: all 22 pre-existing scenario directories are
untouched by this branch (confirmed from the diff — only new scenario directories were
added), and CI run 34151370364 reports 335 ok / 0 not ok with the edited stub in place, so
no pre-existing scenario regressed under either the `for-each-ref` key-specificity edit or
the `merge-base` target-aware edit.

The criterion's explicit timing clause is not evidenced. AC6 requires the suite to pass
"**immediately after that edit, before any new scenario fixtures are authored on top of
it**," and plan task P2-T3 restates that sequencing. The recorded artifact
`evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md` instead reports
the post-Phase-9 tree (335 tests, commit `02ce5eec`), and
`evidence/qa-gates/final-test.2026-09-06T23-03.md` states plainly that "P2-T3 and this
task observe the identical post-Phase-9 tree." A run against the post-Phase-9 tree cannot
be a run taken before the new fixtures existed; the count itself (335 = 321 + the 14 new
tests) confirms the new fixtures were already present.

Documented assumption: the executor could not run bats locally, and
`gh workflow run --ref <branch>` dispatches against branch HEAD, so capturing an
intermediate-tree run would have required an extra throwaway commit. The constraint is
understandable and the gap is low-risk given no pre-existing fixture was modified — but
the criterion as written is not met by the evidence on file.

**Check-off action:** unchecked in `spec.md`. Remediation is cheap: either dispatch the
suite against a commit carrying only the stub edit, or amend the criterion to state the
property actually verified (pre-existing scenarios unmodified and all passing on the final
tree) and record the rationale.

### AC7 — SKILL.md contract and mirror — PASS

Both copies received the identical 15-line addition documenting `ORPHAN_DIR`,
`STALE_REF`, `CHILD_OF`, and `WARN|registration-lost`. Byte-identity independently
confirmed two ways: `diff` produced no output, and both files hash to
`c6353060b287c20249addf4d3d2175ea`. The cross-reference requirement is met — the
`ORPHAN_DIR` bullet points to "the Dirty Worktree Triage Procedure's step 7, which governs
how an orphaned directory is handled" (that step exists at SKILL.md:247-253) rather than
restating the guidance.

Note: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, named in the
criterion as the verifier, was not executed here (Python toolchain not exercised in this
session and no Python file changed on the branch). The property that test asserts was
verified directly by hash comparison, which is why this is PASS rather than UNVERIFIED.

### AC8 — 500-line cap — PASS

`scripts/bash/cleanup_worktrees_lib.sh` is 491 lines, up 12 from the 479 recorded in
`issue.md`. Counted directly, matching both the executor's evidence artifact and the
orchestrator's spot-check. All four other touched bash files are also under the cap (463,
417, 157, 128).

### AC9 — toolchain loop and coverage — PASS

CI run 34151370364 on commit `02ce5eec` covers all four stages with exit 0:
`shfmt` (no-op), `shellcheck` (no diagnostics), `bats` (1..335 planned, 335 ok, 0 not ok),
kcov (`Bash coverage (lines): 93.4%`). 93.4% clears the uniform >= 85% floor; bash is
exempt from the branch gate per `.claude/rules/shell.md:68-70`, so no branch figure is
required. Commit `fbb1e65b` is documentation-only (verified with
`git diff --name-only 02ce5eec fbb1e65b`), so the coverage run remains valid for the
branch tip.

The 94.2% -> 93.4% delta is explained by denominator growth of ~427 lines and is not a
threshold regression. Per-file coverage for the two new production files was not preserved
in the evidence folder; that is recorded as remediation item R-05 and does not fail this
criterion, whose text specifies the aggregate line-coverage gate.

### AC10 — no automatic deletion — PASS

Verified by inspection rather than by absence of a test. `run_apply` calls no scan
function, and its per-branch extraction filter admits only `BRANCH`, `CHILD_OF`, and
`COMMIT` records (`cleanup_worktrees_actions_lib.sh:399-400`), so `ORPHAN_DIR`,
`STALE_REF`, and `WARN|registration-lost` are structurally incapable of reaching a
deletion path. No new call to `delete_candidate`, `delete_branch`, `remove_worktree_safe`,
`rm`, or `git worktree prune` appears anywhere in the diff. `SKILL.md:305-307` retains the
standing prohibition on filesystem removal of an orphaned directory without per-item user
confirmation.

### AC11 — no fixed historical numeric counts — PASS

Every new fixture carries exactly one canned record per shape (one orphan dir, one stale
ref, one lost registration), and every new assertion is an equality or containment check
on a single record, never a count. The historical figures from the 2026-09-06 run (four
directories, 17 refs, two worktrees) appear in no test or fixture. `scan_stale_refs` and
`scan_orphan_dirs` are set-difference and predicate filters with no fixed cardinality.
Independently reproduces the executor's
`evidence/other/ac11-generic-detection-confirmation.2026-09-06T23-03.md`.

## Scope conformance

The delivered change matches `spec.md`'s "In scope" list: exactly four additive record
types, new logic isolated in a new sibling library, `run_report` and `run_apply` both
routed through one shared driver. No out-of-scope surface was touched — no
`enforce-epic-*-gate.ps1`, no `collect_pr_context`, no detached-worktree logic beyond the
sourcing changes required by the new library, no `--clear-disposable` flag, no removal
manifest.

One documented deviation from the plan text: `cleanup_wt_protected_branches` and the
protection carve-out inside `classify_all_branches` were added by the executor and appear
in no plan task. The addition was necessary and its stated rationale is correct — without
it, `main` (protected, and a git ancestor of every unmerged branch) would inherit
`NOT_MERGED`. The implementation faithfully mirrors `classify_branch`'s rung-1 exclusion
(current branch plus any branch checked out in a protected worktree path), and I found no
divergence between the two. It is, however, a partial fix: it closes the `main` case
specifically while leaving the general class of the same bug open (CR-01). It also carries
no direct test — no fixture exercises a branch that is both protected and deferred, which
is the exact condition it was written for.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md
- Total AC items: 11
- Checked off (delivered): 8
- Remaining (unchecked): 3
- Items remaining:
  1. `CHILD_OF|<branch>|<ancestor>` is emitted alongside an unchanged `BRANCH|<branch>|NOT_MERGED` line ... (AC3 — PARTIAL: the "unchanged" clause is contradicted by the fixture trace)
  2. The `CHILD_OF` outcome-preservation invariant is verified as two separately-tested properties ... (AC5 — FAIL: invariant violated; both tests vacuous)
  3. The `for-each-ref` stub key-specificity edit ... backward compatible ... immediately after that edit, before any new scenario fixtures are authored on top of it (AC6 — PARTIAL: substance verified, sequencing not evidenced)
```

Three items were changed from `[x]` to `[ ]` in `spec.md` by this review. No criterion
text was modified and no criterion was added or removed.

## Recommendation

**Changes requested.** AC5 is a genuine correctness failure with a demonstrable
counterexample inside the feature's own fixture, and AC3's "unchanged" clause fails for the
same reason. AC6 is an evidence-sequencing gap with low substantive risk. The remaining
eight criteria are met, the code structure is sound, and the four new record types are
well built — the blocking work is confined to the `CHILD_OF` short-circuit's inheritance
condition and the two tests that were meant to guard it.

Remediation detail: `remediation-inputs.2026-09-07T14-40.md`.
