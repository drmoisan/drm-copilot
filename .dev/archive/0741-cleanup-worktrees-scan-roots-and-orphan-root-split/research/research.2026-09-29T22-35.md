# Research: cleanup-worktrees scan roots and orphan-root split (Issue #741)

- Issue: #741 (bug, work mode `minor-audit`)
- Branch: `bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741`
- Requirements source: `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md`
- Researched: 2026-09-29
- Scope boundary: issue #756 is excluded (see Section 9).

All line numbers below were read from the worktree at research time. Findings are marked as verified (read or searched with tools in this session), recorded (taken from a prior repository artifact), or proposed.

## 1. Canonical Script Location and Mirror Parity

### 1.1 Location (verified)

The issue text still cites `scripts/bash/cleanup-worktrees.sh`. That path is stale:

- A glob for `scripts/bash/*cleanup*` returns no file. No `scripts/bash/` copy of any cleanup-worktrees script exists.
- The canonical scripts are under `.claude/skills/cleanup-merged-worktrees/scripts/` (11 files: the wrapper `cleanup-worktrees.sh`, eight `*_lib.sh` libraries, and `cleanup_worktrees_scan_helper.sh`).
- A byte-identical bundled mirror exists at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/`. A glob for `**/cleanup_worktrees_report_records_lib.sh` returns exactly these two copies. The per-file line counts of the two trees currently agree for every file.
- The issue's own citation `cleanup_worktrees_report_records_lib.sh:129-136` is still accurate against the canonical file.

### 1.2 Parity enforcement (verified)

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 118-143) enumerates every non-memory file under the repository `.claude/` and asserts that it exists in the bundle with identical text.
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` requires every bundled `.claude` file to be listed in a `pack-manifests/*.json` `paths` array. The eleven scripts and `SKILL.md` are listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lines 77-87. This test is relevant only if a new file is added; the recommended design adds none.
- No sync script exists. A search of `package.json` scripts and `.claude/` finds no mirror command, and the #396 remediation plan (`docs/features/completed/2026-07-22-cleanup-merged-worktrees-396/remediation-plan.2026-07-22T13-42.md` line 7) records that the push-down tool publishes outward and is not the repo-to-bundle mechanism. The established procedure is a direct byte-identical copy of each changed file.

Verification commands:

```text
git diff --no-index --exit-code <canonical-path> <bundle-path>
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k all_repo_runtime_contracts
```

## 2. Current State of the Affected Code

### 2.1 Report-mode scan roots (verified)

`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`:

| Lines | Function | Behavior |
|---|---|---|
| 114-150 | `cleanup_wt_scan_roots` | When `CLEANUP_WT_ORPHAN_ROOTS` is non-empty (129-137), it sets `IFS=:` and word-splits the unquoted value. Otherwise it calls `parse_worktree_list` (139), takes the first record's path as the main worktree (143-144), and prints `<main>/.claude/worktrees` then `<main>-wt` (146-147). A `parse_worktree_list` failure returns 0 with no output (140-142). |
| 152-190 | `cleanup_wt_scan_records` | Reads the roots (163-166), returns 0 when none, and runs the scan binary once with all roots as arguments (177-181). |
| 192-252 | `scan_orphan_dirs` | Emits `ORPHAN_DIR` for every record with `has_gitfile == 0` whose normalized path is not a registered worktree (238-247). |
| 254-304 | `scan_registration_loss` | Emits `WARN|registration-lost` for `has_gitfile == 1` and `gitdir_target_exists == 0`. |
| 306-344 | `run_report_scans` | One scan per report, shared by both record functions. |

The only caller of `cleanup_wt_scan_roots` is `cleanup_wt_scan_records` (line 166). `run_report_scans` is called from `cleanup_worktrees_lib.sh:477` (`run_report`).

Latent defect in the same block: `for part in $override` (line 133) is an unquoted expansion, so a root containing `*`, `?`, or `[` is subject to pathname expansion as well as splitting.

### 2.2 Existing `git worktree list` parsing (verified)

`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`:

- `parse_worktree_list` (85-148) emits `path|head|branch-or-DETACHED|flags`. The first stanza always carries the `main` flag (107). Other flags are `detached`, `bare`, `locked`, and `prunable`. On a git failure it prints a diagnostic to stderr and returns git's exit code with no records (124-128).
- `normalize_wt_path` (150-164) converts backslashes to `/`, lowercases, and strips one trailing slash.
- Every bats suite and the wrapper source this library before the report library (`cleanup-worktrees.sh:18`, `test_cleanup_worktrees_report_records.bats:30,41`).

### 2.3 Scan helper semantics relevant to root choice (verified)

`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`:

- `scan_helper_scan_dirs` (126-148) emits one record for every immediate subdirectory of each root. `has_gitfile` is `1` only when `<path>/.git` is a regular file (140). A normal repository's `.git` is a directory, so it yields `has_gitfile == 0`.
- `scan_helper_dir_size` (44-58) runs `du -sh` on every emitted subdirectory.

Consequence, derived from the code above: any root whose immediate children include ordinary repositories or ordinary folders produces an `ORPHAN_DIR` record for each child that is not a registered worktree, and a full `du` walk of each child.

### 2.4 Where registered worktrees actually live (recorded)

The #706 research (`docs/features/completed/cleanup-report-registration-lost-false-positive-706/research/2026-09-26-registration-lost-false-positive-research.md` lines 61-68) lists registrations outside the two fixed roots on the reporting host:

- three `planhome*` worktrees under a session scratchpad `.../scratchpad/planhome/`;
- `<repos>/drm-copilot-parallel-epic-655-followups-plan`, a direct sibling of the main checkout;
- two nested worktrees at depth 2 (`drm-copilot-wt/2026-08-29T15-07-wt/2026-08-30T07-18`, `drm-copilot-wt/2026-08-29T11-55-wt/2026-08-29T15-06`).

### 2.5 Clarification of what the scan contributes

`WORKTREE|` records come from `git worktree list` and already cover every registered worktree regardless of location. The filesystem scan contributes only `ORPHAN_DIR` and `WARN|registration-lost`, and a currently registered worktree yields neither (it is registered, and its pointer resolves to the existing `.git/worktrees/<name>` entry). The value of deriving roots from registrations is therefore the detection of unregistered residue that sits next to registered worktrees outside the fixed pair, for example a pruned plan home beside live ones in `planhome/`, or a failed removal inside a nested `*-wt/` folder.

## 3. Scan-Root Derivation: Design

### 3.1 Risk assessment for the naive rule (derived from Section 2.3)

"Parent of every registered worktree" is unsafe as stated:

| Derived parent | Example | Effect if scanned |
|---|---|---|
| Parent of the main worktree | `<repos>/`, reached through the main stanza or through `<repos>/drm-copilot-parallel-*-plan` | Every sibling repository (its `.git` is a directory) and the `<main>-wt` folder itself are reported as `ORPHAN_DIR`, and `du -sh` walks each sibling repository. This is a real risk, not a hypothetical one: the recorded `drm-copilot-parallel-epic-655-followups-plan` registration produces exactly this parent. |
| Any ancestor of the main worktree | a worktree at `C:/Users/<user>/x` gives `C:/Users/<user>` | Every home-directory folder is reported. |
| The main worktree or a directory inside it | a worktree at `<main>/sub` gives `<main>`; at `<main>/.claude/foo` gives `<main>/.claude` | Every top-level repository folder (`docs`, `scripts`, `.claude/skills`, ...) is reported. |
| A directory inside another registered worktree | worktree B at `<A>/sub/b` gives `<A>/sub` | Folders of worktree A are reported. |

Excluding only the main stanza is insufficient, because non-main worktrees can reproduce the main's parent (row 1).

### 3.2 Recommended rule

Roots are the configured roots followed by the registration-derived roots, deduplicated.

1. Configured roots: the `CLEANUP_WT_ORPHAN_ROOTS` entries when the variable is non-empty (Section 4), otherwise the existing fixed pair `<main>/.claude/worktrees` and `<main>-wt`.
2. Candidate derived roots: the parent directory of every `parse_worktree_list` record that does not carry the `main` flag. The parent is computed in pure bash after converting `\` to `/` (`p=${path//\\//}; parent=${p%/*}`). An empty parent is dropped.
3. A candidate R is kept only when both conditions hold, using `normalize_wt_path` values:
   - R is not the main worktree and is not an ancestor of it. An ancestor test is a prefix test: the normalized main path begins with `R/`. This excludes the repositories directory, and it also excludes a bare drive such as `C:` because `c:/...` begins with `c:/`.
   - R is not equal to, and is not inside, any registered worktree (main included). An inside test is a prefix test: R begins with `<W>/`.
4. Deduplication is by normalized value. The first spelling seen is emitted. Configured roots come first in their given order, and derived roots follow in `LC_ALL=C` order of their normalized value so that the output is deterministic.
5. Failure behavior:
   - No override, and `parse_worktree_list` fails: no root is emitted. This is the existing contract (test `test_cleanup_worktrees_report_records.bats:112-118`).
   - Override set, and `parse_worktree_list` fails: the override roots only. They do not depend on git, and the diagnostic has already been written to stderr by `parse_worktree_list`.

Applied to Section 2.4:

- `planhome/` is kept.
- Both nested `*-wt` folders are kept.
- `<main>-wt` and `<main>/.claude/worktrees` are merged with the configured pair by deduplication.
- `<repos>/` is excluded.

Residual gap (accepted): unregistered residue directly in `<repos>/`, for example a leftover `drm-copilot-parallel-*-plan` whose registration was pruned, is still not detected. Detecting it would require name-pattern filtering in the main's parent directory, which the evidence does not justify for a Low-severity advisory record.

Residual risk (accepted and to be documented): if a user registers a worktree directly inside a general-purpose directory such as `%TEMP%`, that directory is scanned and its unrelated subdirectories are reported as `ORPHAN_DIR`. Every such record is advisory, and SKILL.md lines 536-537 require per-item confirmation before any filesystem removal. Suppressing `ORPHAN_DIR` for derived roots only was considered and rejected: `scan_orphan_dirs` receives records without root provenance, and adding provenance would need a second scan or a changed record shape, which conflicts with the one-scan invariant pinned by `test_cleanup_worktrees_report_records.bats:120-132`.

### 3.3 Where the code goes (file-size driven)

`cleanup_worktrees_report_records_lib.sh` is 476 lines. The derivation adds roughly 40-60 net lines, which would exceed the 500-line cap if it stayed in that file. Recommendation:

- Move `cleanup_wt_scan_roots` wholesale (lines 114-150) into `cleanup_worktrees_enumerate_lib.sh` (252 lines), together with the new pure helpers `cleanup_wt_is_absolute_path` (Section 5), `cleanup_wt_split_roots` (Section 4), and a derived-roots filter. The estimated result is about 380-400 lines. The report library shrinks by about 37 lines.
- This library already hosts `parse_worktree_list` and `normalize_wt_path`, which the derivation consumes. Every consumer, including the wrapper and every bats harness that calls `run_report` or `rr`, already sources it before the report library, so no harness or wrapper `source` line changes.
- Update the report library header comment (lines 8-10) and the `cleanup_wt_scan_records` docstring to name the new home of `cleanup_wt_scan_roots`.

Rejected alternatives:

- A new `cleanup_worktrees_scan_roots_lib.sh`. It would require a `core.json` entry, a new wrapper `source` line, and a new `source` in every bats harness that reaches `run_report`, including `rr`/`report_raw` in `test_cleanup_worktrees_report_records.bats`, which #756 is also expected to edit.
- Keeping the derivation in the report library. It breaches the 500-line cap.

## 4. `CLEANUP_WT_ORPHAN_ROOTS` Separator Contract

### 4.1 Current parsing, default, consumers, documentation (verified)

- Parsing: `cleanup_worktrees_report_records_lib.sh:129-137` (`local IFS=:` and an unquoted `for part in $override`). Docstring: line 117.
- Default: none. When unset or empty, the fixed pair is derived (138-148).
- Code consumers: only `cleanup_wt_scan_roots`. A repository-wide search for `CLEANUP_WT_ORPHAN_ROOTS|cleanup_wt_scan_roots`, excluding feature docs, finds no other reader.
- Documentation sites:
  - `cleanup-worktrees.sh:142-143`, usage text "Colon-separated override for the worktree-tracking roots";
  - the report library docstring at line 117;
  - the bundle mirrors of both.
  - `SKILL.md` does not mention the variable or the root set; it says only "a worktree-tracking root" (line 129) and "worktree-tracking folder" (line 319).
- Tests: `tests/shell/test_cleanup_worktrees_report_records.bats:102-110` (`/a/one:/b/two` yields two lines). No test uses a drive-letter root.

### 4.2 Recommended contract

Apply one rule to every value:

1. Split on `;` and on newline.
2. Split each resulting piece on `:`, except that a `:` is not a separator when the text before it in the current segment is exactly one ASCII letter and the text after it begins with `/` or `\`. That text is a drive-letter prefix.
3. Drop empty segments.
4. Drop a segment that is not absolute according to `cleanup_wt_is_absolute_path`, and write a one-line stderr diagnostic that names it. This extends the function's existing intent (docstring lines 124-127) of never resolving a root against the current working directory.
5. Perform no pathname expansion. The splitter walks the string with parameter expansion, in the same way `preserve_split_tsv` does (`cleanup_worktrees_preserve_lib.sh:64-83`), rather than by unquoted word splitting.

| Input | Output |
|---|---|
| `/a/one:/b/two` | `/a/one`, `/b/two` (unchanged POSIX behavior; existing test still passes) |
| `C:/a/one` | `C:/a/one` (currently split into `C` and `/a/one`) |
| `C:/a/one:D:\b\two` | `C:/a/one`, `D:\b\two` |
| `C:/a/one;D:/b/two` | `C:/a/one`, `D:/b/two` |
| `C:/a` newline `/b` | `C:/a`, `/b` |
| `/a/*` | `/a/*` literally |
| `rel:C:rel` | all dropped with diagnostics (`rel`, `C`, `rel` are not absolute) |

Rationale:

- It is backward compatible with every existing POSIX `:` value.
- `;` is the Windows `PATH` convention and is accepted with no ambiguity.
- A single-letter relative root is the only POSIX value whose meaning changes, and it was already unsafe because it resolved against the current working directory.

Rejected alternatives:

- `;` only: breaks the existing `:` contract and test.
- Newline only: awkward to set from a shell or a PowerShell prompt.
- Drive-aware `:` only, without `;`: workable, but it gives Windows users no conventional separator.

### 4.3 Override versus derived roots

The issue's expected behavior ("registered worktree's parent ... plus the configured roots") is implemented as follows: the override replaces only the fixed pair, and derived roots are always appended. The existing override test (lines 102-110) is unaffected, because its scenario `orphan_dir_present/worktree-list.out` has only the main stanza and therefore contributes no derived root. Trade-off: the override can no longer narrow the scan to fewer roots than the registrations imply. This is acceptable because the records are advisory. The usage text must state the behavior.

## 5. Duplicated Drive-Letter Check and `load_helper`

### 5.1 Drive-letter predicate (verified)

- `cleanup_worktrees_scan_helper.sh:73-85`, `scan_helper_is_absolute_path`: `[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]` (line 84).
- `cleanup_worktrees_preserve_lib.sh:151-166`, `preserve_relative_path_reason`: `[[ $val == /* || $val == [A-Za-z]:[\\/]* ]]` (line 161). The semantics are identical; only the bracket order differs.
- Bundle mirrors of both.
- Not duplicates:
  - `cleanup_worktrees_preserve_lib.sh:471` is host-token regex HT1, a content scan rather than a path predicate;
  - `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:57` is PowerShell.

Deduplication target: define `cleanup_wt_is_absolute_path` once in `cleanup_worktrees_enumerate_lib.sh`, carrying over the #706 docstring (`/`, `C:/`, `c:/`, and `C:\` are absolute; `C:rel` and the empty string are not). Then:

- `preserve_relative_path_reason` line 161 calls it. The preserve library already requires the enumeration library (header lines 11-13).
- `scan_helper_gitdir_target_exists` line 116 calls it. The scan helper runs as a separate process, invoked as `bash "$bin"` from `cleanup_worktrees_report_records_lib.sh:180`, so it must source the sibling `cleanup_worktrees_enumerate_lib.sh` itself: `source "$(dirname -- "${BASH_SOURCE[0]}")/cleanup_worktrees_enumerate_lib.sh"`, with the same `# shellcheck source=` and `# shellcheck disable=SC1091` pair that the wrapper uses at lines 16-18. The enumeration library defines functions and one constant only, so sourcing it has no side effect under the helper's `set -euo pipefail`.
- Delete `scan_helper_is_absolute_path`. Its only callers are line 116 and the two bats tests at `test_cleanup_worktrees_scan_helper.bats:69-101`.
- `cleanup_wt_split_roots` (Section 4) is the third consumer, which is what justifies a shared home.

Rejected: having the preserve library source the scan helper. The helper sets `set -euo pipefail` at top level (line 42), which would leak into every sourcing shell and trigger the kcov trap described in Section 6.3.

Coverage note (verified): the preserve field-matrix fixture `tests/fixtures/cleanup_worktrees/preserve/field-matrix/source-path-absolute/jq.out` exercises only the `/absolute/...` form, and no preserve test uses a drive-letter `source_path` or `target_path`. After deduplication, the shared predicate's table tests cover the drive-letter forms.

### 5.2 `load_helper` (verified)

`load_helper() { source "$1"; set +u; }` is defined inline in three `bash -c` bodies, all in `tests/shell/test_cleanup_worktrees_scan_helper.bats`: lines 48, 74, and 90. A search for `load_helper` across the repository, excluding `docs/`, finds no other file. A search for `^\s*load ` or `bats_load_library` under `tests/` finds nothing, so no shared bats helper-file pattern exists in the repository. The in-repo pattern for shared test plumbing is a file-local helper function defined at the top of a `.bats` file: `rr()` and `report_raw()` in `test_cleanup_worktrees_report_records.bats:25-42`, and `preserve_drive_plan()` in `test_cleanup_worktrees_preserve.bats:409`.

Deduplication target:

- Move the two predicate table tests (lines 69-101) to target `cleanup_wt_is_absolute_path`. They then source only the enumeration library, which never enables nounset, so they need no `set +u`.
- For the one remaining test that must source the helper (lines 36-55, the `scan_helper_target_present` override), add one file-local function at the top of `test_cleanup_worktrees_scan_helper.bats`, for example `run_helper_sourced <bash-body> [args...]`. It wraps `run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit bash -c 'source "$1"; set +u; shift; <body>' _ "$HELPER" "$@"`, and the kcov rationale is stated once in its comment.
- The inline `load_helper` then occurs zero times.

A separate `tests/shell/*.bash` loaded with `load` was rejected. A bats `load` defines functions in the bats process, not inside the `bash -c` child in which the nounset clearing must happen, so it would not remove the duplication.

## 6. Tests, Local Execution, and Coverage

### 6.1 Existing bats coverage (verified)

| File | Lines | Covers |
|---|---|---|
| `tests/shell/test_cleanup_worktrees_report_records.bats` | 132 | `scan_stale_refs`, `scan_orphan_dirs`, `scan_registration_loss`, `cleanup_wt_scan_roots` (91-118), one-scan gate (120-132) |
| `tests/shell/test_cleanup_worktrees_scan_helper.bats` | 101 | scan helper records, #706 drive-letter cases, predicate tables |
| `tests/shell/test_cleanup_worktrees_scan_seam.bats` | 28 | `cleanup_wt_scan_bin` |
| `tests/shell/test_cleanup_worktrees_enumeration.bats` | 142 | `parse_worktree_list`, `normalize_wt_path`, `compute_protected` |
| `tests/shell/test_cleanup_worktrees_preserve*.bats` | - | `preserve_relative_path_reason` via the field matrix |

Stubs:

- `tests/fixtures/cleanup_worktrees/stub-bin/git` replays `<scenario>/worktree-list.out`.
- `tests/fixtures/cleanup_worktrees/stub-bin/scan` replays `<scenario>/scan-dirs.out` and logs `stub-scan: <argv>` to stderr (line 29), so the roots passed to the scan are assertable end to end.

### 6.2 Local execution on Windows (recorded)

Source: memory note `native-shell-toolchain-verification`, and the #706 policy audit line 72. These were not re-executed in this research session; this agent has no shell tool.

- In an agent worktree (`.claude/worktrees/agent-*`), the isolation guard text-denies commands whose text contains `bash`, `pwsh`, or `wsl`. That includes the path `scripts/bash/shell-qc.sh`.
- `npx --yes bats tests/shell/<file>.bats` runs a single suite locally in seconds. The recursive form takes about 35 minutes.
- `shfmt` (v3.12.0) and `shellcheck` (0.11.0) are on the Windows PATH, so `shfmt -d <files>` and `shellcheck <file>` run directly on `.claude/skills/...` and `tests/shell/...` paths.
- `shell-qc.sh check|format` can be run by writing the command into a scratchpad `.sh` file and running `sh <file>.sh`.
- kcov has no local route. Coverage requires `gh workflow run .github/workflows/_shell-coverage.yml --ref <branch>`.

### 6.3 kcov coverage and the `set -u` trap (verified plus recorded)

- `scripts/bash/shell_qc_lib.sh:335-336` sets the kcov include pattern to `tools`, `scripts`, `.claude/lib/bash`, and `.claude/skills`, and excludes `tests`. So the skill scripts and their mirror path pattern are measured.
- The merged report is `artifacts/pester/kcov/cov.xml`. The run prints `Bash coverage (lines): NN.N%`. The gate is line coverage only, at 85% or above (`.claude/rules/shell.md` lines 61-71).
- The trap (`test_cleanup_worktrees_scan_helper.bats:42-44`, #706 policy audit line 191): a file that runs `set -u` at top level, when sourced at the top level of `bash -c`, leaves nounset on. kcov's PS4 trace then expands `${BASH_SOURCE}`, which is unset at `bash -c` top level, and the test aborts. This happens only under kcov, so only in CI. The files that set `-u` at top level are `cleanup_worktrees_scan_helper.sh:42` and `cleanup-worktrees.sh:7`.
- Guidance for the fix:
  - never source the scan helper or the wrapper in a `bash -c` body without clearing nounset through the single helper from Section 5.2;
  - do not add `set -u` to any `*_lib.sh`;
  - new tests of the enumeration library functions need no clearing.

### 6.4 Proposed test strategy (no test code)

- Pure unit tests of `cleanup_wt_split_roots` and `cleanup_wt_is_absolute_path`: source the enumeration library, cover every Section 4.2 table row, and include the relative-drop diagnostic on stderr.
- `cleanup_wt_scan_roots` derivation tests use a new scenario `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out`. It holds a main stanza `/repo/main` plus worktrees at:
  - `/repo/main-wt/a` (duplicate of a configured root);
  - `/repo/main-wt/a-wt/b` (nested, kept);
  - `/scratch/planhome/ph1` (kept);
  - `/repo/sibling-plan` (parent `/repo` is an ancestor of main, excluded);
  - `/repo/main/sub` (parent is main, excluded);
  - `/repo/main/.claude/x` (parent inside main, excluded);
  - `/scratch/planhome/ph1/inner/c` (parent inside a registered worktree, excluded);
  - one mixed-case or backslash spelling that deduplicates.
- Assert exact ordered output.
- Add an override-plus-derived test and an override-with-parse-failure test (a new scenario carrying `worktree-list.rc`).
- End-to-end: drive `run_report` with the scan stub and assert that the single `stub-scan: scan-dirs` argv line contains a derived root.
- Preserve: add one field-matrix case with a drive-letter `source_path` (`C:/x/lesson.md`) that is rejected as absolute. This proves the shared predicate is wired into the preserve library.
- Place the new tests in a new file `tests/shell/test_cleanup_worktrees_scan_roots.bats` with its own two-line `rr`-style helper. Leave `test_cleanup_worktrees_report_records.bats` unmodified to avoid textual overlap with #756 (Section 9).
- Tier: developer tooling (T4 per `.claude/rules/quality-tiers.md`). No property-test or mutation obligation applies. `quality-tiers.yml` does not exist at the repository root (verified by glob), as #706 also recorded.

## 7. File Sizes (500-line limit)

| File | Current lines | Expected change |
|---|---|---|
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` | 252 | + about 130-150, to about 380-400 |
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh` | 476 | - about 35, to about 440 |
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` | 182 | net about -5 (predicate removed, source line added) |
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh` | 492 | net 0 to -1 (one condition replaced); must stay at 500 or below |
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` | 234 | + about 4 (usage text) |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 571 | Markdown, exempt |
| `tests/shell/test_cleanup_worktrees_scan_helper.bats` | 101 | about -20 |
| `tests/shell/test_cleanup_worktrees_scan_roots.bats` | new | about 150-200 |
| `cleanup_worktrees_lib.sh` (496), `cleanup_worktrees_dirt_lib.sh` (495) | - | Not to be touched; both are at the cap |

`cleanup_worktrees_preserve_lib.sh` at 492 lines leaves 8 lines of headroom. Any docstring growth there must be offset.

## 8. Complete Write List (repository-relative)

Production (canonical):

1. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`
2. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`
3. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`
4. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
5. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` (usage text lines 142-143)
6. `.claude/skills/cleanup-merged-worktrees/SKILL.md` (ORPHAN_DIR bullet lines 129-133: name the root set and the override contract)

Bundle mirror (byte-identical copies of 1-6):

7. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`
8. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`
9. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`
10. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`
12. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`

Tests and fixtures:

13. `tests/shell/test_cleanup_worktrees_scan_roots.bats` (new)
14. `tests/shell/test_cleanup_worktrees_scan_helper.bats`
15. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out` (new)
16. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/scan-dirs.out` (new, for the end-to-end argv test; may be empty)
17. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_list_error/worktree-list.rc` (new; override-with-parse-failure case). Reusing the existing `worktree_list_error` scenario is an acceptable alternative.
18. `tests/fixtures/cleanup_worktrees/preserve/field-matrix/source-path-drive-letter/jq.out` (new). If added, the field-matrix count assertion in `tests/shell/test_cleanup_worktrees_preserve.bats` (the `count` check near lines 174-190) must be incremented, which adds `tests/shell/test_cleanup_worktrees_preserve.bats` to this list. An alternative that avoids touching the counted matrix is a direct `preserve_relative_path_reason source_path 'C:/x'` assertion in the new bats file.

Feature documentation and evidence (under the feature folder): the plan, evidence under `evidence/<kind>/`, and review artifacts, as produced by later phases.

Not written:

- `core.json`, because no new production file is added;
- `cleanup_worktrees_lib.sh` and `cleanup_worktrees_dirt_lib.sh`, which are at the cap;
- `tests/shell/test_cleanup_worktrees_report_records.bats`, to keep the #756 boundary.

Observation outside scope: `cleanup_worktrees_report_records_lib.sh:172` still says "Every script under scripts/bash/", which is stale since the move to the skill folder. Correct it only if that comment block is already being edited.

## 9. Overlap with Issue #756 (explicit)

Source: `docs/features/potential/promoted/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths.md`. No active #756 folder exists yet (glob `docs/features/active/*756*` is empty).

#756 is likely to touch:

- `cleanup_worktrees_report_records_lib.sh` `classify_all_branches` (346-476), specifically the pairwise-probe hard-failure path at lines 461-463 (`rc=2` at 462);
- `run_report_scans` (306-344), specifically the scan-failure and rc-maximization block at 322-343. #756 proposes tests only for these paths, not production edits;
- new scenarios under `tests/fixtures/cleanup_worktrees/scenarios/`;
- most likely new tests in `tests/shell/test_cleanup_worktrees_report_records.bats`;
- `docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md` lines 280 and 411.

#741's recommended edits in the same library are confined to removing lines 114-150 (`cleanup_wt_scan_roots`) and adjusting the header (8-10) and the `cleanup_wt_scan_records` docstring. None of #756's functions is edited. The only interaction is that #756's cited line numbers shift upward by about 37 once #741 merges; #756's issue already notes that its line numbers may shift. Keeping #741's tests in a new bats file and new scenario directories avoids a textual conflict in `test_cleanup_worktrees_report_records.bats`.

## 10. Toolchain Commands for Bash

Defined in `.claude/rules/shell.md` and `.github/workflows/_shell-coverage.yml` (verified):

| Stage | Canonical command | CI | Runnable in this Windows agent worktree |
|---|---|---|---|
| Format | `bash scripts/bash/shell-qc.sh format` (`shfmt -w`) | shfmt 3.8.0 | Yes: `shfmt -w <files>` directly, or `sh <scratch>.sh` wrapping the canonical command |
| Format check and lint | `bash scripts/bash/shell-qc.sh check` (`shfmt -d` then `shellcheck` per file) | `_shell-coverage.yml:51-52` | Yes: `shfmt -d <files>` and `shellcheck <file>` directly |
| Type check | not applicable (optional `bash -n`) | - | Not required |
| Unit tests | `bash scripts/bash/shell-qc.sh test` | apt bats | Yes, per file: `npx --yes bats tests/shell/<file>.bats` |
| Coverage | `bash scripts/bash/shell-qc.sh test --coverage` | kcov v43, `_shell-coverage.yml:54-55` | No local route; dispatch `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741` and read `Bash coverage (lines)` and `cov.xml` |
| Mirror parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Python quality job | Yes |

Local availability in the third column is recorded (Section 6.2), not re-verified in this session. CI versions are canonical when local and CI results differ (`.claude/rules/shell.md` lines 73-78).

## 11. Numeric Derivation Evidence

### N1: inline `load_helper` definitions to remove

- Complete Family: every definition of the source-then-clear-nounset test wrapper in the repository's test tree.
- Exhaustive Search Scope: the whole repository excluding `docs/`.
- Inclusion Rules: a definition or invocation line of `load_helper`, or a `set +u` that follows a `source` in a test body.
- Exclusion Rules: prose in `docs/`.
- Primary Search Strategy or Query Expression: content search `load_helper`, glob `!docs/**`.
- Primary Member Set: definitions at `tests/shell/test_cleanup_worktrees_scan_helper.bats` lines 48, 74, and 90. Lines 49, 75, and 91 are the paired invocations, and line 42 is a comment.
- Primary Count: 3 definitions.
- Cross-check Search Strategy or Query Expression: content search `set \+u` under `tests/`.
- Cross-check Member Set: `tests/shell/test_cleanup_worktrees_scan_helper.bats` lines 48, 74, and 90.
- Cross-check Count: 3.
- Member-set Comparison: identical sets {48, 74, 90} in the same file. The count of 3 is confirmed.

### N2: bash drive-letter absolute-path predicate copies

- Complete Family: bash path predicates that classify `/…` and `<letter>:[/\]…` as absolute, in the canonical `.claude/` tree.
- Exhaustive Search Scope: `*.sh`, `*.bats`, and `*.bash` repository-wide, plus all of `.claude/`.
- Inclusion Rules: a bash `[[ ... == [A-Za-z]:[...]* ]]` path test.
- Exclusion Rules: the bundle mirror, counted separately as byte copies; regex content scans (HT1 at `cleanup_worktrees_preserve_lib.sh:471`); PowerShell files.
- Primary Search Strategy or Query Expression: content search `\[A-Za-z\]:|\[a-zA-Z\]:`, glob `*.{sh,bats,bash}`.
- Primary Member Set: `cleanup_worktrees_scan_helper.sh:84` and `cleanup_worktrees_preserve_lib.sh:161` (canonical). Mirrors at the same lines. HT1 line 471 is excluded.
- Primary Count: 2 canonical.
- Cross-check Search Strategy or Query Expression: content search `:\[/\\\\\]|:\[\\\\/\]` over `.claude/`, which targets the separator bracket rather than the letter class.
- Cross-check Member Set: `cleanup_worktrees_preserve_lib.sh:161` and `cleanup_worktrees_scan_helper.sh:84`. `WorktreeTargetResolution.psm1:57` is excluded as PowerShell.
- Cross-check Count: 2.
- Member-set Comparison: identical sets. The count of 2 is confirmed. After the fix, the expected count is 1 (the shared `cleanup_wt_is_absolute_path` in the enumeration library).

### N3: `CLEANUP_WT_ORPHAN_ROOTS` reference sites (canonical, non-feature-doc)

- Complete Family: every code, usage-text, and test reference to the variable or to its sole reader.
- Exhaustive Search Scope: the repository excluding `docs/features/**`.
- Inclusion Rules: a line naming `CLEANUP_WT_ORPHAN_ROOTS` or `cleanup_wt_scan_roots`.
- Exclusion Rules: bundle mirror lines, which are byte copies.
- Primary Search Strategy or Query Expression: content search `CLEANUP_WT_ORPHAN_ROOTS|cleanup_wt_scan_roots`.
- Primary Member Set:
  - report library lines 114, 117, 129, and 166;
  - wrapper line 142;
  - `test_cleanup_worktrees_report_records.bats` lines 91, 95, 102, 105, 112, and 116.
- Primary Count: 11 lines in 3 files.
- Cross-check Search Strategy or Query Expression: case-insensitive content search `Colon|colon-separated|ORPHAN_ROOTS`, reviewed for the cleanup-worktrees family.
- Cross-check Member Set: the cleanup-worktrees files among the results are the report library, the wrapper, `test_cleanup_worktrees_report_records.bats`, and their two bundle mirrors. The other results are unrelated families (mermaid, parallel lane assertion, and similar).
- Cross-check Count: 3 canonical files.
- Member-set Comparison: the file sets agree (3 canonical files). `SKILL.md` has no reference in either search.

## 12. Automation Feasibility

No step requires human interaction.

- Code edits, the mirror copy, and fixture creation use file tools.
- Format, lint, per-file bats, and the mirror-parity pytest run locally.
- Coverage uses a `gh workflow run` dispatch plus a `gh run view --log` read. Both are non-interactive.

Two environmental constraints must be planned for, not escalated:

1. The agent-worktree command-text denylist for `bash`, `pwsh`, and `wsl`. Invoke tools directly or through `sh <scratch>.sh`.
2. CI runtime variability for `_shell-coverage.yml`, which is recorded as ranging from 6 to more than 30 minutes. Poll the run and do not treat slowness as failure.

## 13. Proposed Acceptance Criteria

- [ ] AC-1: With `CLEANUP_WT_ORPHAN_ROOTS` unset, `cleanup_wt_scan_roots` emits `<main>/.claude/worktrees`, `<main>-wt`, and then the parent directory of every non-main registered worktree. Output is deduplicated by `normalize_wt_path` and ordered as in Section 3.2. This is verified by a bats test against the `scan_roots_derived` scenario asserting exact ordered lines.
- [ ] AC-2: A candidate derived root that equals the main worktree, is an ancestor of it (including the main worktree's parent directory), or is equal to or inside any registered worktree is not emitted. Each exclusion class has a scenario entry and is asserted absent.
- [ ] AC-3: When `parse_worktree_list` hard-fails and no override is set, no root is emitted. The existing test `test_cleanup_worktrees_report_records.bats:112-118` passes unchanged.
- [ ] AC-4: When the override is set and `parse_worktree_list` hard-fails, exactly the override roots are emitted.
- [ ] AC-5: `CLEANUP_WT_ORPHAN_ROOTS` is parsed per Section 4.2. Bats cases cover `/a/one:/b/two`, `C:/a/one`, `C:/a/one:D:\b\two`, `C:/a/one;D:/b/two`, newline separation, empty segments, a glob character kept literally, and a relative segment dropped with a stderr diagnostic. The existing test at lines 102-110 passes unchanged.
- [ ] AC-6: A full `run_report` under the scan stub performs exactly one `scan-dirs` invocation, and its argv includes a registration-derived root.
- [ ] AC-7: Exactly one bash definition of the drive-letter absolute-path predicate exists under `.claude/skills/cleanup-merged-worktrees/scripts/` (`cleanup_wt_is_absolute_path`). `preserve_relative_path_reason` and `scan_helper_gitdir_target_exists` call it. `scan_helper_is_absolute_path` no longer exists. The #706 predicate table cases pass against the shared function, and a drive-letter `source_path` is rejected as absolute by the preserve validator.
- [ ] AC-8: The inline `load_helper` definition occurs zero times under `tests/`. The source-then-`set +u` idiom appears in exactly one file-local helper in `tests/shell/test_cleanup_worktrees_scan_helper.bats`, and its kcov rationale is stated once.
- [ ] AC-9: Each changed canonical file is byte-identical to its bundle mirror (`git diff --no-index --exit-code` exits 0 for each pair), and `test_push_down_claude_resource_contracts.py` passes.
- [ ] AC-10: The wrapper usage text (`CLEANUP_WT_ORPHAN_ROOTS` entry) and the `SKILL.md` `ORPHAN_DIR` bullet state the separator contract, the override-replaces-fixed-pair rule, and the always-added derived roots with their exclusions.
- [ ] AC-11: Every changed shell or bats file is at or below 500 lines. `shfmt -d` and `shellcheck` report no finding on changed files. The full bats suite passes in the `_shell-coverage.yml` CI run on the branch head. kcov line coverage for each changed production file is at or above 85%, and every new or changed executable line has at least one hit in that run's `cov.xml`.
- [ ] AC-12: `classify_all_branches` and `run_report_scans` are byte-unchanged, and `tests/shell/test_cleanup_worktrees_report_records.bats` is unmodified, which preserves the #756 boundary.
