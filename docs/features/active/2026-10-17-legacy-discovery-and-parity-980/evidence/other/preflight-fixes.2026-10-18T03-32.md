# Preflight corrections for issue 980

Recorded at 2026-10-18 03:32 UTC. Plan: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md`.

Scope: validation-only preflight. Actual SubagentStart authority-store attestation was verified before these edits: agent `01a14d09-ff5e-71e3-9a9c-815f876656a7`, profile `atomic-executor-c4`, model `gpt-6-astra`, effort `max`; routing, launch authority, and provenance were valid. The recorded profile SHA-256 matched the profile file: `ac681ebf70607a2d00c76e29d142df0a05751c0c375f0ee878cec30b29c044b9`.

| Plan anchor | Defect class | Correction | Basis |
| --- | --- | --- | --- |
| Existing assertion dispositions / Set D | Test anchor | Added the missing `test_` prefix to `test_build_completion_summary_reports_entry_counts_and_readiness`. | Existing test function in `tests/scripts/dev_tools/discovery/test_completion_report.py`. |
| Existing assertion dispositions / Set E | Test anchors | Added the missing `test_` prefixes to `test_projection_*` and `test_positive_generation_*`. | Existing test functions in `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`. |
| P9-T7 | Stale file path | Removed the nonexistent `CL/DiscoveryValidation.psd1` refactor target; retained `CL/DiscoveryValidation.psm1`. | The existing semantic-validation module has no corresponding module manifest. The separately planned new authority module manifest remains unchanged. |
| P11-T6 | Evidence path | Changed the discovery-isolation evidence directory from `qa-gates` to `regression-testing`. | The execution-environment skill assigns independent test-isolation evidence to the regression-testing directory. |

No task IDs, task order, requirements, acceptance criteria, or checkbox states were changed. No production code, tests, configuration, or orchestration checkpoints were edited. Substantive defects are returned to the planner in the preflight result; this record does not approve execution.
