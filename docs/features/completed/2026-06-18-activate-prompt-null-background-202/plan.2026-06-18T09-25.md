# activate-prompt-null-background (Plan)

- **Issue:** #202
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-18T09-25
- **Status:** Active
- **Version:** 1.0

**Fail-closed evidence rule:** This change touches one production PowerShell file (`activate.ps1`, Tier T4) and its test. Coverage must not regress on changed lines; the new null-background test covers the changed branch.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task.

**Phase 0 — Context & Inputs**
- [x] [P0-T1] Link approved spec: `docs/features/active/2026-06-18-activate-prompt-null-background-202/spec.md`
- [x] [P0-T2] Record branch/commit baseline: branch `fix/activate-prompt-null-background` off `main` (`db3d528`)
- [x] [P0-T3] Reproduce the failure deterministically: `Get-VenvAwarePrompt -BackgroundColor $null` throws the ConsoleColor cast error

**Phase 1 — Preparation**
- [x] [P1-T1] Scope locked: null-tolerant `-BackgroundColor` + deterministic regression test; no other behavior changes
- [x] [P1-T2] Workspace on branch; PoshQC toolchain available

**Phase 2 — Regression Test (must fail first)**
- [x] [P2-T1] [expect-fail] Add a unit test asserting `Get-VenvAwarePrompt -BackgroundColor $null` returns the uncolored prompt
- [x] [P2-T2] [expect-fail] Confirm the test fails against the pre-fix code (null bind throws) and passes after the fix

**Phase 3 — Minimal Fix**
- [x] [P3-T1] Make `Get-VenvAwarePrompt -BackgroundColor` optional/`[AllowNull()]`/`[System.Nullable[System.ConsoleColor]]`; treat null as not-dark; leave `Test-IsDarkBackground` unchanged

**Phase 4 — Verification Loop**
- [x] [P4-T1] Re-run repro: null -> uncolored prompt; dark -> green; light -> plain
- [x] [P4-T2] Run PoshQC format -> analyze -> test; restart loop on any change/failure (BOM/non-ASCII finding fixed; re-ran clean)
- [x] [P4-T3] Full `activate.Tests.ps1`: 53 passed / 0 failed / 0 skipped (Pester 5.6.1)

**Phase 5 — Documentation & Status**
- [x] [P5-T1] Update spec/issue with root cause, fix, and AC

**Phase 6 — PR & Handoff**
- [ ] [P6-T1] Pre-review commit; feature-review; PR with summary, risks, validation, links to issue #202

**Phase 7 — Rollout / Follow-up**
- [ ] [P7-T1] S9 CI green gate on PR head; remediate until green
- [ ] [P7-T2] Record links (issue #202, PR) for traceability
