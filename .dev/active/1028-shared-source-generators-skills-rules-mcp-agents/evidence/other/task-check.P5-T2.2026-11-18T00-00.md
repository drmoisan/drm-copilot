# Task Check — [P5-T2]

Timestamp: 2026-11-18T00-00
Command: sh SCRATCH/issue-1028-retry.sh pester -TestPath tests/scripts/harness-generation; format and PSScriptAnalyzer over `scripts` and `tests/scripts` inside the Phase 4 gate run `p4gate2` (964 files, 0 would change, 0 findings); wc -l scripts/harness-generation/HarnessAgentGeneration.psm1
EXIT_CODE: 0
Output Summary: Pester over `tests/scripts/harness-generation` (7 suites) ran 180 tests: 180 passed and 0 failed. `HarnessAgentGeneration.psm1` line coverage is 100.00% (115 of 115). The module has 251 lines, which is within the 700-line acceptance limit. The first run, inside the first Phase 4 gate attempt, failed one case, `rejects invalid JSON`: PowerShell 7's JSON reader accepts an unquoted property name. The fixture now uses an unterminated object.

Changed files: `scripts/harness-generation/HarnessAgentGeneration.psm1` (new) and `tests/scripts/harness-generation/HarnessAgentGeneration.Tests.ps1` (new).
Selection rule: `## Test Cadence (Mandatory)`; the new suite plus the other suites of its folder.

Design notes:
- **Claude agent.** The frontmatter keys are written in source order with raw YAML value text. `Write(` and `Edit(` literals pass through unchanged (OQ-9, tested).
- **Base Codex agent.** The keys are written in source order. Two optional raw fields, `separator` (the blank lines before `developer_instructions`) and `trailer` (for example the `[skills]` table), were added so that every existing base file renders byte-equal; the current files differ in both respects. `developer_instructions` is built from the listed sections, with the Codex substitutions, between `'''` or `"""`.
- **Generated families.** For a family in `codex_model_policy.generated_agent_families` of `config/orchestration-routing.json`, the source declares no model keys. The C3 `model` and `model_reasoning_effort` from `complexity_to_profile.C3` are inserted after `description`, which is the form `render_base_alias` produces.
- **Validation before writing.** A missing required field (claude `name` or `description`, codex `name`, `description` or `delimiter`, or a missing target) throws before any write. This is tested through `Invoke-HarnessGeneration` with a recording writer that sees 0 writes.
- **Bodies are sectioned like the rule sources.** Each target lists its own sections, so a section may belong to one target only, and substitutions still apply on top.
