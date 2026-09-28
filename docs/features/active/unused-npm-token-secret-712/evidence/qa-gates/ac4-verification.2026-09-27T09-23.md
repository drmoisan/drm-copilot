# AC4 Verification Cross-Reference (P6-T6)

Timestamp: 2026-09-27T09-23

| Item | Artifact | Observed | Status |
|---|---|---|---|
| P4-T1 records `1` for both runbook checks | `docs/features/active/unused-npm-token-secret-712/evidence/other/runbook-coverage-check.2026-09-27T09-19.md` | `Delete the Unused` -> 1; `Identify and revoke the matching npm access token` -> 1; both EXIT_CODE 0 | met |
| P4-T2 file carries `Status: pending` | `docs/features/active/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md` | `grep -c -F "Status: pending"` -> 1 | met |
| P4-T3 records `EXIT_CODE: 1` | `docs/features/active/unused-npm-token-secret-712/evidence/other/human-action-pending-no-credential.2026-09-27T09-19.md` | `0`, EXIT_CODE 1 (no token-shaped string) | met |

Pending statement: the human action has not been performed. Deleting the `NPM_TOKEN` repository secret and revoking the corresponding npm access token remain pending, and neither is claimed complete. Under spec decision D5, AC4 is satisfied when the runbook exists and the action is recorded as pending.

Result: acceptance met.
