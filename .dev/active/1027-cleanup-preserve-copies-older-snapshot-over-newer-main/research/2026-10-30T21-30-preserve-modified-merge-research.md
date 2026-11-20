# Research: cleanup-worktrees `--preserve` copies an older snapshot over newer `main` (Issue #1027)

- Issue: #1027
- Branch: bug/cleanup-preserve-older-snapshot-1027-r2
- Mode: preparation (research only)
- Environment facts: see `.claude/skills/execution-environment/SKILL.md`; they are cited, not restated.

## 1. Current Preserve Staging Flow (verified by reading the sources)

### Dispatch

- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`, function `main`: the `preserve | --preserve` case arm calls `run_preserve` and takes no operand. The wrapper sources, in order, `cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_detached_lib.sh`, `cleanup_worktrees_dirt_lib.sh`, `cleanup_worktrees_preserve_eol_lib.sh`, `cleanup_worktrees_preserve_lib.sh`. The `usage` text states that preserve mode "Copies each named source file verbatim".

### `cleanup_worktrees_preserve_lib.sh` (two-phase design)

- `run_preserve`: checks that the consolidation worktree (`consolidation_worktree_path`) is a directory (else `ACTION|preserve-stage||MISSING-WORKTREE`, exit 1) and that the manifest is a readable file (else `ACTION|preserve-manifest|<path>|MISSING`), then runs `preserve_plan` and `preserve_commit_plan`, returning `PRESERVE_EXIT`. Exit contract: 0 clean, 1 something skipped/refused/failed or an index created, 3 host-token hard stop, 127 tool unresolved.
- `preserve_read_manifest`: one jq call (`preserve_resolve_jq`, seam `CLEANUP_WT_JQ_BIN`) validates `tool`/`schema_version` and projects each `preserved_files[]` entry into a 14-column TSV; failure emits `ACTION|preserve-manifest|<path>|REJECTED`.
- `preserve_validate_record`: fail-closed field matrix; any violation emits `ACTION|preserve-stage|<target>|SKIPPED-INVALID`. `change_class` is checked only for vocabulary (`untracked` | `modified`). Its header comment states the defect as a design rule: "change_class is validated for vocabulary but does NOT change the staging action: an untracked and a modified record are both copied to target_path and staged".
- `preserve_plan` (phase 1, documented as performing no writes): sorts records `LC_ALL=C` by (worktree_path, source_path) and calls `preserve_plan_one` for each.
- `preserve_plan_one`, in order: validate; emit `PRESERVE|<wt>|<src>|<verdict>`; `MISSING-SOURCE` if `<wt>/<src>` is not a regular file; advisory `ACTION|preserve-scan|<tgt>|PATTERN-SET-MISMATCH`; `HOST-TOKEN-BLOCKED` (upstream `tokens_present` or `preserve_scan_host_tokens` match; sets `PRESERVE_BLOCKED`); `IGNORED-TARGET` via `git -C <cwt> check-ignore -q`; index decision via `preserve_plan_index` (EOL library); then appends an 8-column entry (target, source file, destination file, index action, index path, index line, terminator, leading-terminator flag) to `PRESERVE_PLAN_STREAM`. No step reads the destination's current content.
- `preserve_commit_plan` (phase 2, the only writer): per entry `mkdir -p`, then `cat -- "$srcfile" >"$dstfile"` (the whole-file overwrite that causes the bug), the optional index append, `git -C <cwt> add -- <tgt>`, and the index `add`. Any failure emits `ACTION|preserve-stage|<tgt>|FAILED`; success emits `ACTION|preserve-stage|<tgt>|OK`.
- Current `ACTION|preserve-stage` result vocabulary (complete, from the source): `OK`, `FAILED`, `SKIPPED-INVALID`, `MISSING-SOURCE`, `HOST-TOKEN-BLOCKED`, `IGNORED-TARGET`, `MISSING-WORKTREE`. Sibling channels: `ACTION|preserve-manifest|…|REJECTED|MISSING`, `ACTION|preserve-scan|…|PATTERN-SET-MISMATCH`, `ACTION|preserve-index|…|OK|CREATED|SKIPPED-DUPLICATE|EOL-MIXED`, `ACTION|preserve-eol|…|ADVISORY-MISMATCH`. `REFUSED-WOULD-REGRESS` does not exist yet.
- Library invariants that a fix must keep: the source is read by plain file I/O, never through git (the repository-root `.claude/agent-memory` tree is gitignored); no `cleanup_wt_git` call passes `-f`/`--force`; every git call goes through `cleanup_wt_git` (seam `CLEANUP_WT_GIT_BIN`).

### `cleanup_worktrees_preserve_eol_lib.sh`

- `preserve_plan_index`, `preserve_derive_line_ending`, `preserve_index_has_entry`, `preserve_index_needs_terminator`, `preserve_line_terminator`, `preserve_render_index_append`. Scope is the `MEMORY.md` index sibling of `target_path` only; the preserved file's own bytes are explicitly never transformed. It is not involved in the defect and needs no change.

### Consolidation branch and "main's current version"

- `cleanup_worktrees_actions_lib.sh`: `CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"`; `consolidation_worktree_path` returns `CLEANUP_WT_CONSOLIDATION_PATH` or `<main-worktree-path>-wt/documentationandmemories`; `create_consolidation_worktree` runs `git worktree add <path> -b documentationandmemories main`, so the branch starts at local `main` and then receives cherry-picks (`cherry_pick_candidates`). `run_preserve` never creates it.
- At staging time, "main's current version" of a target is therefore the working-tree file `<cwt>/<target_path>` in the consolidation worktree (main at branch creation plus consolidated commits). That is also the file the copy overwrites, so it is the correct comparand.
- Merge-base derivability: `worktree_path` names a linked worktree of the same repository (the manifest records come from `git worktree list` triage), so it shares the object store with the consolidation worktree. The base commit is derivable inside the script as `git -C <wt> rev-parse --verify --quiet HEAD` followed by `git -C <cwt> merge-base <wt-head> HEAD`, and the base blob as `git -C <cwt> rev-parse --verify --quiet <merge-base>:<source_path>`. Each of these can fail (worktree path not a worktree of this repository, unrelated history, file absent at the base); the design below treats every failure as "base unavailable".

## 2. Documented Contract

- `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `## Report Line Contract` (record list): `PRESERVE|<worktree-path>|<source-path>|<verdict>`, "per-file outcome is reported by the companion `ACTION|preserve-stage|...` record". The SKILL does not enumerate the `ACTION|preserve-stage` result tokens anywhere, and the End-to-End Workflow does not mention `--preserve`.
- `## Sanctioned Removal Manifest` → `### preserved_files[] record fields`: `change_class` — "either `untracked` or `modified`, recording whether staging adds a new file or carries a working-tree modification"; `target_path` — required "because the same relative path may already exist on `main` with different content and a lesson file may be re-namespaced". The second sentence acknowledges that an existing target can differ from the source, but no consumer behavior guards it.
- `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, `Test-CleanupWorktreeManifestAuthorizesRemoval`: its help text states it "never reads the preserved_files array". No schema or validator constrains `change_class` or the preserve verdict vocabulary outside the bash library. No change is needed there.

## 3. Existing Tests and Impact

All preserve tests are bats suites under `tests/shell/` driven through the recording git stub `tests/fixtures/cleanup_worktrees/stub-bin/git` and the jq stub `tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq`, against fixtures under `tests/fixtures/cleanup_worktrees/preserve/`. No Pester or Python test asserts preserve behavior or the `preserve-stage` vocabulary (search of `tests/` for `preserve-stage`, `change_class`, `run_preserve`, `preserve_plan`, `preserve_commit_plan`, `cleanup_worktrees_preserve` returned only the bats suites, their fixtures, the git stub, and one comment in `test_cleanup_worktrees_scan_roots.bats`).

Key fact for impact: no preserve fixture places a regular file at `<consolidation>/<target_path>`. Scenarios that write use `CLEANUP_WT_CONSOLIDATION_PATH=/dev` with `target_path` `null` (`/dev/null` is a character device, not a regular file) or a target under a consolidation fixture that holds only `MEMORY.md`. If the fix keys the new behavior on `[[ -f <cwt>/<target_path> ]]` (regular file) and takes no git action when it is false, every existing test keeps its current argv log and outcome. Using `-e` instead of `-f` would route `/dev/null` targets into the new path and break the tests marked "would break under `-e`" below.

| Suite | Test | Effect of the recommended fix |
|---|---|---|
| `test_cleanup_worktrees_preserve.bats` | `the git stub replays a scenario response for add` | Unaffected (stub-only). |
| same | `the git stub replays a scenario response for check-ignore` | Unaffected. |
| same | `an untracked preserve record is staged and reported` | Unaffected (target `/dev/null` not a regular file); would break under `-e`. |
| same | `a host token match aborts the pass before any staging` | Unaffected (refused before the new step). |
| same | `preserve library defines functions only and runs no work at source time` | Must be extended with a case that sources the new library; otherwise unaffected. |
| same | `an unresolvable jq returns 127 and stages nothing` | Unaffected. |
| same | `a manifest with a wrong tool or schema_version is rejected and stages nothing` | Unaffected. |
| same | `an absent or malformed host_token_scan refuses to stage the record` | Unaffected. |
| same | `each missing or out of vocabulary field skips the record and reports` | Unaffected (validation unchanged). |
| same | `preserve subcommand dispatches to the preserve driver` | Uses the `modified` scenario through the wrapper; unaffected provided the wrapper sources the new library; would break under `-e`. |
| same | `an unknown subcommand still prints usage to stderr and returns 2` | Unaffected (usage text edits do not touch the asserted `Usage: cleanup-worktrees.sh`). |
| same | `the manifest path is taken from CLEANUP_WT_MANIFEST_PATH` | Uses `modified`; unaffected; would break under `-e`. |
| same | `a missing consolidation worktree reports MISSING-WORKTREE and stages nothing` | Unaffected. |
| same | `a modified preserve record is staged and reported` | Outcome unaffected (absent target → copy), but its comment "change_class `modified` takes the identical staging path as `untracked`" becomes false and must be rewritten to "a modified record whose target is absent on the consolidation branch is copied"; would break under `-e`. |
| same | `records are emitted in LC_ALL=C order regardless of manifest order` | `order` scenario has one `modified` record; target absent under `/dev`; unaffected. Remains unaffected even if refused, because `PRESERVE|` is emitted before the new decision. |
| same | `a null memory_index_line stages the file and touches no index` | Unaffected. |
| same | `a missing source file is reported as MISSING-SOURCE` | Unaffected. |
| same | `an ignored target path is refused without a force flag` | Unaffected (refused before the new step). |
| same | `the preserve exit codes distinguish clean, skipped, and blocked runs` | Unaffected (all `untracked`, `/dev` targets). |
| same | `the memory index line is appended verbatim to the destination index` | Unaffected. |
| same | `an absent destination index is created and reported as CREATED` | Unaffected. |
| same | `a duplicate index entry is skipped and does not change the exit code` | Unaffected. |
| same | `each host token pattern is detected` | Unaffected. |
| same | `HEAD~1 and other revision syntax do not match the short-name pattern` | Unaffected. |
| same | `the host token scan reads only the named source file` | Unaffected. |
| same | `a pattern set id mismatch is reported and the local scan governs` | Unaffected. |
| `test_cleanup_worktrees_preserve_eol.bats` | `a stale advisory crlf value does not override an LF target` | `eol-stale` is `modified`; target absent under its consolidation fixture; unaffected only if the new decision does not refuse before `preserve_plan_index` emits `ADVISORY-MISMATCH`, which the absent-target short circuit guarantees. |
| same | the other five tests (`the crlf fixture still contains…`, `an unterminated final line…`, `an advisory line ending mismatch…`, `a crlf target receives…`, `a mixed line ending target…`) | Unaffected. |
| `test_cleanup_worktrees_preserve_failures.bats` | five writing-phase tests via helper `preserve_commit_one` (`a destination directory that cannot be created…`, `a failed verbatim byte copy…`, `a failed index append…`, `a failed staging call…`, `a failed index staging call…`) | The helper builds 8-column plan entries. Unaffected if new plan-stream columns are appended after column 8 and an empty mode column means "verbatim copy". |
| same | remaining six tests (validation reasons, `tokens_present`, rejected manifest, index-line host token) | Unaffected. |
| `test_cleanup_worktrees_scan_roots.bats` | `preserve_relative_path_reason …` (two tests) | Unaffected (sources the preserve library without the new one; the new library must not be needed at source time). |
| `test_cleanup_worktrees_dirt_clear.bats` | `dirt_staged_tree_is_commit: report mode issues no mutating git command…` | Asserts no `hash-object -w` in report mode. The new `hash-object -w` call runs only in preserve mode; unaffected. |

Git stub: its header comment cites production call sites by line number (`cleanup_worktrees_preserve_lib.sh:400,402`) and says the stub "defines no -w behavior because the dirt classifier never writes an object"; both comments become stale and should be corrected in the same change. The stub's `merge-base` arm answers only `--is-ancestor`; any other form exits 0 with empty stdout. It has no `cat-file` or `merge-file` arm. The production libraries call `merge-base` only with `--is-ancestor` (verified across all scripts), so adding new arms cannot change existing scenarios.

## 4. Design Options

Inputs for a `modified` record whose target exists:

- Worktree file `<wt>/<source_path>`: always available (checked by `MISSING-SOURCE`), read by plain I/O.
- Main's version `<cwt>/<target_path>`: available whenever the target is a regular file.
- Base blob: available only when (i) `<wt>` resolves `HEAD`, (ii) a merge-base with the consolidation `HEAD` exists, (iii) `<merge-base>:<source_path>` exists, and (iv) `source_path == target_path` (otherwise the base belongs to a different file's history and a merge is meaningless). Unavailable cases: worktree path is not a worktree of this repository, unrelated histories, the file was created on both sides after divergence, or a re-namespaced target.

### (a) `git merge-file` three-way merge, conflict → refuse

- Mechanics: `git merge-file` needs three files or, from Git 2.43, `--object-id` with three blob ids ("If the `-p` option is specified, the merged file … goes to standard output … otherwise, the merged file is written to the object store and the object ID of its blob is written to standard output"; exit status is negative on error and otherwise the conflict count — git-scm.com `git-merge-file` documentation; 2.43.0 release notes: "learns a mode to read three variants of the contents to be merged from blob objects"). The base exists only as a blob, so the portable form is `--object-id`, with the worktree file and main's file entered via `git hash-object -w --path=<target_path> -- <file>`. Process substitution (`<(git show …)`) as a file argument is not portable: native `git.exe` under Git Bash cannot open MSYS `/dev/fd` pipes.
- Limitations: a default merge reports a conflict when both sides insert at the same position. Appending at end of file on both sides — the typical shape of the reported defect (an old snapshot with a new note at the end, `main` with newer notes at the end) — therefore always refuses. A clean merge also applies the worktree's deletions and rewrites of base lines, which removes lines that `main` still has and violates the issue's third expected-behavior bullet.

### (b) Added-lines-only guard: refuse unless main's version is a line-subsequence of the source

- Simple, pure bash, no git dependency, no base needed. It guarantees the third bullet.
- Limitation: whenever `main` has advanced past the worktree's snapshot, main's newer lines are absent from the source, so the record is always refused. That is the motivating case, so (b) alone never stages the worktree's added lines, and the issue's first bullet goes unmet.

### (c) Combination (recommended)

Three-way merge with `--union` for placement, bounded by guards that make the result "main plus only the worktree's added lines", with (b) as the fallback when no base is available:

1. G1, worktree change is insertion-only: the base is a line-subsequence of the worktree file. Otherwise the worktree deleted or rewrote lines and cannot be expressed as additions → refuse.
2. Merge: `git -C <cwt> merge-file --union --object-id <main-oid> <base-oid> <wt-oid>` (no `-p`), which writes the merged blob and prints its id. `--union` resolves same-position insertions by keeping both sides. A non-zero exit, including the usage error from a Git older than 2.43, → refuse.
3. G2, no main line lost: main's version is a line-subsequence of the merged content.
4. G3, no resurrection or foreign lines: multiset(merged) − multiset(main) ⊆ multiset(worktree) − multiset(base). Given G2, the left side is exactly the lines the merge added to `main`; the right side is exactly the worktree's added lines. This rejects the `--union` case where `main` deleted a base line next to a worktree insertion (the conflict hunk would re-emit the deleted line). It also accepts the case where the worktree's addition already landed on `main` (nothing extra, merged equals main). A plain count-equality test would wrongly refuse that case.

Rejected alternatives: (a) alone refuses the motivating end-of-file case and can drop main's lines on a clean merge. (b) alone never stages additions once `main` has advanced. A pure-bash LCS merge duplicates `git merge-file` with more code and more risk.

### Recommended verdict behavior per case

Comparisons strip one trailing carriage return per line (consumer checkouts may be CRLF; blobs hashed with `--path` are normalized by the attribute filter).

| Case | Behavior | Result record |
|---|---|---|
| `untracked`, target not a regular file | Unchanged: verbatim copy, stage | `ACTION|preserve-stage|<tgt>|OK` |
| `untracked`, target exists | Recommended: apply guard (b); copy only if main ⊆ source, else refuse (issue bullet 3 is unconditional). Requires planner confirmation, because the delegation brief said "untracked records unchanged"; no existing test is affected either way. If kept unchanged, SKILL.md must record the residual. | `OK` or `REFUSED-WOULD-REGRESS` |
| `modified`, target not a regular file | Verbatim copy (nothing on `main` can regress); no git call | `OK` |
| `modified`, base available, G1 fails | Refuse | `REFUSED-WOULD-REGRESS` |
| `modified`, base available, merge non-zero/error | Refuse; stderr names the git exit code | `REFUSED-WOULD-REGRESS` |
| `modified`, base available, clean or union merge, G2 and G3 pass | Stage the merged blob (main plus worktree additions) | `OK` |
| `modified`, base available, G2 or G3 fails | Refuse | `REFUSED-WOULD-REGRESS` |
| `modified`, base unavailable (no worktree HEAD, no merge-base, file absent at base, or `source_path != target_path`), main ⊆ source | Verbatim copy (source already holds every main line) | `OK` |
| `modified`, base unavailable, main has lines absent from source | Refuse | `REFUSED-WOULD-REGRESS` |

A refused record: `PRESERVE|` is still emitted (it precedes the decision), a `cleanup-worktrees: …` diagnostic naming the failed guard goes to stderr, `PRESERVE_EXIT=1`, no plan-stream entry, no index append, exit 1 for the pass. It is not a hard stop (unlike exit 3). The decision runs after `IGNORED-TARGET` and before `preserve_plan_index`, so a refused record emits no misleading `ACTION|preserve-index|…|OK`.

Phase-1 write exception: `hash-object -w` and `merge-file --object-id` write unreferenced blob objects during the planning phase. They touch no index, ref, or working-tree file. The `preserve_plan` header ("performs NO writes") and the library header must state this exception explicitly. The commit phase writes the merged blob with `git -C <cwt> cat-file blob <oid> >"$dstfile"`, which keeps phase 2 policy-free.

Known residuals to document: a resurrected line textually identical to a worktree-added line cannot be distinguished. Two records with the same `target_path` in one pass are each planned against the pre-pass content, so the later write wins. Recommendation: refuse a duplicate `target_path` in one pass with `REFUSED-WOULD-REGRESS`, or record the residual. Planner decision.

## 5. Mirror and Packaging Obligations

- Byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/` exist for `SKILL.md`, `scripts/cleanup-worktrees.sh`, `scripts/cleanup_worktrees_preserve_lib.sh`, and `scripts/cleanup_worktrees_preserve_eol_lib.sh` (glob-verified). No `.agents/`, `.github/`, or `.codex/` copy of this skill exists (glob over `**/cleanup-merged-worktrees/SKILL.md` and `**/cleanup_worktrees_preserve*_lib.sh` returned only the source and the bundle copy).
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists every script of the skill individually. A new `cleanup_worktrees_preserve_merge_lib.sh` must be added there, in sorted position after `cleanup_worktrees_preserve_lib.sh`, and copied into the bundle.
- Contract tests (execution-environment brief, `## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_resource_contracts.py` (bundle text equality, including the new library) and `test_push_down_claude_pack_manifest_completeness.py` (the new bundled file is listed). `test_push_down_pack_manifest_dependency_closure.py` covers PowerShell `$PSScriptRoot` and hook dependencies only, not bash `source`, so it imposes no extra entry. The Codex generator check is not affected (Claude-only skill).
- `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` pins three fragments of SKILL.md `## End-to-End Workflow` (merge-queue wording) and the SKILL/bundle pair. Edits must stay outside those fragments; documentation for this fix belongs in the manifest section.
- The fix alters no fact stated in the execution-environment brief, so no brief update is required.

## 6. File-Size Posture (logical lines, read with the Read tool)

| File | Lines | Posture |
|---|---|---|
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh` | 492 | At the 500 guidance tier; new logic goes into a new library. The expected growth of about 15 lines (call site, two plan-stream columns, commit-phase branch, comment rewrites) crosses 500 but stays far below 700. Offsetting by tightening the rewritten comments is preferred. |
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh` | 212 | Unchanged. |
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` | 243 | About +6 (source line, usage text). |
| New `cleanup_worktrees_preserve_merge_lib.sh` | 0 | Estimated 150–220. |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 416 | About +30 for the `merge-base` pair, `cat-file`, and `merge-file` arms; stays below 500. |
| `tests/shell/test_cleanup_worktrees_preserve.bats` | 471 | Comment and source-guard edits only; new tests go to a new suite. |
| `tests/shell/test_cleanup_worktrees_preserve_eol.bats` | 175 | Setup sourcing only, if any. |
| `tests/shell/test_cleanup_worktrees_preserve_failures.bats` | 264 | Setup sourcing plus at most two commit-phase merge-mode tests. |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 583 | Markdown, exempt. |

None of these files is listed in `config/file-size-baseline.json` (searched for `cleanup`).

## 7. Language and Portability

- Bash only, matching the existing libraries; no Python (repository direction) and no PowerShell needed.
- `git merge-file --object-id` requires Git 2.43 or later. An older Git fails with a usage error, which the design maps to `REFUSED-WOULD-REGRESS`, so it fails closed. The bats suites use the stub, so the CI runner's Git version does not affect the gate. The actual Git version on `ubuntu-latest` and on the operator host is unverified by this research; the orchestrator can confirm with `git --version`.
- `--union` behavior on same-position insertions (both sides kept, ours first) is documented only as "favouring … both"; the ordering is not stated in the manual page. The executor should confirm it with a probe under `SCRATCH` (three small blobs in a throwaway repository outside the worktree, outside any test) and record the result under `evidence/other/`.
- Windows Git Bash: `git -C <drive-letter path>` and `hash-object -- <drive-letter path>` work with Git for Windows; process substitution must not be used as a git file argument (see option (a)). Line splitting uses the existing `while IFS= read -r line || [[ -n $line ]]` idiom (handles an unterminated final line); G3 needs per-line counts, which `declare -A` (bash 4+) or `sort | uniq -c` provides. Git Bash ships bash 5 and CI uses Ubuntu bash.
- CI: the `shell-coverage / Shell Coverage (Bats + kcov)` job (`.github/workflows/_shell-coverage.yml`) runs `bash scripts/bash/shell-qc.sh check` (shfmt 3.8.0 diff + shellcheck) and `bash scripts/bash/shell-qc.sh test --coverage` (bats over `tests/shell` recursively, kcov over `.claude/skills/` among other roots, aggregate line threshold 85 via `check_coverage_threshold` in `scripts/bash/shell_qc_lib.sh`). The checkout is depth one, so no test may use `origin/main` or real history (brief, `## CI-Only Failure Classes`). Locally, shell QC runs under WSL (`.claude/rules/shell.md`); the isolation guard text restrictions in the brief apply.

## 8. Testing Strategy (no test code)

- New suite `tests/shell/test_cleanup_worktrees_preserve_merge.bats` (same setup idiom, sourcing the new library) with fixtures under `tests/fixtures/cleanup_worktrees/preserve/merge-*/`. Each merge scenario holds `wt/<src>`, `consolidation/<tgt>` (main's version), and stub responses: `rev-parse.verify.HEAD.out`, the new merge-base pair key, `rev-parse.verify.<mb>_<src>.out` (base oid), `cat-file.<oid>.out` (base and merged content), `hash-object.<path>.out`, `merge-file.<…>.out|.rc`, and `check-ignore.<tgt>.rc` = `1`.
- Because merge scenarios need a real target file, they drive `preserve_plan` only (read-only). The commit-phase merge branch is driven through the `preserve_commit_one` pattern with destination `/dev/null` and a stubbed `cat-file`. No checked-in fixture is ever written.
- Cases: clean merge OK; both-sides end-of-file append OK; G1 refusal; merge error refusal; G2 refusal; G3 resurrection refusal; addition-already-on-main OK; each base-unavailable cause with main ⊆ source (OK) and without (refusal); `source_path != target_path`; refused record leaves no plan entry and no index record with `PRESERVE_EXIT=1`; CRLF-stripped comparison; unterminated final line; pure helper tests for the subsequence and multiset functions (positive, negative, empty inputs); untracked-with-existing-target per the planner's decision; source-guard case for the new library; negative-control assertions that `merge-file` is not invoked when the target is absent.
- Fail-before: the issue's repro (main has lines absent from an older snapshot) asserted as `REFUSED-WOULD-REGRESS` or as a merged `OK`, run against the unchanged library, recorded under `evidence/regression-testing/`.
- Isolation: seeded shuffled order of the touched bats files is not a brief requirement (the brief lists Jest, Python, and Pester isolation checks); each bats test exports its own seams, and `run` subshells isolate globals.

## Numeric Derivation Evidence

### Claim N1: existing preserve scenarios carrying a `modified` record = 3

- Complete Family: every preserve fixture scenario under `tests/fixtures/cleanup_worktrees/` whose record set contains `change_class` `modified`.
- Exhaustive Search Scope: all files under `tests/fixtures/cleanup_worktrees/` (both the `jq.out` TSV replays the code consumes and the `manifest.json` documents).
- Inclusion Rules: a scenario directory counts once if any of its records has `modified` in the change_class position.
- Exclusion Rules: `field-matrix/change-class-out-of-vocabulary` (invalid value, not `modified`).
- Primary Search Strategy or Query Expression: content grep of `\tmodified\t` over `**/jq.out` under `tests/fixtures/cleanup_worktrees`.
- Primary Member Set: `preserve/eol-stale`, `preserve/modified`, `preserve/order`.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: files-with-matches grep of `"change_class": "modified"` over all files under `tests/fixtures/cleanup_worktrees`.
- Cross-check Member Set: `preserve/order/manifest.json`, `preserve/modified/manifest.json`, `preserve/eol-stale/manifest.json`.
- Cross-check Count: 3.
- Member-set Comparison: normalized to scenario directory names, both sets are {eol-stale, modified, order}; identical.

### Claim N2: bats tests that drive a `modified`-class scenario = 5

- Complete Family: `@test` blocks in `tests/shell/*.bats` that set the stub scenario or manifest to `eol-stale`, `modified`, or `order`.
- Exhaustive Search Scope: every file under `tests/shell/`.
- Inclusion Rules: a test counts once if any line in its body references `${PRES}/eol-stale`, `${PRES}/modified`, or `${PRES}/order`.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: content grep of `\$\{PRES\}/(modified|order|eol-stale)` over `tests/shell`, then mapping each hit to its enclosing `@test` by reading the files.
- Primary Member Set: `preserve subcommand dispatches to the preserve driver`; `the manifest path is taken from CLEANUP_WT_MANIFEST_PATH`; `a modified preserve record is staged and reported`; `records are emitted in LC_ALL=C order regardless of manifest order` (all in `test_cleanup_worktrees_preserve.bats`); `a stale advisory crlf value does not override an LF target` (`test_cleanup_worktrees_preserve_eol.bats`).
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: full read of the three preserve suites (`test_cleanup_worktrees_preserve.bats`, `test_cleanup_worktrees_preserve_eol.bats`, `test_cleanup_worktrees_preserve_failures.bats`), enumerating every `@test` and its `CLEANUP_WT_STUB_SCENARIO` value; `preserve_failures` builds records inline with `untracked` only.
- Cross-check Member Set: same five test names.
- Cross-check Count: 5.
- Member-set Comparison: identical sets of five test names.

## Pre-Mortem

- Review checklists: a reviewer could flag the planning phase as no longer write-free, or the SKILL.md and `usage` text as still saying "verbatim". Mitigation: the plan states the unreferenced-blob exception in the `preserve_plan` and library headers, rewrites the `preserve_validate_record` change_class comment, updates the `usage` text, and adds a SKILL.md subsection listing the full `ACTION|preserve-stage` vocabulary including `REFUSED-WOULD-REGRESS`.
- Coverage: kcov's aggregate line threshold could drop if the new library's fallback and error branches are not driven. Mitigation: one stubbed scenario per verdict row in the table and per base-unavailable cause, and pure helper tests; record per-file kcov figures from `cov.xml`.
- Mirror parity: the bundle copies of four edited files plus the new library, and the new `core.json` entry, could be missed, failing `test_push_down_claude_resource_contracts.py` and `test_push_down_claude_pack_manifest_completeness.py`. Mitigation: a dedicated mirror task copies all five files and adds the manifest entry, then runs both tests. SKILL.md edits stay outside the `## End-to-End Workflow` fragments pinned by `merge_queue_documentation_expectations.py`. No execution-environment brief update is needed.
- File size: `cleanup_worktrees_preserve_lib.sh` (492) crosses the 500 guidance tier if logic is added inline. Mitigation: all merge and guard logic goes in `cleanup_worktrees_preserve_merge_lib.sh`, new tests go in a new bats file, and the git stub stays below 500.
- Test isolation: merge scenarios need a real target file, and running the commit phase against it would overwrite a checked-in fixture and violate the no-temporary-files rule. Mitigation: drive merge scenarios through `preserve_plan` only, and the commit-phase merge branch through `preserve_commit_one` with `/dev/null`. Use `-f`, not `-e`, for the target-present test so `/dev/null` targets keep the copy path. Append plan-stream columns after column 8 with empty meaning copy.
- CI-only behavior: the shell-coverage job is a depth-one checkout on Linux, and a test that invoked real `git merge-base`/`merge-file` against history would fail or depend on the runner's Git version. Mitigation: all git calls in tests go through the stub. The real-Git `--union` ordering probe runs only under `SCRATCH` as recorded evidence and is never part of the suite. Fixtures are LF, because `eol=lf` normalizes CRLF fixtures in CI; the CRLF comparison test passes CR content to the helpers as inline strings in the test body.
- Evidence: the issue's failure is silent, so a missing fail-before artifact would leave the fix unproven. Mitigation: run the repro test against the unchanged library and record it under `evidence/regression-testing/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Record the `--union` probe under `evidence/other/` with no absolute paths (`SCRATCH` token).

## Automation Feasibility

Fully automatable; no human interaction is required. Every change is a file edit (bash libraries, bats suites, stub, fixtures, SKILL.md, bundle copies, `core.json`). Verification runs through `bash scripts/bash/shell-qc.sh check` / `test --coverage` (under WSL locally per `.claude/rules/shell.md`, or the `shell-coverage` CI job) and the two Python contract tests through Poetry. The optional real-Git `--union` probe is a scripted `sh` run under `SCRATCH`. The only judgment items are planner decisions recorded below, not runtime interaction.

## Open Decisions for the Planner

1. Untracked records whose target already exists: apply guard (b) (recommended, issue bullet 3 is unconditional) or keep unchanged and document the residual.
2. Duplicate `target_path` within one pass: refuse with `REFUSED-WOULD-REGRESS` (recommended) or document.
3. Whether to add an informational `ACTION|preserve-merge|<tgt>|MERGED` record. Recommendation: do not; keep `OK` plus a stderr note, so the only new token is `REFUSED-WOULD-REGRESS`.

## Recommended Fix Design (summary)

Add `cleanup_worktrees_preserve_merge_lib.sh`, sourced immediately before `cleanup_worktrees_preserve_lib.sh`. It defines a line-subsequence helper (trailing-CR tolerant), a multiset-difference containment helper, a base resolver (`rev-parse --verify --quiet HEAD` in the worktree, `merge-base <wt-head> HEAD` in the consolidation worktree, `rev-parse --verify --quiet <mb>:<source_path>`, gated on `source_path == target_path`), and a decision function. The decision function sets `PRESERVE_STAGE_MODE` (`copy` | `merge`) and `PRESERVE_STAGE_OID`, or emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS`, sets `PRESERVE_EXIT=1`, and returns 1. `preserve_plan_one` calls it after the `IGNORED-TARGET` check and before `preserve_plan_index`. It short-circuits to `copy` without any git call when `<cwt>/<target_path>` is not a regular file. For an existing target it runs G1 → `merge-file --union --object-id` → G2 → G3 when a base exists, and guard (b) otherwise. The plan entry gains columns 9 (mode) and 10 (merged oid). `preserve_commit_plan` writes `git -C <cwt> cat-file blob <oid> >"$dstfile"` for `merge` and keeps `cat` for `copy` or empty.

## Complete List of Paths a Fix Would Write

Production:
- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` (new)
- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
- `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`
- `.claude/skills/cleanup-merged-worktrees/SKILL.md`

Mirrors and manifests:
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` (new)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

Tests and fixtures:
- `tests/shell/test_cleanup_worktrees_preserve_merge.bats` (new)
- `tests/shell/test_cleanup_worktrees_preserve.bats` (source-guard case, setup sourcing, rewritten `modified` comment)
- `tests/shell/test_cleanup_worktrees_preserve_eol.bats` (setup sourcing, for chain consistency)
- `tests/shell/test_cleanup_worktrees_preserve_failures.bats` (setup sourcing; commit-phase merge-mode tests)
- `tests/fixtures/cleanup_worktrees/stub-bin/git` (new `merge-base` pair, `cat-file`, `merge-file` arms; corrected header comments)
- `tests/fixtures/cleanup_worktrees/preserve/merge-*/**` (new scenario directories: `jq.out`, `manifest.json`, `wt/…`, `consolidation/…`, stub `.out`/`.rc` files)
- `tests/fixtures/cleanup_worktrees/preserve/modified/jq.out` and `manifest.json` (optional: evidence text "staged by the same path as an untracked one" becomes inaccurate)

Feature documentation and evidence:
- `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/spec.md`, `plan.*.md`
- `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/evidence/{baseline,regression-testing,qa-gates,other}/…`
