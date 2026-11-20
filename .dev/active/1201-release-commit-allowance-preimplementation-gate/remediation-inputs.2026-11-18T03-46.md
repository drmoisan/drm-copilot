# Remediation Inputs (cycle 1 re-audit) - Issue #1201

- Timestamp: 2026-11-18T03-46
- Reviewed head: 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a (PR #1202, CI run 44229371033 in progress)
- Review-Verdict: HALT_NON_REMEDIABLE
- Remediation-Mode: proportionate
- Remediation-Path: full
- Artifacts:
  - policy-audit: docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/policy-audit.2026-11-18T03-46.md
  - code-review: docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/code-review.2026-11-18T03-46.md
  - feature-audit: docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/feature-audit.2026-11-18T03-46.md

## Status of the cycle 1 findings

- Finding CI-1 (Linux probe failure): resolved. Victim reset and 18 leaker teardowns verified; `poshqc / PowerShell hook suites (Linux)` passed in CI at the reviewed head; reviewer gate run 28105 tests, 0 failures. No finding block is carried.

## Finding CI-2

- Severity: Blocking
- Checks: `NPM Audit Gate / npm audit (.)` and `NPM Audit Gate / npm audit (extensions/drm-copilot)` in CI run 44229371033, both failing at the reviewed head.
- Cause: advisory GHSA-fc5q-39xc-vjpf (picomatch ReDoS, high). The advisory record (updated 2026-11-17T15:56:44Z) lists picomatch `<= 4.0.7` with no first patched version; the newest published picomatch is 4.0.7. `origin/main` equals the merge base `1b9e5746e` and does not yet carry the coordinator's scoped exception. The branch changes no package manifest, lockfile, or audit configuration.
- Required outcome: none on this branch. After the scoped exception is merged to `main`, merge `main` into `bug/release-commit-allowance-gate` and re-run CI. If a patched picomatch is published first, the dependency update belongs to `main`, not to this item.
- Remediability: external_dependency
- Remediability-Evidence: no patched picomatch release exists, and the only in-repository route that keeps the audit gate intact is the coordinator-owned exception on main, which this item must not make.
- Finding-Scope: design
