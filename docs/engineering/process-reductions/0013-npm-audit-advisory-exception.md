# 0013: npm audit advisory exception

## Summary

reduction: 0013
Date: 2026-11-18
Issue: #1204
Merge commit: pending (PR #1205)

The NPM Audit Gate (`.github/workflows/_npm-audit-gate.yml`) stops failing on advisory GHSA-fc5q-39xc-vjpf (picomatch, high severity, no patched version) while every affected path is development-only and the exception has not expired. The bare step `npm audit --audit-level="$AUDIT_LEVEL"` is replaced by `scripts/ci/Invoke-NpmAuditGate.ps1`, which runs a strict production pass (`npm audit --omit=dev --audit-level=<level>`, no exception logic) and a full pass (`npm audit --json`, dev dependencies included) filtered by the committed `config/npm-audit-exceptions.json`. The exception names one advisory id, expires on 2026-12-18, and is enforced in code. The audit level is not lowered, and dev dependencies are not omitted from the full audit.

## Reason and Evidence

The gate failed on every branch, including `main`, because the advisory has no fix and the gate had no exception mechanism; every pull request was blocked. `picomatch` reaches the repository only through development dependencies (`jest`, `@parcel/watcher`). A real run of `npm audit --omit=dev --json` in `.`, `extensions/drm-copilot`, and `packages/mcp-server` returned no vulnerabilities and exit 0, while `npm audit --json` returned one advisory object (GHSA-fc5q-39xc-vjpf, severity high) in `.` and `extensions/drm-copilot` and none in `packages/mcp-server` (`docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/evidence/other/npm-audit-observation.2026-11-18T03-41.md`). The reduction is bounded: one advisory id, a 30-day expiry, a production-only strict pass, five distinct failure codes, and every applied exception printed to the job log and `GITHUB_STEP_SUMMARY`. The spec is `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/spec.md`.

## Files Changed

- `.github/workflows/_npm-audit-gate.yml`, source (the `Audit dependencies` step)
- `scripts/ci/NpmAuditGate.psm1`, new pure module
- `scripts/ci/Invoke-NpmAuditGate.ps1`, new entry script
- `config/npm-audit-exceptions.json`, new exception file
- `tests/scripts/ci/NpmAuditGate.Tests.ps1`, new test
- `tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1`, new test
- `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1`, new test

## Prior Text

### Revert Block: .github/workflows/_npm-audit-gate.yml

````Current
shell: pwsh
        run: ${{ github.workspace }}/scripts/ci/Invoke-NpmAuditGate.ps1 -AuditLevel "$env:AUDIT_LEVEL" -ExceptionsPath "${{ github.workspace }}/config/npm-audit-exceptions.json"
````

````Prior
run: npm audit --audit-level="$AUDIT_LEVEL"
````

## Revert Steps

1. Apply the blocks: replace the `Current` fence of `.github/workflows/_npm-audit-gate.yml` with its `Prior` fence, which restores the single line `run: npm audit --audit-level="$AUDIT_LEVEL"`, and delete `scripts/ci/NpmAuditGate.psm1`, `scripts/ci/Invoke-NpmAuditGate.ps1`, `config/npm-audit-exceptions.json`, `tests/scripts/ci/NpmAuditGate.Tests.ps1`, `tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1`, and `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1`.
2. Re-copy mirrors and bundles: not applicable.
3. Regenerate Codex variants: not applicable.
4. Restore pinned hashes: not applicable.
5. Restore contract-test literals: not applicable.
6. Run the contract tests: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` and `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`.

## Revert Signals

- Upstream publishes a patched `picomatch` (remove the exception and revert), or the 2026-12-18 expiry passes without a patched release (extend with a new reviewed entry or revert).
- The gate reports `NPM_AUDIT_EXCEPTION_INVALID` or `NPM_AUDIT_OUTPUT_UNPARSEABLE` on a run with no change to the exception file or to npm, which points to a defect in the gate script rather than in the dependencies.
- A reviewer or a security scan finds that an excepted advisory reaches a production dependency that the strict production pass did not report.
