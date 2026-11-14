# Remediation Inputs — Issue 1163 (CI failure, PR #1170)

Timestamp: 2026-11-13T15-36
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source: S9 CI green gate on PR #1170, head ab6c96321a676320806eb97b4d34c898d7bf4b51, run https://github.com/drmoisan/drm-copilot/actions/runs/43449945463
Prior cycle: cycle 1 (light, F1, closed by the 2026-11-13T15-02 re-audit with PASS).

## Findings requiring remediation

### C1 — NPM Audit Gate fails in all three manifests on new advisories

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The advisories have fixes available through `npm audit fix` (lockfile-level upgrades of hono, @hono/node-server, and deepmerge); no external party, owner decision, or pending CI result is needed.
Finding-Scope: contained

- Failing checks (job URLs):
  - `NPM Audit Gate / npm audit (.)` — https://github.com/drmoisan/drm-copilot/actions/runs/43449945463/job/131969435745
  - `NPM Audit Gate / npm audit (extensions/drm-copilot)` — https://github.com/drmoisan/drm-copilot/actions/runs/43449945463/job/131969435788
  - `NPM Audit Gate / npm audit (packages/mcp-server)` — https://github.com/drmoisan/drm-copilot/actions/runs/43449945463/job/131969436265
  - `CI Required Gate` fails only because the three jobs above fail.
- Cause: advisories published after the last green `main` run (1d62aa292, 2026-11-12) against `hono` and `@hono/node-server` (moderate, all three manifests) and `deepmerge` (extensions/drm-copilot, reported as 8 vulnerabilities, 6 low and 2 moderate). The branch changes no npm manifest; every other check on the head passed.
- Required change: resolve the advisories in the three lockfiles (`package-lock.json`, `extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package-lock.json`) with a non-breaking `npm audit fix` (no `--force`), or, where a fix needs a breaking upgrade, the narrowest `overrides` entry that the repository's existing override pattern allows. Do not change production source.
- Verification required: the npm audit command the gate runs (read it from the NPM Audit Gate workflow) exits 0 in each of the three manifests locally; the TypeScript toolchain for each touched package (build, lint, type check, and Jest through its normal parallel workers with coverage) passes with no coverage drop; the push-down contract tests and the Codex generator check still pass; a new self-review records no FAIL row. CI on the new head is the final confirmation.

## Constraints

- Tests run in parallel only; no serial, single-process, shuffled, or reversed runs.
- Evidence is append-only; do not edit or delete existing evidence files. No artifact records an absolute path or host name.
- No Python file is added or modified.
