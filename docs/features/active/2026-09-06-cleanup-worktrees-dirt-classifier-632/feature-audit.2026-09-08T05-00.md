# Feature Audit — cleanup-worktrees dirt classifier (Issue #632)

- Timestamp: 2026-09-08T05-00
- HostClockAtWrite: 2026-09-08T03-17Z (nominal run-timestamp scheme)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
- Baseline: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680ebcebaabbba10faaa490e46a717686535`
- Work mode: `full-bug` (marker read from `issue.md`: `- Work Mode: full-bug`)
- AC source: `spec.md` **only**

## AC Source Resolution

`issue.md` carries `- Work Mode: full-bug`, which resolves the acceptance-criteria source
to `spec.md` alone. `user-story.md` is present in the feature folder but is **not** an AC
source under this mode and was not evaluated.

The `## Acceptance Criteria` section of `spec.md` (lines 614–740) contains **38** checkbox
items: 36 marked `[x]`, 2 marked `[ ]`.

The three unchecked boxes in `## Context` are the Blocker/High/Medium/Low severity radio
block. They are not acceptance criteria and were neither counted nor evaluated, per the
scoping instruction and per the section-bounded counting rule.

## Verdict Legend

- **PASS** — verified satisfied at this commit.
- **PARTIAL** — substantially delivered but the criterion's literal text is not fully met,
  or a defect exists inside its subject area.
- **PENDING** — cannot yet be verified; the blocking input is external and in progress.
- **FAIL** — not satisfied.

## Evaluation

| # | Acceptance Criterion (abbreviated) | Box | Verdict | Evidence |
|---|---|---|---|---|
| 1 | New library exists, defines the four functions, runs nothing at source time, sourced by the wrapper and by every `test_cleanup_worktrees_*.bats` suite | [x] | **PARTIAL** | Library present at 425 lines; all four functions defined; no work at source time (constants and function definitions only). Wrapper sources it at `cleanup-worktrees.sh:36`. But **11 of 13** matching suites reference it: `test_cleanup_worktrees_scan_helper.bats` (refs=0) and `test_cleanup_worktrees_scan_seam.bats` (refs=0) do not. See AC-1 note below. |
| 2 | `dirt_build_artifact` fixture + test asserts `DISPOSABLE_BUILD_ARTIFACT` for a HintPath-only `*.csproj` diff | [x] | PASS | Fixture checked in; test at `dirt_classify.bats:60` asserts the exact record. |
| 3 | `dirt_session_artifact` fixture + test asserts `DISPOSABLE_SESSION_ARTIFACT` | [x] | PASS | Fixture and test present (`dirt_classify.bats:97`). Reachability caveat in code review F6 does not affect this criterion's literal text. |
| 4 | `dirt_content_on_main` fixture + test asserts `CONTENT_ON_MAIN` for an untracked blob equal to `main:<path>` | [x] | PASS | `dirt_classify.bats:116`; fixture supplies `hash-object` and `rev-parse main:` responses. |
| 5 | `dirt_content_in_history` fixture + test asserts `CONTENT_IN_HISTORY` with the `log --find-object` SHA in the detail field | [x] | PASS | `dirt_classify.bats:134` asserts `...|CONTENT_IN_HISTORY|ffff8888|??|docs/old.md`. |
| 6 | `dirt_staged_tree_is_commit` fixture + test asserts `STAGED_TREE_IS_COMMIT` with the commit SHA and the same SHA in `DIRTSUM` detail | [x] | PASS | `dirt_classify.bats:145` and `:156`. Both halves asserted. Coverage gaps around this verdict are recorded against AC-8/AC-32 and code review F3, not here. |
| 7 | `dirt_unique` fixture + test asserts `UNIQUE` and `HAS_UNIQUE` | [x] | PASS | `dirt_classify.bats:191`. |
| 8 | Verdict field is one of exactly the six tokens; no other token produced by any `dirt_*` scenario | [x] | PASS | `dirt_classify.bats:214` iterates fifteen scenarios (a superset of the ten named), guards vacuity with `[ "$seen" -eq 17 ]`, and checks membership. |
| 9 | `dirt_staged_tree_is_commit`: no `hash-object`, no `diff --quiet main`, no `log --find-object` for the staged paths | [x] | PASS | `dirt_classify.bats:173`, with two positive-control record assertions added by the absence-assertion audit. |
| 10 | `dirt_session_artifact`: no git invocation names the artifact path | [x] | PASS | `dirt_classify.bats:105`; rung 2 is a pure string comparison with no git call. |
| 11 | `dirt_build_artifact`: no `log --find-object` for that path | [x] | PASS | `dirt_classify.bats:74`, positive control is a `diff` naming the csproj. |
| 12 | `dirt_content_on_main`: no `log --find-object` | [x] | PASS | `dirt_classify.bats:125`, positive controls are both rung-4 reads. |
| 13 | `dirt_classifier_read_error` fixture + test: a non-zero classifier read yields `UNIQUE`, `HAS_UNIQUE`, and a refused clear | [x] | PASS | `dirt_classify.bats:203` and `dirt_clear.bats:152`. Satisfied for the `hash-object` read. That it exercises only one of nine such read sites is recorded against AC-32 and code review F3. |
| 14 | A `*.csproj` diff carrying at least one non-`HintPath` changed line is `UNIQUE`, pinned by a dedicated test | [x] | **PARTIAL** | `dirt_build_artifact_mixed` pins the ordinary case. Counterexample reproduced: an added line whose content begins with `++ ` is skipped as a diff header, is neither counted nor `HintPath`-tested, and the entry resolves `DISPOSABLE_BUILD_ARTIFACT`. Code review **F4**. |
| 15 | Exactly one `DIRTFILE` per porcelain entry, in porcelain order, immediately after the `WORKTREE` record, then exactly one `DIRTSUM`; `dirt_mixed_unique_blocks` pins the two-entry case | [x] | **PARTIAL** | Count, order, and placement verified (`dirt_classify.bats:241` and `:283`, the latter asserting by line position). But the record's path field does not faithfully reproduce the porcelain entry for an untracked path containing the literal ` -> `: reproduced as `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|??\|draft.md` for the entry `?? notes -> draft.md`. Code review **F2**. Detached registrations receive no records at all (**F14**). |
| 16 | `DIRTSUM` aggregate is `ALL_DISPOSABLE` iff entry count >= 1 and `UNIQUE` count is 0; zero entries emits neither record | [x] | PASS | Rule implemented at `dirt_lib.sh:376-381`. Zero-entry half pinned live at `dirt_regression.bats:109` against `merged_with_worktree`, with a positive control. |
| 17 | Detail field carries a SHA for the two SHA-bearing verdicts and is empty for the other four; the file path is the last field, pinned by a pipe-character fixture | [x] | PASS | `dirt_pipe_path` asserts `docs/a\|b.md` recovered intact and field 4 empty (`dirt_classify.bats:252`). Field ordering holds; the *value* problem for ` -> ` paths is recorded against AC-15. |
| 18 | Eight report scenarios byte-identical to checked-in expected output, with no `DIRTFILE`/`DIRTSUM` line | [x] | PASS | **Independently verified.** Base tree extracted with `git archive 4ffe680e`; all eight expected files reproduce the BASE libraries' stdout byte for byte (`MATCH` x8, `fail=0`). The references are genuine pre-change captures, so the pins can fail. |
| 19 | Apply-mode stdout without the flag byte-identical for `dirty_worktree` and `dirty_worktree_status_error`, retaining the three-field `DIRTY\|` and `BLOCKED-DIRTY`, no new records | [x] | PASS | **Independently verified** by the same method (`MATCH apply.dirty_worktree`, `MATCH apply.dirty_worktree_status_error`). `dirt_regression.bats:97` additionally asserts the two named records. |
| 20 | `remove_worktree_safe` unchanged; `hard_failures` and `deletion` suites pass with no assertion edits, only the added `source` | [x] | PASS | Full diff of both suites read: changes are confined to `setup()` variable definitions and inline `bash -c` source lists. No assertion text differs. `remove_worktree_safe` is textually unmodified. |
| 21 | `--clear-disposable` alone and `report --clear-disposable` each exit 2 with usage on stderr | [x] | PASS | **Verified first-hand:** `flag-alone exit=2`, `report+flag exit=2`. Pinned at `cli.bats:94` and `:109`, both asserting the usage text names the flag so the pre-existing unknown-argument arm cannot satisfy them. |
| 22 | `--apply --clear-disposable` and `--clear-disposable --apply` both dispatch to apply mode | [x] | PASS | `cli.bats:125` runs both orders and asserts an apply-mode `ACTION` record plus the absence of usage text. |
| 23 | `dirt_mixed_unique_blocks` fixture + test: `REFUSED-UNIQUE`, no `reset --hard`, no `clean`, no second `worktree remove` | [x] | PASS | `dirt_clear.bats:128` and `:137`, the latter with a `REFUSED-UNIQUE` positive control and an exact `worktree remove` count of 1. |
| 24 | `dirt_clear_all_disposable` fixture + test: argv order `reset --hard` -> `clean -fd` -> `worktree remove`; `OK` record; none of `--force`, `-x`, `-X`, `-ff` | [x] | PASS | `dirt_clear.bats:96`, `:110`, `:117`. Force-flag assertion matches whole tokens. `grep -rn -- "--force" scripts/bash/` returns nothing. |
| 25 | `dirt_clear_reverify_order` fixture + test: second `cherry` after `reset --hard` and before the removal retry; direct test of `reverify_delete_eligible` refusing a non-eligible branch | [x] | PASS | `dirt_clear.bats:176` (ordinal, with an exact cherry count of 2) and `:195`. |
| 26 | `git worktree remove` invoked from exactly the two existing call sites with no force flag; the retry introduces no third site | [x] | PASS | `grep -n "worktree remove" cleanup_worktrees_actions_lib.sh` -> lines 191 and 292 only (plus one comment). The retry calls `remove_worktree_safe`, which owns line 292. |
| 27 | Report mode non-mutating over `dirt_staged_tree_is_commit`: no `write-tree`, no `GIT_INDEX_FILE`, no `/index`, no `reset`, no `clean`, no `worktree remove`, no `branch -D`, no `hash-object -w` | [x] | PASS | `dirt_clear.bats:205`, with a `diff-index --cached --quiet` positive control. Confirmed by reading the library: the staged-tree answer is reached with `diff-index --cached` against the existing index and there is no `write-tree` and no index redirect anywhere in the file. |
| 28 | The stub logs `GIT_INDEX_FILE` to stderr when and only when it is set | [x] | PASS | `stub-bin/git:83-85`, guarded by `[[ -n ${GIT_INDEX_FILE+x} ]]`. The guard is load-bearing in both directions and the stub says so. |
| 29 | `diff-index --cached --quiet` appears in the argv log, and every `status --porcelain` from the new library carries `--no-optional-locks` | [x] | PASS | `dirt_clear.bats:224` compares two counts rather than asserting presence, so it fails if any status read lacks the flag. The library's single status read (`dirt_lib.sh:341`) carries it. |
| 30 | The staged-tree probe never probes the first `rev-list` entry, pinned by asserting no `diff-index` names the fixture's HEAD SHA | [x] | PASS | `dirt_classify.bats:162` asserts `diff-index --cached --quiet eeee7777` is present and `... dddd9999` is absent. Implemented by the `first=1` skip at `dirt_lib.sh:102-105`. This is the highest-consequence detail in the design and it is both implemented and pinned. |
| 31 | `shell-qc.sh` `format`, `check`, and `test` each complete with no error in a single consecutive pass | [ ] | **PENDING** | The three stages each returned 0 at this commit: format (before/after digests identical), check (no shfmt hunk, no shellcheck finding), test (390/390). I re-ran `shfmt -d` and `shellcheck -x` first-hand at this commit: both clean. The pass is nonetheless not declarable because the remediation required by AC-14, AC-15 and the coverage finding will restart the loop. The executor's `single-consecutive-pass-blocked.2026-09-08T03-30.md` correctly declines the declaration filename. |
| 32 | `shell-qc.sh test --coverage` reports kcov line coverage of at least 85%; no branch gate asserted | [ ] | **PASS (evidence not yet committed)** | CI run 34182198357 at headSha `ad6bc946...` reports `Bash coverage (lines): 92.9%`, above the 85.0% floor, with no branch figure asserted. The criterion's literal text is met. The box is left unchecked because the evidence artifact `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md` is **untracked** and would not travel with the PR. Separately, the same report shows the new library itself at 82.63%, below the uniform 85% new-file threshold — that is a policy-audit finding (P12), not a failure of this criterion's text. |
| 33 | Every changed or added shell file is at or under 500 lines, measured at integration time | [x] | PASS | **Re-measured at review time.** Maximum 496 (`cleanup_worktrees_lib.sh`); new library 425; largest new suite 300; stub 362. |
| 34 | `SKILL.md` Report Line Contract documents `DIRTFILE\|` and `DIRTSUM\|` with field lists and states `DIRTY\|` remains apply-mode-only with an unchanged three-field shape | [x] | PASS | `SKILL.md:78-100`. All three clauses present and accurate. |
| 35 | `SKILL.md` Prohibited Shortcuts states `--clear-disposable` is not an exception to never-force-remove and is not force-removal, plus a bullet prohibiting widening the disposable definition | [x] | PASS | Both bullets present. The widening bullet is thorough: it names the fixed array, the absence of any override, the two-condition build-artifact rule, and the `--ignored`/`-x` prohibition. One inaccuracy in that bullet is recorded as code review F13 (it names only `*.csproj` where the code also accepts `packages.config` and `app.config`). |
| 36 | `SKILL.md` Triage Procedure states report mode now precedes it with the two records, scopes step 6 to the HintPath-confined case, and amends step 9 to distinguish automated clearing from editorial discard | [x] | PASS | All three amendments present at `SKILL.md:214-219`, `:270-278`, `:311-321`. The step 9 amendment draws the distinction explicitly and correctly. |
| 37 | The mirrored `SKILL.md` is byte-identical to the canonical file and the push-down contract test passes | [x] | PASS | **Independently verified:** both files hash to `fbe6ef448196d4ee371285c025db53fc919c25db881095eb5e04ab6d4d610537`. Exactly one `.claude/**` file changed on this branch, so there is no unmirrored edit. The pytest half is taken from `evidence/qa-gates/pytest-push-down-contract-final.2026-09-08T03-30.md`; the Python toolchain was not available to re-run it here. |
| 38 | The `cleanup_worktrees_lib.sh` contract comment and the wrapper `usage` here-doc both document `DIRTFILE\|`, `DIRTSUM\|`, and `--clear-disposable`; `--help` contains all three, pinned by a CLI test | [x] | PASS | **Verified first-hand:** `--help` emits `--clear-disposable` (line 15), `DIRTFILE\|` (line 33), `DIRTSUM\|` (line 34). Contract comment present at `cleanup_worktrees_lib.sh:47-48`. Pinned at `cli.bats:143`. |

## Tally

| Verdict | Count |
|---|---|
| PASS | 33 |
| PARTIAL | 3 (AC-1, AC-14, AC-15) |
| PENDING | 1 (AC-31) |
| FAIL | 0 |
| PASS with evidence not committed | 1 (AC-32) |
| **Total** | **38** |

No acceptance criterion is outright unsatisfied. The two most consequential defects found in
this review — the `MM`/`AM` staged-tree fail-open (F1) and the ` -> ` path split (F2) — are
notable precisely because they sit **outside** the criteria as written: no AC requires the
staged-tree verdict to account for the porcelain Y column, and no AC constrains path parsing
for entries that are not renames. A complete AC pass and a safe classifier are not the same
thing here, and that gap is itself a finding for the spec.

## AC-1 Note

AC-1 requires the library to be "sourced by ... every `tests/shell/test_cleanup_worktrees_*.bats`
suite". Measured:

```
test_cleanup_worktrees_classification.bats     refs=1
test_cleanup_worktrees_cli.bats                refs=1
test_cleanup_worktrees_consolidation.bats      refs=1
test_cleanup_worktrees_deletion.bats           refs=1
test_cleanup_worktrees_detached.bats           refs=1
test_cleanup_worktrees_dirt_classify.bats      refs=2
test_cleanup_worktrees_dirt_clear.bats         refs=1
test_cleanup_worktrees_dirt_regression.bats    refs=1
test_cleanup_worktrees_enumeration.bats        refs=1
test_cleanup_worktrees_hard_failures.bats      refs=1
test_cleanup_worktrees_report_records.bats     refs=1
test_cleanup_worktrees_scan_helper.bats        refs=0   <-- omitted
test_cleanup_worktrees_scan_seam.bats          refs=0   <-- omitted
```

`test_cleanup_worktrees_scan_helper.bats` sources no cleanup library at all (it drives the
standalone scan helper script), and `test_cleanup_worktrees_scan_seam.bats` sources only the
report-records library. Adding the dirt library to those two would be inert.

This is an AC-precision problem, not a defect: the criterion's purpose is to prove the
"runs nothing at source time" contract broadly, and eleven suites do prove it. Resolve by
narrowing the AC text to the suites that source the cleanup library family, or by adding the
two sources for uniformity. Either way the box should not remain checked against the current
text.

## Baseline Comparison

Behaviour delivered relative to `4ffe680e`:

| Behaviour | Baseline | This branch |
|---|---|---|
| Report mode dirt classification | none | one `DIRTFILE\|` per status entry, one `DIRTSUM\|` per dirty worktree, for branch-backed non-main non-bare registrations |
| Verdict vocabulary | none | six tokens, membership-pinned |
| Apply mode without the flag | `DIRTY\|` + `BLOCKED-DIRTY` | byte-identical (verified) |
| Apply mode with `--clear-disposable` | flag did not exist | `reset --hard` -> `clean -fd` -> re-verify -> unforced retry, gated on `ALL_DISPOSABLE` |
| `git worktree remove` force flag | none | none (unchanged) |
| Report-mode exit code on a per-worktree status read failure | 0 | 128 (unpinned, undocumented — code review F5) |
| bats test count | 343 | 390 (+47) |
| bash line coverage, repo-wide | 93.5% | 92.9% |
| `cleanup_worktrees_dirt_lib.sh` line coverage | n/a (new) | 82.63% (below the 85% floor) |

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md
- Total AC items: 38
- Checked off (delivered): 36
- Remaining (unchecked): 2
- Items remaining:
  1. `wsl -d Ubuntu -- bash -lc '... shell-qc.sh format'` and the same command with
     `check` and with `test` each complete with no error in a single consecutive pass.
     (AC-31 — PENDING; the loop must restart after remediation.)
  2. `wsl -d Ubuntu -- bash -lc '... shell-qc.sh test --coverage'` reports kcov line
     coverage of at least 85%; no branch-coverage gate applies to bash, and none is
     asserted. (AC-32 — text satisfied at 92.9%; box left unchecked only because the
     supporting evidence artifact is untracked.)
```

## Check-Off Actions Taken

No checkbox in `spec.md` was modified by this review.

- No unchecked item was checked. AC-32's text is satisfied, but its evidence artifact is
  untracked and therefore absent from the branch diff; checking it would assert a delivery
  the PR does not carry. Commit that artifact and the box may be checked.
- Three currently-checked items — **AC-1, AC-14, AC-15** — evaluate PARTIAL. The check-off
  protocol authorises reviewers to check items forward, not to uncheck them, so they are
  recorded here for the remediation pass to reconcile rather than silently reverted.

## Remediation Required

Yes. See `remediation-inputs.2026-09-08T05-00.md`.
