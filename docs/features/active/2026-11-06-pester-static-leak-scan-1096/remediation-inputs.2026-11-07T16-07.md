# Remediation Inputs: Cycle 1 (Issue #1096)

Remediation-Mode: proportionate
Review-Verdict: REMEDIATION_REQUIRED

- Timestamp: 2026-11-07T16-07
- Branch: feature/pester-static-leak-scan-1096
- Opened by: a merge conflict with `origin/main`, found before pull-request creation. The feature review `review-status: AWAITING_CI` (`remediation-inputs.2026-11-07T16-00.md`) opened no cycle.
- Prior review artifacts: `policy-audit.2026-11-07T16-00.md`, `code-review.2026-11-07T16-00.md`, `feature-audit.2026-11-07T16-00.md`.

## Remediation-required findings

### MC-1 - Branch conflicts with origin/main

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: a trial merge of `origin/main` into the branch (`git merge-tree --write-tree`) reports content conflicts in `scripts/dev_tools/atomic_executor/cli_preflight.py`, `scripts/dev_tools/atomic_executor/prompt_builder.py`, `scripts/dev_tools/atomic_executor/qc_runner.py`, and `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`. Every conflicted path is already in the branch diff.
- Context: `origin/main` gained PR #1108 (issue #1106), which removed the stale lexile coverage path from the executor commands ("target scripts/dev_tools instead of a missing package"), added preflight and prompt-builder tests to `test_cli_part3.py` and `test_prompt_builder.py`, and changed `test_qc_runner.py`. It also changed the `orchestrate` skill and other customization surfaces for issue #1097, and auto-merged into `.vscode/tasks.json`, `qc_toolchain.py`, `fix_all_branches_extra.py`, and `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`.
- Required change: merge `origin/main` into the branch with a merge commit, resolving each conflict so that both sides' intent survives: this branch's `-n auto` on full-suite commands and main's coverage-path correction. Then re-establish the branch's own guarantees against the merged tree:
  - entry 0001's `Current` fences still occur exactly once in their targets, and its `## Files Changed` and Revert Blocks describe the merged text (spec AC-26 and AC-28);
  - P4-T3 coverage cases that duplicate tests main added are removed or merged, so no two tests assert the same behavior;
  - the per-file coverage and no-new-failure comparisons of spec AC-34 and AC-35 still hold.

## Related non-blocking findings, fixed in this cycle

These come from the feature review's non-blocking list. They are related to the branch and are fixed here instead of being filed.

### NB-1 - `test_qc_runner.py` above the 700-line advisory tier

- Severity: Warning (advisory)
- Remediability: autonomous
- Source: `code-review.2026-11-07T16-00.md`, non-blocking items: `test_qc_runner.py` is 711 logical lines.
- Required change: bring the file to or below 700 logical lines after the merge, splitting by a logical seam into a new test file under `tests/scripts/dev_tools/atomic_executor/` if needed. A new test file is permitted for this split. No test is dropped.

### NB-2 - `QCRunner.FULL_TEST` keeps `--cov-report` flags with no `--cov` source

- Severity: Minor
- Remediability: autonomous
- Source: `code-review.2026-11-07T16-00.md`, non-blocking items.
- Required change: after the merge, make `FULL_TEST` either name a coverage source consistent with main's correction or carry no `--cov-report` flags, and update `test_run_full_runs_all_tools_on_entire_codebase`.

### NB-3 - A file read failure is labelled `parse-error`

- Severity: Minor
- Remediability: autonomous
- Source: `code-review.2026-11-07T16-00.md`, non-blocking items: `Invoke-PoshQCLeakScan` labels a file read failure as `parse-error`.
- Required change: report a read failure with its own label, distinct from a parse error, in `Invoke-PoshQCLeakScan`, with a test through the injected read seam. Update the README and spec `## API / CLI Surface` text if they name the labels. Copy the PoshQC file to its bundle mirror.

## Constraints

- Tests are parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix.
- No `.py` production file is added. No edit to `.claude/rules/`, `.github/instructions/`, any `atomic-plan-contract` copy, or an Epic #1019 folder.
- `poshqc / PowerShell hook suites (Linux)` stays unchanged.

## Do not do

- Do not rebase or force-push; merge `origin/main` with a merge commit.
- Do not re-open settled spec decisions.
