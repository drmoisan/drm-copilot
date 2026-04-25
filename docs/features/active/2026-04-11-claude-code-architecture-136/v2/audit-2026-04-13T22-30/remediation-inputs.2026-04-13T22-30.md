# Remediation Inputs: Claude Code architecture v2 loop 6 (#136)

Timestamp: 2026-04-13T22:30-04:00
Feature Folder: `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
Base Branch: `origin/development`
Head Branch: `feature/claude-code-architecture-136`
Primary Requirements Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`

## Scope Summary

The repaired multi-folder `ScanFoldersJson` wrapper transport remains closed and must stay closed.

This review identifies one new repo-controlled defect plus two still-open review gates:

1. The current working tree raises three touched files above the repository's 500-line file limit.
2. Seven live Claude-session acceptance criteria remain `UNVERIFIED` because the current environment cannot launch a live Claude Code session.
3. Changed-scope coverage accounting remains open by audited exception for the repaired TypeScript and PowerShell scope.

The following findings remain closed and must stay closed:

- The multi-folder `scan_folders` wrapper transport defect.
- The stale checkpoint-absent blocker statement.
- The `.claude/settings.json` schema-validation finding.
- The PowerShell coverage-output-path regression.
- The stale token finding in settings, docs, and runtime tests.

## Enumerated Fix List

1. Restore file-structure compliance for the touched implementation and test files.
   - Files in scope:
     - `extensions/drm-copilot/src/repo-automation-service.ts`
     - `extensions/drm-copilot/test/repo-automation-service.test.ts`
     - `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`
   - Current defect:
     - The current working tree counts are `506`, `542`, and `574` lines respectively, exceeding the repository's 500-line limit for touched files.
   - Expected behavior:
     - Each touched file is reduced below 500 lines without changing the repaired wrapper contract or widening the public API surface.
   - Verification action:
     - Record current and post-change line counts, then rerun the targeted TypeScript and PowerShell toolchain sequence.

2. Capture transcript-level live Claude runtime evidence for the remaining acceptance criteria.
   - Files and artifacts in scope:
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t1.live-skill-validation-refresh.2026-04-13T22-07.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t2.live-allowlist-probe.2026-04-13T22-07.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t3.live-checkpoint-resume.2026-04-13T22-07.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t4.live-subagentstop.2026-04-13T22-07.md`
   - Current defect:
     - The latest blocker artifacts prove only that the current shell environment cannot launch a live Claude Code session; they do not provide transcript-level PASS evidence.
   - Expected behavior:
     - A current evidence package records transcript-backed PASS or current blocker evidence for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, the allowlist probe, checkpoint resume, and `SubagentStop`.
   - Verification action:
     - Run the required workflows in a real Claude Code session on the current branch and store transcript-level artifacts under `evidence/qa-gates/`.

3. Close the changed-scope coverage-accounting gap.
   - Files and artifacts in scope:
     - `coverage.xml`
     - `artifacts/pester/powershell-coverage.koverage.xml`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t5.coverage-accounting.2026-04-13T22-07.md`
     - `extensions/drm-copilot/src/repo-automation-service.ts`
     - `extensions/drm-copilot/resources/templates/run-poshqc-format.ps1`
     - `extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1`
     - `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`
     - `scripts/powershell/PoshQC/PoshQC.Testing.psm1`
   - Current defect:
     - The review still cannot prove no-regression coverage or new-code coverage for the changed TypeScript and PowerShell scope.
   - Expected behavior:
     - A current artifact either provides changed-scope coverage evidence mapped to the repaired files or records a reviewer-actionable scoped exception dossier with enough detail for a policy decision.
   - Verification action:
     - Generate changed-scope TypeScript and PowerShell coverage analysis and store the resulting artifacts under `evidence/qa-gates/`.

## Verified Open Blockers

- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t1.live-skill-validation-refresh.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t2.live-allowlist-probe.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t3.live-checkpoint-resume.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t4.live-subagentstop.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t5.coverage-accounting.2026-04-13T22-07.md`
- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/test/repo-automation-service.test.ts`
- `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`
- `artifacts/orchestration/orchestrator-state.json`

## Do Not Do

- Do not reopen the repaired `ScanFoldersJson` wrapper transport unless new regression evidence proves it is broken again.
- Do not change the public interface of `RepoAutomationService` or the current wrapper command contract while splitting files for structure compliance.
- Do not mark any live-runtime criterion PASS without transcript-level evidence from a live Claude Code session.
- Do not treat the current coverage exception dossier as a PASS substitute without additional evidence or an explicit policy decision.
- Do not check off acceptance criteria until the corresponding live evidence is verified.

## Required Context Package For Planning

- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `artifacts/orchestration/orchestrator-state.json`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T22-30.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T22-30.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T22-30.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
