# Remediation Inputs: native-bash-toolchain-no-poetry (Issue #393)

- Author: feature-review agent (Claude Code)
- Date: 2026-07-21T19-39
- Cycle trigger: policy-audit Blocking finding (bash coverage measurement)
- Blocking finding count: 1
- Branch head at review: `145dae538d732a908d6e1e0e8eb3d5a053e8a7d5`
- Base / merge-base: `main` @ `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`

## Source Review Artifacts

- Policy audit: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/policy-audit.2026-07-21T19-39.md (Section 1.2, 1.2.1, 8, 10)
- Code review: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/code-review.2026-07-21T19-39.md (Blocking + Major rows of the Findings Table)
- Feature audit: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/feature-audit.2026-07-21T19-39.md (AC1-AC9 all PASS; blocker is outside the AC set)
- Executor evidence that pre-declared this outcome: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/coverage-delta.2026-07-21T18-45.md (bash verdict recorded as remediation-required until a CI numeric exists)

## Remediation-Required Findings

### REM-1 (Blocking): Bash line coverage for new production files is unmeasured (0.0% recorded)

- **Requirement:** uniform coverage gate (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`): new code files need >= 85% line coverage. `.claude/rules/shell.md` scopes bash to line coverage only (no bash branch gate).
- **Observed:** the authoritative CI coverage artifact for the branch head (run https://github.com/drmoisan/drm-copilot/actions/runs/29877012724, artifact `shell-coverage`) contains `kcov-merged/cov.xml` with `line-rate="0.000"`, `lines-valid="0"`, an empty `<classes>` list, and `kcov-merged/coverage.json` with `percent_covered: 0.00`. No per-file record exists for `scripts/bash/shell-qc.sh` or `scripts/bash/shell_qc_lib.sh`.
- **Baseline comparison:** the last green run on `main` (https://github.com/drmoisan/drm-copilot/actions/runs/29735688734, same artifact name) is byte-equivalent in structure and values (0.00). The defect is pre-existing in the kcov merge pipeline and was preserved intentionally by the parity requirement; this branch introduces no regression, but fail-closed policy prohibits a PASS coverage verdict without a numeric that meets the gate.
- **Root cause (localized by this review):**
  1. `kcov --merge "$out_dir" <run_dirs...>` writes its merged report to `$out_dir/kcov-merged/cov.xml`, not `$out_dir/cov.xml`; and
  2. the merged report aggregates zero line data from the `--cobertura-only` per-run directories (the per-run dirs retain only Cobertura output, which the kcov v43 merger does not re-aggregate into line records).
  The removed Python module (`scripts/dev_tools/shell_qc.py::run_test_with_options` at merge-base) had identical semantics.
- **Remediation direction (for atomic-planner; do not silent-fix in review):**
  - Change the coverage pipeline so a real merged line-coverage number is produced, e.g. drop `--cobertura-only` on per-run kcov invocations (keeping full kcov output enables a correct merge) and/or read `kcov-merged/cov.xml` as the merged report path.
  - Keep the byte-identical skip-marker and missing-tool contracts unchanged (`fix_all.py` dependency).
  - Update the bats coverage-path tests for any argv change (the argv-shape test asserts `--cobertura-only`).
  - Re-run `_shell-coverage.yml` via `workflow_dispatch` against the new head and record the numeric `Bash coverage (lines): NN.N%` plus per-file rates for the two new files in a refreshed `evidence/qa-gates/coverage-delta.<ts>.md`; the gate is >= 85% lines for the new files and no regression repo-wide.
  - If the measured value cannot reach the gate solely because kcov cannot attribute lines executed by stub-driven subprocesses, document the measured mechanism limits in the evidence and surface the decision to the orchestrator; do not mark PASS without a qualifying numeric.

### REM-2 (Major, same root cause — fold into the REM-1 task):

- `print_coverage_summary "$out_dir/cov.xml"` in `scripts/bash/shell_qc_lib.sh` (line 351) is a silent no-op on CI because the merged report is at `$out_dir/kcov-merged/cov.xml`; the advertised `Bash coverage (lines): NN.N%` line never prints in a real run (verified against the CI step log). Point the parser at the path kcov actually writes and assert the summary line in the CI-facing evidence.

## Non-Blocking Items (tracked, not remediation triggers for this cycle)

- Info: `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` named by the feature-review skill does not exist repo-wide (pre-existing; rule evaluated manually this cycle).
- Info: `quality-tiers.yml` absent at repo root despite being named the tier source of truth (pre-existing).
- Info: `issue.md` line 5 folder-name inconsistency; `#ISO-8601` spurious autoclose candidate in `artifacts/pr_context.summary.txt` (PR author must assert only `#393`).

## Green-Run Evidence Carried Forward (satisfies modified-workflow-needs-green-run for this cycle)

- docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/workflow-dispatch-green-runs.2026-07-21T23-35.md
- Independently verified: runs 29877012724 and 29877013754, both `conclusion: success`, `headSha: 145dae538d732a908d6e1e0e8eb3d5a053e8a7d5`.
- Note: the remediation will change `scripts/bash/shell_qc_lib.sh` and possibly `_shell-coverage.yml`; a fresh green run against the post-remediation head will be required to satisfy the rule again at re-audit.

## Handoff

Per `remediation-handoff-atomic-planner`, the orchestrator delegates plan authoring to `atomic-planner` using this file as the cycle's remediation inputs; the plan is preflighted and executed by `atomic-executor`, then re-audited by `feature-review`. Exit condition: blocking_count == 0 (REM-1 resolved with a qualifying numeric recorded in evidence, REM-2 fixed, fresh green run captured).
