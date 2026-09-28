# Dirt Classifier Design Research — Issue #632 (epic child C)

- **Issue:** #632 (`cleanup-merged-worktrees-hardening`, child C)
- **Branch:** `bug/cleanup-worktrees-dirt-classifier-632`
- **Worktree root:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3944b95a7d58e712`
- **Last Updated:** 2026-09-06T23-45
- **Status:** Research complete; one recommended design per question
- **Scope exclusions honored:** detached-worktree classification and consolidation-branch
  ordering (child A / #630), orphan / stale-ref / `CHILD_OF` / `registration-lost` records
  (child B), removal manifest (child D), `PRESERVE` consolidation (child F).

Every citation below was re-derived against the current tree in this worktree.

---

## 1. Current State Analysis

### 1.1 The four production files

| File | Lines (last content line, verified by Read) | Role |
|---|---|---|
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | git seam, enumeration, protection, freshness |
| `scripts/bash/cleanup_worktrees_lib.sh` | 479 | classification ladder + `run_report` |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 382 | consolidation, deletion, `run_apply` |
| `scripts/bash/cleanup-worktrees.sh` | 92 | CLI wrapper (`usage`, `main`, source order) |

Verified tails: `cleanup_worktrees_lib.sh:479` is the closing `}` of `run_report`;
`cleanup_worktrees_actions_lib.sh:382` is the closing `}` of `run_apply`.

Source order is fixed in `cleanup-worktrees.sh:16-24`: enumerate lib, then classification
lib, then actions lib. Every library defines functions only and runs nothing at source
time (`cleanup_worktrees_lib.sh:13-14`, `cleanup_worktrees_enumerate_lib.sh:12-13`,
`cleanup_worktrees_actions_lib.sh:12-13`).

### 1.2 The git seam

`cleanup_wt_git` (`cleanup_worktrees_enumerate_lib.sh:34-57`) resolves
`CLEANUP_WT_GIT_BIN` when it is set **and** executable (`:47`), otherwise falls back to
`command -v git`, and returns 127 when nothing resolves (`:52-55`). Every git call in the
family goes through it. The complete current call inventory (Grep `cleanup_wt_git ` over
`scripts/bash/`) is 13 distinct subcommands — see §9, Claim C.

### 1.3 The single `DIRTY|` emission site

`remove_worktree_safe` (`cleanup_worktrees_actions_lib.sh:252-279`) is the only place a
`DIRTY|` record is produced:

```
263	cleanup_wt_git worktree remove "$path" >/dev/null || rc=$?
...
270	sout=$(cleanup_wt_git -C "$path" status --porcelain) || srrc=$?
271	if ((srrc == 0)) && [[ -n $sout ]]; then
272		while IFS= read -r line; do
273			[[ -z $line ]] && continue
274			printf 'DIRTY|%s|%s\n' "$path" "$line"
275		done <<<"$sout"
276	fi
277	printf 'ACTION|worktree-remove|%s|BLOCKED-DIRTY\n' "$path"
278	return 1
```

Three properties matter for the design:

1. The status read happens **only after** `git worktree remove` has already failed
   (`:263`). Report mode never issues a `status` command today.
2. The removal invocation at `:263` carries no `--force`; that is the sole removal call in
   the function and the basis of the never-force invariant.
3. A hard status failure (`srrc != 0`) still yields `BLOCKED-DIRTY` and `return 1` — the
   fail-closed convention, pinned by `tests/shell/test_cleanup_worktrees_hard_failures.bats:166-172`.

`remove_worktree_safe` is called only from `delete_candidate`
(`cleanup_worktrees_actions_lib.sh:297-314`), which runs
`reverify_delete_eligible` first (`:309`), then removal (`:311`), then `delete_branch`
(`:313`). `delete_candidate` is called only from `run_apply` (`:376`) and only for the
three-state allowlist at `:375`.

### 1.4 The report driver

`run_report` (`cleanup_worktrees_lib.sh:445-479`) captures `parse_worktree_list` and
`enumerate_branches` up front (`:456-463`), emits `WARN` via `check_main_freshness`
(`:464`), then one `WORKTREE|` line per registration in the loop at `:465-469`, then the
per-branch ladder at `:470-477`. Its contract line at `:446` is
"emit the deterministic report with no mutation of any kind"; the CLI repeats that claim
at `cleanup-worktrees.sh:32-34`.

### 1.5 The report-line contract

Declared twice, and both copies must stay in sync:

- `cleanup_worktrees_lib.sh:40-50` (the authoritative comment block, including
  `DIRTY|<worktree-path>|<status-porcelain-line>` at `:45`).
- `cleanup-worktrees.sh:42-45` (the `usage` here-doc).
- Mirrored a third time in `.claude/skills/cleanup-merged-worktrees/SKILL.md:57-71`
  (`DIRTY|` at `:69`).

### 1.6 The test seam and the stub dispatcher contract

`tests/fixtures/cleanup_worktrees/stub-bin/git` (209 lines) is the recording stub. Its
exact contract, re-derived:

- **Invocation log.** Line 45: `printf 'stub-git: %s\n' "$*" >&2`. Every invocation's full
  argv goes to **stderr**, so a caller capturing stdout via `$( )` gets only canned data,
  while `bats run` merges the log into `$output` for argv assertions.
- **Scenario selection.** `scenario=${CLEANUP_WT_STUB_SCENARIO:-}` (`:47`). With no
  scenario set, every command emits nothing and exits 0 (`respond`, `:55-69`).
- **Response replay** (`:55-69`): for KEY *k*, `<scenario>/k.out` is `cat`-ed to stdout if
  present, and the exit code is the integer in `<scenario>/k.rc` if present, else 0.
  A missing `.out` means empty stdout; a missing `.rc` means exit 0.
- **Key sanitization** (`:49-53`): every character outside `[A-Za-z0-9._-]` becomes `_`.
  So `refs/heads/x` → `refs_heads_x` and `main:docs/gone.md` → `main_docs_gone.md`.
- **Global-option stripping** (`:73-93`): only `-C <path>` and `-c <name>=<value>` are
  consumed before the subcommand. The **last** `-C` value is retained in `dash_c_path` and
  is used to key `status` (`:178-183`). Any other leading global option (for example
  `--no-optional-locks`) would be treated as the subcommand and fall through to the
  `*) exit 0` default at `:205-207`.
- **Subcommand arms** (`:96-208`): 13 named arms — `for-each-ref`, `worktree`,
  `merge-base`, `rev-list`, `diff`, `cherry`, `diff-tree`, `ls-tree`, `rev-parse`,
  `status`, `cherry-pick`, `branch`, `fetch` — plus a `*)` default that exits 0 silently.
- **Argument matching per arm** is positional/scan-based, not exhaustive:
  `merge-base` keys on `$3` only when `$2 == --is-ancestor` (`:110-113`); `rev-list` scans
  for an argument containing `..` and keys on the text after the dots (`:116-122`), so a
  range-free `rev-list` yields the empty key `rev-list.`; `diff` scans for a `...`/`..`
  spec and an optional post-`--` path (`:126-141`); `ls-tree` keys `ref_path` (`:153-165`);
  `rev-parse` has four shapes (`:167-177`), including the generic
  `rev-parse.<sanitized-rev>` fallback at `:175` that already covers `main:<path>`.

**What a new scenario author must create.** A directory
`tests/fixtures/cleanup_worktrees/scenarios/<name>/` containing one `<KEY>.out` file per
command whose stdout matters and one `<KEY>.rc` file per command whose exit code matters.
The minimum viable set for a report/apply run, derived from the `dirty_worktree` scenario
(the closest precedent), is:

| File | Content in `dirty_worktree` | Why it is needed |
|---|---|---|
| `worktree-list.out` | two porcelain stanzas (`/repo/main` main; `/repo-wt/dirty` on `feature-dirty`) | `parse_worktree_list`, `compute_protected` |
| `for-each-ref.out` | `feature-dirty dddd9999` / `main aaaa0000` | `enumerate_branches` |
| `rev-parse.abbrev-ref-HEAD.out` | `main` | `compute_protected` current branch |
| `rev-parse.show-toplevel.out` | `/repo/main` | `compute_protected` current path |
| `merge-base.feature-dirty.rc` | `0` | drives the branch to `MERGED_CLEAN` |
| `worktree-remove.rc` | `1` | forces the dirty-block path |
| `status._repo-wt_dirty.out` | `?? untracked-artifact.txt` | the `DIRTY|` payload |

Note the `status` key: `-C /repo-wt/dirty` sanitizes to `_repo-wt_dirty`, so the file is
`status._repo-wt_dirty.out`. There is exactly one `status.<path>` fixture per scenario
today, in `dirty_worktree` (`.out`) and `dirty_worktree_status_error` (`.rc` = non-zero).

### 1.7 The bats suites

Six suites drive this family. The relevant assertions:

- `tests/shell/test_cleanup_worktrees_deletion.bats:26-34` — the `DIRTY|` assertion at
  `:28` is a **substring** match (`[[ "$output" == *"DIRTY|/repo-wt/dirty|?? untracked-artifact.txt"* ]]`),
  plus `[[ "$output" != *"--force"* ]]` at `:31`.
- `tests/shell/test_cleanup_worktrees_cli.bats:28-39` — report mode asserts the **absence**
  of `worktree remove`, `branch -D`, `cherry-pick`, `worktree add` in the argv log. It does
  **not** assert the absence of `status`.
- `tests/shell/test_cleanup_worktrees_classification.bats:24-27` — the `report` helper
  redirects stderr to `/dev/null`, so `$output` for report tests is stdout only. Several
  assertions are exact-equality on a single line (for example `:32`, `:50`, `:63`).
- `tests/shell/test_cleanup_worktrees_hard_failures.bats:22-28` — the `runin` helper also
  discards stderr; test 17 (`:166-172`) pins `remove_worktree_safe`'s fail-closed behavior.

Every suite sources the three libraries explicitly (for example
`test_cleanup_worktrees_deletion.bats:22-23`), so a new library file must be added to each
suite's `source` chain.

### 1.8 Toolchain and size constraints

- `.claude/rules/shell.md:19-29`: shfmt → shellcheck → (no type check) → bats; coverage via
  `bash scripts/bash/shell-qc.sh test --coverage`.
- `.claude/rules/shell.md:68-70`: kcov measures **line coverage only**; the uniform >= 85%
  line threshold applies; **there is no bash branch-coverage gate**. This matches
  `.claude/rules/quality-tiers.md` (uniform thresholds; PowerShell/bash branch exemption).
- `.claude/rules/shell.md:89`: no production, test, or reusable shell file may exceed 500
  lines. `.claude/rules/general-code-change.md` states the same cap repository-wide.
- `.claude/rules/shell.md:90-93` and `.claude/rules/general-unit-test.md`: tests must not
  create temporary files; use checked-in fixtures.
- `scripts/bash/shell_qc_lib.sh:333-336`: kcov's include pattern covers the discovery roots
  and excludes `<repo_root>/tests`, so the stub and fixtures are not in the coverage
  denominator. The new production library **is**.

### 1.9 Two environment facts that shape the predicates

1. **`/artifacts` is gitignored in this repository** (`.gitignore:6`). Consequently
   `git status --porcelain` (without `--ignored`) will never list
   `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, or
   `artifacts/orchestration/orchestrator-state.json` in a drm-copilot worktree. The
   2026-09-06 observations were recorded against "the TaskMaster checkout"
   (`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md:20`),
   where those paths are evidently not ignored. The tool is repository-agnostic, so the
   `DISPOSABLE_SESSION_ARTIFACT` predicate is still required; it simply cannot fire in a
   drm-copilot worktree. **Do not add `--ignored` to the status read** to make it fire:
   that would enlarge the dirt set with every ignored build output and, combined with
   clearing, would authorize destruction of files that were never classified.
2. **`validate-bash.ps1` blocks any Bash command whose text contains `git reset --hard`**
   (`.claude/hooks/validate-bash.ps1:53`, substring match at `:73`). The hook inspects the
   Bash tool's command text, so `bash scripts/bash/cleanup-worktrees.sh --apply
   --clear-disposable` is not blocked — the `git reset --hard` lives inside the script. But
   an implementer cannot manually reproduce the clearing step with a raw `git reset --hard`
   Bash command; use the stub-driven bats path instead.

---

## 2. Q1 — Emission Site

### Recommendation: (b) a shared classifier in a new library, with report mode emitting **new record types** and the existing `DIRTY|` record left untouched.

**Design.** A new file `scripts/bash/cleanup_worktrees_dirt_lib.sh` defines
`classify_worktree_dirt <worktree-path>`, which performs its own status read and emits:

```
DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>
DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>
```

`run_report` calls it once per non-main, non-bare worktree registration, inside the loop
already at `cleanup_worktrees_lib.sh:465-469`, immediately after that worktree's
`WORKTREE|` line. `run_apply` does **not** call it by default; only the
`--clear-disposable` path (§5) does, via `delete_candidate`.

**Why (b) rather than (a).** A report-mode-only emission would duplicate the status read
and the verdict logic that the clearing gate also needs, and the two copies would drift.
A single function used by both modes keeps one definition of "disposable", which is the
predicate that authorizes a destructive action. The requirement also demands that the
clearing gate ("a worktree whose dirt is entirely non-`UNIQUE`") use the same verdicts the
report shows the operator; sharing the function makes that identity structural rather than
a maintenance promise.

**Why new record types rather than extending `DIRTY|`.** `DIRTY|` is a documented
three-field contract in three places (§1.5) and is asserted by
`test_cleanup_worktrees_deletion.bats:28`. Appending a fourth field would technically
survive that substring assertion but would silently change a published contract for every
downstream consumer. `DIRTFILE|`/`DIRTSUM|` are additive: they collide with nothing under
prefix matching (`DIRTY|*` does not match `DIRTFILE|...`, and `DIRTFILE|*` does not match
`DIRTY|...`), and the file path is the **last** field so a path containing `|` cannot
corrupt earlier fields.

### Resulting output, line by line

**Report mode, `dirty_worktree`-shaped input (no flag):**

```
WORKTREE|/repo/main|main|main
WORKTREE|/repo-wt/dirty|feature-dirty|
DIRTFILE|/repo-wt/dirty|UNIQUE||??|untracked-artifact.txt
DIRTSUM|/repo-wt/dirty|HAS_UNIQUE|
BRANCH|feature-dirty|MERGED_CLEAN
BRANCH|main|PROTECTED_CURRENT
```

(The `DIRT*` lines are new; the `WORKTREE|` and `BRANCH|` lines are byte-identical to
today's output and keep their current relative order.)

**Report mode, a clean worktree:** no `DIRT*` line at all. The status read returns empty,
the classifier emits nothing. This is the mechanism by which **every existing report-mode
fixture stays byte-identical**: only `dirty_worktree` and `dirty_worktree_status_error`
carry a `status.<path>` fixture, and neither is exercised by a report-mode test today.

**Apply mode without `--clear-disposable`:** byte-identical to today. `run_apply` does not
call the classifier; `remove_worktree_safe` is unmodified; the `DIRTY|` and
`ACTION|worktree-remove|<path>|BLOCKED-DIRTY` lines are unchanged.

**Apply mode with `--clear-disposable`, all dirt disposable:**

```
DIRTY|/repo-wt/dirty|?? nuget-restore-artifact.csproj
ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY
DIRTFILE|/repo-wt/dirty|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj
DIRTSUM|/repo-wt/dirty|ALL_DISPOSABLE|
ACTION|dirt-clear|/repo-wt/dirty|OK
ACTION|worktree-remove|/repo-wt/dirty|OK
ACTION|branch-delete|feature-dirty|OK
```

**Apply mode with `--clear-disposable`, any `UNIQUE` dirt:**

```
DIRTY|/repo-wt/dirty|?? untracked-artifact.txt
ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY
DIRTFILE|/repo-wt/dirty|UNIQUE||??|untracked-artifact.txt
DIRTSUM|/repo-wt/dirty|HAS_UNIQUE|
ACTION|dirt-clear|/repo-wt/dirty|REFUSED-UNIQUE
```

No removal retry, no branch delete, driver rc non-zero.

### Reconciling the byte-identical constraint

Adding report-mode `DIRT*` lines **does** change report-mode stdout for a worktree with
dirt. The constraint must therefore be read precisely.

**Recommended interpretation for the plan:** *"Keep the default behavior unchanged" binds
mutating behavior — which git commands with side effects are issued, and which worktrees
and branches are removed or deleted — and binds the shape and ordering of every existing
record type. It does not forbid additive, new-prefix report records.*

Justification from the requirement text itself. The requirement is one paragraph:

> Required: add a deterministic dirt classifier to **report mode** that labels each
> `DIRTY|` line ... Add an opt-in **apply** flag (for example `--clear-disposable`) that
> ... runs `git reset --hard` + `git clean -fd` and then the normal non-forced removal.
> **Keep the default behavior unchanged.** `UNIQUE` dirt still blocks.

The first sentence mandates new report-mode output and attaches no flag to it. If "keep the
default behavior unchanged" covered report stdout, the paragraph would mandate and forbid
the same change. The sentence sits between the description of the destructive flag and
"`UNIQUE` dirt still blocks" — both destructive-behavior statements — so the mutating
reading is the only self-consistent one.

Two guardrails make this safe rather than merely arguable, and both should be pinned by
tests:

1. **No existing record type changes.** `BRANCH|`, `COMMIT|`, `WORKTREE|`, `WARN|`,
   `DIRTY|`, and `ACTION|` keep their field counts, field values, and relative order.
2. **Apply-mode stdout is byte-identical without the flag**, and report mode issues no new
   *mutating* command — only `git --no-optional-locks ... status --porcelain` and other
   read-only plumbing (§3).

---

## 3. Q2 — Non-Mutating Staged-Tree Comparison

### Recommendation: reject `git write-tree` entirely; use `git diff-index --cached --quiet <commit>`.

### 3.1 Why the `GIT_INDEX_FILE` redirect is not viable

- **A redirected index is empty, so `write-tree` gives the wrong answer.** `git write-tree`
  serializes whatever index `GIT_INDEX_FILE` names. Pointing it at a fresh scratch path
  yields the empty tree `4b825dc642cb6eb9a060e54bf8d69288fbee4904`, not the worktree's
  staged tree. A naive redirect therefore produces a deterministic false negative for
  every worktree.
- **`git read-tree` cannot repair this.** `read-tree` populates an index from a **tree**.
  Seeding the scratch index with a commit's tree and then comparing the resulting
  `write-tree` output against that same commit is circular — it is true by construction and
  measures nothing. There is no plumbing command that copies a *staged* index into another
  index.
- **The only correct sequence is a filesystem copy.** `cp .git/worktrees/<name>/index
  <scratch>` (or `$GIT_DIR/index` for the main worktree), then
  `GIT_INDEX_FILE=<scratch> git -C <wt> write-tree`. That requires locating the per-worktree
  git directory (`git -C <wt> rev-parse --git-dir`), a temporary file, and cleanup.
- **`write-tree` still writes to the object database.** `GIT_INDEX_FILE` redirects only the
  index. Tree objects are written into the repository's object store unless
  `GIT_OBJECT_DIRECTORY` is *also* redirected, and redirecting that would break the reads
  the comparison depends on. Writing unreferenced loose tree objects is a real mutation of
  the inspected repository and contradicts `run_report`'s stated contract at
  `cleanup_worktrees_lib.sh:446` and the CLI's at `cleanup-worktrees.sh:32-34`.

### 3.2 The read-only alternative (recommended)

Verified from the git documentation for `git diff-index`:

- `--cached`: "Do not consider the on-disk file at all." In cached mode the command answers
  "show me the differences between HEAD and the current index contents (**the ones I'd
  write using `git write-tree`**)" — i.e. it is the documented read-only equivalent of the
  write-tree comparison.
- `--quiet`: "Disable all output of the program. Implies `--exit-code`."
- `--exit-code`: "exits with 1 if there were differences and 0 means no differences."
- `git diff-index` writes nothing: it neither refreshes nor rewrites the index, and it
  creates no objects.

**Exact sequence:**

```
# candidates: the branch's own commits, bounded, skipping HEAD itself
cands=$(cleanup_wt_git -C "$wt" rev-list --max-count="$((DEPTH + 1))" HEAD)   # guarded capture
# drop the first line (HEAD): "index == HEAD" is the no-staged-changes case, not a finding
for sha in <cands minus first>; do
    rc=0
    cleanup_wt_git --no-optional-locks -C "$wt" diff-index --cached --quiet "$sha" -- >/dev/null 2>&1 || rc=$?
    ((rc == 0)) && { printf '%s\n' "$sha"; return 0; }
    ((rc == 1)) && continue
    return 2      # any other exit is a hard failure -> fail closed
done
```

Notes:
- Run the probe only when at least one status entry has a **staged** change (X column not
  in `' ?!'`). Otherwise the probe is pure cost and, against `HEAD`, would produce a
  meaningless positive.
- Dropping the first `rev-list` entry rather than using `HEAD~1` keeps the command
  root-commit safe (`HEAD~1` fails on a repository with a single commit).
- `DEPTH` is a named constant, recommended `CLEANUP_WT_STAGED_TREE_DEPTH=200`. Bounding can
  only cause a missed match, which degrades to `UNIQUE` and blocks clearing — the safe
  direction.
- `--no-optional-locks` is documented as "Do not perform optional operations that require
  locks ... this will prevent `git status` from refreshing the index as a side effect." Use
  it on **every** read the new library issues, most importantly the `status --porcelain`
  read, so report mode cannot rewrite the inspected worktree's index stat cache. The
  existing apply-mode read at `cleanup_worktrees_actions_lib.sh:270` is left unmodified so
  apply-mode argv stays byte-identical.

### 3.3 Temporary files: does the prohibition bind production code?

No. `.claude/rules/general-unit-test.md` states "**Creation and use of temporary files in
tests** is strictly prohibited", and `.claude/rules/general-code-change.md`'s I/O Boundaries
section repeats "Use of temporary files **within tests** is strictly prohibited." Both are
test-scoped. Production code may use a temporary file.

The question is moot under the recommended design: **the production path needs no scratch
index and no temporary file at all.** If a future variant reintroduces one, it must live
under `$(mktemp)` / `$TMPDIR` — never inside the repository or a worktree — with a
`trap 'rm -f "$scratch"' RETURN` cleanup. Record that as a design note only.

### 3.4 Pinning it through the stub seam

`CLEANUP_WT_GIT_BIN` replaces git entirely, so the only observable is the stub's
`stub-git: <argv>` stderr log (`stub-bin/git:45`). Add **one line** to the stub, immediately
after `:45`, so environment redirection is observable too:

```
[[ -n ${GIT_INDEX_FILE:-} ]] && printf 'stub-git-env: GIT_INDEX_FILE=%s\n' "$GIT_INDEX_FILE" >&2
```

A report-mode non-mutation test then asserts, over the `dirt_staged_tree_is_commit`
scenario:

- `[[ "$output" != *"write-tree"* ]]` — the write path is never taken.
- `[[ "$output" != *"stub-git-env: GIT_INDEX_FILE="* ]]` — no index redirection occurred,
  which is the strongest available form of "the real index path was never passed as the
  write target": no index path was named at all, on the command line or in the environment.
- `[[ "$output" != *"/index"* ]]` — no argv names an index file.
- Every `status` invocation carries `--no-optional-locks` (assert the paired substring
  `--no-optional-locks -C /repo-wt/... status --porcelain`).
- `[[ "$output" == *"diff-index --cached --quiet"* ]]` — the read-only route was used.

---

## 4. Q3 — Verdict Detection Rules

### 4.1 Status parsing (shared preamble)

Read: `cleanup_wt_git --no-optional-locks -C "$wt" status --porcelain` (guarded parent-shell
capture; a non-zero exit yields no `DIRT*` lines and a non-zero return — fail closed).

Per line: status code `xy=${line:0:2}`, path `rel=${line:3}`. For a rename entry
(`R`/`C` in the X column) the payload is `OLD -> NEW`; take the text after ` -> `.

**C-quoting hazard.** With `core.quotePath` at its default, a path containing non-ASCII or
special bytes is emitted double-quoted with escapes. Recommendation: **if `rel` begins with
`"`, classify the entry `UNIQUE` immediately** and do not attempt to unquote. Deterministic,
one branch, and fails in the safe direction. Do not switch the read to `-z`: that would
change the `DIRTY|` payload if the two reads ever converge, and it complicates the
line-oriented loop for no classification benefit.

### 4.2 The six predicates

| Verdict | Applies to | Predicate | Exact plumbing |
|---|---|---|---|
| `STAGED_TREE_IS_COMMIT` | staged entries only (X not in `' ?!'`) | the whole index equals some commit's tree | §3.2 — `rev-list --max-count=N HEAD` (drop first) then `--no-optional-locks -C <wt> diff-index --cached --quiet <sha> --`; exit 0 = match |
| `DISPOSABLE_SESSION_ARTIFACT` | any entry | `rel` is an exact member of the hard-coded path array | pure string comparison; no git call |
| `DISPOSABLE_BUILD_ARTIFACT` | modified tracked entries only | path matches `*.csproj` / `packages.config` / `app.config` **and** every changed content line is an analyzer `HintPath` rewrite | `--no-optional-locks -C <wt> diff --no-color -U0 -- <rel>` and `... diff --no-color -U0 --cached -- <rel>`; every `^[+-]` line (excluding `^+++`/`^---`) must match `^[+-][[:space:]]*<HintPath>.*</HintPath>[[:space:]]*$` |
| `CONTENT_ON_MAIN` | tracked: modified; untracked: `??` | content equals `main`'s current blob at the same path | tracked: `--no-optional-locks -C <wt> diff --quiet main -- <rel>` (exit 0 = equal). untracked: `blob=$(cleanup_wt_git -C <wt> hash-object -- <rel>)` compared to `cleanup_wt_git rev-parse main:<rel>` |
| `CONTENT_IN_HISTORY` | any entry with a resolvable blob | that blob appears somewhere in `main`'s bounded history | `cleanup_wt_git log "main~<N>..main" --find-object=<blob> --format=%H --max-count=1`; non-empty stdout = hit, and that sha is the detail field |
| `UNIQUE` | fallback | none of the above matched, **or** any classifier read hard-failed | — |

### 4.3 `DISPOSABLE_BUILD_ARTIFACT`: path-pattern-only versus content-confined

**Recommendation: path pattern *plus* the content check confined to `HintPath` lines.**

A path-pattern-only rule **will** clear a genuine hand edit to a `.csproj`. That is not a
hypothetical: TaskMaster is a legacy non-SDK C# project (see the `csharp-legacy` profile
under `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/`),
and in a non-SDK project every added source file is an explicit `<Compile Include=...>`
edit to the `.csproj`. Under a path-only rule, an uncommitted new-file registration would
be labelled `DISPOSABLE_BUILD_ARTIFACT` and destroyed by `git reset --hard`.

The requirement names the class precisely — "`*.csproj` / `packages.config` / `app.config`
**analyzer-HintPath rewrites left by `nuget restore`**" — so the content confinement is not
extra scope; it is the definition. The cost is two `git diff` invocations per candidate
file, bounded by the number of dirty project-file entries in one worktree.

Additional narrowing, both cheap and load-bearing:

- The entry must be **tracked and modified** (`' M'`, `'M '`, `'MM'`). An untracked
  (`??`) `.csproj` is a new project file, never a restore rewrite, and falls through to the
  content rungs.
- If either diff read hard-fails, the entry is `UNIQUE` (fail closed).

**If a plan nevertheless chose path-only**, the mandatory mitigations are: (i) state the
data-loss mode explicitly in `SKILL.md`; (ii) keep the flag opt-in with no config default;
(iii) require the operator to have read the `DIRTFILE|` report lines first. This research
recommends against that path.

### 4.4 `DISPOSABLE_SESSION_ARTIFACT`: hard-coded, not configurable

**Recommendation: a hard-coded array constant in the new library**, following the
`CLEANUP_WT_CONSOLIDATION_BRANCH` precedent at `cleanup_worktrees_actions_lib.sh:37`:

```
CLEANUP_WT_SESSION_ARTIFACT_PATHS=(
	"artifacts/pr_context.summary.txt"
	"artifacts/pr_context.appendix.txt"
	"artifacts/orchestration/orchestrator-state.json"
)
```

Rationale:

1. This list is the authorization list for an irreversible action. An environment override
   would let any path be declared disposable at runtime, defeating the `UNIQUE` gate that
   is the feature's entire safety argument.
2. The family's existing environment seams are a *binary path* seam
   (`CLEANUP_WT_GIT_BIN`), a *test scenario* seam (`CLEANUP_WT_STUB_SCENARIO`), and a
   *derived-path* override (`CLEANUP_WT_CONSOLIDATION_PATH`). None is a policy override.
   Adding one would be a new category.
3. Adding a path costs one line and a code review.

Match on the **exact** repo-relative path, never a prefix. `artifacts/**` at large must not
be auto-cleared: `artifacts/orchestration/orchestrator-state.json` is the orchestration
checkpoint (`CLAUDE.md`), and `artifacts/` also holds evidence-adjacent output.

### 4.5 `CONTENT_IN_HISTORY`: cost and bounding

`--find-object=<object-id>` is documented as "Look for differences that change the number of
occurrences of the specified object. Similar to `-S`, just the argument is different in that
it doesn't search for a specific string but for a specific object id." Used with `git log`
it is a full revision walk with a per-commit diff filter.

Cost profile: a **hit** terminates early with `--max-count=1`; a **miss** walks the entire
history of `main`. The miss is the common case for genuinely unique content, so the
expensive path is exactly the path taken most often. On a repository with tens of thousands
of commits this is seconds per file, multiplied by the number of untracked files across 14
worktrees.

**Recommended bound:** restrict the range, not the output count.
`git log "main~${CLEANUP_WT_HISTORY_SCAN_DEPTH}..main" --find-object=<blob> --format=%H --max-count=1`
with `CLEANUP_WT_HISTORY_SCAN_DEPTH=1000`. When `main~1000` does not resolve (history
shorter than the bound), fall back to plain `main`. Detect that with a guarded
`rev-parse --verify --quiet "main~${DEPTH}"` probe rather than by parsing an error message.

The bound is one-sided and safe: a hit is authoritative `CONTENT_IN_HISTORY`; a miss inside
the bound degrades to `UNIQUE`, which blocks clearing. Document that asymmetry in the
function header so a future reader does not "fix" it by removing the bound.

Also bound the *set*: run `--find-object` only for entries that already failed
`CONTENT_ON_MAIN`, and only when `hash-object` produced a blob. `git hash-object` does not
write to the object database (writing requires `-w`), and by default it applies the
attribute-selected input filters including end-of-line conversion; **`--no-filters` must not
be used**, or a CRLF working-tree file on Windows can never match `main`'s LF blob.

### 4.6 Precedence order

First match wins, evaluated per file in this order:

1. `STAGED_TREE_IS_COMMIT` (staged entries only, when the worktree-level probe matched)
2. `DISPOSABLE_SESSION_ARTIFACT`
3. `DISPOSABLE_BUILD_ARTIFACT`
4. `CONTENT_ON_MAIN`
5. `CONTENT_IN_HISTORY`
6. `UNIQUE`

Rationale: rung 1 is the strongest and most informative statement about a staged entry and
is computed once per worktree, so it costs nothing to check first. Rungs 2-3 are path-scoped
and either free (2) or bounded by two diffs (3). Rungs 4-5 are content reads, ordered
cheap-before-expensive: rung 4 is one `diff --quiet` or one `rev-parse`, rung 5 is a bounded
history walk. Rung 4 also carries a stronger claim than rung 5 (the content is on `main`
*now*, not merely somewhere in its past), so where both hold the more useful label wins.

**Fail-closed rule, stated explicitly:** any non-zero exit from any classifier git read maps
the entry to `UNIQUE`. This matches the family-wide convention documented at
`cleanup_worktrees_lib.sh:20-38` and `cleanup_worktrees_actions_lib.sh:19-35`, and here
fail-closed means "blocks clearing". It must be pinned by a dedicated test, because it is
the one rule whose violation converts a git hiccup into data loss.

### 4.7 Per-file versus per-worktree: the data shape

The two are genuinely different granularities and both are required:

- The **label** is per-file: "labels each `DIRTY|` line", and a `DIRTY|` line is one
  `git status --porcelain` entry, i.e. one path.
- The **clearing gate** is per-worktree: "a worktree whose dirt is entirely non-`UNIQUE`".
- `STAGED_TREE_IS_COMMIT` is inherently per-index, which is per-worktree.

**Recommended shape: emit both, with the aggregate derived from the per-file set.**

```
DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>
DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>
```

- `<detail>` on `DIRTFILE` carries the commit sha for `STAGED_TREE_IS_COMMIT` and
  `CONTENT_IN_HISTORY`, and is empty otherwise. This keeps the requirement's
  `STAGED_TREE_IS_COMMIT <sha>` information without a variable-arity field.
- `<detail>` on `DIRTSUM` carries the staged-tree commit sha when the worktree-level probe
  matched, and is empty otherwise.
- `DIRTSUM` is `ALL_DISPOSABLE` iff the entry count is >= 1 and the `UNIQUE` count is 0;
  otherwise `HAS_UNIQUE`. Zero entries emits neither line.
- `<file-path>` is last so an embedded `|` cannot shift field positions.

`--clear-disposable` reads exactly one thing: `DIRTSUM|<path>|ALL_DISPOSABLE`.

---

## 5. Q4 — `--clear-disposable` Mechanics

### 5.1 Flag parsing in `cleanup-worktrees.sh`

**`usage` (`:26-56`).** Add one Commands entry and two contract lines:

```
  --clear-disposable   Apply-mode-only, opt-in, DESTRUCTIVE modifier. For a worktree whose
                       dirt is classified entirely non-UNIQUE, runs `git reset --hard` and
                       `git clean -fd` in that worktree and then retries the normal
                       non-forced removal. Refuses when any dirt is UNIQUE. Requires
                       --apply; supplying it without --apply is a usage error (exit 2).
```

and, in the report-line block at `:42-45`:

```
DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>;
DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>;
```

**`main` (`:58-83`).** Insert a single pre-pass hunk **before** `local command=${1:-}` and
leave every existing `case` arm textually untouched (this is the minimum-conflict shape for
concurrent fan-in):

```
	# Strip the destructive opt-in modifier from the argument list before mode dispatch,
	# so every existing mode arm stays unchanged. The flag is apply-mode-only: supplying it
	# in report mode is a usage error rather than a silently ignored no-op, because an
	# operator who typed it expects clearing to happen.
	local -a rest=()
	CLEANUP_WT_CLEAR_DISPOSABLE=0
	local arg
	for arg in "$@"; do
		if [[ $arg == --clear-disposable ]]; then
			CLEANUP_WT_CLEAR_DISPOSABLE=1
		else
			rest+=("$arg")
		fi
	done
	set -- "${rest[@]:-}"
	if ((CLEANUP_WT_CLEAR_DISPOSABLE == 1)) && [[ ${1:-} != --apply && ${1:-} != apply ]]; then
		usage >&2
		return 2
	fi
```

`CLEANUP_WT_CLEAR_DISPOSABLE` defaults to 0 in the new library
(`CLEANUP_WT_CLEAR_DISPOSABLE=${CLEANUP_WT_CLEAR_DISPOSABLE:-0}`) so the libraries are
directly testable from bats without the wrapper, matching how every other suite drives the
functions.

### 5.2 The gate and the clearing sequence (new library)

```
clear_disposable_dirt() {
	# Args: $1 = worktree path.
	# Emits ACTION|dirt-clear|<path>|OK | REFUSED-UNIQUE | FAILED.
	# Returns 0 only when the worktree was cleared.
	#
	# Refuses unless the aggregate verdict is exactly ALL_DISPOSABLE. A classification
	# hard failure yields HAS_UNIQUE (fail closed) and therefore a refusal.
	#
	# `git clean` is run with -fd and NEVER with -x, -X, or -ff: ignored files never appear
	# in `git status --porcelain` and are therefore never classified, so removing them would
	# be unclassified destruction. -ff is likewise excluded so a nested repository is left
	# alone.
}
```

Sequence, in order, with guarded captures:

1. `cout=$(classify_worktree_dirt "$path") || crc=$?` — on `crc != 0` emit
   `ACTION|dirt-clear|<path>|REFUSED-UNIQUE` and return 1.
2. Read the single `DIRTSUM|` line from `$cout`; require field 3 == `ALL_DISPOSABLE`,
   otherwise `REFUSED-UNIQUE` / return 1.
3. `cleanup_wt_git -C "$path" reset --hard >/dev/null || rc=$?` — on failure emit
   `ACTION|dirt-clear|<path>|FAILED` and return 1.
4. `cleanup_wt_git -C "$path" clean -fd >/dev/null || rc=$?` — same failure handling.
5. Emit `ACTION|dirt-clear|<path>|OK`, return 0.

### 5.3 Where the hook goes, and `reverify_delete_eligible`

**`reverify_delete_eligible` (`cleanup_worktrees_actions_lib.sh:218-250`) is reusable
as-is. No variant is needed.** It takes a branch name and a recorded state, re-runs
`classify_branch`, and requires the fresh verdict to be on the
`MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT` allowlist (`:241-249`), mapping
a hard failure to `BLOCKED-REVERIFY` / return 1 (`:231-235`).

The reason no variant is needed is placement: put the clearing hook in **`delete_candidate`
(`:297-314`)**, not in `remove_worktree_safe`. `delete_candidate` already has `$name` and
`$state` in scope, so `reverify_delete_eligible "$name" "$state"` composes directly. Placing
it there also leaves `remove_worktree_safe` byte-identical, which keeps hard-failure test 17
(`test_cleanup_worktrees_hard_failures.bats:166-172`) and the deletion suite's `DIRTY|`
assertion green without modification.

Replace `:310-312` with:

```
	if [[ -n $wt_path ]]; then
		if ! remove_worktree_safe "$wt_path"; then
			# Opt-in clearing: only when the flag was passed, only when the dirt is
			# provably non-UNIQUE, and only followed by a fresh re-verification and a
			# non-forced removal retry.
			((CLEANUP_WT_CLEAR_DISPOSABLE == 1)) || return 1
			clear_disposable_dirt "$wt_path" || return 1
			reverify_delete_eligible "$name" "$state" || return 1
			remove_worktree_safe "$wt_path" || return 1
		fi
	fi
```

Full ordering: pre-reverify (`:309`, unchanged) → removal attempt → dirt classification →
clear → **post-clear reverify** → non-forced removal retry → `delete_branch` (`:313`,
unchanged).

The post-clear re-verification is required by the constraint and is cheap, even though
`git reset --hard` + `git clean -fd` do not move the branch tip: `main` can advance between
the two reads in a concurrent session, and `reverify_delete_eligible` re-reads `main`.

### 5.4 No force flag reaches `git worktree remove`

Confirmed. The only `git worktree remove` invocations in the family are:

- `cleanup_worktrees_actions_lib.sh:182` (consolidation abort cleanup) — no `--force`.
- `cleanup_worktrees_actions_lib.sh:263` (`remove_worktree_safe`) — no `--force`.

The retry in §5.3 calls `remove_worktree_safe`, so it routes through `:263`. Nothing in the
change introduces a third call site. Pin with `[[ "$output" != *"--force"* ]]` on the
clearing scenarios, mirroring the existing assertion at
`test_cleanup_worktrees_deletion.bats:31`.

---

## 6. Q5 — SKILL.md Reconciliation

Two copies must be edited identically (see §7): the canonical
`.claude/skills/cleanup-merged-worktrees/SKILL.md` and its byte-identical bundle mirror.

### 6.1 Current **Prohibited Shortcuts** text, verbatim (`SKILL.md:231-251`)

```
## Prohibited Shortcuts

- Never invoke `gh pr create` or `gh pr edit --body*` from this skill or the scripts. PR
  authoring is `Agent(pr-author)`'s exclusive responsibility and is enforced by the
  `enforce-pr-author-skill.ps1` PreToolUse hook.
- Never pass a force flag to `git worktree remove`. A dirty worktree blocks deletion and
  is reported for manual handling; it is never force-removed.
- Never execute `git worktree prune`. Prunable registrations are report-only.
- Never act on `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, or `PROTECTED_CURRENT` candidates
  through the script or its apply-mode allowlist; `--apply` never mutates them, and the
  caller's worktree and branch, and the main worktree, are never mutated under any
  disposition. The Dirty Worktree Triage Procedure's `SAFE_TO_DELETE` verdict authorizes
  only a distinct, individually confirmed manual action outside that automated path for
  `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS` — never a change to the classification ladder
  itself, and never for `PROTECTED_CURRENT`.
- Never use commit-message text matching as a classification input, and never
  auto-resolve cherry-pick conflicts.
- Never delete an origin branch, or run plain filesystem removal on an orphaned
  worktree-tracking directory, without explicit per-item user confirmation — both are
  outside this skill's pre-approved tool surface regardless of how the triage verdict
  came out.
```

### 6.2 Drafted replacement for the second bullet (`:236-237`)

```
- Never pass a force flag to `git worktree remove`. A dirty worktree blocks deletion and
  is reported for manual handling; it is never force-removed. The opt-in
  `--clear-disposable` modifier is not an exception to this rule and is not force-removal:
  it clears the working tree first (`git reset --hard` plus `git clean -fd`, and never
  `-x`, `-X`, or `-ff`) and only then retries the same unforced `git worktree remove`, so
  the removal itself still fails on any worktree git still considers dirty. It runs only
  when every `DIRTFILE|` verdict for that worktree is non-`UNIQUE` (`DIRTSUM|...|
  ALL_DISPOSABLE`), only in apply mode, only when explicitly requested, and only after a
  fresh in-process re-verification of delete-eligibility between the clear and the retry.
  A single `UNIQUE` verdict — including the fail-closed `UNIQUE` assigned when a
  classification read errors — refuses the clear for the whole worktree.
```

### 6.3 New bullet to append to **Prohibited Shortcuts**

```
- Never widen the disposable-dirt definition to make `--clear-disposable` clear more. The
  session-artifact path list is a fixed in-script array with no configuration override, the
  build-artifact rule requires both the project-file path pattern and an analyzer-`HintPath`
  content confinement, and ignored files are never cleared because they are never
  classified. Relaxing any of these converts an opt-in cleanup into unclassified deletion.
```

### 6.4 **Report Line Contract** (`SKILL.md:57-71`) additions

Insert two bullets after the existing `DIRTY|` bullet at `:69-70`:

```
- `DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>` — report-mode
  per-entry dirt classification. `verdict` in `DISPOSABLE_BUILD_ARTIFACT |
  DISPOSABLE_SESSION_ARTIFACT | CONTENT_ON_MAIN | CONTENT_IN_HISTORY |
  STAGED_TREE_IS_COMMIT | UNIQUE`. `detail` carries the commit SHA for
  `STAGED_TREE_IS_COMMIT` and `CONTENT_IN_HISTORY` and is otherwise empty. `file-path` is
  last so an embedded `|` cannot shift the preceding fields. A classification read that
  errors yields `UNIQUE` (fail closed).
- `DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>` — the per-worktree
  aggregate. `ALL_DISPOSABLE` requires at least one entry and zero `UNIQUE` entries; it is
  the only state `--clear-disposable` acts on. A clean worktree emits neither record.
```

Also amend the `DIRTY|` bullet at `:69-70` to state that it remains apply-mode only and
unchanged:

```
- `DIRTY|<worktree-path>|<status-porcelain-line>` — a dirty worktree that blocked removal.
  Apply mode only; its three-field shape is unchanged by the dirt classifier.
```

### 6.5 **Dirty Worktree Triage Procedure** (`:129-137`) additions

Extend the Trigger paragraph with a new closing sentence:

```
Report mode now precedes this procedure with a deterministic first pass: every dirty
worktree carries `DIRTFILE|` verdicts and a `DIRTSUM|` aggregate. Start from those records.
A worktree whose aggregate is `ALL_DISPOSABLE` needs no editorial triage at all and is
handled by `bash scripts/bash/cleanup-worktrees.sh --apply --clear-disposable`; steps 1-9
apply to worktrees carrying at least one `UNIQUE` verdict, and to the `UNIQUE` entries
within them.
```

Add a scoping sentence to step 6 (`:186-188`), which already describes the build-artifact
case, so the manual instruction and the automated verdict agree:

```
   The classifier already labels this class `DISPOSABLE_BUILD_ARTIFACT`, but only when the
   changed lines are confined to analyzer `HintPath` rewrites. A project file whose diff
   touches anything else is reported `UNIQUE` and must be diffed by hand here.
```

### 6.6 Step 9 (`:204-219`) amendment

Step 9's current text states that discarding is "never automated" and that the
classification ladder and apply-mode allowlist are never changed. Both remain true and must
be preserved; the amendment distinguishes the automated *clearing of classified-disposable
dirt* from the *editorial discard of `UNIQUE` content*. Replace the sentence beginning "For
a `SAFE_TO_DELETE` verdict" through "before or after triage." with:

```
For a `SAFE_TO_DELETE` verdict on `UNIQUE` dirt, discard the content as a distinct,
individually confirmed manual action — clear the dirty working tree, or delete a
disposable `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS` branch directly. That editorial discard is
never automated: the script's classification ladder and apply-mode allowlist are never
changed to accept those states, so a `--apply` run never deletes them on its own, before
or after triage. The one automated discard the script performs is narrower and does not
depend on an editorial verdict: `--clear-disposable` clears a worktree whose every
`DIRTFILE|` verdict is already non-`UNIQUE` by deterministic rule. It requires the explicit
flag, it never runs on a worktree carrying a `UNIQUE` verdict, it never removes ignored
files, it never force-removes, and it re-verifies delete-eligibility in-process between the
clear and the removal retry.
```

---

## 7. Q6 — File Size and Fan-In

### 7.1 New file

**Name:** `scripts/bash/cleanup_worktrees_dirt_lib.sh` — follows the family convention
(`cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`,
`cleanup_worktrees_actions_lib.sh`) and is discovered by the shell-QC roots
(`.claude/rules/shell.md:48-51`), so it is formatted, linted, and measured for coverage.

**Sourcing point:** **append** a fourth source block after the actions-lib block at
`cleanup-worktrees.sh:22-24`, i.e. as the last source statement. Every library defines
functions only and bash resolves call targets at invocation time, so ordering between the
dirt lib and the actions lib does not matter; appending at the end of a contiguous block is
the lowest-conflict insertion point. If child A also appends there, the conflict is a
both-sides-keep append, which is trivially resolvable.

Each of the six bats suites needs the new path added to its `source` chain
(`test_cleanup_worktrees_deletion.bats:14,23` and the equivalents in `_cli`,
`_classification`, `_consolidation`, `_enumeration`, `_hard_failures`).

### 7.2 Minimal hunks per existing file

| File | Hunks | Description |
|---|---|---|
| `cleanup_worktrees_lib.sh` | 2 | (a) 2 lines into the report-line contract comment block at `:40-50`, after `:45`; (b) 2 lines inside the `run_report` worktree loop at `:465-469` — one comment, one `classify_worktree_dirt "$wpath"` call guarded for non-main, non-bare |
| `cleanup_worktrees_actions_lib.sh` | 2 | (a) ~3 header-comment lines noting the clearing hook; (b) replace `:310-312` in `delete_candidate` with the 9-line block from §5.3. `remove_worktree_safe` is untouched |
| `cleanup-worktrees.sh` | 3 | (a) 3-line source block appended after `:24`; (b) ~7 lines into `usage` (`:36-45`); (c) the ~16-line flag pre-pass inserted before `local command=${1:-}` at `:65` |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 4 | (a) 1 line after `:45` for the `GIT_INDEX_FILE` env log; (b) 3 lines in the global-option loop at `:78-89` to strip `--no-optional-locks`; (c) ~5 lines in the `diff` arm at `:124-142` to key non-`--quiet` diffs; (d) ~5 lines in the `rev-list` arm at `:115-123` for the range-free form; (e) 5 new subcommand arms |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 5 | §6.2-6.6 |
| bundle mirror of the SKILL | 5 | identical to the above |
| six `tests/shell/test_cleanup_worktrees_*.bats` | 2 each | `DLIB=` in `setup`, and `source '${DLIB}';` in the driver helper |

Note that `cleanup_worktrees_lib.sh` (child A also wants `run_report`) and
`cleanup-worktrees.sh` (child A also wants CLI/report changes) are the two shared surfaces.
Keeping this child's changes to 4 lines in the former and 3 anchored hunks in the latter is
the fan-in mitigation.

### 7.3 Projected line counts after the change

| File | Before | After (projected) | Headroom to 500 |
|---|---|---|---|
| `cleanup_worktrees_dirt_lib.sh` | 0 (new) | ~260 | ~240 |
| `cleanup_worktrees_lib.sh` | 479 | **483** | 17 |
| `cleanup_worktrees_actions_lib.sh` | 382 | ~396 | ~104 |
| `cleanup-worktrees.sh` | 92 | ~118 | ~382 |
| `stub-bin/git` | 209 | ~254 | ~246 |

Estimated composition of the new library (~260 lines): ~35-line header comment matching the
family's documented style, ~10 lines of constants, `classify_dirt_entry` ~65,
`classify_worktree_dirt` ~55, `staged_tree_commit` ~35, `clear_disposable_dirt` ~40,
helpers ~20.

**Risk and contingency.** 483/500 in `cleanup_worktrees_lib.sh` leaves 17 lines. Child A
(#630) explicitly names `run_report` and the 479-line constraint in its own notes
(`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/issue.md:71-75`).
If child A lands first and consumes that headroom, the contingency is to extract `run_report`
into a new `scripts/bash/cleanup_worktrees_report_lib.sh` as a separate, behavior-preserving
move commit before this child's hunks land. Re-measure the file at integration time; do not
assume 479.

---

## 8. Q7 — Push-Down Mirror

Verified from `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`:

- `SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)` at `:20`. The parity scope is
  **`.claude/**` only**.
- `list_scoped_files` (`:39-48`) enumerates only paths under those scoped roots.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:106-131`) requires
  every repo `.claude/**` file — excluding `.claude/settings.local.json` (`:121`) and the
  `.claude/agent-memory/**` subtree (`:121`, via `_is_agent_memory_path` at `:76-103`) — to
  be present in the bundle **and byte-identical** (`:128-131`).
- `BUNDLED_ROOT = REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"` (`:17-19`).

**`scripts/bash/**` is NOT in the mirror set.** The parity scope is `.claude/**` only, and
`pack-manifests/` and `.claude-variants/` are explicitly outside it (`:147-164`, `:181-194`).
`.claude/lib/bash/` **is** in scope, but the cleanup-worktrees libraries do not live there:
`.claude/lib/bash/` contains exactly 11 `parallel-*` / `compute-*` / `report-lane-assertion`
/ `validate-parallel-manifest` scripts and no `cleanup_worktrees*` file. So none of the four
production shell files, the stub, the fixtures, or the bats suites require mirroring.

**Exact mirror path for the SKILL.md edit:**

```
extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
```

Verified present, and verified byte-aligned with the canonical file: its **Prohibited
Shortcuts** heading is at the same line 231 with identical text through `:251`.

One governance observation, not a required change: the SKILL's `allowed-tools` already
carries `"Bash(bash scripts/bash/cleanup-worktrees.sh *)"` (`SKILL.md:9`), whose wildcard
pre-approves `--apply --clear-disposable` exactly as it already pre-approves `--apply`. No
`allowed-tools` edit is needed, and narrowing it is out of scope for this child.

---

## 9. Numeric Derivation Evidence

### Claim A — There is exactly **one** production `DIRTY|` emission site.

- **Complete family:** every statement in the repository's production shell tree that
  writes a stdout record whose first pipe-delimited field is `DIRTY`.
- **Exhaustive search scope:** both production bash discovery roots declared in
  `.claude/rules/shell.md:48-51` — `scripts/` and `.claude/lib/bash/`. The third declared
  root `tools/` does not exist in this repository (a Grep against it returned
  "Path does not exist"), so the scope is complete.
- **Inclusion rules:** executable `printf`/`echo` statements whose format string begins the
  record with `DIRTY|`.
- **Exclusion rules:** comment lines; `usage` here-doc documentation text; anything under
  `tests/` (fixtures and stubs are not production).
- **Primary search strategy:** literal-substring Grep for `DIRTY|` scoped to `scripts/`,
  content mode with line numbers.
- **Primary member set:** 4 raw hits —
  `cleanup_worktrees_lib.sh:45` (contract comment, excluded),
  `cleanup_worktrees_actions_lib.sh:256` (docstring comment, excluded),
  `cleanup_worktrees_actions_lib.sh:274` (`printf 'DIRTY|%s|%s\n'`, **included**),
  `cleanup-worktrees.sh:45` (usage here-doc, excluded).
  Normalized member set: `{ scripts/bash/cleanup_worktrees_actions_lib.sh:274 }`.
- **Primary count:** 1.
- **Cross-check search strategy (distinct expression and distinct scope):** regex
  `(printf|echo)[^\n]*DIRTY` with `glob: *.sh` over the **whole repository**, not just
  `scripts/`. This targets the emission verb rather than the record literal, so it reaches
  any `echo`-based or differently-punctuated emission that the literal search would miss,
  anywhere in the tree. Supplemented by a count-mode Grep for `DIRTY` over
  `.claude/lib/bash/`.
- **Cross-check member set:** 2 raw hits —
  `cleanup_worktrees_actions_lib.sh:274` (`DIRTY|`, **included**) and
  `cleanup_worktrees_actions_lib.sh:277` (`ACTION|worktree-remove|%s|BLOCKED-DIRTY`,
  excluded: its first field is `ACTION`, not `DIRTY`). `.claude/lib/bash/` returned
  0 occurrences across 0 files. Normalized member set:
  `{ scripts/bash/cleanup_worktrees_actions_lib.sh:274 }`.
- **Cross-check count:** 1.
- **Member-set comparison:** the normalized primary and cross-check member sets are
  identical — both exactly `{ scripts/bash/cleanup_worktrees_actions_lib.sh:274 }`. The two
  searches used different expressions (record literal vs. emission verb) and different
  scopes (`scripts/` vs. repository-wide `*.sh` plus `.claude/lib/bash/`), and both cover
  the complete family. **Assertion accepted.**

### Claim B — The verdict family has exactly **six** members.

- **Complete family:** the verdict tokens the requirement obliges the classifier to assign
  to a dirt entry.
- **Exhaustive search scope:** both approved requirement documents in the feature folder —
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/issue.md` and
  `.../spec.md`. Each states the requirement twice (a structured list and a verbatim
  run-observation block), giving four independent statements.
- **Inclusion rules:** uppercase verdict tokens presented as labels the classifier assigns.
- **Exclusion rules:** branch states (`MERGED_CLEAN` etc.), per-commit states, triage
  verdicts (`SAFE_TO_DELETE`, `PRESERVE`, `DEAD_ONE_OFF`, …), and action results
  (`BLOCKED-DIRTY`).
- **Primary search strategy:** enumerate the explicit bullet list at `issue.md:48-53`.
- **Primary member set:** `{DISPOSABLE_BUILD_ARTIFACT, DISPOSABLE_SESSION_ARTIFACT,
  CONTENT_ON_MAIN, CONTENT_IN_HISTORY, STAGED_TREE_IS_COMMIT, UNIQUE}`.
- **Primary count:** 6.
- **Cross-check search strategy:** enumerate the tokens named in the *prose* verbatim
  run-observation block at `issue.md:73-79` — a different text region in a different form
  (running prose, not a list) — and independently the list at `spec.md:49-56` and the prose
  block at `spec.md:75-81`.
- **Cross-check member set:** `{DISPOSABLE_BUILD_ARTIFACT, DISPOSABLE_SESSION_ARTIFACT,
  CONTENT_ON_MAIN, CONTENT_IN_HISTORY, STAGED_TREE_IS_COMMIT, UNIQUE}` from each of the
  three cross-check locations.
- **Cross-check count:** 6.
- **Member-set comparison:** identical after normalizing `STAGED_TREE_IS_COMMIT <sha>` to
  its token `STAGED_TREE_IS_COMMIT` (the `<sha>` is a payload, not a distinct verdict). All
  four statements agree. **Assertion accepted.**

### Claim C — The stub dispatcher handles **13** subcommand arms, and the production libraries invoke **13** distinct git subcommands; the classifier requires **5** new arms.

- **Complete family:** (i) every named subcommand arm in the stub's dispatcher; (ii) every
  distinct git subcommand the production libraries pass through `cleanup_wt_git`.
- **Exhaustive search scope:** `tests/fixtures/cleanup_worktrees/stub-bin/git:96-208` for
  (i); all four files under `scripts/bash/cleanup_worktrees*`/`cleanup-worktrees.sh` for
  (ii).
- **Inclusion rules:** for (i), each `<token>)` case label under `case "$subcmd" in`; for
  (ii), the first non-global-option token following `cleanup_wt_git` (skipping `-C <path>`).
- **Exclusion rules:** the `*)` default arm (not a named subcommand); nested `case` labels
  such as `list`/`add`/`remove` under `worktree` and `--abort`/`--skip` under `cherry-pick`
  (they are argument shapes of an already-counted subcommand); comment lines that mention
  `cleanup_wt_git` in prose (`enumerate_lib:18`, `lib:17`).
- **Primary search strategy (stub arms):** read the dispatcher block at `stub-bin/git:96-208`
  and enumerate its top-level case labels.
- **Primary member set:** `{for-each-ref, worktree, merge-base, rev-list, diff, cherry,
  diff-tree, ls-tree, rev-parse, status, cherry-pick, branch, fetch}`.
- **Primary count:** 13.
- **Cross-check search strategy (production call sites):** Grep for the literal
  `cleanup_wt_git ` across `scripts/bash/`, content mode, and reduce each hit to its
  subcommand token. This is a different expression against a different file set, and it
  independently establishes what the stub must cover.
- **Cross-check member set:** from 31 raw hits (2 of which are prose comments, excluded):
  `{for-each-ref, worktree, rev-parse, cherry-pick, branch, fetch, merge-base, status, diff,
  cherry, diff-tree, ls-tree, rev-list}`.
- **Cross-check count:** 13.
- **Member-set comparison:** the two normalized sets are element-for-element identical. The
  stub's coverage of the production call inventory is exact — no unused arm, no uncovered
  call. **Assertion accepted.**
- **Derived requirement (stated as a consequence, not an independent count):** the
  classifier introduces `hash-object`, `log`, `diff-index`, `reset`, and `clean` — **5**
  subcommands absent from both sets above — so the stub needs 5 new arms (18 total), plus
  modifications to the `diff` and `rev-list` arms and to the global-option strip.
  `write-tree` is deliberately **not** added: the non-mutation test asserts its absence, and
  the stub's `*)` default already returns empty/0 for it.

---

## 10. Behavior Semantics

**Success conditions.**

- Report mode: for every non-main, non-bare worktree with at least one status entry, exactly
  one `DIRTFILE|` line per entry and exactly one `DIRTSUM|` line, emitted immediately after
  that worktree's `WORKTREE|` line, in `git status --porcelain` order. Exit code unchanged
  (still the maximum `classify_branch` return).
- Apply mode without the flag: stdout and exit code byte-identical to the pre-change
  behavior.
- Apply mode with the flag on an `ALL_DISPOSABLE` worktree whose branch is delete-eligible:
  `ACTION|dirt-clear|<path>|OK`, then `ACTION|worktree-remove|<path>|OK`, then
  `ACTION|branch-delete|<name>|OK`, driver rc 0.

**Failure conditions (all fail closed).**

- Status read hard-fails → no `DIRT*` lines for that worktree; report mode continues with a
  non-zero contribution; `--clear-disposable` refuses.
- Any per-entry classification read hard-fails → that entry is `UNIQUE` → aggregate is
  `HAS_UNIQUE` → clearing refused.
- Any `UNIQUE` entry → `ACTION|dirt-clear|<path>|REFUSED-UNIQUE`, no reset, no clean, no
  removal retry, `delete_candidate` returns 1, `run_apply` rc 1.
- `reset --hard` or `clean -fd` non-zero → `ACTION|dirt-clear|<path>|FAILED`, no removal
  retry.
- Post-clear `reverify_delete_eligible` flips → `ACTION|delete|<name>|BLOCKED-REVERIFY`, no
  removal retry, no branch delete.
- `--clear-disposable` without `--apply` → usage to stderr, exit 2.

**Ordering rules.** Report: `WARN` → per-worktree (`WORKTREE|`, then its `DIRTFILE|`s, then
its `DIRTSUM|`) → per-branch. Apply clearing: pre-reverify → remove attempt → classify →
clear → post-reverify → remove retry → branch delete.

**Edge cases.** Empty status (no lines). C-quoted path (`UNIQUE`, no unquoting attempt).
Rename entry (classify the new path). Root-commit repository (`rev-list --max-count=N+1
HEAD` with the first entry dropped yields an empty candidate list; no staged-tree probe).
History shorter than the scan depth (`main~N` unresolvable → fall back to `main`). Worktree
with only untracked dirt (no staged-tree probe at all). Ignored files (never in the dirt set,
never cleared).

---

## 11. Q8 — Test Plan Shape

### 11.1 New fixture scenarios

All under `tests/fixtures/cleanup_worktrees/scenarios/`. Each carries the seven-file
baseline from §1.6 (`worktree-list.out`, `for-each-ref.out`,
`rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`, `merge-base.<branch>.rc`=0,
`worktree-remove.rc`=1, `status.<sanitized-wt-path>.out`) plus the verdict-specific files
below. Worktree path `/repo-wt/dirt` sanitizes to `_repo-wt_dirt`.

| # | Scenario directory | `status.*.out` | Additional stub responses | Asserted |
|---|---|---|---|---|
| 1 | `dirt_build_artifact` | ` M src/Legacy/Legacy.csproj` | `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` containing only `+`/`-` `<HintPath>` lines (and the `--cached` counterpart, empty) | `DIRTFILE|...|DISPOSABLE_BUILD_ARTIFACT`; `DIRTSUM|...|ALL_DISPOSABLE` |
| 2 | `dirt_session_artifact` | `?? artifacts/pr_context.summary.txt` | none (path match is pure string comparison; assert no git call was made for it) | `DISPOSABLE_SESSION_ARTIFACT`; `ALL_DISPOSABLE` |
| 3 | `dirt_content_on_main` | `?? docs/copy.md` | `hash-object.docs_copy.md.out` = `bbbb1111`; `rev-parse.main_docs_copy.md.out` = `bbbb1111` | `CONTENT_ON_MAIN`; no `log --find-object` invocation (precedence proof) |
| 4 | `dirt_content_in_history` | `?? docs/old.md` | `hash-object.docs_old.md.out` = `cccc2222`; `rev-parse.main_docs_old.md.rc` = 128 (absent on main); `log.find-object.cccc2222.out` = `ffff8888` | `CONTENT_IN_HISTORY` with detail `ffff8888` |
| 5 | `dirt_staged_tree_is_commit` | `M  src/a.cs` and `M  src/b.cs` | `rev-list.HEAD.out` = `dddd9999\neeee7777\nffff6666`; `diff-index.eeee7777.rc` = 0; `diff-index.ffff6666.rc` = 1 | `STAGED_TREE_IS_COMMIT` with detail `eeee7777`; `DIRTSUM` detail = `eeee7777`; the first `rev-list` entry (`dddd9999` = HEAD) is never probed |
| 6 | `dirt_unique` | `?? notes.md` | `hash-object.notes.md.out` = `9999aaaa`; `rev-parse.main_notes.md.rc` = 128; `log.find-object.9999aaaa.out` absent (empty) | `UNIQUE`; `DIRTSUM|...|HAS_UNIQUE` |
| 7 | `dirt_mixed_unique_blocks` | two lines: `?? artifacts/pr_context.summary.txt` and `?? notes.md` | as in 2 and 6 | one `DISPOSABLE_SESSION_ARTIFACT` + one `UNIQUE`; `HAS_UNIQUE`; `--clear-disposable` emits `REFUSED-UNIQUE` and the argv log contains no `reset --hard` and no `clean` |
| 8 | `dirt_clear_all_disposable` | ` M src/Legacy/Legacy.csproj` | as in 1, plus `worktree-remove.rc` **absent** on the retry — see the limitation below | `ACTION|dirt-clear|...|OK`; argv order `reset --hard` → `clean -fd` → `merge-base` → `worktree remove`; no `--force`; no `-x`/`-X`/`-ff` |
| 9 | `dirt_classifier_read_error` | `?? notes.md` | `hash-object.notes.md.rc` = 128 | `UNIQUE` (fail closed); `HAS_UNIQUE`; clearing refused |
| 10 | `dirt_clear_reverify_order` | as in 8 | as in 8 | the second `merge-base --is-ancestor` appears **after** `reset --hard` in the argv log |

**Stub limitation to record in the plan.** The stub is stateless: it replays the same canned
response for every invocation of the same key. Scenario 8 therefore cannot make the *first*
`worktree remove` fail and the *retry* succeed, and scenario 10 cannot make the post-clear
`reverify_delete_eligible` flip. Two consequences:

- Scenario 8 asserts the clear-and-retry **sequence** through the argv log rather than a
  changing exit code; the retry's outcome line is asserted as whatever the single canned
  `worktree-remove.rc` produces, and the test's subject is the ordering and the absence of
  force/`-x`.
- The post-clear reverification is pinned by **argv ordering** (scenario 10) plus a direct
  unit test of `reverify_delete_eligible` under a non-eligible scenario (the existing
  `unmerged` fixture already supports this, per
  `test_cleanup_worktrees_deletion.bats:36-43`). A stateful stub is not worth introducing
  for this; record the limitation instead of working around it.

### 11.2 Default-unchanged regression tests

- **Report mode:** for each of `merged_with_worktree`, `merged_no_worktree`, `unmerged`,
  `content_neutral`, `residual_on_main`, `residual_unique_doc`, `current_exclusion`,
  `main_divergence` — assert `run_report` stdout is byte-identical to a checked-in expected
  output, and that no `DIRTFILE|`/`DIRTSUM|` line appears (none of these scenarios has a
  `status.<path>` fixture, so the classifier's status read returns empty).
- **Apply mode:** for `dirty_worktree` and `dirty_worktree_status_error` **without** the
  flag — assert `run_apply` stdout is byte-identical to today's, specifically that the
  `DIRTY|` and `ACTION|worktree-remove|...|BLOCKED-DIRTY` lines are unchanged and that no
  `DIRT*` line appears.
- **Exit-code parity:** the existing hard-failure suite (tests 1-17) must pass unmodified
  apart from the added `source` of the new library.

### 11.3 Report-mode non-mutation test

Over `dirt_staged_tree_is_commit`, assert on the stub argv log (§3.4): no `write-tree`, no
`stub-git-env: GIT_INDEX_FILE=`, no `/index`, no `reset`, no `clean`, no `worktree remove`,
no `branch -D`, no `hash-object -w`; every `status` invocation carries
`--no-optional-locks`; and `diff-index --cached --quiet` is present.

### 11.4 CLI tests

- `bash scripts/bash/cleanup-worktrees.sh --clear-disposable` (no `--apply`) → exit 2 with
  usage on stderr.
- `... report --clear-disposable` → exit 2.
- `--help` output contains `--clear-disposable`, `DIRTFILE|`, and `DIRTSUM|`.
- `... --apply --clear-disposable` and `... --clear-disposable --apply` both dispatch to
  apply mode (argument-order independence).

### 11.5 Coverage gate

kcov measures **line coverage only**; the uniform threshold is **>= 85%**
(`.claude/rules/shell.md:68-70`, `.claude/rules/quality-tiers.md`). **No branch-coverage
gate applies to bash**, confirmed in both files. `tests/` is excluded from measurement
(`scripts/bash/shell_qc_lib.sh:336`), so the stub and fixtures do not dilute the metric and
the new production library is fully in the denominator. Ten verdict/path scenarios plus the
error and CLI cases should exercise every rung; watch the `CONTENT_IN_HISTORY` depth-fallback
branch and the C-quoted-path branch, which need dedicated entries or they will be the
uncovered lines.

### 11.6 Toolchain commands (exact)

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh format'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh check'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh test'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh test --coverage'
```

The SKILL.md edits additionally require the Python contract test
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` to pass, which fails
unless the bundle mirror is updated in the same change.

---

## 12. Rejected Alternatives (brief)

- **Report mode gains its own independent `DIRTY|` emission (Q1 option (a)).** Rejected:
  duplicates the status read and the verdict logic that the clearing gate must share, and
  overloads a published three-field record with a second, differently-shaped meaning.
- **Extend `DIRTY|` with a fourth verdict field instead of new record types.** Rejected:
  silently changes a contract published in four places for every consumer, and cannot carry
  the per-worktree aggregate the clearing gate needs.
- **`GIT_INDEX_FILE` + `git write-tree` for `STAGED_TREE_IS_COMMIT`.** Rejected: requires a
  filesystem copy of the real index (a temp file), and still writes tree objects into the
  inspected repository's object database, contradicting report mode's no-mutation contract.
  `git diff-index --cached --quiet` answers the identical question with no writes.
- **Path-pattern-only `DISPOSABLE_BUILD_ARTIFACT`.** Rejected: clears hand edits to non-SDK
  `.csproj` files, which is the normal way source files are registered in the legacy C#
  projects this tool runs against.
- **Configurable session-artifact path list.** Rejected: it is the authorization list for an
  irreversible action; a runtime override defeats the `UNIQUE` gate.
- **Unbounded `git log main --find-object`.** Rejected on cost: the miss case walks the full
  history and is the common case. Bounded by revision range; the bound is one-sided toward
  `UNIQUE`.
- **`git clean -fdx`.** Rejected: ignored files never appear in `git status --porcelain` and
  are therefore never classified; clearing them would be unclassified destruction, and in
  drm-copilot would delete the entire `artifacts/` tree.
- **A stateful stub to model "first call fails, retry succeeds".** Rejected: it would change
  the fixture contract for all six suites to solve one assertion that argv-ordering already
  covers.
