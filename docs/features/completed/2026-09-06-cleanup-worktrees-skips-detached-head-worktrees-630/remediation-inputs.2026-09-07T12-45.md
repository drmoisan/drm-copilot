# Remediation Inputs (Issue #630) — cycle entry

**Entry timestamp:** 2026-09-07T12-45
**Feature folder:** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630`
**Base branch:** `epic/cleanup-merged-worktrees-hardening-integration` (merge base `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`)
**Head:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2` @ `65a56cb94352c2a19c381acf4008837fa84aee69`
**Work mode:** `full-bug` — AC source is `spec.md` only
**Blocking finding count:** 2 (both Major; no Blocker)

---

## Pointer to the audit artifacts that produced these findings

- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/policy-audit.2026-09-07T12-45.md`
  — see `## 1.2` (New Code Coverage, Comprehensive Coverage), `## 5. Test Coverage Detail`
  (enumerated uncovered regions), and `## 8. Gaps and Exceptions` items 1-5.
- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/code-review.2026-09-07T12-45.md`
  — Findings Table rows 1-2 (Major) and rows 3-5 (Minor).
- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/feature-audit.2026-09-07T12-45.md`
  — 24/24 AC PASS; the revision requirement is a policy finding, not an unmet acceptance criterion.
- Supporting evidence already on the branch:
  `evidence/qa-gates/coverage-delta.2026-09-07T14-45.md`,
  `evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md`,
  `evidence/baseline/bash-test-coverage.2026-09-07T14-30.md`.

**Artifact-layout note.** These four artifacts are written in the flat
`<FEATURE>/<kind>.<timestamp>.md` form required by the feature-review agent contract and requested by
the calling orchestrator. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` describes a
folder-per-cycle layout (`remediation/<entry-ts>/`, `audit/<exit-ts>/`). If the orchestrator is
running the folder-per-cycle pattern, relocate these four files into
`audit/2026-09-07T12-45/` (the three audit artifacts) and `remediation/2026-09-07T12-45/` (this file)
before delegating, and keep the paths in the delegated prompt consistent with wherever they land.

---

## Trigger justification

Remediation is triggered under two independent clauses of
`.claude/skills/feature-review-workflow/SKILL.md` step 8:

1. *"the policy audit contains meaningful FAIL or PARTIAL results"* — `policy-audit.2026-09-07T12-45.md`
   records FAIL against `.claude/rules/general-unit-test.md` (scenario completeness / untested
   critical behavior) and against the new-code coverage threshold.
2. *"coverage regression below policy threshold ... < 90% for new files"* —
   `scripts/bash/cleanup_worktrees_detached_lib.sh` is a new file at **80.6%** line coverage, below
   both the >= 85% uniform new-code threshold in `.claude/rules/quality-tiers.md` and the >= 90%
   new-file trigger in the coverage-verification procedure.

Toolchain checks did **not** fail. Acceptance criteria are **not** unmet (24/24 PASS). No workflow
file was modified, so `modified-workflow-needs-green-run` did not fire. No required CI check failed.

---

## Enumerated fix list

### R1 — Cover the two untested delete-eligible verdicts (Major, blocking)

**Problem.** `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` are on the three-token allowlist in
`apply_detached_worktrees` and `reverify_detached_delete_eligible` that authorizes an irreversible
`git worktree remove`. Neither token is produced by any of the seven new fixtures: `detached_merged`,
`detached_merged_dirty`, `detached_locked`, and `detached_prunable` all set `merge-base.<sha>.rc` = 0
and therefore all resolve at rung 1 to `MERGED_CLEAN`; `detached_unmerged` resolves to `NOT_MERGED`;
`detached_current` to `PROTECTED_CURRENT`; `detached_ancestry_error` to `ANCESTRY_ERROR`. The
non-eligible `HAS_UNIQUE_RESIDUALS` terminal is likewise never produced. This is the substance of the
80.6% per-file coverage figure.

**Files to change.**

- `tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/` (new directory)
- `tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/` (new directory)
- `tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/` (new directory)
- `tests/shell/test_cleanup_worktrees_detached.bats` (add cases)

**Expected behavior after the fix.**

- `detached_content_neutral` — HEAD `det00008`, flags `detached`. Keys: `merge-base.det00008.rc` = 1,
  `diff-quiet.det00008.rc` = 0, plus the `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
  `rev-parse.show-toplevel.out`, and `worktree-list.out` shape used by `detached_merged`. Report mode
  must emit `WORKTREE|/repo-wt/det|DETACHED|MERGED_CONTENT_NEUTRAL|detached`.
- `detached_equivalent` — HEAD `det00009`, flags `detached`. Keys: `merge-base.det00009.rc` = 1,
  `diff-quiet.det00009.rc` = 1, `cherry.det00009.out` = `- det00009` (a single patch-id-equivalent
  line, so `classify_cherry_equivalent` returns the single `MERGED_EQUIVALENT` line with no residual).
  Report mode must emit `WORKTREE|/repo-wt/det|DETACHED|MERGED_EQUIVALENT|detached`, and apply mode
  must emit `ACTION|worktree-remove|/repo-wt/det|OK` with `worktree remove /repo-wt/det` present in
  the stub argv log and `--force` and `worktree prune` absent.
- `detached_unique_residuals` — HEAD `det00010`, flags `detached`. Keys: `merge-base.det00010.rc` = 1,
  `diff-quiet.det00010.rc` = 1, `cherry.det00010.out` containing both a `- <sha>` line and a
  `+ det00010` line, `diff-tree.det00010.out` = `M\tsrc/app.py`, and distinct blob OIDs at
  `rev-parse.det00010_src_app.py.out` and `rev-parse.main_src_app.py.out`. Report mode must emit
  `WORKTREE|/repo-wt/det|DETACHED|HAS_UNIQUE_RESIDUALS|detached`, and apply mode must emit no
  `ACTION|worktree-remove` line and no `worktree remove` argv. (The `MINUS_PRESENT` signal is what
  separates this terminal from `NOT_MERGED`.)

**New bats cases (minimum 4).**

1. `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD`
2. `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD`
3. `apply removes a cherry-equivalent detached worktree without force`
4. `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD`, plus an apply-mode
   assertion that no removal is attempted.

**Verification commands.**

```bash
npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats
bash scripts/bash/shell-qc.sh test --coverage
# Confirm: no line beginning `not ok`; `Bash coverage (lines): NN.N%` at or above 85.0;
# and the per-file line-rate for scripts/bash/cleanup_worktrees_detached_lib.sh in the
# uploaded shell-coverage/cov.xml at or above 0.85.
```

**Definition of done.** All three tokens appear in test output; the new file's per-file line rate in
`shell-coverage/cov.xml` is at or above 85%; the aggregate headline is at or above 85%; zero `not ok`.

---

### R2 — Cover the unexercised fail-closed guards on the destructive path (Major, blocking)

**Problem.** Five fail-closed branches in `scripts/bash/cleanup_worktrees_detached_lib.sh` are never
taken by any test. Each exists to prevent a hard git failure from being read as a merge verdict on a
path that ends in `git worktree remove`:

| Branch | Function | Effect when correct |
|---|---|---|
| `compute_protected` non-zero | `classify_detached_head` | `ANCESTRY_ERROR`, return 2 — prevents a weakened (empty) protected set from letting the caller's own worktree reach a delete-eligible verdict |
| `CONTENT_NEUTRAL_ERROR` | `classify_detached_head` | `ANCESTRY_ERROR`, return 2 |
| `CHERRY_ERROR` / `DIFF_TREE_ERROR` | `classify_detached_head` | `ANCESTRY_ERROR`, return 2 |
| `RESIDUAL_ERROR` | `classify_detached_head` | `ANCESTRY_ERROR`, return 2 |
| `((crc != 0))` | `reverify_detached_delete_eligible` | `BLOCKED-REVERIFY`, return 1 |

Only the rung-1 `merge-base` failure (`detached_ancestry_error`, rc 128) is currently exercised.

**Files to change.**

- `tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/` (new)
- `tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/` (new)
- `tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/` (new)
- `tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/` (new)
- `tests/shell/test_cleanup_worktrees_detached.bats` (add cases)

**Pattern to mirror.** `tests/shell/test_cleanup_worktrees_hard_failures.bats` cases 1-5 already
provide the branch-backed equivalents (`diff_tree_error`, `residual_namestatus_error`, `ls_tree_error`,
`rev_parse_error_protection` ×2). Reuse their fixture key conventions rather than inventing new ones.

**Expected behavior after the fix.** For each scenario, `classify_detached_head` returns **2**, echoes
`ANCESTRY_ERROR`, and never echoes any `MERGED_*` token; report mode emits
`WORKTREE|<path>|DETACHED|ANCESTRY_ERROR|<flags>`; apply mode emits no `worktree remove` argv and
returns non-zero. For the `reverify` branch, assert `BLOCKED-REVERIFY` with `$status` 1 and no
`worktree remove`.

**Verification commands.**

```bash
npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats
bash scripts/bash/shell-qc.sh test --coverage
```

**Definition of done.** Each of the five branches is asserted by at least one case; no `not ok`;
coverage thresholds from R1 still met.

---

### R3 — Strengthen two under-asserting cases (Minor, non-blocking)

**Files to change.** `tests/shell/test_cleanup_worktrees_detached.bats`,
`tests/shell/test_cleanup_worktrees_cli.bats`.

1. In `locked detached worktree yields BLOCKED-LOCKED and invokes no removal`, add
   `[ "$status" -ne 0 ]`. The locked path is the primary source of the documented apply-mode
   exit-code change and currently has no test guarding that propagation. The sibling dirty case
   already asserts it.
2. In `--help documents the detached worktree record`, add an assertion on the record literal itself
   in addition to `ANCESTRY_ERROR`:
   `[[ "$output" == *"WORKTREE|<path>|DETACHED|<state>|<flags>"* ]]`. AC22 names that literal; the
   pattern contains no glob metacharacter and is quoted, so the substring test works as written.
   Keep the existing `ANCESTRY_ERROR` assertion.

**Verification commands.**

```bash
npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats tests/shell/test_cleanup_worktrees_cli.bats
sh scripts/bash/cleanup-worktrees.sh --help    # exit 0; contains the record literal
```

---

### R4 — Document the apply-mode exit-code change in the operator-facing surfaces (Minor, non-blocking)

**Problem.** `run_apply` now returns non-zero when a detached worktree is dirty or locked, where the
same checkout previously exited 0. `spec.md` records this deliberately under
`### ACTION lines: apply-mode results` ("Apply-mode exit code ... This is a visible change ...
recorded here so it is not later mistaken for a regression"). `.claude/skills/cleanup-merged-worktrees/SKILL.md`
and the `cleanup-worktrees.sh --help` text do not mention it.

**Files to change.**

- `.claude/skills/cleanup-merged-worktrees/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  (must remain content-identical — this is AC21)
- `scripts/bash/cleanup-worktrees.sh` (usage heredoc)

**Expected behavior after the fix.** One sentence in the apply-mode workflow step stating that a
blocked detached removal (`BLOCKED-DIRTY`, `BLOCKED-LOCKED`, or `BLOCKED-REVERIFY`) sets a non-zero
exit status, so a checkout with dirty or locked detached worktrees will exit non-zero from `--apply`
where it previously exited 0.

**Verification commands.**

```bash
diff .claude/skills/cleanup-merged-worktrees/SKILL.md \
     extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
sh scripts/bash/cleanup-worktrees.sh --help    # exit 0
npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats
bash scripts/bash/shell-qc.sh check            # exit 0, empty stdout and stderr
```

---

### R5 — Record the detached `COMMIT|` blind spot as a known limitation (Minor, non-blocking)

**Problem.** `classify_detached_head` emits no `COMMIT|` records by design (spec Research
Correction 4: reusing `classify_branch` "can fabricate SHA-keyed `COMMIT|` records that
`cherry_pick_candidates` would misread"). The consequence is that unique work held in a detached
worktree classified `HAS_UNIQUE_RESIDUALS` or `NOT_MERGED` is correctly retained but is never
surfaced to the consolidation/cherry-pick triage flow, which reads `COMMIT|...|UNIQUE` records
(`scripts/bash/cleanup_worktrees_actions_lib.sh:127,129`). `spec.md` `## Known Limitations` records
L1-L4 and does not record this one.

**Files to change.** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
(add limitation **L5**), and optionally one sentence in `SKILL.md` plus its mirror.

**Expected behavior after the fix.** L5 states the omission, states that it fails in the safe
direction (retention, never deletion), and names it as a follow-up candidate rather than a defect in
this child. Do **not** implement `COMMIT|` emission for detached HEADs in this branch.

**Verification command.**

```bash
grep -n "L5" docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md
```

---

### R6 — Re-confirm clean integration before opening the PR (Minor, non-blocking, pre-PR check only)

The base branch `epic/cleanup-merged-worktrees-hardening-integration` has advanced 5 commits since
the merge base (current remote head `288ca2148d159bf2f7a1cbfff6bad3ee5c8d791b`), and one of those
commits — sibling child 634 — edits the same `.claude/skills/cleanup-merged-worktrees/SKILL.md` this
branch edits. At review time the two edits are textually disjoint (child 634's hunks land at original
lines 104-112, 249-258, 262-266; this branch's at 64-72 and 119-124) and
`git merge-tree --write-tree 288ca214 65a56cb9` exits **0**. Re-run that check immediately before
opening the PR, because R4 adds text to the same file in the region child 634 also touched.

```bash
git fetch origin epic/cleanup-merged-worktrees-hardening-integration
git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD
# exit 0 means no conflict
```

---

## Do-not-do list

1. **No production-code change is required or authorized by R1, R2, or R3.** These are test and
   fixture additions only. `scripts/bash/cleanup_worktrees_detached_lib.sh` is functionally correct as
   written; the finding is that its state space is under-tested, not that it is wrong. Do not
   restructure, refactor, or "simplify" the library while adding coverage.
2. **Do not modify `remove_worktree_safe`** (`scripts/bash/cleanup_worktrees_actions_lib.sh`, new
   lines 272-299). It is sibling epic child C's region and is byte-unmodified by this branch, which
   AC11 asserts. Adding `--force`, changing the `DIRTY|` emission, or altering the `BLOCKED-DIRTY`
   result would break AC11 and collide with child C.
3. **Do not lower or reinterpret any coverage threshold.** The remedy is more tests, not a changed
   gate. Do not edit `.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`,
   `.claude/rules/shell.md`, or any file under `.github/instructions/`.
4. **Do not add a bash branch-coverage figure.** kcov does not measure branch coverage; the
   `branch-rate="1.0"` attributes in the Cobertura report are fixed placeholders. Reporting a number
   read from them would be fabrication. The existing evidence correctly refuses to do this; preserve
   that refusal.
5. **Do not create temporary files, scratch git repositories, `mktemp` paths, `$BATS_TMPDIR` usage, or
   `git init` calls in any new test.** All new coverage must route through the existing
   `CLEANUP_WT_GIT_BIN` / `CLEANUP_WT_STUB_SCENARIO` seams against checked-in fixture directories.
   AC19 asserts this and the zero-match search must continue to return nothing.
6. **Do not change any pinned assertion literal** in `test_cleanup_worktrees_enumeration.bats`,
   `test_cleanup_worktrees_classification.bats`, `test_cleanup_worktrees_cli.bats`, or
   `test_cleanup_worktrees_hard_failures.bats`. AC5 and AC6 depend on those lines being unmodified.
   `test_cleanup_worktrees_enumeration.bats` must remain entirely untouched.
7. **Do not exclude any file from the kcov denominator.** The include pattern at
   `scripts/bash/shell_qc_lib.sh:335-336` must not be narrowed, and no `exclude` entry may be added
   for any path under `scripts/`. The Coverage Exclusion Policy in
   `.claude/rules/general-unit-test.md` treats that as a Blocking finding.
8. **Do not exceed the 500-line cap on any shell file.** `cleanup_worktrees_detached_lib.sh` is at
   301; `cleanup_worktrees_lib.sh` at 483 with 17 lines of headroom. If a fix would push a file over,
   add a new file instead. The same cap applies to `.bats` files: the detached suite is at 166 lines
   and roughly 10 new cases will fit, but check before assuming.
9. **Do not widen scope to sibling epic children.** The `DIRTY|` vocabulary and `--clear-disposable`
   (child C / 632), report-mode orphan and stale-ref records (child B / 631), the removal manifest
   (child D / 635), and `PRESERVE` untracked-file consolidation (child F / 637) are explicitly out of
   scope per `spec.md` `## Non-Goals`. R5 records the `COMMIT|` blind spot as a limitation; it does
   not implement a fix for it.
10. **Do not unify `BLOCKED-LOCKED` across the branch-backed path.** `spec.md` limitation L2 records
    the asymmetry deliberately and routes it to a follow-up.
11. **No silent skips.** If a verification command cannot run in the environment (notably `kcov`, which
    has no local route in this worktree, and the `wsl -d Ubuntu -- bash -lc '...'` wrapper form, which
    the worktree-isolation guard refuses), dispatch `.github/workflows/_shell-coverage.yml` with
    `gh workflow run` and record the run ID, head SHA, and conclusion in the evidence artifact, exactly
    as the existing Phase 0 and Phase 7 artifacts do. Do not report a figure that was not measured.
12. **Do not re-mark any acceptance criterion.** All 24 are PASS and already checked. Do not add,
    reword, or remove any AC. Do not treat `issue.md`'s 9-item AC section as authoritative; under work
    mode `full-bug`, `spec.md` is the sole source.

---

## Final verification loop for the remediation plan's last phase

Run in this order and restart from stage 1 if any stage fails or rewrites a file:

```bash
# 1. Format — capture porcelain before and after; the two listings must be byte-identical
git status --porcelain -- tools scripts .claude/lib/bash
bash scripts/bash/shell-qc.sh format
git status --porcelain -- tools scripts .claude/lib/bash

# 2. Lint — must exit 0 with empty stdout AND empty stderr
bash scripts/bash/shell-qc.sh check

# 3. Tests + coverage — no line beginning `not ok`; record the numeric headline
bash scripts/bash/shell-qc.sh test --coverage
# (If kcov has no local route: gh workflow run .github/workflows/_shell-coverage.yml --ref <branch>,
#  then record run ID, head SHA, and conclusion.)

# 4. File-size cap
wc -l scripts/bash/*.sh tests/shell/*.bats | sort -rn | head

# 5. Push-down mirror parity (required if R4 is executed)
diff .claude/skills/cleanup-merged-worktrees/SKILL.md \
     extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md

# 6. Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# 7. Integration pre-check
git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD
```

**Required numeric records for the final evidence artifact:**

- Aggregate `Bash coverage (lines): NN.N%` — must be at or above **85.0**, and should recover toward
  or above the **93.6** baseline once R1 and R2 land.
- Per-file line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh` from
  `shell-coverage/cov.xml` — must be at or above **0.85** (currently **0.806**).
- TAP plan count and the count of lines beginning `not ok` (currently `1..308` and `0`; expect the
  plan count to rise by the number of cases R1-R3 add).

**Evidence location.** All artifacts produced during remediation go to
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/coverage/`, and `artifacts/evidence/` are not used and are enforced
against by the `enforce-evidence-locations.ps1` PreToolUse hook.

---

## Exit gate for this cycle

`blocking_count` is currently **2** (R1 and R2). The cycle closes when a reaudit records zero FAIL
findings and zero material blocking PARTIAL findings — concretely, when the per-file line rate for
`scripts/bash/cleanup_worktrees_detached_lib.sh` is at or above 85%, all seven detached state tokens
are produced by at least one test, and the five fail-closed guards named in R2 are each asserted.
R3-R6 are non-blocking and may be deferred to a follow-up issue at the orchestrator's discretion,
provided that decision is recorded.
