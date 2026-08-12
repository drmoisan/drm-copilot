# P6-T33 Commit-Steward TypeScript Coverage

Timestamp: `2026-08-10T20-25`

Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-typescript-coverage.2026-08-10T20-25`

EXIT_CODE: `0`

Output Summary: The clean ordered TypeScript pass completed with `193/193` suites and `2,678/2,678` tests passed, `0` failed, `0` snapshots, in `6.065s`. Coverage is statements `44,076/45,740` (`96.36%`), branches `6,562/7,326` (`89.57%`), functions `1,304/1,434` (`90.93%`), and lines `44,076/45,740` (`96.36%`). The LCOV aggregate independently reports the same line, branch, and function numerators and denominators.

## Threshold and Regression Results

- Repository lines: `96.36%`, PASS against `>=85%`.
- Repository branches: `89.57%`, PASS against `>=75%`.
- Repository functions: `90.93%`, PASS against `>=90%`.
- Current issue-owned changed/new executable TypeScript lines: `3,179/3,393` (`93.6929%`), PASS against `>=90%`.
- Prior P6-T19 issue-owned result: `3,178/3,392` (`93.6910%`).
- Changed/new-code delta: `+1/+1` covered/total and `+0.0019` percentage points; no changed-line regression.
- P6 correction line in `orchestrator-state-codex-model-routing.ts`: `1/1` covered.
- Baseline P0-T21 repository lines/branches/functions: `40,958/42,412` (`96.57%`), `5,822/6,476` (`89.90%`), and `1,191/1,321` (`90.15%`); all final policy floors remain satisfied.

## Owner and Policy Gates

- Production owner `orchestrator-state-codex-model-routing.ts`: `497` lines.
- Test owners: `458`, `317`, `301`, `451`, and `172` lines.
- Added dependency delta: `0`.
- Added suppression findings: `0`.
- `.codex/state` exists: `false`.
- `git diff --exit-code -- .claude`: exit `0`.
- `git diff --check`: exit `0`.

Result: `PASS`.
