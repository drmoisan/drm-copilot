# Code Review: Release Merge Leg of the Epic Merge Gates (#1234)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1234-merge-gate-release-exemption/`
**Feature Folder Selection Rule:** named by the caller and matching issue #1234 and the branch name
**Base Branch:** `main` (merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560`)
**Head Branch:** `feature/merge-gate-release-exemption-1234` (head `134a59879`, PR #1236)
**Review Type:** Initial review

---

## Executive Summary

The branch adds `enforce-epic-merge-gate-release.ps1`, a fail-closed release merge leg that both epic merge gates call in their explicit-number block after the docs-only branch declines and before the final deny. With a destination-owned `.claude/release-commit-allowance.json`, the leg admits a checkpoint-free `gh pr merge <N> --merge|--squash|--rebase --match-head-commit <sha>` when one bounded `gh pr view` shows an open, same-repository pull request whose live head equals the pinned SHA and whose head branch and every changed path belong to one allowance, and when the newest `CI` run on that head is a completed, successful `pull_request` run. Evidence reviewed: the full branch diff, the leg file in full, the gate diffs, the five new Pester suites (targeted reading), the executor QA evidence including the authoritative self-review `evidence/qa-gates/self-review.2026-11-24T09-49.md`, the reviewer's re-parse of `artifacts/pester/powershell-coverage.xml`, SHA-256 comparison of every mirror, and a reviewer run of `Invoke-HarnessGeneration.ps1 -Check`.

**What changed:**
One new leg file (303 lines) in `.claude/hooks/` and `.codex/hooks/`; a Codex copy of `hook-release-pull-request-context.ps1`; a `.NOTES`-only change to the Claude pure file; one guarded dot-source, one call line, and one suffix term in each gate; bundle copies of each, all byte-identical; three new `core.json` entries; documentation in the orchestrator-state rule source and two `.agents/skills/` sources, regenerated; five new Pester suites and two extended list-based suites.

Specific checks performed:

- Absent allowance file: the leg reads the allowance before any process call (`Get-ReleasePullRequestConfigState`, line 244) and returns an empty suffix on `Absent` (line 245); the gates append `$release.Suffix`, which is then empty. Decision rows in both gates assert the exact pre-change deny string and the unchanged `Invoke-DocsOnlyGhExe` and `Invoke-DocsOnlyGitExe` counts.
- Head pinning: `--match-head-commit` must be a 40- or 64-character lowercase object id (`Test-EpicMergeGateChildCiObjectId`) and equal the live `headRefOid` ordinally (line 275). The CI run list is read for the live head, not for the command value.
- Changed-file completeness: `changedFiles` must be at most 100 and equal the listed `files` count; `RENAMED` and `COPIED` are refused because the GraphQL node lists no source path.
- Codex wiring: every call-time dependency (`hook-docs-only-diff.ps1`, `hook-command-invocation.ps1`, `enforce-epic-merge-gate-child-ci.ps1`, `enforce-orchestration-preimplementation-gate-release.ps1`, `hook-release-allowance-context.ps1`) exists in `.codex/hooks/` and is loaded before the leg.
- One-file pull requests: `Get-EpicMergeGateChildCiProperty` returns `, $property.Value`, so a one-element `files` array stays an array and passes the step 6 `[System.Array]` check; both decision-level allow rows use a one-file pull request.
- No Python: no new or changed hook file contains `python` or `poetry`; the parity suite asserts this per copy.

**Top 3 risks:**
1. The leg is a policy-level control: whoever can commit the allowance file decides which paths merge without a checkpoint. This is disclosed in the leg header, the orchestrator-state rule, and the spec.
2. The workflow name `CI` is an assumption shared with #1130; a destination with a differently named workflow denies with `RELEASE_MERGE_CI_MISSING` (fail closed, disclosed).
3. Isolated subagents run the default branch's hook copies, so branch behavior is proven by Pester until merge; the poshqc, quality-checks7, and shell-coverage CI jobs were in progress at review time.

**PR readiness recommendation:** **Go**. No Blocker or Major finding; all acceptance criteria verified; the in-progress CI jobs must complete green before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `.claude/hooks/enforce-epic-merge-gate-release.ps1` (and its three copies) | lines 43-44 (`.NOTES`) | The header states "one gh run list for steps 13 to 16"; the spec (Data & State) and AC-19 state that the run list is also read for the allow outcome (steps 13-17). | Optional: change "13 to 16" to "13 to 17" in a later change to the leg, re-mirroring all four copies. | Comment accuracy only; behavior matches the spec and AC-19 rows assert one run-list call for the allow row. | Inspected file; `enforce-epic-merge-gate-release.Ci.Tests.ps1` row `makes one pr view call and one run list call for the allow row` |
| Info | `.claude/hooks/enforce-epic-merge-gate.ps1` | whole file | 500 logical lines, at the 500-line cap that `session-root-reads-850.Constraints.Tests.ps1` sets for this file. | None for this change; any later addition to this gate needs a sibling file or a header reduction. | Recorded for visibility; the spec anticipated this and the constraint test passed. | `awk 'END{print NR}'` = 500; `evidence/qa-gates/contract-scope.2026-11-24T09-47.md` |
| Info | `.dev/active/1234-merge-gate-release-exemption/evidence/` | `other/evidence-timestamp-disclosure.2026-11-24T09-49.md` | Several evidence filename stamps were taken from a clock read made shortly before the write rather than immediately before it; two were typed. The executor disclosed this append-only and left the files unchanged. | None; the disclosure names the corrective practice (read the clock in the writing command). | The lexicographically greatest artifact of each kind is still the intended one; no evidence was altered or deleted. | Disclosure file; three `self-review.*.md` files kept unchanged |

No Blockers or Major findings. No covered file is at or above 700 lines, so no file-size Warning row applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The evaluation order follows the spec step by step, and every failure after step 1 maps to one named `RELEASE_MERGE_*` code, with only the first failing step reported.
- The leg defines no allowance parser, wildcard matcher, command tokenizer, process invoker, or run selector; it reuses the #1201, #1231, docs-only, and child-CI helpers (AC-26, AC-27).
- Process calls are bounded: none for steps 1-5, one `gh pr view` for steps 6-12, and one `gh run list` thereafter, all through `Invoke-DocsOnlyGhExe` with fixed argument arrays.
- The gate change is minimal: one guarded dot-source, one call line, and one suffix term per gate, so earlier branches keep their order and outcome.
- `gh pr view` output is parsed with `-NoEnumerate`, and every field the leg relies on is type-checked before use (object id, branch-name pattern with `..` rejection, JSON boolean, JSON integer, JSON array).

#### API and safety notes

- Every function has `[CmdletBinding()]` and `[OutputType()]`; verbs are `Get-` only.
- No script-scope or global state; seams are injected through `ConfigReader` and `ContainerProbe` with production defaults.
- Comparisons are ordinal and case-sensitive (`-ceq`, `-cne`, `-cnotcontains`, `[string]::Equals(..., Ordinal)`).

#### Error handling and logging

- One whole-body `try/catch` returns `Allowed = $false` with an empty suffix and writes `EPIC_MERGE_GATE_RELEASE_LEG_ERROR` through `Write-Debug`, so the gate's deny stands (fail closed).
- Both dot-sources use the guarded `Add-HookDependencyFailure` form, so a missing dependency surfaces through the existing dependency guard rather than an unhandled error.

---

## Test Quality Audit

The five new suites cover every allow row and every sub-code row named in AC-01 to AC-25, using synthetic roots and mocked seams; the unit suites run against both tree copies through `-ForEach` over the trees. The executor's final Pester gate passed (29483 tests, 0 failures), and the reviewer's re-parse confirmed 95/95 lines for each leg copy.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Tests.ps1`: steps 1-12, including 9 `PR_UNRESOLVED` data rows, the exact `gh pr view` argument list, the 100/101 boundary, and the no-combination row.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Ci.Tests.ps1`: steps 13-17, allow per merge method, the `--commit` binding to the live head, the newest-run event rule over an older green `pull_request` run, first-failure-only, the three call-count bands, and the caught error.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1`: decision-level rows for AC-01/AC-02, AC-05, AC-21/AC-22, AC-23, AC-24, and AC-25.
- `tests/scripts/claude-hooks/release-merge.Parity.Tests.ps1`: copy parity, function set, manifest listing, and the no-Python token check.
- `.dev/active/1234-merge-gate-release-exemption/evidence/qa-gates/coverage-delta.2026-11-24T09-38.md`: per-file baseline and post-change figures; matches the reviewer re-parse.

### Quality assessment prompts

- **Determinism:** no clock, network, process, or real worktree; fixed run timestamps in fixtures.
- **Isolation:** one behavior per row; fixtures re-registered in `BeforeEach`; the discovery-guard baseline mocks are registered as the guard requires.
- **Speed:** no waits; process seams mocked.
- **Diagnostics:** allow rows pass the suffix or reason to `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token text in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | `gh` runs only through `Invoke-DocsOnlyGhExe` with argument arrays; no string-built command or `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Command shape via `Get-DocsOnlyMergeShapeViolation` plus an explicit `--admin` refusal; head value regex; every `gh pr view` field type-checked; branch names restricted to a conservative pattern without `..`. |
| Error handling remains explicit | ✅ PASS | Named sub-codes for every failure; unexpected errors decline with `Write-Debug`. |
| Configuration / path handling is safe | ✅ PASS | The allowance is read only through the existing seams; no path is built from `gh` output; no `release-commit-allowance.json` exists in the repository, bundles, or manifests (`git ls-files` count 0). |

---

## Research Log

No external research was required. The design is covered by `research/research.2026-11-24T04-03.md` and the spec.

---

## Verdict

The change is ready for the normal PR flow. The leg follows the spec's evaluation order, reuses the existing parsers and seams, leaves deny text and process calls unchanged where no allowance file exists, is byte-identical across both trees and both bundles, and is fully covered by targeted Pester suites. The findings are one comment-accuracy Nit and two Info items; none blocks merge.

Merge should wait for the in-progress poshqc, quality-checks7, and shell-coverage CI jobs on PR #1236 to complete green at head `134a59879`.
