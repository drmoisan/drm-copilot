---
title: "2026-04-11-claude-code-architecture-136-v2-remediation-loop-5"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-13T22-07"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T22-07.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T22-07.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Remediation Plan — Feature #136 Claude Code architecture v2 loop 5

## Overview

This remediation loop is evidence-focused. The repo-controlled wrapper defect is closed. The remaining work is to collect current live Claude-session validation evidence, refresh the stale checkpoint-resume artifact, and close the coverage-accounting gap that still prevents a PASS review.

## Deterministic Inputs

- Remediation requirements: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T22-07.md`
- Supporting scope docs:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Work-mode source: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T22-07.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T22-07.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T22-07.md`
- PR-context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
- Checkpoint artifact:
  - `artifacts/orchestration/orchestrator-state.json`

## Scope Guardrails

- Do not reopen the repaired `ScanFoldersJson` wrapper transport unless new live evidence proves regression.
- Do not reopen the resolved settings/schema, coverage-output-path, or stale-token findings.
- Do not mark any live Claude-session criterion PASS without transcript-level runtime evidence.
- Do not use stale checkpoint evidence that still claims the canonical checkpoint is absent.
- Do not skip changed-scope coverage accounting; either provide current evidence or an explicit audited exception.

## Requirements Traceability

| Remediation requirement | Remediation tasks |
|---|---|
| Capture current live Claude skill-entrypoint evidence | P1-T1 |
| Capture current live allowlist, checkpoint-resume, and `SubagentStop` evidence | P1-T2, P1-T3, P1-T4 |
| Resolve changed-scope coverage-accounting gap | P1-T5 |
| Refresh review artifacts from the new evidence package | P2-T1, P2-T2 |

### Phase 0 — Context and Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T22-07.md`, and the current review artifacts, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/phase0-instructions-read.2026-04-13T22-07.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Policy Order:`, the resolved work-mode marker `- Work Mode: full-feature`, and the exact ordered file list.

### Phase 1 — Live Validation Evidence

- [x] [P1-T1] Capture transcript-backed evidence for `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue` in a live Claude Code session, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t1.live-skill-validation-refresh.2026-04-13T22-07.md`.
  - Acceptance: The artifact exists, records each required skill individually, and marks each one `PASS`, `FAIL`, or `UNVERIFIED` with transcript-level proof or current blocker evidence.

- [x] [P1-T2] Capture a live subagent allowlist probe against the current branch state and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t2.live-allowlist-probe.2026-04-13T22-07.md`.
  - Acceptance: The artifact proves whether a disallowed operation is blocked from the relevant subagent context, with transcript-level evidence.

- [x] [P1-T3] Capture a live checkpoint-resume exercise against `artifacts/orchestration/orchestrator-state.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t3.live-checkpoint-resume.2026-04-13T22-07.md`.
  - Acceptance: The artifact supersedes the stale `p5-t5` blocker statement and records the observed resume behavior against the current checkpoint file.

- [x] [P1-T4] Capture a live `SubagentStop` proof and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t4.live-subagentstop.2026-04-13T22-07.md`.
  - Acceptance: The artifact shows the stop gate rejecting incomplete output or records a current blocker with transcript-level evidence.

- [x] [P1-T5] Produce changed-scope coverage evidence or an explicit audited exception and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p1-t5.coverage-accounting.2026-04-13T22-07.md`.
  - Acceptance: The artifact resolves or explicitly documents the review’s open no-regression and new-code coverage fields for the changed TypeScript and PowerShell scope.

### Phase 2 — Review Refresh

Restart this phase from [P2-T1] if any artifact is missing, stale, or contradicted by the current branch state.

- [x] [P2-T1] Refresh PR context against `origin/development` and verify that the new live-evidence artifacts exist on disk, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t1.pr-context-refresh.2026-04-13T22-07.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact refresh command, and the refreshed artifact paths.

- [ ] [P2-T2] Create a new `policy-audit.*.md`, `code-review.*.md`, and `feature-audit.*.md` set in the `v2` folder that cites the refreshed live evidence, resolves the stale checkpoint statement, and either closes or explicitly carries forward the coverage-accounting gap.
  - Acceptance: The new audit set is newer than the `2026-04-13T22-07` review set, cites the new evidence artifacts, and does not claim PASS for any criterion without current supporting evidence.

## Verification Actions

- `mcp__drmCopilotExtension__collect_pr_context(base='origin/development', workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot')`
- Live Claude Code session transcripts for `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue`
- Live Claude Code transcript for the allowlist probe
- Live Claude Code transcript for checkpoint resume from `artifacts/orchestration/orchestrator-state.json`
- Live Claude Code transcript for the `SubagentStop` gate

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
