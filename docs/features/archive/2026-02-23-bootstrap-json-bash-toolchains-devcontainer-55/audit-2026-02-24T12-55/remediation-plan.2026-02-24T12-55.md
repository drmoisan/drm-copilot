# Remediation Plan: 2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55 (2026-02-24T12-55)

- **Issue:** 55
- **Status:** Scope-corrected remediation plan
- **Work Mode Source:** `issue.md`
- **Selected Work Mode:** `minor-audit`
- **Reason for remediation:** Prior remediation scope incorrectly referenced out-of-scope host scripts.

## Overview

This remediation plan closes the remaining audit gaps for feature #55 by capturing explicit devcontainer-open PASS evidence for local Docker and Codespaces, then synchronizing plan status at two checkpoints. The plan is constrained to documentation/evidence updates inside this feature folder and uses machine-verifiable acceptance criteria.

### Phase 0 — Context & Inputs

- [x] [P0-T1] Resolve and record work mode from `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/issue.md` in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/remediation-baseline/mode-resolution.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact lines `Timestamp: 2026-02-24T12-55`, `Command: mode-resolution(issue.md)`, `EXIT_CODE: 0`, and `Output Summary: PASS mode=minor-audit source=issue.md`.

- [x] [P0-T2] Record policy-read precedence evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/remediation-baseline/policy-read-order.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact lines `Command: read policy files in required order`, `EXIT_CODE: 0`, and ordered entries for `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, and `.github/instructions/python-code-change.instructions.md|.github/instructions/python-unit-test.instructions.md|.github/instructions/powershell-code-change.instructions.md|.github/instructions/powershell-unit-test.instructions.md`.

- [x] [P0-T3] Capture remediation baseline inventory in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/remediation-baseline/pre-remediation-inventory.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact lines `Command: ls evidence/qa-gates && grep -n "\[x\]" plan.2026-02-23T20-42.md`, `EXIT_CODE: 0`, and an `Output Summary:` line beginning with `PASS baseline inventory captured`.

### Phase 1 — Targeted Verification Evidence (minor-audit)

- [x] [P1-T1] Capture local Docker devcontainer open/startup PASS evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/devcontainer-open-local-docker.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact line `Timestamp: 2026-02-24T12-55`, one non-empty command line matching regex `^Command: .+\S.+$`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS local Docker devcontainer open/startup`.

- [x] [P1-T2] Capture Codespaces devcontainer open/startup PASS evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/devcontainer-open-codespaces.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact line `Timestamp: 2026-02-24T12-55`, one non-empty command line matching regex `^Command: .+\S.+$`, exact line `EXIT_CODE: 0`, and exact line `Output Summary: PASS Codespaces devcontainer open/startup`.

- [x] [P1-T3] Verify both PASS artifacts are discoverable via a single grep command and record the result in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/devcontainer-open-verification.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact line `Command: grep -R "Output Summary: PASS" docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates`, exact line `EXIT_CODE: 0`, and an `Output Summary:` line that includes both filenames `devcontainer-open-local-docker.2026-02-24T12-55.md` and `devcontainer-open-codespaces.2026-02-24T12-55.md`.

### Phase 2 — Plan Status Synchronization

- [x] [P2-T1] Perform baseline plan-status sync in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/plan.2026-02-23T20-42.md` and record checkpoint evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/other/plan-status-sync-baseline.2026-02-24T12-55.md`
	- Acceptance: Checkpoint file exists and contains exact lines `Command: baseline plan-status sync plan.2026-02-23T20-42.md`, `EXIT_CODE: 0`, and `Output Summary: PASS baseline sync completed`.

- [x] [P2-T2] Perform final plan-status sync in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/plan.2026-02-23T20-42.md` after [P1-T1], [P1-T2], and [P1-T3], and record checkpoint evidence in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/other/plan-status-sync-final.2026-02-24T12-55.md`
	- Acceptance: Checkpoint file exists and contains exact lines `Command: final plan-status sync plan.2026-02-23T20-42.md`, `EXIT_CODE: 0`, and `Output Summary: PASS final sync completed`.

- [x] [P2-T3] Verify out-of-scope host script references are absent from remediation artifacts using grep and record result in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/other/scope-guard.2026-02-24T12-55.md`
	- Acceptance: Checkpoint file exists and contains exact line `Command: grep -R "scripts/bash/bootstrap-host.sh\|scripts/bash/verify-host.sh" docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55`, exact line `EXIT_CODE: 1`, and exact line `Output Summary: PASS out-of-scope host script references absent`.

### Phase 3 — End-State Evidence and Handoff

- [x] [P3-T1] Record end-state remediation summary in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/other/remediation-end-state.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact lines `Command: remediation end-state reconciliation`, `EXIT_CODE: 0`, and `Output Summary: PASS minor-audit mandatory gates complete`.

- [x] [P3-T2] Verify remediation changes are constrained to the feature folder and record result in `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/other/remediation-scope-diff.2026-02-24T12-55.md`
	- Acceptance: File exists and contains exact line `Command: git diff --name-only`, exact line `EXIT_CODE: 0`, and an `Output Summary:` line confirming all changed paths begin with `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/`.

## Do Not Do

- Do not introduce or require `scripts/bash/bootstrap-host.sh` for this remediation.
- Do not introduce or require `scripts/bash/verify-host.sh` for this remediation.
- Do not broaden remediation scope to unrelated feature folders.
- Do not modify policy files under `.github/instructions/`.
- Do not weaken or skip evidence capture gates.
