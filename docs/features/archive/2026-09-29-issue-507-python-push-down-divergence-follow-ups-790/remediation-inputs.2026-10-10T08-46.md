# Remediation Inputs: Issue #790 (2026-10-10T08-46)

- Branch: `bug/issue-507-python-push-down-divergence-follow-ups-790` at `fed98c9000ba490784e4532521296ef971719ec7`
- Base: `7bbd0b9b990737642b4eeded01a27b7c5c8348b3` (`origin/main`)
- Review artifacts:
  - `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/policy-audit.2026-10-10T08-46.md` (verdict PASS)
  - `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/code-review.2026-10-10T08-46.md` (no blocking findings)
  - `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/feature-audit.2026-10-10T08-46.md` (REMEDIATION REQUIRED: FA-B1)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `fed98c900`)

## Remediation-Required Findings

### R1 (FA-B1): AC-22 targeted-command branch coverage for `push_down_claude_filesystem.py`

- Remediability: `autonomous`
- Rule: `spec.md` AC-22. The repository coverage policy is already met (95.58% line / 89.29% branch under the repository test suite); the AC binds verification to the Test Strategy pytest command, under which the module is 88.5% line / 64.29% branch (18 of 28 branches).
- Current evidence: `evidence/qa-gates/python-coverage-values.2026-10-10T08-25.md`, `evidence/qa-gates/python-coverage-delta.2026-10-10T08-29.md`, `artifacts/python/lcov.info` (BRF 28, BRH 18).
- Target: at least 21 of 28 branches under the Test Strategy command.
- Required change (tests only; no production change):
  1. Add direct `ExcludingFileSystem.list_files` tests, using the in-memory `RecordingFileSystem` and no temporary files, to `tests/scripts/dev_tools/test_push_down_claude_customizations.py`. If that file would exceed 500 lines, use `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` instead. Both files are already in the Test Strategy command. The tests cover:
     - `memory_mode="skip"`: a general-scoped `.claude/agent-memory/<agent>/x.md` source file is not listed (covers `push_down_claude_filesystem.py:406-407`).
     - `memory_mode="merge"` with `destination_root` set: a general-scoped memory whose destination file exists is not listed, and one whose destination file is absent is listed (covers lines 408-414).
     - `memory_mode="merge"` with `destination_root=None`: the general-scoped memory is listed (covers lines 409-410).
  2. Run the Python toolchain loop in order: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, the Test Strategy pytest command (add `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`, as in the executor run) with `--cov-report=json:artifacts/python/coverage-790-remediation.json`, and `poetry run pytest tests/scripts/dev_tools -k push_down`.
  3. Record results under `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/qa-gates/` with the line and branch values for all four modules.
  4. If `push_down_claude_filesystem.py` branch is at least 75% and line is at least 85% under that command, check off AC-22 in `spec.md`. Re-confirm AC-19 (line counts) for the edited test file and AC-24 (toolchain single pass), because both were evaluated on the pre-remediation tree.
- Alternative (not for the executor): a planning agent may amend the AC-22 verification command to include `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py`. Under that command the module measures 95.58% / 89.29% (reviewer cross-check). Executors and reviewers must not edit AC text.

## Not Remediation-Required

- FA-N1 through FA-N4 (feature audit) and the seven non-blocking code-review findings are optional and do not gate merge.
- CI has not run because no PR exists yet. No AC depends on CI; CI results apply to the PR gate, not to this remediation.
