# Feature Audit: Claude Code architecture v2 post-remediation re-review (#136)

---

**Audit Date:** 2026-04-13
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Base Branch:** `origin/development`
**Head Branch:** `feature/claude-code-architecture-136` plus current working tree
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `origin/development` (`14708b3b0c75ebf36b314f7c1780db1625604ecb`)
- **Head branch/commit:** `feature/claude-code-architecture-136` (`93eea9b6effb35f0842aed0f3a221ef7133ef23f`) plus current working tree
- **Merge base:** `226a39309f3223bd48f3d52a2bc4feca324d34b4`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/**`
  - Additional evidence: `artifacts/orchestration/orchestrator-state.json`
- **Feature folder used:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
- **Requirements source:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- **Work mode resolution note:** `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md` persists `- Work Mode: full-feature`, so both `spec.md` and `user-story.md` remain authoritative.
- **Scope note:** PR context was refreshed against `origin/development` during this review. The latest remediation evidence closes the wrapper defect, but several live-runtime artifacts still lack transcript proof and one checkpoint-resume artifact is stale relative to the current workspace.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` — primary checkbox-backed source
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` — supporting checkbox-backed source

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

### From spec.md

- `Definition of Done`: 17 checkbox items total in the current file state; 11 are checked and 6 remain unchecked.
- The remaining unchecked spec items all correspond to live Claude-session validation or related evidence gaps rather than to the repaired wrapper implementation itself.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Research sufficiency stated explicitly | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 2 | Main-thread orchestrator model | PASS | `p4-t1.claude-runtime-green.2026-04-12T15-57.md`; `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content ...p4-t1.claude-runtime-green...`; `Get-Content ...p4-t2.architecture-doc-green...` | Unchanged PASS. |
| 3 | `/orchestrate` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md` | No transcript-level live Claude evidence was added in this review. |
| 4 | `/commit-message` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | same as above | Unchanged. |
| 5 | `/pr-author` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | same as above | Unchanged. |
| 6 | `/research-issue` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | same as above | Unchanged. |
| 7 | Canonical `.github/skills` mapping | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content ...p4-t2...` | Unchanged PASS. |
| 8 | Canonical `.github/agents` disposition | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md`; `p5-t6.disallowed-agent-validation.2026-04-12T15-57.md` | `Get-Content ...p4-t2...`; `Get-Content ...p5-t6...` | Unchanged PASS. |
| 9 | Direct-use prompt mapping to skills | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content ...p4-t2...` | Unchanged PASS. |
| 10 | Repository-enforceable vs managed-only controls | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content ...p4-t2...` | Unchanged PASS. |
| 11 | Live subagent allowlist probe | UNVERIFIED | `p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md` | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md` | Static permission inspection exists, but no live disallowed-operation transcript was added. |
| 12 | Live checkpoint resume behavior | UNVERIFIED | `p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md`; current `artifacts/orchestration/orchestrator-state.json` | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md`; `Get-Content artifacts/orchestration/orchestrator-state.json` | The prior evidence is stale because it states the checkpoint was absent, but the checkpoint now exists and has live state. |
| 13 | `PreToolUse` dangerous-command block | PASS | `p4-t3.validate-bash-green.2026-04-12T15-57.md`; `p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | `Get-Content ...p4-t3.validate-bash-green...`; `Get-Content ...p5-t3.hook-enforcement-validation...` | Unchanged PASS for documented hook behavior. |
| 14 | `SubagentStop` premature termination block | UNVERIFIED | `p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | `Get-Content docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | Static hook configuration exists, but no live stop-gate transcript was added. |
| 15 | Sync strategy usability | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content ...p4-t2...` | Unchanged PASS. |
| 16 | Non-equivalence documentation is accurate | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | `Get-Content ...p4-t2...` | Unchanged PASS. |

---

## Summary

**Overall Feature Readiness:** BLOCKED

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 7 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. No transcript-level live Claude session proof exists for `/orchestrate`, `/commit-message`, `/pr-author`, or `/research-issue`.
2. No live transcript proof exists for the allowlist probe or the `SubagentStop` gate.
3. The checkpoint-resume evidence artifact is stale because it predates the current canonical checkpoint state.

**Recommended follow-up verification steps:**

1. Capture fresh live Claude session evidence for the seven remaining runtime criteria.
2. Refresh the checkpoint-resume evidence against the current `artifacts/orchestration/orchestrator-state.json`.
3. Regenerate the review artifacts after the live evidence package is available.

The repaired wrapper contract is no longer an open feature blocker. The remaining blockers are evidence-only validation gaps that still prevent a PASS verdict under the repository review rules.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

No source-file checkbox updates were made in this re-review. The current review did not convert any unchecked criterion into a newly supported PASS outcome, and the remaining runtime criteria still lack required transcript evidence.

### AC Status Summary

- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- Total AC items: 33
- Checked off (delivered): 20
- Remaining (unchecked): 13
- Items remaining: `/orchestrate` live invocation; `/commit-message` live invocation; `/pr-author` live invocation; `/research-issue` live invocation; live allowlist probe; live checkpoint resume; live `SubagentStop` proof; supporting spec items for live invocation, live allowlist, live resume, and live stop-gate validation.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` | 16 | 9 | 7 | Checkbox-backed authoritative source. |
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` | 17 | 11 | 6 | Checkbox-backed supporting source. |
