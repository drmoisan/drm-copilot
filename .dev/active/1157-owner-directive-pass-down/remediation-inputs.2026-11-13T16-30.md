# Remediation Inputs — Issue 1157 (cycle 2, CI failure)

Timestamp: 2026-11-13T16-30
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Head: `b79d27bc0398dffa1d2af6031f23232378f83d66`
Base: `main`, merge base `1d62aa292161035aec8058e6c370f133e10a04db`
Source: CI run 43460709376 on PR #1171 (`pull_request` event), job logs read with `gh api repos/drmoisan/drm-copilot/actions/jobs/<job-id>/logs`.
Remediation plan target: `docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T16-30.md`

Mode note: the fix changes `package-lock.json` files that are not in the branch diff, so the cycle is classified design (a CI-failure cycle is never light). No spec acceptance criterion and no public interface changes.

Origin note: this branch changes no `package.json` or `package-lock.json`. The advisories below were published after the last green `main` CI run (run 43170341553 at the merge base), so every open pull request fails the same gate. The coordinator directed that the fix land in this item (OD-17); items #1164 and #1163 take it by merging `main` after #1171 merges.

## Findings requiring remediation

### C1 — `NPM Audit Gate / npm audit (.)` fails

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: `npm audit` reports "fix available via `npm audit fix`" for each moderate advisory; a non-breaking lockfile update in the repository resolves it.
Finding-Scope: contained

- Failing check: `NPM Audit Gate / npm audit (.)`
- Failing job: https://github.com/drmoisan/drm-copilot/actions/runs/43460709376/job/132010740579
- Gate: `audit-level: moderate` (`.github/workflows/ci.yml` calling `.github/workflows/_npm-audit-gate.yml`), step "Audit dependencies".
- Observed: 8 vulnerabilities (6 low, 2 moderate). Moderate: `hono <=4.13.15` (GHSA-4m76-xfj5-7975, GHSA-h7mg-cq63-vhpq, GHSA-3gg2-335m-rxc6, GHSA-46wx-v44x-9hh2, GHSA-4h7h-rv7c-7m2v) and `@hono/node-server` 2.0.0 - 2.1.5 (GHSA-qv5m-9pm6-hqp3, GHSA-jpvv-r467-5p4w), each "fix available via `npm audit fix`". Low findings in the jest chain.
- Required change: non-breaking lockfile update of the root manifest (`npm audit fix`, never `--force`); `npm audit --audit-level=moderate` exits 0 for the root manifest.

### C2 — `NPM Audit Gate / npm audit (extensions/drm-copilot)` fails

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the moderate advisories carry "fix available via `npm audit fix`"; `deepmerge` (fix only via `--force`) is below the moderate gate.
Finding-Scope: contained

- Failing check: `NPM Audit Gate / npm audit (extensions/drm-copilot)`
- Failing job: https://github.com/drmoisan/drm-copilot/actions/runs/43460709376/job/132010740667
- Observed: 8 vulnerabilities (6 low, 2 moderate): `hono <=4.13.15` and `@hono/node-server` 2.0.0 - 2.1.5 as in C1; `deepmerge >=4.2.0` (GHSA-gcqx-w48m-w2h4) offers only `npm audit fix --force`.
- Required change: non-breaking lockfile update of `extensions/drm-copilot/package-lock.json`; `npm audit --audit-level=moderate` exits 0 for that manifest. A finding that can be resolved only by a breaking change is recorded, not forced.

### C3 — `NPM Audit Gate / npm audit (packages/mcp-server)` fails

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the moderate advisories carry "fix available via `npm audit fix`".
Finding-Scope: contained

- Failing check: `NPM Audit Gate / npm audit (packages/mcp-server)`
- Failing job: https://github.com/drmoisan/drm-copilot/actions/runs/43460709376/job/132010740875
- Observed: moderate advisories against `hono <=4.13.15`, "fix available via `npm audit fix`".
- Required change: non-breaking lockfile update of `packages/mcp-server/package-lock.json`; `npm audit --audit-level=moderate` exits 0 for that manifest.

## Verification required

- `npm audit --audit-level=moderate` exits 0 for each of the three manifests after the update.
- Root TypeScript tests and the extension Jest suite pass at phase-gate level (parallel workers) after the lockfile updates; the MCP server package tests run where the package defines them.
- The lockfile diff is limited to the dependency versions the audit fix selects; no `package.json` range is widened by hand and no `--force` is used.
- Self-review file rewritten with no FAIL row; the PR head is re-reviewed (records-only commits inside the feature folder excepted).

## Constraints

- Tests run in parallel only; test-order dependence is a violation.
- Evidence is append-only, stamped from clock reads; no artifact records an absolute path.
- No new Python file. No change outside the three lockfiles (and `package.json` only if `npm audit fix` itself rewrites it), the feature folder, and evidence.
- Commands use the sibling-worktree forms (`npm --prefix <abs>`).
