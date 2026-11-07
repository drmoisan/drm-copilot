# Code Review: Documentation Authoring Workflow (#1037)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-authoring-workflow-1037`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `6baed77f6b3be8d98a70c15342d7c8722e35c342`; tip `098b6edfe89b4c2d8a2095718b538d1edbeabf10`)
**Head Branch:** `feature/docs-authoring-workflow-1037-r2` at `68845d93483433928502bfa4b75eb13cee8a5c30`
**Review Type:** Initial feature review

---

## Executive Summary

The branch delivers four documentation roles with tool allowlists, eight skills with page templates, mirrors on three hosts and three bundles, a SubagentStop result-token check, a PreToolUse write-scope hook, registrations and Pester suites. Evidence reviewed: the PR context generated in this review, the full production and test diff, the evidence folder, reviewer analyzer and formatter runs, a coverage re-parse, byte-identity checks over 64 bundle pairs, a manifest check, and 17 real-process hook probes.

**What changed:**
Three PowerShell hooks (273, 196 and 89 logical lines) with byte-identical bundle copies; Markdown and TOML agent and skill files; JSON settings, routing and manifest edits; nine new Pester files and one added row in each of three guard tests.

**Top 3 risks:**
1. The branch conflicts with the base tip in the Claude core manifest (PA-1). A conflicting pull request receives no CI checks.
2. The write-scope hook depends on `agent_type` in PreToolUse payloads for project subagents. The research cites the Claude Code hooks reference and the precedent hook `enforce-epic-invocation-origin.ps1`; no live run on this branch confirms it, by specification.
3. Codex and Copilot copies of `docs-author` hold write tools without any write-scope hook (owner question OQ-2, provisional default).

**PR readiness recommendation:** **No-Go** until PA-1 is remediated and the owner decides PA-2.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Hook entries near `enforce-docs-complete-gate-target.ps1` | PA-1: `git merge-tree` against the base tip `098b6edfe` reports a content conflict: the branch adds `enforce-docs-role-write-scope.ps1` and the base adds `enforce-epic-merge-gate-review.ps1` at the same line. The branch is 195 commits behind the tip. | Merge the base tip, keep both lines, and re-run the Codex generator `--check`, the contract tests, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run at the merged head. | A conflicting pull request gets zero CI checks, so S9 cannot pass. | Policy audit `## Base Synchronization`. |
| Blocking | `spec.md`, `user-story.md` | Spec AC 9, spec AC 11, user-story AC 7 | PA-2: each criterion requires existing contract tests to pass "without modification". Guard tests B4, U2 and the #1026 inventory test require a row for each new registered hook, so the in-scope hooks cannot be added without editing them. The branch adds rows only. | Owner decides: amend the clause to allow the additive rows (as 1034 did), or accept the deviation in a specification revision. No code change is needed. | The executor cannot meet the clause and the reviewer may not edit criterion text. | Feature audit rows spec 9, spec 11, story 7; plan note N4. |
| Minor | `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | `It 'reads nine dispatch rows and six defined docs tools'` | The case asserts `$script:Rows.Count` equals 9. A later child that adds a docs subcommand fails this suite although no skill changed. The specification's test rule asks for membership checks, not set equality. | Assert that the nine subcommands the skills name are present, or use `Should -BeGreaterOrEqual 9`. Fold into the PA-1 cycle. | Avoids a cross-child break; the parser sanity purpose is kept. | Inspection; spec `## Tests`. |
| Info | `.claude/hooks/enforce-docs-role-write-scope.ps1` | `Invoke-DocsRoleWriteScopeDecision` | An unparseable PreToolUse payload yields no role and is allowed with no output. A docs role with a corrupt payload is therefore not restricted by this hook. | No action. The suite pins this behavior, and Claude Code emits well-formed payloads. | Matches the specification's pass-through rule and the precedent hook. | Real-process probe `garbage`. |
| Info | `.claude/settings.json` | New PreToolUse group | The hook runs on every Write, Edit, MultiEdit, NotebookEdit and Bash call in every session, adding one `pwsh` start per call, although it acts only for four roles. | No action for this item. A shared dispatcher for role-scoped hooks would remove the cost. | Latency only. | Settings diff. |
| Info | `.claude/hooks/enforce-docs-role-write-scope.ps1` | Rule 5 | Rule 5 reads the profile only from the default path relative to the payload cwd. A profile at another path or a session started in a subdirectory leaves rule 5 inactive. All default artifact paths are `.json`, so rule 4 still denies them. | No action. The header states the default-path limit. | Defense in depth holds through rule 4. | `DocsProfile.psm1` default `artifact_paths`; probe `author-ledger`. |
| Info | `.codex/agents/docs-author.toml`, `.github/agents/docs-author.agent.md` | Tool lists | The Codex and Copilot `docs-author` copies hold write tools with no write-scope hook. | Owner question OQ-2 remains open. | Recorded so 900010 states it in onboarding text. | Spec `## Owner Questions`. |

No file-size Warning applies: no covered file in the branch diff is at or above 700 logical lines (largest 381).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `docs-role-contract.ps1` keeps parsing pure and takes file existence through an injected scriptblock, so the token rules can be tested without files.
- The write-scope hook normalizes targets with `GetFullPath` and compares against the root plus a separator. A sibling directory that extends the root name is denied, and `docs/../.claude/x.md` is normalized and denied by rule 6 (both confirmed by real-process probes).
- Rule order 3, 6, 5, 4 reports a profile artifact as rule 5 even when rule 4 also applies, so the reason names the more specific rule.
- The SubagentStop hook separates repairable token defects (block on every stop) from non-repairable anomalies (block once, allow on re-entry), following `validate-required-artifact-output.ps1`.
- Dependency loading uses the guarded pattern, and the guard tables of `hook-dependency-failure.Claude.Tests.ps1` and `subagentstop-uncaught-error.Tests.ps1` now cover both hooks.

#### API and safety notes

- `Test-DocsRoleOutputFile` checks paths relative to the process cwd. Claude Code runs hooks in the session directory, so this matches repository-relative paths.
- Role names compare case-sensitively in both hooks and in the matcher, so a case variant of a role name is treated as a non-docs agent consistently.

#### Error handling and logging

- Every block message starts with a fixed prefix; an unhandled SubagentStop error blocks with the report-and-halt line.

---

## Test Quality Audit

Hook suites cover each rule, each token, and each anomaly class; structural suites pin the committed contracts. Per the owner directive the reviewer did not run single-file suites; discrimination was judged by inspection and by real-process probes of the shipped hooks, all of which matched the asserted behavior.

### Reviewed test and QA artifacts

- `evidence/regression-testing/docs-role-contract.2026-11-07T16-30.md`, `validate-docs-role-output.2026-11-07T16-30.md`, `enforce-docs-role-write-scope.2026-11-07T16-30.md`, `hook-guard-suites.2026-11-07T16-30.md` - focused runs.
- `evidence/regression-testing/structural-suites.2026-11-07T16-50.md` - 299 structural tests.
- `evidence/regression-testing/contract-tests.2026-11-07T16-37.md` - 1011 contract tests, Codex generator `--check`.
- `evidence/qa-gates/pester-coverage.2026-11-07T17-06.md` - final parallel gate; figures reproduced from the artifact.
- `evidence/qa-gates/python-jest-regression.2026-11-07T17-10.md` - pytest and Jest.
- `evidence/regression-testing/pester-shuffle.2026-11-07T17-06.md` - waiver record.
- `evidence/qa-gates/ac-tracking.2026-11-07T17-20.md`, `self-review.2026-11-07T17-20.md` - read in full.

### Quality assessment prompts

- **Determinism:** no clock, randomness or process start in the new suites.
- **Isolation:** one behavior per `It`.
- **Speed:** seconds per suite.
- **Diagnostics:** `-Because` text carries the actual reason.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | The hooks start no process and evaluate no text. |
| Input validation at boundaries | PASS | Payloads parsed by the shared readers; each token value is validated. |
| Error handling remains explicit | PASS | Fail-closed blocks with fixed prefixes. |
| Configuration / path handling is safe | PASS | Root-plus-separator comparison; case-insensitive protected prefixes; probes confirm. |

---

## Research Log

No external research was required. Upstream contracts were read from the merged sources recorded in `evidence/other/upstream-contracts.2026-11-07T15-59.md` and checked against `Invoke-DocsCommand.ps1` for the options the skills name.

---

## Verdict

The implementation is correct on every probe and inspection performed, and coverage, static analysis, parity and manifests hold. Two blocking findings remain: PA-1 (synchronize with the base and re-run the gates; autonomous) and PA-2 (an owner decision on the "without modification" clause). One Minor row should be folded into the PA-1 cycle.
