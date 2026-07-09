# Remaining Technical Debt Audit

Date: 2026-07-09
Scope: `docs/features/completed/**`, `docs/features/archive/**`, `docs/features/active/**`, `docs/features/research/**`, `docs/research/**`, `docs/engineering/**`, `README.md` at repo root.
Method: local grep across the documentation tree for debt/limitation/follow-up terminology and headings, targeted reads of matching sections, and verification of current repository state (file existence, hook wiring, rule content) against each claim. GitHub issue status was checked via the public GitHub REST search API (`api.github.com/search/issues`) rather than the `gh` CLI, because no shell/CLI tool was available in this session; results were cross-checked against local `docs/features/active/` and `docs/features/potential/` content.

## Automation Feasibility

N/A — no third-party UI interaction; local grep and `gh issue list` only.

## Resolved or Already Tracked

| Item | Source | Resolution/Tracking reference |
|---|---|---|
| Cross-language new-code delta coverage gate (TS/C#/PowerShell) — Decision L item, out of scope for issue #181 | `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/spec.md:426-439`, `remediation-inputs.2026-06-13T19-53.md` RF-1 | Open GitHub issue #182 ("Evaluate cross-language new-code delta coverage gate (TS/C#/PowerShell)") |
| Test-purity hooks for TypeScript and C# — Decision L item | Same source as above | Open GitHub issue #183 ("Add test-purity hooks for TypeScript and C#") |
| Batch-budget hooks for TypeScript and C# — Decision L item | Same source as above | Open GitHub issue #184 ("Add batch-budget hooks for TypeScript and C#") |
| Prioritized follow-up changes ported from a comparison-repo hardening audit (7 items: `Test-HumanInteractionShape`, `Test-AutomationFeasibilitySection`, orchestrate `## Autonomous-Execution Mandate`, `human-exception-runbook` skill, `human_interaction` invariants in the Python validator, `## Coverage Exclusion Policy` / `## Test File Location` in `general-unit-test.md`, `remediation-handoff-atomic-planner/SKILL.md` replacement) | `docs/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md` section 7 | Verified present in current repo: `.claude/hooks/validate-orchestrator-output.ps1` contains `Test-HumanInteractionShape`; `.claude/hooks/validate-task-researcher-output.ps1` contains `Test-AutomationFeasibilitySection`; `.claude/skills/orchestrate/SKILL.md` contains an Autonomous-Execution Mandate section; `.claude/skills/human-exception-runbook/{SKILL.md,example.runbook.md}` exist; `.claude/rules/orchestrator-state.md` and `.claude/rules/general-unit-test.md` contain the described sections. All 7 items implemented. |
| Stale MCP function names (`mcp__drmCopilotExtension__*`) in `.claude/rules/powershell.md`, flagged as a separate defect for issue #151 | `docs/research/20260417-github-instructions-not-migrated-to-claude-151-research.md:166,182-184` | Verified resolved: current `.claude/rules/powershell.md` uses `mcp__drm-copilot__run_poshqc_*`; neither the old stale name nor the once-canonical replacement name from the research doc is present, confirming the file has been updated since. |
| PowerShell branch-coverage allow-list gap for `scripts/dev-tools/new-claude-worktree-session.ps1` | `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/other/2026-07-07T12-48-acceptance-verification.md` "Notes / Findings" | Verified resolved: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` now includes `scripts/dev-tools/new-claude-worktree-session.ps1`. |
| `extensions/drm-copilot/README.md` stale "Scaffold Extension" / "Scaffold Utils" branding | `docs/features/archive/2026-03-09-push-down-copilot-customizations-84/audit-2026-03-11T07-42/{code-review,remediation-inputs}.2026-03-11T07-42.md` | Verified resolved: no matches for the stale strings in the current README. |
| `extension.ts` line-count / `Any`-typed Python wrapper boundary in `push_down_copilot_customizations.py` | Same source as above | Superseded: `extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py` no longer exists in the repository (the push-down command path was later ported to TypeScript per `docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/initiative.md`), so the original remediation target is moot. |
| "Honest Enforcement Strength (Known Limitation)" — sentinel-based `pr-author` enforcement is a policy guardrail, not a cryptographic control | `docs/features/completed/2026-06-24-require-pr-author-agent-for-prs-231/spec.md:57-61` | Not omitted work — an explicitly accepted, documented design limitation (the mechanism intentionally is not cryptographically non-bypassable; spec section 3.2 lists this as Out of Scope by design). No remediation is implied or pending. |
| Deferred epic-status hand-edit guard and migration-of-existing-epics follow-ups | `docs/features/active/2026-07-07-epic-single-home-manifest-331/spec.md:409,421` | Already tracked — recorded inside a currently active feature folder, not an orphaned gap. |

## Still Outstanding

### codex-pr-author-hook-not-wired

**Problem statement:** The bundled Codex mirror hook `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` exists and carries the same PR-authorization-sentinel enforcement logic as the root Claude hook, but the sibling bundled `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` has no `[[hooks.PreToolUse]]` entry referencing it. As a result, any Codex-ecosystem agent that calls `gh pr create` or `gh pr edit` in a consumer repository that has received this push-down bundle is not actually protected by the sentinel check, even though the hook file itself is present and current. The root repository's own `.codex/config.toml` and `.codex/hooks/` likewise contain no `enforce-pr-author-skill.ps1` hook or wiring.

**Source citations:**
- `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/follow-up-codex-wiring-gap.md` — "the Codex hook body receives the contract-parity edit in this feature's scope, but it has no runtime effect in the Codex ecosystem as currently configured, because nothing invokes it."
- `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md:54,229` — "The Codex mirror hook is currently an orphaned artifact (not wired into any Codex hook list)... Codex mirror re-wiring gap remains unresolved."
- Verified directly: no `enforce-pr-author-skill` match in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, despite the hook file existing at the sibling `hooks/` path; no `enforce-pr-author-skill.ps1` file or wiring in the root `.codex/hooks/` or `.codex/config.toml`.
- GitHub issue search (`api.github.com/search/issues`, repo `drmoisan/drm-copilot`) for "codex config.toml hook", "codex pr-author hook" returned no dedicated open issue.

**Suggested severity/impact:** Medium. The gap is confined to the Codex ecosystem's enforcement of PR-authorship delegation; Claude-ecosystem enforcement (the primary runtime) is unaffected. Impact scales with how many consumer repositories rely on Codex agents to call `gh pr create`/`gh pr edit`.

### quality-tiers-yml-missing-at-repo-root

**Problem statement:** `.claude/rules/quality-tiers.md` (and `.claude/rules/general-code-change.md`) state that `quality-tiers.yml` at the repository root is the source of truth mapping every project to a T1–T4 rigor tier, and that "adding a project without a tier classification fails CI." No `quality-tiers.yml` file currently exists at the repository root. This means the tier-classification CI gate that the rule files describe currently has no data file to validate against.

**Source citations:**
- `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/follow-up-quality-tiers-gap.md` — "`quality-tiers.yml` does not currently exist at the repository root... This is a pre-existing, orthogonal gap... Explicitly out of scope for issue #272."
- Verified directly: `Glob` for `quality-tiers.yml` at repo root returns no match.
- GitHub issue search for "quality-tiers.yml" and "quality-tiers" returned no open or closed issue.
- No matching entry found under `docs/features/active/` or `docs/features/potential/`.

**Suggested severity/impact:** Low-to-Medium. The rule text is aspirational/inaccurate until the file exists, which could mislead an agent or reviewer into believing an automated tier gate is active when it is not. No evidence that any CI stage currently depends on the missing file failing closed.

### orchestrator-state-audit-trail-deferred

**Problem statement:** The orchestration-enforcement-hardening feature (issue #253) diagnosed six enforcement gaps in `artifacts/orchestration/orchestrator-state.json` handling and closed five of them (Gaps 1-5) plus a routing-matrix agent-name reconciliation. Gap 6 — a checkpoint-transition audit trail (an append-only `artifacts/orchestration/orchestrator-state.log.jsonl`, capped at 100 entries, readable by the monotonic-checkpoint hook for forensic context on a block) — was explicitly deferred as "diagnostic rather than preventive" and marked out of scope for that feature's Definition of Done.

**Source citations:**
- `docs/research/20260626-orchestration-enforcement-hardening-research.md:509-513` ("Gap 6 — Audit Trail (Low Priority, Deferred)").
- `docs/features/completed/2026-06-26-orchestration-enforcement-hardening-253/{user-story.md:57, spec.md:25,67,96, issue.md:27, plan.2026-06-26T15-50.md:17}` — consistent statements that Gap 6 is deferred/out of scope.
- Verified directly: no `orchestrator-state.log.jsonl` file or `Test-AuditTrail`-style logic in `.claude/hooks/` or `scripts/dev_tools/`.
- GitHub issue search confirms issue #253 (which named the gap) is closed, and no separate open issue tracks Gap 6 specifically.
- No matching entry found under `docs/features/active/` or `docs/features/potential/`.

**Suggested severity/impact:** Low. The feature's own classification of this gap as diagnostic (not preventive) and low priority is consistent with the evidence; the five preventive gaps it depended on are closed.

## Needs Human Judgment

- **Repo-wide test coverage below the 85%/75% policy threshold.** `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/remediation-inputs.2026-06-13T19-53.md` OB-1 records combined line+branch coverage TOTAL at 82% as of 2026-06-13, described as "long-standing repository state and... not a feature-blocking finding," with "Repository-wide coverage uplift is a separate concern." This audit did not re-run coverage tooling (out of scope for a documentation-grep task) so the current figure is unverified, and no open issue or active/potential entry names a scoped uplift effort. Whether this constitutes an actionable backlog item versus an ambient metric that most individual features already avoid regressing is a judgment call outside grep-based evidence gathering.
