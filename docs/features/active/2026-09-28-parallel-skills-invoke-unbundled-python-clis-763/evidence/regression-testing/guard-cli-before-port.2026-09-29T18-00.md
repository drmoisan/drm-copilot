# Guard CLI Before the Port (P1-T8, expect-fail)

Timestamp: 2026-09-29T18-00
Command: poetry run python -m scripts.dev_tools.skill_bundle_contract_cli
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- stderr, exactly two lines, in this order:
  - `skill-bundle violation: parallel-orchestrate | scripts/dev_tools/parallel_drift_detection_cli.py | not-in-bundle`
  - `skill-bundle violation: parallel-remove | scripts/dev_tools/parallel_mutation_abandon_cli.py | not-in-bundle`
- stdout: empty (confirmed by a second run with stderr discarded, which printed nothing and exited 1)
