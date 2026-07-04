# Feature Audit: Claude Code architecture v2 remediation review (#136)

---

**Audit Date:** 2026-04-13
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Base Branch:** `origin/development`
**Head Branch:** `feature/claude-code-architecture-136` plus current working tree
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `origin/development` (commit `14708b3b0c75ebf36b314f7c1780db1625604ecb`)
- **Head branch/commit:** `feature/claude-code-architecture-136` (commit `93eea9b6effb35f0842aed0f3a221ef7133ef23f`)
- **Merge base:** `226a39309f3223bd48f3d52a2bc4feca324d34b4`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/**`
  - Additional evidence: current `validate_json` output and current `mcp__drmCopilotExtension__run_poshqc_test` wrapper repro
- **Feature folder used:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
- **Requirements source:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- **Work mode resolution note:** `issue.md` explicitly declares `- Work Mode: full-feature`, so both `spec.md` and `user-story.md` remain authoritative.
- **Scope note:** This re-review stays aligned to the active remediation scope. Prior PASS and UNVERIFIED acceptance states are retained unless the current remediation evidence changed them.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` — primary checkbox-backed acceptance criteria
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` — secondary supporting checkbox inventory (`Definition of Done` and `Seeded Test Conditions`)

### From user-story.md

1. The architecture documentation states explicitly that the provided `20260412-claude-code-github-skills-agents-migration-research.md` research is sufficient to define the migration scope and file-by-file Claude mapping without additional discovery work.
2. The Claude architecture uses a main-thread orchestrator model and does not require a forked `orchestrator` subagent to spawn downstream subagents.
3. A developer can invoke `/orchestrate` by name in a Claude Code session and trigger the full orchestration workflow without manual agent configuration steps beyond opening the repository in Claude Code.
4. A developer can invoke `/commit-message` and receive a conventional commit message formatted according to the repository's canonical conventions.
5. A developer can invoke `/pr-author` and receive a complete, GitHub-ready PR body derived from the pr_context artifacts.
6. A developer can invoke `/research-issue` and receive structured research output written to the correct artifact path under `artifacts/research/`.
7. The migration documentation includes a file-by-file mapping for the canonical `.github/skills/*/SKILL.md` files to their `.claude/skills/*/SKILL.md` targets, including any files that remain documentation-only rather than runtime assets.
8. The migration documentation includes a file-by-file disposition for all `.github/agents/*.agent.md` files, identifying which become project subagents, which become wrapper skills, which remain main-thread-only orchestration logic, and which are personal or library personas that stay out of project scope.
9. The migration documentation identifies the direct-use `.github/prompts/*.prompt.md` entry points that must become `.claude/skills/*/SKILL.md` files rather than `.claude/commands/*` files.
10. The migration documentation distinguishes between repository-enforceable controls (`CLAUDE.md`, `.claude/rules/`, `.claude/settings.json`, `.claude/hooks/*`) and controls that require managed settings outside the repository for non-overrideable enforcement.
11. Subagent tool restrictions correctly block operations outside their declared allowlist (verified by attempting a disallowed operation from within the relevant subagent context).
12. The main-thread orchestrator reads `artifacts/orchestration/orchestrator-state.json` at session start and resumes from the recorded `next_step` rather than restarting from scratch when a valid checkpoint exists.
13. The `PreToolUse` hook blocks at least one representative dangerous-command pattern (for example `rm -rf` or `git push --force`) via the hook script in `.claude/hooks/`.
14. The `SubagentStop` hook blocks premature worker termination when the required completion artifact (plan path, research path, or review artifact path) is absent from the output.
15. A developer can follow the sync strategy documentation in `docs/engineering/claude-code-architecture.md` to determine whether `.claude/` content is current with `.github/` sources and apply updates.
16. The architecture documentation explicitly identifies each non-equivalence between Copilot and Claude and does not claim runtime enforcement for behaviors that are enforced only by prompt conventions.

### Supporting secondary inventory from spec.md

- `Definition of Done`: 10 checkbox items; current checked state is 9 checked and 1 remaining.
- `Seeded Test Conditions`: 7 checkbox items; current checked state is 2 checked and 5 remaining.
- The current remediation did not add evidence that changes the spec checkbox state relative to the previously recorded v2 evidence set.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Research sufficiency stated explicitly | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`; `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |
| 2 | Main-thread orchestrator model | PASS | `p4-t1.claude-runtime-green.2026-04-12T15-57.md`; `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |
| 3 | `/orchestrate` live invocation | UNVERIFIED | Existing `p5-t4.live-skill-validation.2026-04-12T15-57.md` remains blocked | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md` | No transcript-level Claude runtime evidence was added in this remediation. |
| 4 | `/commit-message` live invocation | UNVERIFIED | Existing `p5-t4.live-skill-validation.2026-04-12T15-57.md` remains blocked | same as above | No new live-session evidence. |
| 5 | `/pr-author` live invocation | UNVERIFIED | Existing `p5-t4.live-skill-validation.2026-04-12T15-57.md` remains blocked | same as above | No new live-session evidence. |
| 6 | `/research-issue` live invocation | UNVERIFIED | Existing `p5-t4.live-skill-validation.2026-04-12T15-57.md` remains blocked | same as above | No new live-session evidence. |
| 7 | Canonical `.github/skills` mapping | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |
| 8 | Canonical `.github/agents` disposition | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md`; `p5-t6.disallowed-agent-validation.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |
| 9 | Direct-use prompt mapping to skills | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |
| 10 | Documentation distinguishes repository-enforceable vs managed controls | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | The current blockers do not change the documentation claim itself. |
| 11 | Live subagent allowlist probe | UNVERIFIED | Existing `p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md`; `p5-t4.live-skill-validation.2026-04-12T15-57.md` | `Get-Content` of both evidence files | No live subagent-session probe was added. |
| 12 | Live checkpoint resume behavior | UNVERIFIED | Existing `p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` remains blocked | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` | No transcript-level runtime evidence was added. |
| 13 | `PreToolUse` hook blocks dangerous commands | PASS | `p4-t3.validate-bash-green.2026-04-12T15-57.md`; `p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | `Get-Content tests/scripts/claude-hooks/validate-bash.Tests.ps1` | Unchanged PASS from prior evidence. |
| 14 | `SubagentStop` hook blocks premature worker termination | UNVERIFIED | Existing `p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` does not contain live stop-gate transcript proof | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | No new live stop-gate evidence was added. |
| 15 | Sync strategy is usable by a maintainer | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |
| 16 | Non-equivalences are identified without overstating enforcement | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/engineering/claude-code-architecture.md` | Unchanged PASS from prior evidence. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 7 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. `.claude/settings.json` still fails JSON schema validation on the current PowerShell test-runner permission entry.
2. The canonical multi-folder `mcp__drmCopilotExtension__run_poshqc_test` wrapper still fails before Pester execution.
3. Numeric PowerShell coverage evidence is still unavailable, and all live Claude-session criteria remain UNVERIFIED.

**Recommended follow-up verification steps:**

1. Resolve the schema-compatible settings contract, restore the canonical MCP test wrapper, and regenerate numeric PowerShell coverage evidence.
2. Collect transcript-level Claude runtime evidence for the still-unverified live-session criteria in a separate validation loop.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

No source-file checkbox updates were made in this re-review. All PASS items in `user-story.md` and the supporting `spec.md` inventories were already checked before this review, and all remaining unchecked items stay unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- Total AC items: 33
- Checked off (delivered): 20
- Remaining (unchecked): 13
- Items remaining: `/orchestrate` live invocation; `/commit-message` live invocation; `/pr-author` live invocation; `/research-issue` live invocation; live allowlist probe; live checkpoint resume; live `SubagentStop` proof; supporting spec checkbox items for live invocation, live allowlist, live resume, and live stop-gate validation.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` | 16 | 9 | 7 | Primary checkbox-backed acceptance criteria for this review. |
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` | 17 | 11 | 6 | Supporting checkbox-backed `Definition of Done` and `Seeded Test Conditions`; current state unchanged by this remediation. |
