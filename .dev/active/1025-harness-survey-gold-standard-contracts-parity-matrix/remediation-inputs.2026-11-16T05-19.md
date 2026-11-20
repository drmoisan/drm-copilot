# Remediation Inputs — Issue 1025 (initial review)

Timestamp: 2026-11-16T05-19
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Issue: 1025
Base: epic/shared-agent-harness-layer-integration
Merge-Base: bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee
Reviewed-Head: 4d23522173644d386848a8651d5267274a6407c9
Source review artifacts:
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/policy-audit.2026-11-16T05-19.md`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/code-review.2026-11-16T05-19.md`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/feature-audit.2026-11-16T05-19.md`

## Disposition

Policy compliance passes and 41 of 43 acceptance criteria evaluate PASS; the remaining two are CI-dependent and pending the pull request head, which is expected and is not a remediation item. Two findings in the content of the gold-standard contracts require a fix before merge. Both come from the session contract generator and are of the same class as the plan A P3-T8 `## Owner Questions` table: text that passes the structural lint but is truncated or substituted.

The path is light: two findings, both autonomous and contained; the fix edits only contract files already in the branch diff and their bundle mirrors; no spec acceptance criterion, public interface, schema, validator contract, hook decision or production logic changes; the cycle is opened by this review, and no prior cycle exists.

## Finding R1 (code review CR-1)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the contract files and their bundle copies are on this branch and can be corrected from the source SKILL.md sections in the item worktree, with no external dependency or owner input.
Finding-Scope: contained

- Location: `## Observable Behaviors` of these `.agents/skills/<name>/references/standard.md` files and their copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`: `csharp-change-budget-router` (OB-2), `csharp-qa-gate` (OB-1, OB-5), `docs-author-page` (OB-1), `docs-init` (OB-1), `docs-inventory-surface` (OB-1), `docs-plan-ia` (OB-1), `docs-reconcile-behavior` (OB-1), `docs-review-coverage` (OB-1), `docs-validate` (OB-1), `documentation-workflow` (OB-1), `epic-plan` (OB-4), `epic-run` (OB-1), `feature-promotion-lifecycle` (OB-2), `human-exception-runbook` (OB-5), `powershell-change-budget-router` (OB-2, OB-4), `powershell-qa-gate` (OB-1, OB-5), `pr-base-branch-merge-base` (OB-5), `python-change-budget-router` (OB-4), `python-qa-gate` (OB-1, OB-5), `remediation-handoff-atomic-planner` (OB-1), `test-execution-policy` (OB-1, OB-5). 25 items in 21 files.
- Observed: 24 items end in a truncated fragment (`;.` or `,.`), for example `test-execution-policy` OB-1 "The suite name is the first argument;."; `feature-promotion-lifecycle` OB-2 refers to "the MCP tool forms listed above", which the contract does not contain.
- Required: each item is a complete, tool-neutral behavior sentence drawn from the source `SKILL.md` section that the item names; the `- **OB-<n>** ` prefix, numbering and the `AC-<n>` citations stay unchanged; each bundle copy stays byte-identical. Afterwards `grep -n ";\.$\|,\.$\|:\.$\|listed above" .agents/skills/*/references/standard.md` returns nothing.

## Finding R2 (code review CR-2)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the specific objective for each skill is already recorded in the batch records on this branch, so the fix copies existing text with no external dependency or owner input.
Finding-Scope: contained

- Location: `## Objective` of `.agents/skills/{csharp-change-budget-router,execute-hard-lock,feature-promotion-lifecycle,make-skill-template,powershell-change-budget-router,pr-base-branch-merge-base,translate-copilot-to-claude}/references/standard.md` and their bundle copies. 7 files.
- Observed: the first sentence is the placeholder "Produce the outcome that the <name> skill exists for, with the same observable result in every tool that runs it." instead of the `Objective (draft)` text of the skill's batch record (for example `survey/batch-c-integration.md` `### feature-promotion-lifecycle`).
- Required: the first sentence is the batch-record `Objective (draft)` text, made tool-neutral where it names a tool-specific mechanism; the second sentence ("This standard states the behavior that every expression of the skill must show...") stays; each bundle copy stays byte-identical. Afterwards `grep -l "Produce the outcome that the" .agents/skills/*/references/standard.md` returns nothing.

## Light Fix Tasks

- [x] [P0-T1] Fix finding R1 in the 21 contracts named under Finding R1 (`.agents/skills/<name>/references/standard.md`, 25 Observable Behavior items) and copy each byte for byte to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`.
- [x] [P0-T2] Fix finding R2 in the 7 contracts named under Finding R2 (`.agents/skills/<name>/references/standard.md`, `## Objective`) and copy each byte for byte to the bundle mirror; then run the parallel Pester gate (including `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`) and the Python bundle-parity contract set, and record the results under `evidence/qa-gates/`.

## Non-remediation notes

- Info (code review CR-3): bulk-approval rationales are templated and classes follow section presence; approved at the owner stop. Child 3 should confirm each `positive` port direction against the skill objective before porting.
- Info (code review CR-4): `Approved-By` records the autonomous orchestrator decision rather than the owner's handle.
- Info (code review CR-5, CR-6, CR-8) and Nit (CR-7): no change required.
- Pending-CI: spec `Required CI check` and the user-story completeness-gate criterion are checked off by the orchestrator at S9.
- These items do not gate the PR.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
