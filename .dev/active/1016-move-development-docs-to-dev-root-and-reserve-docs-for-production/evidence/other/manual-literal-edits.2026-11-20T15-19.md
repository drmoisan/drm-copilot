# Manual Literal Edits [P3-T6]

Timestamp: 2026-11-20T15-19
Command: Edit-tool changes to the six test files below; sh SCRATCH/issue-1016-tc-p3t6.sh (Black, Ruff, Pyright on the three changed Python files; launcher pytest -n auto over test_discovery_documentation_contracts.py, test_parallel_orchestrator_surface_contracts.py, test_epic_run_kickoff_discovery_contract.py, test_parallel_planner_surface_contracts.py; launcher pester -TestPath over claude-architecture-doc.Tests.ps1, codex-epic-runtime-contracts.Tests.ps1, ProcessReductionChain.Ledger.Tests.ps1); sh SCRATCH/issue-1016-pstc.sh per edited Pester file
EXIT_CODE: 0
Output Summary: Six test files edited; pytest selection 90 passed, 0 failed; Pester selection 27 tests, 0 failures (exit 0); Python static 0 findings; PowerShell format drift 0, PSSA findings 0. Includes SECTION_OBLIGATION_CASES kickoff-feature-folder-and-issue-number, all four tests of test_epic_run_kickoff_discovery_contract.py, and every case of codex-epic-runtime-contracts.Tests.ps1. REHEARSAL (apply-rehearsal.2026-11-20T13-04.md) has no FIX-MANUAL or FIX-PINNED row; its [P3-T6] rows are FIX-NAMED and all pass.

## Edits

| File | Test or symbol | Change |
| --- | --- | --- |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | the four `It` blocks that read the architecture document | document path built with `Join-Path` from `.dev` and `engineering` (was `docs`, `engineering`) |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | "requires the architecture document to describe the discovery controls and the planning prerequisite linkage (issue #980)" | asserted pattern `engineering/legacy-discovery-and-parity/enforcement\.md` (see decision D-P3T6-1) |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | `DOC` | joined from `.dev` and `engineering` |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | `test_handoff_reconciles_the_built_artifacts`, `test_handoff_carries_no_stale_installed_host_limit` | handoff located by `0980-*/handoff.md` across `.dev/active`, `.dev/completed`, `.dev/archive` through the new helper `find_issue_980_handoffs` and the constant `HANDOFF_AREAS` |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | `test_architecture_document_links_the_planning_prerequisite` | asserted substring `engineering/legacy-discovery-and-parity/enforcement.md` (decision D-P3T6-1) |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | `KICKOFF_IDENTITY_FRAGMENTS` | entry set to the rewritten skill text ``written literally as `.dev/active/<basename>` `` (outside every stored-patch hunk; no patch holds this text) |
| `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` | `test_epic_run_skill_discovers_kickoff_across_integration_branch` `git cat-file -e` fragment; module docstring | kickoff path `.dev/epics/<epic-slug>/epic-kickoff.md`; the `git show origin/epic/...` fragment of `test_epic_orchestrator_precondition_establishes_kickoff_presence` unchanged |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | "preserves the merged planner lifecycle boundary" | kickoff pattern `\.dev/epics/<epic-slug>/epic-kickoff\.md` (outside the `0010` hunk; no patch holds the pattern) |

`.claude/skills/epic-run/SKILL.md`, `.agents/skills/epic-plan/SKILL.md` and `.claude/skills/epic-plan/SKILL.md` are not edited by this task (porcelain status lists none of them).

## Decision D-P3T6-1 (autonomous, OD-1 and OD-4)

`.dev/engineering/claude-code-architecture.md` lies inside a moved tree, so the `links-only` in-tree scope left its backticked text `docs/engineering/legacy-discovery-and-parity/enforcement.md` unchanged, while the tool rewrote the two test literals that read it to `.dev/engineering/...`; both tests failed (REHEARSAL FIX-NAMED rows of [P3-T6]). The task rule is to edit the literal to what the test reads after the move. Options: (a) pin the old `docs/engineering/...` text, which fixes a stale prefix in the test; (b) edit the moved document, which this task does not list; (c) assert the root-neutral substring `engineering/legacy-discovery-and-parity/enforcement.md`. Selected (c): it is a test-only edit, it still fails if the document stops naming the enforcement page, and it holds under either root. `SKILL_LINKAGE` in the same Python file reads tool-rewritten skills that carry `.dev/engineering/...` and is unchanged.
