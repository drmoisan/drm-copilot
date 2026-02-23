# Remediation Plan: 2026-02-23-minor-audit-planning-58 (2026-02-23T14-24)

- **Issue:** 58
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-23T14-24
- **Status:** Planned
- **Version:** 0.1-remediation

## Required References

- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/python-code-change.instructions.md`
- `.github/instructions/python-unit-test.instructions.md`
- `.github/instructions/powershell-code-change.instructions.md`
- `.github/instructions/powershell-unit-test.instructions.md`
- `docs/features/active/2026-02-23-minor-audit-planning-58/remediation-inputs.2026-02-23T14-24.md`

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline sync and scope lock
- [ ] [P0-T1] Verify remediation scope against `remediation-inputs.2026-02-23T14-24.md` and confirm only `scripts/dev-tools/new-potential-entry.ps1` and `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` require edits.
  - Acceptance: scope lock note added to execution log; no unrelated file edits.
- [ ] [P0-T2] Synchronize original feature plan status by reviewing `plan.2026-02-23T17-20.md` and recording completed-vs-unchecked discrepancies before remediation edits.
  - Acceptance: status-sync note captured and referenced in remediation execution summary.

### Phase 1 — PowerShell lint compliance
- [ ] [P1-T1] Update indentation in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` for lines flagged by PSScriptAnalyzer (257–267).
  - Acceptance: no `PSUseConsistentIndentation` findings remain for this file.
- [ ] [P1-T2] Run PowerShell analyzer and confirm zero findings.
  - Acceptance: `Invoke-PoshQCAnalyze -Root .` exits 0.

### Phase 2 — Insiders command preference behavior fix
- [ ] [P2-T1] Update `Invoke-VSCodeOpen` in `scripts/dev-tools/new-potential-entry.ps1` to prefer `code-insiders` when insider session signal exists and command is available, with fallback to `code`.
  - Acceptance: behavior aligns with existing/failing test expectations.
- [ ] [P2-T2] Run Pester and confirm the insiders preference scenario passes with no regressions.
  - Acceptance: `Invoke-PoshQCTest -Root .` exits 0.

### Phase 3 — Final QA loop and plan-status sync
- [ ] [P3-T1] Run final full quality loop for impacted toolchains (Python, JSON, PowerShell) in policy order where applicable.
  - Acceptance: Black, Ruff, Pyright, Pytest, JSON validate, PowerShell analyze, and Pester all pass.
- [ ] [P3-T2] Perform final status synchronization with original plan `plan.2026-02-23T17-20.md`, checking off any remediation-delivered items that map to previously open checklist work.
  - Acceptance: status-sync completed and documented.

## Test Plan

- PowerShell static analysis: `Invoke-PoshQCAnalyze -Root .`
- PowerShell tests: `Invoke-PoshQCTest -Root .`
- Python checks: Black, Ruff, Pyright, Pytest coverage
- JSON check: `poetry run python -m scripts.dev_tools.validate_json`

## Open Questions / Notes

- Remediation strictly targets failing PowerShell checks found in post-implementation feature review.
- No policy changes or scope expansion permitted.
