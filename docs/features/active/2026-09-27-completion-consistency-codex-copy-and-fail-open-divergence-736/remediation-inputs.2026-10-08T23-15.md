# Remediation Inputs (issue #736, cycle 1: PR #853 required-check failures)

- Reviewed: 2026-10-08
- Pull request: #853 (base `epic/enforcement-hook-precision-integration`, head `bug/completion-consistency-codex-copy-and-fail-open-divergence-exec-736`)
- Source: required CI check results for PR #853. 20 required checks ran; 18 passed and 2 failed. The failures are the two `NPM Audit Gate` jobs below. This cycle is separate from the audit-derived inputs in `remediation-inputs.2026-10-08T22-30.md`, whose single item (R-1, repo-wide PowerShell coverage) is a pre-existing non-attributable finding that this cycle does not address.

## Remediation-Required Findings

### R1: `NPM Audit Gate / npm audit (.)` fails

- Severity: Blocking (required check).
- Job: https://github.com/drmoisan/drm-copilot/actions/runs/37855295491/job/113577899904
- Evidence: `npm audit --audit-level=moderate` at the repository root reports transitive dependency `handlebars` in the affected range 4.0.0 through 4.7.9, severity critical, advisories GHSA-xw65-4hp5-5hc7, GHSA-8r5x-fm3f-whwj, and GHSA-p8wg-vrv2-v86f. The audit output states that a fix is available via `npm audit fix`. The workflow `.github/workflows/_npm-audit-gate.yml` runs `npm ci` and then `npm audit --audit-level="$AUDIT_LEVEL"` with `moderate` (set in `.github/workflows/ci.yml` and `.github/workflows/npm-audit-gate.yml`).
- Lock state at planning time: `package-lock.json` entry `node_modules/handlebars` resolves to version 4.7.9. The only dependent that names handlebars is `ts-jest`, which declares `"handlebars": "^4.7.9"`; `handlebars` is not a direct dependency and has no `overrides` entry.
- Attribution: not caused by the #736 change. The hooks changed by #736 do not use handlebars, and the advisory is new. No other open PR or issue addresses it.
- Remediation: move the locked `handlebars` version out of the affected range in `package-lock.json` only.

### R2: `NPM Audit Gate / npm audit (extensions/drm-copilot)` fails

- Severity: Blocking (required check).
- Job: https://github.com/drmoisan/drm-copilot/actions/runs/37855295491/job/113577899858
- Evidence: same advisory set and affected range as R1, reported by `npm audit --audit-level=moderate` in `extensions/drm-copilot`.
- Lock state at planning time: `extensions/drm-copilot/package-lock.json` entry `node_modules/handlebars` resolves to version 4.7.9.
- Attribution: same as R1.
- Remediation: move the locked `handlebars` version out of the affected range in `extensions/drm-copilot/package-lock.json` only.

## Scope Constraints

- Lockfile-only change: `package-lock.json` and `extensions/drm-copilot/package-lock.json`.
- `packages/mcp-server/package-lock.json` has no `handlebars` entry and its audit job passed; it is verified and not modified.
- No `package.json` change. No `overrides` entry is added. No workflow change. `npm audit fix --force` is prohibited.
- Verification: `npm audit --audit-level=moderate` exits 0 in all three directories, `npm ci --dry-run` exits 0 in the two changed directories, and the root and extension Jest suites show no new failures against their baselines.
- Commit and push after each phase.

## Not Remediation-Required (for orchestrator awareness)

- Re-running the two failed CI jobs on PR #853 after the push is an orchestrator step.
- The pre-existing items listed in `remediation-inputs.2026-10-08T22-30.md` are unchanged by this cycle.

## Blocking Summary

- R1 and R2 are the only blocking items. Both are resolved by a lockfile-only `handlebars` version move.
