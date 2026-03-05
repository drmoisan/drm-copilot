# 2026-03-05-bootstrap-agentic-csharp-work - Plan

- **Issue:** #79
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-05T06-40
- **Status:** Draft
- **Version:** 0.2
- **Directive:** MINIMAL-AUDIT PLAN REQUIRED
- **Requirements Source:** `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/issue.md` (sole source)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read required policy files in mandated order and write `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/phase0-instructions-read.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Policy Order:`, and explicit file list including `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, and `.github/instructions/powershell-unit-test.instructions.md`.
- [x] [P0-T2] Record sole requirements-source evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/other/requirements-source.md`
  - Acceptance: Artifact exists and contains exact lines `Requirements Source: docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/issue.md` and `Disallowed Sources: spec.md, user-story.md, research.md`.
- [x] [P0-T3] Run `poetry run black . --check` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/python-format.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run black . --check`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [x] [P0-T4] Run `poetry run ruff check` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/python-lint.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [x] [P0-T5] Run `poetry run pyright` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/python-typecheck.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [x] [P0-T6] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/python-test-coverage.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: [0-9]+`, and `Output Summary:` with numeric coverage headline values.
- [x] [P0-T7] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/powershell-format.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [x] [P0-T8] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/powershell-analyze.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [x] [P0-T9] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and store baseline step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/baseline/powershell-test.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.

### Phase 1 — Constrained Small-Path Implementation Placeholder

- [ ] [P1-T1] Delegate constrained small-path implementation using only `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/issue.md` requirements and record handoff in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/other/small-path-implementation-handoff.md`
  - Acceptance: Artifact exists and contains exact lines `Work Mode: minor-audit`, `Requirements Source: issue.md only`, and `Forbidden Inputs: spec.md, user-story.md, research.md`.
- [ ] [P1-T2] Record implementation completion checkpoint in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/other/small-path-implementation-complete.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Changed Files:`, and `Completion Signal: IMPLEMENTATION COMPLETE`.

### Phase 2 — Final QC Loop

- [ ] [P2-T1] Run `poetry run black .` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/python-format.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [ ] [P2-T2] Run `poetry run ruff check` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/python-lint.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [ ] [P2-T3] Run `poetry run pyright` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/python-typecheck.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [ ] [P2-T4] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/python-test-coverage.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: [0-9]+`, and `Output Summary:` with numeric post-change coverage values.
- [ ] [P2-T5] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/powershell-format.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [ ] [P2-T6] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/powershell-analyze.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [ ] [P2-T7] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and store final-QC step evidence in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/powershell-test.md`
  - Acceptance: Artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: [0-9]+`, and `Output Summary:`.
- [ ] [P2-T8] Rerun the full final QC command sequence from `[P2-T1]` after any command that changes files or returns non-zero exit code and record loop status in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/qa-gates/final-qc-loop-summary.md`
  - Acceptance: Artifact exists and contains exact lines `Loop Rule: restart from P2-T1 on change or failure` and `Final Loop Result: PASS`.
- [ ] [P2-T9] Record reduced small-audit handoff in `docs/features/active/2026-03-05-bootstrap-agentic-csharp-work-79/evidence/other/minor-audit-handoff.md`
  - Acceptance: Artifact exists and contains exact lines `Audit Scope: reduced small-path`, `Baseline Evidence: complete`, and `End-State Evidence: complete`.
