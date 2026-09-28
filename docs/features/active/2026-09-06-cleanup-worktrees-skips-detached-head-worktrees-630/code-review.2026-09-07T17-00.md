# Code Review: detached-worktree classification and consolidation-branch ordering (Issue #630)

**Review Date:** 2026-09-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630`
**Feature Folder Selection Rule:** Supplied by the caller and confirmed — it is the only active feature folder whose suffix matches the issue number in the branch name (`...-630-r2`), and it holds the scoping docs changed by this branch.
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration` (merge base `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`)
**Head Branch:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2` (head `2742c417dcd686e76310d9f15420390d421868db`)
**Review Type:** Re-audit (R4) of remediation cycle 1; full feature-vs-base scope
**Work Mode:** `full-bug` — AC source is `spec.md` only

---

## Executive Summary

This branch closes two apply-mode defects in the `cleanup-merged-worktrees` tool. A worktree with a
detached HEAD was listed in the report but never classified and never removable, because
classification iterated `enumerate_branches` output and the apply-mode `wt_of` map explicitly
skipped `DETACHED` registrations. Separately, the consolidation branch `documentationandmemories`
was classified `MERGED_CLEAN` during the window between its creation at `main` and its first commit,
so an apply pass in that window would delete it.

The fix adds a 301-line sourceable library, `scripts/bash/cleanup_worktrees_detached_lib.sh`, whose
six functions classify a detached registration on its own HEAD SHA using the four existing ladder
rungs, emit a five-field `WORKTREE|<path>|DETACHED|<state>|<flags>` record, and remove
delete-eligible detached worktrees under the same allowlist, the same same-process re-verification,
and the same non-forced `git worktree remove` that govern branch-backed worktrees. The consolidation
fix is a 20-line tip-equality pre-check inside `verify_consolidation_merged`.

This is the fourth review pass and the first after remediation cycle 1. The prior review raised two
Major blocking findings and one FAIL coverage verdict. **All three are closed**, and the closure was
verified by re-derivation rather than by accepting the reported figures.

For R1, the two previously unproduced delete-eligible verdicts are now each produced and each drive
the destructive path. This reviewer ran `run_apply` against `detached_content_neutral` outside bats
and observed the full sequence: the five-field record carrying `MERGED_CONTENT_NEUTRAL`, a second
classification pass (the same-process re-verification), the argv line `worktree remove /repo-wt/det`
with no force flag, `ACTION|worktree-remove|/repo-wt/det|OK`, and exit 0. `MERGED_EQUIVALENT` is
produced at two distinct ladder rungs and likewise reaches `OK`. `HAS_UNIQUE_RESIDUALS` is produced
and its apply-mode non-eligibility asserted. For R2, all five named fail-closed guards now have an
asserting case, four of them with the report-mode `ANCESTRY_ERROR` record and a non-zero apply
status alongside. Per-file coverage for the new library moved 0.806 to 1.000 and the repo-wide
aggregate 0.936 (merge base) to 0.942, both re-read from the Cobertura XML inside the CI run
artifacts.

The eight new fixture directories model reality rather than merely satisfying the stub. Each was
checked against the ladder implementation at `scripts/bash/cleanup_worktrees_lib.sh:53-240` and
against the stub's key scheme: `detached_content_neutral` models a revert-pair HEAD (not an ancestor,
zero net diff); `detached_equivalent` a cherry-picked HEAD; `detached_equivalent_residual` a residual
commit whose touched path holds an identical blob OID on main; `detached_unique_residuals` a
partially incorporated HEAD with both a `-` and a `+` cherry line and genuinely differing blob OIDs;
the four error scenarios each drive exactly one git probe to exit 128. The `consolidated_zero_commit`
fixture deliberately sets `merge-base.documentationandmemories.rc` to 0, so the pre-existing ancestry
check would say `MERGED_CLEAN` and the tip-equality pre-check has to win — that is a falsifiable
design, not a rubber stamp.

The remediation introduced no new problem. No executable statement under `scripts/` changed; the
only production edit is five lines of operator text inside the quoted `usage()` heredoc, and every
claim in that text was traced to code (`remove_detached_worktree` returns 1 for `BLOCKED-LOCKED`,
`reverify_detached_delete_eligible` returns 1 for `BLOCKED-REVERIFY`, `remove_worktree_safe` returns
1 for `BLOCKED-DIRTY`; all three fold into `rc=1` in `apply_detached_worktrees` and propagate through
`run_apply`). The four pre-existing suites gained only a `DLIB` path variable and a `source` link in
their helper chains; every pinned assertion named in AC5, AC6, and AC17 is textually unmodified and
green.

One new Minor finding is recorded, and it corrects a statement this reviewer made in the prior pass.

**What changed since the prior review:**

- **Fixtures (+63 files, 8 directories):** `detached_content_neutral`, `detached_content_neutral_error`, `detached_equivalent`, `detached_equivalent_residual`, `detached_unique_residuals`, `detached_cherry_error`, `detached_residual_error`, `detached_protection_error`.
- **Tests (+13 cases):** 12 appended to `test_cleanup_worktrees_detached.bats`, 1 appended to `test_cleanup_worktrees_cli.bats`; 2 existing cases strengthened.
- **Production (+5 lines, non-executable):** operator text inside the `usage()` heredoc of `scripts/bash/cleanup-worktrees.sh`.
- **Docs:** `SKILL.md` and its content-identical push-down mirror gained the apply-mode exit-code paragraph; `spec.md` gained limitation L5; 19 evidence artifacts added.

**Top 3 risks (all accepted, none blocking):**

1. **Apply mode now exits non-zero on checkouts that previously exited 0.** A dirty or locked detached worktree yields `BLOCKED-DIRTY` or `BLOCKED-LOCKED` and a non-zero `run_apply` return. This is deliberate and is now documented in four places (`spec.md`, `SKILL.md`, the push-down mirror, `--help`) and asserted by three tests. Any caller that treats a non-zero `--apply` exit as fatal will change behavior on such a checkout.
2. **`run_report` and `run_apply` hard-depend on a function defined in a file sourced after them.** A consumer that sources only the enumerate and classification libraries and calls `run_report` dies at `is_detached_candidate` with exit 127. This is the deliberate design recorded in `spec.md` D2 (a `declare -F` soft guard was rejected because it would silently skip detached classification). All in-repo consumers were updated.
3. **The detached path emits no `COMMIT|` record**, so unique work in a `HAS_UNIQUE_RESIDUALS` or `NOT_MERGED` detached worktree is retained but invisible to consolidation triage. Recorded as limitation L5 in `spec.md`; fails in the safe direction.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/shell/test_cleanup_worktrees_detached.bats` | `the caller's own detached worktree is PROTECTED_CURRENT`, line 134 | The assertion `[[ "$output" != *"merge-base --is-ancestor det00005"* ]]` cannot fail. `classify_ancestry` invokes git as `cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1` (`scripts/bash/cleanup_worktrees_lib.sh:65`), which routes the stub's `stub-git: ` argv line to `/dev/null`, so no `merge-base` string reaches `$output` in any scenario. The prior review described this as "the correct falsifiable form for a short-circuit claim"; that statement was incorrect and is corrected here. | Give `detached_current` a `merge-base.det00005.rc` of `0` and assert that the emitted record is `PROTECTED_CURRENT` rather than `MERGED_CLEAN`. Reaching the ancestry rung would then change the verdict, which is observable. Alternatively drop the assertion and rely on the positive record assertion plus the code contract. | A negative assertion that cannot fail contributes no protection while reading as if it does. Correcting the prior review's own claim matters more than the assertion itself. | Empirically proved: `run_report` against `detached_merged` emits `WORKTREE&#124;/repo-wt/det&#124;DETACHED&#124;MERGED_CLEAN&#124;detached`, a verdict only `classify_ancestry` can produce, yet the combined stdout and stderr contains zero occurrences of `merge-base`. Same run shows `stub-git: rev-parse --abbrev-ref HEAD` and `stub-git: worktree remove ...` lines, so the stub log itself is reaching `$output`. |
| Info | `tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/` | whole directory | The scenario hosts two key sets. `det00014` makes `git cherry` exit 128; `det00015` makes `git diff-tree` exit 128 while probing a `+` residual. Only `det00014` appears in `worktree-list.out`, so `/repo-wt/det2` is reachable only by direct function invocation. This departs from one-directory-one-repository-state. | No action. | The stub answers `cherry` from one key per sha, so a single directory cannot make both `cherry` and `diff-tree` fail for the same sha. The test comment states this explicitly, and the alternative (a ninth directory differing in one `.rc` file) buys little. | `cherry.det00014.rc` = 128; `cherry.det00015.out` = `+ det00015` with `diff-tree.det00015.rc` = 128; `worktree-list.out` lists only `/repo-wt/det` at `det00014`. Test comment at lines 283-288. |
| Info | `scripts/bash/cleanup_worktrees_detached_lib.sh` | `report_detached_worktrees` lines 181-188, `apply_detached_worktrees` lines 279-286 | The two drivers share an eight-line iterate-classify-emit preamble. | No action. | The duplication is deliberate and documented: apply mode must retain the verdict it emitted in order to decide removal from that same verdict, and factoring the loop out would either force a second classification or introduce a callback seam that costs more than it saves. The file header states the reasoning. | Both functions read in full; the divergence begins at the `((crc != 0))` handling and continues through the allowlist `case`. |
| Info | `scripts/bash/cleanup-worktrees.sh` | `usage()` heredoc, lines added by `12cc5766` | The added paragraph states that a blocked detached removal sets a non-zero exit status and names `BLOCKED-DIRTY`, `BLOCKED-LOCKED`, and `BLOCKED-REVERIFY`. Every claim was traced to code and is accurate. The change is inside a quoted heredoc, so it adds no instrumented statement. | No action. | The prior review's R4 finding asked for exactly this text in exactly this place. | `remove_detached_worktree` returns 1 at the `locked` case and propagates `reverify_detached_delete_eligible`'s 1 and `remove_worktree_safe`'s 1; `apply_detached_worktrees` folds each into `rc=1`; `run_apply` propagates via `apply_detached_worktrees "$wlout" &#124;&#124; rc=1`. `git diff 65a56cb9..HEAD -- scripts/` is this hunk and nothing else. |
| Info | `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh` | `run_report` line 473, `run_apply` line 372 | All branch-backed `WORKTREE` records precede all detached records, whereas before this branch both interleaved in `git worktree list --porcelain` order. Output remains fully deterministic. | No action. Note it if a downstream consumer ever depends on registration ordering. | Every report consumer in this repository matches by prefix or substring, not by position. | Both emission loops read; all `WORKTREE` assertions across the six suites are substring or prefix based; 83 of 83 cleanup-suite cases pass locally at head. |
| Info | `scripts/bash/cleanup_worktrees_lib.sh` | whole file | 483 of the 500-line cap. | Watch the margin as sibling epic children extend the same library. | Pre-existing, and the stated reason the detached function group ships in a new file. | `wc -l scripts/bash/*.sh`: 483 is the maximum; the new library is 301. |
| Info | `scripts/bash/cleanup_worktrees_detached_lib.sh` | `classify_detached_head` line 88; `reverify_detached_delete_eligible` line 210 | `compute_protected` is invoked once per detached candidate and again during re-verification, each call costing three git subprocesses. On the 30-detached-worktree checkout described in `issue.md` this is roughly 90 extra spawns in report mode and up to 180 in apply mode. | No action for this child. If a sibling adds a shared protected-set cache, this call site should adopt it. | The cost profile is identical to the pre-existing `classify_branch`, which also recomputes the protected set per branch. Not a regression introduced here. | Confirmed by the argv log of an out-of-bats `run_apply` run: `rev-parse --abbrev-ref HEAD`, `rev-parse --show-toplevel`, `worktree list --porcelain` appear once per classification pass, twice per removed candidate. |
| Info | branch integration | `epic/cleanup-merged-worktrees-hardening-integration` @ `288ca214` | The base branch is 5 commits ahead of the merge base, and one of those commits (sibling child 634) edits the same `SKILL.md` this branch edits. Cycle 1 added a further paragraph to that file, which was the reason the prior review asked for a re-check. | No action; re-check after any further base movement. | The two edit regions remain textually disjoint. | `git fetch origin epic/...` then `git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD` exits **0**, re-run by this reviewer at head `2742c417`. |

**Blocking findings: 0.** No finding in this table requires remediation before PR.

---

## Prior-Finding Closure

| Prior finding | Severity | Status | Verification performed by this reviewer |
|---|---|---|---|
| R1 — `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, and `HAS_UNIQUE_RESIDUALS` produced by no test | Major, blocking | **Closed** | Read all three new fixture directories against the ladder implementation; ran the suite (26/26 green); drove `run_apply` against `detached_content_neutral` outside bats and observed the record, the re-verification pass, the non-forced `worktree remove` argv, `ACTION&#124;worktree-remove&#124;/repo-wt/det&#124;OK`, and exit 0. `MERGED_EQUIVALENT` is produced at rung 3 (`detached_equivalent`) and rung 4 (`detached_equivalent_residual`), and the rung-3 case drives the destructive path to `OK`. `HAS_UNIQUE_RESIDUALS` is produced and its apply run asserted to emit no removal. |
| R2 — five fail-closed guards unexercised | Major, blocking | **Closed** | One case per guard, all green: `compute_protected` failure, `CONTENT_NEUTRAL_ERROR`, `CHERRY_ERROR`, `DIFF_TREE_ERROR`, `RESIDUAL_ERROR`, and the `((crc != 0))` half of `reverify_detached_delete_eligible`. Four also assert the report-mode `ANCESTRY_ERROR` record, a non-zero apply status, and the absence of `worktree remove`. Each fixture drives exactly one probe to exit 128, so the guard under test is the one that fires. |
| Coverage FAIL — new file at 80.6% against the reviewer's 90% new-file threshold | FAIL | **Closed** | Cobertura from CI run 34142466852 (verified `headSha` `12cc5766`, `conclusion` success) reports `line-rate="1.000"` for `scripts/bash/cleanup_worktrees_detached_lib.sh` and `line-rate="0.942"` repo-wide. The merge-base run 34113725852 at `a36b6dca` reports 0.936 repo-wide; no modified file regressed. |
| R3 — two under-asserting cases | Minor | **Closed** | `locked detached worktree yields BLOCKED-LOCKED and invokes no removal` now asserts `[ "$status" -ne 0 ]`; `--help documents the detached worktree record` now asserts the literal `WORKTREE&#124;<path>&#124;DETACHED&#124;<state>&#124;<flags>`. Both green. |
| R4 — apply-mode exit-code change undocumented in operator surfaces | Minor | **Closed** | `SKILL.md` line 150 and the `usage()` heredoc both carry the statement; the push-down mirror is byte-identical (`git hash-object` returns `123aa988ebd7af19108d0022ae533115c5bf7c74` for both). A new CLI case asserts `BLOCKED-REVERIFY` appears in `--help`. |
| R5 — detached `COMMIT` blind spot unrecorded | Minor | **Closed** | `spec.md` records it as limitation **L5** with its safe failure direction and follow-up status. No `COMMIT` emission was implemented, as the finding required. |
| R6 — re-confirm clean integration before PR | Minor, pre-PR | **Closed** | `git merge-tree --write-tree` against the current remote base head exits 0. |

---

## Security and Safety Review

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Read the full new library and every diff hunk. No credential, token, key, or environment secret is read, written, or logged. All fixture data is synthetic (`det00001`-`det00016`, `aaaa0000`, `blobA`/`blobB`/`blobSAME`). |
| No unsafe subprocess or command construction | PASS | All git access routes through the existing `cleanup_wt_git` wrapper with separate argv words. No `eval`, no unquoted expansion in command position, no string-built command line. Every variable used as a git argument is double-quoted. |
| Destructive action is gated | PASS | Removal requires `is_detached_candidate` true, a state on the three-token allowlist, not locked, not prunable, and a fresh same-process re-classification still on the allowlist. Any failure at any gate returns 1 and performs no removal. |
| All three allowlist entries proven on the destructive path | PASS | This was the prior review's first blocking finding. Each of `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, and `MERGED_EQUIVALENT` now drives an apply-mode case to `ACTION&#124;worktree-remove&#124;/repo-wt/det&#124;OK` with `--force` and `worktree prune` asserted absent. |
| Fail-closed branches are tested | PASS | This was the prior review's second blocking finding. All six hard-failure branches now have an asserting case. |
| Removal is never forced and pruning is never invoked | PASS | `grep -rn -- "--force" scripts/bash/` returns no match. `grep -rn "worktree prune" scripts/bash/` matches only a comment stating it is never invoked. Six tests assert the absence of both strings from the argv log, and the argv log for `worktree remove` is demonstrably observable in `$output`. |
| Protection of the caller's own worktree | PASS | Decided by normalized path against `compute_protected`'s protected-path records. `classify_detached_head` returns `PROTECTED_CURRENT` at lines 97-98, before the `classify_ancestry` call at line 102. The behavior is correct; only the test's argv-based evidence for the ordering is weak (see the Minor finding). |
| A weakened protected set cannot unlock a removal | PASS | A `compute_protected` hard failure maps to `ANCESTRY_ERROR` and return 2 before any classification probe, now asserted by `a protection-set hard failure fails closed as ANCESTRY_ERROR` in all three modes (direct, report, apply). |
| Main worktree is never a candidate | PASS | `is_detached_candidate` returns non-zero for any flag set containing `main` or `bare`, asserted by three rows of the flag matrix plus a negative assertion in the first report case. |
| Input validation at boundaries | PASS | Empty flag sets, empty records, and empty `rev-parse` results are handled explicitly. `is_detached_candidate ''` returns non-zero; both driver loops skip empty records; the consolidation pre-check treats an empty tip on either side as a hard failure rather than an equality match, asserted by `verify_consolidation_merged fails closed on an empty rev-parse`. |
| Error handling remains explicit | PASS | Every git-backed read is parent-shell captured with `&#124;&#124; rc=$?` and fails closed. No broad catch-all. No silent degradation. Traced through all six functions. |
| Configuration and path handling is safe | PASS | Paths are normalized once via `normalize_wt_path` and compared as strings. No path is constructed by concatenation and none is passed to a shell for re-parsing. |
| No network call in the blocked consolidation case | PASS | The tip-equality pre-check runs before the best-effort `fetch`, so a zero-commit consolidation branch is refused without any network access. |

---

## Test Quality Review

| Aspect | Assessment |
|---|---|
| Assertion strength | Strong. 30 of the 31 new-or-changed cases assert at least one positive condition. The negative argv assertions on `worktree remove`, `--force`, `worktree prune`, and `branch -D` are meaningful because those commands are invoked without stderr suppression, which this reviewer confirmed by observing `stub-git: worktree remove /repo-wt/det` in `$output` during a removal run. The one exception is the `merge-base` negative recorded as the Minor finding. |
| Fixture fidelity | Strong. Every new scenario was cross-checked against the ladder implementation and the stub key scheme; each drives the rung it claims to drive, and the error scenarios each fail exactly one probe so the guard under test is unambiguous. |
| Regression protection | Strong. `branch-backed worktree records keep the four-field shape` guards the record shape; the four pinned assertion sets in `enumeration`, `classification`, `cli`, and `hard_failures` are textually unmodified and green. |
| Determinism | Strong. No clock, no RNG, no network, no temp file, no scratch repository. Local and CI TAP plans agree at `1..321`. |
| Comment quality | Strong. Every new case states which rung or guard it drives and why the substring assertion form was chosen (the stub's stderr argv log merges into `$output`, so equality tests against a bare token would fail). |
| Documented rationale for non-obvious choices | Strong. The `detached_cherry_error` two-key-set arrangement, the substring-versus-equality decision, and the deliberate non-reuse of `classify_branch` are each explained where a reader will encounter them. |

---

## Verification Commands Run by This Reviewer

```bash
sh scripts/bash/shell-qc.sh check                                  # exit 0, empty stdout, empty stderr
npx --yes bats tests/shell/                                        # exit 0, 1..321, 321 ok, 0 not ok
npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats    # 26/26 ok
npx --yes bats tests/shell/test_cleanup_worktrees_{cli,deletion,classification,hard_failures,enumeration}.bats
                                                                   # 57/57 ok
sh scripts/bash/cleanup-worktrees.sh --help                        # exit 0; record literal + BLOCKED-REVERIFY
git hash-object .claude/skills/cleanup-merged-worktrees/SKILL.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
                                                                   # identical OIDs
grep -rn "rev-list --count" scripts/bash/                          # no match
grep -rn -- "--force" scripts/bash/                                # no match
wc -l scripts/bash/*.sh                                            # max 483
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0
gh run view 34142466852 --json headSha,conclusion,headBranch       # success @ 12cc5766
gh run view 34142466852 --log                                      # 1..321, 321 ok, 0 not ok, 94.2%
gh api repos/drmoisan/drm-copilot/actions/artifacts/10026546424/zip  # post-change Cobertura
gh api repos/drmoisan/drm-copilot/actions/artifacts/10015570663/zip  # merge-base Cobertura
git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD  # exit 0
```

Two additional out-of-bats driver runs were performed to test claims the suite asserts indirectly:
`run_apply` against `detached_content_neutral` (confirming the destructive path from a
`MERGED_CONTENT_NEUTRAL` verdict) and `run_report` against `detached_merged` (establishing that the
`merge-base` argv log is suppressed, which is the basis of the Minor finding).

---

## Recommendation

**Approve.** Both Major blocking findings from the prior review are closed in substance, the
coverage FAIL is closed with re-derived figures, all four Minor findings are addressed, and the
remediation introduced no new defect. The single new finding is a non-falsifiable pre-existing
assertion whose underlying behavior is correct; it does not warrant another remediation cycle. No
`remediation-inputs` artifact is produced by this pass.
