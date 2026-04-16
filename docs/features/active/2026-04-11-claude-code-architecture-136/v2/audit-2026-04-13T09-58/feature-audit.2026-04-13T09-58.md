# Feature Audit: Claude Code architecture v2 (#136)

---

**Audit Date:** 2026-04-13
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Base Branch:** `origin/development`
**Head Branch:** `feature/claude-code-architecture-136`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `origin/development` (`14708b3b0c75ebf36b314f7c1780db1625604ecb`)
- **Head branch/commit:** `feature/claude-code-architecture-136` (`93eea9b6effb35f0842aed0f3a221ef7133ef23f`)
- **Merge base:** `226a39309f3223bd48f3d52a2bc4feca324d34b4`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/**`
  - Additional evidence: current re-review command output for JSON validation, targeted PowerShell analysis, and targeted PowerShell tests
- **Feature folder used:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
- **Requirements source:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- **Work mode resolution note:** Work mode resolves from `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md` with marker `- Work Mode: full-feature`.
- **Scope note:** PR context was refreshed against `origin/development` because the prior stored review artifacts predated the current working-tree state.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` — primary Definition of Done source
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` — primary acceptance-criteria source

### From `spec.md` — Definition of Done

1. The repository contains a working Claude-native architecture spanning `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/`, with each layer implemented for its intended feature role rather than documented only.
2. The main-thread orchestration flow is implemented so the repository can run end-to-end feature workflows in Claude Code without relying on a forked `orchestrator` worker to perform nested subagent delegation.
3. The repository includes the canonical user-facing workflow skills required by this feature (`orchestrate`, `commit-message`, `pr-author`, `research-issue`, and any required review/status skills), and each one routes to the expected Claude-native runtime surface.
4. The repository includes the bounded repository-canonical worker agents required by this feature (planner, executor, research, review, feature-doc, and language-engineer workers), with project-scoped routing limited to those workers rather than to generic personal personas.
5. The `.claude/settings.json` permissions and `.claude/hooks/*` enforcement layer are implemented and demonstrably block at least the documented disallowed tool/path/command cases while allowing the intended workflow operations.
6. The checkpoint-based resumability flow works with `artifacts/orchestration/orchestrator-state.json`, and an interrupted orchestration run resumes from recorded state instead of restarting from scratch.
7. The sync strategy is implemented and documented so a maintainer can determine how `.claude/` runtime files stay aligned with canonical `.github/` sources and can update them without guessing ownership or mirror rules.
8. The Copilot-to-Claude equivalence documentation is complete, including file-by-file migration maps for canonical `.github/skills`, `.github/agents`, and direct-use `.github/prompts`, plus explicit documentation of non-equivalences and fallback behavior.

### From `user-story.md` — Acceptance Criteria

9. The architecture documentation states explicitly that the provided `20260412-claude-code-github-skills-agents-migration-research.md` research is sufficient to define the migration scope and file-by-file Claude mapping without additional discovery work.
10. The Claude architecture uses a main-thread orchestrator model and does not require a forked `orchestrator` subagent to spawn downstream subagents.
11. A developer can invoke `/orchestrate` by name in a Claude Code session and trigger the full orchestration workflow without manual agent configuration steps beyond opening the repository in Claude Code.
12. A developer can invoke `/commit-message` and receive a conventional commit message formatted according to the repository's canonical conventions.
13. A developer can invoke `/pr-author` and receive a complete, GitHub-ready PR body derived from the pr_context artifacts.
14. A developer can invoke `/research-issue` and receive structured research output written to the correct artifact path under `artifacts/research/`.
15. The migration documentation includes a file-by-file mapping for the canonical `.github/skills/*/SKILL.md` files to their `.claude/skills/*/SKILL.md` targets, including any files that remain documentation-only rather than runtime assets.
16. The migration documentation includes a file-by-file disposition for all `.github/agents/*.agent.md` files, identifying which become project subagents, which become wrapper skills, which remain main-thread-only orchestration logic, and which are personal or library personas that stay out of project scope.
17. The migration documentation identifies the direct-use `.github/prompts/*.prompt.md` entry points that must become `.claude/skills/*/SKILL.md` files rather than `.claude/commands/*` files.
18. The migration documentation distinguishes between repository-enforceable controls (`CLAUDE.md`, `.claude/rules/`, `.claude/settings.json`, `.claude/hooks/*`) and controls that require managed settings outside the repository for non-overrideable enforcement.
19. Subagent tool restrictions correctly block operations outside their declared allowlist (verified by attempting a disallowed operation from within the relevant subagent context).
20. The main-thread orchestrator reads `artifacts/orchestration/orchestrator-state.json` at session start and resumes from the recorded `next_step` rather than restarting from scratch when a valid checkpoint exists.
21. The `PreToolUse` hook blocks at least one representative dangerous-command pattern (for example `rm -rf` or `git push --force`) via the hook script in `.claude/hooks/`.
22. The `SubagentStop` hook blocks premature worker termination when the required completion artifact (plan path, research path, or review artifact path) is absent from the output.
23. A developer can follow the sync strategy documentation in `docs/engineering/claude-code-architecture.md` to determine whether `.claude/` content is current with `.github/` sources and apply updates.
24. The architecture documentation explicitly identifies each non-equivalence between Copilot and Claude and does not claim runtime enforcement for behaviors that are enforced only by prompt conventions.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Claude-native architecture spans `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/` | PASS | Current file inspection; refreshed PR context; existing runtime-structure evidence | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development` | The required layers still exist in the selected `v2` scope. |
| 2 | Main-thread orchestration flow is implemented without a forked `orchestrator` worker | PASS | `.claude/skills/orchestrate/SKILL.md`; `.claude/agents/orchestrator.md`; current runtime tests | file inspection; targeted Pester rerun | The no-fork model remains explicit in the runtime surface. |
| 3 | Canonical user-facing workflow skills are present and route to the expected Claude-native runtime surface | PASS | `.claude/skills/orchestrate/SKILL.md`; `.claude/skills/commit-message/SKILL.md`; `.claude/skills/pr-author/SKILL.md`; `.claude/skills/research-issue/SKILL.md`; wrapper-skill inventory tests | targeted Pester rerun | Static runtime routing remains present. Live slash-command execution is tracked separately in criteria 11-14. |
| 4 | Repository-canonical worker agents exist with project-scoped routing limited to those workers | PASS | `.claude/agents/orchestrator.md`; `.claude/agents/prd-feature.md`; `.claude/agents/staged-review.md`; `.claude/agents/epic-review.md`; `.claude/agents/status-updater.md`; language-engineer worker files | targeted Pester rerun | The bounded worker inventory remains present and routed. |
| 5 | Settings and hooks block disallowed cases while allowing intended workflow operations | PARTIAL | `.claude/settings.json:38-41`; `.claude/rules/powershell.md:15-18`; `.claude/agents/atomic-executor.md:21-24,64`; `docs/engineering/claude-code-architecture.md:223`; passing hook and targeted Pester evidence | `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`; `Invoke-PoshQCAnalyze ...`; `Invoke-PoshQCTest ...` | Dangerous-command blocking remains intact, but the PowerShell **test** MCP contract is still stale: the runtime uses `mcp__drmCopilotExtension__run_poshqc_test` instead of the current policy-required `mcp_drmcopilotext_run_poshqc_test`. |
| 6 | Checkpoint resumability works from `artifacts/orchestration/orchestrator-state.json` | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` | static inspection only | No live Claude runtime session was available to capture resume behavior. |
| 7 | Sync strategy is implemented and documented | PASS | `docs/engineering/claude-code-architecture.md` sync-strategy section | file inspection | The sync procedure remains explicit and actionable. |
| 8 | Copilot-to-Claude equivalence documentation is complete | PASS | `docs/engineering/claude-code-architecture.md` migration tables and non-equivalence sections | file inspection; targeted Pester rerun | The required tables and narrative remain present. |
| 9 | Research sufficiency statement is explicit | PASS | `docs/engineering/claude-code-architecture.md` opening paragraphs | file inspection | The document still states that the migration research is sufficient. |
| 10 | Claude architecture uses a main-thread orchestrator model with no forked orchestrator subagent | PASS | `CLAUDE.md`; `.claude/skills/orchestrate/SKILL.md`; `.claude/agents/orchestrator.md` | file inspection | The architecture remains anchored on the main session. |
| 11 | `/orchestrate` works in a live Claude session | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.live-entrypoints.2026-04-13T09-09.md` | none available in this environment | Live slash-command surface unavailable in this run. |
| 12 | `/commit-message` works in a live Claude session | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.live-entrypoints.2026-04-13T09-09.md` | none available in this environment | Same environment blocker as criterion 11. |
| 13 | `/pr-author` works in a live Claude session | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.live-entrypoints.2026-04-13T09-09.md` | none available in this environment | Same environment blocker as criterion 11. |
| 14 | `/research-issue` works in a live Claude session | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.live-entrypoints.2026-04-13T09-09.md` | none available in this environment | Same environment blocker as criterion 11. |
| 15 | Skills migration map is present | PASS | `docs/engineering/claude-code-architecture.md` canonical `.github/skills` migration map | file inspection | The skills migration table remains complete. |
| 16 | Agents disposition table is present | PASS | `docs/engineering/claude-code-architecture.md` canonical `.github/agents` migration map | file inspection | The agents disposition table remains complete. |
| 17 | Prompts migration table is present | PASS | `docs/engineering/claude-code-architecture.md` direct-use `.github/prompts` migration map | file inspection | The prompt migration table remains complete. |
| 18 | Repository-enforceable versus managed-settings controls are distinguished | PASS | `docs/engineering/claude-code-architecture.md` sections 5 and 6 | file inspection | The distinction remains explicit. |
| 19 | Subagent tool restrictions block operations outside their allowlist | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.live-enforcement.2026-04-13T09-09.md` | static inspection only | No live disallowed-operation probe was captured in this environment. |
| 20 | Main-thread orchestrator reads checkpoint and resumes from `next_step` | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.live-enforcement.2026-04-13T09-09.md`; `.../p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` | static inspection only | The checkpoint path is documented, but resume behavior is not live-verified. |
| 21 | `PreToolUse` blocks dangerous command patterns | PASS | `tests/scripts/claude-hooks/validate-bash.Tests.ps1`; current targeted Pester rerun; prior green hook evidence | `Invoke-PoshQCTest -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders 'tests/scripts/claude-runtime','tests/scripts/claude-hooks'` | The hook behavior remains well covered and currently passing. |
| 22 | `SubagentStop` blocks premature worker termination | UNVERIFIED | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.live-enforcement.2026-04-13T09-09.md` | static inspection only | The matcher exists in settings, but no live stop-gate transcript was captured. |
| 23 | Sync strategy is actionable for maintainers | PASS | `docs/engineering/claude-code-architecture.md` manual sync procedure | file inspection | The current procedure remains actionable. |
| 24 | Architecture documentation identifies non-equivalences without overstating enforcement | PASS | `docs/engineering/claude-code-architecture.md` sections 1-2 and 5-6 | file inspection | The document continues to separate enforceable runtime controls from prompt conventions and managed settings. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 15 criteria
- **PARTIAL:** 1 criterion
- **UNVERIFIED:** 8 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. The PowerShell runtime still uses the stale test MCP symbol `mcp__drmCopilotExtension__run_poshqc_test` instead of the current policy-required `mcp_drmcopilotext_run_poshqc_test`.
2. Live Claude-session validation remains unavailable for slash-command entry points, checkpoint resume, permission probes, and stop-gate behavior.
3. The targeted PowerShell rerun still lacks a numeric changed/new-code coverage value.

**Recommended follow-up verification steps:**

1. Correct the PowerShell test-runner contract in runtime files and runtime tests, then rerun JSON validation, targeted PSScriptAnalyzer, and targeted Pester.
2. Perform a live Claude-session validation pass for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, checkpoint resume, permission-probe blocking, and `SubagentStop` behavior.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- Total AC items reviewed from `spec.md`: 8
- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Total AC items reviewed from `user-story.md`: 16
- Checked off during this review: 0
- Remaining (unchecked or not newly checkable): criteria 5, 6, 11, 12, 13, 14, 19, 20, 22
- Items remaining: the PowerShell test-runner contract criterion, checkpoint-resume validation, four live entry-point validations, live allowlist enforcement validation, and live stop-gate validation

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` | 8 | 6 | 2 | Checkbox-backed; criterion 5 is PARTIAL and criterion 6 is UNVERIFIED. |
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` | 16 | 9 | 7 | Checkbox-backed; several live-runtime criteria remain UNVERIFIED. |

No source-file checkbox changes were made during this review because unresolved and partial criteria remain in both authoritative files.