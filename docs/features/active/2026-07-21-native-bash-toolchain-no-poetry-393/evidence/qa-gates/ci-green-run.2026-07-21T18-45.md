# Final QC — CI Green Run for Modified Workflows (P5-T9 / AC9) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: git push + observe GitHub Actions runs for ci.yml (calls _shell-coverage.yml) and
         _build-check.yml against the branch head
EXIT_CODE: NOT-EXECUTED (deferred; see note)

Status: DEFERRED — pre-merge gate, not satisfiable by the executor.

Note: Per the orchestrator's directive, the executor does not commit or push; staging, commit,
and push are performed by the orchestrator after execution. The green CI run against the branch
head (required by `modified-workflow-needs-green-run` because both `.github/workflows/
_shell-coverage.yml` and `_build-check.yml` were modified) must be produced and observed by the
orchestrator/CI. `workflow_dispatch` is available on both reusable workflows if a direct run is
needed.

Required observations to record here once the run completes (currently OUTSTANDING):
- ci.yml / _shell-coverage.yml run URL: <pending> — must be green; must upload `cov.xml` under
  `artifacts/pester/kcov/**` (upload-artifact `if-no-files-found: error`); must print
  `Bash coverage (lines): NN.N%`.
- _build-check.yml run URL: <pending> — must be green; must pass the native
  `bash scripts/bash/shell-qc.sh --help` smoke step.
- Observed `Bash coverage (lines): NN.N%`: <pending> (feeds P5-T4 and P5-T10 bash values).

Output Summary: AC9 green-run verification is a pre-merge gate deferred to the orchestrator/CI;
the workflows are migrated and locally reviewed (P4-T3). This artifact must be updated with the
green run URLs and the coverage summary line before merge.
