# Remediation Inputs — cleanup-worktrees dirt classifier (Issue #632)

- Timestamp: 2026-09-08T05-00
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680ebcebaabbba10faaa490e46a717686535`

## Source Artifacts

- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/policy-audit.2026-09-08T05-00.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/code-review.2026-09-08T05-00.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/feature-audit.2026-09-08T05-00.md`

## Blocking Findings (6)

### R1 — `MM`/`AM` entries: rung 1 ignores the unstaged worktree delta

- Severity: **FAIL**. Data loss on the feature's own destructive flag.
- Source: code review **F1**; policy audit **P18**.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:229-240`.
- Problem: rung 1 tests only the porcelain **X** column. `dirt_staged_tree_commit` answers
  a question about the index (`diff-index --cached`), which says nothing about a non-space
  **Y** column. An entry such as `MM path` is therefore labelled `STAGED_TREE_IS_COMMIT`,
  the worktree aggregates `ALL_DISPOSABLE`, and `--clear-disposable` runs `reset --hard`,
  destroying an unstaged modification that exists in no commit and not in the index.
- Reproduced end to end: `DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|MM|src/a.cs`,
  `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|eeee7777`, then
  `ACTION|dirt-clear|/repo-wt/dirt|OK` (emitted only after `reset --hard` and `clean -fd`
  both returned 0).
- Required change: honour rung 1 only when `${xy:1:1}` is a space. Otherwise fall through to
  the lower rungs, which compare working-tree content, or resolve `UNIQUE`.
- Required test: fixture `dirt_staged_tree_worktree_delta` with `MM src/a.cs` and a matching
  ancestor tree; assert the verdict is **not** `STAGED_TREE_IS_COMMIT` and the aggregate is
  **not** `ALL_DISPOSABLE`. Pin the `M ` case in the same fixture family so the fix is
  pinned in both directions.

### R2 — Unconditional ` -> ` split misclassifies and misreports untracked paths

- Severity: **FAIL**. Data loss plus a wrong path in the audit record.
- Source: code review **F2**; feature audit AC-15.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:366-367`.
- Problem: the `OLD -> NEW` split is applied to every status entry, not only `R`/`C`. A
  space does not trigger C-quoting, so an untracked file named `notes -> draft.md` is
  reported verbatim and then truncated to `draft.md`. Every probe is issued against the
  wrong path, and the emitted `DIRTFILE|` record names the wrong file.
- Reproduced: `?? notes -> draft.md` -> `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|draft.md`
  and `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|`. Correct verdict is `UNIQUE`.
- Required change: `[[ ${xy:0:1} == R || ${xy:0:1} == C ]] && rel="${rel#* -> }"`.
- Required test: fixture with `?? notes -> draft.md` asserting the record's path field is
  the full literal and the verdict is not disposable; plus an `R` fixture asserting the
  split still occurs for a genuine rename.

### R3 — New-file line coverage below the uniform threshold

- Severity: **FAIL**.
- Source: policy audit **P12**; corroborated by the branch's own
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`.
- Measurement: `scripts/bash/cleanup_worktrees_dirt_lib.sh` at **82.63%** (138/167), against
  the uniform 85% line floor. Repo-wide bash coverage is 92.9% and passes. No modified file
  regressed. CI run 34182198357 at headSha `ad6bc946...`.
- Problem: the 29 uncovered lines are concentrated on the fail-closed machinery — the
  branches that decide what happens when a classifier git read fails. That is the property
  preventing a "safe to delete" verdict about unrecoverable content.
- Uncovered lines: `74, 75, 76, 77, 95, 98, 113, 114, 117, 148, 151, 155, 160, 190, 191,
  233, 234, 258, 259, 269, 270, 273, 274, 305, 308, 309, 343, 415, 416`.
- Required change: new scenario entries driving the uncovered fail-closed branches — the
  staged-probe `rev-list` failure (95/98), the `diff-index` exit-above-1 failure (113/114),
  the no-match return (117), the HintPath diff read failure (148/151/155), the
  `log --find-object` failure (305), the tracked-half `CONTENT_ON_MAIN` emission (269/270),
  the build-artifact filename fallthrough (190/191), and the `dirt-clear FAILED` record for
  a failed `reset --hard` (415/416).
- Note: `74`–`77` is the session-artifact constant array; its uncovered status is a symptom
  of R6 and will resolve with the decision recorded there, or persist as a documented
  consequence.

### R4 — `STAGED_TREE_IS_COMMIT` pinned in only one of three material directions

- Severity: **FAIL** against the standing both-directions obligation.
- Source: code review **F3**; policy audit **P18**.
- Problem: `dirt_staged_tree_is_commit` is the only fixture in the set with a non-space X
  column, and in it the probe matches. The only near-miss pinned is "the X column is a
  space". Unpinned: (a) a staged entry whose index matches no ancestor tree; (b) a rung-1
  hard read failure mapping to `UNIQUE` (lines 233/234 never executed); (c) a staged entry
  with a non-space Y column (that is R1).
- Verified behaviour today for (a) and (b): both correctly return `UNIQUE` / `HAS_UNIQUE`.
  This is a missing-pin finding, not a second live defect — but it is on the rung where a
  false positive is most expensive, and nothing currently holds it.
- Required test: `dirt_staged_tree_no_match` and `dirt_staged_probe_read_error` (one variant
  per hard-failure site). These also close most of R3.

### R5 — Diff header filter is content-blind

- Severity: **PARTIAL, blocking**. Fail-open on the build-artifact rung.
- Source: code review **F4**; feature audit AC-14.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:157-167`.
- Problem: `"+++ "* | "--- "*) continue` also drops an added line whose content begins
  `++ ` and a removed line whose content begins `-- `. Such a line is neither counted toward
  `changed` nor tested for `HintPath`, so the entry can resolve
  `DISPOSABLE_BUILD_ARTIFACT` despite carrying a real non-HintPath change. This directly
  contradicts AC-14.
- Reproduced: a `-U0` diff with one genuine `HintPath` rewrite plus
  `+++ this line is real added content and is NOT a HintPath rewrite` yields
  `DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj` and
  `ALL_DISPOSABLE`.
- Required change: anchor the header skip to the forms git emits
  (`"--- a/"*`, `"+++ b/"*`, `"--- /dev/null"`, `"+++ /dev/null"`), or track position
  relative to each `diff --git` line and skip exactly the two headers that follow it.
- Required test: fixture whose csproj diff contains a `++`-leading added line; assert
  `UNIQUE`.

### R6 — Two undocumented, unpinned behaviour changes needing a recorded decision

Grouped because both need a decision rather than necessarily a code change, and both are
blocking only until that decision is recorded in the spec and `SKILL.md`.

**R6a — Report-mode exit code changed from 0 to 128** (code review **F5**; policy audit
**P22**). Verified against both trees under `dirty_worktree_status_error`:
`HEAD report-mode exit code = 128`, `BASE report-mode exit code = 0`. The wrapper propagates
it. AC-18 pins report-mode stdout for eight scenarios, none with a failing status read;
`dirty_worktree_status_error` is pinned in apply mode only. `SKILL.md` gained no
report-mode exit-status note, though issue 631 set the precedent of documenting exactly such
a change for apply mode.
Resolve by either (i) adding an AC and a test pinning report-mode exit 128 for that
scenario plus a `SKILL.md` note, or (ii) suppressing the propagation and emitting a `WARN|`
record instead.

**R6b — `DISPOSABLE_SESSION_ARTIFACT` cannot fire in this repository** (code review **F6**;
policy audit **P22**). All three hard-coded paths are gitignored:
`git check-ignore -v` returns `.gitignore:6:/artifacts` for each. The library reads status
without `--ignored` by deliberate design, so ignored files never become entries. Confirmed
empirically: `artifacts/orchestration/orchestrator-state.json` exists on disk in this
worktree and does not appear in `git status --porcelain`. One of the six required verdicts,
and one of the three dirt categories the issue enumerated from the 2026-09-06 run, is inert
against a real checkout; the stub cannot reveal this because it replays a hand-written
status file.
Resolve by re-deriving the 2026-09-06 observation and then either recording rung 2 as
retained-but-inert for this repository, or reconsidering the class.
**Do not** resolve by adding `--ignored` to the status read — the library header's argument
against that is sound, and adding it would pull build output into the clearable set.

## Non-Blocking Findings

Carried for disposition; none blocks merge on its own.

| ID | Title | Suggested action |
|---|---|---|
| F7 | `cleanup_worktrees_lib.sh` calls `classify_worktree_dirt` without sourcing or guarding for it; missing dependency yields rc 127 swallowed by `\|\|` and a silently unclassified report | Add a `declare -F` guard with an explicit error, or a header note |
| F8 | Apply mode with the flag discards the `DIRTFILE\|`/`DIRTSUM\|` records it computes, so the destructive action leaves no per-file justification | Emit the captured classification when the clear proceeds |
| F9 | `rc=$?` at the new `run_report` call site departs from the documented max-rc contract | Use the `if ((crc > rc))` idiom |
| F10 | `awk -F'\|'` aggregate extraction assumes no `\|` in the worktree path | Match the literal token or read fields from the right |
| F11 | The clear hook fires on any `remove_worktree_safe` failure, not only a dirt-caused one | Add a comment recording that the hook keys on the return code, not on a `BLOCKED-DIRTY` determination |
| F12 | The clear is unscoped and TOCTOU-exposed relative to the classification | One sentence in the `SKILL.md` flag description |
| F13 | Three doc/code mismatches: `SKILL.md` names only `*.csproj` where the code also accepts `packages.config`/`app.config`; `SKILL.md` omits that detached/main/bare registrations are never classified; the library header renders two four-field contracts as five-field | Correct all three |
| F14 | Detached-HEAD registrations receive no dirt records, against AC-15's literal text | Extend classification to them, or narrow the AC |

## Acceptance-Criteria Reconciliation

Three currently-checked criteria evaluate PARTIAL and should be unchecked by the
remediation pass, then re-checked once the corresponding work lands:

- **AC-1** — 11 of 13 `test_cleanup_worktrees_*.bats` suites source the library;
  `test_cleanup_worktrees_scan_helper.bats` and `test_cleanup_worktrees_scan_seam.bats` do
  not. Either narrow the AC text or add the two sources.
- **AC-14** — contradicted by R5.
- **AC-15** — contradicted by R2 (wrong path in the record) and F14 (detached registrations).

Two criteria remain unchecked:

- **AC-31** — PENDING. The toolchain loop must restart after the above remediation.
- **AC-32** — text satisfied (92.9% >= 85.0%, CI run 34182198357). Commit
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`, which is currently
  untracked, and the box may be checked.

Consider also adding an acceptance criterion covering the porcelain **Y** column in the
staged-tree rung and one covering path parsing for non-rename entries. The two most serious
defects in this change both sit outside the criteria as written, which is itself a finding
for the spec: a complete AC pass and a safe classifier are not currently the same thing.

## Suggested Order of Work

1. R1 and R2 — the two live data-loss paths, with their pins.
2. R5 — one-pattern fix with its pin.
3. R4 — the missing near-miss scenarios (largely shared with R3).
4. R3 — remaining fail-closed coverage scenarios; re-run coverage and confirm the new file
   clears 85%.
5. R6a and R6b — record the decisions; amend spec and `SKILL.md`.
6. Non-blocking F7–F14 as scoped.
7. Restart the toolchain loop from stage 1 and re-declare AC-31.
