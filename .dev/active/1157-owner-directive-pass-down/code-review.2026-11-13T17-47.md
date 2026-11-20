# Code Review: Owner-Directive Pass-Down to Executing Agents (Issue #1157)

**Review Date:** 2026-11-13
**Branch:** `feature/owner-directive-pass-down-1157` @ `aac741a5896fb65e7dcc7bbabe8776e5d200d6a7` (PR #1171, open)
**Base:** `main`; merge base `18520b3fce8b6273ac63a16fef03816f7119dcad` (the PR #1170 merge; base unmoved at review time)
**Scope:** full branch diff, 198 files. This re-audit reads in full the delta since the prior PASS head `b632f1759`: three cycle-2 lockfile commits, the merge commit `be38f27de` and its two-file conflict resolution, and 54 added feature-folder files. It also re-checks the branch's own contribution for changes introduced by the merge.

## Executive Summary

Cycle 2 resolves C1 to C3 (moderate `hono` and `@hono/node-server` advisories in the three npm manifests), and the merge of `origin/main` leaves the item's own content unchanged.

- Lockfiles: the head's three `package-lock.json` files are byte-identical to `origin/main`. The branch's pushed cycle-2 fix (`73533f6ea`) was already byte-identical to main's lockfiles, so the merge resolved cleanly to them, as OD-18 requires. The branch diff holds no npm manifest or lockfile.
- Merge resolution: `.claude/rules/orchestrator-state.md` and its bundle copy keep this item's owner-directive pass-down bullet followed by main's `Restored-host note (#1163)` bullet. They have no conflict marker and are byte-identical.
- Merge neutrality: for each of the 72 non-feature-folder paths, the branch's added and removed lines against `18520b3fc` equal those against `1d62aa292` at `b632f1759`.

No blocking finding. One non-blocking item is added (CR6). CR1 to CR5 carry over unchanged.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (C1) | `package-lock.json` | root manifest | Lockfile equals `origin/main`, which carries the non-breaking `hono` and `@hono/node-server` update; local audit at moderate exits 0. | None. | The gate failure on PR #1171 had an external origin, and main's fix now covers it. | Reviewer `git diff origin/main HEAD` (empty); `evidence/qa-gates/npm-audit-final.2026-11-13T17-14.md`; PR #1170 `npm-audit / npm audit (.)` pass |
| Resolved (C2) | `extensions/drm-copilot/package-lock.json` | extension manifest | Same as C1; `deepmerge` remains a low finding below the moderate gate. | None. | As C1. | As C1; PR #1170 `npm-audit / npm audit (extensions/drm-copilot)` pass |
| Resolved (C3) | `packages/mcp-server/package-lock.json` | MCP server manifest | Same as C1; 0 vulnerabilities locally. | None. | As C1. | As C1; PR #1170 `npm-audit / npm audit (packages/mcp-server)` pass |
| Minor (CR1) | `.claude/hooks/enforce-owner-directive-pass-down.ps1` | `Resolve-OwnerDirectivePassDownAck` | Per-call resolution cost for acknowledgement-set agents, disclosed in the spec. Unchanged. | No change in this item; #1159 should measure this hook. | Carried over. | Spec `## Known Limitations` |
| Minor (CR2) | branch history | commit `a4e992584` | The main implementation commit carries a pause subject. Unchanged. | Describe the content in the PR body or squash-merge. | `git log` and blame read better with a descriptive subject. | `git show --stat a4e992584` |
| Info (CR3) | `evidence/baseline/pester-baseline.2026-11-10T04-02.md` | Phase 0 baseline | The Phase 0 Pester run overlapped a module write of this item. Unchanged. | None. | Recorded so the baseline is not cited as clean pre-change evidence. | The artifact's own failure note |
| Minor (CR4) | `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` | `Get-OrchestratorOutputOwnerPassDownSourceText`, self-equal rule | A source ordinally equal to the checkpoint text is treated as absent. Unchanged. | No change in this item; replace path-agnostic mocks with path-keyed ones if a later item touches those suites. | Narrow, documented effect. | Helper source at head |
| Info (CR5) | `evidence/qa-gates/phase-gate.P1.2026-11-13T15-34.md` | correction bullet | Cites `task-check.P1-T7.2026-11-13T14-57.md`; the committed file is `...T14-58.md`. Unchanged. | None; evidence is append-only. | Keeps the citation chain traceable. | `ls evidence/other/task-check.P1-T7.*` |
| Info (CR6) | `evidence/qa-gates/pytest-final.2026-11-13T17-40.md`; `evidence/qa-gates/npm-audit-final.2026-11-13T17-14.md` | branch-coverage figure; `Timestamp:` field | The pytest artifact records branch coverage 94.37% for BRH 12669 of BRF 13424, which is 94.376% and rounds to 94.38%. The prior gate had BRH 12668, which is 94.37%. The npm audit artifact's file name stamp is `17-14` and its `Timestamp:` field is `2026-11-13T17-13`. Neither changes a verdict, and both figures clear their thresholds by a wide margin. | None; evidence is append-only (OD-6). Future artifacts should round to two places and use one clock read for both the stamp and the field. | Records the correct figures here instead of editing evidence. | Reviewer parse of `artifacts/python/lcov.info`; artifact header |

No covered file in the diff is at or above 700 logical lines (largest: `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, 536), so no file-size Warning row applies, and `config/file-size-baseline.json` is not in the diff.

## Detailed Review

### Lockfiles and OD-18

OD-18 permits a pushed own fix only when merging main resolves cleanly to main's lockfiles. `git diff 73533f6ea 18520b3fc` over the three lockfiles is empty, so the branch's fix and main's fix are the same bytes. The merge recorded no conflict on them (`main-sync.2026-11-13T17-23.md` lists only the two rule copies), and `git diff origin/main HEAD` over them is empty. The branch's lockfile commits remain in history but contribute no net change against `main`, and no `package.json` changed. The PR #1170 checks for all three `npm-audit` manifests passed on lockfiles identical to `18520b3fc`.

### Merge resolution

The resolved rule keeps the full branch hunk set: the B and R clock clarification, the `Coordinator ledger and pass-down (issue #1157)` paragraph, and the pass-down Known-limitations bullet. Main's `Restored-host note (#1163)` bullet follows that bullet. The resolution text drops no line from either side. The bundle copy is byte-identical (`cmp`).

Auto-merged shared files: the six execution-environment brief copies share one SHA-256. `validate-orchestrator-output.TargetWorktree.Tests.ps1` holds both sides' rows and passes 18/0. `pack-manifests/core.json` keeps both sides' entries, and manifest completeness and dependency closure pass in the post-merge pytest gate.

### Interaction with main's #1163 change

PR #1170 changed SubagentStop hooks and added `AgentTargetWorktree.psm1`. This item's hooks are PreToolUse (`enforce-owner-directive-pass-down.ps1`) and a stop-hook sibling loaded by `validate-orchestrator-output.ps1`, which main did not change. The merged-tree Pester gate runs both sides' suites in one parallel run with 0 failures (`AgentTargetWorktree` 77/0, `validate-orchestrator-output-target` 31/0, item suites unchanged counts).

### Coverage of changed lines

The merge changed no line of the seven production files. The reviewer parse of the post-merge JaCoCo file gives the same per-file figures as the cycle-1 review, and every figure meets its threshold.

## Verification Performed

- `git -C <item worktree> log b632f1759..HEAD` and per-path comparison of the branch's added and removed lines across the two merge bases (72 paths, all identical).
- `git diff` of the three lockfiles against `origin/main` and between `73533f6ea` and `18520b3fc` (both empty).
- Read of the merge-resolved `orchestrator-state.md` hunks; `cmp` against the bundle copy; marker count 0.
- SHA-256 of the six execution-environment brief copies (one value).
- Parse of `artifacts/pester/powershell-coverage.xml` (root and seven production files) and of `artifacts/python/lcov.info`; modification times against the merge commit.
- Logical line counts of every covered file in the diff.
- `check_quality_tiers.py` and `validate_evidence_locations.py` against the item worktree: both clean.
- `git fetch origin main` and `git merge-tree --write-tree origin/main HEAD`: no drift, no conflict.
- `gh pr checks 1171` (pending at the head) and `gh pr checks 1170` (all three `npm-audit` checks pass).

The owner's parallel-only rule forbids single-file Pester runs, so no reviewer mutant runs were made. No production logic changed since the prior review, in which test discrimination was assessed.

## Verdict

**PASS.** Zero blocking findings. C1 to C3 are resolved on the branch, and CI confirmation on the PR head is pending CI. CR1 to CR6 are non-blocking.
