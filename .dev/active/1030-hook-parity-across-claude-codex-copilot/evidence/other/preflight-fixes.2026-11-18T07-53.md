# Preflight Fixes — Issue #1030, plan version 2.1

Timestamp: 2026-11-18T07-53
Plan: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md`

## Fix 1 — [P1-T3]

- Defect class: literal correction (data value that the task leaves to the skeleton default; no acceptance condition changes).
- Observed: `New-HarnessParityMatrixSkeleton` in `scripts/harness/HarnessParityMatrix.psm1` emits `consumers` as an empty array, while every existing `codex` `hook-registration` entry sourced from `.codex/config.toml` (for example `SubagentStop/feature-review|feature-reviewer/validate-feature-review-coverage`) records `consumers` `["codex"]`. The schema accepts an empty array, so no gate fails either way, but the new entry would state that no runtime consumes the registration.
- Change made: the [P1-T3] matrix-entry clause now sets `consumers` `["codex"]` "as its sibling `.codex/config.toml` entries", and notes that the skeleton emits an empty array. No task was added, removed, or reordered; no asserted value changed.
- Validator after the fix: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan-path>` exit 0.
