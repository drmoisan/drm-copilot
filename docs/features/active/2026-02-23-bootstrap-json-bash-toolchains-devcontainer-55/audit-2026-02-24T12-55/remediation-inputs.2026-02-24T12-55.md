# Remediation Inputs — bootstrap-json-bash-toolchains-devcontainer-55

Timestamp: 2026-02-24T12-55
Base branch: main (assumed)

## Required Fixes (authoritative)

1. Provide direct evidence for local Docker + Codespaces devcontainer-open success.
   - Files: feature evidence under `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates/`
   - Expected behavior:
     - Evidence explicitly demonstrates successful open/startup in both local Docker and Codespaces contexts.
   - Acceptance criteria:
     - Two evidence artifacts exist (or one combined artifact with clearly separate sections), each including `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary: PASS ...`.
   - Verification commands:
     - `grep -R "Output Summary: PASS" docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/evidence/qa-gates`

2. Reconcile scope narrative and acceptance source-of-truth artifacts.
   - Files: `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/issue.md`, `plan.2026-02-23T20-42.md`, and evidence references.
   - Expected behavior:
     - AC language matches what is actually implemented and verified.
     - Out-of-scope host script references are removed and codex setup/devcontainer scope is explicit.
   - Acceptance criteria:
     - No contradiction between AC text and delivered files.
   - Verification commands:
     - `grep -n "codex-web-setup.sh\|codex-web-maintenance.sh\|devcontainer" docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/issue.md docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/plan.2026-02-23T20-42.md`

3. Plan status synchronization (mandatory).
   - Files: `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/plan.2026-02-23T20-42.md`
   - Expected behavior:
     - Baseline sync: check off any already-delivered but unchecked items immediately after remediation plan creation.
     - Final sync: update all delivered items again at remediation completion.
   - Acceptance criteria:
     - Two explicit sync checkpoints are documented in remediation execution history.
   - Verification commands:
     - `grep -n "\[x\]" docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/plan.2026-02-23T20-42.md`

## Do Not Do

- Do not broaden remediation scope into unrelated feature #58 work.
- Do not weaken lint/type/test policies or disable checks to force green status.
- Do not silently skip evidence capture for required AC verification.
- Do not edit policy files under `.github/instructions/`.

## Unmet Acceptance Criteria and Minimum Changes

Unmet or partially met AC from feature audit:
- AC#1 (PARTIAL): local Docker + Codespaces “open successfully” lacks direct runtime proof.
  - Minimum change: add explicit PASS evidence for both environments.
