# Preflight Fixes (Issue #1025)

Timestamp: 2026-10-30T21-47
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md
Preflight signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned separately to the planner)

## Fixes Applied In Place

1. [P0-T3] | hyphen-leading search pattern (validator-blind class) | Added the instruction to pass a hyphen-leading pattern such as `--check` (citation `scripts/dev_tools/generate_codex_agent_variants.py | --check`) through `-e`, and stated that a `file presence` citation is checked by `git ls-files --error-unmatch` alone. The assertion is unchanged.
2. [P12-T9] | placeholder in a command span | Replaced `<merge-base>` with `MB`, the merge-base commit defined in `## Definitions`. The assertion is unchanged.
3. [P12-T10] | placeholder in a command span | Replaced `<merge-base>` with `MB`, the merge-base commit defined in `## Definitions`. The assertion is unchanged.
4. `## Citations Re-Checked at Phase 0` | citation correction | Added file-presence entries for the excluded paths (the two `pack-manifests/core.json` files, `config/file-size-baseline.json`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `extensions/drm-copilot/jest.config.cjs`, and the six execution-environment brief copies). The spec acceptance criterion `Phase 0 gate` requires the excluded paths to be re-checked, and the list did not include them. Each path was confirmed tracked at preflight with `git ls-files`.
