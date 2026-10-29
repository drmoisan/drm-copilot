# Code Review: Parallel run leaves uncommitted records and worktrees (#995)

---

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
**Feature Folder Selection Rule:** the only active feature folder added on the branch; its suffix matches issue #995 in the branch name.
**Base Branch:** `main` (merge base `972e4083c59fefd1d40984929503c9956eed7137`)
**Head Branch:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995` (`7dec2f9a0a0f4ef8f30b225462dac19f4a4a604b`)
**Review Type:** Re-review after a proportionate remediation cycle (prior review `code-review.2026-10-29T11-55.md` at `bed21939d7da24cce0c2100ef619fe3aaa23f19d`)

---

## Executive Summary

The branch fixes two causes of issue #995: the removal gates did not recognise a checkpoint record whose `worktree_path` is relative to the main checkout, and the parallel orchestrator had no closing step. The shared pure matcher in `WorktreeRunRecordPath.psm1` now serves all six matcher-family sites, and the `parallel-orchestrate` skill and `parallel-orchestrator` agent carry a `### Run Closing` procedure. The full branch diff against the merge base was reviewed again; this document records the state at the new head.

The remediation commit `7dec2f9a0` addresses the four Minor findings of the prior review:

1. `Test-CleanupManifestCheckpointCoversPath` now also matches on invariant-lower-cased record, target, and base roots, so the checkpoint-coverage exclusion is no narrower than the case-insensitive `Find-CleanupWorktreeManifestRemovalRecord`. The widening affects only the exclusion, which moves in the fail-closed direction (more records block the manifest branch). The shared matcher stays ordinal for single-slash POSIX paths, so the gates' allow lookups are unchanged. CM-case1 to CM-case3 pin the rule, including a negative row.
2. Run Closing substep 3 in the skill, agent, and both bundle copies now names only `docs/features/` pathspecs and states that `artifacts/` is gitignored. RC4 narrows its allowed prefixes to `docs/features/`, and RC5 and RA5 assert the removed alternative is absent.
3. RE2b adds three epic `features[]` deny rows (`pr_open`, `worktree_created`, absent status).
4. One exported `Get-WorktreeRunRecordBaseRoot` replaces the two identical hook helpers; B1 to B4 cover it, including the StrictMode-safe handling of a read object without a `Target` property.

The executor also added RP5, RP6, and RE5 to cover pre-existing uncovered lines so that no changed file fell below its baseline after the helper deletion.

**What changed (remediation delta):**
`Get-WorktreeRunRecordBaseRoot` added and exported; `Get-ParallelWorktreeGateBaseRoot` and `Get-EpicWorktreeGateBaseRoot` deleted with all four call sites updated; case-parity clause in `Test-CleanupManifestCheckpointCoversPath`; Run Closing substep 3 wording in four files; 22 new test rows across five suites; seven bundle mirrors updated.

**Top 3 risks:**
1. The Run Closing procedure cannot be proven by unit tests (unlock and remove under a live harness lock, docs-only pull request through `Agent(pr-author)`, merge-gate evaluation). The spec records LV1 to LV4 with deferral behavior.
2. `origin/main` has advanced three commits past the merge base (release `1.1.23` and npm audit fixes). `git merge-tree` reports a clean merge and none of the commits touches a changed path, but the branch must be brought up to date before the pull request is opened.
3. The case-parity clause performs a second matcher call per record when the first fails. The cost applies only to manifest-branch evaluation of `git worktree remove` commands and is bounded by the record count.

**PR readiness recommendation:** **Go**. No Blocker, Major, or Minor finding; the toolchain and coverage thresholds pass. Merge remains subject to the S9 CI green gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/spec.md` | `## Proposed Fix` item 3 (line 133) and AC-11 text (line 204) | The spec's design text and AC-11 still name `docs/features/` or `artifacts/orchestration/` as permitted pathspec prefixes, while the runtime surfaces now permit only `docs/features/`. | No change required. Optionally note the narrowing in `## Implementation Deviations`. | The runtime text is a strict subset of what AC-11 permits, so AC-11 remains satisfied; the spec is a planning record, not a runtime surface. | `git diff bed21939d..HEAD -- .claude/skills/parallel-orchestrate/SKILL.md`; `grep -n "artifacts/orchestration" spec.md`. |
| Info | `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/evidence/qa-gates/file-sizes.2026-10-29T13-11.md` | Command line | The executor counted post-change sizes with `wc -l`, while plan task P0-T4 and the file-size policy specify `@(Get-Content -LiteralPath <path>).Count`. | No change required. | The reviewer's logical line counts confirm every changed covered file is at most 495 lines, so no conclusion changes. | Reviewer logical line count of all 33 changed covered files. |
| Info | `artifacts/pester/powershell-coverage.xml` (gitignored) | Executor final Pester run | The executor's final coverage run scanned only `tests/scripts/claude-hooks`, `claude-lib`, and `claude-runtime`, so the artifact's repo-wide total (61.05%, 12009 of 19670) is not representative. The reviewer regenerated the artifact from a full `tests/scripts` run (policy audit, Approved Exceptions). | For future cycles, write the final coverage artifact from a full `tests/scripts` run. | Per-file figures for the changed files were already valid in the executor's artifact; only the repo-wide figure needed the full run. | Reviewer parse of the executor artifact (backed up to the session scratchpad) and of the regenerated artifact. |
| Info | `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | `$script:AbsolutePathPattern` | Carried from the prior review: the pattern duplicates the one in `WorktreeRunResolution.psm1`; the comment acknowledges it. | No change required. | Recorded so a future edit updates both. | Module source. |
| Info | `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1` | RC5, RA5 | The regex pins only the exact phrase `or` followed by the backticked `artifacts/orchestration/`. | No change required. | RC4 with the narrowed `AllowedPathPrefixes` independently rejects any backticked `git add`/`git commit` span outside `docs/features/`, so a reworded reintroduction in a command example still fails. | Test diff. |

No Blocker, Major, or Minor findings. The four Minor findings of `code-review.2026-10-29T11-55.md` are resolved (see Remediation Verification). No covered file in the branch diff is at or above 700 lines (largest 495), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

### Remediation Verification

| Prior finding | Status | Evidence |
|---|---|---|
| Manifest case-rule asymmetry | Resolved | Second matcher call on invariant-lower-cased inputs in `Test-CleanupManifestCheckpointCoversPath`; `.DESCRIPTION` states the rule; CM-case1 and CM-case2 failed before the change (`evidence/regression-testing/expect-fail.2026-10-29T12-26.md`) and pass after; CM-case3 negative row passes. The shared matcher (M5, P2) is unchanged. |
| `artifacts/orchestration/` pathspec wording | Resolved | Substep 3 in `SKILL.md` and `parallel-orchestrator.md` (and bundle copies) names only `docs/features/`; RC5 and RA5 failed before and pass after. |
| Epic `features[]` deny rows | Resolved | RE2b, three rows, passes; correctly recorded as passing against unchanged production code. |
| Duplicated base-root helpers | Resolved | `Get-WorktreeRunRecordBaseRoot` exported; no match for either removed helper name under `.claude/`, `tests/`, `extensions/`, or the spec (reviewer search); X1 expects four exports. |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python change in the remediation. The replaced contract test still requires the list of `pr-author` entries to equal exactly `["Agent(pr-author)"]`.

#### Typing and API notes

- Pyright: 0 errors, 0 warnings, 0 informations on the changed test (reviewer). No production Python change.

#### Error handling and logging

- The assertion message prints the full tools list.

### TypeScript implementation audit

#### What changed well

- Not applicable; no TypeScript file changed.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- The base-root rule now has one definition. The new helper adds a `Target` property-existence check before reading `$Read.Target`, which makes it safe under StrictMode for read objects that lack `Target` (B3b); the deleted hook helpers did not have that check.
- The case-parity clause is guarded: a blank `$WorktreePath` or `$null` checkpoint returns `$false` before `.ToLowerInvariant()` is called, and `[string]$null` records become empty strings, which the matcher rejects.
- Lower-casing cannot turn an unsafe relative record into a safe one, because the safety rule tests for blank, `.`, `..`, dot segments, and `:`, none of which depend on case.
- Hook import order is unchanged: the parallel gate and the epic resolution file import `WorktreeRunRecordPath.psm1` in the guarded `try/catch Add-HookDependencyFailure` form, and the epic gate reaches the helper through the guarded dot-source of its resolution file.
- Mirrors: `cmp` reports all nine changed `.claude` files identical to their bundle copies.

#### API and safety notes

- Exported surface of `WorktreeRunRecordPath.psm1`: `Test-WorktreeRunPathEqual`, `Test-WorktreeRunRecordedPathMatchesTarget`, `Get-WorktreeRunRecordBaseRoot`, `Get-WorktreeRunMainCheckoutRoot` (X1). The removed helpers were hook-local and had no test or external caller.
- The allow lookups in both gates still use the shared matcher only, so their fail-closed comparison semantics are unchanged by the remediation.

#### Error handling and logging

- Deny reason prefixes and text are unchanged.

### C# implementation audit

#### What changed well

- Not applicable; no C# file changed.

#### Type safety and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The reviewer ran a full single-process `tests/scripts` Pester run with coverage, parsed the regenerated `artifacts/pester/powershell-coverage.xml`, ran PSScriptAnalyzer over all 26 changed PowerShell files (0 findings), and ran Black, Ruff, Pyright, four Python contract modules (70 passed), and the Codex generator `--check` (exit 0). Results are recorded in the policy audit.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`: CM-case1 (rooted POSIX case variant), CM-case2 (relative record with base root), CM-case3 (different name, negative).
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1`: B1 to B4 and B3b for `Get-WorktreeRunRecordBaseRoot`, including the empty `string[]` return through the comma operator; X1 updated to four exports.
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`: RE2b (three `features[]` deny rows) and RE5 (null checkpoint, blank target).
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1`: RP5 and RP6 drive the shipped epic checkpoint reader with `Test-Path` and `Get-Content` mocked, captured before the baseline mock replaces it by name; no file is read.
- `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1`: RC4 narrowed to `docs/features/`; RC5 and RA5 added.
- `evidence/regression-testing/expect-fail.2026-10-29T12-26.md`: 15 expected failures before the production change, matching the plan.
- `evidence/regression-testing/isolation.2026-10-29T13-11.md`: three seeded shuffles of 19 suites, 496 of 496 each; reversed-order Python run 52 of 52.

### Quality assessment prompts

- **Determinism:** POSIX literals and in-memory JSON only; `git` is never mocked or invoked; no temp files (`evidence/qa-gates/scope-check.2026-10-29T13-11.md` and reviewer diff review).
- **Isolation:** RP5 and RP6 use `Mock` in `It` scope, so the `Test-Path` and `Get-Content` mocks do not leak to other rows; seeded shuffles pass.
- **Speed:** all added rows are pure string or mocked-seam work.
- **Diagnostics:** `-Because` on CM-case1, B4, RC5, and RA5; deny-prefix assertions use `StartsWith`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | No new executable call in the remediation. |
| Input validation at boundaries | PASS | Blank target and null checkpoint return `$false` before lower-casing; unsafe relative records match nothing (M7, RR4, RP2, RE2, RE2b). |
| Error handling remains explicit | PASS | Fail-closed ordering and deny prefixes unchanged; the case-parity widening affects only the exclusion that blocks the manifest branch. |
| Configuration / path handling is safe | PASS | Manifest exclusion now symmetric with the manifest lookup; gates' allow lookups remain ordinal for POSIX. |
| Least privilege for the agent | PASS | `Agent(pr-author)` remains the only `pr-author` grant (Python contract test passes). |
| No host paths in committed artifacts | PASS | Added-line scan for host-path patterns: the only matches are the prior review artifacts quoting the scan patterns themselves. |

---

## Research Log

No external research was required. The review relied on the branch diff, the remediation plan and evidence, the prior review artifacts, and repository policy files.

---

## Verdict

The change is ready for the normal PR flow. The remediation resolves all four prior Minor findings without changing the gates' fail-closed allow semantics, removes the duplicated helper, and adds direct test coverage for each resolution. Every changed executable line is covered and no changed file is below its baseline. Before opening the pull request, bring the branch up to date with `origin/main` (three unrelated commits; clean merge). Merge remains subject to the S9 CI green gate on the final PR head.
