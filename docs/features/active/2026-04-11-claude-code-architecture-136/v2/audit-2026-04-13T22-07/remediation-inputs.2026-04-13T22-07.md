# Remediation Inputs: Claude Code architecture v2 post-remediation validation loop (#136)

Timestamp: 2026-04-13T22:07-04:00
Feature Folder: `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
Base Branch: `origin/development`
Head Branch: `feature/claude-code-architecture-136`
Primary Requirements Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`

## Scope Summary

The repo-controlled multi-folder PoshQC wrapper defect is closed in the current working tree and must remain closed.

The remaining blockers are evidence and validation gaps:

1. Seven live Claude-session acceptance criteria are still `UNVERIFIED`.
2. The checkpoint-resume evidence artifact is stale because it predates the current canonical checkpoint state.
3. Policy-required coverage fields for no-regression and new-code coverage remain unresolved for the changed scope.

The following findings remain closed and must stay closed:

- The multi-folder `scan_folders` wrapper transport defect.
- The `.claude/settings.json` schema-validation finding.
- The PowerShell coverage-output-path finding.
- The stale MCP token finding in settings, docs, and runtime tests.

## Enumerated Fix List

1. Capture transcript-level live Claude Code evidence for the user-facing skill entrypoints.
   - Files and artifacts in scope:
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/`
   - Current defect:
     - `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue` still rely on `p5-t4.live-skill-validation.2026-04-12T15-57.md`, which explicitly records no live Claude session transcript.
   - Expected behavior:
     - A current evidence artifact records transcript-backed PASS or current blocker evidence for each required live skill entrypoint.
   - Verification action:
     - Run the four skills in a live Claude Code session on the current branch and store transcript-level evidence under `evidence/qa-gates/`.

2. Capture current live enforcement and resumability evidence.
   - Files and artifacts in scope:
     - `artifacts/orchestration/orchestrator-state.json`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md`
   - Current defect:
     - No live allowlist probe transcript exists.
     - No live `SubagentStop` transcript exists.
     - The current checkpoint-resume artifact is stale because it states that the checkpoint file was absent.
   - Expected behavior:
     - Fresh evidence proves or blocks the allowlist probe, `SubagentStop`, and checkpoint-resume behaviors against the current checkpointed workspace.
   - Verification action:
     - Perform the live subagent probe, live stop-gate probe, and live checkpoint-resume validation in Claude Code and replace or supersede the stale evidence files.

3. Resolve the coverage-accounting gap for the changed scope.
   - Files and artifacts in scope:
     - `coverage.xml`
     - `artifacts/pester/powershell-coverage.koverage.xml`
     - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p3-t4.powershell-coverage-green.2026-04-13T11-06.md`
   - Current defect:
     - The review still cannot prove no-regression coverage or new-code coverage for the changed TypeScript and PowerShell scope.
   - Expected behavior:
     - A current artifact either provides changed-scope coverage evidence or records an explicit audited exception that the next review can evaluate.
   - Verification action:
     - Generate changed-scope coverage analysis or a documented exception dossier and store it under `evidence/qa-gates/`.

## Verified Open Blockers

- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md`
- `artifacts/orchestration/orchestrator-state.json`
- `coverage.xml`
- `artifacts/pester/powershell-coverage.koverage.xml`

## Do Not Do

- Do not reopen the repaired `ScanFoldersJson` wrapper transport unless new live evidence proves regression.
- Do not mark any live-runtime criterion PASS without transcript-level evidence from the current branch state.
- Do not rely on `p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` as current checkpoint proof.
- Do not weaken coverage requirements by replacing missing coverage analysis with unsupported assumptions.
- Do not change acceptance checkboxes until the corresponding live evidence is verified.

## Required Context Package For Planning

- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `artifacts/orchestration/orchestrator-state.json`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T22-07.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
