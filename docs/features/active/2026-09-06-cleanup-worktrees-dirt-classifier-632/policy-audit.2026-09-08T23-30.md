# Policy Audit — cleanup-worktrees dirt classifier (Issue #632), remediation cycle 2 EXIT REAUDIT

- Timestamp: 2026-09-08T23-30 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `454bd523`
- Resolved base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
  (`git merge-base HEAD origin/epic/cleanup-merged-worktrees-hardening-integration`)
- Cycle 2 sub-range examined separately: `02150524..454bd523`
- Work mode: `full-bug`. Acceptance-criteria source: `spec.md` only.
- Blocking findings in this artifact: **2** (N3 FAIL, N4 blocking-PARTIAL). Both are NEW.

## Rejected Scope Narrowing

The caller prompt supplied a cycle-scoped diff range and a five-item adjudication list:

> Cycle 2 base for the diff is `02150524` (the plan-only commit that opened the cycle); cycle 2's
> work is `c7d6c989..454bd523`.

This is recorded because the Scope Invariant forbids treating a caller-supplied range as the audit
scope. Justification for proceeding differently: the audit scope is the full branch diff
`4ffe680e..454bd523` against the resolved base branch, and every verdict below is stated against
that range. The cycle-2 sub-range is reported as an additional breakdown only.

No other narrowing was attempted. The caller did not ask for any language, toolchain check, or
coverage check to be skipped.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/shell.md` (bash is the only production language with changed files)

No policy document was modified. No source or test file was modified. All mutation probes were run
against copies under the session scratchpad.

## Changed-File Language Inventory (full branch diff)

Command:

```
git diff --name-only 4ffe680e..454bd523
```

| Language | Changed files | Coverage verdict |
|---|---|---|
| bash (`.sh`, `.bats`) | 4 (`scripts/bash/cleanup-worktrees.sh`, `cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_dirt_lib.sh`, `cleanup_worktrees_lib.sh`) plus 13 `tests/shell/*.bats` | **PASS** |
| TypeScript | 0 | N/A — zero changed files on the branch |
| Python | 0 | N/A — zero changed files on the branch |
| PowerShell | 0 | N/A — zero changed files on the branch |
| C# | 0 | N/A — zero changed files on the branch |

Everything else in the diff is Markdown (`docs/features/**`, two `SKILL.md` copies), TSV fixture
data, and stub scenario fixture files. No coverage language other than bash has a changed file, so
the `N/A` rows above are the permitted case, not a narrowing.

## Coverage Verification — bash

Coverage was verified from the pre-existing CI artifact. No coverage generation was re-run.

- Source run: dispatch **34229386300** of `.github/workflows/_shell-coverage.yml`.
- Independently confirmed by this reviewer:

```
gh run view 34229386300 --json status,conclusion,headSha,event,url
{"conclusion":"success","event":"workflow_dispatch",
 "headSha":"7d7a661f88c082184a892e153922f22af43e6a40","status":"completed", ...}
```

- Artifact retrieved with `gh api repos/drmoisan/drm-copilot/actions/artifacts/10057356590/zip`
  (385025 bytes) and `kcov-merged`/root `cov.xml` reparsed by counting `<line hits>` per `<class>`
  rather than reading the rounded `line-rate` attribute.

Recomputed figures (this reviewer's own parse, not a restatement of the executor's artifact):

```
ROOT ATTRS: {'line-rate': '0.937', 'lines-covered': '2166', 'lines-valid': '2312'}
RECOMPUTED REPO: 2166/2312 = 93.69%

cleanup-worktrees.sh                       38/ 39 =  97.44%
cleanup_worktrees_actions_lib.sh          159/169 =  94.08%
cleanup_worktrees_detached_lib.sh         103/103 = 100.00%
cleanup_worktrees_dirt_lib.sh             160/170 =  94.12%
cleanup_worktrees_enumerate_lib.sh         82/ 89 =  92.13%
cleanup_worktrees_lib.sh                  187/196 =  95.41%
cleanup_worktrees_report_records_lib.sh   162/182 =  89.01%
cleanup_worktrees_scan_helper.sh           46/ 53 =  86.79%
```

| Check | Threshold | Observed | Verdict |
|---|---|---|---|
| Repo-wide bash line coverage | >= 85% | 93.69% (2166/2312) | PASS |
| `cleanup_worktrees_dirt_lib.sh` (modified file) | >= 85%, no regression | 94.12% (160/170), up from 94.05% (158/168) | PASS |
| Other seven `cleanup[-_]worktrees*` files | no regression | unchanged from baseline; lowest is 86.79% | PASS |
| Branch coverage | n/a for bash | kcov measures none | Not applicable by rule, not by exemption request |

The N1 fix's own lines are covered, checked directly against the artifact rather than asserted:

```
line 312 hits=1 : cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet \
line 314 hits=1 : if ((erc == 0)); then # guard:rung4-tracked-path-in-main
line 315 hits=1 : printf 'CONTENT_ON_MAIN|\n'
line 316 hits=1 : return 0
```

The ten uncovered lines in the classifier library are line continuations of captured `$( )` reads,
the `CLEANUP_WT_SESSION_ARTIFACT_PATHS` array literal, and two `case` arms. None is a fail-closed
branch. This matches the cycle-1 finding and is unchanged.

One file repo-wide is below the 85% floor: `.claude/lib/bash/compute-concurrency-batches.sh` at
81.82% (36/44). It has **zero changed lines on this branch** (`git diff --name-only 4ffe680e..454bd523`
does not list it), so it is out of this feature's remit. Carried forward as cycle 1's O4.

## Evidence Location Compliance

```
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT=0   (no output)

git diff --name-only 4ffe680e..454bd523 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'
  (no matches)
```

**PASS.** Every evidence artifact this branch adds is under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`. No file is
written to a non-canonical path. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred in this
review; this reviewer wrote no evidence artifacts of its own.

## Epic NFR Compliance

| NFR | Verdict | Evidence |
|---|---|---|
| Bash line coverage >= 85% | **PASS** | 93.68% -> 93.69% repo-wide; recomputed above from run 34229386300. |
| Every new bash library function has bats coverage through the `CLEANUP_WT_GIT_BIN` stub seam against checked-in fixtures | **PASS** | Cycle 2 added no library function. `git diff 02150524..454bd523 -- scripts/bash/cleanup_worktrees_dirt_lib.sh` adds one guarded `rev-parse` read inside an existing function and 37 marker comments. Both new executable lines are covered. |
| No temporary files in tests | **PASS** | `grep -nE 'mktemp\|BATS_TMPDIR\|/tmp/\|TMPDIR\|mkdir -p'` over the three changed/added bats files returns nothing. The new registry gate composes its mutated source into a shell variable and pipes it to a child; the mutated source never reaches disk (`mutate_lib`, `run_child`, lines 68–113 of `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`). |
| No production source file over 500 lines | **PASS** | `wc -l`: `cleanup_worktrees_dirt_lib.sh` 481, `cleanup_worktrees_lib.sh` 496. Changed test files: 380, 230, 452. All under 500. |
| Every `.claude/**` edit mirrored byte-identically | **PASS** | `diff .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` produces no output. `.claude/skills/cleanup-merged-worktrees/SKILL.md` is the only `.claude/**` file changed on the branch. |

## Toolchain Loop

| Stage | Verdict | How verified |
|---|---|---|
| 1 Formatting (`shfmt` write mode) | **UNVERIFIED by re-run** | The worktree-isolation guard denies this reviewer any command line that invokes `bash` or `source` in a plain command, which is the only route to `shell-qc.sh format` and to `discover_shell_scripts`. Reason recorded rather than substituted. See the P0-T3 adjudication below. |
| 2 Linting (`shellcheck`) | **UNVERIFIED by re-run** | Same denial. Covered transitively by CI run 34229386300 concluding `success`. |
| 3 Type checking | Not applicable | No type checker applies to bash, per `.claude/rules/shell.md`. |
| 4 Architecture-boundary tests | Not applicable | No bash architecture gate exists in this repository. |
| 5 Unit tests | **PASS** | Reproduced independently. `bats --tap` over all 13 `tests/shell/test_cleanup_worktrees_*.bats` files: **179 ok, 0 not ok, exit 0**. Full-suite figure of `1..411` with 0 `not ok` comes from CI run 34229386300 and is not re-derivable locally for the non-cleanup-worktrees suites within this reviewer's permission surface. |
| 6 Contract / schema checks | **PARTIAL, non-blocking** | `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` -> `1 failed, 10 passed`. See below. |
| 7 Integration tests | Not applicable | No bash integration suite. |

### Stage 6 detail — the push-down contract test

Reproduced by this reviewer:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::
       test_bundled_claude_payload_contains_all_repo_runtime_contracts
AssertionError: Repo file missing from bundle: .claude\state\current-session-id
1 failed, 10 passed in 0.18s
```

The cause is confirmed independently:

```
git check-ignore -v .claude/state/current-session-id
.gitignore:68:.claude/state/   .claude/state/current-session-id
```

The failing assertion concerns a gitignored local session-state file, not this branch's content. The
half of the test that this feature is responsible for — SKILL.md mirror parity — passes, and the
mirror is byte-identical as shown above. This is issue **#510**, fails identically at Phase 0
baseline, and is green in CI. **Not blocking, and not attributable to this branch.**

Minor evidence-accuracy note (non-blocking): `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`
cites the ignore rule as `.gitignore:67`; the observed citation is `.gitignore:68`. The reasoning is
unaffected.

## Adjudication of the Five Unchecked Plan Tasks

53 of 58 plan tasks are checked. The five unchecked ones were reviewed against
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` and independently re-derived.

### P0-T3 / P5-T1 — the denied tree digest

The substitution argument is **sound**, and this reviewer verified each of its three load-bearing
premises rather than accepting them:

1. `tools/` does not exist — `ls` reports `No such file or directory`. Two of the three discovery
   roots in `discover_shell_scripts` (`scripts/bash/shell_qc_lib.sh:85`) therefore reduce to
   `scripts` and `.claude/lib/bash`.
2. `is_shell_script` (`shell_qc_lib.sh:54-73`) admits a file either by a lowercased `.sh` suffix or
   by a `bash`/`sh` shebang. A search over both roots for files without a `.sh` suffix whose first
   200 bytes match `^#!.*\b(bash|sh)\b` returns **zero** matches, across 238 non-`.sh` files. The
   digest set and the `-name '*.sh'` set are therefore identical in this tree.
3. Because the byte-identical `StatusBefore`/`StatusAfter` listing contains no untracked `.sh` file,
   every member of the digest set at that moment was tracked, so any rewrite would have surfaced in
   `StatusAfter`.

The digest's extra reach over the status channel is over an empty set. Leaving the task `- [ ]` is
the correct disposition because two of its four required observation fields are denied; the
underlying property (the write-mode formatter rewrote nothing) is established by the status channel.
**Not blocking.**

### P0-T10 / P4-T7 / P5-T11 — the push-down contract test

Reproduced and attributed above. Pre-existing, unrelated, open as #510, identical at both ends of
the baseline-to-post-change comparison. The executor's refusal to delete the gitignored state file
to force a green result is correct: it would make the gate pass without changing anything the gate
measures. **Not blocking.**

## Findings

### N3 — rungs 4 and 5 resolve a disposable verdict without ever comparing the index blob (NEW, FAIL)

- Severity: **FAIL**. Data loss on `--clear-disposable`, the feature's own destructive flag.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:303-320` (rung 4 tracked half) and
  `:344-362` (rung 5).
- Full statement, reproduction, and discrimination analysis are in
  `code-review.2026-09-08T23-30.md`. Summarised here because it is a policy violation as well as a
  code defect: it breaks the ONE-SIDED BOUND ASYMMETRY property the library header asserts at
  `cleanup_worktrees_dirt_lib.sh:22-27` ("Every bound and every match in this file fails in the safe
  direction"), and it breaks the Scenario Completeness clause of `.claude/rules/general-unit-test.md`
  because no checked-in scenario covers an entry with a non-space Y column whose working-tree
  content resolves disposable.

### N4 — the guard registry gate can be satisfied without exercising a guard (NEW, blocking-PARTIAL)

- Severity: **PARTIAL, blocking** under the caller's stated criterion: "If the gate can still be
  satisfied without genuinely exercising a guard, that is a blocking finding."
- Location: `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:338-373` (the `EXEMPT` arm
  of Obligation 5 and Obligation 6's sibling rule).
- The full cheapest-passing-artifact construction and the empirical demonstration are in
  `code-review.2026-09-08T23-30.md`. In brief: 20 of the 37 marker ids are not pinned by the third
  test, all 20 are arithmetic-only, and Obligation 6's sibling rule is satisfied trivially by naming
  a scenario in which the ladder never reaches the guard, because both admissible constants are then
  unobservable. This reviewer demonstrated it by parking `staged-probe-skip-head` at `EXEMPT`
  against `dirt_unique` in a scratch copy; all three gate tests still pass, even though the shipped
  registry proves the same guard is separable under `dirt_staged_tree_is_commit`.
- AC-47's own text discloses this ("`EXEMPT is scenario-scoped`"), so this is not a mismatch between
  what the criterion claims and what was delivered. It is a limitation of the gate's strength, and it
  matters because the gate was created to answer a systemic obligation that N3 shows is still open.

## Non-Blocking Observations

| ID | Observation |
|---|---|
| P1 | `.claude/lib/bash/compute-concurrency-batches.sh` at 81.82% line coverage, zero changed lines on this branch. Cycle 1's O4, still open, separate issue. |
| P2 | `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` cites `.gitignore:67`; observed value is `.gitignore:68`. |
| P3 | `cleanup_worktrees_dirt_lib.sh` is at 481 of the 500-line limit and `cleanup_worktrees_lib.sh` at 496. The registry gate suite is at 452. Headroom for the N3 remediation is 19 lines in the classifier library. |
| P4 | The registry gate's `GUARD_RE` predicate forces markers only onto arithmetic comparisons. Non-arithmetic guards are compelled only by the hard-coded eight-element `LIT_IDS`/`LIT_MUTS` list, so a newly added `[[ ... ]]` verdict guard would not be pulled into the registry automatically. AC-47 states exactly this scope, so it is not a defect against the criterion. |

## Verdict

**FAIL.** Two blocking findings, both NEW. N1 and all four N2 sites are verified closed by
reproduction and by discriminating mutation probes; see `feature-audit.2026-09-08T23-30.md`.
