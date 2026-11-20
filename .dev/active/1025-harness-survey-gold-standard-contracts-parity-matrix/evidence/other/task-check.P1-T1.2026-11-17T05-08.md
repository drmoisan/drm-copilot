# Task Check — [P1-T1] (Issue 1025, remediation cycle 2)

Timestamp: 2026-11-17T05-08
Plan: remediation-plan.2026-11-16T06-14.md

## Changed Files

- `.agents/skills/acceptance-criteria-tracking/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/references/standard.md`
- `.agents/skills/atomic-plan-contract/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/references/standard.md`
- `.agents/skills/csharp-orchestration-state-machine/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-orchestration-state-machine/references/standard.md`
- `.agents/skills/evidence-and-timestamp-conventions/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/references/standard.md`
- `.agents/skills/policy-audit-template-usage/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/policy-audit-template-usage/references/standard.md`
- `.agents/skills/powershell-orchestration-state-machine/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-orchestration-state-machine/references/standard.md`
- `.agents/skills/review-epic/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/review-epic/references/standard.md`
- `.agents/skills/skill-canonical-location-audit/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/skill-canonical-location-audit/references/standard.md`

## Selection and Rule

Rule: plan `## Task Check` for a changed contract file under `.agents/skills/**` or its bundle copy: Text Checks (a) and (b) over the changed contracts and (c) over both trees; format, lint and type check N/A (Markdown); the Pester selection `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; the plan A Python contract set (five modules).

## Commands

Command: `sh SCRATCH/issue-1025-textcheck.sh acceptance-criteria-tracking,atomic-plan-contract,csharp-orchestration-state-machine,evidence-and-timestamp-conventions,policy-audit-template-usage,powershell-orchestration-state-machine,review-epic,skill-canonical-location-audit` (Text Checks (a), (b), (c))
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
Output Summary: pytest attempt 1 exit 0;  92 passed in 4.02s 

Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` with the four selected test files
EXIT_CODE: 0
Output Summary: pester attempt 1 exit 0; Invoke-PoshQCParallelTest: workers=4; wall-clock=133.21s; exit code=0; per-shard: Tests Passed: 136, Failed: 0, Skipped: 0 Tests Passed: 108, Failed: 0, Skipped: 0 Tests Passed: 18, Failed: 0, Skipped: 0 Tests Passed: 7, Failed: 0, Skipped: 0 

## Results and Decisions

- Text Check (c): greps 1 to 4 and the inputs' R1 form exit 1 with empty output in both trees. The R3–R5 grep returns 4 lines per tree, all of them the R5 items `epic-plan` OB-1, `orchestrate` OB-1 and `translate-copilot-to-claude` OB-2 and OB-5, which [P1-T4] fixes; the plan places the 0-line acceptance for that grep on [P1-T4]. Every R3 and D-C2-1 line is gone (11 to 4).
- Pester shard lines: the selection ran on 4 workers (136 + 108 + 18 + 7 = 269 passed, 0 failed); shard logs 5 to 8 are from the earlier full gate and are not part of this selection.
- Decision D-C2-1 (applied here, autonomous mode): the `Resume Protocol` OB-4 items of `csharp-orchestration-state-machine` and `powershell-orchestration-state-machine` carried the copied ordinal form `On invocation: 1) ... 4) ...`, matched by the inputs' R3–R5 grep. Each is rewritten as one sentence that keeps all four steps. Reason: otherwise Verification Command 3 cannot return nothing.
- Each new item is one line, keeps its `- **OB-<n>** <Heading>: ` prefix, names no runtime tool, standing-instruction file, policy-mirror path or MCP tool name, and names no consuming product.

## Source-Check Table (10 rows)

| Contract | OB | Source heading | Members the section enumerates | Members the new text names | Prior text | New text | Class closed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| acceptance-criteria-tracking | OB-4 | `## AC Status Summary (Required at Completion)` | 6: when (end of plan execution or feature review); fields source, total, checked off, remaining, items remaining; locations executor final report, reviewer feature audit | all named | The executor's final completion report (after last plan task). | At the end of plan execution or feature review, an acceptance-criteria status summary is reported that names the source file or files, the total number of criteria, the number checked off as delivered, the number remaining unchecked and the text of each remaining criterion, and it appears in both the executor's final completion report after the last plan task and the reviewer's feature-audit artifact (Phase F or equivalent). | R3 |
| atomic-plan-contract | OB-4 | `## Short-Path Minimal Plan Contract` | 4 blocks in order: baseline capture, delegated implementation, final QC, reduced audit | all named | 1) Baseline capture block. | When orchestration selects the short path, a minimal plan is still mandatory and contains four blocks in order: a baseline capture block (static baselines and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate, with one artifact per baseline step carrying `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, and pass, fail and coverage values for each test step), a delegated implementation block (an explicit handoff task to the small-path implementation engineer with acceptance criteria for completion), a final QC block (the full format, lint, type-check and test loop, rerun when any step changes files or fails, with one static artifact per language and one artifact per test gate, coverage-mode test commands compared with the `Phase 0 baseline`, and no `SKIPPED` result unless the task text authorizes a skip), and a reduced audit block (an explicit post-implementation small-audit handoff with the reduced artifact checks of the short path). | R3 |
| atomic-plan-contract | OB-5 | `## Minimal-Audit Directive Contract (Small Path)` | the directive plus 6 planner outputs: sole source issue.md, explicit AC section, no spec/user-story/research, 3 phases, unconditional final-QC tasks, plan-path and preflight signal | all named | `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`. | For a short-path planning handoff the orchestrator includes the directive `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`, and the planner then returns a plan that uses `${feature-folder}/issue.md` as its sole requirements source, requires that file to contain an explicit `## Acceptance Criteria` section and treats only that section as the minor-audit acceptance-criteria source, does not require `spec.md`, `user-story.md` or `research.md`, has exactly three phases (Phase 0 baseline capture, a Phase 1 placeholder for constrained small-path implementation and a Phase 2 final QC loop), makes every final-QC command task unconditional with no in-scope or out-of-scope branch and no skipped completion path unless the task text authorizes a skip branch, and returns the `plan-path` and the final preflight signal. | R3 |
| evidence-and-timestamp-conventions | OB-5 | `## Canonical Evidence Discovery Order` | 12 places in order (6 feature, 6 epic), the default use, the remediation-reconciliation exception, the non-canonical rule | all named | Use the list order by default for audit fidelity. | When locating evidence artifacts for audits or plan reconciliation, the default search order for audit fidelity is the feature's `evidence/issue-updates/`, `evidence/regression-testing/`, `evidence/other/`, `evidence/qa-gates/`, `evidence/baseline/` and `evidence/remediation-baseline/` folders, then the same six folders in the same sequence under the epic root; an explicit remediation reconciliation may prefer `remediation-baseline` over `baseline` while still recording the original baseline as the authoritative audit reference, and evidence found anywhere else is recorded as non-canonical with a remediation step to move or copy it into the first applicable canonical location. | R3 |
| policy-audit-template-usage | OB-2 | `## Required Steps` | 6 steps in order: resolve and copy, replace placeholders, remove instructions, mark sections, preserve 13 sections, validate | all named | `## Appendix A: Test Inventory`. | The skill resolves the policy-audit template asset from the packaged template source and copies it to the target location under an ISO-8601 timestamp, replaces the placeholders with actual values (component, date, files under test and commits), removes the template usage instructions, marks each section PASS, FAIL or N/A by the template's conventions, preserves the thirteen canonical major sections in order (Executive Summary, 1. General Unit Test Policy Compliance, 2. General Code Change Policy Compliance, 3. Language-Specific Code Change Policy Compliance, 4. Language-Specific Unit Test Policy Compliance, 5. Test Coverage Detail, 6. Test Execution Metrics, 7. Code Quality Checks, 8. Gaps and Exceptions, 9. Summary of Changes, 10. Compliance Verdict, Appendix A: Test Inventory and Appendix B: Toolchain Commands Reference), and validates the result as a `policy-audit` orchestration artifact, failing closed on any non-zero result. | R3 |
| review-epic | OB-1 | `## Inputs` | 2 inputs: active epic folder path; evidence and child-feature context under the epic folder | all named | Evidence and child-feature context under that epic. | The skill takes two inputs, the path of the active epic folder and the evidence and child-feature context held in the same epic folder. | R3 |
| skill-canonical-location-audit | OB-2 | `## Audit Workflow` | 3 steps in order: inventory, detect duplicates, report (item, conflicting skills, recommendation) | all named | 1) Inventory canonical-location statements. | The audit runs three steps in order: it inventories canonical-location statements by reading each skill file, extracting its explicit canonical location statements (paths, folders and file names) and grouping them by the item they describe; it detects duplicates by verifying that exactly one skill defines each item's canonical location and flagging any item whose canonical location two or more skills define; and it reports the results in a short report that lists each item with a duplicated canonical location, the conflicting skills, and a consolidation recommendation naming the single skill to keep as the source of truth. | R3 |
| skill-canonical-location-audit | OB-3 | `## Output Template (Suggested)` | 3 fields: item, skills with definitions, recommendation | all named | Item: <canonical item name>. | The suggested output gives, for each item with a duplicated canonical location, the canonical item name, the skills with definitions of it, and a recommendation that keeps one named skill as canonical and removes the duplicates from the others. | R3 |
| csharp-orchestration-state-machine | OB-4 | `## Resume Protocol` | 4 steps in order: read checkpoint, resume incomplete, start missing or completed, restart on request | all named | On invocation: 1) Read checkpoint if it exists. 2) If incomplete, resume from `next_step` without re-running `completed_steps`. 3) If missing or completed, start at phase-0 intake. 4) If user explicitly requests restart, reset checkpoint and start phase-0. | On invocation the orchestrator reads the checkpoint if it exists, resumes from `next_step` without re-running `completed_steps` when the checkpoint is incomplete, starts at phase-0 intake when the checkpoint is missing or completed, and resets the checkpoint and starts phase-0 when the user explicitly requests a restart. | R3 |
| powershell-orchestration-state-machine | OB-4 | `## Resume Protocol` | 4 steps in order: read checkpoint, resume incomplete, start missing or completed, restart on request | all named | On invocation: 1) Read checkpoint if it exists. 2) If incomplete, resume from `next_step` without re-running `completed_steps`. 3) If missing or completed, start at phase-0 intake. 4) If user explicitly requests restart, reset checkpoint and start phase-0. | On invocation the orchestrator reads the checkpoint if it exists, resumes from `next_step` without re-running `completed_steps` when the checkpoint is incomplete, starts at phase-0 intake when the checkpoint is missing or completed, and resets the checkpoint and starts phase-0 when the user explicitly requests a restart. | R3 |
