# Task Check P1-T3

Timestamp: 2026-11-19T08-21
Plan: plan.2026-10-30T18-39.md
Changed files (all under `tests/scripts/dev_tools/`): `test_completion_gate_documentation_contracts.py` (`AC_TRACKING_SKILLS`, `EVIDENCE_SKILLS`, the `github-ac-tracking` and `github-evidence` pairs and `_GITHUB_BUNDLE` removed; docstring counts); `test_evidence_timestamp_contracts.py` (`EVIDENCE_SKILLS`, `PLAN_CONTRACT_SKILLS`, the `github` pair and `_GITHUB_BUNDLE` removed; docstring counts); `test_minor_audit_acceptance_criteria_contracts.py` (`ROOT_MIRROR_PAIRS` and `required_paths` skill rows retargeted to `.agents` and the `codex-and-agents-customizations` bundle; prompt rows unchanged); `test_csharp_orchestration_contracts.py` (`_assert_state_machine_contract`, `test_csharp_change_budget_router_requires_orchestrated_small_path_wording`, `_assert_bundle_mirror_contract` skill paths retargeted to `.agents` and its bundle; agent and prompt rows unchanged); `test_push_down_issue_824_follow_ups.py` (`STEP_EIGHT_COPIES` and `FEATURE_REVIEW_TEXT_COPIES` drop the two Copilot rows; `EXPECTED_LISTED_COPY_COUNT` 40 to 38, because `STEP_EIGHT_COPIES` is one of the listed tuples); `test_discovery_publication_contracts.py` (`COPILOT_ROOTS` drops the skill root; `test_skill_is_represented_on_every_host` drops the Copilot skill mirror check; module and test docstrings).
Selection rule: the six changed test modules. No `REGION-MAP` row names these files.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `env -u VIRTUAL_ENV poetry run black --check` (6 modules) | 0 | 6 files would be left unchanged |
| `env -u VIRTUAL_ENV poetry run ruff check` (6 modules) | 0 | All checks passed |
| `env -u VIRTUAL_ENV poetry run pyright` (6 modules) | 0 | 0 errors, 0 warnings |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <6 modules> -q -p no:cacheprovider` | 0 | 152 passed, including every `test_copilot_bundle_mirrors_every_scoped_github_file` parameter |
| Grep for RETIRED-PATH over the six modules | 0 | 0 matches |
