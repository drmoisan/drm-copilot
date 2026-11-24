# Final QC: generator parity and scope guard (P3-T4)

Timestamp: 2026-11-24T14-50
Command: sh SCRATCH/issue-1223-gen-check.sh (Invoke-HarnessGeneration.ps1 -Surface skills -Check); git diff --name-only 5267cb8294cb933c28ace89647d8283b3ba81404 HEAD -- . ':!.dev/active/1223-docs-epic-scale-routing' (paired with git status --porcelain)
EXIT_CODE: 0
Output Summary:
- Generator -Check: exit 0, "harness-generation: no drift" (AC-10).
- Scope guard: the diff base is the merge base of the epic integration branch and HEAD (5267cb829, the integration tip this feature branched from). Deviation from the plan text, recorded: the merge base of origin/main and HEAD precedes the sibling epic children already merged into the integration branch, so a diff from it lists their .ps1, .ts, and other files and does not isolate this feature. The integration-tip base isolates this feature's own change.
- The name-only diff lists 11 files outside the feature folder: the three .agents sources (documentation-workflow SKILL.md and references/standard.md, execution-environment SKILL.md), the two generated .claude skill copies, the two generated Claude bundle copies, the three Codex bundle copies, and the new test documentation-workflow.EpicRouting.Tests.ps1. It lists no .py file, no .ts file, no .ps1 file other than the new test, and none of .claude/agents/epic-orchestrator.md, .claude/skills/epic-orchestrate/SKILL.md, docs-plan-ia, or the substitutions file (AC-13).
- The porcelain status lists only the plan checkbox edit and the three new final-QC evidence files of this phase, all under the feature folder.
