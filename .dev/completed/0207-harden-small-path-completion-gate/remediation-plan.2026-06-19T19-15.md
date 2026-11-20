# Remediation Plan — Issue #207 (CI failure, pass 1)

- Timestamp: 2026-06-19T19-15
- Work Mode: minor-audit
- Feature folder: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/`
- Remediation inputs: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/remediation-inputs.2026-06-19T19-15.md`
- Plan path (this file): `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/remediation-plan.2026-06-19T19-15.md`
- Scope: resolve two Blocking findings (B1, B2) from the failing pytest contract test
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  on PR #208.

## Change Classification

This remediation is a cross-cutting bundle-mirror sync, not new logic. The repository
enforces a byte-identical mirror contract: every non-memory `.claude/**` file must exist,
byte-identical, in the bundled extension payload at
`extensions/drm-copilot/resources/claude-customizations/.claude/`. The two source files
(`.claude/hooks/enforce-completion-consistency.ps1` and `.claude/settings.json`) already
comply with policy and the 500-line limit; this remediation copies their current content
into the bundled payload so the bundle matches the repo. No `.ps1` logic, no `.py` logic,
and no test logic is modified. Because no PowerShell logic changes, the PowerShell Pester
suite is not required; however the bundled hook copy must remain byte-identical to its
source per the mirror contract.

## Findings Addressed

- B1 (Blocking): `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
  is missing entirely from the bundle. Resolved in Phase 1.
- B2 (Blocking): `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`
  differs from the repo `.claude/settings.json` (missing the new hook registration).
  Resolved in Phase 1.

## Evidence Location Invariant

All evidence artifacts produced for this remediation are written under
`docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Non-canonical paths
(`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`)
are prohibited and rejected.

---

### Phase 0 — Baseline Capture and Policy Read

- [x] [P0-T1] Read policy files in required order and record evidence to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/remediation-baseline/phase0-instructions-read.md`.
  Files, in order: `CLAUDE.md`; `.claude/rules/general-code-change.md`;
  `.claude/rules/general-unit-test.md`; `.claude/rules/powershell.md` (bundled hook is a
  `.ps1` file); `.claude/rules/python.md` and `.claude/rules/python-suppressions.md`
  (verification commands are Python toolchain). Note explicitly that this is a
  cross-cutting bundle-mirror sync, not new logic.
  Acceptance: artifact exists with `Timestamp:`, `Policy Order:`, and the explicit list of
  files read.

- [x] [P0-T2] Capture the failing baseline by running
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  and record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/remediation-baseline/baseline-bundle-contract.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`;
  the summary records that `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  fails with `AssertionError: Repo file missing from bundle: .claude/hooks/enforce-completion-consistency.ps1`
  (fail-before evidence for the remediation).

- [x] [P0-T3] Record the byte-identical pre-state of the two source files versus their
  bundled counterparts to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/remediation-baseline/baseline-bundle-diff.md`.
  Capture: (a) confirmation that
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
  is absent; (b) the difference between repo `.claude/settings.json` and bundled
  `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`
  (missing `enforce-completion-consistency.ps1` registration).
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
  identifying the two out-of-sync paths.

---

### Phase 1 — Bundle-Mirror Sync (Resolve B1 and B2)

- [x] [P1-T1] Resolve B1: copy `.claude/hooks/enforce-completion-consistency.ps1`
  byte-identical to
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`.
  Do not modify the source; create the destination file with content identical to the source.
  Acceptance: the destination file exists and is byte-identical to the repo source
  (`Compare-Object (Get-Content -Raw <src>) (Get-Content -Raw <dst>)` returns no
  differences; bundled file remains under 500 lines).

- [x] [P1-T2] Resolve B2: update
  `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` so it is
  byte-identical to the repo `.claude/settings.json` (which registers the new hook
  `enforce-completion-consistency.ps1` in the `Write|Edit` PreToolUse matcher).
  Acceptance: the bundled `settings.json` is byte-identical to the repo
  `.claude/settings.json` (`Compare-Object (Get-Content -Raw <src>) (Get-Content -Raw <dst>)`
  returns no differences; file remains under 500 lines).

---

### Phase 2 — Verification (Final QC Loop)

- [x] [P2-T1] Run the targeted bundle-contract suite:
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  Record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-bundle-contract.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
  confirming all tests in the file pass, including
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. This task also confirms
  no OTHER `.claude` file is out of sync, because that test enumerates every non-memory
  `.claude/**` repo file and asserts byte-identical presence in the bundle.

- [x] [P2-T2] Run the full repository pytest suite to confirm no regression and capture
  coverage:
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
  Record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-pytest-coverage.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
  with numeric line-coverage and branch-coverage headline values; line coverage >= 85% and
  branch coverage >= 75%; no test failures.

- [x] [P2-T3] Run Black formatting check: `poetry run black --check .`.
  Record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-black.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
  confirming no files would be reformatted. If files are reformatted, restart the loop from
  this phase's first command after correcting.

- [x] [P2-T4] Run Ruff lint check: `poetry run ruff check .`.
  Record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-ruff.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
  confirming zero lint errors.

- [x] [P2-T5] Run Pyright type check: `poetry run pyright`.
  Record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-pyright.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
  confirming zero type errors.

- [x] [P2-T6] Verify file-size compliance for the two synced files. Confirm both
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
  and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`
  are under 500 lines (the source files already comply).
  Record output to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-file-size.md`.
  Acceptance: artifact includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
  listing both files with line counts below 500.

---

### Phase 3 — Reduced Audit Handoff

- [x] [P3-T1] Reduced small-path audit handoff: confirm B1 and B2 are resolved with
  byte-identical evidence (P1-T1, P1-T2), the targeted contract test passes (P2-T1), and the
  Python toolchain is clean (P2-T2 through P2-T5). Record the reduced-audit summary to
  `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/remediation-minor-audit.md`.
  Acceptance: artifact records each finding (B1, B2) as resolved with the corresponding
  evidence path and the final EXIT_CODE for each Phase 2 command.

## Notes

- The PowerShell Pester suite is not required because no `.ps1` logic changed; the bundled
  hook is a byte-identical copy of the already-validated source. The byte-identical
  acceptance checks in P1-T1 and P2-T1 enforce that invariant.
- No production source under `src/` is excluded from coverage; this remediation does not
  add or modify coverage exclusions.
