# Code Review: Preimplementation gate demands a checkpoint for a merged-feature follow-up (#1141)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141`
**Feature Folder Selection Rule:** Named by the caller; `issue.md` records issue #1141 and `- Work Mode: full-bug`.
**Base Branch:** `main` (merge base `5c81af727d0c4c85b893d6542356c47123454117`, equal to `origin/main` after `git fetch origin main`)
**Head Branch:** `bug/preimpl-gate-merged-feature-followup` (`d5961781e56f83046f76b7ab4d131ef8cb498d44`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds a merged-feature follow-up allowance to the epic scope of the preimplementation gate on the Claude and Codex surfaces. In `Get-OrchestrationEpicScopeDecision` of each surface, a second allow-only disjunct runs only when the readiness failure is exactly `merge-in-progress` (`-ceq`) and returns `''` when `Get-EpicMergedFeatureFollowUpAllowance` admits the call; every other path returns the unchanged failure, so no deny text is produced by new code. The allowance lives in `hook-epic-fan-in.ps1` (four byte-identical copies) and reuses the #1136 command-leg parser through two optional predicate parameters instead of duplicating it. Diff scope: 43 paths, 2155 insertions, 103 deletions against the merge base; the merge commit `d5961781e` brought only #1138 content, which is outside the merge-base range.

**What changed:**
`Get-EpicFanInShapeDetail`, `Test-EpicFanInCommitShape`, `Test-EpicFanInStagedIndex`, and `Get-EpicFanInAllowance` gained an optional predicate; with no predicate they keep the #1136 status-document equality. New `Get-EpicMergedFeatureRoots` derives `docs/features/active/<basename>/` and `docs/features/completed/<basename>/` only from epic-checkpoint `features[]` entries with a terminal `merge_status`, a plain slug, a 40- or 64-character lowercase-hex `merge_commit_sha`, and an integer `pr_number` above 0. New `Test-EpicMergedFeaturePath` refuses blanks, backslashes, glob characters, leading `/`, and `.`/`..` segments, and requires a non-empty remainder after a trailing-slash root. The epic-orchestrate and orchestrate skills (`.claude`, `.agents`, bundles) and the six execution-environment brief copies document the path; the frozen-surface pin was re-baselined.

**Top 3 risks:**
1. The epic checkpoint remains writable by a same-session agent, and provenance is format-checked rather than verified against git (a fabricated entry with a well-formed SHA and PR number qualifies). The spec records this as a policy-level control, the same trust source as #1136.
2. The follow-up predicate reads `$mergedFeatureRoots` through PowerShell dynamic scope. If the call chain changes (for example the allowance moves into a module), the roots resolve to `$null` and the allowance fails closed; it cannot widen.
3. `git mv` and `git rm` are not modelled, so moving a merged feature's folder from `active/` to `completed/` stays denied in epic scope before fan-in. This matches the spec's command list and keeps the allowance narrow.

**PR readiness recommendation:** **Go** - no Blocker, Major, or Minor finding; the gate is not weakened beyond the specified allowance, previously admitted calls stay admitted, and all parity and coverage checks hold at the reviewed head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/hook-epic-fan-in.ps1` (and three byte-identical copies) | lines 480-484 | The follow-up predicate reads `$mergedFeatureRoots` through the dynamic scope chain; an inline comment documents it. | None required. A future refactor that moves the allowance into a module should pass the roots explicitly. | A broken lookup yields `$null` roots, and `Test-EpicMergedFeaturePath` then refuses every path, so the failure mode is a deny. | Code inspection; reviewer in-process probe (17 command rows and 7 path rows behaved as specified) |
| Info | `.claude/hooks/hook-epic-fan-in.ps1` | lines 216, 225, 295 | In default (#1136) mode the generalized predicates accept repeated status-document operands or staged names (`git add <doc> <doc>`), where #1136 required exactly one. | None. | Strict superset of the #1136 admissions on the same single path; no new path is reachable. The executor's self-review records the same observation. | `git diff 5c81af727...HEAD -- .claude/hooks/hook-epic-fan-in.ps1` |
| Info | `.claude/hooks/hook-epic-fan-in.ps1` | line 372 | The diagnostic `Detail` string `staged index is not exactly the status document` is now also returned in follow-up mode, where it is inaccurate. | Optional wording change in a later edit (`staged index is not within the allowed paths`). | `Detail` is not part of any deny text; the hook's deny reason comes from the unchanged readiness failure. | Code inspection |
| Info | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1` | `Context 'denies'` | Codex deny rows assert `.Contains("'merge-in-progress'")` rather than the exact deny text; the Claude rows assert `-BeExactly`. | None required. | The Codex deny text is produced by `Resolve-OrchestrationEpicTargetOutcome`, which the branch does not change; the new disjunct can only return `''`. Existing Codex epic-scope suites pass unchanged. | `git diff --numstat 5c81af727...HEAD -- tests/` (no existing test file modified); reviewer Pester run |
| Info | `.claude/skills/epic-orchestrate/SKILL.md` | `**Merged-feature follow-up allowance (issue #1141).**` | The provenance fields are validated by shape only; the skill states that the merge-mirror step records `pr_number` and `merge_commit_sha`, which the spec reports as verified on a real epic checkpoint. | None. | Spec-accepted residual risk ("A same-session writer can edit the epic checkpoint"). | `spec.md` Residual Risks |

No Blockers, Major, or Minor findings. No covered file reaches 700 logical lines (largest: `hook-epic-fan-in.ps1` 488 in each of four copies; `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` 473; Python pin module 466), so no file-size Warning applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- Only `PINNED_FROZEN_SURFACE_HASHES` and its comment block changed in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. The new skill digest `e227db65...` equals `git show HEAD:.claude/skills/epic-orchestrate/SKILL.md | sha256sum`; the agent digest `5ff9c66f...` equals the head blob of `.claude/agents/epic-orchestrator.md`.

#### Typing and API notes
- No typed code changed.

#### Error handling and logging
- Not applicable.

### PowerShell implementation audit (if applicable)

#### What changed well
- Reuse without duplication: the follow-up allowance calls `Get-EpicFanInAllowance` with `-PathPredicate` and `-OperandPredicate`, so command splitting, the unresolvable-character check, tokenization, the commit option table, and the staged-index read are shared with #1136.
- The disjunct is allow-only and guarded by `$failure -ceq 'merge-in-progress'` on both surfaces (Claude line 389, Codex line 449); every other failure returns unchanged.
- Qualification is fail-closed: the SHA must be a `[string]` matching `^([0-9a-f]{40}|[0-9a-f]{64})\z`; `pr_number` must be `[int]` or `[long]` and above 0, which rejects strings, doubles, booleans, and null.
- Roots carry a trailing slash and a non-empty remainder is required, which blocks sibling-prefix folders and the bare root; the status document is admitted only by equality.
- No per-item checkpoint is read: the new functions read only `$Scope.Checkpoint`, `$Scope.Branch`, and `$Scope.WorktreeRoot`, and the unit suite's AST scan finds no `Get-Content`, `Test-Path`, `ReadAllText`, or `orchestrator-state.json` in the file.

#### API and safety notes
- New parameters are optional with `$null` defaults; existing callers (`Get-EpicFanInAllowance` from the #1136 disjunct and the #1136 tests) are unchanged and their suites pass.
- Reviewer in-process probe of `Get-EpicMergedFeatureFollowUpAllowance` against a synthetic scope: denied `>` redirection, unquoted `$(...)`, `git add -- -A`, a trailing `--`, a pathspec without `--`, `:(top)` magic, `&& rm`, `git -c ... commit`, `--amend`, a non-qualifying feature, `git mv`, `git rm`, a `..` traversal path, and an absolute path outside the worktree root; admitted the specified add, commit, and path forms. A single-quoted `$(...)` operand is admitted as a literal filename under the root, which the shell does not expand.
- Codex apply_patch legs include `*** Move to` destinations in the leg paths (`Get-OrchestrationPatchMarkerPath`), so a move out of an allowed root is evaluated against the destination and denied.

#### Error handling and logging
- Both allowance functions wrap their bodies in `try`/`catch` and answer `Allowed = $false` with an `allowance error:` detail; unit rows cover a throwing reader and an unreadable `route_id`.

### TypeScript implementation audit (if applicable)

N/A. No TypeScript file changed.

### C# implementation audit (if applicable)

N/A. No C# file changed.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` (+191, -0; runs per surface copy).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1` (new, 296 lines).
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1` (new, 186 lines).
- `evidence/regression-testing/fail-before.2026-11-08T19-39.md`, `evidence/qa-gates/pester-final.2026-11-08T20-03.md`, `evidence/qa-gates/pytest-final.2026-11-08T20-06.md`, `evidence/qa-gates/powershell-static.2026-11-08T19-53.md`, `evidence/qa-gates/python-static.2026-11-08T19-53.md`, `evidence/other/codex-generator-check.2026-11-08T19-52.md`.
- Reviewer runs at the reviewed head: full `Invoke-PoshQCParallelTest` (ExitCode 0, 8 workers, 609.83 s; JUnit tests=20484, failures=0, errors=0, disabled=10; repo-wide 95.67% lines, 36347 of 37991), `pytest -n auto` over seven contract modules (105 passed), `generate_codex_agent_variants --check` (exit 0), `validate_evidence_locations.py --root .` (exit 0).

### Quality assessment prompts
- Discrimination: the fail-before run shows all 18 allow rows (11 Claude, 7 Codex) denied with `merge-in-progress` on the unmodified hooks, while every deny row passed both before and after, so the allow rows fail without the fix.
- Each qualification conjunct has a pass and a fail row, including uppercase hex, lengths 39/41/63, non-string SHA, string/0/-1/null/7.5/`$true`/absent `pr_number`.
- No existing test file was modified (`git diff --numstat` shows only additions to `hook-epic-fan-in.Tests.ps1`), so the #1136 EpicFanIn and #539 CommandExemption suites pass unchanged.
- Tests use mocked resolver and staged-index seams, synthetic `/synthetic-worktrees/` roots, and no temporary files.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection |
| No unsafe subprocess or command construction | PASS | The allowance starts no process; the staged index is read through the existing injected `Get-OrchestrationGateStagedIndex` seam |
| Input validation at boundaries | PASS | Path refusals in `Test-EpicMergedFeaturePath`; the command text passes the existing unresolvable-character check before tokenization; reviewer probe |
| Error handling remains explicit | PASS | `try`/`catch` answering not allowed; deny path unchanged |
| Configuration / path handling is safe | PASS | Trailing-slash roots, ordinal case-sensitive comparison, absolute paths converted through `Get-HookTargetWorktreeRelativePath` and refused outside the worktree root |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md`, `research/research.2026-11-08T19-00.md`, `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (command splitting and unresolvable-character rules), and `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (apply_patch marker parsing).

---

## Verdict

PASS. No blocking finding. The allowance is bounded to qualifying merged features whose provenance comes only from the epic checkpoint, previously admitted calls stay admitted, deny texts are unchanged, and the four `hook-epic-fan-in.ps1` copies, the epic-scope bundle copies, the skills, and the brief copies are in parity.
