# Contract Fix: Plans That Alter a Brief Fact Update the Brief (#964)

Timestamp: 2026-10-17T04-11
Command: poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_plan_gate_document_docs.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
EXIT_CODE: 0
Output Summary: 89 passed (87 before this change plus the two new pinning tests). The design-level contract's Pre-Mortem `Mirror parity` label and the brief's validator-blind defect classes now require a plan that alters a fact the brief states to include a task that updates the brief in the same change, in all six byte-identical copies. All bundle copies are byte-identical; Codex generator write and check, Black, Ruff, and Pyright pass; both re-plan plans pass the branch-current plan validator.

## Finding

The attempt-2 preflight of the #962 re-plan (`evidence/other/replan-962/attempt-2/preflight-fixes.2026-10-17T04-02.md`) returned one substantive defect: the plan adds two `ci.yml` jobs but has no task that updates the execution-environment brief's job list, although the brief's maintenance rule requires that update in the same change. Neither the contract nor the brief's list of validator-blind defect classes stated this obligation for plan authors and preflight reviewers.

## Changed Text Locations

- `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, heading `## Design-Level Plan Contract (Mandatory)`, `Pre-Mortem` rule bullet: new sentences stating that the `Mirror parity` bullet also covers the execution-environment brief; a plan that alters a fact the brief states (for example, adds or renames a CI job, changes a required status context, a tool route, or a batch-budget rule) includes a task that updates the brief in the same change, in all six byte-identical copies, and the bullet names that task. The text is identical in the three surfaces. These are the only contract copies that define the `Mirror parity` label; the agent and prompt surfaces reference the section by heading.
- `.claude/skills/execution-environment/SKILL.md`, heading `## Preflight Defect Classes the Validator Cannot See`: new bullet for the class and the preflight check (compare each task's changes against the facts the brief states; confirm that a brief-update task exists and that the `Mirror parity` Pre-Mortem bullet names it). Copied byte-identically to the other five brief locations.
- Bundle mirrors under `extensions/drm-copilot/resources/` for the three contract copies and the three brief copies, written by the SCRATCH mirror-copy script.
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`: new test `test_contract_premortem_mirror_parity_requires_brief_update_task`, which pins the obligation inside the design-level section of every contract copy.
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: new test `test_brief_preflight_classes_include_brief_maintenance`, which pins the class inside the preflight-defect section of the brief.
- `evidence/other/replan-962/summary.2026-10-17T04-10.md`: the orchestrator's O1 summary, written verbatim with the stamp and the commit reference substituted. AC-33 remains unchecked in `spec.md`.

## Verifying Commands

| Command | EXIT_CODE | Result |
|---|---|---|
| `poetry run python SCRATCH/issue-964-brief-maintenance.py <worktree root>` | 0 | four files edited (three contracts, canonical brief) |
| `sh SCRATCH/issue-964-mirror-copy.sh` | 0 | `COPIED=60 MISMATCH=0` |
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` | 0 | no file changed (tracked porcelain status identical before and after) |
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | generated outputs current |
| `poetry run black --check scripts tests` | 0 | `620 files would be left unchanged.` |
| `poetry run ruff check scripts tests` | 0 | `All checks passed!` |
| `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| contract suite command in the header | 0 | 89 passed, including `test_brief_copies_are_byte_identical` and `test_brief_has_no_g11_or_g12_findings` |
| `git show HEAD:<file> \| grep -c <new token>` for the canonical contract and brief | 1 (count 0) | the pinned tokens are absent at the parent commit, so the two new tests fail against the pre-change text |
| `poetry run python -m scripts.dev_tools.validate_evidence_locations --root docs/features/active/2026-10-16-planning-process-churn-964` | 0 | no non-canonical evidence path |
| `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` | 0 | no non-canonical evidence path |
| `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/plan.md` | 0 | `plan validation passed` |
| `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/attempt-2/plan.md` | 0 | `plan validation passed` |

## Tonality

The new sentences were checked against `.claude/rules/tonality.md`: they are declarative, contain no humor, hyperbole, or metaphor, and state the failure mechanism (a superseded fact in the brief once the change lands) without dramatizing it.
