# Research: `WARN|registration-lost` false positive for healthy worktrees (Issue #706)

- Issue: #706
- Branch: `bug/cleanup-report-registration-lost-false-positive-706`
- Date: 2026-09-26
- Mode: preparation (research only; no source changes)

## 1. Current State Analysis

### 1.1 Data flow of the record

1. `cleanup_wt_scan_roots` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:114-150`) derives two roots from the first `git worktree list --porcelain` stanza: `<main>/.claude/worktrees` and `<main>-wt`. Under Git for Windows the porcelain path is drive-letter form, so both roots are `C:/Users/.../drm-copilot/...`.
2. `cleanup_wt_scan_records` (same file, lines 152-190) runs the scan helper (`scripts/bash/cleanup_worktrees_scan_helper.sh`) with `scan-dirs <roots>`, through the `CLEANUP_WT_SCAN_BIN` seam (`cleanup_wt_scan_bin`, lines 46-63).
3. `scan_helper_scan_dirs` (`cleanup_worktrees_scan_helper.sh:101-123`) builds `path=${entry%/}` from `"$root"/*/`, so `path` is `C:/Users/.../drm-copilot-wt/<name>`. When `$path/.git` is a regular file it calls `scan_helper_gitdir_target_exists "$path" "$gitfile"` (line 117).
4. `scan_registration_loss` (`cleanup_worktrees_report_records_lib.sh:254-304`) emits `WARN|registration-lost|<path>` for every record with `has_gitfile == 1` and `target_exists == 0` (lines 296-298). `run_report_scans` (lines 306-344) is the sole report-mode caller.

The record lib contains no path logic of its own; the verdict is decided entirely by the helper's third field.

### 1.2 The defective function

`scripts/bash/cleanup_worktrees_scan_helper.sh:72-99`, `scan_helper_gitdir_target_exists`:

```bash
	if [[ $target != /* ]]; then
		target="$dir/$target"
	fi
	if [[ -e $target ]]; then
```

(lines 91-94). The only absolute form recognised is a leading `/`. The header comment at lines 20-23 documents the same rule ("resolved relative to <path> when the target is not absolute") without defining "absolute".

### 1.3 Existing tests and why they did not catch it

- `tests/shell/test_cleanup_worktrees_scan_helper.bats` (one test, lines 23-34) drives the helper against `tests/fixtures/cleanup_worktrees/scan_roots/basic/`. Both pointer fixtures use relative targets: `good_wt/dotgit` = `gitdir: ../good_wt_target`, `broken_wt/dotgit` = `gitdir: ../missing_target_does_not_exist`. No fixture exercises an absolute target of any form, so the `!= /*` branch's absolute leg is never taken with a drive-letter value.
- `tests/shell/test_cleanup_worktrees_report_records.bats:76-89` tests `scan_registration_loss` through the checked-in scan stub (`tests/fixtures/cleanup_worktrees/stub-bin/scan`) that replays canned records. It never runs the real helper, so it cannot observe the helper's path classification.
- `tests/shell/test_cleanup_worktrees_scan_seam.bats` tests only `cleanup_wt_scan_bin` resolution.

## 2. Root Cause (verified)

**Confirmed.** `scan_helper_gitdir_target_exists` treats a Windows drive-letter gitdir target (`C:/...`) as relative because it does not begin with `/` (`cleanup_worktrees_scan_helper.sh:91`). It then prefixes the worktree directory (line 92), producing `C:/Users/DanMoisan/repos/drm-copilot-wt/no-target-followup/C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/no-target-followup`. That path does not exist, `[[ -e ]]` fails (line 94), the helper emits `0`, and `scan_registration_loss` emits `WARN|registration-lost|<path>`.

Evidence, gathered by reading the live pointer files on the reporting host with read-only tools:

- `C:\Users\DanMoisan\repos\drm-copilot-wt\no-target-followup\.git` (the worktree named in the issue) contains `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/no-target-followup`.
- Every pointer file currently present directly under the two scan roots uses the same form. A search for `^gitdir: C:/` over `drm-copilot-wt/*/.git` matched 21 files; a search for `^gitdir:` over `drm-copilot/.claude/worktrees/*/.git` returned 64 lines, all `gitdir: C:/...`. A search for `^gitdir: [^C]` over both roots returned no match. No relative, backslash, lowercase-drive, UNC, or `/c/...` pointer exists in the current tree.

### 2.1 Other candidate conditions, each evaluated

| Candidate | Finding |
|---|---|
| Helper run under WSL bash, where `C:/` does not resolve | **Refuted as a contributor.** A `WARN|registration-lost` line requires `has_gitfile == 1`, which requires `[[ -d $root ]]` (line 109) and `[[ -f "$path/$gitfile" ]]` (line 115) to succeed on `C:/...` paths. The issue's WARN lines carry `C:/` paths, so the interpreter that produced them resolved drive-letter paths. That interpreter was Git Bash (MSYS), consistent with the issue's Environment section. Under WSL the roots would be skipped and no record would be emitted at all. |
| CRLF pointer file | **Refuted for this report.** The helper already strips a trailing CR (line 85), and the issue records `od -c` showing LF termination. |
| Backslash form `C:\...` | Not present on the host; Git for Windows writes forward slashes. It would fail the same way, so the fix should classify it as absolute at no extra cost. |
| Lowercase drive `c:/...` | Not present; would fail the same way. Covered by a `[A-Za-z]` class. |
| UNC `//server/share/...` | Already absolute under the current rule (leading `/`). `\\server\share` would be misclassified, but it is not a form git writes. |
| MSYS `/c/...` | Already absolute under the current rule and resolvable in Git Bash. Not affected. |
| Drive-relative `C:foo` (no separator) | Not a form git writes. Should remain relative, matching the PowerShell precedent below. |

### 2.2 Why 4 of 71 were not flagged

Not fully derivable; the 2026-09-25 worktree set is not preserved. The relative-pointer hypothesis (`git worktree add --relative-paths` / `worktree.useRelativePaths`) is **not supported by the current state**: zero relative pointers exist under either scan root. Under the defect, every pointer-bearing immediate subdirectory of the two roots is flagged, so the gap is most likely in the denominator rather than in pointer shape. The current `.git/worktrees/*/gitdir` registrations include worktrees the scan never visits, because the scan covers only immediate subdirectories of `<main>/.claude/worktrees` and `<main>-wt`:

- the main checkout itself (its `.git` is a directory, and it is not under either root);
- three `planhome*` worktrees under the session scratchpad (`C:/Users/DanMoisan/AppData/Local/Temp/claude/.../scratchpad/planhome/`);
- `C:/Users/DanMoisan/repos/drm-copilot-parallel-epic-655-followups-plan`;
- two nested worktrees at depth 2 (`drm-copilot-wt/2026-08-29T15-07-wt/2026-08-30T07-18`, `drm-copilot-wt/2026-08-29T11-55-wt/2026-08-29T15-06`).

A 71-registered / 67-flagged split is therefore consistent with four registrations outside the scanned set on that date. This is a likely explanation, not a verified one. It does not affect the fix.

## 3. Every Copy of the Affected Logic

Search strategy: file-name glob `**/cleanup_worktrees_scan_helper*` and `**/cleanup*worktrees*.sh` over the whole repository, plus a content search for `scan_helper|gitdir_target_exists|registration-lost` across `.claude/`, `extensions/`, `scripts/`, `.github/`.

| Location | Kind | Needs the fix? | Parity binding |
|---|---|---|---|
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | The only implementation | **Yes** | None; single copy |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | Consumer of the record; no path logic | No | n/a |
| `scripts/bash/cleanup_worktrees_lib.sh:53,455`, `scripts/bash/cleanup-worktrees.sh:116,143` | Contract prose only | No (contract unchanged) | n/a |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md:142-144` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md:142-144` | Contract prose ("names a gitdir target that no longer exists") | No (the documented contract already describes the intended behavior) | Byte-identical mirror enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (precedent: #631 evidence `skill-md-mirror-contract.2026-09-06T23-03.md`) |

No bundled or mirrored copy of the scan helper exists: the cleanup-worktrees bash scripts are not in `.claude/lib/bash/` nor in the extension's `resources/` payload. No shell parity test is required.

Related, not a copy: `.claude/lib/worktree-resolution/WorktreeResolution.psm1:155-161` (`Test-WorktreeResolutionAbsolutePath`) already classifies `^([A-Za-z]:(/|$)|/)` as absolute after backslash normalisation, and `Resolve-WorktreeResolutionPathAgainst` (lines 185-213) prefixes the base only for non-absolute targets. This is the in-repo precedent for the recommended rule.

## 4. Design Options

### Option A (recommended): pure-bash absolute-path predicate plus a one-line existence seam

- Add `scan_helper_is_absolute_path <path>`: returns 0 when the path matches `/*`, `[A-Za-z]:/*`, or `[A-Za-z]:\\*` (the `[[ $p == [A-Za-z]:[/\\]* ]]` glob), else 1. Pure, no I/O.
- Add `scan_helper_target_present <path>`: `[[ -e $1 ]]`. The single filesystem read, isolated so a test can redefine it after sourcing.
- In `scan_helper_gitdir_target_exists`, replace lines 91-94 with: prefix `$dir/` only when `scan_helper_is_absolute_path` fails, then call `scan_helper_target_present`.
- Update the header comment (lines 20-23) to state which forms are absolute.

Pros: pure bash, no new dependency, deterministic on ubuntu, mirrors the PowerShell precedent, separates classification (pure) from existence (I/O) per `.claude/rules/general-code-change.md`. Adds roughly 20 lines to a 157-line file. The `.git` pointer is still read locally and never executes git.
Cons: the existence seam is a bash function override rather than the repository's usual `*_BIN` environment-variable seam; no bats file in `tests/shell/` currently redefines a sourced function. This is a narrow, test-only use and is justified inline.

### Option B (rejected): normalise with `cygpath -u` when available

`cygpath` exists only under MSYS/Cygwin. The branch that calls it cannot execute on the ubuntu CI runner, which leaves unexecuted lines in a file already at 86.79% line coverage (46/53, per `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/dirt-lib-coverage.2026-09-08T07-00.md`), and it adds an environment-dependent branch. It also does not help, because MSYS bash already resolves `C:/...` natively.

### Option C (rejected): ask git with `git -C <dir> rev-parse --git-dir`

Spawns one git process per scanned directory (85 at present), requires routing git through `CLEANUP_WT_GIT_BIN` inside a helper whose documented contract is filesystem-only reads (`cleanup_worktrees_report_records_lib.sh:38-44`), conflates "pointer target missing" with any other git failure (exit 128 for several reasons), and would require the git stub to model a new subcommand. More complex, less deterministic.

Out of scope, noted for a possible follow-up: `CLEANUP_WT_ORPHAN_ROOTS` is split on `:` (`cleanup_worktrees_report_records_lib.sh:129-136`), so a drive-letter root supplied through that override on Windows would be split at the drive colon. The override is documented as a test seam and the derived roots do not pass through it, so it does not contribute to #706.

## 5. Behavior Semantics

- A pointer with a drive-letter target (`C:/...`, `c:/...`, `C:\...`) is resolved as given, without the worktree prefix. It yields `1` when the target exists, `0` when it does not (AC-1, AC-2).
- A `/`-leading target keeps its current behavior.
- A relative target (for example `../good_wt_target`, or a `--relative-paths` pointer) is still resolved against the worktree directory.
- `C:foo` (drive-relative, no separator) stays relative. An empty or missing target yields `0` (unchanged, lines 87-90).
- The record shape, field order, `NA` semantics, sort order, and the WARN line format are unchanged. `scan_registration_loss` and `run_report_scans` are not modified.

## 6. Test Strategy (Linux CI, bats, no temp files)

Constraints honoured: fixtures are checked in under `tests/fixtures/cleanup_worktrees/scan_roots/`; the pointer file is named `dotgit` through `CLEANUP_WT_SCAN_GITFILE_NAME` (git will not index `.git`, per the helper's header at lines 32-40); no scratch repository, no `origin/main`, no gitignored state, no CRLF fixture, and no dependence on a real `C:` drive. A directory literally named `C:` is not an option because it cannot be checked out on Windows.

New fixture root, kept separate from `scan_roots/basic/` so the existing test's expectations are untouched:

- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`, containing `gitdir: C:/fixture-repo/.git/worktrees/wt_drive` followed by LF.

Tests to append to `tests/shell/test_cleanup_worktrees_scan_helper.bats`:

1. **Regression (AC-1, AC-3), must fail before the fix.** Source the helper in `bash -c`, redefine `scan_helper_target_present() { [[ $1 == "C:/fixture-repo/.git/worktrees/wt_drive" ]]; }`, set `CLEANUP_WT_SCAN_GITFILE_NAME=dotgit`, and call `scan_helper_scan_dirs "<drive_letter root>"`. Assert the output matches `*/wt_drive|1|1|*`.
   - Before the fix, the redefined function is never called. The inline `[[ -e "$dir/C:/fixture-repo/..." ]]` fails, the record is `|1|0|`, and the assertion fails. This reproduces the reported false positive in the exact record shape `scan_registration_loss` consumes.
   - After the fix, the seam receives the unprefixed drive-letter path and returns true. The exact-match comparison also proves the directory was not prepended.
2. **Missing drive-letter target still reports loss (AC-2).** Run the same fixture with no redefinition. On Linux, `C:/fixture-repo/...` is classified absolute, `[[ -e ]]` is false, and the record is `|1|0|`. This passes before and after the fix and pins that the fix does not suppress genuine losses. The existing `broken_wt|1|0|` assertion continues to pin the relative-missing case.
3. **Pure predicate table.** `scan_helper_is_absolute_path` returns 0 for `/abs`, `C:/x`, `c:/x`, and `C:\x`, and returns non-zero for `../rel`, `rel`, `C:rel`, and the empty string. Arrange-Act-Assert, one invocation per case or one test per class.

The chain from record to WARN line is already pinned by `test_cleanup_worktrees_report_records.bats:84-89` ("emits nothing when the gitdir pointer resolves"), so no change to that file is required.

Local execution note: on the Windows host the agent worktree refuses command text containing `bash`, `pwsh`, or `wsl`, so bats execution is expected to be verified in CI (`.github/workflows/_shell-coverage.yml`). The ubuntu run is canonical per `.claude/rules/shell.md`.

## 7. Files a Fix Would Write

Production:
- `scripts/bash/cleanup_worktrees_scan_helper.sh`

Tests and fixtures:
- `tests/shell/test_cleanup_worktrees_scan_helper.bats`
- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit` (new)

Feature documentation:
- `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md` (root cause, AC-3)
- evidence under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/<kind>/` (baseline, qa-gates)

Not written: `scripts/bash/cleanup_worktrees_report_records_lib.sh`, `scripts/bash/cleanup-worktrees.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, and both `cleanup-merged-worktrees/SKILL.md` copies. The documented contract already states the intended behavior, so no documentation edit or mirror update is needed.

## 8. Sibling-Item Risk (issues 707-716)

The local branches for 707-711 are `codex-gates-4-5-lack-epic-scope-707`, `completion-consistency-edit-reads-relative-checkpoint-708`, `gate-suites-read-unmocked-local-epic-state-709`, `preimplementation-helpers-backslash-chain-operator-710`, and `remaining-cannot-fail-count-assertions-711`. None names cleanup-worktrees. No branch or feature folder for 712-716 was present locally, and `artifacts/orchestration/parallel-planner-state.json` records their feature folders without slugs, so their scope is unknown.

Shared hot spots, if any sibling touches cleanup-worktrees:
- `scripts/bash/cleanup_worktrees_scan_helper.sh` (this fix's only production file);
- `tests/shell/test_cleanup_worktrees_scan_helper.bats`;
- `scripts/bash/cleanup_worktrees_report_records_lib.sh` and `tests/shell/test_cleanup_worktrees_report_records.bats`, not touched here. Issue 711 (cannot-fail count assertions) could plausibly edit the `grep -c` scan-call count at line 130 of that bats file;
- the `.claude/` and `extensions/.../claude-customizations/` `SKILL.md` mirror pair, not touched here.

For merge-order independence: confine the edit to the lines inside `scan_helper_gitdir_target_exists` plus two new functions placed immediately above it; append the new bats tests after the existing `@test` rather than editing it; place the fixture in a new `scan_roots/drive_letter/` subtree; and state acceptance as named-test pass/fail rather than as a total test count or a whole-file diff.

## 9. Coverage and Shell QC

- Commands, in order: `bash scripts/bash/shell-qc.sh format`, then `bash scripts/bash/shell-qc.sh check` (shfmt `-d` plus shellcheck), then `bash scripts/bash/shell-qc.sh test`, then `bash scripts/bash/shell-qc.sh test --coverage` (`scripts/bash/shell-qc.sh:40-94`; `scripts/bash/shell_qc_lib.sh:226-254, 294-375`).
- Coverage: kcov, include pattern `tools,scripts,.claude/lib/bash`, exclude `tests` (`shell_qc_lib.sh:335-336`). The merged Cobertura report is `artifacts/pester/kcov/cov.xml` (copied from `kcov-merged/cov.xml`), and the run prints `Bash coverage (lines): NN.N%`. Line coverage only, with an 85% floor; no branch gate for bash.
- Per-file figure: count `line` elements with non-zero `hits` under the `class` whose `filename` ends in `scripts/bash/cleanup_worktrees_scan_helper.sh`. The prior recorded baseline is 46/53 (86.79%). Because that margin is small, every new line must be executed: test 1 runs the predicate's true path and the seam call, test 2 runs the real `scan_helper_target_present`, and test 3 runs both predicate outcomes. The plan should capture a fresh baseline before the change, because the 86.79% figure dates from 2026-09-08.
- CI: `.github/workflows/_shell-coverage.yml` runs `check` and then `test --coverage` on `ubuntu-latest` and uploads `artifacts/pester/kcov/**` as the `shell-coverage` artifact. Default `actions/checkout` depth is 1, and none of the proposed tests reads git history.
- Tier: the rule `.claude/rules/quality-tiers.md` refers to `quality-tiers.yml` at the repository root, but no such file exists on this branch. The bash property-test obligation (T1/T2) names no bash framework. The table-driven predicate test is the closest equivalent; the plan should record the tier assumption explicitly.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for any `spec.md` acceptance criterion. The counts in sections 2 and 2.2 (21, 64, 85, 46/53) are diagnostic observations of host state and prior evidence, not acceptance assertions. Acceptance should be stated as named-test outcomes.

## Automation Feasibility

No step requires human interaction. The fix, fixtures, and tests are fully automatable, and verification runs in CI on ubuntu. An optional manual confirmation on the Windows host (`bash scripts/bash/cleanup-worktrees.sh` emitting no `WARN|registration-lost` for healthy worktrees) is useful but not required by any acceptance criterion, because the regression test reproduces the defect without a Windows drive.

## Rejected Alternatives (summary)

- `cygpath` normalisation: host-dependent, and adds uncoverable lines in CI.
- `git rev-parse --git-dir` per directory: widens the helper's filesystem-only contract, is slower, and conflates failure modes.
- A fixture directory literally named `C:`: cannot be checked out on Windows.
