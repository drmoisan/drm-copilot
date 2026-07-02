# Remediation Plan: codex-worktree-session-failures (#268)

- **Issue:** #268
- **Work Mode:** full-bug
- **Feature folder:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268`
- **Authoritative remediation input:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268/remediation-inputs.2026-07-02T14-18.md`
- **Original plan:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md`
- **Status:** Draft remediation plan
- **Timestamp:** 2026-07-02T14-18

## Execution Rules

- Execute tasks in order.
- Store all new remediation evidence under `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, or `evidence/other/`.
- Each command evidence artifact must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Keep the original feature plan synchronized where remediation changes complete previously checked-but-invalid outcomes.
- Do not change source code outside the files named in this plan unless a validator output identifies an additional required reference update.

### Phase 0 — Remediation Baseline And Status Sync

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/typescript/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, and `docs/features/active/2026-07-02-codex-worktree-session-failures-268/remediation-inputs.2026-07-02T14-18.md`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/remediation-baseline/remediation-instructions-read.2026-07-02T14-18.md` with `Timestamp:`, `Policy Order:`, and files read.
- [x] [P0-T2] Inspect `docs/features/active/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md`, `spec.md`, `policy-audit.2026-07-02T14-18.md`, `code-review.2026-07-02T14-18.md`, and `feature-audit.2026-07-02T14-18.md`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/remediation-baseline/remediation-status-sync.2026-07-02T14-18.md` identifying AC #7 and AC #10 as remediation targets without unchecking source criteria.
- [x] [P0-T3] Reproduce the empty-copy-plan failure with same-root execution and missing-source-folder execution; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/regression-testing/remediation-fail-before-post-codex-empty-plan.2026-07-02T14-18.md` with both commands, outputs, and failing exit status.
- [x] [P0-T4] Run `python scripts\dev_tools\validate_evidence_locations.py --root .`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/remediation-baseline/remediation-fail-before-evidence-locations.2026-07-02T14-18.md` with the reported non-canonical research path.

### Phase 1 — PowerShell No-Op Fix

- [x] [P1-T1] Update `.codex/scripts/post-codex-worktree-session.ps1` so empty copy-operation plans complete without error; acceptance criteria: same-root and missing-source-folder executions return success and real copy errors still propagate.
- [x] [P1-T2] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1` to match the root script exactly; acceptance criteria: SHA-256 parity succeeds.
- [x] [P1-T3] Extend `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1` with focused coverage for empty copy-operation execution; acceptance criteria: tests prove same-root and missing-source-folder no-op behavior does not throw without using persistent temporary files.

### Phase 2 — Evidence Location Remediation

- [x] [P2-T1] Move or mirror `artifacts/research/2026-07-02T13-17-codex-worktree-session-failures-268-research.md` to `docs/features/active/2026-07-02-codex-worktree-session-failures-268/research/2026-07-02T13-17-codex-worktree-session-failures-268-research.md` or another validator-approved path.
- [x] [P2-T2] Update references to the research artifact in `docs/features/active/2026-07-02-codex-worktree-session-failures-268/spec.md`, `docs/features/active/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md`, and affected evidence artifacts; acceptance criteria: no remaining reference points at `artifacts/research/2026-07-02T13-17-codex-worktree-session-failures-268-research.md`.
- [x] [P2-T3] Run `python scripts\dev_tools\validate_evidence_locations.py --root .`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/qa-gates/remediation-evidence-location-validation.2026-07-02T14-18.md` with EXIT_CODE 0.

### Phase 3 — Remediation QA Loop

- [x] [P3-T1] Run `mcp__drm-copilot__run_poshqc_format`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/qa-gates/remediation-powershell-poshqc-format.2026-07-02T14-18.md` with EXIT_CODE 0 and changed-file status.
- [x] [P3-T2] Run `mcp__drm-copilot__run_poshqc_analyze`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/qa-gates/remediation-powershell-poshqc-analyze.2026-07-02T14-18.md` with EXIT_CODE 0.
- [x] [P3-T3] Run `mcp__drm-copilot__run_poshqc_test`; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/qa-gates/remediation-powershell-pester-coverage.2026-07-02T14-18.md` with EXIT_CODE 0 and numeric coverage values.
- [x] [P3-T4] Run `Push-Location extensions/drm-copilot; npm run format; Pop-Location`, `Push-Location extensions/drm-copilot; npm run lint; Pop-Location`, `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location`, and `Push-Location extensions/drm-copilot; npm run test:unit -- --coverage; Pop-Location` if TypeScript or `package.json` references changed; write one evidence artifact per command under `evidence/qa-gates/` with EXIT_CODE 0.
- [x] [P3-T5] Rerun the direct same-root and missing-source no-op script commands; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/regression-testing/remediation-pass-after-post-codex-empty-plan.2026-07-02T14-18.md` with EXIT_CODE 0 for both.

### Phase 4 — Final Sync And Review Readiness

- [x] [P4-T1] Update `docs/features/active/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md` only if a checklist item was materially contradicted by remediation evidence; otherwise write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/other/remediation-plan-sync-no-change.2026-07-02T14-18.md`.
- [x] [P4-T2] Run `mcp__drm-copilot__validate_orchestration_artifacts` for this remediation plan and the original plan; write `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/other/remediation-plan-validator.2026-07-02T14-18.md` with EXIT_CODE 0.
- [x] [P4-T3] Request or run a follow-up feature review using the same active feature folder; acceptance criteria: new policy-audit, code-review, and feature-audit artifacts record PASS or identify only new remediation findings.
