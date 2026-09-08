# Feature Audit: detached-worktree classification and consolidation-branch ordering (Issue #630)

**Audit Date:** 2026-09-07
**Feature Folder:** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630`
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration`
**Head Branch:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/cleanup-merged-worktrees-hardening-integration` (this is an epic child feature; the base is the integration branch, not `main`). Current remote head `288ca2148d159bf2f7a1cbfff6bad3ee5c8d791b`.
- **Head branch/commit:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2` (commit `65a56cb94352c2a19c381acf4008837fa84aee69`)
- **Merge base:** `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`
- **Diff range audited:** `a36b6dca7809e456f00c7d5b01eec5da49f7fca0..65a56cb94352c2a19c381acf4008837fa84aee69` — 94 files changed, 2910 insertions(+), 106 deletions(-). The audit scope is the full branch diff against the resolved base; no caller narrowing was applied or accepted.
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/**` (28 artifacts across `baseline/`, `regression-testing/`, `qa-gates/`, `other/`)
  - Direct re-verification: commands executed by this reviewer against the head worktree, listed in `policy-audit.2026-09-07T12-45.md` Appendix B.
- **Feature folder used:** as above; it is the only active folder whose suffix matches the issue number in the branch name.
- **Requirements source:** `spec.md` **only**.
- **Work mode resolution note:** The marker `- Work Mode: full-bug` is persisted at `issue.md:12`. Under `full-bug`, `.claude/skills/acceptance-criteria-tracking/SKILL.md` resolves the authoritative AC source to `spec.md` alone. `spec.md` restates this at its head: "Under `full-bug`, this document is the sole acceptance-criteria source ... `user-story.md` in this folder carries no acceptance criteria." `user-story.md` (97 lines) was inspected and contains no `## Acceptance Criteria` section. `issue.md` carries its own `## Acceptance Criteria` section of 9 items, which is **context only** under `full-bug` and is not evaluated here; `spec.md` supersedes it and records each divergence under `## Research Corrections Adopted`.
- **Scope note — PR context regeneration.** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were **absent** at review start. Both were regenerated with `poetry run python -m scripts.dev_tools.pr_context.collector --base epic/cleanup-merged-worktrees-hardening-integration --head HEAD --repo-root .`. The regenerated pair carries an identical `Context generated` timestamp (`2026-09-07 12:35:49 UTC`) in both files and a `Head SHA:` of `65a56cb94352c2a19c381acf4008837fa84aee69` in both, satisfying the pair-identity and head-binding freshness cross-checks. The collector independently resolved the merge base to `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`, matching the caller-supplied value.
- **Scope note — coverage-run staleness.** The post-change CI coverage run (34118811332) was dispatched at `fdd0fecf`, one commit behind head. `git diff --stat fdd0fecf 65a56cb9` shows 23 changed files, all Markdown under the feature folder; no `.sh`, `.bats`, or fixture file differs. The coverage and test figures are therefore valid for the head tree. The format and lint gates were additionally re-run at head by this reviewer.
- **Scope note — toolchain substitution.** `kcov` has no local route in this worktree and the plan's `wsl -d Ubuntu -- bash -lc '...'` wrapper form is refused by the worktree-isolation guard. `shfmt` v3.12.0 and `shellcheck` 0.11.0 run natively; `bats` runs as `npx --yes bats` (Bats 1.13.0). Coverage figures come from CI workflow `.github/workflows/_shell-coverage.yml`, whose step executes the identical `bash scripts/bash/shell-qc.sh test --coverage`. Both CI runs were verified by this reviewer with `gh run view` for head SHA, branch, and conclusion.
- **Scope note — pre-existing unrelated failure.** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on an untracked, gitignored `.claude/state/` file (issue #510; green in CI; unrelated to this change set). For AC21 this reviewer did not rely on the executor's recorded pass; the substantive requirement was verified directly with a byte-level `diff` of the two SKILL.md files.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` — **only source** (work mode `full-bug`)
- `docs/features/active/.../user-story.md` — not an AC source; contains no acceptance criteria
- `docs/features/active/.../issue.md` — not an AC source under `full-bug`; context only

**Total acceptance criteria in `spec.md` `## Acceptance Criteria`: 24** (AC1-AC24), all in markdown
checkbox form, counted from the `## Acceptance Criteria` heading to the next equal-or-shallower
heading (`## Verification`).

### Acceptance criteria (abbreviated; full text preserved unmodified in `spec.md`)

1. **AC1** — Report mode emits exactly one `WORKTREE|` record per detached registration, in the form `WORKTREE|<path>|DETACHED|<state>|<flags>`.
2. **AC2** — The detached state is produced by the existing ladder applied to the worktree HEAD SHA; a non-ancestor detached HEAD with a unique residual yields `NOT_MERGED`.
3. **AC3** — The detached-candidate predicate is the `detached` flag with the `main` and `bare` markers absent, not the branch field.
4. **AC4** — Branch-backed worktree records keep the four-field shape `WORKTREE|<path>|<branch>|<flags>` unchanged.
5. **AC5** — `parse_worktree_list` emits the same records as before the change; four pinned literals in `test_cleanup_worktrees_enumeration.bats` unmodified.
6. **AC6** — Each existing `WORKTREE|` assertion enumerated in research §4.4 continues to pass with its assertion text unmodified.
7. **AC7** — Apply mode removes a delete-eligible detached worktree with a non-forced `git worktree remove`, emitting `ACTION|worktree-remove|<path>|OK`.
8. **AC8** — Apply mode attempts no removal for a detached worktree outside the `MERGED_CLEAN`/`MERGED_CONTENT_NEUTRAL`/`MERGED_EQUIVALENT` allowlist.
9. **AC9** — The caller's own detached worktree is protected by normalized path, not branch name, and short-circuits before any classification git call.
10. **AC10** — The main worktree is never a detached candidate.
11. **AC11** — A dirty delete-eligible detached worktree is blocked without force and reports the git status content; `remove_worktree_safe` is unmodified.
12. **AC12** — A locked detached worktree yields the new `BLOCKED-LOCKED` token and invokes no git removal command.
13. **AC13** — A prunable detached worktree is report-only.
14. **AC14** — A hard git failure during detached classification maps to `ANCESTRY_ERROR`, performs no removal, and yields a non-zero apply return code.
15. **AC15** — Same-process re-verification blocks a detached removal when the re-check verdict is outside the allowlist.
16. **AC16** — `verify_consolidation_merged` refuses a zero-commit consolidation branch by tip equality; apply mode emits the block line and deletes nothing.
17. **AC17** — The rejected `rev-list --count` guard form does not ship, and the post-merge cleanup path is not blocked.
18. **AC18** — An empty or unresolvable `rev-parse` on either side of the tip comparison is a hard failure, not an equality match.
19. **AC19** — All new coverage runs through the `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` seams against newly checked-in fixture directories, with no temporary files and no scratch repositories.
20. **AC20** — `SKILL.md` documents the detached record, the new result token, the detached apply-mode behavior, and the consolidation guard.
21. **AC21** — The push-down mirror is content-identical.
22. **AC22** — `cleanup-worktrees.sh --help` describes the detached record.
23. **AC23** — No shell file in `scripts/bash/` exceeds 500 lines, and the detached function group ships in a new file.
24. **AC24** — The bash toolchain loop completes in a single pass: `format` rewrites nothing, `check` exits 0 with empty output, `test --coverage` exits 0 with no `not ok` and `Bash coverage (lines)` at or above 85%.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1 | One five-field detached record per registration | **PASS** | `report_detached_worktrees` emits `WORKTREE\|%s\|DETACHED\|%s\|%s`; the pre-existing loop at `cleanup_worktrees_lib.sh:469` now `continue`s on a detached candidate, making the emission a replacement. Test `report emits one detached record with MERGED_CLEAN` asserts the literal `WORKTREE\|/repo-wt/det\|DETACHED\|MERGED_CLEAN\|detached` and that `grep -c '^WORKTREE\|/repo-wt/det'` equals exactly 1. | `npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats` → `ok 1` | Reviewer read both emission loops and confirmed the skip guard makes duplication structurally impossible, not merely untested. |
| AC2 | Ladder applied to the HEAD SHA; `NOT_MERGED` for a unique residual | **PASS** | `classify_detached_head` calls `classify_ancestry`, `classify_content_neutral`, `classify_cherry_equivalent`, `classify_residual_commit` with the bare SHA. Fixture `detached_unmerged` sets `merge-base.det00002.rc`=1, `diff-quiet.det00002.rc`=1, `cherry.det00002.out`=`+ det00002`, and blob OIDs `blobA` ≠ `blobB`, driving the full ladder to `NOT_MERGED`. | `npx --yes bats ...detached.bats` → `ok 2` | Fixture key values read directly by the reviewer to confirm the ladder is genuinely traversed rather than short-circuited. |
| AC3 | Predicate is the `detached` flag, not the branch field | **PASS** | `is_detached_candidate` tests `,$flags,` for `main`/`bare` first (return 1) then `detached` (return 0). Eight-row matrix asserts 0 for `detached`, `detached,locked`, `detached,prunable` and non-zero for `main`, `main,bare`, `main,detached`, `prunable`, `''`. | `npx --yes bats ...detached.bats` → `ok 3` | The `main,detached` row is the load-bearing one: it proves the exclusion is not merely a branch-field test. Function makes no git call, and the test exercises it with none. |
| AC4 | Branch-backed four-field record unchanged | **PASS** | `printf 'WORKTREE\|%s\|%s\|%s\n'` at `cleanup_worktrees_lib.sh:471` and `cleanup_worktrees_actions_lib.sh:369` is unchanged. Test asserts `WORKTREE\|/repo-wt/feat\|feature-wt\|` against `scenarios/merged_with_worktree`. | `npx --yes bats ...detached.bats` → `ok 4` | Also confirmed by 41/41 ok across the three unmodified-assertion suites. |
| AC5 | `parse_worktree_list` output unchanged; four pinned literals unmodified | **PASS** | `git diff a36b6dca..65a56cb9 -- tests/shell/test_cleanup_worktrees_enumeration.bats` returns **empty** — the file is untouched. `parse_worktree_list` itself is untouched (no diff hunk in `cleanup_worktrees_enumerate_lib.sh`). Cases 14-16 (`parses a branch stanza and marks the first as main`, `parses a detached and locked stanza`, `parses a prunable stanza`) pass. | `git diff ... -- tests/shell/test_cleanup_worktrees_enumeration.bats`; `npx --yes bats tests/shell/test_cleanup_worktrees_enumeration.bats` | The strongest possible evidence: the file did not change at all, so the pinned literals `/repo/main\|aaaa0000\|main\|main`, `/repo-wt/onbranch\|bbbb1111\|some-branch\|`, `/repo-wt/detachedlocked\|cccc2222\|DETACHED\|detached,locked`, `/repo-wt/pruned\|dddd3333\|gonebranch\|prunable` are unmodified by construction. |
| AC6 | Existing `WORKTREE\|` assertions pass with text unmodified | **PASS** | `git diff` on the three named suites shows changes confined to `DLIB=` variable definitions and added `source '${DLIB}'` links in helper chains, plus one appended CLI case. No assertion line at `classification.bats:37,:44,:108`, `cli.bats:33,:61`, or `hard_failures.bats:90,:107` is touched. Full suite exit 0 with zero `not ok`. | `git diff a36b6dca..65a56cb9 -- tests/shell/test_cleanup_worktrees_{classification,cli,hard_failures}.bats`; `npx --yes bats tests/shell/` | Diff inspected line by line by the reviewer. |
| AC7 | Non-forced removal of a delete-eligible detached worktree | **PASS** | `remove_detached_worktree` calls `remove_worktree_safe "$path"` with no force argument; `--force` returns zero matches across all of `scripts/bash/`. Test asserts `ACTION\|worktree-remove\|/repo-wt/det\|OK`, presence of `worktree remove /repo-wt/det` in the stub argv log, and absence of `--force` and `worktree prune`. | `npx --yes bats ...detached.bats` → `ok 5`; `grep -rn -- "--force" scripts/bash/` | Verified for `MERGED_CLEAN` only. `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` reach the same code path by the same `case` arm, but no test produces either token — recorded as a Major code-review finding. The AC text names one delete-eligible removal case and that case is delivered, so the criterion itself is met. |
| AC8 | No removal outside the allowlist | **PASS** | `apply_detached_worktrees` dispatches removal only from a `case` arm listing the three allowlist tokens; `*) : ;;` for everything else. Test asserts `$output` contains `WORKTREE\|/repo-wt/det\|DETACHED\|NOT_MERGED\|detached` and does not contain `worktree remove` or `ACTION\|worktree-remove`. | `npx --yes bats ...detached.bats` → `ok 6` | The positive record assertion is what makes the case falsifiable; without it both negatives would hold even if the library were absent. The test author documented exactly this reasoning inline. |
| AC9 | Caller's own detached worktree protected by path, short-circuiting before classification | **PASS** | `classify_detached_head` runs the `protected-path\|` comparison first and returns `PROTECTED_CURRENT` before reaching `classify_ancestry`. Fixture `detached_current` sets `rev-parse.abbrev-ref-HEAD.out`=`HEAD` and `rev-parse.show-toplevel.out`=`/repo-wt/current`. Test asserts the record, asserts `$output` does **not** contain `merge-base --is-ancestor det00005`, and asserts apply mode emits no `ACTION\|worktree-remove`. | `npx --yes bats ...detached.bats` → `ok 10` | The negative argv assertion is the correct falsifiable form for a short-circuit claim, and it works only because the helper retains stderr so the stub argv log lands in `$output`. |
| AC10 | Main worktree never a detached candidate | **PASS** | `emit_record` always tags the first porcelain stanza with the `main` flag; `is_detached_candidate` returns 1 for any set containing `main` or `bare`. Matrix rows `main`, `main,bare`, `main,detached` all non-zero; first report case asserts `$output` does not contain `WORKTREE\|/repo/main\|DETACHED\|`. | `npx --yes bats ...detached.bats` → `ok 1`, `ok 3` | Reviewer confirmed the `main` tagging in `cleanup_worktrees_enumerate_lib.sh` `emit_record`, so the guarantee is structural. |
| AC11 | Dirty detached worktree blocked without force; `remove_worktree_safe` unmodified | **PASS** | Test asserts `DIRTY\|/repo-wt/det\|?? untracked-artifact.txt`, `ACTION\|worktree-remove\|/repo-wt/det\|BLOCKED-DIRTY`, absence of `--force`, and non-zero apply status. `remove_worktree_safe` unmodified: both `cleanup_worktrees_actions_lib.sh` diff hunks are at old lines 202-207 and 343-351; the function occupies old 252-279 (new 272-299), strictly between them. | `npx --yes bats ...detached.bats` → `ok 7`; `git diff ... -- scripts/bash/cleanup_worktrees_actions_lib.sh \| grep -E "^@@"`; `grep -n "^remove_worktree_safe()" scripts/bash/cleanup_worktrees_actions_lib.sh` | Hunk-header arithmetic verified by the reviewer rather than taken from the evidence artifact. |
| AC12 | Locked detached worktree yields `BLOCKED-LOCKED`, no removal command | **PASS** | `remove_detached_worktree` tests `,$flags,` for `locked` and returns before any git call. `BLOCKED-LOCKED` is a new token; it did not exist in `scripts/bash/` before this change. Test asserts the token and the absence of `worktree remove` and `worktree prune`. | `npx --yes bats ...detached.bats` → `ok 8` | The case does not additionally assert `$status -ne 0`, which the spec's apply-mode exit-code paragraph implies; recorded as a Minor code-review finding. The AC text does not require the status assertion, so the criterion is met. |
| AC13 | Prunable detached worktree is report-only | **PASS** | `remove_detached_worktree` returns 0 with no output for a prunable flag set, after the locked test and before any git call. Test asserts a `WORKTREE\|/repo-wt/det\|DETACHED\|` line in report mode and, in apply mode, no `ACTION\|worktree-remove`, no `worktree remove`, no `worktree prune`. | `npx --yes bats ...detached.bats` → `ok 9` | `git worktree prune` returns zero invocation matches across `scripts/bash/`; the only occurrence is a comment asserting it is never invoked. |
| AC14 | Hard git failure → `ANCESTRY_ERROR`, no removal, non-zero apply rc | **PASS** | Fixture `detached_ancestry_error` sets `merge-base.det00006.rc`=128. Apply-mode case asserts `WORKTREE\|/repo-wt/det\|DETACHED\|ANCESTRY_ERROR`, absence of `worktree remove`, and non-zero `$status`. Unit case asserts `classify_detached_head det00006 /repo-wt/det` returns exactly 2, `$output` contains `ANCESTRY_ERROR` and does not contain `MERGED_CLEAN`. `apply_detached_worktrees` sets `rc=1` and `continue`s before the allowlist `case` on a non-zero classification return. | `npx --yes bats ...detached.bats` → `ok 11`, `ok 13` | Both halves of the AC (driver behavior and unit return code) are delivered as the AC text specifies. |
| AC15 | Re-verification blocks on a flipped verdict | **PASS** | `reverify_detached_delete_eligible` re-runs `classify_detached_head` in-process and emits `ACTION\|worktree-remove\|<path>\|BLOCKED-REVERIFY` with return 1 for any verdict outside the allowlist. Test against `detached_unmerged` asserts `BLOCKED-REVERIFY`, `$status` equals 1, and absence of `worktree remove`. | `npx --yes bats ...detached.bats` → `ok 14` | The hard-failure half of the same function (`((crc != 0))` → `BLOCKED-REVERIFY`) is not exercised; recorded as part of the second Major code-review finding. The AC text specifies the flipped-verdict path, which is delivered. |
| AC16 | Tip-equality refusal of a zero-commit consolidation branch | **PASS** | Pre-check added as the first three statements of `verify_consolidation_merged`, ahead of the best-effort `git fetch`. New fixture `deletion/consolidated_zero_commit/` has `rev-parse.main.out` and `rev-parse.documentationandmemories.out` both `aaaa0000` (read directly by the reviewer) and a `/repo-wt/dm` worktree stanza. Unit case asserts `$status` 1, `NOT_ANCESTOR`, not `MERGED_CLEAN`. Apply case asserts `ACTION\|delete\|documentationandmemories\|BLOCKED-CONSOLIDATION-UNMERGED`, no `branch -D documentationandmemories`, no `worktree remove /repo-wt/dm`. | `npx --yes bats tests/shell/test_cleanup_worktrees_deletion.bats` → `ok 7`, `ok 8` | Both cases the AC names are present and pass. `run_apply` required no change: `consolidation_ok` stays 1 and the pre-existing guard emits the block line. |
| AC17 | Rejected `rev-list --count` form absent; post-merge path not blocked | **PASS** | (a) `grep -rn "rev-list --count" scripts/bash/` returns **no match**. (b) `deletion/consolidated_merged/` gained `rev-parse.main.out`=`aaaa0000` and `rev-parse.documentationandmemories.out`=`dm000001` (distinct, read directly), and the pre-existing case `consolidated-content branch deletion is gated on the merge check` passes unchanged, asserting `branch -D documentationandmemories` and `ACTION\|branch-delete\|documentationandmemories\|OK`. | `grep -rn "rev-list --count" scripts/bash/`; `npx --yes bats tests/shell/test_cleanup_worktrees_deletion.bats` → `ok 6` | Both halves verified independently. The distinct fixture values are what stop the new guard from firing on a genuinely merged branch. |
| AC18 | Empty/unresolvable `rev-parse` is a hard failure, not equality | **PASS** | Pre-check condition is `((ctrc != 0)) \|\| ((mtrc != 0)) \|\| [[ -z $cons_tip \|\| -z $main_tip ]]` → `ANCESTRY_ERROR`, return 2 — evaluated **before** the equality test, so two empty strings can never compare equal. Test uses `scenarios/merged_no_worktree`, which supplies neither `rev-parse` key, and asserts `$status` 2, `ANCESTRY_ERROR`, not `MERGED_CLEAN`, and no `branch -D documentationandmemories`. | `npx --yes bats tests/shell/test_cleanup_worktrees_deletion.bats` → `ok 9` | The AC text names "a scenario in which `rev-parse.main.out` is absent"; the delivered test uses `merged_no_worktree`, in which both keys are absent. That satisfies the criterion and is a strictly stronger input. |
| AC19 | Stub seams, checked-in fixtures, no temp files or scratch repos | **PASS** | Every invocation in the new suite is `run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="$1" ...`. Tracked-file counts: 41 under `tests/fixtures/cleanup_worktrees/scenarios/detached_*`, 9 under `deletion/consolidated_zero_commit/`. `scripts/bash/cleanup_worktrees_detached_lib.sh` is tracked. Zero-match search for `mktemp`, `$BATS_TMPDIR`, `$BATS_TEST_TMPDIR`, `git init`, `/tmp/`. | `git ls-files tests/fixtures/cleanup_worktrees/scenarios/ \| grep detached \| wc -l`; `git ls-files tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/ \| wc -l`; `grep -n "mktemp\|BATS_TMPDIR\|BATS_TEST_TMPDIR\|git init\|/tmp/" tests/shell/test_cleanup_worktrees_detached.bats` | All eight fixture directories the AC enumerates exist and are tracked in git. |
| AC20 | `SKILL.md` documents record, token, apply behavior, consolidation guard | **PASS** | Diff of `.claude/skills/cleanup-merged-worktrees/SKILL.md` adds (a) the literal `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>` with the full seven-token state vocabulary including `ANCESTRY_ERROR`; (b) the literal `BLOCKED-LOCKED` in the apply-mode workflow step; (c) a paragraph on detached apply-mode behavior covering re-verification, non-forced removal, locked, prunable, and dirty; (d) a sentence stating that a consolidation branch whose tip equals `main` is reported `NOT_ANCESTOR` by a tip-equality pre-check and is not delete-eligible. | `git diff a36b6dca..65a56cb9 -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | All four required elements present and read in full by the reviewer. |
| AC21 | Push-down mirror is content-identical | **PASS** | `diff .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` produced **no output** — the files are byte-identical, which is strictly stronger than the content-identical requirement the governing pytest enforces via `Path.read_text(encoding="utf-8")`. Both files show the same +29 line addition in the branch diff. | `diff <repo SKILL.md> <bundled SKILL.md>` | Verified independently of the governing pytest, which fails locally on unrelated pre-existing issue #510 (untracked gitignored `.claude/state/` file; green in CI). The direct byte diff is the stronger evidence for the actual requirement. |
| AC22 | `--help` describes the detached record | **PASS** | `sh scripts/bash/cleanup-worktrees.sh --help` executed by this reviewer: exit code **0**, and stdout contains the literal `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>` together with the full state vocabulary. The usage text is a quoted heredoc (`<<'EOF'`), so no expansion can alter the literal. | `sh scripts/bash/cleanup-worktrees.sh --help; echo "EXIT=$?"` | Verified by direct execution, not inference. The accompanying bats case asserts only `ANCESTRY_ERROR` rather than the record literal — a weaker guard than the AC names, recorded as a Minor code-review finding, but the AC's own requirement is met. |
| AC23 | No `scripts/bash/` file over 500 lines; new file exists and is sourced | **PASS** | `wc -l scripts/bash/*.sh` at head: 483, 406, 379, **301**, 236, 103, 103, 8, 7. Maximum 483 < 500. `scripts/bash/cleanup_worktrees_detached_lib.sh` is tracked in git and sourced at `scripts/bash/cleanup-worktrees.sh:27`, last, after the actions library. | `wc -l scripts/bash/*.sh \| sort -rn`; `git ls-files scripts/bash/cleanup_worktrees_detached_lib.sh`; `sed -n '25,27p' scripts/bash/cleanup-worktrees.sh` | Re-derived at head by the reviewer, not read from the evidence artifact. |
| AC24 | Bash toolchain loop completes in a single pass, coverage >= 85.0 | **PASS** | Stage 1 `format`: exit 0, no output; `git status --porcelain -- tools scripts .claude/lib/bash` before and after byte-identical, proving nothing was rewritten. Stage 2 `check`: exit 0 with empty stdout and stderr — **re-run at head by this reviewer** as `sh scripts/bash/shell-qc.sh check` with the same result. Stage 3 `test --coverage`: exit 0, TAP plan `1..308`, zero lines beginning `not ok`, headline `Bash coverage (lines): 92.9%` — **92.9 >= 85.0**. `evidence/qa-gates/toolchain-single-pass.2026-09-07T14-45.md` records iteration 1 with no restart condition met. No `scripts/bash/` file exceeds 500 lines. | `sh scripts/bash/shell-qc.sh check`; `npx --yes bats tests/shell/`; `gh run view 34118811332 --json headSha,conclusion` | All four sub-conditions the AC enumerates are met. The **aggregate** coverage gate this AC defines passes with 7.9 points of margin. Separately, and outside this AC's text, per-new-file coverage of the 301-line library is 80.6%, below the reviewer's new-code threshold — recorded as a FAIL in `policy-audit.2026-09-07T12-45.md` and routed to remediation. That is a review-contract finding, not an AC failure; AC24 gates the aggregate headline and the aggregate headline passes. |

---

## Summary

**Overall Feature Readiness:** **PASS** (acceptance criteria) / **NEEDS REVISION** (policy compliance)

All 24 acceptance criteria in the authoritative source `spec.md` are delivered and verified. The
feature does what it set out to do: a detached-HEAD worktree is now classified on its own HEAD SHA
against `main`, reported with its state and porcelain flags, and removed in apply mode under the same
allowlist, the same same-process re-verification, and the same non-forced removal that govern
branch-backed worktrees; and a zero-commit `documentationandmemories` branch can no longer be deleted
by an apply pass.

The revision requirement comes from outside the AC set. New-file line coverage of
`scripts/bash/cleanup_worktrees_detached_lib.sh` is 80.6%, below the 85% new-code threshold applied
by this review workflow, and the uncovered region is concentrated on the destructive path: two of the
three delete-eligible verdicts (`MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`) and one non-eligible
verdict (`HAS_UNIQUE_RESIDUALS`) are never produced by any test, and five fail-closed
`ANCESTRY_ERROR`/`BLOCKED-REVERIFY` guards on that same path are never taken. `spec.md` design
constraint D3 anticipated this requirement in its own words — "every function in it must be
exercised" — and while every function is entered, the state space that governs an irreversible action
is not.

**Criteria summary:**
- **PASS:** 24 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing an unconditional PASS:**

1. New-file coverage of 80.6% against an 85% threshold, with `MERGED_CONTENT_NEUTRAL` and
   `MERGED_EQUIVALENT` — both of which authorize `git worktree remove` — never produced by any test.
   Two additional stub fixture directories and roughly four bats cases close it, with no
   production-code change.
2. Five fail-closed error branches on the destructive path unexercised, where the branch-backed
   counterparts already have equivalent coverage in `test_cleanup_worktrees_hard_failures.bats`.
3. Documentation of the apply-mode exit-code change is present in `spec.md` but absent from the
   operator-facing `SKILL.md` and `--help` text; and the detached path's silence in the `COMMIT|`
   namespace is not recorded as a known limitation.

**Recommended follow-up verification steps:**

1. Add `scenarios/detached_content_neutral` (`merge-base.<sha>.rc`=1, `diff-quiet.<sha>.rc`=0) and
   `scenarios/detached_equivalent` (`merge-base` rc 1, `diff-quiet` rc 1, `cherry.<sha>.out`=`- <sha>`),
   with report-mode assertions for both tokens and an apply-mode assertion that `MERGED_EQUIVALENT`
   reaches `ACTION|worktree-remove|...|OK` without `--force`. Re-run
   `bash scripts/bash/shell-qc.sh test --coverage` and confirm the new-file line rate is at or above 85%.
2. Extend the hard-failure fixture family so each ladder rung's non-zero exit is asserted to reach
   `ANCESTRY_ERROR` with no removal, mirroring `test_cleanup_worktrees_hard_failures.bats` cases 1-5.
3. Add `[ "$status" -ne 0 ]` to the locked-worktree case, and assert the record literal (not only
   `ANCESTRY_ERROR`) in the `--help` case.
4. Add one sentence on the apply-mode exit-code change to `SKILL.md` and the `--help` text, keeping
   the push-down mirror in sync; record the detached `COMMIT|` blind spot as `spec.md` limitation L5
   or as a follow-up issue.
5. Re-confirm `git merge-tree --write-tree <base-head> <feature-head>` exits 0 immediately before
   opening the PR, since the integration branch is moving and a sibling child is editing the same
   `SKILL.md`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are
  represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

**Action taken by this reviewer: none required.** All 24 criteria in `spec.md` were already marked
`- [x]` by the executor at commit `65a56cb9`. This reviewer independently evaluated all 24 as PASS,
so every existing check-off is corroborated and no checkbox needed to be added. No checkbox was
changed, and no criterion text was modified. No phantom criterion was added.

### AC Status Summary

- Source: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
- Total AC items: **24**
- Checked off (delivered): **24**
- Remaining (unchecked): **0**
- Items remaining: **None.**

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 24 | 24 | 0 | Checkbox-backed; sole authoritative source under work mode `full-bug`. All 24 independently re-verified as PASS by this reviewer. |
| `user-story.md` | 0 | 0 | 0 | Not an AC source. Contains no `## Acceptance Criteria` section (97 lines inspected). |
| `issue.md` | 9 | 0 | 9 | **Not authoritative** under `full-bug`; context only. Its 9 items are superseded by `spec.md`, whose `## Research Corrections Adopted` records each divergence (notably the tip-equality guard replacing the rejected `rev-list --count` form, and the five-field record replacing the four-field form `issue.md` names). Deliberately left unchecked; checking them would misrepresent `issue.md` as an AC source. |
