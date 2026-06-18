# pester-adapter-id-collision (Plan)

- **Issue:** #198
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-17T21-05
- **Status:** Active
- **Version:** 1.0

**Fail-closed evidence rule:** This change is test-only PowerShell; no production lines change, so no production coverage delta is possible. Adapter-collision evidence is the controlling artifact.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task.

**Phase 0 — Context & Inputs**
- [x] [P0-T1] Link approved spec: `docs/features/active/2026-06-17-pester-adapter-id-collision-198/spec.md`
- [x] [P0-T2] Record branch/commit baseline: branch `fix/pester-adapter-id-collision-198` off `main`
- [x] [P0-T3] Required environment/fixtures: Pester 5.6.1, `pspester.pester-test` adapter `PesterInterface.ps1` for collision verification

**Phase 1 — Preparation**
- [x] [P1-T1] Scope locked: disambiguate colliding case-sensitivity cases + add case-insensitive sibling-name guard; no production changes
- [x] [P1-T2] Workspace synced to branch; PoshQC toolchain available

**Phase 2 — Regression Test (must fail first)**
- [x] [P2-T1] [expect-fail] Add `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` that asserts no two sibling Describe/Context/It names — and no two literal `-ForEach` expansions — collide case-insensitively across `tests/**/*.Tests.ps1`
- [x] [P2-T2] [expect-fail] Confirm the guard fails against a synthetic case-only-distinct fixture and passes against the current (fixed) suite

**Phase 3 — Minimal Fix**
- [x] [P3-T1] Disambiguate the `-ForEach` cases in `Invoke-FullRelease.Tests.ps1` with a non-case `CaseLabel` included in the `It` name; preserve both assertions

**Phase 4 — Verification Loop**
- [x] [P4-T1] Re-run the guard and the `Invoke-FullRelease` file under Pester 5.6.1 to confirm expected behavior (full suite 604 passed / 0 failed / 9 skipped)
- [x] [P4-T2] Run PoshQC format → analyze → test; restart loop if any step changes files or fails (format clean, analyze 0 findings, test green)
- [x] [P4-T3] Adapter discovery across all `tests/**/*.Tests.ps1` produces zero colliding IDs (controlling evidence: 39 files, 608 items, 0 collisions)

**Phase 5 — Documentation & Status**
- [x] [P5-T1] Update spec/issue with root cause, fix, and AC; record outcomes

**Phase 6 — PR & Handoff**
- [ ] [P6-T1] Pre-review commit; feature-review; PR with summary, risks, validation, links to issue #198 and tests

**Phase 7 — Rollout / Follow-up**
- [ ] [P7-T1] S9 CI green gate on PR head; remediate until green
- [ ] [P7-T2] Record links (issue #198, PR, related docs) for traceability
