# 0004: Smaller plans

## Summary

reduction: 0004
Date: 2026-11-07
Issue: #1097
Merge commit: 81b6a1be385666e5025936a85e487e43e7ac6187

Adds a `**Task target.**` bullet to `## Design-Level Plan Contract (Mandatory)` of the planning contract: a plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks, and the `**Size guideline.**` bullet, with the limit the validator enforces, is not changed. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, and the orchestrator replaces it with the pull request number right after PR creation.

## Reason and Evidence

Research section 2 of `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` measured 31 plans written since the size rule shipped: a median of 41 tasks, 30 of 31 plans above 20 tasks, and 16 above 40, each with a size justification. Smaller plans cost less to author, preflight, and execute. The time saved is unknown until stage timing has data.

## Files Changed

- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.agents/skills/atomic-plan-contract/SKILL.md`
- `.github/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`, a byte-identical bundle copy
- `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, the `PCW-TASK-TARGET` row
- `docs/engineering/process-reductions/README.md`, the index row of this entry

## Prior Text

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.

````

````Prior
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.

````

````Prior
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.

````

````Prior
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, which removes the bullet and its line. Revert this entry before `0001`: the bullet sits inside a hunk of `patches/0001-parallel-only-test-gates.patch`, so that patch does not reverse-apply to the six contract copies while the bullet is present.
2. Re-copy mirrors and bundles: copy each of the three contract sources to its bundle path under `extensions/drm-copilot/resources/`: `claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, `codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, and `customizations/.github/skills/atomic-plan-contract/SKILL.md`.
3. Regenerate Codex variants: not applicable, because no base agent changed; still run the generator `--check`.
4. Restore pinned hashes: not applicable, because no pinned surface moved.
5. Restore contract-test literals: remove the `PCW-TASK-TARGET` row from `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
6. Run the contract tests: run `planning-contract-wording.Tests.ps1`, `test_plan_gate_document_docs.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `ProcessReductionLedger.Tests.ps1`.

## Revert Signals

- Plans that merge several tasks into long ones to meet the target.
- More preflight defects per plan.
- A rise in plans above the target that carry no reason for their size.
