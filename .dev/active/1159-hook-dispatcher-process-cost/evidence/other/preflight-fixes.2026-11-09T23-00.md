# Preflight Fixes (round 3, after the OD-2026-11-09-max-parallel revision)

Timestamp: 2026-11-09T23-00
Plan: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/plan.2026-11-09T16-31.md

Records `preflight-fixes.2026-11-09T22-20.md` and `preflight-fixes.2026-11-09T22-35.md` are unchanged.

## Fixes

1. [P5-T1] | test-isolation clarification (keeps the acceptance condition unchanged) | Envelopes run as real hook processes. `Get-DiscoverySentinelDecision` in `.claude/lib/discovery-validation/DiscoveryObservation.psm1` writes a host observation file for every sentinel envelope, and the merge gates call `gh`. The corpus rule now states that no envelope makes a hook write a file or call `gh`, and that a hook with no such envelope is reported by name in the same way as a hook that needs a filesystem mock. This applies the plan preamble constraint that tests create no files. The acceptance condition (each corpus file under 500 lines) is unchanged.
2. [P5-T2] | CI-dependent acceptance timing | The acceptance condition required a pass in `poshqc / PowerShell hook suites (Linux)`, which the executor cannot observe before the pull request exists. It now reads: passes in [P7-T4] on Windows, and the Linux job result is a CI-dependent criterion verified on the PR head at the CI green gate. The assertion is unchanged; only the point at which it is verified is stated.

## Validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (plan): ok.
- `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>`: `plan validation passed`, EXIT_CODE 0.
