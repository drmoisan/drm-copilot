# Remediation Inputs — Issue #1032 (related non-blocking finding CR-1)

Timestamp: 2026-11-20T05-28
Issue: #1032
Branch: feature/retire-github-skills-and-thin-copilot-layer-1032
Trigger: the S7 feature review at head 6a0b4b3f7 (code-review.2026-11-20T05-16.md, policy-audit.2026-11-20T05-16.md, feature-audit.2026-11-20T05-16.md) returned PASS with one Minor finding, CR-1, in this item's own guard suite. Standing rule for this run: related findings are fixed inside the item through a remediation cycle before merge, not deferred to a later change or a new issue. This cycle is opened by orchestrator decision after a PASS review, so it names no opening review.
Review-Verdict: PASS
Remediation-Mode: proportionate

Rationale for the mode: the fix adds negative test cases to one existing test file that is already in the branch diff (`tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`). No spec acceptance criterion, public interface, production file, or file outside the branch diff and its tests changes.

## Findings

### CR-1 — Two guard-suite rule branches have no discriminating negative case
- Severity: Minor (non-blocking in review; fixed here under the related-findings rule)
- Remediability: autonomous
- Finding-Scope: contained
- Location: `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`, helpers `Test-ClrBriefCount` (retired-path branch) and `Test-ClrCollisionControl` (workspace branch).
- Observation (from the review): no `-REJECTS` case feeds a brief copy that names the retired path, and no case feeds a complete workspace-scope settings file with a wrong value (the existing REJECTS case has no `chat.` key), so a defect in the retired-path check or in the workspace-case value comparison would not fail any test.
- Required change: add an in-memory brief-copy fixture holding the retired path, asserting exactly one `CLR-BRIEF-COUNT` violation; and add an in-memory complete workspace-scope settings fixture with one wrong value (for example `".claude/skills": true`), asserting exactly one `CLR-COLLISION-CONTROL` violation. Fixtures are in-memory (no temporary files), the retired path is built at runtime from its parts (no literal), and each new case is shown to fail against a deliberately broken branch before it is accepted (fail-before evidence or exception dossier).
- Verification: the task-check Pester selection of the suite through the launcher, then the final Pester gate (one `Invoke-PoshQCParallelTest` through the launcher) with zero failures and no line-coverage drop against the cycle-2 Pester final record; PSScriptAnalyzer and the formatter comparison on the edited file.

## Non-Blocking Notes Not Carried

- CR-2, CR-4: informational, no change required.
- CR-3: process note on where the executor writes the Jest coverage report; the final TypeScript gate is not re-run in this cycle because no TypeScript file changes.
