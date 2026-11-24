# Code Review: Release Exemption for the Checkpoint-Free Pull Request Path (#1231)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1231-pr-author-release-exemption/`
**Feature Folder Selection Rule:** named by the caller and matching issue #1231 and the branch name
**Base Branch:** `main` (merge base `3d905ca0bb80f12061f6ff7d3a0d79c0c53046bf`)
**Head Branch:** `feature/pr-author-release-exemption-1231` (head `a857d3f47`, PR #1232)
**Review Type:** Initial review

---

## Executive Summary

The branch adds three Claude-only allow-side legs that let a destination repository with a committed `.claude/release-commit-allowance.json` open a release pull request without an orchestration checkpoint. Leg 1 (`enforce-pr-author-skill.release.ps1`) exempts a structural `gh pr create` from the checkpoint preflight; Leg 2 (`enforce-model-routing-receipt-release.ps1`) admits `Agent(pr-author)`; Leg 3 (`enforce-orchestration-preimplementation-gate-release-receipt.ps1`) admits the `artifacts/pr_body_<N>.receipt.json` Write. A shared pure file (`hook-release-pull-request-context.ps1`) holds the config-state and path-decision predicates. Evidence reviewed: the full branch diff, the four new hook files in full, the diffs of the four edited hook files, the five new Pester suites (targeted reading), the executor QA evidence, the reviewer's own re-parse of `artifacts/pester/powershell-coverage.xml`, and a reviewer run of `Invoke-HarnessGeneration.ps1 -Check`.

**What changed:**
Four new hook files (108-177 lines each) and four edited hook files (dot-source, call, suffix, and header changes only), each mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; four new entries in `pack-manifests/core.json`; documentation changes to the orchestrator-state rule, execution-environment brief, pr-author skill, and pr-author agent made in their generator sources; five new Pester suites under `tests/scripts/claude-hooks/`.

The caller's explicit checks were verified as follows:

- Absent allowance file: each leg reads the file first through `Get-ReleasePullRequestConfigState`; `State = 'Absent'` returns before any git seam. Leg 1 returns `Reason = $null`, so `Get-PrAuthorPreflightExemption` returns the unchanged docs-only or cleanup result; Legs 2 and 3 return an empty suffix. Pester rows assert the exact pre-change deny text per gate and zero release-leg git calls (`enforce-pr-author-skill.Release.Tests.ps1:356`, `enforce-model-routing-receipt.Release.Tests.ps1:234`, receipt suite rows at lines 173 and 253).
- Leg 1 scope: `Test-CommandLineInvocation ... -SubcommandPath @('pr','create')` limits the leg to `gh pr create`; the branch must match an allowance (`Test-ReleaseAllowanceBranchMatch`); every diff path must be listed by one allowance (`Get-ReleasePullRequestPathDecision`, ordinal `-cnotcontains`, no combination across allowances).
- Mirrors: `cmp` of all 12 `.claude/` files and the two `.agents/skills/` files against their bundle copies reports all identical; `core.json` lists the four new hook files.
- Generated docs: the changes are in `scripts/harness-generation/sources/rules/orchestrator-state.md`, `scripts/harness-generation/sources/agents/pr-author.md`, and `.agents/skills/*/SKILL.md`; the generator `-Check` reports no drift.
- No Python: no new or changed hook file references `python` or `poetry`.
- D1: `enforce-epic-merge-gate.ps1` is not in the diff; spec Non-Goals, user-story Non-Goals, plan Decisions, and the orchestrator-state rule each state that merging is out of scope.

**Top 3 risks:**
1. Legs 1 and 2 compare local tracking refs and never fetch; a push from another clone can leave `refs/remotes/origin/<head>` stale. This is disclosed in the rule and spec, with `git push` immediately before `gh pr create` as the mitigation.
2. Leg 2 does not confirm that the prompt's `branch:` label equals the worktree's current branch; the diff it checks is `origin/<base>...HEAD` of the worktree. Paths remain bounded by the allowance, and Leg 1 re-checks the remote head at `gh pr create`, so the residual is limited to delegation admission (Minor M1).
3. Hooks in isolated subagents run the default branch's copy, so this behavior is proven only by Pester until merge; three CI job groups (poshqc, quality-checks7, shell-coverage) were pending at review time.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all acceptance criteria verified; pending CI jobs must complete green before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-model-routing-receipt-release.ps1` | lines 84-101 | Leg 2 matches the prompt's `branch:` label against the allowance patterns but does not compare it with the worktree's current branch; the diff it checks is computed from the worktree `HEAD`. A prompt naming a matching release branch from a worktree on another branch is admitted when that worktree's diff is entirely within the allowance. | Optional follow-up: compare the label with `Get-EpicScopeWorktreeHeadBranch` of R, as Leg 3 does. Not required by the spec, which mirrors the docs-estate delegation leg. | Admission is still bounded by allowed paths, and Leg 1 enforces the branch, remote head, and diff at `gh pr create`, so no unlisted path can reach a pull request through this gap. | Inspected file; spec Leg 2 "The remote-head comparison is not repeated at delegation" |
| Nit | `.claude/hooks/enforce-pr-author-skill.release.ps1`, `enforce-model-routing-receipt-release.ps1`, `enforce-orchestration-preimplementation-gate-release-receipt.ps1`, `hook-release-pull-request-context.ps1` | release.ps1:264; model-routing-release.ps1:90; receipt.ps1:214; context.ps1:99-102 | The branch-candidate filter (`Where-Object` over `BranchPatterns` with `Test-ReleaseAllowanceBranchMatch`) is written inline four times. | Optionally expose a `Get-ReleasePullRequestBranchCandidate` helper in the pure file and call it from each leg. | Small duplication across files that must stay in agreement. | Inspected files |
| Nit | `.dev/active/1231-pr-author-release-exemption/spec.md` | Implementation Strategy, AC-17 | The spec names `scripts/harness-generation/sources/agents/pr-author.json` as the agent source; the precondition paragraph lives in `sources/agents/pr-author.md`, which the plan Decisions section records and which the branch edits. | None required; the plan documents the correction and the generator reports no drift. | Spec text and delivered source differ by file name only. | `plan.2026-11-23T17-58.md` Decisions; `git diff` of `sources/agents/pr-author.md` |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | whole file | 501 logical lines, at the 500-line guidance tier. | None; below the 700-line advisory tier. | Recorded for visibility; the spec anticipated this size. | `@(Get-Content -LiteralPath ...).Count` = 501 |

No Blockers or Major findings. No covered file is at or above 700 lines, so no file-size Warning row applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The allowance read happens first in every leg, so the absent-file path makes no git call and leaves deny text unchanged; this is pinned by exact-string rows.
- The #1201 parser (`ConvertFrom-ReleaseAllowanceConfig`), branch matcher (`Test-ReleaseAllowanceBranchMatch`), and file seams are reused through injected scriptblocks; no new JSON parser or wildcard matcher is defined.
- Leg 1's `--head` parsing rejects `--head=`, single-dash tokens containing `H`, repeated `--head`, missing values, `owner:branch` (by the branch regex), and `..`; base parsing reuses `Get-PrAuthorDocsOnlyBaseName`, which rejects `-R`, `--repo`, and `GH_REPO=`.
- Path matching is ordinal and case-sensitive (`-cnotcontains`), and the first matching allowance that lists every path wins without combining allowances.
- Diff output is required to be NUL-terminated and is parsed by the existing `ConvertFrom-DocsOnlyNameList`; commit hashes are validated against a 40- or 64-hex pattern before use in the diff argument.
- The wiring change in `Get-PrAuthorPreflightExemption` preserves the previous result object when the release reason is `$null`, which keeps the docs-only and cleanup deny text identical.

#### API and safety notes

- Every function has `[CmdletBinding()]` and `[OutputType()]`; verbs are `Get-` and `Test-` only.
- Script-scope state is limited to constant regex patterns prefixed `ReleasePullRequest`.
- git runs only through the existing bounded wrappers (`Invoke-PrAuthorDocsOnlyGitExe`, `Invoke-DocsOnlyGitExe`) with fixed argument arrays; no `Invoke-Expression`.

#### Error handling and logging

- Each leg wraps its body in one `try/catch`; the catch writes a `Write-Debug` record with a leg-specific code and declines, so the gate's deny stands (fail closed), as the spec requires.
- Dot-sources use the guarded `Add-HookDependencyFailure` pattern of the sibling legs.

---

## Test Quality Audit

The five new suites cover every allow row and every sub-code row named in AC-01 to AC-11, using synthetic roots and mocked seams. The executor's final Pester gate passed (29270 passed, 0 failed), and the reviewer's re-parse of the coverage artifact confirmed 100% line coverage for each new hook file.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-pr-author-skill.Release.Tests.ps1` — 22 rows: every `RELEASE_EXEMPTION_*` code, head and base token variants, suffix ordering, epic and docs-only precedence, AC-10 exact text with zero release git calls.
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.Release.Tests.ps1` — 14 rows: every `RELEASE_DELEGATION_*` code, suffix order after the docs-estate suffix, AC-10 exact text with `Invoke-DocsOnlyGitExe -Times 0`.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1` — 14 rows: allow (relative and absolute), every `RELEASE_RECEIPT_*` code, non-receipt and nested path declines, absent file with zero further seam calls (unit) and exact pre-change text (decision level).
- `tests/scripts/claude-hooks/hook-release-pull-request-context.Tests.ps1` — 16 rows for the pure predicates, including the case-sensitivity and no-combination rows.
- `tests/scripts/claude-hooks/release-pull-request.Parity.Tests.ps1` — 6 rows: copy parity, manifest listing, and final deny-line ordering.
- `.dev/active/1231-pr-author-release-exemption/evidence/qa-gates/coverage-delta.2026-11-24T01-13.md` — per-file baseline and post-change figures; matches the reviewer re-parse.

### Quality assessment prompts

- **Determinism:** no clock, network, process, or real worktree; all I/O seams mocked.
- **Isolation:** one behavior per row; fixtures re-registered in `BeforeEach`.
- **Speed:** 1-2 s per suite as recorded in task-check evidence.
- **Diagnostics:** decision rows pass the full reason text to `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token text in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | git only through existing wrappers with argument arrays; branch and commit values validated by regex before use. |
| Input validation at boundaries | ✅ PASS | `--head` value regex with `..` rejection; base via `Get-PrAuthorDocsOnlyBaseName`; receipt path exact-match regex beneath R; allowance directory entries rejected. |
| Error handling remains explicit | ✅ PASS | Named sub-codes for every failure; unexpected errors decline with `Write-Debug`. |
| Configuration / path handling is safe | ✅ PASS | The allowance file is destination-owned; no copy exists in the repository, the bundles, or any pack manifest (`git ls-files` search empty). |

---

## Research Log

No external research was required. The design is covered by `research/research.2026-11-23T23-00.md` and the spec.

---

## Verdict

The change is ready for the normal PR flow. The implementation follows the spec's evaluation order for each leg, reuses the #1201 parser and seams, leaves deny text unchanged where no allowance file exists, is mirrored byte-identically, and is fully covered by targeted Pester suites. The one Minor finding (Leg 2 does not bind the `branch:` label to the worktree branch) is consistent with the spec and the existing docs-estate delegation leg and is backstopped by Leg 1; it does not block merge.

Merge should wait for the pending poshqc, quality-checks7, and shell-coverage CI jobs on PR #1232 to complete green.
