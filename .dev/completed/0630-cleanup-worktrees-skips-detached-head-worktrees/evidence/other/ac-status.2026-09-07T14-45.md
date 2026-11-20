# Acceptance Criteria Status (Issue #630)

Timestamp: 2026-09-07T14-45

Task: [P7-T12]

Command: `grep -c '^- \[x\] AC[0-9]' docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` and `grep -c '^- \[ \] AC[0-9]' <same file>`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## AC Source Resolution

`issue.md` carries `- Work Mode: full-bug`. Per
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the acceptance
criteria to **`spec.md` only**. `user-story.md` is present in the feature folder but is not
an AC source under this work mode, and `issue.md` is context only. No checkbox in any file
other than `spec.md` was modified by [P7-T11].

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
- Total AC items: 24
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: none

## Integrity of the Check-Off Edit

The 24 criteria occupy contiguous lines 401-424 of `spec.md`, under the `## Acceptance
Criteria` heading. Before the edit, all 24 read `- [ ]`; after it, all 24 read `- [x]`, and
the file still contains exactly **24** checkbox items in total, numbered **AC1 through
AC24** with no gap and no addition.

`git diff --stat` reports **24 insertions and 24 deletions**, one line each. `git diff
--word-diff=porcelain` reports exactly one distinct removed token, `[ ]`, and one distinct
added token, `[x]`. **No criterion text differs from its pre-edit text by any character.** No
criterion was added, removed, or renumbered.

## Per-Criterion Evidence Map

Every criterion below was verified individually against the named artifact before being
checked. All paths are relative to the feature folder
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/`.

| AC | Supporting evidence artifact | What in it establishes the criterion |
|---|---|---|
| AC1 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 1 report emits one detached record with MERGED_CLEAN` |
| AC2 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 2 report emits NOT_MERGED for an unmerged detached HEAD` |
| AC3 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 3 is_detached_candidate flag matrix` |
| AC4 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 4 branch-backed worktree records keep the four-field shape` |
| AC5 | `evidence/qa-gates/pinned-assertions-unmodified.2026-09-07T14-30.md`; `evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md` | `tests/shell/test_cleanup_worktrees_enumeration.bats` has an **empty diff** against `origin/epic/cleanup-merged-worktrees-hardening-integration`, so all four pinned literals at `:33`, `:34`, `:41`, `:48` are unmodified; the full-suite run reports **no `not ok` line**, so those cases pass |
| AC6 | `evidence/qa-gates/pinned-assertions-unmodified.2026-09-07T14-30.md`; `evidence/regression-testing/cli-suite-pass-after.2026-09-07T14-30.md`; `evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md` | the anchored `git diff` counted through `awk` prints **`0`**: no added or removed line in the classification, CLI, hard-failures, or enumeration suites carries a `WORKTREE` assertion; the full-suite run reports **no `not ok` line at all**, so no failing case names any of those assertions |
| AC7 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 5 apply removes a merged detached worktree without force` |
| AC8 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 6 apply never touches an unmerged detached worktree` |
| AC9 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 10 the caller's own detached worktree is PROTECTED_CURRENT` |
| AC10 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md`; direct fixture re-derivation recorded below | `ok 3 is_detached_candidate flag matrix` covers the `main`, `main,bare`, and `main,detached` rows; `ok 1` carries the end-to-end assertion at `tests/shell/test_cleanup_worktrees_detached.bats:48` |
| AC11 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md`; `evidence/qa-gates/remove-worktree-safe-untouched.2026-09-07T14-30.md` | `ok 7 dirty detached worktree blocks with DIRTY lines`; the anchored diff of `cleanup_worktrees_actions_lib.sh` contains exactly two hunks, at base 202-207 and base 343-351, and **neither intersects lines 252-279**, so the diff on that range is empty |
| AC12 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 8 locked detached worktree yields BLOCKED-LOCKED and invokes no removal` |
| AC13 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 9 prunable detached worktree is report-only` |
| AC14 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 11 a hard git failure maps to ANCESTRY_ERROR with no removal` and `ok 13 classify_detached_head returns 2 on a hard failure` |
| AC15 | `evidence/regression-testing/detached-suite-pass-after.2026-09-07T14-30.md` | `ok 14 reverify_detached_delete_eligible blocks on a flipped verdict` |
| AC16 | `evidence/regression-testing/deletion-suite-pass-after.2026-09-07T14-30.md` | `ok 7 a zero-commit consolidation branch is never deleted` and `ok 8 verify_consolidation_merged returns NOT_ANCESTOR on tip equality` |
| AC17 | `evidence/qa-gates/rejected-guard-absent.2026-09-07T14-30.md`; `evidence/regression-testing/deletion-suite-pass-after.2026-09-07T14-30.md` | clause (a): `grep -rnF -- "rev-list --count" scripts/bash/ \| wc -l` prints **`0`**, with the same pipeline against `rev-parse` printing `25` as the falsifiability control; clause (b): `ok 6 consolidated-content branch deletion is gated on the merge check`, the pre-existing case, still passes |
| AC18 | `evidence/regression-testing/deletion-suite-pass-after.2026-09-07T14-30.md` | `ok 9 verify_consolidation_merged fails closed on an empty rev-parse` |
| AC19 | `evidence/qa-gates/no-temp-files.2026-09-07T14-30.md`; `evidence/qa-gates/new-paths-tracked.2026-09-07T14-30.md` | the `mktemp\|BATS_TMPDIR\|BATS_TEST_TMPDIR\|git init` search over the new suite prints **`0`**; `git ls-files` covers all ten named paths across **52 tracked entries**, with each of the eight new fixture directories represented |
| AC20 | `evidence/qa-gates/skill-tokens-present.2026-09-07T14-30.md`; direct re-derivation recorded below | the three-`grep` chain exits 0 with counts 2, 1, 1; the report-line bullet and the consolidation sentence are quoted verbatim from the skill file |
| AC21 | `evidence/qa-gates/push-down-mirror.2026-09-07T14-30.md` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` reports **`1 passed`**; independently, `cmp` finds the skill file and its bundled mirror byte-identical at 18325 bytes each |
| AC22 | `evidence/regression-testing/cli-suite-pass-after.2026-09-07T14-30.md` | `ok 1 --help prints usage and exits 0` and `ok 6 --help documents the detached worktree record`; the help output's report-lines paragraph is quoted verbatim and contains `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>` |
| AC23 | `evidence/qa-gates/shell-file-line-counts.2026-09-07T14-30.md`; `evidence/qa-gates/detached-lib-line-count.2026-09-07T14-30.md`; `evidence/qa-gates/new-paths-tracked.2026-09-07T14-30.md`; direct re-derivation recorded below | the `wc -l scripts/bash/*.sh` table shows a largest per-file count of **483**, so no file exceeds 500; the new library is **301** lines; `git ls-files` shows it tracked |
| AC24 | `evidence/qa-gates/final-bash-format.2026-09-07T14-30.md`; `evidence/qa-gates/final-bash-check.2026-09-07T14-30.md`; `evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md`; `evidence/qa-gates/toolchain-single-pass.2026-09-07T14-45.md`; `evidence/qa-gates/coverage-delta.2026-09-07T14-45.md` | stage 1: `format` printed nothing, `PreCheck:` empty, before/after porcelain byte-identical; stage 2: `check` exited 0 with empty stdout and stderr; stage 3: exited 0, TAP plan `1..308`, no `not ok` line, `Bash coverage (lines): 92.9%`, which is at least 85.0 |

## Three Conjuncts Verified Directly Rather Than From an Artifact

Three criteria name a conjunct that no pre-existing artifact records. Each was re-derived
against the current tree during [P7-T11] rather than checked on a close-enough basis, and the
re-derivation is recorded here so a third party can repeat it.

**AC10, second conjunct — "no scenario in the new suite producing a
`WORKTREE|/repo/main|DETACHED|` line in either mode".** The suite carries this assertion at
`tests/shell/test_cleanup_worktrees_detached.bats:48`, inside the case
`report emits one detached record with MERGED_CLEAN`, which passed. That covers the
`detached_merged` scenario explicitly. For the remaining scenarios the property is structural
rather than asserted case by case: the `worktree-list.out` fixture of every one of the seven
detached scenarios (`detached_merged`, `detached_unmerged`, `detached_merged_dirty`,
`detached_locked`, `detached_current`, `detached_prunable`, `detached_ancestry_error`)
registers `/repo/main` with `branch refs/heads/main` and **no `detached` marker**, and
`is_detached_candidate` requires the `detached` flag — exhaustively verified by the passing
flag-matrix case, which asserts non-zero for `main`, `main,bare`, `main,detached`, `prunable`,
and the empty string. `/repo/main` therefore cannot be emitted as a `DETACHED` record in any
scenario of the new suite, in either mode.

**AC20, first conjunct — the literal `WORKTREE|<path>|DETACHED|<state>|<flags>`.** The [P6-T4]
artifact greps for `ANCESTRY_ERROR`, `BLOCKED-LOCKED`, and `NOT_ANCESTOR`, not for this
literal, although it quotes verbatim a bullet that begins with it. The literal was re-derived
directly with `grep -nF 'WORKTREE|<path>|DETACHED|<state>|<flags>'
.claude/skills/cleanup-merged-worktrees/SKILL.md`, which returns **two** matches, at lines
**67** and **139**.

**AC23, second conjunct — "being sourced by `scripts/bash/cleanup-worktrees.sh`".** No
artifact records the source line. It was re-derived with `grep -n cleanup_worktrees_detached_lib
scripts/bash/cleanup-worktrees.sh`, which returns line **25**
(`# shellcheck source=scripts/bash/cleanup_worktrees_detached_lib.sh`) and line **27**
(`source "$SCRIPT_DIR/cleanup_worktrees_detached_lib.sh"`). The wrapper sources the new
library.

## One Recorded Divergence Between AC24's Wording and the Executed Run

AC24's stage-1 clause carries a parenthetical predicting that the porcelain listing "is
non-empty at that point because this feature has modified tracked files". **That prediction
did not hold in the executed run:** both the `Before:` and the `After:` listings are empty,
because every change this feature makes had been committed before the stage ran.

The criterion is checked because the parenthetical is rationale for choosing byte-identity
over an emptiness test, not a separate verification requirement, and the operative
assertion — both listings recorded verbatim and byte-identical to each other — holds. The
divergence is recorded rather than passed over because it has a consequence worth stating:
byte-identity of two empty listings is trivially satisfied and could not have failed in that
state, so the porcelain pair is not by itself falsifiable evidence here. The falsifiable
evidence for stage 1 is the **empty `PreCheck:` output** captured by [P7-T1], which runs
`shfmt -d` over the same discovered file list that `format` rewrites and is therefore the
exact inverse of what `shfmt -w` would have rewritten. That instrument is stronger than the
one AC24 names, and it did establish the underlying fact.

## One Recorded Caveat on AC21

The governing test passed, but a first invocation of the same command failed on an assertion
naming `.claude/state/python-batch-budget.worktree-agent-adf4f49cbc48904be-7d397a9a.json`, an
untracked and gitignored local file. That is the previously filed issue **#510**: a
local-only failure that is green in CI. The passing run was obtained by moving that single
untracked file aside and restoring it; **no tracked file was altered**, so the repository
content under test was identical in both runs. Independently of the test, `cmp` reports the
repository skill file and its bundled mirror byte-identical at 18325 bytes each, which is
stricter than the content comparison the test performs.

Output Summary: All **24** acceptance criteria in
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
are **checked off**; **0** remain unchecked. Each was verified individually against the
evidence artifact named for it in the plan's AC-to-Task Traceability table before being
checked, and three conjuncts that no artifact recorded were re-derived directly against the
current tree and are documented above. The check-off edit changed exactly 24 lines, replacing
`[ ]` with `[x]` and nothing else; the file still holds exactly 24 checkbox items numbered
AC1 through AC24 with unmodified text. Two items carry recorded caveats — AC24's non-operative
parenthetical did not describe the executed run, and AC21's test required the issue #510
workaround — and both are stated in full above rather than omitted.
