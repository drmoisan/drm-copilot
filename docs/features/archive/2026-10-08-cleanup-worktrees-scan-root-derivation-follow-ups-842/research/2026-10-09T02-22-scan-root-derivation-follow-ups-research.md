# Research: cleanup-worktrees scan-root derivation follow-ups (Issue #842)

- Timestamp: 2026-10-09T02:22
- Branch: bug/cleanup-worktrees-scan-root-derivation-follow-ups-842
- Scope: M-3, N-1, M-2, M-1 from the #741 review. All line numbers below were re-derived from this checkout by reading the files; none were taken from the issue.
- Not executed: shfmt, shellcheck, bats, kcov, pytest, Pester (this research session had no shell tool). Baseline results are therefore unknown, not "passing".

## 1. M-3: `cleanup_wt_derive_scan_roots`

### Current text

File: `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` (416 lines). The function spans lines 319-372. Executable body:

```
333  local records=${1:-}
334  local -a paths=() norms=()
335  local record path
336  while IFS= read -r record; do
337      [[ -z $record ]] && continue
338      path=${record%%|*}
339      paths+=("$path")
340      norms+=("$(normalize_wt_path "$path")")
341  done <<<"$records"
342  ((${#paths[@]} < 2)) && return 0
343  local main_norm=${norms[0]}
344  local -A seen=()
345  local -a kept=()
346  local i p parent n w inside
347  for ((i = 1; i < ${#paths[@]}; i++)); do
348      p=${paths[i]//\\//}
349      parent=${p%/*}
350      [[ -z $parent || $parent == "$p" ]] && continue
351      n=$(normalize_wt_path "$parent")
352      [[ -z $n || -n ${seen[$n]:-} ]] && continue
353      [[ $n == "$main_norm" || $main_norm == "$n"/* ]] && continue
354      inside=0
355      for w in "${norms[@]}"; do ... inside-a-worktree check ... done   (355-361)
362      ((inside == 1)) && continue
363      seen[$n]=1
364      kept+=("$n|$parent")
365  done
366  ((${#kept[@]} == 0)) && return 0
367-371  sort by normalized key, print `${line#*|}` (the original-spelling parent)
372  }
```
(Leading tabs omitted. The header comment is lines 320-332.)

`cleanup_wt_is_absolute_path` is lines 257-271; its predicate (line 270) is `[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]`. It is pure, accepts `/x`, `//server`, `C:/x`, `c:/x`, `C:\x`, and rejects `C:rel`, `rel`, `../rel`, and the empty string. It is already called at line 310 (override splitter), `cleanup_worktrees_preserve_lib.sh:161`, and `cleanup_worktrees_scan_helper.sh:105`. The enumeration library is a hard dependency of the scan helper, so no sourcing change is needed.

### Defect trace (reasoned, not executed)

For a registration `D:/wt`: line 348 gives `p=D:/wt`; line 349 gives `parent=D:`; line 350 passes (non-empty, differs from `p`); `n=d:`. Line 353: `main_norm` is `c:/repo/main`, which does not match `d:/*`, so the main-ancestor filter does not drop it. Line 355-361: `d:` is not equal to or a prefix of any registered worktree. So `D:` is kept and emitted. The same-drive case is already filtered: for a registration `C:/x` with main `C:/repo/main`, `n=c:` and `c:/repo/main` matches `c:/*`, so it is dropped as a main ancestor. The leak is therefore specific to a different drive than the main worktree.

### Insertion point

Insert one line between current line 350 and line 351:

```
cleanup_wt_is_absolute_path "$parent" || continue
```

Ordering relative to backslash normalization: the check must run after it. `parent` is derived from `p`, which is the output of the `${paths[i]//\\//}` conversion on line 348, so by line 350 every separator is already `/`. The predicate also accepts `X:\`, so the check would work on a raw value, but the derived `$parent` is always the post-conversion form, so no ordering choice remains beyond "after line 350". It must run before line 351 so that `normalize_wt_path` is never called on a drive-relative value and `D:` never reaches `seen`/`kept`. The existing `[[ -z $parent ... ]]` guard on line 350 can stay unchanged (the empty-parent case is a subset of "not absolute", but keeping it preserves current readability and the `parent == "$p"` no-slash guard).

### Drop vs emit `D:/`: recommendation is to drop

- Dropping matches the issue's proposed fix and the "no relative root" invariant already enforced for overrides (line 310 drops non-absolute entries).
- Emitting `D:/` would make the scan helper list every immediate subdirectory of the drive root (`D:/Users`, `D:/Windows`, ...) as orphan/registration-loss candidates. That adds noise to an advisory report and is a different behavior from the POSIX analogue below.
- The POSIX analogue is already dropped: a registration `/wt` gives `p=/wt`, `parent=${p%/*}` is the empty string, and line 350 (`-z $parent`) skips it. So a registration directly under a root is already not scanned on POSIX; dropping `D:` makes the Windows drive-root case consistent. No new handling is needed for `/wt` (existing check suffices). A test for `/wt` is optional but cheap and would document that equivalence.
- A drive-root registration directly under a *same* drive as main is already dropped by the main-ancestor filter, as traced above.

### Other edge cases for the new check

- UNC `//server/share/wt` gives parent `//server/share`, which starts with `/` and is kept (unchanged behavior).
- Relative registration `foo` gives `parent == p` and is dropped by the existing guard; `a/b` gives `parent=a`, which the new check now also drops (previously emitted as a relative root). This is within the invariant's intent.
- Mixed-case drive letters are accepted by `[A-Za-z]`.

## 2. Existing tests and fixtures; new test recommendations (N-1 and M-3)

### Existing coverage

Only two bats files exercise scan roots:

- `tests/shell/test_cleanup_worktrees_scan_roots.bats` (242 lines; the only direct consumer of derivation). `setup()` defines `ELIB`, `LIB`, `RLIB`, `DLIB`, `DIRTLIB`, `PLIB`, `STUB` (`tests/fixtures/cleanup_worktrees/stub-bin/git`), `SCAN` (`.../stub-bin/scan`), `SCEN` (`tests/fixtures/cleanup_worktrees/scenarios`). Helpers: `roots_run <scenario> <override>` (runs `cleanup_wt_scan_roots` under `env CLEANUP_WT_GIT_BIN CLEANUP_WT_SCAN_BIN CLEANUP_WT_STUB_SCENARIO CLEANUP_WT_ORPHAN_ROOTS` with `bash -c "source ELIB && source RLIB && ..."`, stderr discarded), `roots_run_raw` (stderr retained), `report_run <scenario>` (sources all libs and runs `run_report`, so `stub-scan: scan-dirs ...` is countable). Derivation tests at lines 58, 71, 88, 101, 177. The only backslash cases are the override splitter (line 122, `'C:/a/one:D:\b\two'`) and the predicate (line 198, `'C:\x'`); no test passes a backslash registration through derivation.
- `tests/shell/test_cleanup_worktrees_report_records.bats`: tests at lines 91-130 call `cleanup_wt_scan_roots` and `run_report` on other scenarios. No fixture in `tests/fixtures/cleanup_worktrees/` contains a `worktree ` line with a drive letter or a backslash (searched with `^worktree [A-Za-z]:|^worktree .*\\`, no match), so the M-3 change cannot alter any existing scenario's output.
- Other bats files that call `run_report` (hard_failures, dirt_*, detached, deletion, classification) do not use drive-letter scenarios; they are unaffected.

Feeding mechanism: the git stub (`stub-bin/git`) replays `<scenario>/worktree-list.out` for `git worktree list --porcelain` via `cat` (backslashes preserved). `parse_worktree_list` reads with `IFS= read -r` (no backslash interpretation) and emits `path|head|branch|flags`. `cleanup_wt_scan_roots` calls `parse_worktree_list` and passes the output to `cleanup_wt_derive_scan_roots`.

Existing fixture `scenarios/scan_roots_derived/worktree-list.out` (40 lines) holds 10 stanzas, all `/`-separated (main `/repo/main`).

### Recommended new fixtures (checked-in; no temp files)

1. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`
   - Stanzas: main `C:/repo/main`; `D:/wt` (the defect case, parent `D:`); `D:/other/x` (parent `D:/other`, must still be kept); `/wt` is not mixed in here because a drive main plus a POSIX path is not a realistic single listing.
   - Expected `roots_run scan_roots_drive_relative ""` output (3 lines): `C:/repo/main/.claude/worktrees`, `C:/repo/main-wt`, `D:/other`. The line `D:` must be absent.
2. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`
   - Stanzas: main `C:/repo/main` (forward slash, so the default pair keeps a forward-slash spelling); `C:\repo\main-wt\a` (the issue's example); `C:\scratch\plan\p1`.
   - Expected `roots_run scan_roots_backslash ""` output (3 lines): `C:/repo/main/.claude/worktrees`, `C:/repo/main-wt`, `C:/scratch/plan`. The `C:\repo\main-wt\a` parent converts to `C:/repo/main-wt`, which duplicates the default and is deduplicated by `cleanup_wt_scan_roots`; `C:\scratch\plan\p1` supplies the discriminating derived root `C:/scratch/plan` (forward-slash spelling, proving the conversion).
3. Optional isolation of derivation from default-pair dedupe: call `cleanup_wt_derive_scan_roots` directly with `parse_worktree_list` output, so the expected output is exactly the sorted derived roots: for fixture 2, `C:/repo/main-wt` then `C:/scratch/plan`; for fixture 1, `D:/other` only.

### Recommended new bats test names (add to `test_cleanup_worktrees_scan_roots.bats`, which stays well under 500 lines)

- `cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root` (fixture 1, direct call; asserts output is exactly `D:/other`).
- `cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration` (fixture 1 via `roots_run`; asserts 3 lines and that no line equals `D:`).
- `cleanup_wt_derive_scan_roots converts a backslash registration path before taking its parent` (fixture 2, direct call; asserts `C:/repo/main-wt` and `C:/scratch/plan`, in that order).
- `cleanup_wt_scan_roots emits forward-slash roots for backslash registrations` (fixture 2 via `roots_run`; asserts the three lines above).
- `run_report passes no drive-relative root to its single filesystem scan` (fixture 1 via `report_run`; asserts exactly one `stub-scan: scan-dirs` line and the exact argv `stub-scan: scan-dirs C:/repo/main/.claude/worktrees C:/repo/main-wt D:/other`, following the pattern of the test at line 177).
- Optional: `cleanup_wt_derive_scan_roots emits nothing for a registration directly under /` (one stanza `/wt`; existing guard on line 350).

The direct-call form needs the env vars and sourcing used by `roots_run`; the shortest route is a new helper `derive_run <scenario>` running `bash -c "source '${ELIB}' && cleanup_wt_derive_scan_roots \"\$(parse_worktree_list)\""` under the same `env` prefix (the enumeration library does not enable nounset, per the comment at lines 10-14 of the test file).

### `.gitattributes` and `git grep`

- `.gitattributes` line 1 is `* text=auto eol=lf`; only `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/**` (line 14), and a few orchestration/csproj fixtures, are exempted with `-text`. Backslashes are ordinary bytes and no CR is needed for N-1, so no `.gitattributes` change is required for either new fixture. A CRLF variant is not part of #842 and would need a `-text` entry.
- `git grep` does not search untracked files. Any verification step that locates the new fixture directories or new test names before `git add` must use the Grep tool, `grep -r`, `git grep --untracked`, or a `test -f` check. The issue's reproduction command for N-1 (`git grep -n -F 'C:\' -- 'tests/fixtures/cleanup_worktrees/**/worktree-list.out'`) only works after the new files are staged or committed; and `git grep -F 'C:\'` as a shell-quoted token needs care with the backslash.

## 3. M-2: SC1091 suppression in the scan helper

Current text, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`:

```
42  set -euo pipefail
43  # shellcheck source=.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh
44  # shellcheck disable=SC1091
45  source "$(dirname -- "${BASH_SOURCE[0]}")/cleanup_worktrees_enumerate_lib.sh"
```

Reference pattern, `cleanup-worktrees.sh` lines 11-18:

```
11  # The library paths are resolved at runtime from SCRIPT_DIR, so shellcheck cannot load
12  # them as static inputs without -x; SC1091 is the expected, benign result. The
13  # enumeration/protection library is sourced first because ...
...
16  # shellcheck source=.../cleanup_worktrees_enumerate_lib.sh
17  # shellcheck disable=SC1091
18  source "$SCRIPT_DIR/cleanup_worktrees_enumerate_lib.sh"
```

Rule, `.claude/rules/shell.md` lines 85-86: "Keep scripts shellcheck-clean. Suppressions are permitted only when justified inline with a `# shellcheck disable=SCxxxx` comment stating the reason." The repository's convention is prose comment lines immediately above the directive pair, not a trailing comment on the directive line. Recommended edit: insert two or three prose lines before line 43, for example "The library path is computed at runtime from BASH_SOURCE, so shellcheck (run without -x by scripts/bash/shell_qc_lib.sh) cannot follow it; SC1091 is the expected, benign result." Keep lines 43-45 otherwise unchanged. The recommended placement avoids relying on a shellcheck version's support for trailing explanatory text on a directive line (not verified here).

Related observation (outside the issue's stated scope, record only): in `cleanup-worktrees.sh`, `disable=SC1091` appears on lines 17, 22, 25, 28, 31, 44, 49, 52; only the first is preceded by the reason text (lines 11-12); the others rely on it by proximity. `cleanup_worktrees_preserve_eol_lib.sh` also has one SC1091 directive (not inspected for a reason). A stricter reading of "every SC1091 suppression" would extend to those; the issue names only the scan helper, so the recommended scope is the scan helper only, with the other occurrences listed as an optional follow-up.

## 4. M-1: stale cross-file reference

File `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`, `is_detached_candidate`, lines 44-48:

```
44  # The predicate is the porcelain FLAG, not the branch field: emit_record writes the
45  # literal DETACHED into the branch field whenever the branch accumulator is empty
46  # (.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh:115-116), which is also true of a
47  # bare-repository stanza, and a local branch literally named DETACHED would produce
48  # the same branch field with no `detached` flag.
```
(The grep and read show the cited text on line 46; the sentence begins on line 44.)

Current location of the write: `emit_record` is a nested function inside `parse_worktree_list` in `cleanup_worktrees_enumerate_lib.sh`. `parse_worktree_list` spans lines 88-151, `emit_record` lines 106-122. The write is lines 118-119: `local branch_field="DETACHED"` and `[[ -n $branch ]] && branch_field=$branch`. Lines 115-116 are `local flags=""` and `local IFS=,`, confirming the reference is stale. Recommended fix: replace the `file:115-116` citation with a function-name reference, for example "(emit_record, nested in parse_worktree_list in cleanup_worktrees_enumerate_lib.sh)", so it cannot drift again. Do not introduce a new line range.

Verified not stale: line 23 of the same file cites `cleanup_worktrees_actions_lib.sh:19-35`; those lines are the "Guarded-read invariant" paragraph (actions lib lines 19-35), which matches. Leave it unchanged (a function- or section-name reference would be more drift-proof, but changing it is out of scope).

## 5. Bundle mirrors and parity checks

Mirrors of every script in the skill exist under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/` (same 10 `.sh` files plus `SKILL.md`). The relevant mirror files, with line anchors confirmed identical to the source by grep:

| Source (repo) | Mirror (bundle) | Change |
|---|---|---|
| `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` | M-3 (+1 line, optionally a header-comment sentence) |
| `.../scripts/cleanup_worktrees_scan_helper.sh` | same relative path under the bundle root | M-2 |
| `.../scripts/cleanup_worktrees_detached_lib.sh` | same relative path under the bundle root | M-1 |

Tests, fixtures, stubs, and `docs/` are not mirrored; the bundle holds only the `.claude/` tree.

Checks that fail if a mirror diverges:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every distributable file under the repo `.claude/` (excluding `agent-memory`, `state`, `worktrees`, `settings.local.json`) and asserts the file exists in the bundle and that `read_text(utf-8)` content is equal. This is the mirror-identity check for these three scripts. Run: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (the repo's Python rule routes pytest through Poetry; confirm exact flags against `.claude/rules/python.md` when planning).
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and its TypeScript twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` check that every `.claude` file is listed in `pack-manifests/*.json`. No new `.claude` file is added by #842, so no manifest membership change is needed.
- Manifest/hash: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the skill's paths (lines 79-89: SKILL.md and the 10 scripts) as a path list only. It stores no content hash or checksum; no manifest or hash file needs updating when file contents change, only when a path is added or removed. (Searched for hash/sha256 in the manifest completeness tests and `core.json` usage; found none tied to these files.)
- Related memory note (from the project memory index, not re-verified here): the bundle-parity test can fail locally on gitignored state while passing in CI (issue #510). A local failure must be read for which path it names before attributing it to the mirror edit.

Implementation rule: apply the identical edit to both copies in the same change; a byte-for-byte copy of the finished source file is the safest method, since the test compares full text.

## 6. Toolchain commands

From `.claude/rules/shell.md`:

1. Format: `bash scripts/bash/shell-qc.sh format` (shfmt write mode). Check form: shfmt diff mode (`shfmt -d`) over the discovered file list.
2. Lint: `bash scripts/bash/shell-qc.sh check` (`shfmt -d` once over all files, then `shellcheck "$file"` once per file; no `-x`, so SC1091 is expected for runtime-resolved `source` paths). Max exit code is returned.
3. Type check: not applicable (optional `bash -n`).
4. Test: `bash scripts/bash/shell-qc.sh test` (bats over `tests/shell`, then `tests/bash` if present). Coverage: `bash scripts/bash/shell-qc.sh test --coverage` (kcov v43, merged Cobertura at `artifacts/pester/kcov/cov.xml`, prints `Bash coverage (lines): NN.N%`).
5. Discovery roots (shell.md lines 48-52): `tools/`, `scripts/`, `.claude/lib/bash/`, `.claude/skills/`. The skill scripts are therefore in format, lint, test, and coverage scope. Excluded directories: `.venv`, `.git`, `node_modules`, `dist`, `build`. The bundle mirror under `extensions/` is not under a discovery root.

CI (`.github/workflows/_shell-coverage.yml`, ubuntu-latest): apt-installs `shellcheck bats`, installs shfmt `3.8.0` as a binary, builds kcov `v43` from source (cached), then runs `bash scripts/bash/shell-qc.sh check` and `bash scripts/bash/shell-qc.sh test --coverage`. CI versions are canonical when local WSL versions disagree.

Agent environment constraints (from the project memory index, not re-verified in this session): a worktree isolation guard text-denies commands containing `bash`, `pwsh`, `wsl`, and heredocs. The known local route is to write a small `.sh` file and run it with `sh file.sh`, or use `npx`; CI is the authority for bats. `scripts/bash/shell-qc.sh` has a `bash` shebang, so `sh` may not run it; treat local bats as best-effort and defer to CI. If a local run is feasible, run (1) format, (2) check, then (4) test, restarting from step 1 after any auto-fix.

Baseline results: not run in this research session (no shell tool available). Planner must record a baseline from CI or an operator-run command rather than infer one.

The generic seven-stage loop in `.claude/rules/general-code-change.md` additionally lists architecture-boundary, contract/schema, and integration stages; none has a bash-specific tool in this repo for these scripts. Python (the mirror-identity pytest) and, if touched, Pester/TypeScript are separate languages not modified by #842.

## 7. Tier and coverage

- `quality-tiers.yml` has no entry for `.claude/skills/` or `.claude/skills/cleanup-merged-worktrees`. Entries nearby: `"."` T4 (root scaffold), `.claude/lib/bash` T3, `scripts/bash` T4, `.claude/hooks` T3. The project-discovery logic is in `scripts/dev_tools/check_quality_tiers.py` and `tests/scripts/dev_tools/test_quality_tiers_contract.py` (a search of `check_quality_tiers.py` for `.sh` and `.claude` found no skill-script discovery rule; discovery was not read in full). The #741 work added no tier entry, and #842 adds no new project, so no `quality-tiers.yml` change is proposed. If the tier of these scripts is needed for the plan, the closest enclosing classification is the root `"."` T4 entry; this is an inference, not a verified discovery result.
- Coverage rule for bash (`.claude/rules/shell.md` lines 61-71 and `.claude/rules/general-unit-test.md`): line coverage >= 85% measured by kcov over `tools/`, `scripts/`, `.claude/lib/bash/`, `.claude/skills/`; no branch gate; no production file may be excluded from measurement; changed lines must not reduce coverage. The new `|| continue` line is covered by the drive-relative tests; M-1 and M-2 change comments only.
- File size: `cleanup_worktrees_enumerate_lib.sh` is 416 lines, so +1 line is within the 500-line cap; `test_cleanup_worktrees_scan_roots.bats` is 242 lines, so ~60-80 new lines stay within the cap.

## Candidate approaches (M-3)

- Recommended: drop non-absolute derived parents with `cleanup_wt_is_absolute_path "$parent" || continue` after line 350. One line, reuses the shared predicate, consistent with override handling and the existing `/wt` behavior.
- Rejected alternative: emit `D:/` for a drive-relative candidate. It broadens the scan to a drive root's entire contents, adds report noise, and diverges from the POSIX root-level behavior.
- Rejected alternative: inline `[[ $parent == [A-Za-z]: ]]` test. It duplicates predicate logic that issue #706 centralised in `cleanup_wt_is_absolute_path`.

## Automation Feasibility

No human interaction is required. All four changes are text edits to checked-in files plus checked-in fixtures and bats tests; verification is by shfmt, shellcheck, bats, kcov (CI is authoritative), and the mirror-identity pytest. The one environment limitation is that local bats may not be runnable under the worktree isolation guard; that is resolved by CI, not by a person.

## Recommended list of repository files the implementation will write

Edited (source and mirror, identical content):

1. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` (M-3)
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` (M-3 mirror)
3. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` (M-2)
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` (M-2 mirror)
5. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` (M-1)
6. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` (M-1 mirror)
7. `tests/shell/test_cleanup_worktrees_scan_roots.bats` (new tests, optional `derive_run` helper)

Created:

8. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out`
9. `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out`

Feature documentation (written by the workflow, not by the code change): the plan already present at `docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md`, and later evidence/review artifacts under the same folder.

Not written: `quality-tiers.yml`, `.gitattributes`, `pack-manifests/*.json`, any hash file, `SKILL.md`.
