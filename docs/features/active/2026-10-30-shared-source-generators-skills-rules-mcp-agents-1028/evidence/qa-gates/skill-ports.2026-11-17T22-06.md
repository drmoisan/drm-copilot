# Skill reconciliation — per-Diff-ID dispositions ([P3-T2])

Timestamp: 2026-11-17T22-06
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-skillports.ps1 -OutFile SCRATCH/issue-1028-skillports-rows.md (reads `survey/difference-approval.md` of child 1, Bulk Approval Set and Disputed Cases); section ports with SCRATCH/issue-1028-port.ps1; substitution sources with SCRATCH/issue-1028-gensubs.ps1 (each derived substitution is verified by rendering the intended Claude copy exactly); ledger check with SCRATCH/issue-1028-regioncheck.ps1
EXIT_CODE: 0
Output Summary: The table below lists all 297 Diff IDs of child 1's approval artifact. Every row targets either a skill selected for the mirror (54) or a D-14 excluded skill (11). Dispositions: 16 `applied`, 141 `not-applicable` and 140 `deferred-ledger-region`. Every Diff ID that targets an excluded skill is `deferred-ledger-region` with the entries `## Constraints` lists for that skill. D-epic-orchestrate-03, -04, -05, -06, -07, -10, -12, -13, -14 and -15 each read `deferred-ledger-region` with entries `0007, 0010`. The ledger check reports no substitution `find` overlapping a recorded region: the `.agents` copy of `remediation-handoff-atomic-planner` keeps its 0003 block `Current` line and `evidence-and-timestamp-conventions` keeps its 0006 hunk, both verbatim. `-Surface skills -Check` reports no drift on the working tree.

Method:
- **`applied`, `claude->codex`.** The Claude section is ported into the shared body `.agents/skills/<name>/SKILL.md` and its bundle copy. Paths are mapped to their Codex counterparts where one exists (`.claude/skills/` to `.agents/skills/`, `.claude/rules/<x>.md` to `.agents/skills/<x>/SKILL.md`, `.claude/agents/<x>.md` to `.codex/agents/<x>.toml`, `.claude/hooks/` to `.codex/hooks/`). The substitution source maps them back for the Claude rendering.
- **`applied`, `codex->claude`.** D-epic-plan-11, owner decision A: the section is ported into the Claude copy and adapted to the Claude checkpoint flags, with no Codex topology, model-routing or launcher receipt requirement.
- **`not-applicable`.** Either the target copy already carries the same guidance under a named equivalent heading, or the section is a tool-specific mechanism whose counterpart the target copy carries. Neutral and mechanism-only differences are also `not-applicable`: each copy keeps its own wording, and the Claude rendering carries the Claude wording through substitutions.
- **Substitution sources.** `scripts/harness-generation/sources/skills/<name>.substitutions.json` holds ordered exact-text substitutions for 39 of the 54 selected skills. The other 15 render byte-equal from the shared body.

Deviation: the task asks to add Claude-only frontmatter keys to the source. Adding `allowed-tools`, `argument-hint`, `context` and `agent` to five `.agents` copies created four new inventoried `codex:skill-frontmatter-field` features that have no matrix entry, so `HarnessParityMatrix.RepoGate.Tests.ps1` failed. Adding those entries would break this task's acceptance that exactly eleven matrix entries change. The keys therefore stay in the Claude rendering only, through the substitution sources, and the `.agents` frontmatter is unchanged (child 1's E2 frontmatter check stays deferred). A later item that adds the four matrix entries can move the keys into the source.

| Diff ID | Skill | Class | Port direction | Disposition | Reason |
| --- | --- | --- | --- | --- | --- |
| D-acceptance-criteria-tracking-01 | acceptance-criteria-tracking | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-adjudicate-unspecified-behavior-01 | adjudicate-unspecified-behavior | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-atomic-plan-contract-01 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-02 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-03 | atomic-plan-contract | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-04 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-05 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-06 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-07 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-08 | atomic-plan-contract | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-09 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-10 | atomic-plan-contract | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-11 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-12 | atomic-plan-contract | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-atomic-plan-contract-13 | atomic-plan-contract | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0008. |
| D-characterize-runtime-behavior-01 | characterize-runtime-behavior | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-commit-message-01 | commit-message | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-change-budget-router-01 | csharp-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-change-budget-router-02 | csharp-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-change-budget-router-03 | csharp-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-change-budget-router-04 | csharp-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-change-budget-router-05 | csharp-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-orchestration-state-machine-01 | csharp-orchestration-state-machine | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-csharp-qa-gate-01 | csharp-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-csharp-qa-gate-02 | csharp-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-csharp-qa-gate-03 | csharp-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-csharp-qa-gate-04 | csharp-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-csharp-qa-gate-05 | csharp-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-csharp-qa-gate-06 | csharp-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-docs-author-page-01 | docs-author-page | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-author-page-02 | docs-author-page | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-author-page-03 | docs-author-page | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-init-01 | docs-init | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-init-02 | docs-init | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-inventory-surface-01 | docs-inventory-surface | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-inventory-surface-02 | docs-inventory-surface | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-inventory-surface-03 | docs-inventory-surface | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-plan-ia-01 | docs-plan-ia | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-plan-ia-02 | docs-plan-ia | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-reconcile-behavior-01 | docs-reconcile-behavior | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-reconcile-behavior-02 | docs-reconcile-behavior | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-reconcile-behavior-03 | docs-reconcile-behavior | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-review-coverage-01 | docs-review-coverage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-review-coverage-02 | docs-review-coverage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-review-coverage-03 | docs-review-coverage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-validate-01 | docs-validate | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-validate-02 | docs-validate | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-docs-validate-03 | docs-validate | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-documentation-workflow-01 | documentation-workflow | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-documentation-workflow-02 | documentation-workflow | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-orchestrate-01 | epic-orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-02 | epic-orchestrate | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-03 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-04 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-05 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-06 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-07 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-08 | epic-orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-09 | epic-orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-10 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-11 | epic-orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-12 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-13 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-14 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-15 | epic-orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-16 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-17 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-18 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-19 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-20 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-21 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-22 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-23 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-24 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-25 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-26 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-27 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-28 | epic-orchestrate | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-orchestrate-29 | epic-orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0007, 0010. |
| D-epic-plan-01 | epic-plan | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-02 | epic-plan | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-03 | epic-plan | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-04 | epic-plan | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-05 | epic-plan | mechanism-only | none | not-applicable | mechanism-only: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-06 | epic-plan | positive | codex->claude | not-applicable | The Claude copy carries the same guidance under `### Integration Commit Form (issue #539)`; porting would duplicate it. |
| D-epic-plan-07 | epic-plan | positive | codex->claude | not-applicable | Codex child-launch mechanism (launcher script, `spawn_agent` restriction); the Claude copy carries its own mechanism under `## Preparation-Mode Child Delegation`. |
| D-epic-plan-08 | epic-plan | positive | codex->claude | not-applicable | The Claude copy carries the same contract under `### Child run contract (route_id: preparation)`. |
| D-epic-plan-09 | epic-plan | positive | codex->claude | not-applicable | The Claude copy carries the same guidance under `## Fan-In to the Integration Branch`. |
| D-epic-plan-10 | epic-plan | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-11 | epic-plan | positive (disputed, owner A) | codex->claude | applied | Owner decision A: `## Execution-Readiness Gate` is ported into the Claude copy, adapted to the Claude checkpoint flags (no Codex topology or Codex model-routing receipt requirement). |
| D-epic-plan-12 | epic-plan | positive | codex->claude | not-applicable | The Claude copy carries the same guidance under `## Kickoff Prompt Artifact`. |
| D-epic-plan-13 | epic-plan | positive | codex->claude | not-applicable | The Claude copy carries the same guidance under `## Checkpoint Handling` and `## Completion Report`. |
| D-epic-plan-14 | epic-plan | positive | claude->codex | applied | `## Epic-Level Issue Promotion` is ported into the shared body (`.agents` copy), with Claude paths mapped to Codex counterparts. |
| D-epic-plan-15 | epic-plan | positive | claude->codex | applied | `## Complexity Assessment` is ported into the shared body (`.agents` copy). |
| D-epic-plan-16 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same guidance under `## Integration Branch`. |
| D-epic-plan-17 | epic-plan | positive | claude->codex | not-applicable | Claude child-delegation mechanism; the shared body carries the Codex mechanism under `## Concurrent Preparation`. |
| D-epic-plan-18 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same contract under `## Preparation Route Contract`. |
| D-epic-plan-19 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same `cross_epic_depends_on` paragraph inside `## Preparation Route Contract`. |
| D-epic-plan-20 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same guidance under `## Fan-In`. |
| D-epic-plan-21 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same guidance under `## Kickoff Artifacts`. |
| D-epic-plan-22 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same guidance under `## Integration Commit Form`. |
| D-epic-plan-23 | epic-plan | mechanism-only | none | not-applicable | mechanism-only: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-epic-plan-24 | epic-plan | positive | claude->codex | not-applicable | The shared body carries the same guidance under `## Checkpoint and Completion`. |
| D-epic-plan-25 | epic-plan | positive | claude->codex | not-applicable | Claude Code runtime mechanism (`Agent` tool spawn depth, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`) with no Codex counterpart; it stays in the Claude rendering through substitution. |
| D-epic-run-01 | epic-run | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0010. |
| D-epic-run-02 | epic-run | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0010. |
| D-epic-run-03 | epic-run | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0010. |
| D-epic-run-04 | epic-run | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0010. |
| D-evidence-and-timestamp-conventions-01 | evidence-and-timestamp-conventions | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-execute-hard-lock-01 | execute-hard-lock | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-execute-hard-lock-02 | execute-hard-lock | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-execute-hard-lock-03 | execute-hard-lock | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-execute-hard-lock-04 | execute-hard-lock | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-extract-feature-contract-01 | extract-feature-contract | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-01 | feature-promotion-lifecycle | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-02 | feature-promotion-lifecycle | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-03 | feature-promotion-lifecycle | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-04 | feature-promotion-lifecycle | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-05 | feature-promotion-lifecycle | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-06 | feature-promotion-lifecycle | positive | claude->codex | applied | `## Pre-Existing Issue Path` is ported into the shared body, with `.claude/rules/orchestrator-state.md` mapped to `.agents/skills/orchestrator-state/SKILL.md`. |
| D-feature-promotion-lifecycle-07 | feature-promotion-lifecycle | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-feature-promotion-lifecycle-08 | feature-promotion-lifecycle | negative (disputed, owner A) | none | not-applicable | Negative on the Copilot copy, which this child does not generate; neither the shared body nor the Claude copy carries the non-MCP fallback, so the negative already holds. |
| D-feature-promotion-lifecycle-09 | feature-promotion-lifecycle | negative (disputed, owner A) | none | not-applicable | Negative on the Copilot copy, which this child does not generate; neither the shared body nor the Claude copy carries the non-MCP fallback, so the negative already holds. |
| D-feature-promotion-lifecycle-10 | feature-promotion-lifecycle | negative (disputed, owner A) | none | not-applicable | Negative on the Copilot copy, which this child does not generate; neither the shared body nor the Claude copy carries the fallback command sequence. |
| D-feature-promotion-lifecycle-11 | feature-promotion-lifecycle | negative (disputed, owner A) | none | not-applicable | Negative on the Copilot copy, which this child does not generate; neither the shared body nor the Claude copy carries the fallback command sequence. |
| D-feature-promotion-lifecycle-12 | feature-promotion-lifecycle | negative (disputed, owner A) | none | not-applicable | Negative on the Copilot copy, which this child does not generate; neither the shared body nor the Claude copy carries the fallback short-path sequence. |
| D-feature-promotion-lifecycle-13 | feature-promotion-lifecycle | negative (disputed, owner A) | none | not-applicable | Negative on the Copilot copy, which this child does not generate; neither the shared body nor the Claude copy carries the fallback short-path sequence. |
| D-feature-review-workflow-01 | feature-review-workflow | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-02 | feature-review-workflow | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-03 | feature-review-workflow | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-04 | feature-review-workflow | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-05 | feature-review-workflow | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-06 | feature-review-workflow | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-07 | feature-review-workflow | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-08 | feature-review-workflow | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-09 | feature-review-workflow | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-feature-review-workflow-10 | feature-review-workflow | mechanism-only | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006. |
| D-fill-feature-docs-01 | fill-feature-docs | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-fill-feature-docs-02 | fill-feature-docs | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-generate-acceptance-scenarios-01 | generate-acceptance-scenarios | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-human-exception-runbook-01 | human-exception-runbook | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-human-exception-runbook-02 | human-exception-runbook | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-initialize-discovery-workspace-01 | initialize-discovery-workspace | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-inventory-legacy-system-01 | inventory-legacy-system | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-invoke-csharp-engineer-01 | invoke-csharp-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-csharp-engineer-02 | invoke-csharp-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-csharp-engineer-03 | invoke-csharp-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-csharp-engineer-04 | invoke-csharp-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-csharp-engineer-05 | invoke-csharp-engineer | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-powershell-engineer-01 | invoke-powershell-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-powershell-engineer-02 | invoke-powershell-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-powershell-engineer-03 | invoke-powershell-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-powershell-engineer-04 | invoke-powershell-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-powershell-engineer-05 | invoke-powershell-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-powershell-engineer-06 | invoke-powershell-engineer | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-python-engineer-01 | invoke-python-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-python-engineer-02 | invoke-python-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-python-engineer-03 | invoke-python-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-python-engineer-04 | invoke-python-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-python-engineer-05 | invoke-python-engineer | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-invoke-python-engineer-06 | invoke-python-engineer | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-make-skill-template-01 | make-skill-template | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-orchestrate-01 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-02 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-03 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-04 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-05 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-06 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-07 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-08 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-09 | orchestrate | positive (disputed, owner A) | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-10 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-11 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-12 | orchestrate | positive (disputed, owner A) | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-13 | orchestrate | positive (disputed, owner A) | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-14 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-15 | orchestrate | positive (disputed, owner A) | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-16 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-17 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-18 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-19 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-20 | orchestrate | positive | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-21 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-22 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-23 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-24 | orchestrate | positive (disputed, owner A) | codex->claude | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-25 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-26 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-27 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-28 | orchestrate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-29 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-30 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-31 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-32 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-33 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-34 | orchestrate | positive (disputed, owner A) | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-35 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-36 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-37 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-38 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-39 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-40 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-41 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-42 | orchestrate | positive (disputed, owner A) | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-43 | orchestrate | positive (disputed, owner A) | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-44 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-45 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-46 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-47 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-48 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-49 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-50 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-orchestrate-51 | orchestrate | positive | claude->codex | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0003. |
| D-policy-audit-template-usage-01 | policy-audit-template-usage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-policy-audit-template-usage-02 | policy-audit-template-usage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-policy-audit-template-usage-03 | policy-audit-template-usage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-policy-compliance-order-01 | policy-compliance-order | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-policy-compliance-order-02 | policy-compliance-order | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-powershell-change-budget-router-01 | powershell-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-powershell-change-budget-router-02 | powershell-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-powershell-change-budget-router-03 | powershell-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-powershell-orchestration-state-machine-01 | powershell-orchestration-state-machine | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-powershell-orchestration-state-machine-02 | powershell-orchestration-state-machine | positive | claude->codex | applied | `## Portable Prepared-State Projection` is ported into the shared body. |
| D-powershell-orchestration-state-machine-03 | powershell-orchestration-state-machine | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-powershell-qa-gate-01 | powershell-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-powershell-qa-gate-02 | powershell-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-powershell-qa-gate-03 | powershell-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-powershell-qa-gate-04 | powershell-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-powershell-qa-gate-05 | powershell-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-pr-author-01 | pr-author | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-pr-author-02 | pr-author | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-pr-author-03 | pr-author | positive | claude->codex | applied | `## Output Artifact` is ported into the shared body. |
| D-pr-author-04 | pr-author | positive | claude->codex | applied | `## Closing-Reference Verification` is ported into the shared body. |
| D-pr-author-05 | pr-author | positive | claude->codex | applied | `## Required `--head` on `gh pr create` (issue #687)` is ported into the shared body. |
| D-pr-author-06 | pr-author | positive | claude->codex | applied | `## Coordinator-Session Topology (issue #1011)` is ported into the shared body. |
| D-pr-base-branch-merge-base-01 | pr-base-branch-merge-base | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-pr-base-branch-merge-base-02 | pr-base-branch-merge-base | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-pr-base-branch-merge-base-03 | pr-base-branch-merge-base | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-pr-base-branch-merge-base-04 | pr-base-branch-merge-base | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-pr-context-artifacts-01 | pr-context-artifacts | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-python-change-budget-router-01 | python-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-python-change-budget-router-02 | python-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-python-change-budget-router-03 | python-change-budget-router | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-python-qa-gate-01 | python-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-python-qa-gate-02 | python-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-python-qa-gate-03 | python-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-python-qa-gate-04 | python-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-python-qa-gate-05 | python-qa-gate | neutral | none | deferred-ledger-region | Skill excluded from the mirror under D-14; entries 0006, 0001. |
| D-reconcile-parity-matrix-01 | reconcile-parity-matrix | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-01 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-02 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-03 | remediation-handoff-atomic-planner | positive | codex->claude | not-applicable | The Claude copy carries the same guidance under `## Trigger Conditions`. |
| D-remediation-handoff-atomic-planner-04 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-05 | remediation-handoff-atomic-planner | positive | codex->claude | not-applicable | The Claude copy carries the same guidance under `## Full Handoff Chain` and `## Plan Shape`. |
| D-remediation-handoff-atomic-planner-06 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-07 | remediation-handoff-atomic-planner | positive | claude->codex | applied | `## Full Handoff Chain` is ported into the shared body, with Claude paths mapped to Codex counterparts. |
| D-remediation-handoff-atomic-planner-08 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-09 | remediation-handoff-atomic-planner | positive | claude->codex | not-applicable | The shared body carries the same guidance under `## Trigger Conditions (Generic)`. |
| D-remediation-handoff-atomic-planner-10 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-11 | remediation-handoff-atomic-planner | positive | claude->codex | applied | `## Required Artifacts` (with its `### Cycle-Document Sweep Scope`) is ported into the shared body. |
| D-remediation-handoff-atomic-planner-12 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-13 | remediation-handoff-atomic-planner | positive | claude->codex | applied | `### Cycle-Document Sweep Scope` is ported into the shared body inside `## Required Artifacts`. |
| D-remediation-handoff-atomic-planner-14 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-15 | remediation-handoff-atomic-planner | positive | claude->codex | applied | `## Plan Shape` is ported into the shared body. |
| D-remediation-handoff-atomic-planner-16 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-17 | remediation-handoff-atomic-planner | positive (disputed, owner A) | claude->codex | applied | Owner decision A: `## Preflight Sub-Loop` is ported into the shared body. |
| D-remediation-handoff-atomic-planner-18 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-19 | remediation-handoff-atomic-planner | positive | claude->codex | applied | `## Execution and Reaudit` is ported into the shared body. |
| D-remediation-handoff-atomic-planner-20 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-remediation-handoff-atomic-planner-21 | remediation-handoff-atomic-planner | positive (disputed, owner A) | claude->codex | applied | Owner decision A: `## Exit Gate` is ported into the shared body. |
| D-remediation-handoff-atomic-planner-22 | remediation-handoff-atomic-planner | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-research-issue-01 | research-issue | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-research-issue-02 | research-issue | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-research-issue-03 | research-issue | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-research-issue-04 | research-issue | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-research-issue-05 | research-issue | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-review-discovery-coverage-01 | review-discovery-coverage | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-skill-canonical-location-audit-01 | skill-canonical-location-audit | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-01 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-02 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-03 | translate-copilot-to-claude | positive (disputed, owner A) | codex->claude | not-applicable | Owner decision A is met without new text: the section differs only by tool root, and the Claude copy carries it as `2.1 ... -> .claude/hooks/`. |
| D-translate-copilot-to-claude-04 | translate-copilot-to-claude | positive | codex->claude | not-applicable | Differs only by tool root; the Claude copy carries it as `2.2 ... -> .claude/rules/`. |
| D-translate-copilot-to-claude-05 | translate-copilot-to-claude | positive | codex->claude | not-applicable | Differs only by tool root; the Claude copy carries it as `2.3 ... -> .claude/skills/<name>/SKILL.md`. |
| D-translate-copilot-to-claude-06 | translate-copilot-to-claude | positive | codex->claude | not-applicable | Differs only by tool root; the Claude copy carries it as `2.4 ... -> .claude/agents/<name>.md`. |
| D-translate-copilot-to-claude-07 | translate-copilot-to-claude | positive | codex->claude | not-applicable | Differs only by tool root; the Claude copy carries it as `2.6 ... -> CLAUDE.md`. |
| D-translate-copilot-to-claude-08 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-09 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-10 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-11 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-12 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-13 | translate-copilot-to-claude | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
| D-translate-copilot-to-claude-14 | translate-copilot-to-claude | positive (disputed, owner A) | claude->codex | not-applicable | Owner decision A is met without new text: the section differs only by tool root, and the shared body carries it as `2.1 ... -> .codex/hooks/`. |
| D-translate-copilot-to-claude-15 | translate-copilot-to-claude | positive | claude->codex | not-applicable | Differs only by tool root; the shared body carries it as `2.2 ... -> .agents/skills/`. |
| D-translate-copilot-to-claude-16 | translate-copilot-to-claude | positive | claude->codex | not-applicable | Differs only by tool root; the shared body carries it as `2.3 ... -> .agents/skills/<name>/SKILL.md`. |
| D-translate-copilot-to-claude-17 | translate-copilot-to-claude | positive | claude->codex | not-applicable | Differs only by tool root; the shared body carries it as `2.4 ... -> .codex/agents/<name>.md`. |
| D-translate-copilot-to-claude-18 | translate-copilot-to-claude | positive | claude->codex | not-applicable | Differs only by tool root; the shared body carries it as `2.6 ... -> AGENTS.md`. |
| D-validate-discovery-artifacts-01 | validate-discovery-artifacts | neutral | none | not-applicable | neutral: no port; each copy keeps its wording and the Claude rendering carries the Claude wording through substitutions. |
