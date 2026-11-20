# Preflight Fixes - #1038 remediation cycle 1

Timestamp: 2026-11-07T22-32
Plan: docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/remediation-plan.2026-11-07T22-30.md
Command: single-pass preflight review of the plan against the tree; poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: two trivial defects fixed in task text; one substantive defect returned to the planner ([P3-T2]). Branch-current plan validator passed before and after the fixes.

## Fixes

1. [P0-T3] - validator-blind defect (search scope). The search for `consumer-onboarding.md` readers in `tests/` and `docs/engineering/` also matches the separate page `docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md` and its readers (`tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, the legacy-discovery `README.md` and `examples/taskmaster-tmw.md`). As written, the test-file hit is outside the dispositions table and would stop execution with `BLOCKED: unlisted test`. Change: the task text now counts a hit as a reader only when it reads or links `ONB/consumer-onboarding.md`, records the named legacy-discovery hits as not readers, and records the link-only `ONB/README.md` as a non-test reader. The assertion (every reader of the edited page is dispositioned) is unchanged.
2. [P3-T2] - stale-documentation wording. The `.DESCRIPTION` of `EndToEndDocumentationEstate.Tests.ps1` states "one stateful in-memory context ... per test" in a sentence separate from the D-3 replay sentence. Change: the task text now names both sentences for update to one replay per `Context`. No assertion changes.
