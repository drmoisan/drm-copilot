# Research: cleanup-worktrees `--apply` deletes local `main` (Issue #594)

- Issue: #594
- Branch: `bug/cleanup-worktrees-apply-deletes-local-main-594`
- Research date: 2026-09-25
- Code baseline: current `origin/main` (head `d754f83f`, after #630, #631, #632, #635, #637, #660) plus one docs commit
- Method: static reading of every file cited below. `--apply` was not run against the real repository. No bats run was performed in this research pass.

## 1. Reproduction verdict on current code

**Verdict: the defect still reproduces on current code.** No code path excludes the base branch `main` from classification or deletion unless `main` happens to be checked out in a protected worktree.

### 1.1 Trace

1. `run_apply` captures the worktree list and branch list up front (`scripts/bash/cleanup_worktrees_actions_lib.sh:373-380`), then builds `wt_of[<branch>]=<path>` for every branch-backed registration (`:383-391`).
2. `enumerate_branches` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:59-83`) emits every `refs/heads/*` ref via `git for-each-ref`, LC_ALL=C sorted. There is no filter; `main` is enumerated like any other branch.
3. `classify_all_branches` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:346-476`) calls `classify_branch` once per enumerated name (`:418-426`).
4. `classify_branch` (`scripts/bash/cleanup_worktrees_lib.sh:315-450`) rung 1 reads `compute_protected` (`:341-351`) and the branch's worktree path (`:354-367`), then returns `PROTECTED_CURRENT` only when the name is in `prot_branch` or its worktree path is in `prot_path` (`:368-371`).
5. `compute_protected` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:166-219`) emits exactly:
   - `protected-branch|<current branch>` from `git rev-parse --abbrev-ref HEAD` of the invoking worktree (`:185`, `:196-198`);
   - `protected-path|<first porcelain stanza>` (the primary worktree, `:211-212`);
   - `protected-path|<invoking worktree toplevel>` (`:213-214`).
   It never emits `main` by name.
6. In the reported topology (script run from the primary worktree, primary checked out on `chore/cleanup`, `main` not checked out anywhere): `prot_branch={chore/cleanup}`, `prot_path={<primary>}`, and `main` has no worktree, so `wt_norm` is empty. Rung 1 does not fire.
7. Rung 2, `classify_ancestry main` (`scripts/bash/cleanup_worktrees_lib.sh:59-80`), runs `git merge-base --is-ancestor main main` (`:71`). A commit is its own ancestor, so the exit is 0 and the verdict is `MERGED_CLEAN` (`:72-73`). `classify_branch` emits `BRANCH|main|MERGED_CLEAN` (`:375-377`).
8. The apply loop (`scripts/bash/cleanup_worktrees_actions_lib.sh:410-435`) reads that state; `MERGED_CLEAN` is on the allowlist (`:429-431`), so it calls `delete_candidate main "${wt_of[main]:-}" MERGED_CLEAN`.
9. `delete_candidate` (`:326-354`) calls `reverify_delete_eligible` (`:247-279`), which re-runs `classify_branch main` and again obtains `MERGED_CLEAN` (same self-ancestry), then `delete_branch main` (`:310-324`) runs `git branch -D main` (`:317`) and emits `ACTION|branch-delete|main|OK`.

### 1.2 Existing exclusions of `main` (none by name)

- `compute_protected`: protects by current branch name and by worktree path only (`cleanup_worktrees_enumerate_lib.sh:166-219`).
- `parse_worktree_list` flags the first stanza `main` (`cleanup_worktrees_enumerate_lib.sh:107`); this is the *primary worktree* flag, not the `main` branch. It is consumed by `is_detached_candidate` (`cleanup_worktrees_detached_lib.sh:55-56`) and the dirt-classification skip (`cleanup_worktrees_lib.sh:485`). Neither affects branch deletion.
- `classify_all_branches` documents an assumption that is false in the reported topology: "`main` needs no special handling: classify_branch resolves it PROTECTED_CURRENT at rung 1" (`cleanup_worktrees_report_records_lib.sh:391-394`, repeated at `:428-429`). This holds only when `main` is checked out in the primary or invoking worktree.
- `run_apply`'s docstring makes the same worktree-based claim (`cleanup_worktrees_actions_lib.sh:361-362`).
- `check_main_freshness` (`cleanup_worktrees_enumerate_lib.sh:221-236`) is advisory only, always returns 0, and silently skips when `main` or `origin/main` does not resolve (`:230-231`). It does not protect `main`.
- The detached path (`cleanup_worktrees_detached_lib.sh:64-165`) classifies by HEAD SHA and reads only `protected-path|` records (`:94-95`). It never deletes a branch, so it is not a route to deleting `main`.

### 1.3 Why it is not always visible

When the primary worktree is on `main`, `main`'s worktree path equals the first-stanza protected path, so rung 1 returns `PROTECTED_CURRENT`. Every existing fixture uses that shape (primary stanza `branch refs/heads/main`, for example `tests/fixtures/cleanup_worktrees/scenarios/current_exclusion/worktree-list.out:1-3`), which is why the suite never exercised the defect. The only existing negative assertion, `tests/shell/test_cleanup_worktrees_cli.bats:57-58` (`!= *"branch -D main"*`), runs under `merged_with_worktree`, where `main` is on the primary worktree.

### 1.4 Cascade symptom under the current driver

The issue's log shows later `BRANCH|...` lines degrading to `ANCESTRY_ERROR`. Under the current driver, `run_apply` computes every `BRANCH` verdict in one `classify_all_branches` pass (`cleanup_worktrees_actions_lib.sh:405-409`) **before** the deletion loop starts (`:410`). The printed `BRANCH` lines for branches that sort after `main` therefore reflect pre-deletion verdicts. The cascade now appears one step later: for each subsequent delete-eligible branch, `reverify_delete_eligible` re-runs `classify_branch`, whose `merge-base --is-ancestor <tip> main` hard-fails once `main` is gone. That yields `ANCESTRY_ERROR`, return 2 (`cleanup_worktrees_lib.sh:379-381`), which is mapped to `ACTION|delete|<name>|BLOCKED-REVERIFY` (`cleanup_worktrees_actions_lib.sh:260-263`), and `run_apply` returns non-zero. This is derived from reading the code; it was not observed at runtime. The local `main` deletion itself is unchanged.

## 2. Naming of the comparison base

- **Hard-coded literal `main`.** There is no variable, no `--base` option, and no environment override. `main()` in the wrapper accepts only `report`, `--apply`/`apply`, `preserve`/`--preserve`, `--help`, and `--clear-disposable` (`scripts/bash/cleanup-worktrees.sh:161-219`).
- A code-line grep for `\bmain\b` across `scripts/bash/cleanup*` found the base literal at:
  - `cleanup_worktrees_lib.sh:71, 96, 138, 230, 239, 248, 288` (ladder);
  - `cleanup_worktrees_enumerate_lib.sh:230-231` (freshness, including `origin/main`);
  - `cleanup_worktrees_actions_lib.sh:103, 225, 234, 235` (consolidation);
  - `cleanup_worktrees_dirt_lib.sh:315, 323, 349, 360, 362-363` (dirt classifier).
- The only named-branch constant precedent is `CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"`, a plain assignment that is not environment-overridable (`cleanup_worktrees_actions_lib.sh:46`).

**Recommendation.** Key the protection off the **same base name the ladder compares against**. Introduce a single named constant, `CLEANUP_WT_BASE_BRANCH="main"`, defined in `cleanup_worktrees_enumerate_lib.sh` (sourced first by the wrapper, `cleanup-worktrees.sh:18`, and by every bats harness). Follow the `CLEANUP_WT_CONSOLIDATION_BRANCH` precedent: a plain assignment that is not environment-overridable. Leave the ladder literals unchanged in this fix. An overridable constant would let the guard protect one name while the ladder compared against another. Do not derive protection from `origin/HEAD` (see Rejected alternatives).

## 3. Guard placement

### 3.1 Constraints discovered

- **File-size headroom.** `cleanup_worktrees_lib.sh` is at 496/500 lines, leaving 4 lines of headroom (see section 6). A new rung plus its docstring line in `classify_branch` cannot fit without trimming existing comments.
- **Byte-identity golden pins.** `tests/shell/test_cleanup_worktrees_dirt_regression.bats:40-63` compares live `run_report` and `run_apply` stdout byte-for-byte against `tests/fixtures/cleanup_worktrees/expected/*.out`. That file's header (`:9-11`) states the references were captured from the unmodified libraries, which is what lets the comparison fail. Nine of those goldens contain the line `BRANCH|main|PROTECTED_CURRENT` (see Numeric Derivation Evidence). Any design that changes the state emitted for `main` in the common topology (primary worktree on `main`) breaks nine pins and `tests/shell/test_cleanup_worktrees_classification.bats:110-112`.
- **State-vocabulary consumers.**
  - Bash: the header list (`cleanup_worktrees_lib.sh:54-55`), the help text (`cleanup-worktrees.sh:64-68`, `:119-122`), and the detached header (`cleanup_worktrees_detached_lib.sh:35-37`).
  - Skill: `.claude/skills/cleanup-merged-worktrees/SKILL.md:62-63, 70-72, 414-417, 521-527`, mirrored at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  - PowerShell manifest gate: an allowlist, `$script:AuthorizedBranchStates = @('NOT_MERGED', 'HAS_UNIQUE_RESIDUALS')` checked with `-cnotcontains` (`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1:50`, `:338`). A new state name is rejected by construction and would not break it. `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1:57-60` pins the allowlist at two members. `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1:158` pins `PROTECTED_CURRENT` as rejected. Neither enumerates the full bash vocabulary.
- **Line-number citations in comments (not test-enforced).**
  - `tests/fixtures/cleanup_worktrees/stub-bin/git:77-86` cites `cleanup_worktrees_actions_lib.sh:103, 147, 157, 164, 191, 198, 292, 317`.
  - `cleanup_worktrees_detached_lib.sh:23` cites `actions_lib.sh:19-35`, and `:46` cites `enumerate_lib.sh:115-116`.
  - Insertions placed below those lines keep the citations accurate.

### 3.2 Options

| Option | Description | Advantages | Limitations |
|---|---|---|---|
| A. `compute_protected` emits `protected-branch\|main` unconditionally | Add the base constant to the protected-branch set. `main` resolves `PROTECTED_CURRENT` at rung 1 in every topology. | About 5 lines in `enumerate_lib` (236 lines, ample headroom). Zero net lines in `cleanup_worktrees_lib.sh`. No vocabulary change. All nine goldens and `classification.bats:112` stay byte-identical. The false comment at `report_records_lib:391-394` becomes true. The detached path is unaffected, because it reads only `protected-path\|`. Q4 topology covered. | The state name `PROTECTED_CURRENT` is imprecise for a branch that is not checked out. The issue's Expected Behavior asks for "equivalent" protection (satisfied); its validation idea mentions a "distinct" state as one option. |
| B. New `PROTECTED_BASE` rung in `classify_branch` | Dedicated rung and state. | Precise label. | Does not fit the 4-line headroom without comment trimming. Vocabulary churn in the header, help text, detached header, and both SKILL.md copies. If placed before rung 1, it breaks 9 goldens and `classification.bats:112`. If placed after rung 1, `main`'s label depends on the checkout topology (`PROTECTED_CURRENT` or `PROTECTED_BASE`), so the report is not topology-stable. |
| C. Filter `main` out of `enumerate_branches` | `main` never appears as a candidate. | Simple. | Puts policy into plumbing. Removes `BRANCH\|main\|...` from 9 goldens. Breaks `test_cleanup_worktrees_enumeration.bats:26-27` (`lines[1] = "main aaaa0000"`). Also changes `run_report`'s early-abort probe input. |
| D. Defense-in-depth refusal in `delete_candidate` | Refuse `name == CLEANUP_WT_BASE_BRANCH` before re-verification, worktree removal, and branch deletion, emitting `ACTION\|delete\|main\|BLOCKED-PROTECTED-BASE` and returning 1. | Independent of classification. The ladder's protection assumption has already been wrong once (`report_records_lib:391-394`). Placing it at the top of `delete_candidate` (line 326 onward) also prevents the worktree removal in the Q4 topology. It sits below every `actions_lib` line number cited in comments elsewhere, so those citations stay accurate. `actions_lib` has 63 lines of headroom. | Unreachable through `run_apply` once A is in place, so coverage comes from direct `delete_candidate` calls (the existing suite already does this, `test_cleanup_worktrees_deletion.bats:46-53`). Adds one `ACTION` result token to document. |

**Recommendation: A + D.** A fixes both the report and apply classification with the smallest change and no contract churn. D is a narrow, independent backstop at the only function that performs a branch-backed worktree removal or a branch deletion. Place D at the top of `delete_candidate`, not in `delete_branch`. `delete_branch` runs after `remove_worktree_safe`, so a guard there would not prevent the worktree removal in the Q4 topology. `delete_branch` is also cited by line in the stub header (`:317`).

Implementation notes for A:
- Emit after the two `rev-parse` hard-failure guards (`cleanup_worktrees_enumerate_lib.sh:186-194`) so that the fail-closed contract (`rev_parse_error_protection`, `tests/shell/test_cleanup_worktrees_hard_failures.bats:70-82`) is unchanged.
- Skip emission when `current_branch` already equals the base, so the output carries no duplicate line.
- Place the constant and the emission below `enumerate_lib:116` so the `detached_lib:46` citation stays accurate.
- Reword `cleanup_worktrees_lib.sh:319-320` ("main worktree always protected" becomes one that also names the base branch) at zero net line change.
- Reword `cleanup_worktrees_report_records_lib.sh:391-394` and `:427-429`, and `cleanup_worktrees_actions_lib.sh:361-362`, to cite the unconditional base protection.
- Update `compute_protected`'s docstring (`enumerate_lib:167-183`) and the file header (`:7`, `:29-32`).

## 4. Worktree checked out on `main` that is not the primary worktree

**Yes, it must be protected. It is currently more exposed than the reported case.** Consider `main` checked out in a linked worktree that is neither the primary nor the invoking worktree:
1. `wt_norm` is that path (`cleanup_worktrees_lib.sh:360-367`), which is not in `prot_path`, so rung 1 does not fire and rung 2 yields `MERGED_CLEAN`.
2. `run_apply` has `wt_of[main]=<path>` (`cleanup_worktrees_actions_lib.sh:390`), so `delete_candidate` calls `remove_worktree_safe <path>` (`:346`). The unforced `git worktree remove` succeeds when that worktree is clean (`:292-295`).
3. `git branch -D main` then runs.

The result is a removed worktree as well as the deleted branch. Option A protects this case by branch name, before any worktree lookup matters. Option D refuses at the top of `delete_candidate`, before `remove_worktree_safe`. When the primary worktree is on `main`, `main` is already protected by path (`enumerate_lib:211-212`), and that is unchanged.

## 5. Test design

### 5.1 Sanctioned fixture mechanism (no scratch repositories)

The issue's validation idea ("a throwaway fixture repo") conflicts with repository policy. Every cleanup-worktrees suite states "No temporary files; no scratch git repositories", for example `test_cleanup_worktrees_classification.bats:5-6`, `test_cleanup_worktrees_deletion.bats:7-8`, and `test_cleanup_worktrees_hard_failures.bats:10`. `.claude/rules/shell.md` (Coding Standards) and `.claude/rules/general-unit-test.md` prohibit temporary files. The sanctioned mechanism is:

- **Recording git stub** `tests/fixtures/cleanup_worktrees/stub-bin/git`, wired through `CLEANUP_WT_GIT_BIN` (`cleanup_worktrees_enumerate_lib.sh:34-57`). It replays `<scenario>/<KEY>.out` to stdout and exits with `<scenario>/<KEY>.rc`, defaulting to empty output and exit 0 (`stub-bin/git:10-16`, `:128-142`). It logs `stub-git: <argv>` to stderr (`:107`) so tests can assert which destructive commands ran. It writes nothing to disk (`:3-4`).
- **Scenario directories** under `tests/fixtures/cleanup_worktrees/scenarios/<name>/`, selected by `CLEANUP_WT_STUB_SCENARIO`.
- **Filesystem-scan stub** `tests/fixtures/cleanup_worktrees/stub-bin/scan`, wired through `CLEANUP_WT_SCAN_BIN` for any `run_report`/`run_apply` driver (`test_cleanup_worktrees_deletion.bats:26-34`).
- Harness pattern: `run env CLEANUP_WT_GIT_BIN=... CLEANUP_WT_SCAN_BIN=... CLEANUP_WT_STUB_SCENARIO=... bash -c "source <libs in order>; <function>"`.

Under the stub, `merge-base --is-ancestor main main` with no fixture exits 0 (`stub-bin/git:222-237`), so the defect reproduces deterministically under the stub with no special fixture. `branch -D main` with no `branch-D.main.rc` exits 0, so pre-fix output contains `ACTION|branch-delete|main|OK`. The stub is stateless and cannot model `main` disappearing mid-run. The "no cascade" property is therefore asserted as "main is never deleted" plus a positive control on a branch that sorts after `main`.

### 5.2 New scenarios (checked-in fixtures, LF endings per `.gitattributes:1`)

`scenarios/base_not_checked_out/` (the reported topology):
- `worktree-list.out`: one stanza, `worktree /repo/main`, `HEAD cccc0000`, `branch refs/heads/chore-cleanup`, blank line.
- `for-each-ref.out`: `chore-cleanup cccc0000`, `feature-merged bbbb1111`, `main aaaa0000`, `zeta-merged dddd3333` (LC_ALL=C order; `zeta-merged` sorts after `main`).
- `rev-parse.abbrev-ref-HEAD.out`: `chore-cleanup`.
- `rev-parse.show-toplevel.out`: `/repo/main`.
- No `rev-parse.origin_main.*` fixture, so `check_main_freshness` resolves an empty SHA and emits nothing (`enumerate_lib:232`).

`scenarios/base_in_linked_worktree/` (Q4 topology): as above, plus a second stanza `worktree /repo-wt/base`, `HEAD aaaa0000`, `branch refs/heads/main`.

### 5.3 Test cases (fail before the fix, pass after, except where noted)

- `test_cleanup_worktrees_enumeration.bats`:
  - `compute_protected` under `base_not_checked_out` emits `protected-branch|main` and `protected-branch|chore-cleanup`.
  - Under `current_exclusion` it emits `protected-branch|main` in addition to the existing assertions (`:74-89`).
  - Under a scenario whose current branch is `main`, exactly one `protected-branch|main` line appears.
- `test_cleanup_worktrees_classification.bats`: `cb base_not_checked_out main` and `cb base_in_linked_worktree main` each equal `BRANCH|main|PROTECTED_CURRENT`.
- `test_cleanup_worktrees_deletion.bats`:
  - `apply base_not_checked_out`: output lacks `branch -D main`, `ACTION|branch-delete|main|`, and `BRANCH|main|MERGED_CLEAN`. Positive controls: `ACTION|branch-delete|feature-merged|OK` and `ACTION|branch-delete|zeta-merged|OK`, which prove the deletion pass ran and that a branch sorting after `main` is unaffected.
  - `apply base_in_linked_worktree`: output lacks `worktree remove /repo-wt/base` and `branch -D main`.
  - Direct `delete_candidate main "" MERGED_CLEAN` (Option D): status 1, `ACTION|delete|main|BLOCKED-PROTECTED-BASE`, and no `merge-base`, `worktree remove`, or `branch -D` argv, which proves the refusal precedes re-verification.
  - Direct `delete_candidate main /repo-wt/base MERGED_CLEAN`: no `worktree remove` argv.
  - Option D's direct-call tests fail before the fix because `delete_candidate` currently reverifies to `MERGED_CLEAN` and deletes.
- Pass-before regression pins that must stay green unchanged:
  - the nine goldens via `test_cleanup_worktrees_dirt_regression.bats`;
  - `classification.bats:105-113`;
  - `hard_failures.bats:70-82`;
  - `cli.bats:48-59`.

### 5.4 CI-compatibility constraints (sibling #660 failure)

`#660` failed Linux CI because tests ran `git diff origin/main` under the default depth-1 checkout. `.github/workflows/_shell-coverage.yml:13-14` uses `actions/checkout@v7` with no `fetch-depth` (recorded in `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/remediation-inputs.2026-09-25T17-00.md:13-47`). The new tests must:
- invoke no real git (all git goes through the stub) and reference no `origin/*` ref;
- read no gitignored state (for example `artifacts/orchestration/`);
- use POSIX fixture paths (`/repo/...`, `/repo-wt/...`) matching existing fixtures, with no drive roots or `/mnt/c` paths;
- create no files outside the checked-in fixture tree.

### 5.5 How the suite runs

- Local: `bash scripts/bash/shell-qc.sh test`, with coverage via `bash scripts/bash/shell-qc.sh test --coverage` (`.claude/rules/shell.md`, Toolchain). On Windows this runs under WSL. A single file can be run with `bats tests/shell/<file>.bats`. Project memory records that agent worktrees text-deny `bash`/`wsl` invocations, leaving CI as the authoritative bats run. That constraint was not re-verified in this session.
- CI: `.github/workflows/ci.yml:26-27` calls `_shell-coverage.yml`. On `ubuntu-latest` it runs `shell-qc.sh check` (shfmt 3.8.0 diff + shellcheck, `:51-52`), then `shell-qc.sh test --coverage` (bats under kcov v43, `:54-55`), then uploads `artifacts/pester/kcov/**` (`:57-62`).
- Coverage: kcov line coverage only. The include pattern is `tools`, `scripts`, `.claude/lib/bash`, and `tests` is excluded (`scripts/bash/shell_qc_lib.sh:335-336`). Results merge into `cov.xml` and print `Bash coverage (lines): NN.N%` (`:291`). `run_test_coverage` prints but does **not** enforce a threshold (`:294-379`). The 85% line threshold is policy (`.claude/rules/quality-tiers.md`, `.claude/rules/shell.md`). No branch-coverage gate applies to bash. The new lines in `compute_protected` and `delete_candidate` are executed by the tests in 5.3.

## 6. File-size headroom (500-line limit)

| File | Current lines | Expected change | Headroom after |
|---|---|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 0 net (docstring reword `:319-320`) | 4 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | about +6 (constant, emission, docstring) | about 258 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 437 | about +8 (D guard plus docstring) | about 55 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 476 | 0 net (comment reword `:391-394`, `:427-429`) | 24 |
| `scripts/bash/cleanup-worktrees.sh` | 229 | +1 to 2 (help text note) | about 269 |
| `tests/shell/test_cleanup_worktrees_deletion.bats` | 153 | about +45 | about 300 |
| `tests/shell/test_cleanup_worktrees_classification.bats` | 259 | about +15 | about 225 |
| `tests/shell/test_cleanup_worktrees_enumeration.bats` | 113 | about +25 | about 360 |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` (plus extension mirror) | 565 | +2 to 4 | Markdown is exempt |

Line counts were taken with a per-file `^` line count over the files listed. Option B is excluded partly because of the 4-line headroom in `cleanup_worktrees_lib.sh`.

## 7. Files a fix would touch (recommended design A + D)

Production:
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh`: `CLEANUP_WT_BASE_BRANCH` constant, unconditional `protected-branch|` emission in `compute_protected`, docstrings.
- `scripts/bash/cleanup_worktrees_actions_lib.sh`: refusal at the top of `delete_candidate`; `run_apply` docstring (`:361-362`); header note for the new `BLOCKED-PROTECTED-BASE` result.
- `scripts/bash/cleanup_worktrees_lib.sh`: docstring reword only (`:319-320`).
- `scripts/bash/cleanup_worktrees_report_records_lib.sh`: comment corrections only (`:391-394`, `:427-429`).
- `scripts/bash/cleanup-worktrees.sh`: help text sentence that `PROTECTED_CURRENT` also covers the base branch `main`, plus the new blocked token.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`: the invariant at `:521-527` (never mutate the base branch `main`). The two copies must stay in parity.

Tests and fixtures:
- `tests/shell/test_cleanup_worktrees_enumeration.bats`, `tests/shell/test_cleanup_worktrees_classification.bats`, `tests/shell/test_cleanup_worktrees_deletion.bats`.
- New `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/` (4 files) and `.../base_in_linked_worktree/` (4 files).

Not touched: the nine goldens under `tests/fixtures/cleanup_worktrees/expected/`, `stub-bin/git`, the PowerShell manifest module and its tests, `cleanup_worktrees_detached_lib.sh`, `cleanup_worktrees_dirt_lib.sh`, and `.github/workflows/*`.

## Numeric Derivation Evidence

### Claim N1: golden reference files that pin `BRANCH|main|PROTECTED_CURRENT`

- Complete Family: all checked-in golden reference files under `tests/fixtures/cleanup_worktrees/expected/`.
- Exhaustive Search Scope: every file in `tests/fixtures/cleanup_worktrees/expected/` (both `report.*.out` and `apply.*.out` members).
- Inclusion Rules: the file contains a line exactly equal to `BRANCH|main|PROTECTED_CURRENT`.
- Exclusion Rules: files outside `expected/`; lines that merely contain `main` in a `WORKTREE|` record.
- Primary Search Strategy or Query Expression: Grep, anchored regex `^BRANCH\|main\|PROTECTED_CURRENT$`, `files_with_matches`, path `tests/fixtures/cleanup_worktrees/expected`.
- Primary Member Set: `report.unmerged.out`, `report.residual_unique_doc.out`, `report.residual_on_main.out`, `report.merged_with_worktree.out`, `report.merged_no_worktree.out`, `report.main_divergence.out`, `report.current_exclusion.out`, `report.content_neutral.out`, `apply.dirty_worktree.out`.
- Primary Count: 9.
- Cross-check Search Strategy or Query Expression: Glob `tests/fixtures/cleanup_worktrees/expected/*` to enumerate the complete family (10 files), then per-file inspection. The unanchored content Grep `\|main\|` over `tests/` lists the `BRANCH|main|...` line number per file, and the only remaining member, `apply.dirty_worktree_status_error.out`, was read in full (2 lines, both `WORKTREE|`, no `BRANCH|` line).
- Cross-check Member Set: the 10 Glob members minus `apply.dirty_worktree_status_error.out`, giving `report.content_neutral.out`, `report.current_exclusion.out`, `report.main_divergence.out`, `report.merged_no_worktree.out`, `report.merged_with_worktree.out`, `report.residual_on_main.out`, `report.residual_unique_doc.out`, `report.unmerged.out`, `apply.dirty_worktree.out`.
- Cross-check Count: 9.
- Member-set Comparison: after normalizing to basenames and sorting, the primary and cross-check sets are identical (9 = 9, no member present in only one set).

## Recommendations

**Recommended design (single).**
1. Define `CLEANUP_WT_BASE_BRANCH="main"` in `scripts/bash/cleanup_worktrees_enumerate_lib.sh` as a plain, non-overridable constant, following `CLEANUP_WT_CONSOLIDATION_BRANCH`.
2. Make `compute_protected` emit `protected-branch|$CLEANUP_WT_BASE_BRANCH` unconditionally. Emit it after the `rev-parse` hard-failure guards and skip it when the current branch is already the base. `main` then resolves `PROTECTED_CURRENT` at rung 1 of `classify_branch` in every checkout topology, in both report and apply mode, and including a linked worktree checked out on `main`.
3. Add a defense-in-depth refusal at the top of `delete_candidate` in `scripts/bash/cleanup_worktrees_actions_lib.sh`. For the base branch it emits `ACTION|delete|main|BLOCKED-PROTECTED-BASE` and returns 1 before re-verification, worktree removal, or branch deletion.
4. Correct the now-inaccurate comments (`report_records_lib:391-394`, `:427-429`; `actions_lib:361-362`; `lib:319-320`), add a help-text note, and update both SKILL.md copies.
5. Add regression coverage using two new checked-in stub scenarios (primary worktree on a non-`main` branch; `main` in a linked worktree), with no scratch repositories and no `origin/*` references.

**Alternatives considered (for the spec's decision record).**
- New `PROTECTED_BASE` state via a dedicated `classify_branch` rung. Rejected: it does not fit the 4-line headroom in `cleanup_worktrees_lib.sh`, and it churns the state vocabulary across the script header, help text, and both SKILL.md copies. Ordered first, it breaks nine byte-identity goldens. Ordered second, it makes `main`'s label depend on the checkout topology.
- Filtering `main` out of `enumerate_branches`. Rejected: it embeds policy in plumbing, removes `main` from the report, and breaks nine goldens and `test_cleanup_worktrees_enumeration.bats:26-27`.
- Guard in the deletion pass only (Option D alone). Rejected as the sole fix: report mode would still print `BRANCH|main|MERGED_CLEAN`, a misleading state that the cleanup skill's triage consumes. Retained as the backstop.
- Guard in `delete_branch` instead of `delete_candidate`. Rejected: it runs after `remove_worktree_safe`, so it would not prevent the worktree removal when `main` is checked out in a linked worktree.
- Protection derived from `origin/HEAD` (`git symbolic-ref refs/remotes/origin/HEAD`). Rejected: it adds a git read to every `compute_protected` call (once per branch plus each re-verification) and a new fail-closed path. The ref may be absent in some clones, and in this repository it resolves to `main`, which is already protected. It also diverges from the ladder, which compares against the literal `main`.
- Making the base configurable (`--base` option or environment override) and replacing every ladder literal. Deferred: the literal appears across four libraries, including `cleanup_worktrees_dirt_lib.sh` at 495/500 lines. That is a feature change beyond this Blocker fix, and a partial override would desynchronize protection from comparison.
