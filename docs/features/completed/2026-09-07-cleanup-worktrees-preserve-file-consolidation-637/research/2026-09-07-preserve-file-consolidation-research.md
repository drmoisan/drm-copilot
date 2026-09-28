# Preserve-file consolidation (issue #637) — research

- **Issue:** #637 (`bug/cleanup-worktrees-preserve-file-consolidation-637`)
- **Epic:** `cleanup-merged-worktrees-hardening`, child F, gap 5
- **Timestamp:** 2026-09-07
- **Author role:** task-researcher
- **Working tree:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a1dc348c3021379d8`
- **Branch:** `bug/cleanup-worktrees-preserve-file-consolidation-637`, branched from
  `epic/cleanup-merged-worktrees-hardening-integration`

## R0. Method, claim strength, and tool limitations

Every `path:line` citation below was derived by this agent against the tree as it stands on this
branch, using the Read, Grep, and Glob tools. Claim strength is stated per finding.

Three tool limitations bound what could be verified and are stated once here so no finding
overstates its evidence:

1. **The Bash tool is disabled for this session.** The tool returned
   `Error: No such tool available: Bash. Bash is disabled for this session, in subagents as well as
   here.` Consequently **no command was executed**: no `wc -l`, no `git check-ignore`, no
   `git ls-files --eol`, no `cmp`/`diff`, no `bats`, no `shell-qc.sh`. Every statement about
   runtime behavior in this document is derived from reading source and configuration, not from
   observing execution, and is labelled as such.
2. **Line counts were derived by reading, not by `wc -l`.** The Read tool renders a file that ends
   with a trailing newline as having one extra, empty final line. Counts below are **content
   lines** (the line number of the last non-empty line), which is the convention
   `epic.md:206-207` uses when it states `cleanup_worktrees_lib.sh` "is at 479 of the 500-line
   cap". See R11.3 for the resulting off-by-one disagreements among sibling research files.
3. **The Grep and Glob tools honor `.gitignore`.** Files under gitignored paths are invisible to
   them. This materially affects R8: the root `.claude/agent-memory/**` tree is gitignored, so its
   absence from Glob results is evidence that **no tracked file exists there**, not evidence that
   no file exists on disk.

No evidence-location override was supplied or required: the delegated path is a research path
under `docs/features/active/<feature>/research/`, which is the canonical location for research
artifacts, not an `evidence/<kind>/` path.

---

## R1. The consolidation surface today

Verified by reading `scripts/bash/cleanup_worktrees_actions_lib.sh` in full (382 content lines).

### R1.1 Constant and path derivation

- `CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"` at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:37`. It is the only module-scope constant in the
  file.
- `consolidation_worktree_path()` at :39-68. Precedence:
  - `CLEANUP_WT_CONSOLIDATION_PATH` overrides unconditionally and returns 0 (:48-52).
  - Otherwise the path is `<main-worktree-path>-wt/documentationandmemories`, formatted at :67 as
    `printf '%s-wt/%s\n' "$main_wt" "$CLEANUP_WT_CONSOLIDATION_BRANCH"`. `main_wt` is the first
    field of the **first** `parse_worktree_list` record (:61-62).
  - A `parse_worktree_list` hard failure returns git's exit code with a stderr diagnostic and no
    stdout (:56-60); an empty main path returns 1 with no stdout (:63-66). Both guards exist
    specifically so the malformed `-wt/documentationandmemories` derivation is impossible.

### R1.2 `create_consolidation_worktree` (:70-101)

- Derives the path through a guarded capture (:84-87).
- **Refuses to reuse an existing branch**: if `rev-parse --verify --quiet
  refs/heads/documentationandmemories` succeeds, it writes a diagnostic to stderr and returns 1
  (:88-93). No `git worktree add` is attempted in that case.
- Otherwise runs `cleanup_wt_git worktree add "$path" -b "$CLEANUP_WT_CONSOLIDATION_BRANCH" main`
  (:94).
- Emits `ACTION|worktree-add|<path>|FAILED` and returns git's rc on failure (:96-97), or
  `ACTION|worktree-add|<path>|OK` and returns 0 (:99-100).

### R1.3 `cherry_pick_candidates` (:103-163) — how it obtains input

This is the function the defect report describes as "the consolidation step".

- **Input is stdin, not an argument.** The loop is `while IFS= read -r line; do` at :125.
- **It consumes exactly one record type.** `[[ $line == COMMIT\|* ]] || continue` at :126 drops
  every non-`COMMIT|` line silently. Fields are then parsed as
  `IFS='|' read -r _ branch sha _ <<<"$line"` at :127, taking only fields 2 (`branch`) and 3
  (`sha`); fields 4 through 7 (`state`, `paths-csv`, `author`, `author-date`) are discarded into
  the trailing `_`. **The `UNIQUE` state token itself is never checked**, so any `COMMIT|` record
  is picked regardless of its state field.
- `$1` is the consolidation worktree path (:124); every git call targets it with `-C` (:138, :148,
  :154, :155).
- **Records it emits:**
  | Line | Record |
  | --- | --- |
  | :130 | `ACTION|cherry-pick|<sha>|SKIPPED-BRANCH` |
  | :143 | `ACTION|cherry-pick|<sha>|OK` |
  | :149 | `COMMIT|<branch>|<sha>|CONTENT_ON_MAIN|reclassified-empty` |
  | :150 | `ACTION|cherry-pick-skip|<sha>|OK` |
  | :157 | `COMMIT|<branch>|<sha>|CONFLICT|` |
  | :158 | `ACTION|cherry-pick|<sha>|CONFLICT` |
- Conflict handling: abort (:154-155), record, set `skip_branch` so the rest of that source
  branch is skipped (:159), set `rc=1` (:160), continue to the next branch. The function returns
  `rc` at :162.
- A stub-specific accommodation exists at :138-141: the combined-output capture re-surfaces
  `stub-git: ` lines to stderr so the bats argv assertions still see them. This is a no-op under
  real git and is relevant to R10 because any new function that captures git output must repeat
  it to remain observable in tests.

### R1.4 `cleanup_consolidation_on_abort` (:165-196)

Undoes exactly two things and always returns 0 (:195):

- Removes the consolidation worktree with `cleanup_wt_git worktree remove "$path"` (:182),
  reporting `ACTION|worktree-remove|<path>|OK` (:184) or `|FAILED` (:186). No force flag is used —
  the docstring at :168-169 records that as a library-global policy.
- Deletes the branch with `branch -D documentationandmemories` (:189), reporting
  `ACTION|branch-delete|documentationandmemories|OK` (:191) or `|FAILED` (:193).
- On a path-derivation failure it emits `ACTION|worktree-remove||FAILED` with an empty target
  field (:180) and still attempts the branch deletion.

**It does not undo any commit, staged change, or file copy.** Nothing in the current abort path
contemplates work products other than a worktree registration and a branch ref.

### R1.5 `verify_consolidation_merged` (:198-216)

- `cleanup_wt_git fetch origin main` best-effort, errors swallowed (:205).
- `merge-base --is-ancestor documentationandmemories main` (:206).
- Echo/return contract: `MERGED_CLEAN`/0 (:207-209), `NOT_ANCESTOR`/1 (:210-212),
  `ANCESTRY_ERROR`/2 (:214-215).

It checks **ancestry only**. It does not check that the branch carries any commit; the run
observations record that as gap 6, owned by sibling child A (#630).

### R1.6 Placement inside `run_apply` (:316-382)

Verified execution order:

| Step | Lines |
| --- | --- |
| Guarded `parse_worktree_list`, abort on failure | :333-336 |
| Guarded `enumerate_branches`, abort on failure | :337-340 |
| `check_main_freshness` | :341 |
| Emit `WORKTREE|` lines and build the `wt_of` map | :342-348 |
| **Consolidation merge gate** (`verify_consolidation_merged`, gate only) | :349-356 |
| Per-branch loop: `classify_branch`, then `delete_candidate` for allowlisted states | :358-380 |

`delete_candidate` (:297-314) runs the fixed order `reverify_delete_eligible` (:309) →
`remove_worktree_safe` (:311, only when the candidate has a worktree) → `delete_branch` (:313).
`remove_worktree_safe` (:252-279) is therefore the **first and only point at which a worktree is
removed**, reached no earlier than :376.

Two further verified facts about `run_apply`:

- It does **not** call `run_report`; it re-implements the `WORKTREE|` emission at :346 and prints
  each `classify_branch` result at :366.
- The consolidation block at :349-356 only *reads* the branch. `run_apply` never creates the
  consolidation worktree and never cherry-picks.

### R1.7 The decisive finding: consolidation has no CLI path

A repository-wide Grep over `*.sh` for `create_consolidation_worktree`, `cherry_pick_candidates`,
`cleanup_consolidation_on_abort`, `verify_consolidation_merged`, and
`consolidation_worktree_path` returns **only** definitions, docstring mentions, and the two
internal uses of `consolidation_worktree_path` (:84, :178) and `verify_consolidation_merged`
(:354).

- `create_consolidation_worktree`, `cherry_pick_candidates`, and `cleanup_consolidation_on_abort`
  have **no call site in any shell file in the repository**. They are invoked only by
  `tests/shell/test_cleanup_worktrees_consolidation.bats`.
- `scripts/bash/cleanup-worktrees.sh` dispatches only three arms plus a usage error (:66-81).
  There is no `--consolidate` arm. `bash scripts/bash/cleanup-worktrees.sh --consolidate` falls to
  the `*)` arm at :77-80, prints usage to stderr, and returns 2.

**Consequence for the defect report and for `issue.md`/`spec.md`.** The issue's repro step 3 says
"Run the consolidation step (`--consolidate`), which cherry-picks the reported commits". That
command does not exist and would exit 2. The observed outcome — "the consolidation step completed
without moving any content" — is consistent with a step that was never runnable from the CLI at
all, not merely with an empty candidate list. This should be corrected in the spec rather than
carried forward. Verified by reading the wrapper's `case` and by the call-site Grep.

### R1.8 What this implies about "the smallest, clearest seam"

The research question asks for the smallest seam at which a preserve-staging step can be inserted
so that it runs before any worktree is removed. The verified constraints are:

1. There is no existing consolidation driver to extend (R1.7). Any new step needs a driver **and**
   a way to reach it.
2. `run_apply` is the only mutating driver, and the earliest point in it at which nothing has been
   removed is between :341 and :349. Inserting there would, however: (a) run preserve staging on
   every `--apply`, including the post-merge `--apply` of `SKILL.md:113-120` where the
   consolidation branch is already merged and the staging is complete; (b) place commit-producing
   mutation inside the deletion driver; and (c) grow `cleanup_worktrees_actions_lib.sh`.
3. The skill's own ordering already places consolidation staging at step 3
   (`SKILL.md:88-94`), before the PR (step 4, :96-105), before merge verification (step 5,
   :107-111), before `--apply` (step 6, :113-120). If staging is its own invocation, "before any
   worktree is removed" is satisfied by the workflow order rather than by intra-function
   placement.
4. Adding a dispatch arm to `cleanup-worktrees.sh` `main` is a small change to a 92-line file
   (408 lines of headroom) and matches how `--apply` reaches `run_apply` (:70-72).
5. `cherry_pick_candidates`'s stdin-record idiom (:125-127) is the established shape for a
   record-consuming step and is already exercised by a bats test that pipes records in
   (`test_cleanup_worktrees_consolidation.bats:39`).

These constraints point toward a new dispatch arm driving a new function group in a **new sibling
library**, not toward an insertion inside `run_apply`. This document does not propose the
implementation; the constraints are recorded so the spec can choose with the facts in view.
Open questions O1 and O2 in R16 record what remains undecided.

---

## R2. The report-line contract

Verified by reading `.claude/skills/cleanup-merged-worktrees/SKILL.md` in full (264 content
lines).

### R2.1 The contract's stated conventions

`SKILL.md:57` is the heading `## Report Line Contract`. `SKILL.md:59` states the conventions
verbatim:

> The script emits pipe-delimited, `LC_ALL=C`-ordered records, one per line:

Three conventions are therefore normative for a new record type: the delimiter is `|`, ordering is
`LC_ALL=C`, and one record occupies exactly one line.

### R2.2 Every existing record type, with exact field order

Enumerated from `SKILL.md:61-71`, which is a bullet list, one bullet per type, in the form
`` - `TYPE|<field>|<field>` — prose. ``:

| # | SKILL.md line | Record shape (exact field order) |
| --- | --- | --- |
| 1 | :61-62 | `BRANCH|<name>|<state>` |
| 2 | :63-65 | `COMMIT|<branch>|<sha>|<state>|<paths-csv>|<author>|<author-date>` |
| 3 | :66 | `WORKTREE|<path>|<branch-or-DETACHED>|<flags>` |
| 4 | :67-68 | `WARN|main-divergence|<local-sha>|<origin-sha>` |
| 5 | :69-70 | `DIRTY|<worktree-path>|<status-porcelain-line>` |
| 6 | :71 | `ACTION|<verb>|<target>|<result>` |

Formatting conventions a new `PRESERVE|<worktree>|<path>|<verdict>` bullet must follow to be
consistent, all read off :61-71:

- The bullet opens with `- ` and the record shape in a single backtick-delimited inline code span.
- Placeholders are angle-bracketed lowercase-with-hyphens (`<worktree-path>`, `<status-porcelain-line>`,
  `<branch-or-DETACHED>`). Note `WARN`'s second field is a **literal** (`main-divergence`), not a
  placeholder — so a literal discriminator in field 2 has precedent.
- The prose follows a spaced em-dash `—` and is a sentence fragment ending in a period.
- Enumerated value sets are written inline in a code span with ` | ` separators
  (`NOT_MERGED | MERGED_CLEAN | ...` at :61-62; `EQUIVALENT | CONTENT_ON_MAIN | EMPTY | UNIQUE |
  CONFLICT` at :64).
- Continuation lines are indented two spaces (:62, :64-65, :68, :70).

### R2.3 The narrowest insertion point

The bullet list runs :61-71. `SKILL.md:72` is blank and `:73` is the next heading
`## End-to-End Workflow`. **The narrowest insertion is a single new bullet appended immediately
after :71**, leaving :61-71 byte-unchanged. Appending is preferable to inserting mid-list because
sibling children edit the same range (R2.5).

### R2.4 Two additional copies of the same list

The record-type list is duplicated twice more in the repository. A new record type is only
consistent if all three are updated (four counting the push-down mirror, R12):

- `scripts/bash/cleanup_worktrees_lib.sh:40-46` — the library header's "Report line contract"
  block, listing the same six shapes.
- `scripts/bash/cleanup-worktrees.sh:42-45` — the wrapper's `usage()` heredoc, listing the same
  six shapes in compressed form.

`cleanup_worktrees_lib.sh` is the file this child must not grow (R11.2), so touching its header
comment is a direct collision risk with the three serialized siblings.

### R2.5 Sibling contention on this exact range

Verified by Grep across `docs/features/active/`:

- **Child B (#631)** extends the Report Line Contract with four new record types
  (`.../631/spec.md:231`, `:433`; `.../631/plan.2026-09-06T23-03.md:571-584`). Its research pins
  the same range: "1.7 SKILL.md — Report Line Contract (verified, line 57-71)"
  (`.../631/research/2026-09-06-report-mode-visibility-gaps-research.md:174`).
- **Child C (#632)** edits "Report Line Contract, Prohibited Shortcuts, and Dirty Worktree Triage
  Procedure" (`.../632/spec.md:294`) and adds a `DIRTFILE|` record (`.../632/spec.md:720`).
- **Child D (#635)** edits `SKILL.md` in four other places — a manifest-write step, step 9 of the
  triage procedure, the `allowed-tools` block, and the `<N>` literal at :104 (issue #635 spec,
  "Skill-text changes required"). It does **not** touch the Report Line Contract.
- **Child G (#634)** states the Report Line Contract is "Unchanged" (`.../634/spec.md:496`).

So the Report Line Contract range is contended by B, C, and F; `allowed-tools` and the triage
procedure are contended by C, D, and F. Line numbers in this section **will move** once B, C, and
D fan into the integration branch and must be re-derived at execution time.

### R2.6 The `PRESERVE` vocabulary already exists in the skill

`PRESERVE` is already a disposition token in the skill text, used at `SKILL.md:141`, `:201`,
`:204`, and `:211` (and its `SAFE_TO_DELETE` counterpart at :141, :201, :211, :242). Step 9
(:204-219) already routes `PRESERVE` findings "through the existing consolidation flow ... before
that worktree's dirty content is discarded". The gap is that no machine-readable record carries
the finding to the script.

The `<verdict>` field of a `PRESERVE|` record maps to the step-5 classification at
`SKILL.md:168-182`, whose members are `DEAD_ONE_OFF` (:169-172),
`ALREADY_SOLVED_ELSEWHERE` (:173-175), `STALE_OR_CONTRADICTED` (:176-178), and
`GENUINELY_NEW` / `STILL_RELEVANT` (:179-182). Note that :179 writes the last two as **one bullet
holding two alternative labels**; issue #635's Vocabulary table records the same observation and
represents them as two distinct enum members.

---

## R3. `_shared_no_absolute_host_paths` — negative evidence

The expected finding was that the only match is the run-observations document. **That is refuted
in its literal form and confirmed in substance**: four files match the literal, but none of them
is an implementation.

- `SearchScope:` the entire worktree
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a1dc348c3021379d8`, recursive,
  all file types, case-insensitive. (Limitation: the Grep tool honors `.gitignore`, so gitignored
  paths — `/artifacts`, `.claude/agent-memory`, `.claude/worktrees`, `node_modules`, `dist`,
  `out`, `.venv` — were not searched.)
- `SearchPatterns:` a single alternation covering all five required spellings —
  `_shared_no_absolute_host_paths|no_absolute_host_paths|absolute-host-path|host_path|absolute host path`
  — run case-insensitively.
- `SearchResult:` 8 matching lines in 8 distinct files, in two disjoint groups:

  **Group 1 — the literal `_shared_no_absolute_host_paths` (4 files, all epic documents):**
  - `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md:97`
    — the original run-observations sentence.
  - `docs/features/potential/promoted/2026-09-07-cleanup-worktrees-preserve-file-consolidation.md:75`
  - `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/issue.md:77`
  - `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md:73`

  The last three are this child's own promoted lifecycle record, issue body, and spec stub, each
  carrying the same restatement ("does not exist anywhere in this repository"). They are
  derivative of the run observations, not independent evidence.

  **Group 2 — the phrase `absolute host path` (4 files, unrelated feature #423):**
  - `docs/features/completed/2026-07-25-jest-rootdir-testmatch-dot-directory-423/spec.md:148`
  - `.../423/issue.md:88`
  - `.../423/evidence/regression-testing/spot-check-readconfig.2026-07-26T01-16.md:46`
  - `.../423/code-review.2026-07-26T01-32.md:120`

  These concern Jest `<rootDir>` glob interpolation and are unrelated to token sanitization.

  **No match at all** for `no_absolute_host_paths` outside the `_shared_`-prefixed occurrences,
  and **no match at all** for `absolute-host-path` or `host_path`.

**Conclusion (verified).** No production code, test, fixture, configuration file, hook, or schema
in this repository defines, references, or implements `_shared_no_absolute_host_paths`. The name
appears only in prose that asks for it to exist. Issue #635 reaches the same conclusion and
explicitly assigns ownership: "The host-token pattern set consumed by
`preserved_files[].host_token_scan`. This child defines the field contract only; child F (#904)
owns the pattern set and its identifier." **This child must define the pattern set from scratch.**

---

## R4. What a host-token pattern set must catch, and what it must not

### R4.1 No sanitization precedent exists

- `SearchScope:` `scripts/` (recursive), then the whole worktree.
- `SearchPatterns:` `redact|sanitiz|scrub|REDACTED|anonymi` (case-insensitive) over `scripts/`;
  `redact|REDACTED|anonymi|scrub` (case-insensitive) over the whole worktree;
  `USERPROFILE|\$HOME|HOMEPATH|COMPUTERNAME|hostname` over `scripts/`.
- `SearchResult:`
  - `scripts/` — **none** for both pattern sets.
  - Whole worktree, redaction vocabulary — 5 files, none of which redacts anything:
    `.github/instructions/github-actions-ci-cd-best-practices.instructions.md:387` and its bundled
    mirror say staging data should be "anonymized if necessary"; the other three are completed
    feature audit/evidence documents.
  - `.claude/` — only `enforce-powershell-batch-budget.ps1:20,:118` and
    `enforce-python-batch-budget.ps1:19,:115`. Reading
    `enforce-powershell-batch-budget.ps1:108` shows what "sanitized" means there:
    `return ($Value -replace '[^A-Za-z0-9._-]', '_')`. That is **filename-segment escaping so a
    session id cannot escape the state directory**, not content redaction. It is a coincidental
    vocabulary match, not a precedent.

**Conclusion (verified).** There is no repository code that redacts or sanitizes paths, user
names, hosts, or emails. The new pattern set is genuinely novel and has nothing to be consistent
with. The only adjacent character-class convention in the repository is the
`[^A-Za-z0-9._-] → _` escape above, which is used for a different purpose.

### R4.2 Token families the pattern set must cover

Evidence that each family occurs in real content in this repository (counts are occurrences /
files, from the Grep tool in `count` mode, case-insensitive, `.gitignore`-honoring):

| Family | Pattern searched | Occurrences / files | Representative evidence |
| --- | --- | --- | --- |
| Windows absolute path with account name, backslash form | `C:\\Users\\` | 283 / 175 | `.claude/settings.json:75` holds `"c:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\skills\\execute-hard-lock"` |
| Windows absolute path with account name, forward-slash form | `C:/Users/` | 1117 / 468 | `docs/features/potential/promoted/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees.md`; issue #635's own manifest example uses `C:/Users/DanMoisan/repos/...` as a `worktree_path` value |
| WSL mount form, 8.3 short form, POSIX home | `/mnt/c/Users/` \| `DANMOI~1` \| `/home/[a-z]` | 192 / 53 | `epic.md:295` documents the WSL invocation `cd /mnt/c/<worktree>`; `.devcontainer/TROUBLESHOOTING.md`; multiple active-feature specs and plans |
| Email address | `[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}` | 1 / 1 under `docs/features/active/` | `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/baseline/typescript-dependencies.2026-08-24T00-00.md` |
| Machine / host name, UNC `\\host\share` | see caveat | not established | see below |

**UNC and host names — not established.** An attempted combined search whose fourth alternation
branch was intended to match `\\host\share` returned 1552 occurrences across 655 files, but that
branch also matches any doubled backslash inside an escaped string (for example the JSON in
`.claude/settings.json`), so the figure is not a UNC count and is **not used** here. No
independent UNC-form or hostname search was run. **Not verified.** The spec must either derive
this separately or scope the pattern set to the four families above and record UNC/hostname as
out of scope with a reason.

Additional families the evidence suggests but which were **not** independently searched, recorded
as gaps rather than findings: Windows drive letters other than `C:`; `%USERPROFILE%` and `$HOME`
expansions written literally; Git author identity strings; and IP addresses.

### R4.3 The false-positive hazard is severe and concrete

The question "which legitimate repository content would a naive `C:\Users` pattern match?" has a
direct answer: **a great deal of tracked content, including runtime configuration.**

- `.claude/settings.json:75` — a tracked, runtime-read permission entry whose value is an absolute
  host path containing the account name. Its push-down mirror
  `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` carries the same
  string, and the two are held text-equal by the parity test (R12). A repository-wide refusal
  scan would flag a file that **must** contain that string.
- 468 files contain `C:/Users/` and 175 contain `C:\Users\`. The overwhelming majority are
  `docs/features/**` evidence artifacts, audit records, and TypeScript tests whose fixtures are
  deliberately absolute Windows paths (for example
  `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`, 11 occurrences
  across the two forms).
- Issue #635's own manifest example encodes `worktree_path` as
  `"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-0f1c2d"`. **The manifest that
  feeds this child therefore legitimately contains the very tokens the scan must refuse in staged
  file content.** The scan must be scoped to the bytes of the file being staged, never to the
  manifest, never to the repository.

**Design constraint (verified).** The host-token scan must be a per-staged-file content scan with
an explicitly bounded scope. A repo-wide or bundle-wide scan is not viable. This is the same
scoping lesson `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:396-407`
already records for a different scan: "The scan targets only these two files; a bundle-wide or
repository-wide scan would fail on out-of-scope files that legitimately carry stale forms."

A second constraint follows from R10: a bats fixture that exercises the refusal path must itself
be a checked-in file containing a host token. That fixture is repository content and would be
matched by any future repo-wide scan, so its placement and any exemption must be decided
deliberately.

---

## R5. Line-ending re-derivation

### R5.1 `.gitattributes` — what the repository actually declares

- A Glob for `**/.gitattributes` returns **exactly one file**: `.gitattributes` at the repository
  root. Verified.
- Its entire content is one line (`.gitattributes:1`):

  ```
  * text=auto eol=lf
  ```

- There is **no `.editorconfig`** anywhere in the tree (Glob returned no files). Verified.

### R5.2 What that means, and how it contradicts the defect report

Reading git's documented attribute precedence — `eol` overrides `core.autocrlf` — the declared
attribute applies to `*`, i.e. every path git tracks:

- Every tracked text file is stored LF in the index and **checked out LF in the working tree on
  every platform**, including Windows.
- `git add` on a CRLF working-tree file for a path covered by `text=auto` normalizes CRLF to LF in
  the index.

**Therefore, within this repository, "the target file exists with CRLF" is not reachable for any
path git tracks, and "normalize to CRLF then commit" is undone by git at `add` time.** This is a
direct tension with the defect report's stated remedy ("normalize the index files to CRLF (the
consumer checkout is CRLF and appended LF lines produce mixed endings)").

Two reachable explanations, both consistent with the rest of the evidence:

1. **The files in question are not tracked.** The root `.claude/agent-memory/**` tree is
   gitignored (R6). Git never checks those files out and never applies a clean/smudge filter to
   them, so their line endings are whatever the writing tool produced. On Windows that is commonly
   CRLF. This explains the observed mixed endings exactly.
2. **The "consumer checkout" is a different repository.** `epic.md:185-187` and #635's Rollout
   section record that fixes reach consumer repositories through push-down. A consumer repository
   without this `.gitattributes` and with `core.autocrlf=true` would check out CRLF.

**Claim strength.** The `.gitattributes` content and the absence of any other `.gitattributes` or
`.editorconfig` are verified by reading. The behavioral consequences are derived from documented
git semantics and **were not verified by execution** (Bash disabled).

### R5.3 `core.autocrlf`

`C:\Users\DanMoisan\repos\drm-copilot\.git\config` was read in full. It contains a `[core]`
section (:1-9) with `repositoryformatversion`, `filemode = false`, `bare = false`,
`logallrefupdates`, `symlinks = false`, `ignorecase = true`, `hooksPath`, and `longpaths = true`.
**There is no `autocrlf` key.** The global and system configs are outside the readable scope of
this session, so their value is **not verified**. This does not change R5.2's conclusion, because
`eol=lf` in `.gitattributes` takes precedence over `core.autocrlf` for every path.

Two other `[core]` values are relevant downstream: `ignorecase = true` (path comparison must be
case-insensitive, matching `normalize_wt_path`'s lowercasing at
`cleanup_worktrees_enumerate_lib.sh:161`) and `symlinks = false`.

### R5.4 Determining a target's convention with POSIX tools and git

**Git-native options and their limits:**

- `git -C <wt> ls-files --eol -- <path>` reports `i/<index-eol> w/<worktree-eol> attr/<attrs>`.
  It only reports **tracked** paths. The untracked and ignored cases this child exists to serve
  are exactly the cases it cannot answer. Not usable as the primary mechanism.
- `git -C <wt> check-attr text eol -- <path>` works for any path, tracked or not, and reports the
  effective attribute. It answers "what will git do on add", not "what bytes does the file have
  now". Useful as a cross-check, not as the derivation.

**POSIX byte-level derivation.** The convention is a property of the bytes preceding each `\n`.
The available primitives are a count of lines terminated by `\r\n` versus a count of all
terminated lines — for example `LC_ALL=C grep -c $'\r$' <file>` against `wc -l <file>`. The three
required cases resolve as:

| Case | Observable | Consequence |
| --- | --- | --- |
| (a) target does not exist | the file test fails before any read | There is no target convention. A default must be chosen and stated; #635 encodes this as `line_ending: "absent"`. The natural default in this repository is LF, because `.gitattributes` guarantees LF for every tracked path (R5.2). |
| (b) target exists, CRLF | `crlf_count == line_count` and `line_count > 0` | Append with `\r\n`. |
| (c) target exists, LF | `crlf_count == 0` and `line_count > 0` | Append with `\n`. |

Two edge cases the three-case framing omits and that the design must decide:

- **Mixed endings.** `0 < crlf_count < line_count`. There is no single convention to normalize to.
  The rule must be stated explicitly (majority, first-terminator, or refuse-and-report). This is
  recorded as open question O5.
- **No trailing terminator on the final line.** `wc -l` counts newline characters, so a file whose
  last line lacks a terminator under-reports by one, and appending without first adding a
  terminator concatenates the new index line onto the existing last entry. The append operation
  must therefore probe the final byte, not only the terminator statistics.
- **Empty file.** `line_count == 0`; indistinguishable from case (a) for the purpose of choosing a
  convention.

### R5.5 What "normalize to the target's convention" must mean for the defect's specific case

For the case in the defect report — appending a `MEMORY.md` index line to an existing CRLF index
file — the operation decomposes into four ordered obligations, all derived from the above:

1. Re-derive the target's terminator from the **target's current bytes**, ignoring
   `preserved_files[].line_ending`, which #635 marks ADVISORY precisely because a stale value
   "would drive exactly the mixed-ending defect gap 5 exists to fix".
2. Ensure the target's final line is terminated in that convention before appending.
3. Emit the index line's own terminator in that same convention.
4. Recognise that if the target path is one git tracks under `* text=auto eol=lf`, obligation 3 is
   cosmetic: `git add` will re-normalize to LF. The obligation is only load-bearing for
   gitignored or non-git-managed targets, or for a consumer repository. The spec should say this
   plainly rather than assert a CRLF guarantee the repository's own `.gitattributes` overrides.

---

## R6. The root `.claude/agent-memory` tree is gitignored

This is the single most consequential finding for the design and does not appear in `issue.md`,
`spec.md`, or the run observations.

### R6.1 The evidence

- `.gitignore:67` is the entry `.claude/agent-memory`. Verified by reading `.gitignore` in full
  (70 content lines).
- Because the pattern contains a slash that is neither leading nor trailing, gitignore semantics
  anchor it to the directory containing the `.gitignore` — the repository root. It therefore
  matches `<root>/.claude/agent-memory` and **not** the nested
  `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory`. This is confirmed
  observationally: the Grep tool (which honors `.gitignore`) returns files under the nested path
  but none under the root path.
- Related entries: `.gitignore:21` ignores `.claude/worktrees`, and `.gitignore:6` ignores
  `/artifacts` — the directory issue #635 places the manifest in.
- A Glob for `.claude/agent-memory/**` in this worktree returns no files. Given the tool's
  gitignore behavior this establishes **no tracked file exists there**; it does not establish that
  no file exists on disk. The run observations report ~140 such files across 20 worktrees, which
  is consistent.

### R6.2 An in-repo memory already records this fact

`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/epic-orchestrator/MEMORY.md:11`
reads, verbatim:

```
- [Agent-memory is gitignored; mirror it to the bundle](feedback_commit_push_memory_before_pr.md) — repo-root .claude/agent-memory/ is ignored; only the extensions/ bundled mirror is tracked. Rescue worktree memory before removal.
```

Note that the corresponding orchestrator index entry
(`.../orchestrator/MEMORY.md:16`) and the body file
`.../orchestrator/feedback_commit_push_memory_before_pr.md:9` still describe agent-memory files as
"Repo-committed ... under `.claude/agent-memory/<agent-name>/`" and instruct staging them
directly. The two tracked memories disagree with each other; the epic-orchestrator one matches
`.gitignore:67`. Recorded as an observed in-repo documentation discrepancy, not fixed by this
research.

### R6.3 The consequences for this child

1. **`git status --porcelain` in a source worktree will not list these files.** Ignored files
   require `--ignored`. The `remove_worktree_safe` DIRTY-line path
   (`cleanup_worktrees_actions_lib.sh:270-276`) uses plain `status --porcelain` and therefore
   never saw them either — which is a second, independent explanation for why the run's dirt was
   invisible to the script.
2. **`git add` on such a path fails** with `The following paths are ignored by one of your
   .gitignore files` unless `-f`/`--force` is passed. Any staging step must handle this
   explicitly. **Not verified by execution.**
3. **The destination matters more than the source.** If the consolidation target is the root
   `.claude/agent-memory/<agent>/<file>.md`, the staged file is ignored at the destination too and
   the commit either fails or requires `-f`; and even if forced, the file would never reach a
   consumer, because push-down distributes from the bundle. If the destination is the bundle path
   `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/<agent>/<file>.md`,
   the file is tracked — but it then falls under the bundled-memory scope contract (R7.4), which
   requires `metadata.scope: general` on every non-index memory.
4. **Issue #635's `preserved_files[].target_path` is "repo-relative on the consolidation branch"**
   and its example target is `.claude/agent-memory/general-purpose/hook-payload-anomaly-envelope.md`
   — the **ignored** root path. The upstream contract's own example therefore names a destination
   that cannot be committed without `-f` and that push-down would never distribute. This is
   recorded as open question O3 and should be raised with the epic planner, because it is a
   cross-child contract question, not a local implementation choice.

---

## R7. `MEMORY.md` index-line carrying

### R7.1 Where the index sits relative to a lesson file

Verified by Glob over the only tracked agent-memory tree,
`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/**` (13 files, two
namespaces):

```
.../agent-memory/epic-orchestrator/MEMORY.md
.../agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md
.../agent-memory/epic-orchestrator/feedback_no_sendmessage_tool.md
.../agent-memory/epic-orchestrator/feedback_worktree_isolation_branches_from_main.md
.../agent-memory/orchestrator/MEMORY.md
.../agent-memory/orchestrator/feedback_branch_base_check_unmerged_pr_deps.md
.../agent-memory/orchestrator/feedback_commit_push_memory_before_pr.md
.../agent-memory/orchestrator/feedback_every_change_through_lifecycle.md
.../agent-memory/orchestrator/feedback_policy_compliance_not_optional.md
.../agent-memory/orchestrator/feedback_potential_to_issue_creates_github_issue.md
.../agent-memory/orchestrator/feedback_remediation_plan_em_dash_required.md
.../agent-memory/orchestrator/feedback_small_bug_uses_minor_audit.md
.../agent-memory/orchestrator/feedback_test_files_count_against_500_cap.md
```

`MEMORY.md` is a **sibling of the lesson file in the same namespace directory**, one per agent
namespace. The index link is a bare filename with no directory component, so the index is
resolvable only from within its own directory. A file re-namespaced during consolidation
(#635's `target_path` explicitly permits this) therefore needs its index line to land in the
destination namespace's index, not the source's.

### R7.2 The exact shape of an index line

Verified by reading both tracked indexes:

`.../orchestrator/MEMORY.md:9-16` (8 entries) and `.../epic-orchestrator/MEMORY.md:11-13`
(3 entries). Every entry has the form:

```
- [<Title>](<filename>.md) — <one-line hook>
```

with a **spaced em-dash** `—` separating the link from the hook. Examples verbatim:

- `- [test-files-count-against-500-cap](feedback_test_files_count_against_500_cap.md) — the 500-line file cap applies to test files too; QA must scan changed/created production AND test files.`
- `- [No SendMessage tool](feedback_no_sendmessage_tool.md) — a launched child cannot be corrected; delegation prompts must be complete, self-correcting, and fail-closed at launch.`

Title style is inconsistent between the two indexes (kebab-case slugs in some orchestrator
entries, sentence-case prose in others and in all epic-orchestrator entries). There is no
enforced title convention.

**Discrepancy with the upstream contract.** Issue #635's `preserved_files[]` example sets
`memory_index_line` to
`"- [Hook payload anomaly envelope](hook-payload-anomaly-envelope.md) - the deny path a malformed envelope takes"`
— a **hyphen-minus**, not an em-dash. Because #635 defines the field as "the `MEMORY.md` index
line from the source worktree", the correct behavior is to carry the source bytes verbatim rather
than to re-render the separator. The spec should state that explicitly so an implementation does
not normalize the separator and drift from either convention.

### R7.3 Ordering and grouping

Neither index is alphabetically sorted and neither groups by memory type. `.../orchestrator/MEMORY.md:9-16`
runs policy-compliance, test-files-cap, every-change-lifecycle, remediation-plan-em-dash,
branch-base-check, potential-to-issue, small-bug, commit-push — append order, not sorted order.
The same holds for the epic-orchestrator index. **Appending at end of file is consistent with the
observed convention**; no sort or insertion-position rule needs to be honored.

### R7.4 Index-file structure: two variants exist

The two tracked indexes are **not** the same shape as the indexes the memory system currently
instructs agents to write:

- **Tracked bundle variant.** Both files open with YAML frontmatter at :1-7 —
  `name:`, `description:`, and a `metadata:` block declaring `type: index` and `scope: repo`.
  `epic-orchestrator/MEMORY.md` then has an H1 `# Epic Orchestrator Memory Index` at :9 followed
  by bullets at :11-13. `orchestrator/MEMORY.md` has **no H1**; its bullets start at :9.
- **Agent-created variant.** The memory instructions loaded into this session state that
  `MEMORY.md` "is an index, not a memory ... It has no frontmatter", and the project-scope index
  at `C:\Users\DanMoisan\.claude\projects\C--Users-DanMoisan-repos-drm-copilot\memory\MEMORY.md`
  opens with a plain `# Memory Index` heading and no frontmatter.

Consequences for "append the index line":

- Appending at end-of-file is safe for all three observed layouts and never lands inside
  frontmatter. Any position-sensitive rule (for example "insert after the H1") is not universally
  applicable, because one of the two tracked indexes has no H1.
- A **push-down contract applies to the bundle variant**:
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:262-306` asserts that every
  bundled `MEMORY.md` declares `metadata.scope: repo` and that **every bundled non-index memory
  declares exactly `metadata.scope: general`**, rejecting even the fail-safe `repo` default. If
  the consolidation destination is the bundle (R6.3), a preserved lesson file that does not carry
  `metadata.scope: general` fails that test, and a newly created bundled `MEMORY.md` that does not
  carry frontmatter with `scope: repo` also fails it.

### R7.5 The target index may be absent, and duplicates are undefined

- **Absence is the normal case.** The consolidation worktree is created from `main`
  (`cleanup_worktrees_actions_lib.sh:94`). On `main` the only `MEMORY.md` files that exist are the
  two bundled ones (R7.1). Every other agent namespace — `general-purpose`, `task-researcher`,
  `atomic-planner`, and the rest — has **no** index at the destination. #635 covers this with
  `line_ending: "absent"`, but the absent-index case also means the staging step must be able to
  **create** an index file, which raises R7.4's frontmatter question: a newly created index in the
  bundle must carry `scope: repo` frontmatter to satisfy the parity test, while a newly created
  index at the ignored root would follow the no-frontmatter convention.
- **Duplicate index lines are undefined.** No repository code deduplicates index entries. If the
  target `MEMORY.md` already contains a line whose link target equals the incoming file's
  basename, a blind append produces two entries for one file. Neither the run observations nor
  #635 states a rule. Recorded as open question O4.

---

## R8. The bats test seam

### R8.1 The suites in scope

`tests/shell/` contains six `cleanup_worktrees` suites:

- `test_cleanup_worktrees_classification.bats`
- `test_cleanup_worktrees_cli.bats` (63 content lines, read in full)
- `test_cleanup_worktrees_consolidation.bats` (78 content lines, read in full)
- `test_cleanup_worktrees_deletion.bats` (83 content lines, read in full)
- `test_cleanup_worktrees_enumeration.bats`
- `test_cleanup_worktrees_hard_failures.bats`

### R8.2 There is no shared helper library

Verified by reading three suites: each defines its own `setup()` and there is no `load` of a
common file. The only helper function anywhere is `apply()`, defined locally in
`test_cleanup_worktrees_deletion.bats:21-24`. **A new suite therefore duplicates the setup block;
there is no existing helper to reuse.** The block to duplicate is
`test_cleanup_worktrees_consolidation.bats:9-18`:

```bash
setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    CONS="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/consolidation"
    chmod +x "${STUB}" 2>/dev/null || true
}
```

### R8.3 How `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` are wired

- `CLEANUP_WT_GIT_BIN` is consumed by `cleanup_wt_git` at
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh:45-56`. The override is used only when it is
  both non-empty **and** executable (`[[ -n $override && -x $override ]]`, :47); otherwise the
  function falls back to `command -v git` and returns 127 with a diagnostic if nothing resolves
  (:52-55). This is why every suite runs `chmod +x "${STUB}"` in `setup()`.
- `CLEANUP_WT_STUB_SCENARIO` is consumed only by the stub itself, at
  `tests/fixtures/cleanup_worktrees/stub-bin/git:47`. With no scenario configured, `respond()`
  emits nothing and exits 0 (:55-69).
- Both are set per-invocation with `run env VAR=... VAR=... bash -c "..."`
  (`test_cleanup_worktrees_consolidation.bats:21-22`, :30-31, :38-39, :51-52, :62-63, :71-72).
- The library-under-test is loaded by explicit sourcing inside the `bash -c` string, always in the
  order enumerate → lib → actions:
  `bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; create_consolidation_worktree"`.
- **Stdin-driven functions are exercised by piping into a brace group** —
  `test_cleanup_worktrees_consolidation.bats:39`:
  `bash -c "printf 'COMMIT|branch-a|sha-a1|UNIQUE|d|A|d\n...' | { source '${ELIB}'; source '${LIB}'; source '${ALIB}'; cherry_pick_candidates /repo-wt/dm; }"`.
  This is the precedent a record-consuming preserve step would follow.
- A third seam, `CLEANUP_WT_CONSOLIDATION_PATH`, exists
  (`cleanup_worktrees_actions_lib.sh:48`, documented at `cleanup-worktrees.sh:53-54`) but is not
  used by any suite read; the consolidation suite instead supplies a `worktree-list.out` fixture
  and lets the path be derived.

### R8.4 What the stub records and how tests assert against it

- The stub echoes its full argv to **stderr** as `stub-git: <argv>` at
  `tests/fixtures/cleanup_worktrees/stub-bin/git:45`, before any dispatch. The header at :6-8
  explains the choice: stdout stays clean for command substitution, and under bats `run` stderr
  merges into `$output`.
- Tests assert with glob matches against `$output`, for example
  `[[ "$output" == *"cherry-pick -x sha-a1"* ]]`
  (`test_cleanup_worktrees_consolidation.bats:42`) and negative assertions such as
  `[[ "$output" != *"--force"* ]]` (`test_cleanup_worktrees_deletion.bats:31`).
- Relative ordering is asserted by `grep -n | head -n1 | cut -d: -f1` on `$output` and a numeric
  comparison (`test_cleanup_worktrees_consolidation.bats:45-47`;
  `test_cleanup_worktrees_deletion.bats:47-51`).

### R8.5 Scenario directory layout and KEY scheme

A scenario is a **flat directory** of `<KEY>.out` and `<KEY>.rc` files; there are no
subdirectories. `respond()` (:55-69) cats `<KEY>.out` if present and exits `<KEY>.rc` if present,
defaulting to empty stdout and rc 0. `sanitize()` (:49-53) replaces every character outside
`[A-Za-z0-9._-]` with `_`.

The KEY scheme is documented at :20-41 and implemented at :96-208. Representative examples from
the tree:

- `tests/fixtures/cleanup_worktrees/consolidation/ok/worktree-list.out` — 4 lines: `worktree
  /repo/main`, `HEAD aaaa0000`, `branch refs/heads/main`, blank.
- `tests/fixtures/cleanup_worktrees/consolidation/ok/rev-parse.verify.refs_heads_documentationandmemories.rc`
- `tests/fixtures/cleanup_worktrees/consolidation/conflict/cherry-pick.sha-a1.rc`
- `tests/fixtures/cleanup_worktrees/consolidation/empty/cherry-pick.sha-c1.out`
- `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree/status._repo-wt_dirty.out` — one
  line, `?? untracked-artifact.txt`.

### R8.6 What a NEW scenario would need — four blocking gaps

This is the most important part of R8, because three of the four required cases cannot be
expressed by the stub as it stands.

**(a) An untracked preserve file.** The stub has **no case** for `add`, `ls-files`,
`check-ignore`, `commit`, `hash-object`, `cat-file`, or `diff --cached`. Every one of them falls
to the default arm `*) exit 0 ;;` at :205-207, producing empty stdout and rc 0. A scenario
therefore **cannot currently express** "the add failed", "the path is ignored", or "the commit
succeeded with these files". The stub must gain cases and KEYs for each new subcommand the
preserve step invokes. The stub is 208 content lines, leaving 292 lines of headroom against the
500-line cap, so this is feasible.

**(b) A modified preserve file.** The `status` KEY at :178-183 is
`status.<sanitized -C path>`, derived only from the retained `-C` value (:79-82). It is
**flag-insensitive**: `git -C <wt> status --porcelain` and
`git -C <wt> status --porcelain --ignored` collide on one KEY and cannot return different
fixtures. Since discovering an ignored preserve file requires `--ignored` (R6.3) while the
existing DIRTY path uses plain `--porcelain`
(`cleanup_worktrees_actions_lib.sh:270`), a scenario that needs both would require the KEY scheme
to incorporate flags. This is a real, blocking constraint on scenario design.

**(c) A host-token match that must hard-stop.** This is not a git interaction at all; it is a scan
of file bytes. It requires a **checked-in fixture file containing a host token**, not a stub
response. Placement consistent with the tree is
`tests/fixtures/cleanup_worktrees/<new-group>/<scenario>/`. Two second-order consequences: the
fixture is itself repository content matching the pattern set (R4.3), and it must be readable at
a path the function under test is pointed at — which today has no seam, because the preserve
source path would come from the manifest and there is no manifest-path environment override
(R9.3).

**(d) A stale advisory `line_ending`.** This needs two artifacts: a checked-in manifest JSON
fixture asserting (say) `"line_ending": "crlf"`, and a checked-in target file whose real
convention is LF, or vice versa. **Checking in a genuinely CRLF fixture is blocked by
`.gitattributes:1`** (`* text=auto eol=lf`): git normalizes it to LF in the index and checks it
out as LF, so the fixture would silently become LF for every developer and in CI. Producing a real
CRLF fixture requires an explicit `.gitattributes` exception for that path (for example an
`-text` or `eol=crlf` rule scoped to the fixture directory). That exception is a repository-wide
configuration change and must be an explicit spec decision, not an implementation detail.

### R8.7 No temporary files

`.claude/rules/general-unit-test.md` prohibits creating or using temporary files in tests, and
`.claude/rules/shell.md:90-93` restates it for bash: "Tests must not create temporary files; use
checked-in fixtures under `tests/fixtures/` and checked-in stub binaries". Every artifact in
R8.6 must therefore be checked in. This interacts with (c) and (d) above: the fixture content is
permanent repository content.

---

## R9. Upstream contract from issue #635, and a numbering discrepancy

### R9.1 The `preserved_files[]` input contract

Read verbatim from the exported copy of issue #635's spec, section "Technical specification — the
normative manifest contract", subsection "`preserved_files[]` record fields". Restated here as
this child's input contract (fields, types, and fail-closed rules are #635's, not this
document's):

| Field | Type | Allowed values | Consumer obligation on violation |
| --- | --- | --- | --- |
| `worktree_path` | string | non-empty | absent ⇒ not stageable; skip and report |
| `source_path` | string | repo-relative within that worktree | absent or absolute ⇒ skip and report |
| `change_class` | string | `untracked` \| `modified` | absent or out of set ⇒ skip and report |
| `disposition` | string | exactly `PRESERVE` | any other value ⇒ skip |
| `verdict` | string | a step-5 verdict | absent or out of vocabulary ⇒ skip and report |
| `target_path` | string | repo-relative on the consolidation branch | absent ⇒ must not guess; skip and report |
| `memory_index_line` | string or null | the source index line, or `null` | key absent ⇒ skip and report; `null` is valid |
| `line_ending` | string | `crlf` \| `lf` \| `absent` | **ADVISORY**; must be re-derived and compared, never trusted |
| `host_token_scan` | object | `{ result, pattern_set_id }` | absent, non-object, or missing either member ⇒ refuse to stage |
| `evidence` | string | non-empty | absent or empty ⇒ skip and report |

Vocabulary (#635's Vocabulary table, sourced from `SKILL.md`):

- Dispositions: `SAFE_TO_DELETE`, `PRESERVE`.
- Step-5 verdicts: `DEAD_ONE_OFF`, `ALREADY_SOLVED_ELSEWHERE`, `STALE_OR_CONTRADICTED`,
  `GENUINELY_NEW`, `STILL_RELEVANT`.
- Branch states: `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`,
  `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`.

Structural facts #635 pins that constrain this child:

- `removals` and `preserved_files` are **sibling arrays, never nested**, with three stated
  reasons, the third being that `PRESERVE` entries legitimately exist for worktrees with no
  removal record.
- The hooks **never read `preserved_files`**, and #635's AC-17 pins that a malformed
  `preserved_files` produces the same gate decision as an empty one. This child must not assume
  the hooks validated anything in that array.
- The manifest is written by the skill's editorial pass — an LLM — not by a script. Every field
  must therefore be validated fail-closed at consumption.

### R9.2 What #635 leaves for this child to define

- **The pattern set and its identifier.** #635 Non-Goals: "The host-token pattern set consumed by
  `preserved_files[].host_token_scan`. This child defines the field contract only; child F (#904)
  owns the pattern set and its identifier."
- **The allowed values of `host_token_scan.result`.** #635's table writes the value as
  `<scan result>` and its example uses `"clean"`. The enum is not defined anywhere. This child
  must define it.
- **Whether `pattern_set_id` must equal the example literal `child-f-host-tokens-v1`.** #635 gives
  it only as an example value in a JSON block. Undefined.

### R9.3 The manifest path is gitignored — a test-seam consequence

`artifacts/orchestration/cleanup-worktrees-manifest.json` sits under `/artifacts`, which
`.gitignore:6` ignores. #635 records this deliberately ("written by the same agent that issues the
removal, into a gitignored directory (`.gitignore:6`)"). Two consequences for this child:

1. A bats fixture manifest **cannot** live at the real path; it must live under `tests/fixtures/`.
2. There is no seam to point the reader at a fixture. The existing environment overrides are
   exactly three — `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_STUB_SCENARIO`, and
   `CLEANUP_WT_CONSOLIDATION_PATH` (`cleanup-worktrees.sh:47-54`) — and none of them addresses a
   manifest. A new override would be needed, and it **cannot** be supplied as a second CLI
   argument because the wrapper discards one (R11.4).

### R9.4 Issue-number discrepancy — recorded as required

The exported #635 specification refers to this child as **"#904"** throughout (Scope item 3,
D6, the `preserved_files[]` preamble, the Non-Goals entry, and External dependencies). The real
GitHub issue number for this child is **#637**.

The same placeholders are present in the committed epic manifest on this branch, so this is not
confined to the sibling's document:

- `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md:49-51` — a manifest entry
  `issue_num: 904`, `feature_folder: cleanup-worktrees-preserve-file-consolidation`,
  `depends_on: [903]`.
- `epic.md:98-108` — the decomposition table rows `| B | 901 |`, `| C | 902 |`, `| D | 903 |`,
  `| F | 904 |`.
- `epic.md:135` and `:171-173` — prose naming "Child D (#903)" and "Child F consumes the cleanup
  manifest that child D defines".

The real issue numbers, established from the branch names present in
`C:\Users\DanMoisan\repos\drm-copilot\.git\config:241-273` and from the active feature folders,
are: B = **#631**, C = **#632**, D = **#635**, F = **#637**. Children A (#630), E (#545),
G (#634), H (#633), and I (#591) already carry their real numbers in `epic.md`.

**Recommendation:** the spec should cite siblings by real issue number and note the placeholder
mapping once, rather than propagate 901–904. Correcting `epic.md` is the epic planner's call and
is out of this child's scope.

---

## R10. File-size and placement constraints

### R10.1 Current line counts

Derived by reading each file to its end (Bash disabled; see R0.2). Counts are content lines. The
500-line cap in `.claude/rules/general-code-change.md` applies to every one of these; Markdown is
exempt.

| File | Content lines | Headroom to 500 |
| --- | --- | --- |
| `scripts/bash/cleanup_worktrees_lib.sh` | 479 | **21** |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 382 | 118 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | 264 |
| `scripts/bash/cleanup-worktrees.sh` | 92 | 408 |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 264 | n/a (Markdown exempt) |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 208 | 292 |

The 479 figure is corroborated by `epic.md:206-207` ("`cleanup_worktrees_lib.sh` is at 479 of the
500-line cap") and by #635's Constraints section ("21 lines of headroom").

### R10.2 `cleanup_worktrees_lib.sh` must not be grown here

`epic.md:206-209` states the constraint directly: because `cleanup_worktrees_lib.sh` is at 479 of
500, "each of those children adds its new function group in a new or clearly separated file. That
separation, not a dependency edge, is what keeps their fan-in conflict-free."

That three sibling children (#630, #631, #632) add call sites to `run_report` in that file is
asserted by their specs and plans and is **not verified by reading their diffs** — their branches
are not present on this branch. What is verified is `run_report`'s current shape
(`cleanup_worktrees_lib.sh:445-479`) and the 21-line headroom. Either way the conclusion holds:
this child must not add code to `cleanup_worktrees_lib.sh`.

Note that R2.4's finding — the record-type list is duplicated in
`cleanup_worktrees_lib.sh:40-46` — creates a documentation-only pressure on the same file. Adding
one comment line there is within 21 lines but is a fan-in conflict with three serialized
siblings. The spec should decide explicitly whether to touch it.

### R10.3 `main` reads only `${1:-}` — confirmed

Confirmed by reading `scripts/bash/cleanup-worktrees.sh:58-83`. The exact lines:

```bash
main() {
	local exit_code=0
	local command=${1:-}
	case "$command" in
	"" | report)
		run_report || exit_code=$?
		;;
	--apply | apply)
		run_apply || exit_code=$?
		;;
	--help | -h | help)
		usage
		return 0
		;;
	*)
		usage >&2
		return 2
		;;
	esac
	return "$exit_code"
}
```

(`:58` `main() {`, `:64` `local exit_code=0`, `:65` `local command=${1:-}`, `:66` the `case`,
`:81` `esac`, `:82` `return "$exit_code"`, `:83` `}`.)

There is **no `shift`, no reference to `$2` or `$@`, and no option loop**. `$@` appears only at
`:90` in the source-guard, where it forwards to `main`. Therefore:

- `bash scripts/bash/cleanup-worktrees.sh --apply --manifest x` runs apply and **silently
  discards** `--manifest` and `x`. Confirmed. (This is the same defect #635's D6 records as its
  reason for rejecting option (b).)
- `bash scripts/bash/cleanup-worktrees.sh --consolidate` falls to `*)`, prints usage to stderr,
  and returns 2. Confirmed.

Contrast `shell-qc.sh:62-83`, which does implement a `shift` plus a flag loop for
`test [--coverage]`. That is the in-repo precedent if this child needs a flag rather than a bare
subcommand.

### R10.4 How libraries are sourced

`scripts/bash/cleanup-worktrees.sh:9-24`:

- `SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)` at `:10` resolves the script's
  own directory so sourcing is cwd-independent.
- Three `source` statements in a fixed order at `:18`, `:21`, `:24` — enumerate lib, then
  classification lib, then actions lib. The comment at `:12-15` states why: the classification
  functions call `cleanup_wt_git`, `parse_worktree_list`, `compute_protected`, and
  `normalize_wt_path`, all defined in the enumerate lib.
- Each `source` is preceded by a `# shellcheck source=scripts/bash/<file>` directive and a
  `# shellcheck disable=SC1091` suppression (`:16-17`, `:19-20`, `:22-23`), because the path is
  resolved at runtime from `SCRIPT_DIR`.

A new sibling library is wired in by adding the same three-line block. Its position in the
sequence is determined by its dependencies: anything calling `cleanup_wt_git` must be sourced
after `:18`. The bats suites source the same files explicitly in the same order
(`test_cleanup_worktrees_consolidation.bats:11-13` and each `bash -c` string), so a new library
must also be added to every suite that exercises it.

Each library's header states a "Sourcing contract: this library defines functions only; it never
runs work at source time" (`cleanup_worktrees_lib.sh:13-14`,
`cleanup_worktrees_enumerate_lib.sh:12-13`, `cleanup_worktrees_actions_lib.sh:13`). A new library
must honor the same contract, and the CLI suite's source-guard test
(`test_cleanup_worktrees_cli.bats:53-63`) asserts the observable consequence.

### R10.5 Off-by-one disagreements among sibling research files

Two sibling research documents disagree with this one and with each other on the same files:

- `.../630/research/2026-09-06-detached-worktree-classification-and-consolidation-ordering.md:373`
  — "The file is 265 lines, not 264" (about `SKILL.md`).
- `.../631/research/2026-09-06-report-mode-visibility-gaps-research.md:30` — "`SKILL.md` | 264".
- `.../631/research/...:36` — "is 93 lines (prompt said 92, off by one)" (about
  `cleanup-worktrees.sh`).

All three are consistent with a single cause: a file ending in a trailing newline can be reported
as N or N+1 depending on whether the counter counts newline characters or split segments. This
document uses content lines (N), which is the convention `epic.md:206-207` uses. **Any acceptance
criterion that cites a line count must state which convention it uses**, or it will be
adjudicated differently by different agents. No numeric line-count assertion is proposed here.

---

## R11. Push-down mirror obligation

Verified by reading `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` in full
(450 content lines).

### R11.1 What the parity test enforces

- `SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)` at `:20`. `list_scoped_files` (`:39-48`)
  enumerates with `rglob("*")` under that single root, so **the whole `.claude` tree is in scope**
  — `hooks/`, `lib/`, `rules/`, `agents/`, and `skills/` alike.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:106-131`) enumerates every
  repository `.claude/**` file, excludes exactly two things — `.claude/settings.local.json` and
  anything under `.claude/agent-memory/` via `_is_agent_memory_path` (`:76-103`, `:121`) — and for
  each remaining file asserts (a) the path is present in the bundle (`:125-127`) and (b)
  `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (`:128-131`).
- `read_text` (`:51-54`) is `read_text(encoding="utf-8")`. **Parity is UTF-8 text equality, not
  byte equality.**
- Byte equality is asserted only for the three `PLANNER_REVIEW_RESOURCE_PATHS` (`:32-36`) in
  `test_planner_review_resources_exist_and_are_byte_identical` (`:134-144`, comparison at
  `:142-144` via `read_bytes()`). `cleanup-merged-worktrees/SKILL.md` is **not** among them.
- `test_bundled_agent_memory_scopes_are_well_formed` (`:262-306`) enumerates the whole bundled
  `.claude/agent-memory` tree and requires `metadata.scope: repo` on every `MEMORY.md` and exactly
  `metadata.scope: general` on every other memory file — see R7.4.

### R11.2 The mirror for `cleanup-merged-worktrees/SKILL.md`

- **The mirror path exists today**:
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Confirmed by Glob and by reading it.
- **Byte-identity is not verified.** With Bash disabled, no `cmp` or `diff` could be run. What was
  verified: the mirror's lines 55-79 are character-for-character identical to the root file's
  lines 55-79, covering the entire `## Report Line Contract` section and the start of
  `## End-to-End Workflow`. That is consistent with parity across the whole file but does not
  establish it. The parity test asserts text equality and is presumably green on this branch, but
  **this agent did not execute it**.
- Text equality (not byte equality) means a line-ending difference between the two copies would
  not be caught by the parity test but a content difference would. Given `.gitattributes:1`, both
  copies are LF in the working tree anyway.

### R11.3 Obligation for this child

Any edit to `.claude/skills/cleanup-merged-worktrees/SKILL.md` — including the single
`PRESERVE|` bullet from R2.3 — must be mirrored into the bundle path in the same change, or
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails. Sibling child B records
the same obligation for the same file (`.../631/spec.md:204`, `:234-235`, `:433-436`).

---

## R12. Toolchain

### R12.1 Commands and order

From `.claude/rules/shell.md:17-32` (verified by reading), the bash toolchain runs in this order
and restarts from step 1 on any failure or rewrite:

1. **Format** — `bash scripts/bash/shell-qc.sh format` (shfmt write mode).
2. **Lint** — `bash scripts/bash/shell-qc.sh check` (runs `shfmt -d` once over the full file list,
   then `shellcheck` once per file, returning the maximum exit code).
3. **Type check** — not applicable to bash; skip to testing.
4. **Test** — `bash scripts/bash/shell-qc.sh test`; with coverage,
   `bash scripts/bash/shell-qc.sh test --coverage`.

`shell-qc.sh:47-92` confirms the accepted subcommands are exactly `check`, `format`,
`test [--coverage]`, and `--help|-h|help`; anything else prints usage to stderr and returns 2
(`:88-91`). `check` and `format` reject extra positionals (`:49-52`, `:56-59`).

`.claude/rules/shell.md:39` requires the toolchain to run under WSL on Windows.
`epic.md:294-296` gives the concrete invocation used for this epic:
`wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree> && bash scripts/bash/shell-qc.sh <format|check|test --coverage>'`.

### R12.2 Coverage output location and headline

Verified by reading `scripts/bash/shell_qc_lib.sh`:

- Output directory: `SHELL_QC_KCOV_OUT_DIR`, default `artifacts/pester/kcov`, resolved against the
  repo root when relative (`:323-327`). It is deleted and recreated on every run (`:328-330`).
- The include pattern is `"$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash"` and
  the exclude pattern is `"$repo_root/tests"` (`:335-336`), matching `.claude/rules/shell.md:64-67`.
- Per-directory kcov runs are merged (`:361`); kcov writes the merged Cobertura report to
  `<out_dir>/kcov-merged/cov.xml`, which is copied to the canonical `<out_dir>/cov.xml`
  (`:365-370`).
- **The exact headline line** is printed by `print_coverage_summary` at `shell_qc_lib.sh:291`:

  ```bash
  printf 'Bash coverage (lines): %s%%\n' "$percent"
  ```

  with `percent` formatted to exactly one decimal place at `:290`
  (`awk -v r="$rate" 'BEGIN { printf "%.1f", r * 100 }'`). So the printed form is
  `Bash coverage (lines): NN.N%`. It is printed only when the overall run succeeded and `cov.xml`
  is parseable (`:374-377`); a missing or unparseable `cov.xml` prints nothing (`:277-288`).

### R12.3 The gate

- Line coverage **>= 85%**, uniform across tiers T1–T4
  (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).
- **No branch-coverage gate for bash.** `.claude/rules/shell.md:68-70`: "kcov reports line
  coverage only ... Branch coverage is not measurable by kcov for bash; there is no bash
  branch-coverage gate." This is a threshold exemption only — bash production files remain in the
  coverage denominator under the Coverage Exclusion Policy.
- Because the include pattern covers all of `scripts/`, a new library file adds its lines to the
  shared bash denominator. A new, under-tested library lowers the whole repository's bash line
  coverage.

### R12.4 Evidence placement

`artifacts/` is gitignored (`.gitignore:6`, `/artifacts`), so `artifacts/pester/kcov/cov.xml` is
not committed. Under `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:22-30`,
`artifacts/coverage/`, `artifacts/qa/`, `artifacts/baselines/`, and `artifacts/evidence/` are
**forbidden** for evidence output. Coverage output belongs under
`docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence/qa-gates/`
(`SKILL.md:14-20`, `:54`). Fail-before regression output belongs under
`evidence/regression-testing/` (`:52`, `:97`). Timestamps use `yyyy-MM-ddTHH-mm` (`:46`).

---

## R13. Behavior semantics implied by the requirement

Derived from the run observations (gap 5), `SKILL.md`, and #635's contract. These are semantics,
not a design.

### R13.1 Success conditions

A preserve-staging pass succeeds for one `preserved_files[]` record when all of the following
hold:

1. Every required field is present and in vocabulary (R9.1), and `disposition == "PRESERVE"`.
2. The source file exists in the named worktree at the named repo-relative path.
3. The host-token scan of the **source file's bytes** finds no match against this child's pattern
   set.
4. The target's line-ending convention is re-derived from the target's current bytes (never from
   the advisory field), and the written bytes use that convention.
5. When `memory_index_line` is non-null, the destination namespace's `MEMORY.md` carries the line
   after the pass, in the target's convention, with the target's final line properly terminated
   beforehand.
6. The file is staged at `target_path` on the consolidation branch.
7. A `PRESERVE|<worktree>|<path>|<verdict>` record is emitted.

### R13.2 Failure conditions and their required direction

| Condition | Required behavior | Source |
| --- | --- | --- |
| Host-token match | **Hard stop.** "refusing to commit any file that matches ... until sanitized" (run observations gap 5); `issue.md:90` requires confirming "the host-token refusal is a hard stop rather than a warning" | run observations :97; `issue.md:90` |
| Any required manifest field absent or out of vocabulary | Skip that record and report; do not guess | #635 `preserved_files[]` fail-closed column |
| `host_token_scan` absent, non-object, or missing a member | **Refuse to stage** (stronger than skip) | #635 |
| `target_path` absent | Must not guess; skip and report | #635 |
| Advisory `line_ending` disagrees with the re-derived value | The re-derived value governs; the disagreement is reportable | #635 ("re-derive and compare") |
| Source file missing | Undefined by any upstream source — see O6 | — |

### R13.3 Ordering rules

- Preserve staging must complete before the consolidation PR is authored
  (`SKILL.md:88-105`), which must merge before `--apply` (`SKILL.md:107-120`). The ordering
  requirement "before any worktree is removed" is therefore satisfied by the workflow, given
  R1.8.
- Within a pass, per-record ordering must be deterministic and `LC_ALL=C`-ordered to match the
  contract at `SKILL.md:59` and the existing precedent
  (`cherry_pick_candidates`'s docstring, `cleanup_worktrees_actions_lib.sh:106-110`).
- For a given file, the byte-scan gate precedes any write, and the target-convention derivation
  precedes the index append.

### R13.4 Edge cases

Enumerated from the findings above: absent target index (R7.5); target index already containing a
line for the same file (R7.5, O4); target with mixed line endings (R5.4, O5); target whose final
line has no terminator (R5.4); `memory_index_line == null` for a non-memory file (#635, valid);
a `PRESERVE` record for a worktree with no removal record (#635, explicitly legitimate); an
ignored source path requiring `-f` (R6.3); a `target_path` that already exists on `main` with
different content (#635 cites `SKILL.md:157-159` as the reason `target_path` is required); and a
source and target in different agent namespaces (R7.1).

---

## R14. Consolidated design constraints

1. Consolidation has no CLI entry point today; a preserve step needs both a driver and a way to
   reach it (R1.7).
2. `cleanup_worktrees_lib.sh` has 21 lines of headroom and is contended by three serialized
   siblings; do not grow it (R10.1, R10.2).
3. `main` discards every argument after the first, so no flag-with-value can be added without a
   `shift` loop (R10.3).
4. A new library must be sourced after the enumerate lib, define functions only, and be added to
   every bats suite that exercises it (R10.4).
5. `SKILL.md`'s Report Line Contract is contended by children B and C; append one bullet after
   :71 and mirror it (R2.3, R2.5, R11.3).
6. The record-type list is duplicated in two more places (R2.4).
7. The root `.claude/agent-memory` tree is gitignored, so the source files are invisible to plain
   `status --porcelain` and unstageable without `-f`; the destination question is unresolved
   (R6).
8. Bundled non-index memories must declare `metadata.scope: general` and bundled `MEMORY.md`
   files `metadata.scope: repo` (R7.4, R11.1).
9. `.gitattributes` forces LF for every tracked path, so a CRLF target is only reachable for
   ignored files or a foreign checkout, and a checked-in CRLF fixture is impossible without a new
   `.gitattributes` exception (R5.2, R8.6d).
10. The host-token scan must be scoped to staged file bytes; a repo-wide scan is not viable
    because tracked runtime config and 468+ documents legitimately contain the tokens (R4.3).
11. Tests may create no temporary files; every scenario, fixture manifest, and token-bearing
    fixture must be checked in (R8.7).
12. The git stub cannot express three of the four required new scenarios without KEY-scheme and
    subcommand extensions (R8.6).
13. Bash line coverage >= 85% with no branch gate; evidence to `evidence/qa-gates/` (R12).

---

## R15. Numeric Derivation Evidence

This document proposes **no** numeric acceptance criterion. This section is recorded for the one
enumeration a downstream spec is most likely to cite — the existing report record types — and for
the line counts in R10.1, so the spec author can decide with the derivations in hand.

### R15.1 Existing report record types

- **Complete Family:** every distinct record type emitted to the `cleanup-worktrees.sh` report
  stream (report mode and apply mode combined), as of this branch, before any sibling child lands.
- **Exhaustive Search Scope:** `.claude/skills/cleanup-merged-worktrees/SKILL.md` (whole file,
  read); and all four shell files that can emit a report line —
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`,
  `scripts/bash/cleanup_worktrees_actions_lib.sh`, `scripts/bash/cleanup-worktrees.sh` — all read
  in full, plus a Grep over `scripts/bash/` for every `printf` whose first literal token is an
  uppercase word followed by `|`.
- **Inclusion Rules:** a record type is a member when it is emitted on stdout by `run_report` or
  `run_apply` or by a function they call, as a pipe-delimited line whose first field is an
  uppercase discriminator.
- **Exclusion Rules:** excluded are (a) internal echo-verdict tokens returned to a caller through
  command substitution and never printed to the report stream; (b) lowercase internal tokens; (c)
  stderr diagnostics; (d) the stub's `stub-git: ` argv log.
- **Primary Search Strategy:** enumerate the bullets of the prose contract at `SKILL.md:59-71`,
  one bullet per type.
- **Primary Member Set:** `{ACTION, BRANCH, COMMIT, DIRTY, WARN, WORKTREE}` (normalized to
  alphabetical order).
- **Primary Count:** 6.
- **Cross-check Search Strategy:** a Grep over `scripts/bash/` for the regex
  `printf '[A-Z][A-Z_-]*\|` in `only-matching` mode, enumerating every emission site in the
  implementation rather than the prose, then applying the exclusion rules.
- **Cross-check Member Set:** the Grep returned 38 emission sites spanning
  `{UNIQUE, COMMIT, BRANCH, WORKTREE, WARN, ACTION, DIRTY}`. Applying exclusion rule (a) removes
  `UNIQUE`: `cleanup_worktrees_lib.sh:249` emits `UNIQUE|<paths-csv>` as
  `classify_residual_commit`'s echo-verdict, captured into a variable at `:294` and `:405` and
  never printed. Applying exclusion rule (b) confirms `protected-branch|` and `protected-path|`
  (`cleanup_worktrees_enumerate_lib.sh:197`, `:212`, `:214`) are already outside the regex.
  Remaining set, normalized to alphabetical order:
  `{ACTION, BRANCH, COMMIT, DIRTY, WARN, WORKTREE}`.
- **Cross-check Count:** 6.
- **Member-set Comparison:** the normalized primary set and the normalized cross-check set are
  identical, element for element:
  `ACTION == ACTION`, `BRANCH == BRANCH`, `COMMIT == COMMIT`, `DIRTY == DIRTY`, `WARN == WARN`,
  `WORKTREE == WORKTREE`. No member is present in one set and absent from the other. Counts agree
  at 6.
- **Two further corroborating surfaces** (not used as the cross-check, recorded for completeness):
  the library header list at `cleanup_worktrees_lib.sh:40-46` and the wrapper usage text at
  `cleanup-worktrees.sh:42-45` each enumerate the same six shapes.
- **Stability caveat that makes this unsuitable as an acceptance criterion:** children B (#631)
  and C (#632) each add record types to this family before this child executes. Any spec that
  asserts "there are 6 record types" or "PRESERVE is the 7th" will be false at execution time.
  **The assertion is withheld.**

### R15.2 Line counts in R10.1

- **Complete Family:** the content-line count of each of the six files listed in R10.1.
- **Exhaustive Search Scope:** each file individually, read from line 1 to its end.
- **Inclusion Rules:** a content line is a line bearing a line number in the Read tool's output
  that is not the trailing empty artifact line described in R0.2.
- **Exclusion Rules:** the trailing empty artifact line is excluded.
- **Primary Search Strategy:** full-file Read of each file; the count is the line number of the
  last non-empty line.
- **Primary Member Set / Counts:** `cleanup_worktrees_lib.sh` 479; `cleanup_worktrees_actions_lib.sh`
  382; `cleanup_worktrees_enumerate_lib.sh` 236; `cleanup-worktrees.sh` 92; `SKILL.md` 264;
  `stub-bin/git` 208.
- **Cross-check Search Strategy:** a second, offset Read of the tail of each of the two files
  whose count is closest to a policy boundary or most cited, requesting a range that begins before
  and ends after the expected last line, so the boundary between content and artifact is directly
  observable rather than inferred from a truncated first read.
- **Cross-check Member Set / Counts:** `cleanup_worktrees_lib.sh` read from offset 475 shows
  `475..479` as content and `480` as the empty artifact ⇒ 479. `cleanup_worktrees_actions_lib.sh`
  read from offset 378 shows `378..382` as content and `383` as the empty artifact ⇒ 382.
  `SKILL.md` read from offset 260 shows `260..264` as content and `265` as the empty artifact ⇒
  264. `stub-bin/git` read from offset 204 shows `204..208` as content and `209` as the empty
  artifact ⇒ 208.
- **Member-set Comparison:** for every file cross-checked, the primary and cross-check counts are
  equal (479 == 479, 382 == 382, 264 == 264, 208 == 208). Two files
  (`cleanup_worktrees_enumerate_lib.sh` 236 and `cleanup-worktrees.sh` 92) were **not**
  independently cross-checked by an offset read; their counts rest on a single derivation and are
  labelled accordingly.
- **Independent corroboration for the load-bearing figure:** `epic.md:206-207` and issue #635's
  Constraints section both independently state 479 / 21 lines of headroom for
  `cleanup_worktrees_lib.sh`, matching this derivation.
- **Withheld:** no acceptance criterion asserting a specific line count is proposed, both because
  two of the six counts have a single derivation and because sibling children will change three of
  the six files before this child executes. A cap-conformance criterion should be written as "no
  file changed or added by this work exceeds 500 lines, verified per file" — a predicate, not a
  count — following #635's AC-27.

---

## R16. Open questions for the spec author and the epic planner

- **O1 (design, this child).** Should preserve staging be a new dispatch arm on
  `cleanup-worktrees.sh` (a bare subcommand, since a flag-with-value needs a `shift` loop per
  R10.3), or should it remain a library function driven only by the skill and tests? A bare
  subcommand needs a way to locate the manifest, which R9.3 shows requires a new environment
  seam.
- **O2 (design, this child).** Does the preserve step also create the consolidation worktree, or
  does it require one to exist? `create_consolidation_worktree` has no caller (R1.7), and
  `cleanup_consolidation_on_abort` does not undo commits or staged files (R1.4), so the abort
  contract would have to grow if staging can partially succeed.
- **O3 (cross-child, escalate to the epic planner).** #635's `target_path` example names the
  gitignored root `.claude/agent-memory/...`. Is the consolidation destination the ignored root
  path, the tracked bundle path, or both? The answer determines whether `-f` is required, whether
  push-down distributes the preserved lesson, and whether the bundled-memory `scope: general`
  contract applies (R6.3, R7.4, R11.1).
- **O4 (this child).** What happens when the target `MEMORY.md` already contains an index line for
  the same file — skip, replace, or append a duplicate? Nothing upstream states a rule (R7.5).
- **O5 (this child).** What is the rule for a target file with mixed line endings — majority,
  first terminator, or refuse and report (R5.4)?
- **O6 (this child).** What happens when a manifest record names a `source_path` that does not
  exist in the named worktree? #635's fail-closed column does not cover it (R13.2).
- **O7 (this child).** What is the allowed value set for `host_token_scan.result`, and must
  `pattern_set_id` equal `child-f-host-tokens-v1`? Both are undefined upstream (R9.2).
- **O8 (this child).** Does the pattern set cover UNC paths and hostnames? Their presence in the
  repository was **not** established (R4.2) and a scoping decision with a stated reason is
  required either way.
- **O9 (this child, blocking a test).** Does this work add a `.gitattributes` exception so a real
  CRLF fixture can be checked in, or is the CRLF-target case exercised by constructing the bytes
  another way? Without an exception the case cannot be represented as a checked-in fixture
  (R8.6d).
- **O10 (this child, blocking a test).** Does the git stub's KEY scheme gain flag awareness so
  `status --porcelain` and `status --porcelain --ignored` can return different fixtures (R8.6b)?
- **O11 (documentation, epic planner).** `epic.md` and #635 use placeholder issue numbers
  901/902/903/904 for children B/C/D/F, whose real numbers are 631/632/635/637 (R9.4). Who
  corrects `epic.md`?
- **O12 (documentation, this child).** `issue.md` and `spec.md` describe running `--consolidate`,
  a flag that does not exist and exits 2 (R1.7). Both should be corrected before the spec is
  approved.
- **O13 (documentation, observed, not fixed).** The two tracked orchestrator memories contradict
  each other on whether `.claude/agent-memory/` is tracked (R6.2). Recorded, not corrected here.

---

## R17. Sources read

Repository files read in full or in the cited ranges, all on this branch:

- `scripts/bash/cleanup_worktrees_actions_lib.sh` (full)
- `scripts/bash/cleanup_worktrees_lib.sh` (full)
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` (full)
- `scripts/bash/cleanup-worktrees.sh` (full)
- `scripts/bash/shell-qc.sh` (full); `scripts/bash/shell_qc_lib.sh` (cited ranges)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` (full)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` (:55-79)
- `.claude/rules/shell.md` (full)
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (full)
- `.gitattributes` (full); `.gitignore` (full); `C:\Users\DanMoisan\repos\drm-copilot\.git\config` (full)
- `tests/shell/test_cleanup_worktrees_{cli,consolidation,deletion}.bats` (full)
- `tests/fixtures/cleanup_worktrees/stub-bin/git` (full);
  `tests/fixtures/cleanup_worktrees/consolidation/ok/worktree-list.out`;
  `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree/status._repo-wt_dirty.out`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (full)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/MEMORY.md`
  and `.../feedback_commit_push_memory_before_pr.md`;
  `.../epic-orchestrator/MEMORY.md`
- `.claude/hooks/enforce-powershell-batch-budget.ps1` (:108-152)
- `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` (cited ranges)
- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md` (:60-119)
- `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/issue.md` (full)
  and `spec.md` (full)

External, cited by issue number and section name and **not** copied into the repository:

- Issue #635 specification, `bug/cleanup-worktrees-sanctioned-removal-manifest-635`, sections
  "Scope & Non-Goals", "Technical specification — the normative manifest contract"
  (`preserved_files[]` record fields, Vocabulary), "Push-down parity", "Constraints",
  and the acceptance criteria AC-17 and AC-27.
