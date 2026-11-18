# Local end-to-end run of the gate script (supplementary observation)

Timestamp: 2026-11-18T05-28
Command: `pwsh -NoProfile -File scripts/ci/Invoke-NpmAuditGate.ps1 -AuditLevel moderate -ExceptionsPath config/npm-audit-exceptions.json` with the working directory set to each of `.`, `extensions/drm-copilot`, and `packages/mcp-server` (real npm 11.20.0, no mocks), run by a `sh` helper under SCRATCH; plus one negative run with a missing exception file path. This is an observation, not a test lane; the real gate result on the runner is the CI-dependent acceptance criterion.
EXIT_CODE: 0
Output Summary:
- Manifest `.`: exit 0. Log: `npm audit --omit=dev --audit-level=moderate exited 0`, `found 0 vulnerabilities`, `npm audit --json exited 1`, then `NPM Audit Gate: PASS` and `Exception applied: id=GHSA-fc5q-39xc-vjpf package=picomatch scope=dev approved_at=2026-11-18 expires=2026-12-18 days_remaining=30 reason=...` in both the log and the Summary target (GITHUB_STEP_SUMMARY was unset locally, so the Summary text was shown on the information stream with the `[Summary]` prefix).
- Manifest `extensions/drm-copilot`: exit 0, same lines as above.
- Manifest `packages/mcp-server`: exit 0; `npm audit --json exited 0`; `Exception unused (informational): id=GHSA-fc5q-39xc-vjpf package=picomatch expires=2026-12-18`; the gate passes.
- Negative run (missing exception file): exit 1 with `NPM Audit Gate: FAIL NPM_AUDIT_EXCEPTION_INVALID: the exception file is blank`. A first version of this run printed the code twice (`FAIL NPM_AUDIT_EXCEPTION_INVALID: NPM_AUDIT_EXCEPTION_INVALID: ...`); the summary builder was fixed to print the code once and the test `NAG-DEC-ORDER prints the invalid-file code once in the failing summary` was added (task check on this change: 30 and 74 tests passed in the two selected files, 0 failed; format 0 rewritten, analyze 0 findings).
- Separate probe (pwsh 7.6 with `$ErrorActionPreference = 'Stop'`, the Actions default): a native command writing to stderr and exiting 3, captured with `2>&1`, did not throw; stderr arrived as an ErrorRecord and the exit code 3 was preserved. The wrapper `Invoke-NpmAuditExe` relies on this behavior.
