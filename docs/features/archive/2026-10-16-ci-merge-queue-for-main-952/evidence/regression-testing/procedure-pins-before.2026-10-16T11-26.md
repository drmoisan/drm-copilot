# Procedure Pins Before (P6-T3, expect-fail)

Timestamp: 2026-10-16T11-26
Command: poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 12 failed, 38 passed in 0.42s

Summary line (verbatim): 12 failed, 38 passed in 0.42s
38 = CONTRACT_BASE_PASSED 33 + the five new mirror pairs (already byte-identical per P0-T6).

Failing node IDs (verbatim):
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-parallel-orchestrate-merge]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-parallel-orchestrate-conflict]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-parallel-orchestrator-agent]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-orchestrate-s9]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-orchestrate-pr-gate]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-epic-orchestrate-lifecycle]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-epic-orchestrate-kickoff]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-epic-orchestrate-completion]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-epic-orchestrator-agent]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[agents-epic-orchestrate]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[codex-epic-orchestrator-agent]
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation[claude-cleanup-merged-worktrees]

RowAttribution: the 12 failing nodes are exactly the 12 Appendix I.1 pins. Each fails because the procedure text it pins has not been written yet (Phase 6 procedure edits follow). `claude-cleanup-merged-worktrees` fails because `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208` states the strict up-to-date requirement with no queue case (D10(a)).
