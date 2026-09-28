# Code Review — cleanup-worktrees dirt classifier (Issue #632)

- Timestamp: 2026-09-08T05-00
- HostClockAtWrite: 2026-09-08T03-17Z (nominal run-timestamp scheme)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680ebcebaabbba10faaa490e46a717686535`
- Primary review obligation: classifier correctness. A false "safe to delete" verdict
  destroys user work.

## Method

The classifier was reviewed adversarially rather than by reading alone. I extracted the
base tree with `git archive`, built scenario fixtures against the checked-in stub seam, and
drove `classify_worktree_dirt`, `delete_candidate`, and `run_report` directly at both trees.
Every finding below marked "reproduced" carries the observed output verbatim.

## Findings Summary

| ID | Severity | Area | Title |
|---|---|---|---|
| F1 | **FAIL — blocking** | Classifier | `MM`/`AM` entries: rung 1 ignores the unstaged worktree delta, and the clear destroys it |
| F2 | **FAIL — blocking** | Classifier | Unconditional ` -> ` split misclassifies and misreports untracked paths containing that literal |
| F3 | **FAIL — blocking** | Tests | `STAGED_TREE_IS_COMMIT` is pinned in only one of three material directions |
| F4 | **PARTIAL — blocking** | Classifier | Diff header filter is content-blind; a `++`-leading added line is skipped as a header |
| F5 | **PARTIAL — blocking** | Compatibility | Report-mode exit code changed from 0 to 128, undocumented and unpinned |
| F6 | **PARTIAL — blocking** | Efficacy | `DISPOSABLE_SESSION_ARTIFACT` cannot fire against a real checkout of this repository |
| F7 | PARTIAL | Structure | `cleanup_worktrees_lib.sh` hard-depends on a function it neither sources nor guards |
| F8 | Advisory | Observability | Apply mode with the flag emits no `DIRTFILE|`/`DIRTSUM|` audit record |
| F9 | Advisory | Correctness | `rc=$?` at the new call site departs from the documented max-rc contract |
| F10 | Advisory | Robustness | `awk -F'\|'` aggregate extraction assumes no pipe in the worktree path |
| F11 | Advisory | Design | Clear hook fires on any removal failure, not only `BLOCKED-DIRTY` |
| F12 | Advisory | Design | Clear is unscoped and TOCTOU-exposed relative to the classification |
| F13 | Advisory | Docs | Three doc/code mismatches in `SKILL.md` and the library header |
| F14 | Advisory | Coverage | Detached-HEAD registrations are never classified |

Blocking count: **6** (3 FAIL, 3 blocking-PARTIAL).

## What Is Done Well

Stated first because it is load-bearing for the severity calibration below: this is a
careful piece of work, and most of the safety machinery is right.

- The **one-sided bound asymmetry** is stated as an invariant in the header and then
  actually held throughout. Every bound (`CLEANUP_WT_STAGED_TREE_DEPTH`,
  `CLEANUP_WT_HISTORY_SCAN_DEPTH`) and every unmatched probe degrades to `UNIQUE`, which
  makes the worktree `HAS_UNIQUE`, which refuses the clear.
- The **two-way classification of non-zero exits** is the subtlest thing in the file and it
  is correct. `rev-parse main:<path>` exiting non-zero and `diff --quiet main` exiting 1 are
  defined negative answers that advance the ladder; `status`, `hash-object`,
  `log --find-object`, and `diff-index` above 1 carry no verdict and fail closed. The header
  explains why collapsing them would make `CONTENT_IN_HISTORY` unreachable. I verified both
  halves by driving them.
- **No index or object-database write anywhere.** The staged-tree answer is reached with
  `diff-index --cached --quiet <sha> --` against the existing index, never `write-tree`,
  and no `GIT_INDEX_FILE` redirect exists. The stub deliberately defines no arm for any
  writing subcommand so the non-mutation assertion cannot be defeated by adding one, and it
  logs `GIT_INDEX_FILE` to stderr only when set, which makes the environment half of that
  assertion able to fail in both directions. This is a well-built guard.
- **Vacuous confinement is closed.** `dirt_is_build_artifact` returns "not a build
  artifact" when the two diffs contain zero changed content lines, so a read that returned
  nothing cannot resolve to a disposable verdict.
- **C-quoted payloads are refused outright** with no unquoting attempt, and the near-miss
  fixture `dirt_quoted_path` is chosen so that its unquoted prefix is exactly a
  session-artifact path — it defeats both a prefix match and an unquoting implementation.
- **The probe drops the first `rev-list` entry** (HEAD), whose tree an unmodified index
  always equals, and the test asserts by SHA that the HEAD SHA is never passed to
  `diff-index`. Without that drop every staged entry in every worktree would be labelled
  disposable. This is the single highest-consequence detail in the design and it is both
  implemented and pinned.
- The **session-artifact list is a hard-coded array with no override**, matched exactly and
  never by prefix, with the rationale (a runtime override would defeat the `UNIQUE` gate)
  written next to it.
- **`remove_worktree_safe` is textually unmodified** and its single `git worktree remove`
  still carries no force flag. `grep -n "worktree remove"` finds exactly the two
  pre-existing call sites in the actions library; `grep -rn -- "--force"` across
  `scripts/bash/` finds none. The clear-and-retry routes through the same unforced call.
- **The absence-assertion discipline** in the new suites is above the repository norm.
  Nearly every negative assertion carries an explicit positive control in the same body,
  with a comment saying what would otherwise make it vacuous. The three repaired instances
  and the wrapper-flag propagation gap are recorded in
  `evidence/qa-gates/absence-assertion-audit.2026-09-08T01-30.md` and
  `evidence/qa-gates/wrapper-clear-flag-mutation.2026-09-08T03-30.md`. I re-audited the
  remaining negative assertions independently and found no unhandled fourth instance; the
  one candidate (the trailing log assertion in the `dirt_quoted_path` test) is explicitly
  considered in that audit and its justification holds.
- **The byte-identity references are real.** I replayed all ten pinned scenarios through
  the *base* tree's libraries and every checked-in `expected/*.out` matched byte for byte,
  so the regression pins can actually fail.

The findings below are what survives that.

---

## F1 — `MM`/`AM` entries: rung 1 ignores the unstaged worktree delta (FAIL, blocking)

**Location:** `scripts/bash/cleanup_worktrees_dirt_lib.sh:229-240`

```bash
# Rung 1. Staged entries only: the X column is the index status, and a space,
# question mark, or exclamation mark there means the entry is not staged.
if [[ $x != " " && $x != "?" && $x != "!" ]]; then
        ...
        printf 'STAGED_TREE_IS_COMMIT|%s\n' "$staged"
```

The rung inspects only the **X** column. `git status --porcelain` is two columns: X is
index-versus-HEAD, Y is **worktree-versus-index**. An entry such as `MM path` means the
index differs from HEAD *and* the working tree differs from the index.

`dirt_staged_tree_commit` answers a question about the **index** only — it compares the
index against candidate commit trees with `diff-index --cached --quiet`, which by design
ignores the working tree. So a match establishes that the *staged* content is recoverable
from commit `<sha>`. It establishes nothing at all about the Y-column delta, which exists
in no commit and not even in the index.

The verdict `STAGED_TREE_IS_COMMIT` is disposable, so a worktree whose only dirt is `MM`
aggregates to `ALL_DISPOSABLE`, and `--clear-disposable` runs `git reset --hard`, which
destroys the unstaged worktree modification permanently.

**Reproduced — classification:**

```
status --porcelain:  MM src/a.cs
rev-list HEAD:       dddd9999 / eeee7777      diff-index eeee7777 -> rc 0

DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|MM|src/a.cs
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|eeee7777
```

**Reproduced — end to end through `delete_candidate` with the flag armed:**

```
stub-git: worktree remove /repo-wt/dirt
ACTION|worktree-remove|/repo-wt/dirt|BLOCKED-DIRTY
ACTION|dirt-clear|/repo-wt/dirt|OK          <- reset --hard and clean -fd both ran
stub-git: worktree remove /repo-wt/dirt
ACTION|worktree-remove|/repo-wt/dirt|BLOCKED-DIRTY
```

The `OK` record is emitted only after both `reset --hard` and `clean -fd` return 0. The
unstaged delta is gone.

This is not a hypothetical shape. The issue's own motivating observation is a worktree that
"carried 86 staged changes that were exactly an earlier commit"; any one of those 86 paths
that also had a subsequent unstaged edit falls into this hole. It is the exact failure mode
the feature exists to prevent, produced by the one verdict that declares tracked, modified
content disposable.

The library header's own framing condemns it: "Every bound and every match in this file
fails in the safe direction." This match does not.

**Remediation.** Honour rung 1 only when the Y column establishes that the working tree
equals the index — that is, only when `${xy:1:1}` is a space. An entry with a non-space Y
column should fall through to the lower rungs (which compare *working-tree* content) or, if
no lower rung resolves it, be `UNIQUE`. Pin it with a `dirt_staged_tree_worktree_delta`
fixture carrying `MM src/a.cs` and asserting the verdict is **not**
`STAGED_TREE_IS_COMMIT` and the aggregate is **not** `ALL_DISPOSABLE`.

## F2 — Unconditional ` -> ` split misclassifies untracked paths (FAIL, blocking)

**Location:** `scripts/bash/cleanup_worktrees_dirt_lib.sh:366-367`

```bash
# A rename or copy entry's payload is `OLD -> NEW`; the destination is the path
# that exists in the working tree and is therefore the one classified.
[[ $rel == *" -> "* ]] && rel="${rel#* -> }"
```

The comment scopes this to rename and copy entries, but the code applies it to **every**
status entry regardless of the status code. `git status --porcelain` uses the `OLD -> NEW`
payload only for `R` and `C` entries; for every other code the payload is a single path.
A space is not a character that triggers C-quoting, so an ordinary untracked file named
`notes -> draft.md` is reported verbatim as `?? notes -> draft.md` and is then silently
truncated to `draft.md`.

Two defects follow from the one line:

1. **Wrong verdict, in the disposable direction.** Every subsequent probe is issued against
   `draft.md`. If `draft.md` happens to exist on `main` with matching content — a
   commonplace situation for a scratch copy — the entry resolves `CONTENT_ON_MAIN`, the
   worktree aggregates `ALL_DISPOSABLE`, and `clean -fd` deletes the real
   `notes -> draft.md`, which exists nowhere.
2. **Wrong path in the record.** The `DIRTFILE|` record names `draft.md`. The operator's
   audit trail therefore names a file that is not the one about to be destroyed. This also
   breaks the contract AC-14 states — "exactly one `DIRTFILE|` record per
   `git status --porcelain` entry" — in substance if not in count, and it undermines the
   path-last field ordering that AC-16 and `dirt_pipe_path` exist to protect.

**Reproduced:**

```
status --porcelain:  ?? notes -> draft.md
hash-object draft.md -> blob1111        rev-parse main:draft.md -> blob1111

DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|draft.md
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
```

The correct verdict for `notes -> draft.md` is `UNIQUE`.

**Remediation.** Gate the split on the status code:

```bash
[[ ${xy:0:1} == R || ${xy:0:1} == C ]] && rel="${rel#* -> }"
```

Pin with a fixture carrying `?? notes -> draft.md` that asserts the record's path field is
the full literal and the verdict is not disposable. Consider also asserting the `R` case is
still split correctly, so the fix is pinned in both directions.

## F3 — `STAGED_TREE_IS_COMMIT` is pinned in only one of three material directions (FAIL, blocking)

**Location:** `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, and the fixture set
generally.

`dirt_staged_tree_is_commit` is the **only** scenario in the entire fixture set whose status
output has a non-space X column:

```
dirt_staged_tree_is_commit/status._repo-wt_dirt.out:M  src/a.cs
dirt_staged_tree_is_commit/status._repo-wt_dirt.out:M  src/b.cs
(every other dirt_* scenario is '??' or ' M')
```

and in it the probe matches. The suite header names `dirt_build_artifact` ("an unstaged X
column") as the near-miss. That pins only that rung 1 does not fire for an unstaged entry.
Three directions that matter are unpinned:

1. **Staged entry, index matches no ancestor tree.** Nothing asserts the probe's no-match
   return produces a non-`STAGED_TREE_IS_COMMIT` verdict. kcov confirms line 117 (the
   probe's `return 1`) is never executed.
2. **Rung-1 hard read failure.** The `staged == "ERROR"` → `UNIQUE` branch at lines 232–235
   is executed by no test — kcov reports lines 233 and 234 uncovered, along with the
   probe's two `return 2` sites at 98 and 114. AC-13's `dirt_classifier_read_error`
   scenario uses an untracked entry, so `any_staged` is 0 and the probe never runs.
   This is the fail-closed branch for the most dangerous rung, and it has never executed.
3. **Staged entry with a non-space Y column** — F1.

I verified (1) and (2) behave correctly today by driving them directly, so this is a
missing-pin finding rather than a second live defect:

```
REPRO C  M  src/a.cs, diff-index eeee7777 -> rc 1 (no match)
         -> DIRTFILE|/repo-wt/dirt|UNIQUE||M |src/a.cs
            DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|

REPRO D  M  src/a.cs, rev-list HEAD -> rc 128
         -> DIRTFILE|/repo-wt/dirt|UNIQUE||M |src/a.cs
            DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

But "correct and unpinned" on the branch that decides what happens when a classifier read
fails is exactly the state the standing both-directions obligation exists to prevent: the
next edit to that ladder has nothing holding it.

**Remediation.** Add three scenarios: `dirt_staged_tree_no_match`,
`dirt_staged_probe_read_error` (one variant per hard-failure site: `rev-list` non-zero and
`diff-index` exiting above 1), and the `dirt_staged_tree_worktree_delta` from F1. These
also close most of the P12 coverage shortfall.

## F4 — Diff header filter is content-blind (PARTIAL, blocking)

**Location:** `scripts/bash/cleanup_worktrees_dirt_lib.sh:157-167`

```bash
case "$line" in
"+++ "* | "--- "*) continue ;;
"+"* | "-"*) ;;
*) continue ;;
esac
```

The intent, correctly stated in the docstring, is to exclude the `---`/`+++` file headers
before counting changed lines. The pattern is content-blind: it also drops any **added**
line whose content begins with `++ `, and any **removed** line whose content begins with
`-- `. Such a line is neither counted toward `changed` nor tested for `HintPath`, so it is
invisible to the confinement rule. That is the fail-open direction — a real content change
is treated as though it were absent, and the entry can resolve
`DISPOSABLE_BUILD_ARTIFACT`.

**Reproduced:**

```
diff for src/Legacy/Legacy.csproj (-U0):
  ...
  -      <HintPath>..\..\packages\X.dll</HintPath>
  +      <HintPath>..\packages\X.dll</HintPath>
  @@ -41,0 +42 @@
  +++ this line is real added content and is NOT a HintPath rewrite

DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
```

Severity is tempered by realism: the rung is reachable only for `*.csproj`,
`packages.config`, and `app.config`, whose lines are XML and in practice leading-whitespace
indented, and the entry must additionally contain at least one genuine `HintPath` line to
avoid the `total == 0` guard. I rate it blocking rather than advisory because the fix is one
pattern, the failure direction is destruction, and this is the rung whose *whole point* —
per both the docstring and the amended `SKILL.md` "Never widen" bullet — is that content
confinement, not the path pattern, is the definition of the class.

**Remediation.** Anchor to the header forms git actually emits, e.g.
`"--- a/"* | "+++ b/"* | "--- /dev/null" | "+++ /dev/null") continue ;;`, or track position
relative to each `diff --git` line and skip exactly the two headers that follow it. Pin with
a fixture whose diff contains a `++`-leading added line and assert `UNIQUE`.

## F5 — Report-mode exit code changed from 0 to 128 (PARTIAL, blocking)

**Location:** `scripts/bash/cleanup_worktrees_lib.sh:484-486`

```bash
if [[ ,$wflags, != *,main,* && ,$wflags, != *,bare,* ]]; then
        classify_worktree_dirt "$wpath" || rc=$?
fi
```

`classify_worktree_dirt` returns git's exit code on a hard `status --porcelain` failure.
That propagates through `run_report`'s `return "$rc"` and through the wrapper's
`run_report || exit_code=$?` / `return "$exit_code"`.

**Verified against both trees** under the `dirty_worktree_status_error` scenario:

```
HEAD report-mode exit code = 128
BASE report-mode exit code = 0
```

Report mode is the read-only diagnostic pass the skill's triage procedure runs first. A
checkout containing one worktree whose status read fails now makes the whole report exit
128, where it previously exited 0 and produced a complete report. Callers and wrappers that
treat non-zero as "the run failed" will abort.

The intent is defensible and is stated in the classifier docstring ("a read failure can
never be mistaken for a clean worktree"). The problem is that the consequence is invisible:
AC-16 pins report-mode stdout for eight scenarios, none with a failing status read;
`dirty_worktree_status_error` is pinned in apply mode only; and `SKILL.md` gained no
report-mode exit-status note, though issue 631 set the precedent of documenting exactly
such a change for apply mode.

**Remediation.** Decide and record which behaviour is intended. If propagation is intended,
add an AC and a test pinning report-mode exit 128 for `dirty_worktree_status_error`, and add
a `SKILL.md` note mirroring the existing apply-mode one. If it is not, suppress the
propagation and emit a `WARN|` record instead.

## F6 — `DISPOSABLE_SESSION_ARTIFACT` cannot fire in this repository (PARTIAL, blocking)

**Location:** `scripts/bash/cleanup_worktrees_dirt_lib.sh:74-78` (the constant array) and
`:341` (the status read).

All three hard-coded session-artifact paths are gitignored in this repository:

```
$ git check-ignore -v artifacts/pr_context.summary.txt \
      artifacts/pr_context.appendix.txt artifacts/orchestration/orchestrator-state.json
.gitignore:6:/artifacts   artifacts/pr_context.summary.txt
.gitignore:6:/artifacts   artifacts/pr_context.appendix.txt
.gitignore:6:/artifacts   artifacts/orchestration/orchestrator-state.json
```

The library reads `status --porcelain` without `--ignored`, deliberately and with a good
reason written in the header. Ignored files therefore never become entries, so rung 2 can
never match. Confirmed empirically in this very worktree:
`artifacts/orchestration/orchestrator-state.json` exists on disk (32 KB, dated 2026-09-07)
and `git status --porcelain` does not list it.

Corroborating signal from the coverage report: lines 74–77, the constant array itself, are
among the uncovered lines — consistent with a rung reached only through synthetic fixture
status lines that real git would not emit.

This is an efficacy finding, not a safety finding: the failure direction is `UNIQUE`, so
nothing is destroyed. But one of the six required verdicts, and one of the three dirt
categories the issue enumerated from the 2026-09-06 run, is dead code against a real
checkout — and the tests cannot reveal that, because the stub replays a hand-written status
file rather than deriving it from a repository.

**Remediation.** Re-derive the 2026-09-06 observation: establish whether those paths were
genuinely reported by `git status --porcelain` in the affected worktrees, and if so under
what `.gitignore` state. Then either (a) record in the spec and `SKILL.md` that rung 2 is
retained for checkouts that do not ignore `artifacts/`, and accept it as inert here, or
(b) reconsider the class. Do **not** resolve this by adding `--ignored` to the status read:
the header's argument against that is sound and adding it would pull build output into the
classified — and therefore clearable — set.

## F7 — `cleanup_worktrees_lib.sh` hard-depends on an unsourced function (PARTIAL)

`run_report` now calls `classify_worktree_dirt`, which lives in
`cleanup_worktrees_dirt_lib.sh`. `cleanup_worktrees_lib.sh` neither sources that file nor
guards for the function's presence, and its own record-contract comment block gained the
two record lines without gaining a dependency note. The dirt library documents its
dependency on `cleanup_worktrees_enumerate_lib.sh` as a MUST; the reverse dependency is
undocumented.

Failure mode: a consumer that sources the report libraries without the dirt library gets
`classify_worktree_dirt: command not found`, rc 127 — swallowed by the `|| rc=$?` — and a
report in which all dirt classification is silently missing while the run exits 127. The
wrapper sources correctly and AC-1 requires every `test_cleanup_worktrees_*.bats` suite to
source it, so the in-repo consumers are covered; the hazard is for future ones.

**Remediation.** Add a `declare -F classify_worktree_dirt >/dev/null || { ...; }` guard with
an explicit error, or state the sourcing requirement in `cleanup_worktrees_lib.sh`'s header
next to the two new record lines.

## F8 — Apply mode with the flag emits no per-file audit record (Advisory)

`clear_disposable_dirt` calls `classify_worktree_dirt`, captures its stdout into `cout`, and
uses it only to extract the aggregate:

```bash
cout=$(classify_worktree_dirt "$wt") || crc=$?
agg=$(printf '%s\n' "$cout" | awk -F'|' '/^DIRTSUM\|/{print $3; exit}')
```

The `DIRTFILE|` records are discarded. `run_apply` does not call the classifier itself, so
`--apply --clear-disposable` produces `ACTION|dirt-clear|<path>|OK` and nothing else. The
operator sees that a destructive clear happened but not which files were declared
disposable or on what grounds — the justification for an irreversible action is computed and
then thrown away.

AC-17 requires no `DIRTFILE|` in apply mode *without* the flag, and says nothing about with
it, so this is not an AC violation. It is nonetheless the wrong default for a destructive
path. Consider emitting the captured `cout` when the clear proceeds; the existing byte-identity
pins are unaffected because they run without the flag.

## F9 — `rc=$?` departs from the documented max-rc contract (Advisory)

`run_report`'s docstring states it "Returns the maximum return code observed", and the
`classify_all_branches` call site implements that with `if ((crc > rc)); then rc=$crc; fi`.
The new call site uses bare `rc=$?`, so a classifier failure (rc 1) can overwrite a higher
`run_report_scans` rc (rc 2). The adjacent `report_detached_worktrees` line has the same
shape and predates this change, so the pattern is inherited rather than introduced — but
this change adds an instance to a function whose contract says otherwise.

## F10 — Aggregate extraction assumes no pipe in the worktree path (Advisory)

`awk -F'|' '/^DIRTSUM\|/{print $3; exit}'` reads the aggregate from field 3, which is
correct only while the worktree path (field 2) contains no `|`. The record contract goes to
deliberate lengths to put the *file* path last for exactly this reason, and
`dirt_pipe_path` pins it; the worktree path gets no equivalent protection in either record.
Low likelihood, cheap to harden (match on the literal `ALL_DISPOSABLE` as the last field, or
anchor with a fixed-field-count read from the right).

## F11 — Clear hook fires on any removal failure (Advisory)

`delete_candidate` invokes the hook on `if ! remove_worktree_safe "$wt_path"`.
`remove_worktree_safe` returns 1 for *any* `git worktree remove` failure — locked worktree,
missing path, submodule — and unconditionally labels the outcome `BLOCKED-DIRTY`. So the
clear can fire for a removal that failed for a reason unrelated to dirt.

The blast radius is bounded: `clear_disposable_dirt` still refuses unless every entry is
disposable, and a worktree with no dirt produces no aggregate and refuses. So this widens
*when* the clear may run, not *what* it may destroy. Worth a comment recording that the hook
keys on `remove_worktree_safe`'s return rather than on a `BLOCKED-DIRTY` determination,
since the two are not the same thing.

## F12 — The clear is unscoped and TOCTOU-exposed (Advisory)

`reset --hard` and `clean -fd` operate on the whole worktree, not on the set of entries that
were classified. A file created between the classification's status read and the `clean`
is deleted without ever having been classified. The window is short in a single-pass run,
and this is inherent to using `reset`/`clean` rather than per-path operations, but it is
worth one sentence in the `SKILL.md` `--clear-disposable` description so an operator does not
read "only classified-disposable dirt is cleared" more literally than the implementation
supports.

## F13 — Doc/code mismatches (Advisory)

1. `SKILL.md`, "Never widen the definition of disposable dirt": "The build-artifact rule
   requires both conditions together — the `*.csproj` path pattern and the content
   confinement". The code also accepts `packages.config`, `app.config`, and their `*/`
   forms (`cleanup_worktrees_dirt_lib.sh:190`). The doc understates the path set.
2. `SKILL.md` describes `DIRTFILE|` as emitted "in porcelain order immediately after that
   worktree's `WORKTREE|` record", without noting that detached, `main`, and `bare`
   registrations are never classified (see F14). A reader would expect a record after every
   `WORKTREE|` line.
3. The library header renders two contracts as though they had an extra field:
   `DIRTSUM|<worktree-path>|ALL_DISPOSABLE|HAS_UNIQUE|<detail>` and
   `ACTION|dirt-clear|<worktree-path>|OK|REFUSED-UNIQUE|FAILED`. Both records have four
   fields; the pipes here are alternation, not delimiters. The wrapper's `usage` text gets
   this right (`DIRTSUM|<worktree>|<aggregate>|<detail>`); the header should match it.

## F14 — Detached-HEAD registrations are never classified (Advisory)

`run_report` skips detached registrations (`is_detached_candidate "$wflags" && continue`)
before reaching the new call, and `report_detached_worktrees` emits their `WORKTREE|` records
without any dirt records. AC-14 says "For each worktree with dirt, report mode emits exactly
one `DIRTFILE|` record per `git status --porcelain` entry ... immediately after that
worktree's `WORKTREE|` record", which reads as covering detached registrations too.

The direction is safe — no verdicts means no clear — and detached worktrees are not branch
deletion candidates, so nothing is destroyed. But the operator gets no triage information for
exactly the worktrees issue 631 just made more visible. Either extend the classification to
detached registrations or amend AC-14 to scope it to branch-backed ones.

## Test Suite Review

Beyond F3, the suites are strong. Specific observations:

- The **two-driver split** in `test_cleanup_worktrees_dirt_clear.bats` (direct
  `delete_candidate` for the ordinal assertions, plus a wrapper-driven pair for the flag
  pre-pass) is correctly reasoned and correctly documented: without the wrapper pair, a
  wrapper that never set `CLEANUP_WT_CLEAR_DISPOSABLE` would leave the feature permanently
  disarmed and every other test would still pass. The `env -u` in `wrapper_apply` closes the
  ambient-value hole. This is the gap recorded in
  `evidence/qa-gates/wrapper-clear-flag-mutation.2026-09-08T03-30.md` and it is properly
  closed.
- The **"second occurrence is the subject"** reasoning for the ordinal assertions is right:
  `remove_worktree_safe` issues `worktree remove` before it reads status, so a first-match
  idiom would compare against a line preceding `reset --hard`.
- The **token-membership test** guards against vacuity with `[ "$seen" -eq 17 ]`, an
  explicit count over the fifteen scenarios. Without it the membership check would pass over
  an empty union.
- The **placement test** asserts by line position relative to the `WORKTREE|` record rather
  than by membership, which is the only way to pin the placement clause.
- The **force-flag assertion** matches whole tokens (`grep -qE '(^| )(--force|-x|-X|-ff|-fdx|-fdX)( |$)'`)
  with a comment explaining that `-fd` must not read as `-ff` and `-U0` must not read as
  carrying `-x`. That is the right level of care.
- The **`--no-optional-locks` assertion** compares two counts rather than asserting presence,
  so it fails if any status read lacks the flag rather than passing on the first one that
  has it.
- Modifications to the eight pre-existing suites are confined to `setup()` variable
  definitions and inline `bash -c` source lists. No assertion text changed anywhere, which
  satisfies AC-18. Verified by reading the full diff of all eight files.

One suggestion, not a finding: `dirt_session_artifact`'s log test uses
`[[ "$log" == *"status --porcelain"* ]]` as its positive control. That proves the classifier
ran its status read, not that the entry reached a rung-2 verdict. The preceding test pins the
verdict for the same scenario, so the pair is adequate, but a control asserting the
`DISPOSABLE_SESSION_ARTIFACT` record in the same body would match the pattern used in test 12.

## Design and Structure

- Placing the classifier in a new sibling library rather than growing
  `cleanup_worktrees_lib.sh` past the 500-line cap is the right call and is reasoned in the
  issue's "Suspected Cause" section.
- The functions are small and single-purpose: a bounded probe, a pure string matcher, a diff
  reader, a per-entry ladder, a per-worktree driver, a clearing sequence. `classify_dirt_entry`
  at 116 lines is the largest and is a linear ladder rather than nested logic, which is
  appropriate for a precedence rule that must be auditable.
- Issuing the staged-tree probe once per worktree, and only when at least one entry is
  actually staged, is a good optimisation that costs nothing in clarity.
- The header comment block is long but every paragraph earns its place: each one records a
  decision that a future edit could silently reverse. This is the right way to document a
  safety-critical file.

## Recommendation

Do not merge as-is. F1 and F2 are live data-loss paths on the feature's own destructive
flag and both were reproduced end to end. F4 is a third fail-open with a one-line fix. F3
and the P12 coverage shortfall are the same underlying gap seen from two angles and are
addressed by the same new scenarios. F5 and F6 need recorded decisions rather than
necessarily code changes.

The underlying design is sound and most of the safety machinery is correctly built; the
findings are concentrated in rung 1 and in path parsing, not spread across the file.
