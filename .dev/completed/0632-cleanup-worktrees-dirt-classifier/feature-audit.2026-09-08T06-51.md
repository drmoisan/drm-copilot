# Feature Audit — cleanup-worktrees dirt classifier (Issue #632), remediation cycle 1 exit

- Timestamp: 2026-09-08T06-51 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ed84aac2`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
- Work mode: `full-bug`
- AC source: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
  `## Acceptance Criteria` section only

## AC source resolution

`issue.md` carries the work-mode marker `full-bug`, so `spec.md` is the sole acceptance-criteria
source and `user-story.md` is not an AC source for this feature. The `## Acceptance Criteria`
section runs from line 678 to line 850 and contains **45** checkbox items, all `[x]`.

The three unchecked boxes at `spec.md` lines 24, 26, and 27 are the `Blocker` / `Medium` /
`Low` options of a severity radio block inside `## Context`, with `High` checked at line 25.
They are not acceptance criteria and are excluded from the count, consistent with the prior
cycle's treatment.

Two further checked boxes outside the AC section — line 84 (`Attached minimal logs or
screenshot`) and lines 595-599 (the test-plan bullets) — are also excluded.

## Verdict

**42 PASS, 2 PASS-with-note, 1 PARTIAL, 0 FAIL.**

Every acceptance criterion is satisfied as written. The feature nevertheless carries two
blocking findings, recorded in `code-review.2026-09-08T06-51.md` as N1 and N2. Neither maps
to any criterion in the set.

That gap is itself the audit's most important observation, and it is the second cycle in a
row it has appeared. The prior cycle's remediation inputs closed with the same note: "a
complete AC pass and a safe classifier are not currently the same thing." Seven criteria
(AC-39 through AC-45) were added to close that gap for the specific defects cycle 1 found.
They do close those. But the classifier's central safety property — that no rung resolves a
disposable verdict from a read whose result does not support one — still has no criterion
stating it in general terms, so a new instance of the same class (N1) again passes the
whole set.

## Acceptance Criteria evaluation

Numbering follows document order within `## Acceptance Criteria`. Criteria 39 through 45
carry their own `AC-NN —` prefix in the source text; the two numbering schemes agree.

| # | Subject | Verdict | Evidence |
|---:|---|---|---|
| 1 | New library exists, defines the four functions, no source-time work, sourced by the wrapper and every self-sourcing suite | **PASS** | File present at 463 lines; all four functions defined; the wrapper sources it at `cleanup-worktrees.sh:33-37`. The narrowing is verified: of the 14 `test_cleanup_worktrees_*.bats` suites, `scan_helper` and `scan_seam` reference neither library and `cli` references the dirt library but not `cleanup_worktrees_lib.sh`; the other 11 reference both. Tabulated by grep at `HEAD`. |
| 2 | `dirt_build_artifact` fixture + test → `DISPOSABLE_BUILD_ARTIFACT` | **PASS** | Fixture present; reproduced by the reviewer. |
| 3 | `dirt_session_artifact` fixture + test → `DISPOSABLE_SESSION_ARTIFACT` | **PASS** | Fixture present; test at `dirt_classify.bats:97`. Inert against this repository's checkout, disclosed by AC-44. |
| 4 | `dirt_content_on_main` fixture + test → `CONTENT_ON_MAIN` | **PASS** | Fixture present; test at `dirt_classify.bats:116`. |
| 5 | `dirt_content_in_history` fixture + test → `CONTENT_IN_HISTORY` with the SHA in detail | **PASS** | Test at `dirt_classify.bats:134` asserts `CONTENT_IN_HISTORY\|ffff8888`. |
| 6 | `dirt_staged_tree_is_commit` fixture + test → verdict and both detail fields carry the SHA | **PASS** | Tests at `dirt_classify.bats:145` and `:156`. |
| 7 | `dirt_unique` fixture + test → `UNIQUE` and `HAS_UNIQUE` | **PASS** | Test at `dirt_classify.bats:191`. |
| 8 | Every `DIRTFILE\|` verdict is one of the six tokens across the `dirt_*` scenarios | **PARTIAL** | The property holds and is enforced by the test at `dirt_classify.bats:214`, which iterates 25 scenarios, asserts the iterated count equals the on-disk `dirt_*` directory count, and asserts a 30-record union so the membership check cannot pass over an empty set. The criterion's *text* says "the **ten** `dirt_*` scenarios"; there are 25. Stale count in the criterion, not a behavioural gap. Non-blocking. |
| 9 | Rung 1 precedes rungs 2-5, proven by argv-log absence | **PASS** | Test at `dirt_classify.bats:173` with a two-record positive control before the four absence assertions. |
| 10 | Rung 2 is a pure string comparison, no invocation names the path | **PASS** | Test at `dirt_classify.bats:105` with a `status --porcelain` positive control. |
| 11 | Rung 3 precedes rungs 4-5 | **PASS** | Test at `dirt_classify.bats:74` with a rung-3 read positive control. |
| 12 | Rung 4 precedes rung 5 | **PASS** | Test at `dirt_classify.bats:125` with two rung-4 read positive controls. |
| 13 | `dirt_classifier_read_error` → `UNIQUE`, `HAS_UNIQUE`, refused clear | **PASS (note)** | Behaviour verified by the reviewer: verdict `UNIQUE`, aggregate `HAS_UNIQUE`, `ACTION\|dirt-clear\|...\|REFUSED-UNIQUE` at rc 1. The criterion is satisfied. The pin behind it is weak — the fixture's failing read returns no stdout, so the `[[ -z $blob ]]` clause alone carries the verdict and the `((hrc != 0))` clause could be deleted without changing the fixture's output. Carried as finding N2, not as an AC failure. |
| 14 | A non-`HintPath` line in a csproj diff → `UNIQUE`, dedicated test | **PASS** | `dirt_build_artifact_mixed` reproduced; mutation probe confirms the assertion discriminates. |
| 15 | One `DIRTFILE\|` per porcelain entry in order, immediately after the `WORKTREE\|` record, then one `DIRTSUM\|`; detached/`main`/`bare` never classified | **PASS** | The narrowing is verified accurate against `cleanup_worktrees_lib.sh:479-491`: `is_detached_candidate "$wflags" && continue` precedes the `printf` of the `WORKTREE\|` record, and the classification call is guarded by `[[ ,$wflags, != *,main,* && ,$wflags, != *,bare,* ]]`. Placement is pinned by position, not membership, at `dirt_classify.bats:296`. The narrowing is disclosed in the criterion text itself, which names the guard and the three excluded registration kinds, and its rationale is recorded in `evidence/other/deferred-findings.2026-09-08T07-00.md` under F14. It removes an assertion the implementation never satisfied rather than weakening one it did. |
| 16 | `ALL_DISPOSABLE` iff entry count >= 1 and `UNIQUE` count is 0; zero entries emit neither record | **PASS** | Aggregate logic at `dirt_lib.sh:414-419`; the zero-entry half is pinned over live `run_report` stdout at `dirt_regression.bats:109`, with a positive control on the registration whose status read returned nothing. |
| 17 | Detail carries a SHA for two verdicts and is empty for four; path is the last field | **PASS** | `dirt_pipe_path` uses a path containing the delimiter and asserts field 4 is empty. |
| 18 | Eight report scenarios byte-identical, no `DIRTFILE\|`/`DIRTSUM\|` | **PASS** | Eight tests in `dirt_regression.bats` compare against references captured before the classifier existed. |
| 19 | Apply-mode stdout byte-identical for two scenarios without the flag | **PASS** | `dirt_regression.bats:97` and `:105`; the three-field `DIRTY\|` and `BLOCKED-DIRTY` records asserted explicitly. |
| 20 | `remove_worktree_safe` unchanged; two suites pass with no assertion edits | **PASS** | The diff to `cleanup_worktrees_actions_lib.sh` touches only `delete_candidate` and the header; the diffs to both named suites add only a `source` line. |
| 21 | Flag without apply mode exits 2 with usage on stderr | **PASS** | Two tests in `cli.bats` using `2>&1 1>/dev/null` so the stream is asserted, plus an assertion that the usage text names the flag, which distinguishes the deliberate rejection from the pre-existing unknown-argument arm. |
| 22 | Both argument orders dispatch to apply mode | **PASS** | `cli.bats` argument-order test with a precondition that the dirt library exists. |
| 23 | `dirt_mixed_unique_blocks` → `REFUSED-UNIQUE`, no `reset`, no `clean`, no second removal | **PASS** | `dirt_clear.bats:128` and `:137`, the second with an explicit positive control on the refusal record and a removal count of exactly 1. |
| 24 | `dirt_clear_all_disposable` → argv order, `OK` record, none of `--force`/`-x`/`-X`/`-ff` | **PASS** | `dirt_clear.bats:96`, `:110`, `:117`. The flag search matches whole tokens so `-fd` cannot be read as `-ff` and `-U0` cannot be read as carrying `-x`. |
| 25 | `dirt_clear_reverify_order` → second `cherry` after `reset` and before the retry; direct `reverify_delete_eligible` refusal | **PASS** | `dirt_clear.bats:176` and `:195`. Ordinals are taken over the second occurrence, with the reason documented in the suite header. |
| 26 | `worktree remove` from exactly the two existing call sites, no force | **PASS** | Reviewer grep over `cleanup_worktrees_actions_lib.sh`; the clear-and-retry routes through `remove_worktree_safe`. |
| 27 | Report mode non-mutating: eight absence assertions | **PASS** | `dirt_clear.bats:205` with a `diff-index --cached --quiet` positive control. |
| 28 | The stub logs `GIT_INDEX_FILE` when set | **PASS** | `stub-bin/git:83-85`, guarded by `[[ -n ${GIT_INDEX_FILE+x} ]]` so the sentinel can fail in both directions. |
| 29 | `diff-index --cached --quiet` present; every status read carries `--no-optional-locks` | **PASS** | `dirt_clear.bats:224`, asserted by comparing two grep counts rather than by presence alone. |
| 30 | The probe never probes the first `rev-list` entry | **PASS** | `dirt_classify.bats:162`, asserting no `diff-index` names the HEAD sha, with a positive control that the second entry was probed. |
| 31 | `shell-qc.sh format`, `check`, and `test` all clean in a single consecutive pass | **PASS** | Reviewer re-ran `shfmt -d` (exit 0, no diff) and `shellcheck` (exit 0, no findings) over the five changed shell files. `bats` and `kcov` have no local route in this worktree, so the test stage is taken from CI run `34194469882`: `1..404`, 404 `ok`, 0 `not ok`, counted from the run log by the reviewer. Evidence: `evidence/qa-gates/single-consecutive-pass.2026-09-08T07-00.md`. |
| 32 | CI kcov dispatch reports >= 85% repository-wide and >= 85% for the new file | **PASS** | Verified independently from the artifact, not from the evidence file: `gh api .../artifacts/10043508097/zip`, `kcov-merged/cov.xml`. Root `line-rate` `0.937`; recomputed 2164/2310 = 93.68% repo-wide; `cleanup_worktrees_dirt_lib.sh` 158/168 = 94.05%. No branch gate asserted. |
| 33 | Every changed shell file at or under 500 lines, measured at integration time | **PASS** | Measured at `HEAD`: max 496 (`cleanup_worktrees_lib.sh`), then 463, 437, 377, 329, 302, 259, 187 and below. |
| 34 | `SKILL.md` Report Line Contract documents both records and the unchanged `DIRTY\|` shape | **PASS** | Present, with full field lists, the six-token verdict enumeration, and an explicit statement that `DIRTY\|` remains apply-mode-only with an unchanged three-field shape. |
| 35 | `SKILL.md` Prohibited Shortcuts covers the never-force-remove rule and a no-widening bullet | **PASS** | Both present. The no-widening bullet names the fixed three-path array, the absence of any override, and the two-condition build-artifact rule. |
| 36 | `SKILL.md` Triage Procedure amended in three places | **PASS** | The preamble records the machine-readable first pass; step 6 is scoped to the `HintPath`-confined case; step 9 gains the paragraph distinguishing automated clearing of classified-disposable dirt from the never-automated editorial discard of `UNIQUE` content. |
| 37 | Push-down mirror byte-identical; the contract pytest passes | **PASS** | `md5sum` of both copies: `0735a7440c44c59d35dbd194355e5891` (reviewer-run). `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` → `11 passed` (reviewer-run). |
| 38 | Library comment block and wrapper usage document both records and the flag; `--help` contains all three strings | **PASS** | Present in `cleanup_worktrees_lib.sh:44-49` and the wrapper here-doc; pinned by the `--help` test in `cli.bats`. |
| 39 | Rung 1 fires only when Y is a space; both directions pinned from one fixture | **PASS** | `dirt_lib.sh:260`. Reproduced: `MM` → `UNIQUE`, `M ` → `STAGED_TREE_IS_COMMIT\|eeee7777`, both from the same probe result. Mutation probe M1 restores the pre-fix defect exactly, so the fixture discriminates. Genuine, and not a restatement — it names a code property (the Y column) the original 38 never mentioned. |
| 40 | The ` -> ` split applies only to X of `R` or `C`; both directions pinned | **PASS** | `dirt_lib.sh:403`. Reproduced: `?? notes -> draft.md` → full path and `UNIQUE`; `R  old.md -> new.md` → `new.md` and `CONTENT_ON_MAIN`, with an argv-log assertion that no probe names `old.md`. Mutations M2 and M3 both restore the truncation. Genuine. |
| 41 | The header skip is anchored; both directions pinned | **PASS** | `dirt_lib.sh:172`. `dirt_build_artifact_plus_content` → `UNIQUE`; `dirt_build_artifact_added_file` → `DISPOSABLE_BUILD_ARTIFACT` through the `/dev/null` header. Mutation M4 flips the first. The fixture's added line no longer contains the literal it discriminates on, closing the self-reported fifth vacuous case. Genuine. |
| 42 | Five material directions on the staged-tree rung, hard-failure sites counted separately | **PASS** | All five present in `test_cleanup_worktrees_dirt_failclosed.bats`, each with an argv-log positive control where an absence assertion is made. Mutation M5 flips both hard-failure fixtures. Genuine; it demands strictly more than any of the original 38. |
| 43 | Report mode returns the non-zero exit code, emits no dirt record, documented and pinned | **PASS** | Reproduced through `run_report` over `dirty_worktree_status_error`: status 128, `WORKTREE\|/repo-wt/dirty\|feature-dirty\|` present, no `DIRTFILE\|` or `DIRTSUM\|`. Documented in `SKILL.md`. Genuine: it converts an undocumented behaviour change into a stated contract rather than restating existing behaviour. |
| 44 | `DISPOSABLE_SESSION_ARTIFACT` retained as repository-agnostic and inert here; `--ignored` absence pinned | **PASS** | `.gitignore:6` confirmed to ignore `/artifacts`; `SKILL.md` records the decision and forbids the `--ignored` remedy; the test at `dirt_classify.bats:365` asserts absence with a `status --porcelain` positive control. Genuine: it records a decision that would otherwise be an undocumented inert code path. |
| 45 | The new file reports >= 85% kcov line coverage in the CI merged Cobertura | **PASS** | 158/168 = 94.05%, parsed by the reviewer from `kcov-merged/cov.xml` of run `34194469882`. Genuine but overlapping AC-32, which already carries the same figure; it is the narrower of the two and the one that names the file. |

## Assessment of the seven added criteria

AC-39 through AC-45 were checked for the failure mode the task names: a criterion written to
describe what was built rather than to constrain it.

- **AC-39, AC-40, AC-41** each name a specific code property (the Y column, the X-column
  gate, the anchored header forms) and each demands both directions. Each is independently
  falsifiable: the corresponding mutation probe flips the pinned output. Not restatements.
- **AC-42** demands five directions where the original set demanded one. It raises the bar
  rather than describing what exists.
- **AC-43** and **AC-44** convert two behaviours that were undocumented and unpinned into
  stated contracts with tests. AC-44 in particular commits the repository to a decision
  (retain the verdict, do not add `--ignored`) that constrains future work.
- **AC-45** is narrower than AC-32 and overlaps it: AC-32 already required both the
  repository-wide and the per-file figure. AC-45 is not self-serving, but it is redundant.
  Recorded as an observation only.

None of the seven is a restatement of what was built. All seven are satisfied.

## Both-directions coverage of the six verdicts

The standing obligation was re-checked for every verdict, including over the new fixtures.

| Verdict | Positive fixture | Near-miss fixture | Reviewer-confirmed discriminating |
|---|---|---|---|
| `DISPOSABLE_BUILD_ARTIFACT` | `dirt_build_artifact`, `dirt_build_artifact_added_file` | `dirt_build_artifact_mixed`, `dirt_build_artifact_plus_content` | Yes (M4) |
| `DISPOSABLE_SESSION_ARTIFACT` | `dirt_session_artifact` | `dirt_quoted_path` | Yes (M11 — verdict unchanged but the argv-log assertion fails) |
| `CONTENT_ON_MAIN` | `dirt_content_on_main`, `dirt_pipe_path` | `dirt_unique`, `dirt_content_in_history` | Yes |
| `CONTENT_IN_HISTORY` | `dirt_content_in_history`, `dirt_history_depth_fallback` | `dirt_unique`, `dirt_history_read_error` | **Partial** — the near-miss does not discriminate the fail-closed guard (N2) |
| `STAGED_TREE_IS_COMMIT` | `dirt_staged_tree_is_commit`, `dirt_staged_tree_worktree_delta` (`M ` half) | `dirt_staged_tree_no_match`, `dirt_staged_probe_revlist_error`, `dirt_staged_probe_diffindex_error`, `dirt_staged_tree_worktree_delta` (`MM` half) | Yes (M1, M5) |
| `UNIQUE` | every near-miss above | every disposable fixture | Yes |

The one gap is `CONTENT_IN_HISTORY`'s fail-closed near miss and the three related guards,
recorded as N2.

## Criteria not satisfied

None.

## Findings not covered by any criterion

- **N1** — rung 4 resolves `CONTENT_ON_MAIN` from a `diff --quiet` exit 0 over a pathspec
  that matched nothing, so an `AD` entry whose content exists only in the index aggregates
  `ALL_DISPOSABLE` and is cleared. No criterion in the set constrains rung 4's inference.
- **N2** — four safety guards whose removal changes no checked-in scenario's output. AC-42
  covers the staged-tree rung's hard-failure sites specifically, which is why those two are
  discriminating; the four in N2 sit on rungs no criterion reaches.

A criterion of the form "no rung resolves a disposable verdict from a probe whose result
does not establish one, pinned by a fixture in which removing the guard changes the
aggregate" would have caught both, and would have caught R1, R2, and R5 in cycle 1.
Recommended for cycle 2's AC additions.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
- Total AC items: 45
- Checked off (delivered): 45
- Remaining (unchecked): 0
- Items remaining: none

No criterion was newly checked or unchecked by this review. AC-8 evaluates PARTIAL on a
stale count in its own text rather than on unmet behaviour; under the check-off protocol a
PARTIAL leaves the box unchecked, but unchecking it here would misreport delivered work,
because the property the criterion states is enforced by a test that is stricter than the
text. The correct remedy is a text correction in cycle 2, and the box is left checked with
this note recorded.
