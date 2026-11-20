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
- [x] [P0-T1] Read `.github/copilot-instructions.md` and record that repository-level instructions were reviewed before execution.
  - Acceptance: execution log contains a timestamped entry referencing `.github/copilot-instructions.md`.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and `.github/instructions/general-unit-test.instructions.md` in required policy order.
  - Acceptance: execution log records both files in the required order.
- [x] [P0-T3] Read PowerShell and Python language-specific policy files required by scope (`.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`).
  - Acceptance: execution log lists all four files and confirms they were reviewed before edits.
- [x] [P0-T4] Capture baseline PowerShell quality evidence by running `Invoke-PoshQCAnalyze -Root .` and `Invoke-PoshQCTest -Root .`.
  - Acceptance: baseline evidence artifact includes `Timestamp`, exact `Command`, and `EXIT_CODE` for both PowerShell commands.
- [x] [P0-T5] Capture baseline Python quality evidence by running `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: baseline evidence artifact includes `Timestamp`, exact `Command`, and `EXIT_CODE` for each Python command.
- [x] [P0-T6] Capture baseline JSON validation evidence by running `poetry run python -m scripts.dev_tools.validate_json`.
  - Acceptance: baseline evidence artifact includes `Timestamp`, exact `Command`, and `EXIT_CODE` for JSON validation.
- [x] [P0-T7] Verify remediation scope against `remediation-inputs.2026-02-23T14-24.md` and confirm only `scripts/dev-tools/new-potential-entry.ps1` and `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` require edits.
  - Acceptance: scope lock note added to execution log; no unrelated file edits.
- [x] [P0-T8] Synchronize original feature plan status by reviewing `plan.2026-02-23T17-20.md` and recording completed-vs-unchecked discrepancies before remediation edits.
  - Acceptance: status-sync note captured and referenced in remediation execution summary.

### Phase 1 — PowerShell lint compliance
- [x] [P1-T1] Update indentation in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` for lines flagged by PSScriptAnalyzer (257–267).
  - Acceptance: no `PSUseConsistentIndentation` findings remain for this file.
- [x] [P1-T2] Run PowerShell analyzer and confirm zero findings.
  - Acceptance: `Invoke-PoshQCAnalyze -Root .` exits 0.

### Phase 2 — Insiders command preference behavior fix
- [x] [P2-T1] Update `Invoke-VSCodeOpen` in `scripts/dev-tools/new-potential-entry.ps1` to prefer `code-insiders` when insider session signal exists and command is available, with fallback to `code`.
  - Acceptance: behavior aligns with existing/failing test expectations.
- [x] [P2-T2] Run Pester and confirm the insiders preference scenario passes with no regressions.
  - Acceptance: `Invoke-PoshQCTest -Root .` exits 0.

### Phase 3 — Final QA loop and plan-status sync
- [x] [P3-T1] Run PowerShell final QA loop in order: formatter (`Invoke-PoshQCFormat -Root .`), analyzer (`Invoke-PoshQCAnalyze -Root .`), then Pester (`Invoke-PoshQCTest -Root .`).
  - Acceptance: all three commands exit 0 in one final pass, and if any command fails or changes files the loop is restarted from formatter.
- [x] [P3-T2] Run Python final QA loop in order: `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, then `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: all four commands exit 0 in one final pass, and if any command fails or changes files the loop is restarted from Black.
- [x] [P3-T3] Run final JSON validation with `poetry run python -m scripts.dev_tools.validate_json` after Python and PowerShell loops complete.
  - Acceptance: JSON validation command exits 0 and is recorded in final QA evidence.
- [x] [P3-T4] Perform final status synchronization with original plan `plan.2026-02-23T17-20.md`, checking off any remediation-delivered items that map to previously open checklist work.
  - Acceptance: status-sync completed and documented.

## Test Plan

- PowerShell static analysis: `Invoke-PoshQCAnalyze -Root .`
- PowerShell tests: `Invoke-PoshQCTest -Root .`
- Python checks: Black, Ruff, Pyright, Pytest coverage
- JSON check: `poetry run python -m scripts.dev_tools.validate_json`

## Open Questions / Notes

- Remediation strictly targets failing PowerShell checks found in post-implementation feature review.
- No policy changes or scope expansion permitted.
