---
title: 2026-02-23-bootstrap-json-bash-toolchains-devcontainer - Plan
issue: 55
parent: none
owner: drmoisan
last_updated: 2026-02-23T20-42
status: In progress
status_color: yellow
version: 1.1
work_mode: minor-audit
fallback_reason: none
mode_source_of_truth: issue.md
---

# 2026-02-23-bootstrap-json-bash-toolchains-devcontainer - Plan

![Status: In progress](https://img.shields.io/badge/Status-In%20progress-yellow)

- **Issue:** #55
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-23T20-42
- **Status:** In progress
- **Version:** 1.1
- **Selected Work Mode:** minor-audit

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs

Phase completion criteria:
- Work mode is resolved from `issue.md` and recorded.
- Requirement source is locked without blocking on missing `spec.md`.
- Policy-read order evidence is recorded in required precedence order.
- Baseline no-harm evidence artifacts exist with required machine-checkable schema fields.
- Baseline toolchain runs for each touched language are captured in Phase 0.

- [x] [P0-T1] Resolve work mode from `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/issue.md` metadata and record `minor-audit` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/mode-resolution.*.md`
  - Acceptance: Evidence file exists and contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: mode-resolution(issue.md)`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS mode=minor-audit source=issue.md`.

- [x] [P0-T2] Lock requirement source by recording that `spec.md` is absent and `issue.md` acceptance criteria are authoritative in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/requirements-source.*.md`
  - Acceptance: Evidence file exists and contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: requirements-source-lock(issue.md)`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS spec.md absent, issue.md authoritative under minor-audit`.

- [x] [P0-T3] Record policy-read evidence for `.github/copilot-instructions.md` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/policy-read-01.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: read .github/copilot-instructions.md`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS policy-read-order step=1`.

- [x] [P0-T4] Record policy-read evidence for `.github/instructions/general-code-change.instructions.md` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/policy-read-02.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: read .github/instructions/general-code-change.instructions.md`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS policy-read-order step=2`.

- [x] [P0-T5] Record policy-read evidence for `.github/instructions/general-unit-test.instructions.md` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/policy-read-03.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: read .github/instructions/general-unit-test.instructions.md`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS policy-read-order step=3`.

- [x] [P0-T6] Record policy-read evidence for `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, and `.github/instructions/powershell-unit-test.instructions.md` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/policy-read-04.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: read language policies python/powershell`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS policy-read-order step=4`.

- [x] [P0-T7] Capture baseline repository state using `git status --porcelain` and `git diff --name-only` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/repo-state.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: git status --porcelain && git diff --name-only`, integer `EXIT_CODE`, and exact line `Output Summary: PASS baseline repo-state captured`.

- [x] [P0-T8] Capture baseline Python toolchain run in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/python-toolchain.*.md` using `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, one `Command:` line per baseline Python command, one integer `EXIT_CODE:` line per `Command:` line, and exact line `Output Summary: PASS|FAIL baseline python toolchain`.

- [x] [P0-T9] Capture baseline PowerShell toolchain run in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/powershell-toolchain.*.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, one `Command:` line per baseline PowerShell command, one integer `EXIT_CODE:` line per `Command:` line, and exact line `Output Summary: PASS|FAIL baseline powershell toolchain`.

- [x] [P0-T10] Capture baseline JSON/Bash toolchain run in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/json-bash-toolchain.*.md` using `poetry run python -m scripts.dev_tools.format_json`, `poetry run python -m scripts.dev_tools.validate_json`, `poetry run shell-qc format`, `poetry run shell-qc check`, and `poetry run shell-qc test`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, one `Command:` line per baseline JSON/Bash command, one integer `EXIT_CODE:` line per `Command:` line, and exact line `Output Summary: PASS|FAIL baseline json-bash toolchain`.

### Phase 1 — Baseline QC Capture (Pre-Bootstrap)

Phase completion criteria:
- Baseline QC outcomes are captured before bootstrap execution.
- Evidence uses canonical baseline paths and PASS/FAIL output summaries.

- [x] [P1-T1] Capture baseline JSON formatter result using `poetry run python -m scripts.dev_tools.format_json` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/json-format.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: poetry run python -m scripts.dev_tools.format_json`, integer `EXIT_CODE`, and `Output Summary:` beginning with `PASS` or `FAIL`.

- [x] [P1-T2] Capture baseline JSON validator result using `poetry run python -m scripts.dev_tools.validate_json` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/json-validate.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: poetry run python -m scripts.dev_tools.validate_json`, integer `EXIT_CODE`, and `Output Summary:` beginning with `PASS` or `FAIL`.

- [x] [P1-T3] Capture baseline shell formatter result using `poetry run shell-qc format` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/shell-format.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: poetry run shell-qc format`, integer `EXIT_CODE`, and `Output Summary:` beginning with `PASS` or `FAIL`.

- [x] [P1-T4] Capture baseline shell lint result using `poetry run shell-qc check` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/shell-check.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: poetry run shell-qc check`, integer `EXIT_CODE`, and `Output Summary:` beginning with `PASS` or `FAIL`.

- [x] [P1-T5] Capture baseline shell test result using `poetry run shell-qc test` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/baseline/shell-test.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: poetry run shell-qc test`, integer `EXIT_CODE`, and `Output Summary:` beginning with `PASS` or `FAIL`.

### Phase 2 — Bootstrap Execution and Post-Bootstrap Targeted Verification

Phase completion criteria:
- Manual bootstrap of qualifying code is completed without presuming any specific script path or command shape.
- Bootstrap execution evidence records only commands that were actually run in this environment.
- Codex web setup/maintenance scripts use `drm-copilot` naming consistently.
- `codex-web-setup.sh` has explicit coverage for all required tool families implied by the Codespaces devcontainer and Dockerfile.
- `shell-qc test` discovers `tests/shell` tests and passes.

- [x] [P2-T1] Manual bootstrap of qualifying code
  - Acceptance: Evidence file `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/manual-bootstrap.*.md` exists and contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, a non-empty `Command:` line matching regex `^Command: .+\S.+$`, integer `EXIT_CODE`, and `Output Summary:` beginning with `PASS` or `FAIL`.

- [x] [P2-T2] Replace all `transcript-etl-pipeline` references with `drm-copilot` in `.github/codex/codex-web-setup.sh`
  - Acceptance: `grep -n "transcript-etl-pipeline" .github/codex/codex-web-setup.sh` exits non-zero and `grep -n "drm-copilot" .github/codex/codex-web-setup.sh` exits 0.

- [x] [P2-T3] Replace all `transcript-etl-pipeline` references with `drm-copilot` in `.github/codex/codex-web-maintenance.sh`
  - Acceptance: `grep -n "transcript-etl-pipeline" .github/codex/codex-web-maintenance.sh` exits non-zero and `grep -n "drm-copilot" .github/codex/codex-web-maintenance.sh` exits 0.

- [x] [P2-T4] Record required tool parity matrix from `.devcontainer/codespaces/devcontainer.json` and `.devcontainer/codespaces/Dockerfile` into `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/codex-setup-tool-parity.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: derive tool parity matrix from codespaces devcontainer + Dockerfile`, exact line `EXIT_CODE: 0`, and a `Required Tools:` section listing at minimum `jq`, `shfmt`, `shellcheck`, `bats`, `kcov`, `node`, `npm`, `pwsh`, `poetry`, and `actionlint`.

- [x] [P2-T5] Add tool setup/check coverage for `jq` in `.github/codex/codex-web-setup.sh`
  - Acceptance: `grep -n "jq" .github/codex/codex-web-setup.sh` exits 0 and `bash -n .github/codex/codex-web-setup.sh` exits 0.

- [x] [P2-T6] Add tool setup/check coverage for `shfmt`, `shellcheck`, and `bats` in `.github/codex/codex-web-setup.sh`
  - Acceptance: `grep -n "shfmt\\|shellcheck\\|bats" .github/codex/codex-web-setup.sh` exits 0 and `bash -n .github/codex/codex-web-setup.sh` exits 0.

- [x] [P2-T7] Add tool setup/check coverage for `kcov` in `.github/codex/codex-web-setup.sh`
  - Acceptance: `grep -n "kcov" .github/codex/codex-web-setup.sh` exits 0 and `bash -n .github/codex/codex-web-setup.sh` exits 0.

- [x] [P2-T8] Add tool setup/check coverage for `node` and `npm` in `.github/codex/codex-web-setup.sh`
  - Acceptance: `grep -n "node\\|npm" .github/codex/codex-web-setup.sh` exits 0 and `bash -n .github/codex/codex-web-setup.sh` exits 0.

- [x] [P2-T9] Add tool setup/check coverage for `actionlint` in `.github/codex/codex-web-setup.sh`
  - Acceptance: `grep -n "actionlint" .github/codex/codex-web-setup.sh` exits 0 and `bash -n .github/codex/codex-web-setup.sh` exits 0.

- [x] [P2-T10] Add shell test scenario for `.github/codex/codex-web-setup.sh` naming banner update in `tests/shell/test_codex_web_setup_source_safety.bats`
  - Acceptance: `poetry run shell-qc test` exits 0 and test output includes `test_codex_web_setup_source_safety.bats`.

- [x] [P2-T11] Add shell test scenario for `.github/codex/codex-web-setup.sh` tool parity assertions in `tests/shell/test_codex_web_setup_apt_helpers.bats`
  - Acceptance: `poetry run shell-qc test` exits 0 and test output includes `test_codex_web_setup_apt_helpers.bats`.

- [x] [P2-T12] Add shell test scenario for `.github/codex/codex-web-maintenance.sh` naming banner update in `tests/shell/test_codex_web_setup_pypi_connectivity.bats`
  - Acceptance: `poetry run shell-qc test` exits 0 and test output includes `test_codex_web_setup_pypi_connectivity.bats`.

- [x] [P2-T13] Verify `shell-qc test` discovers tests under `tests/shell` and all shell tests pass; record results in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/shell-qc-tests.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: poetry run shell-qc test`, exact line `EXIT_CODE: 0`, exact line `Output Summary: PASS shell tests discovered and passed`, and a `Discovered Test Files:` section including `tests/shell/test_codex_web_setup_apt_helpers.bats`, `tests/shell/test_codex_web_setup_pypi_connectivity.bats`, `tests/shell/test_codex_web_setup_source_safety.bats`, and `tests/shell/test_coverage_demo.bats`.

### Phase 3 — Final QA Loop and End-State No-Harm Evidence

Phase completion criteria:
- Final toolchain pass is clean after bootstrap execution.
- End-state evidence proves no unintended repository harm.

- [x] [P3-T1] Run final Python toolchain pass in order using `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
  - Acceptance: All four commands exit `0` in one uninterrupted pass; if any command fails or changes files, rerun from Black.

- [x] [P3-T2] Run final PowerShell toolchain pass in order using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: All commands exit `0` in one uninterrupted pass; if formatting/analyze/test changes files or fails, rerun from format.

- [x] [P3-T3] Run final JSON/Bash toolchain pass in order using `poetry run python -m scripts.dev_tools.format_json`, `poetry run python -m scripts.dev_tools.validate_json`, `poetry run shell-qc format`, `poetry run shell-qc check`, and `poetry run shell-qc test`
  - Acceptance: All commands exit `0` in one uninterrupted pass; if any command fails or changes files, rerun from JSON format.

- [x] [P3-T4] Record final QA gate evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/final-toolchain-pass.*.md`
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, one `Command:` line per command executed in P3-T1 through P3-T3, one integer `EXIT_CODE:` line per `Command:` line, and exact line `Output Summary: PASS final QA loop clean`.

- [x] [P3-T5] Record end-state no-harm evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/other/end-state-no-harm.*.md` by comparing baseline repository state artifact to post-bootstrap repository state artifact
  - Acceptance: Evidence file contains `Timestamp:` matching regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$`, exact line `Command: compare baseline repo-state vs post-repo-state`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS no unintended repo changes outside evidence artifacts`.


## Requirements Traceability

| REQ ID | Requirement | Plan Task Coverage |
|---|---|---|
| REQ-001 | Use issue.md as authoritative requirement source under minor-audit when spec.md is absent | P0-T1, P0-T2 |
| REQ-002 | Capture baseline evidence before bootstrap execution | P0-T7, P0-T8, P0-T9, P0-T10, P1-T1, P1-T2, P1-T3, P1-T4, P1-T5 |
| REQ-003 | Execute qualifying bootstrap path without implementing new code and without presuming script paths | P2-T1 |
| REQ-004 | Capture post-bootstrap targeted verification for JSON and Bash QC | P3-T3, P3-T4 |
| REQ-005 | Prove no repository harm from bootstrap execution | P3-T5 |
| REQ-006 | Preserve non-Bash toolchain health (Python and PowerShell non-regression) | P3-T1, P3-T2 |
| REQ-007 | Complete minor-audit mandatory gates (baseline, targeted verification, end-state evidence) | P0-T1, P0-T2, P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P2-T1, P3-T4, P3-T5 |
| REQ-008 | Record mandatory policy-read precedence evidence | P0-T3, P0-T4, P0-T5, P0-T6 |
| REQ-009 | Codex web setup script uses repository name `drm-copilot` instead of legacy naming | P2-T2 |
| REQ-010 | Codex web maintenance script uses repository name `drm-copilot` instead of legacy naming | P2-T3 |
| REQ-011 | Codex web setup script covers required tools implied by Codespaces devcontainer and Dockerfile | P2-T4, P2-T5, P2-T6, P2-T7, P2-T8, P2-T9 |
| REQ-012 | Shell tests explicitly exercise codex web setup and maintenance script updates | P2-T10, P2-T11, P2-T12 |
| REQ-013 | shell-qc discovers tests/shell and executes them successfully | P2-T13 |

## Test Plan

- Unit:
  - `poetry run pyright`
- Integration:
  - Manual bootstrap of qualifying code (record exact command(s) executed in evidence file; do not assume specific script paths)
  - `poetry run python -m scripts.dev_tools.format_json`
  - `poetry run python -m scripts.dev_tools.validate_json`
  - `poetry run shell-qc format`
  - `poetry run shell-qc check`
  - `poetry run shell-qc test`
- Manual/CLI:
  - Execute only branch-relevant JSON/Bash QC and devcontainer verification commands recorded in evidence artifacts.

## Open Questions / Notes

- `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/spec.md` does not exist at plan update time; this plan uses `issue.md` as authoritative requirement source per `minor-audit` mode rules.
- This is a no-development minimal-audit plan: it validates existing bootstrap functionality and verifies post-execution repo safety through baseline-to-post evidence comparison.
