# Remediation Plan — legacy-discovery-init-templates (#362) — Cycle 3

**Timestamp:** 2026-07-18T17-57  
**Branch:** `feature/legacy-discovery-init-templates-362`  
**Issue:** #362  
**Blocking Finding:** `test_bundled_claude_payload_contains_all_repo_runtime_contracts` failing due to four missing `.claude/agents/*.md` files in bundled extension resources  
**Scope:** Push-down copy of four agent persona files from repo root into bundled mirror  

## Summary

This remediation addresses a single Blocking finding: four `.claude/agents/*.md` files (legacy-parity-analyst, migration-coverage-reviewer, requirements-reconciler, runtime-characterization-analyst) exist in the repo root but are absent from the bundled extension payload at `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`. The failing test `test_bundled_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` requires the bundle to be a byte-identical mirror of the repo `.claude/` tree (excluding `.claude/agent-memory/` and `.claude/settings.local.json`).

The fix is a purely mechanical push-down: copy each of the four files byte-for-byte from their repo-root locations into the corresponding bundled locations, re-run the Python toolchain (black, ruff, pyright, pytest with coverage), and commit.

---

### Phase 0 — Baseline Capture and Policy Compliance

### Objective
Establish a deterministic baseline of the failing test state and ensure all policy documents are read in the required order before making any changes.

- [x] [P0-T1] Read repository policy documents in required order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`. Record completion with timestamp in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-instructions-read.md`.

- [x] [P0-T2] Run baseline Python toolchain to establish failing test state. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v
  ```
  Record exact exit code, full pytest output, and the assertion failure message in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-baseline-failing-test.md`. Acceptance criterion: artifact includes `EXIT_CODE: 1` (test fails) and captures the AssertionError naming the first missing file.

- [x] [P0-T3] Enumerate all missing `.claude/agents/*.md` files in the bundled payload. Compare the full directory listing of `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\.claude\agents\` against `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\extensions\drm-copilot\resources\claude-customizations\.claude\agents\`. Generate a diff report in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-missing-files-enumeration.md` that lists:
  - Total repo-root files (count)
  - Total bundled files (count)
  - Named list of missing files (one per line, with full path)
  - Named list of any files in the bundle that are absent from repo root (if any)
  - Named list of any content-differing files (if any)
  Acceptance criterion: artifact confirms exactly four missing files and zero content-differing files.

---

### Phase 1 — Copy Missing Agent Persona Files

### Objective
Perform byte-for-byte copy of the four missing `.claude/agents/*.md` files from repo root into the bundled extension payload.

- [x] [P1-T1] Copy `legacy-parity-analyst.md` from repo root to bundle. Execute:
  ```
  Copy-Item -Path "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\.claude\agents\legacy-parity-analyst.md" `
    -Destination "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\extensions\drm-copilot\resources\claude-customizations\.claude\agents\legacy-parity-analyst.md" `
    -Force
  ```
  Verify byte-for-byte equality with: `Get-FileHash -Algorithm SHA256` on both source and destination. Record hashes in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-copy-legacy-parity-analyst.md`. Acceptance criterion: both hashes match.

- [x] [P1-T2] Copy `migration-coverage-reviewer.md` from repo root to bundle. Execute:
  ```
  Copy-Item -Path "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\.claude\agents\migration-coverage-reviewer.md" `
    -Destination "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\extensions\drm-copilot\resources\claude-customizations\.claude\agents\migration-coverage-reviewer.md" `
    -Force
  ```
  Verify byte-for-byte equality with: `Get-FileHash -Algorithm SHA256` on both source and destination. Record hashes in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-copy-migration-coverage-reviewer.md`. Acceptance criterion: both hashes match.

- [x] [P1-T3] Copy `requirements-reconciler.md` from repo root to bundle. Execute:
  ```
  Copy-Item -Path "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\.claude\agents\requirements-reconciler.md" `
    -Destination "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\extensions\drm-copilot\resources\claude-customizations\.claude\agents\requirements-reconciler.md" `
    -Force
  ```
  Verify byte-for-byte equality with: `Get-FileHash -Algorithm SHA256` on both source and destination. Record hashes in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-copy-requirements-reconciler.md`. Acceptance criterion: both hashes match.

- [x] [P1-T4] Copy `runtime-characterization-analyst.md` from repo root to bundle. Execute:
  ```
  Copy-Item -Path "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\.claude\agents\runtime-characterization-analyst.md" `
    -Destination "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e\extensions\drm-copilot\resources\claude-customizations\.claude\agents\runtime-characterization-analyst.md" `
    -Force
  ```
  Verify byte-for-byte equality with: `Get-FileHash -Algorithm SHA256` on both source and destination. Record hashes in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/r3c1-copy-runtime-characterization-analyst.md`. Acceptance criterion: both hashes match.

---

### Phase 2 — Full Python Toolchain QA Loop

### Objective
Confirm that the push-down copy fixes the failing test and does not introduce any new failures or regressions.

- [x] [P2-T1] Run Black formatter on all modified files. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  poetry run black --check extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/migration-coverage-reviewer.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/requirements-reconciler.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/runtime-characterization-analyst.md
  ```
  Note: Black will exit 0 on `.md` files (no reformatting). Record exit code and output in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-qa-format-check.md`. Acceptance criterion: `EXIT_CODE: 0`.

- [x] [P2-T2] Run Ruff linter on all modified files. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  poetry run ruff check extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/migration-coverage-reviewer.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/requirements-reconciler.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/runtime-characterization-analyst.md
  ```
  Note: Ruff will exit 0 on `.md` files (no linting). Record exit code and output in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-qa-lint-check.md`. Acceptance criterion: `EXIT_CODE: 0`.

- [x] [P2-T3] Run Pyright type checker. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  poetry run pyright
  ```
  Record exit code and full output in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-qa-type-check.md`. Acceptance criterion: `EXIT_CODE: 0` and no new type errors introduced.

- [x] [P2-T4] Run the full Python test suite with coverage in the exact scope that contains the failing test. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v --cov=scripts/dev_tools --cov-branch --cov-report=term-missing
  ```
  Record exit code, full test output, and coverage summary in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-qa-test-suite.md`. Include coverage percentages for baseline. Acceptance criterion: `EXIT_CODE: 0`, the previously-failing test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` now PASSES, and no other test failures.

- [x] [P2-T5] Run full test suite with coverage across the entire Python codebase to detect any indirect regressions. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  poetry run pytest --cov --cov-branch --cov-report=term-missing
  ```
  Record exit code, full test output, and coverage summary in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-qa-full-suite.md`. Include coverage percentages (line and branch) for all modules and the aggregated total. Acceptance criterion: `EXIT_CODE: 0`, no regression vs. the cycle 2 audit baseline, and line coverage >= 85%, branch coverage >= 75%.

---

### Phase 3 — Commit and Push

### Objective
Record the fix in git and push to the feature branch.

- [x] [P3-T1] Stage the four newly-copied files in git. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  git add extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/migration-coverage-reviewer.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/requirements-reconciler.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/runtime-characterization-analyst.md
  ```
  Record exit code in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-git-stage.md`. Acceptance criterion: `EXIT_CODE: 0`.

- [x] [P3-T2] Create a commit with a descriptive message. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  git commit -m "fix(bundled-resources): push-down four missing agent personas to extension bundle

- Copy legacy-parity-analyst.md into bundled extension
- Copy migration-coverage-reviewer.md into bundled extension
- Copy requirements-reconciler.md into bundled extension
- Copy runtime-characterization-analyst.md into bundled extension

These files were added to the repo root by sibling feature #365 but
were not pushed down into the bundled extension payload at
extensions/drm-copilot/resources/claude-customizations/.claude/agents/.

The test test_bundled_claude_payload_contains_all_repo_runtime_contracts
requires the bundle to be a byte-identical mirror of the repo .claude/
tree (excluding .claude/agent-memory/** and .claude/settings.local.json).

This fix restores that invariant and allows the test to pass."
  ```
  Record exit code, commit hash, and log output in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-git-commit.md`. Acceptance criterion: `EXIT_CODE: 0` and commit hash is 40 hexadecimal characters.

- [x] [P3-T3] Push the feature branch to remote. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  git push origin feature/legacy-discovery-init-templates-362
  ```
  Record exit code and full output in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-git-push.md`. Acceptance criterion: `EXIT_CODE: 0` and output confirms branch was pushed.

- [x] [P3-T4] Verify the commit was pushed and is visible on GitHub. Execute:
  ```
  cd C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae68d14e27bb8727e
  git log -1 --oneline origin/feature/legacy-discovery-init-templates-362
  ```
  Record exit code and commit hash in `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r3c1-git-verify-push.md`. Acceptance criterion: `EXIT_CODE: 0` and commit hash from P3-T2 is listed.

---

## Acceptance Criteria Summary

1. **Phase 0:** Policy files read and baseline test failure confirmed; missing files enumerated.
2. **Phase 1:** Four files copied byte-for-byte; SHA256 hashes match on source and destination.
3. **Phase 2:** Full Python toolchain passes; previously-failing test now passes; no regressions; coverage >= 85% line, >= 75% branch.
4. **Phase 3:** Commit created, pushed, and verified on remote.

All evidence artifacts must be written to the canonical path `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/` with subdirectories `baseline/` and `qa-gates/` as applicable, using the `r3c1-` timestamp prefix for this remediation cycle 3, cycle 1.
