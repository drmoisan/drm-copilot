# Remediation Inputs - issue #1019 (review 2026-11-06T18-47)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Finding classes: F1 autonomous. AC-8 is pending-CI and is not a finding in this file.

Source review artifacts (this folder):

- `policy-audit.2026-11-06T18-47.md`
- `code-review.2026-11-06T18-47.md`
- `feature-audit.2026-11-06T18-47.md`
- Target plan: `remediation-plan.2026-11-06T18-47.md`

Branch: `bug/docs-tokenizer-scaling-1019`, head `fe9a4023d`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `c4a2398aa`).

## Blocking Findings

### F1 - Structural guard does not pin the lexing window bound

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The gap was reproduced with a scratch mutant, and the fix is a test assertion in a file already in the branch diff; no external system, owner decision, or CI result is needed to make it.
- File: `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`
- Symbol: `Describe 'Get-DocsPythonToken structural scaling guard'`, `It 'assigns the lexing window only from a Substring of the source text'`
- Rule: `.claude/rules/general-unit-test.md`, `## Coverage Requirements` (untested critical behavior is not acceptable even if the overall percentage looks good); `issue.md` `## Implementation Intent` (structural regression guard).
- Evidence: `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`, `## Structural Guard on an Unbounded Window`: with both `$source` assignments rewritten to `$sourceText.Substring($windowStart)` and `$sourceText.Substring(0)`, the guard describe reports passed 2, failed 0. The behavior cases do not depend on the bound, and the token-limit test uses a names-only source.
- Required change:
  1. In the second guard case, require each `$source` assignment to pass exactly two arguments to `.Substring`, with the second argument an `InvokeMemberExpressionAst` for `Min` on `[math]` whose first argument is the variable `$windowSize`.
  2. In the first guard case or a new case in the same describe, require the first argument of each `.Match` call inside the `Get-DocsPythonToken` token loop to be the variable `$source`, so an inline slice or other expression cannot replace the window. The coding-cookie loop is outside this requirement.
  3. Keep the test free of sleep, timing thresholds, and temporary files. Keep the new lines separated from the candidate suite hunks by at least one unchanged base line.
- Verification:
  - Guard run on four trees (unfixed, candidate, fixed, and a scratch mutant with the unbounded window), recorded in a new `evidence/regression-testing/guard-fail-before.<timestamp>.md`: at least one failing case on unfixed, candidate, and mutant; none on fixed.
  - Candidate hunk identity check, format, analyzer, `SUITE`, and the docs test folder coverage run pass, with new evidence artifacts for each.
  - `MODULE` line coverage stays at least 85%, and repo-wide figures are recorded from the merged CI artifact at S9.

## Non-blocking Items Related to This Item

These items sit in files already in the branch diff and change no acceptance criterion or public interface. They are listed for the same cycle under the standing instruction that related review items are fixed inside the item.

- Minor: extend the declaration comment above `$source` in `.claude/lib/docs/DocsPythonTokens.psm1` to state that `Match` also runs after a margin rebase. Keep the candidate loop-head lines byte-identical.
- Minor: add a note in the module `.NOTES` that the measured cost is in the PowerShell method-invocation layer and that the AMSI attribution in the retained candidate comments is unverified.
- Minor: update the `issue.md` `## Dependencies / Risks` sentence that says 1034 already carries the candidate hunks; the 1034 tip has reverted them. Do not edit `## Acceptance Criteria`.
- Nit: add one sentence on the window to the module `.DESCRIPTION`, and one on the guard and window cases to the `SUITE` `.DESCRIPTION`.
- Info: set the plan header `Status` to reflect completed work.

A module edit changes the `MODULE` hash, so the cycle must re-copy the bundle, re-confirm byte identity and contract tests, and refresh hash-bound evidence. A comment-only module edit does not change tokens; the plan may state how it re-establishes the differential and scaling evidence for the new hash.

## Decision for the Orchestrator, Outside This Cycle

- Minor: `DocsCSharpTokens.psm1` and other modules keep the same whole-source `Match` call pattern, and `issue.md` places them outside this item. A search of open issues for `DocsCSharpTokens` found only #1033, the feature that added the module. Decide whether a separate epic child measures and fixes them, or file a tracking issue.

## Pull Request Notes

- AC-8 stays unchecked and pending-CI until S9 of the item's own orchestrator run.
- #1019 is the epic issue. Do not use a closing keyword for it in the PR body.
- The branch is one docs-only commit behind the base, with no conflict reported by `git merge-tree`. Sync before opening the PR.
- `ci.yml` triggers only on pull requests into `main` or `development`, per the 1033 remediation record; dispatch it manually if no checks start on the epic-child PR.

## Do Not Do

- Do not weaken or remove a guard or boundary case, or lower any threshold.
- Do not edit the candidate lines in `MODULE` or `SUITE`, or any policy document.
- Do not widen the cycle to other tokenizer modules.
- Do not add a Python file. New helpers are PowerShell under `SCRATCH`.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/policy-audit.2026-11-06T18-47.md
- code-review-path: docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/code-review.2026-11-06T18-47.md
- feature-audit-path: docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/feature-audit.2026-11-06T18-47.md
