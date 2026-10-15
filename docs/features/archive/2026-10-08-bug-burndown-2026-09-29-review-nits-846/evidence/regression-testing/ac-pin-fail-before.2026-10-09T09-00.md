# Regression: AC-tracking cross-reference pin test fails before the SKILL.md edits ([P4-T2], expect-fail)

Timestamp: 2026-10-09T21-19
Command: poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -k "cross_references_ci_dependent_exception" -q
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: 3 failed, 30 deselected in 0.16s. Run after [P4-T1] added the test and before any SKILL.md edit ([P4-T3] to [P4-T5] not yet run). Each failure names the missing first fragment "Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion" in the `## Check-Off Protocol` section of its skill file.

```
E           AssertionError: .claude/skills/acceptance-criteria-tracking/SKILL.md ## Check-Off Protocol is missing required text: Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion
E           AssertionError: .agents/skills/acceptance-criteria-tracking/SKILL.md ## Check-Off Protocol is missing required text: Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion
E           AssertionError: .github/skills/acceptance-criteria-tracking/SKILL.md ## Check-Off Protocol is missing required text: Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion
FAILED tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[claude]
FAILED tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[agents]
FAILED tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[github]
3 failed, 30 deselected in 0.16s
```

Acceptance: exit 1; `3 failed` (ids claude, agents, github), each naming the missing fragment. PASS (expected failure observed).
