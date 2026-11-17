# QA Gate — Light Remediation Cycle 3 (Issue 1025)

Timestamp: 2026-11-17T07-38
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-inputs.2026-11-17T06-52.md (`## Light Fix Tasks`, Remediation-Mode: light)
Findings: R6 (code review CR-15), R7 (code review CR-16), optional CR-17 alignment, plus the same-class sweep of all 65 contracts
Rewrite rules: `## Rewrite Rules` of `remediation-plan.2026-11-16T06-14.md`
Base head before the cycle: 89fa11914

## Summary

- [P0-T1] done: `python-change-budget-router` OB-3 (R6) and OB-1 (CR-17 alignment). Task-check record: `evidence/other/task-check.P0-T1.2026-11-17T07-07.md`.
- [P0-T2] done: `execution-environment` OB-4 (R7). Task-check record: `evidence/other/task-check.P0-T2.2026-11-17T07-10.md`.
- Same-class sweep: 1 further item, `human-exception-runbook` OB-5 (R4 class, count without members).
- Total: 3 contracts, 4 items, each in `.agents/skills/<name>/references/standard.md` and its byte-identical copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/` (6 files). No `SKILL.md`, survey record, matrix, schema, module, test, checkpoint, spec acceptance criterion or remediation-inputs file was edited.

## Gate 1 — Contract lint, mirror identity and regression greps

Timestamp: 2026-11-17T07-11
Command: `sh SCRATCH/issue-1025-textcheck.sh all` (lint through `sh SCRATCH/issue-1025-lint-contracts.sh`, which calls `Get-HarnessSkillContractViolation` from `scripts/harness/HarnessSkillContract.psm1` on the base and bundle copy of each contract; `cmp -s` of each pair; greps over both trees), followed by `grep -n "^- \*\*OB-" <tree>/python-change-budget-router/references/standard.md | grep -i mcp` over both trees
EXIT_CODE: 0
Output Summary: CONTRACTS_CHECKED: 65 (x2 copies); VIOLATIONS: 0; LINT_EXIT=0. cmp: PAIRS=65 DIFFERING=0. Greps, each over `.agents/skills` and the bundle tree, each exit 1 with 0 lines: R1 grep (g1), R1 inputs form with `listed below` (g1-inputs), R2 grep (g2), cycle 1 sweep grep (g3), forbidden-token grep (g4), R3–R5 grep of `remediation-inputs.2026-11-16T06-14.md` (g-r3r5), and the router MCP grep of Verification Command 3. The greps are those recorded under `## Greps` of `light-remediation-cycle-1.2026-11-16T06-00.md` and in `SCRATCH/issue-1025-textcheck.sh`.

## Gate 2 — Four-file Pester selection

Timestamp: 2026-11-17T07-11
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1 tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` (through `sh SCRATCH/issue-1025-pester-retry.sh`)
EXIT_CODE: 0
Output Summary: attempt 1 exit 0; Invoke-PoshQCParallelTest workers=4, wall-clock 132.94s; shards 136, 108, 18 and 7 passed: 269 passed, 0 failed, 0 skipped. A selection run, not a gate.

## Gate 3 — Plan A Python contract set (five modules), generator check, tier check

Timestamp: 2026-11-17T07-14
Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (through `sh SCRATCH/issue-1025-contracts.sh c3f`)
EXIT_CODE: 75
Output Summary: queue timeout, not a failure: attempts 1 to 6 (2026-11-17T07-14 to 07-26) returned 75 while the machine test-suite lock was held by another suite; each was re-run after the holder.

Timestamp: 2026-11-17T07-26
Command: the same command, re-run
EXIT_CODE: 0
Output Summary: attempt 7: 92 passed in 4.62s (equal to the cycle 2 count of 92). Then `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exit 0, and `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers` exit 0 (`quality-tiers: OK (36 entries, 36 discovered projects)`).

## Gate 4 — Full parallel Pester gate

Timestamp: 2026-11-17T07-26
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (from the worktree root through `sh SCRATCH/issue-1025-c2-gate.sh c3f`, which re-runs only on exit 75; then `SCRATCH/issue-1025-pester-read.ps1` and `SCRATCH/issue-1025-junit-file.ps1` read the merged files)
EXIT_CODE: 0
Output Summary: attempt 1 exit 0 (2026-11-17T07-26 to 07-38); Invoke-PoshQCParallelTest workers=8, wall-clock 713.38s. Merged `artifacts/pester/pester-junit.xml`: passed 27468, failed 0, skipped 18; failing test files: none. `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`: 7 passed, 0 failed, 0 skipped. Coverage source: merged `artifacts/pester/powershell-coverage.xml` (run ExitCode 0). Repo-wide line coverage 96.07% (45203 covered, 1848 missed). Per-file: `scripts/harness/HarnessInventory.psm1` 100.00%, `scripts/harness/HarnessParityMatrix.psm1` 99.25%, `scripts/harness/HarnessSkillContract.psm1` 100.00%.

Comparison with `final-pester-c2.2026-11-17T06-37.md`: passed/failed/skipped 27468/0/18 in both; repo-wide 96.07% in both; harness modules 100.00/99.25/100.00 in both. No new failing test and no coverage drop. No production file changed (Markdown contracts only), so changed-code coverage is N/A; PowerShell has no branch gate.

## Source Check (one row per changed item)

| Contract | OB | Source heading | Members | Named | Prior text | New text | Class closed |
|---|---|---|---|---|---|---|---|
| python-change-budget-router | OB-3 | `## Orchestrated Small-Path Requirements` | promotion and folder lifecycle steps through the repository automation tools; stop before promotion when the required tool is unavailable | all named | If the MCP server or required tool is unavailable, stop before promotion. | Promotion and folder lifecycle steps run through the repository automation tools, and when the required tool is unavailable the skill stops before promotion begins. | R5 (R6/CR-15) |
| python-change-budget-router | OB-1 | `## Canonical Routing Rules` | estimate from production Python files; 1 to 3 production files with tests to the small path; more than 3 to the large path with no production-file cap; test files not counted | all named | Estimate rough change budget first based on likely production Python files touched. | The skill first estimates the change budget from the likely production Python files touched and then routes 1 to 3 production files with their tests to the small path (`python-typed-engineer` direct mode) and more than 3 production files to the orchestrated large path, which has no production-file cap, and test files are not counted toward the routing threshold. | CR-17 alignment (Nit) |
| execution-environment | OB-4 | `## Command-Text Restrictions` | the two mechanisms (runtime worktree isolation guard; repository command hooks: destructive patterns, a directory change followed by a file-reading command, a direct test runner, merge text not bound to one pull request under concurrent review); the preferred forms (target directory named on the tool, one-number merge in its own command, multi-line inline Python placed in a file) | all named | Two separate mechanisms restrict Bash command text. | Command text is restricted by two separate mechanisms with different causes and fixes, the runtime worktree isolation guard, which is not a repository hook and refuses command text it cannot show stays inside an agent-isolated worktree, and the repository command hooks, which deny destructive patterns, a directory change followed later in the same command by a file-reading command, a direct test runner in place of the test-execution launcher, and merge text that cannot be bound to one pull request when a checkpoint records concurrent review, so the preferred forms name the target directory on the tool instead of changing into it, issue a merge as one pull request number in its own command, and place a multi-line inline Python program in a file because it otherwise exits without running. | R4 (R7/CR-16) |
| human-exception-runbook | OB-5 | `## Conformance` | location; five required sections (Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation); source URL and capture date; MCP-first and web-second sourcing; `Version check:` marker lines per the Tool Command Version Rule | all named | A runbook is contract-conformant when it lives at `<FEATURE>/runbooks/<name>.runbook.md`, contains all five required sections, records at least one source URL and a capture date in its Source and Citation section, sources third-party UI steps MCP-first and web-second, and carries `Version check:` marker lines in every counted shell block. | A runbook is contract-conformant when it lives at `<FEATURE>/runbooks/<name>.runbook.md`, contains all five required sections (Cue, Prerequisites, Step-by-step Instructions, Verification, and Source and Citation), records at least one source URL and a capture date in its Source and Citation section, sources third-party UI steps MCP-first and web-second, and carries `Version check:` marker lines in every counted shell block as the Tool Command Version Rule requires. | R4 (sweep, R7 class) |

## Class Sweep (all 65 contracts, base and twin)

Method: the twin tree is byte-identical to the base tree (Gate 1 cmp, 65 pairs), so the scans ran over the 262 Observable Behavior lines of `.agents/skills/*/references/standard.md` after the named fixes, and every hit was read against its `SKILL.md` section.

- R5/R6 class (tool-name mechanism). Scan: OB lines matching `MCP`, `mcp__`, `Claude`, `Codex`, `Copilot`, `AGENTS.md`, `CLAUDE.md`, `copilot-instructions`, a backticked runtime tool name (`Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `Agent`, `Task`, `WebFetch`), `spawn_agent`, `apply_patch`, `.claude/`, `.codex/` or `.github/`. Result: 18 lines before the fixes. Fixed: `python-change-budget-router` OB-3 and `execution-environment` OB-4 (named fixes). Accepted unchanged: the eight docs prerequisite items (CR-13 docs MCP exception), `execution-environment` OB-5 and `policy-audit-template-usage` OB-1 and `feature-promotion-lifecycle` OB-1 and `human-exception-runbook` OB-3 and OB-5 (mechanism-subject: the source section's subject is that MCP surface or the MCP-first sourcing rule; CR-13/CR-19 precedent), `docs-init` OB-4 and `feature-review-workflow` OB-4 (repository data paths under `.github/workflows/`, allowed by rewrite rule 3), and `translate-copilot-to-claude` OB-1 (the contract's subject is translating `.github/` sources). After the fixes no R5 instance remains.
- R4/R7 class (count without members). Scans: OB lines with a count word (`two` to `ten`, `both`, `several`, `multiple`, or a digit before a member noun) and OB lines with `all required`, `every required` or `required <member noun>`. Result: 34 and 11 hit lines (42 distinct), each read in full. 40 name every counted member or carry no member count (for example `commit-message` OB-5 "no multiple alternative commit messages"); `execution-environment` OB-4 (named fix R7) and `human-exception-runbook` OB-5 did not. The `## Conformance` source line names the five sections in a parenthesis ("all five required sections (Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation)"), and the item dropped them, so it is a residual R4 instance and was fixed under the same rules. The six discovery `OB-3 Exact output boundary` items name every artifact kind and every bound field, and are accepted.

## Changed Files

- `.agents/skills/python-change-budget-router/references/standard.md` (OB-1, OB-3)
- `.agents/skills/execution-environment/references/standard.md` (OB-4)
- `.agents/skills/human-exception-runbook/references/standard.md` (OB-5)
- each of the three copied byte for byte to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`

## Decisions (autonomous mode)

- D1: CR-17 applied in the [P0-T1] edit. Reason: the delegation recorded this decision under autonomous mode and the owner forethought rule; it aligns OB-1 with the C# and PowerShell router contracts and closes the only remaining sibling divergence. The large path is named tool-neutrally ("the orchestrated large path") instead of the source's prompt-file path (rewrite rule 3).
- D2: R7 sentence extended beyond the inputs' example. Reason: rewrite rule 2 requires the item to state the whole source section; the example omitted the merge-text, test-execution-hook and inline-Python bullets of `## Command-Text Restrictions`.
- D3: `human-exception-runbook` OB-5 fixed although the inputs' scope boundary lists only R6, R7 and CR-17. Reason: the delegation directs a class sweep of all 65 contracts with any residual fixed under the same rules and recorded; the edit changes only the item text after the prefix, and numbering, headings and `AC-<n>` text are unchanged.
- D4: The remediation-inputs file is not edited (delegation rule), so its `## Light Fix Tasks` boxes stay unchecked; task completion is recorded in this artifact and the two task-check records.
