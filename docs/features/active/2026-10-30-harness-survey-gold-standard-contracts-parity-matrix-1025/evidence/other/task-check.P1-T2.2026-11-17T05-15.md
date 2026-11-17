# Task Check — [P1-T2] (Issue 1025, remediation cycle 2)

Timestamp: 2026-11-17T05-15
Plan: remediation-plan.2026-11-16T06-14.md

## Changed Files

- `.agents/skills/csharp-orchestration-state-machine/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-orchestration-state-machine/references/standard.md`
- `.agents/skills/evidence-and-timestamp-conventions/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/references/standard.md`
- `.agents/skills/feature-promotion-lifecycle/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/references/standard.md`
- `.agents/skills/feature-review-workflow/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/references/standard.md`
- `.agents/skills/fill-feature-docs/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/fill-feature-docs/references/standard.md`
- `.agents/skills/policy-compliance-order/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/policy-compliance-order/references/standard.md`
- `.agents/skills/powershell-orchestration-state-machine/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-orchestration-state-machine/references/standard.md`
- `.agents/skills/pr-context-artifacts/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/references/standard.md`

## Selection and Rule

Rule: plan `## Task Check` for a changed contract file under `.agents/skills/**` or its bundle copy: Text Checks (a) and (b) over the changed contracts and (c) over both trees; format, lint and type check N/A (Markdown); the Pester selection `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; the plan A Python contract set (five modules).

## Commands

Command: `sh SCRATCH/issue-1025-textcheck.sh csharp-orchestration-state-machine,evidence-and-timestamp-conventions,feature-promotion-lifecycle,feature-review-workflow,fill-feature-docs,policy-compliance-order,powershell-orchestration-state-machine,pr-context-artifacts` (Text Checks (a), (b), (c))
EXIT_CODE: 0
Output Summary:

```text
CONTRACTS_CHECKED: 8 (x2 copies)
VIOLATIONS: 0
LINT_EXIT=0
PAIRS=8 DIFFERING=0
-- tree .agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=0 lines=4
-- tree extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=0 lines=4
```

Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` with the five plan A contract modules
EXIT_CODE: 0
Output Summary: pytest attempt 1 exit 75;pytest attempt 2 exit 0;  92 passed in 5.77s 

Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` with the four selected test files
EXIT_CODE: 0
Output Summary: pester attempt 1 exit 0; Invoke-PoshQCParallelTest: workers=4; wall-clock=149.27s; exit code=0; per-shard: Tests Passed: 136, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 108, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 18, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 

## Results and Decisions

- Text Check (c): greps 1 to 4 and the inputs' R1 form exit 1 with empty output in both trees; the R3–R5 grep still returns only the 4 R5 lines per tree that [P1-T4] fixes.
- Each source-check row names every member the section enumerates (named-member count equals the source member count, as the Members column states).
- `policy-compliance-order` OB-1 states the order tool-neutrally: the source section names the standing-instruction file three times through a path substitution (cycle 1 decision D2 records the same defect class), and the companion runtime copy orders the standing instructions, the cross-language code-change policy and the cross-language unit-test policy, so the item names those three levels and then the six language and suppression rules by language.
- Pytest attempt 1 exited 75 (queue timeout: the machine test-suite lock was busy); it was re-run and recorded as a queue timeout, not a failure. Attempt 2 exited 0.

## Source-Check Table (9 rows)

| Contract | OB | Source heading | Members the section enumerates | Members the new text names | Prior text | New text | Class closed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| policy-compliance-order | OB-1 | `## Required Policy Reading Order (Baseline)` | 4 levels in order (standing instructions, code-change policy, unit-test policy, language rules) and 6 language rules (Python, Python suppressions, PowerShell, TypeScript, TypeScript suppressions, C#) | all named | Python: `.agents/skills/python/SKILL.md`, `.agents/skills/python-suppressions/SKILL.md`. | When policies conflict, precedence follows the reading order of the repository standing instructions first, then the cross-language code-change policy, then the cross-language unit-test policy, then the language- or domain-specific rules for the files in scope (the Python rule and the Python suppressions rule, the PowerShell rule, the TypeScript rule and the TypeScript suppressions rule, and the C# rule). | R4 |
| evidence-and-timestamp-conventions | OB-3 | `## Canonical Evidence Locations` | 5 locations: baseline, regression-testing, other, qa-gates, issue-updates; plus the epic rollup rule | all named | Baseline evidence: `evidence/baseline/`. | Evidence is stored in five canonical locations under the feature folder, `evidence/baseline/` for baseline evidence, `evidence/regression-testing/` for regression testing evidence, `evidence/other/` for other evidence, `evidence/qa-gates/` for QA gate evidence and `evidence/issue-updates/` for issue update mirrors, and epic rollups may mirror them under the epic root. | R4 |
| csharp-orchestration-state-machine | OB-2 | `## Required Checkpoint Fields` | 14 required fields plus 5 short-path fields | all named | `path_selected` (`small` or `large`). | The checkpoint records `objective`, `change_budget_estimate`, `path_selected` (`small` or `large`), `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode` (`minor-audit`, `full-feature` or `full-bug`, with legacy `full` normalized to `full-feature` before persistence), `plan-path` (the minimal or full plan path), `completed_steps`, `next_step` and `last_updated`, and a short-path run also persists `small_path_qc_summary`, `small_path_audit_artifacts`, `bootstrap_mode` (`manual-bootstrap` or `auto-small-dev`), `phase0_execution_summary` and `resume_after_manual_bootstrap` (the next step token). | R4 |
| powershell-orchestration-state-machine | OB-2 | `## Required Checkpoint Fields` | 14 required fields plus 5 short-path fields | all named | `path_selected` (`small` or `large`). | The checkpoint records `objective`, `change_budget_estimate`, `path_selected` (`small` or `large`), `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode` (`minor-audit`, `full-feature` or `full-bug`, with legacy `full` normalized to `full-feature` before persistence), `plan-path` (the minimal or full plan path), `completed_steps`, `next_step` and `last_updated`, and a short-path run also persists `small_path_qc_summary`, `small_path_audit_artifacts`, `bootstrap_mode` (`manual-bootstrap` or `auto-small-dev`), `phase0_execution_summary` and `resume_after_manual_bootstrap` (the next step token). | R4 |
| feature-promotion-lifecycle | OB-3 | `## Canonical Variables` | 11 canonical variables | all named | `${promotion-type}`: `feature` or `bug`. | The lifecycle uses eleven canonical variables: `${promotion-type}` (`feature` or `bug`), `${short-name}` (a lowercase hyphen-separated slug), `${relativeFile}` (the workspace-relative path of the created potential entry), `${long-name}` (the `${relativeFile}` file name without `.md`), `${issue-num}` (the promoted issue number), `${feature-folder}` (the active feature folder path), `${plan-path}` (the single canonical plan path reused across planning and preflight revisions), `${work-mode}` (`minor-audit`, `full-feature` or `full-bug`, with legacy `full` accepted only as an alias for `full-feature`), `${short-path-flag}` (`--work-mode minor-audit`, mandatory for short-path promotion and folder creation), `${pre-issue-branch}` (`${promotion-type}/${short-name}`, created or verified before issue creation) and `${final-branch}` (`${promotion-type}/${short-name}-${issue-num}`, created by branch rename after promotion returns a numeric issue number). | R4 |
| feature-promotion-lifecycle | OB-4 | `## Required Outputs for Downstream Handoffs` | 5 handoff outputs: issue.md, spec.md, user-story.md, research paths, constraints; plus mode-aware expectations and the persisted marker | all named | `${feature-folder}/issue.md`. | Before delegating research, spec or planning work, the handoff provides `${feature-folder}/issue.md`, `${feature-folder}/spec.md` (or its expected target path), `${feature-folder}/user-story.md` (or an explicit `NONE`), the latest research artifact path or paths, and the constraints, APIs and invariants to preserve, with the spec and user-story expectations set by the selected work mode and exactly one persisted work-mode marker in `issue.md`. | R4 |
| feature-review-workflow | OB-1 | `## Required Shared Skills` | 7 shared skills | all named | `policy-compliance-order`. | The review always applies seven shared skills: `policy-compliance-order`, `evidence-and-timestamp-conventions`, `policy-audit-template-usage`, `pr-context-artifacts`, `pr-base-branch-merge-base`, `acceptance-criteria-tracking` and `remediation-handoff-atomic-planner`. | R4 |
| fill-feature-docs | OB-2 | `## Output Paths` | 2 output paths: spec.md, user-story.md | all named | `docs/features/active/<feature>/spec.md`. | The skill writes two output files, `docs/features/active/<feature>/spec.md` and `docs/features/active/<feature>/user-story.md`. | R4 |
| pr-context-artifacts | OB-1 | `## Canonical Artifact Locations` | 2 locations: summary, appendix | all named | Summary: `artifacts/pr_context.summary.txt`. | The PR context artifacts have two canonical locations, the summary at `artifacts/pr_context.summary.txt` and the appendix at `artifacts/pr_context.appendix.txt`. | R4 |
