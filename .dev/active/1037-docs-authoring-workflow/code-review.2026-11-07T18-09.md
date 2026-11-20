# Code Review: Documentation Authoring Workflow (#1037)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-authoring-workflow-1037`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `098b6edfe89b4c2d8a2095718b538d1edbeabf10`, re-fetched; the merge base with HEAD is the tip)
**Head Branch:** `feature/docs-authoring-workflow-1037-r2` at `20a37a7246d68b5869b77650efa185a1dc85eb9e`
**Review Type:** Re-audit at the exit of remediation cycle 1 (prior review `code-review.2026-11-07T17-30.md`)

---

## Executive Summary

The cycle merged the integration tip, resolved the Claude core manifest conflict by keeping both lines, replaced the exact dispatch-row count with a membership check, and re-ran every gate at the merged head. Evidence reviewed: the regenerated PR context, the cycle commits, the full branch diff from the new merge base, the cycle evidence, a fresh `git merge-tree` against a re-fetched tip, a coverage re-parse, reviewer analyzer and formatter runs, byte-identity checks over 64 bundle pairs, and seven real-process hook probes at HEAD.

**What changed in this cycle:**
One merge commit (`bfe9488d0`) with one resolved manifest hunk; one test assertion in `docs-authoring-roles.Skills.Tests.ps1` (`9c9225bf0`); evidence and plan documents. No production PowerShell, settings or routing file changed in the cycle.

**Top 3 risks:**
1. The write-scope hook depends on `agent_type` in PreToolUse payloads for project subagents. The research cites the Claude Code hooks reference and the precedent hook `enforce-epic-invocation-origin.ps1`; no live subagent run on this branch confirms it, by specification.
2. Codex and Copilot copies of `docs-author` hold write tools without any write-scope hook (owner question OQ-2, provisional default).
3. CI has not run; the branch has no pull request yet. Spec AC 17 and user-story AC 11 depend on it.

**PR readiness recommendation:** **Go.** No blocking finding remains. Spec AC 9, spec AC 11 and user-story AC 7 carry the accepted N4 deviation and stay unchecked.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Hook entries after `enforce-docs-complete-gate-target.ps1` | Prior PA-1 is resolved. A fresh fetch shows the tip at `098b6edfe`, HEAD 0 commits behind, and `git merge-tree --write-tree` exits 0 with no conflicted path. Both the branch line and the base's `enforce-epic-merge-gate-review.ps1` line are present, in ascending order. | No action. | The pull request can receive CI. | Policy audit `## Base Synchronization`; `evidence/other/merge-result.2026-11-07T17-46.md`. |
| Info | `spec.md`, `user-story.md` | Spec AC 9, spec AC 11, user-story AC 7 | Prior PA-2 is an accepted deviation under main plan note N4 (option b), per the orchestrator disposition. The reviewer verified its condition: the three guard test files differ from the merge base by 4 added lines and 0 removed lines, each a table row; `hook-dependency-guard-completeness.Tests.ps1` is not in the diff. | No action. The criteria stay unchecked with the gap recorded in `evidence/qa-gates/ac-tracking.2026-11-07T18-05.md`. | The deviation was decided before execution and is documented; it is non-blocking. | Policy audit `## Accepted Deviation Verification (PA-2)`. |
| Info | `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | `It 'contains the nine required dispatch rows and six defined docs tools'` | The prior Minor row is resolved. The case asserts that each of the nine subcommands the skills name is a key of the parsed dispatch table and that the count is at least nine. `Get-DocsCommandRowOption` returns a hashtable keyed by row name, so `.Keys` membership is meaningful. A removed required row still fails the case. | No action. | The change is the requested membership check, not a weakening to make a failing test pass; the case passed before and after. | Commit `9c9225bf0`; `evidence/qa-gates/pester-coverage.2026-11-07T17-58.md` row for the renamed `It`. |
| Info | `.claude/hooks/enforce-docs-role-write-scope.ps1` | `Invoke-DocsRoleWriteScopeDecision` | An unparseable PreToolUse payload yields no role and is allowed with no output, so a docs role with a corrupt payload is not restricted by this hook. Carried from the prior review. | No action. The suite pins this behavior. | Matches the specification's pass-through rule and the precedent hook. | Prior real-process probe; hook unchanged since. |
| Info | `.claude/settings.json` | New PreToolUse group | The hook runs on every Write, Edit, MultiEdit, NotebookEdit and Bash call in every session, adding one `pwsh` start per call, although it acts only for four roles. Carried from the prior review. | No action for this item. A shared dispatcher for role-scoped hooks would remove the cost. | Latency only. | Settings diff. |
| Info | `.claude/hooks/enforce-docs-role-write-scope.ps1` | Rule 5 | Rule 5 reads the profile only from the default path relative to the payload cwd. All default artifact paths are `.json`, so rule 4 still denies them. Carried from the prior review. | No action. The header states the default-path limit. | Defense in depth holds through rule 4 (re-probed: `docs/x.json` denied by rule 4). | Real-process probe at HEAD. |
| Info | `.codex/agents/docs-author.toml`, `.github/agents/docs-author.agent.md` | Tool lists | The Codex and Copilot `docs-author` copies hold write tools with no write-scope hook. Carried from the prior review. | Owner question OQ-2 remains open. | Recorded so the onboarding child states it. | Spec `## Owner Questions`. |

No file-size Warning applies: no covered file in the branch diff is at or above 700 logical lines (largest 381). `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The merge resolution changed only the conflicting hunk. The resolved manifest's path set is the union of both parents with each parent's order preserved (recorded in the merge-result evidence; the reviewer confirmed the diff against the tip adds only the 23 feature paths).
- The cycle left the three hooks and their dependencies untouched; the merge brought in no change to `hook-dependency-guard.ps1`, `HookPayload.psm1`, the SubagentStop envelope reader or `.claude/lib/docs`.
- Real-process probes at HEAD reproduce the prior results: rule 6 with `..` normalization, rule 4, rule 2, main-thread pass-through, non-docs SubagentStop pass-through, and exit 2 with each absent token named.

#### API and safety notes

- `Test-DocsRoleOutputFile` checks paths relative to the process cwd, which matches repository-relative paths when Claude Code runs hooks in the session directory.
- Role names compare case-sensitively in both hooks and in the matcher.

#### Error handling and logging

- Every block message starts with a fixed prefix; an unhandled SubagentStop error blocks with the report-and-halt line.

---

## Test Quality Audit

The cycle changed one assertion. The new form checks the specification's contract (each subcommand the skills name exists in the dispatch table) rather than table size. Per the owner directive the reviewer ran no single-file suite; discrimination was judged by inspection: a missing required key fails `Should -Contain`, and the parser returns a keyed hashtable.

### Reviewed test and QA artifacts

- `evidence/other/merge-preview.2026-11-07T17-45.md`, `merge-result.2026-11-07T17-46.md` - merge and resolution checks.
- `evidence/qa-gates/powershell-format.2026-11-07T17-47.md`, `powershell-analyze.2026-11-07T17-47.md` - static gates, reproduced by the reviewer.
- `evidence/regression-testing/codex-generator-check.2026-11-07T17-47.md` - generator `--check` exit 0.
- `evidence/qa-gates/pester-coverage.2026-11-07T17-58.md` - merged-head parallel gate; figures reproduced from the artifact.
- `evidence/qa-gates/pytest-regression.2026-11-07T18-03.md`, `jest-regression.2026-11-07T18-03.md` - pytest and Jest.
- `evidence/qa-gates/ac-tracking.2026-11-07T18-05.md`, `scope-check.2026-11-07T18-04.md`, `classification-check.2026-11-07T18-05.md`, `self-review.2026-11-07T18-06.md` - closure checks.

### Quality assessment prompts

- **Determinism:** no clock, randomness or process start in the new suites.
- **Isolation:** one behavior per `It`.
- **Speed:** the parallel gate ran 18859 tests in 586.38 s.
- **Diagnostics:** `Should -Contain` names the absent row.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | The hooks start no process and evaluate no text. |
| Input validation at boundaries | PASS | Payloads parsed by the shared readers; token values validated. |
| Error handling remains explicit | PASS | Fail-closed blocks with fixed prefixes; probe confirmed. |
| Configuration / path handling is safe | PASS | Root-plus-separator comparison; protected prefixes; probes at HEAD confirm. |

---

## Research Log

No external research was required. Upstream contracts are unchanged since `evidence/other/upstream-contracts.2026-11-07T15-59.md`; `.claude/lib/docs` is not changed by the merge.

---

## Verdict

No blocking finding remains. PA-1 is resolved and verified against a fresh fetch. PA-2 is an accepted, recorded deviation whose condition holds. The prior Minor row is resolved. Coverage, static analysis, parity and manifests hold at the merged head. The branch is ready for a pull request into the integration branch; the CI-dependent criteria remain for S9.
