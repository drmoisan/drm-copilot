# Task Check — [P1-T4] (Issue 1025, remediation cycle 2)

Timestamp: 2026-11-17T05-25
Plan: remediation-plan.2026-11-16T06-14.md

## Changed Files

- `.agents/skills/epic-plan/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/references/standard.md`
- `.agents/skills/orchestrate/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/references/standard.md`
- `.agents/skills/translate-copilot-to-claude/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-copilot-to-claude/references/standard.md`

## Selection and Rule

Rule: plan `## Task Check` for a changed contract file under `.agents/skills/**` or its bundle copy: Text Checks (a) and (b) over the changed contracts and (c) over both trees; format, lint and type check N/A (Markdown); the Pester selection `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; the plan A Python contract set (five modules).

## Commands

Command: `sh SCRATCH/issue-1025-textcheck.sh epic-plan,orchestrate,translate-copilot-to-claude` (Text Checks (a), (b), (c))
EXIT_CODE: 1 (the script exits with the status of its final grep guard: 1 means the last grep matched nothing; the pass criteria are LINT_EXIT=0, DIFFERING=0 and each grep exit 1 with 0 lines)
Output Summary:

```text
CONTRACTS_CHECKED: 3 (x2 copies)
VIOLATIONS: 0
LINT_EXIT=0
PAIRS=3 DIFFERING=0
-- tree .agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=1 lines=0
-- tree extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=1 lines=0
```

Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` with the five plan A contract modules
EXIT_CODE: 0
Output Summary: pytest attempt 1 exit 0;  92 passed in 3.63s 

Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` with the four selected test files
EXIT_CODE: 0
Output Summary: pester attempt 1 exit 0; Invoke-PoshQCParallelTest: workers=4; wall-clock=158.2s; exit code=0; per-shard: Tests Passed: 136, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 108, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 18, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 

## Results and Decisions

- Text Check (c): every grep, including the R3–R5 grep, exits 1 with empty output in both trees (the R3–R5 grep was 11 lines per tree in [P0-T1] and 4 after [P1-T1] to [P1-T3]); this meets the [P1-T4] acceptance of 0 lines in both trees.
- None of the four new items names a rule 3 mechanism: no runtime tool name, no standing-instruction file name, no runtime policy-mirror path, no MCP tool name. The only repository data paths named are `config/orchestration-routing.json` and `artifacts/orchestration/epic-planner-state.json` (`epic-plan` OB-1), which rule 3 allows.
- `translate-copilot-to-claude` OB-5 names the runtime configuration file by role ("the runtime configuration file") rather than by path.

## Source-Check Table (4 rows)

| Contract | OB | Source heading | Members the section enumerates | Members the new text names | Prior text | New text | Class closed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| translate-copilot-to-claude | OB-2 | `## Phase 1 — Intake and Section Extraction` | 5 steps in order (read, parse frontmatter, split, classify, record) and the no-modify rule | all named | Read the full file with `Read`. | For each input file the skill reads the full source file, parses its YAML frontmatter (name, description, tools, applyTo, agent, handoffs, model and other keys), splits the body into top-level sections at `#`, `##` and `###` headings, classifies each section as declarative, procedural, enforceable, identity or handoff by the Phase 2 taxonomy, and records each section as `{source_path, heading, classification, raw_content}` in an in-memory list, never modifying or deleting a source file because translation copies forward. | R5 |
| translate-copilot-to-claude | OB-5 | `## Phase 4 — Existing State Diff` | 4 steps in order (read target, per-section delta of 5 kinds, add-only configuration updates, merge for personas) and the conflict rule | all named | `Read` the existing file when it exists. | For every target path the skill reads the existing target file when it exists and computes a per-section delta of add, replace, merge, skip or conflict, computes add-only updates to the hook arrays and allowed permissions of the runtime configuration file without removing an existing permission unless explicitly instructed, prefers merge over replace for agent personas already present, and flags every conflict row in the plan so that the row stops in Phase 6 until it is resolved. | R5 |
| orchestrate | OB-1 | `## Prerequisites` | 4 prerequisites in order: standing instructions, language policies, compliance reading order, execution-environment brief | all named | Read `AGENTS.md` for repository tone policy and architectural context. | Before proceeding, the orchestrator reads the repository standing instructions for tone policy and architectural context, the applicable language policies for the languages in scope, the policy files of the compliance reading order, and the `execution-environment` brief before delegating any worker, so that delegation prompts and plans reference the brief instead of restating tool routes, command-text restrictions, the batch budget, hook context or CI shape. | R5 |
| epic-plan | OB-1 | `## Prerequisites` | 4 reads: standing instructions, language policies, routing config, planner checkpoint | all named | Before proceeding, `epic-planner` must read `AGENTS.md`, the applicable language policies under `.agents/skills/`, `config/orchestration-routing.json`, and any existing `artifacts/orchestration/epic-planner-state.json` checkpoint. | Before proceeding, the epic planner reads the repository standing instructions, the applicable language policies, `config/orchestration-routing.json`, and any existing `artifacts/orchestration/epic-planner-state.json` checkpoint. | R5 |
