# Population Source Line (P6-T12) — partial: run C pending

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P6-RUNS (replaces `Select-String -SimpleMatch -Pattern 'Code coverage population: source=config; files='` on `artifacts/pester/final-run-a.log` and `final-run-c.log`). Grep tool, fixed pattern `Code coverage population: source=config; files=`, over the run A job log `artifacts/ci/run-36983551836/job.log` (https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194) and the run B job log `artifacts/ci/run-36984586891/job.log` (https://github.com/drmoisan/drm-copilot/actions/runs/36984586891/job/110766595828). Run C log does not exist (operator-run blocker).
EXIT_CODE: 0
Output Summary: run A: exactly 1 matching line (job log line 837: `Code coverage population: source=config; files=174`). Run B: exactly 1 matching line (line 829, identical text). Run C: pending. P6-T12 stays unchecked because the run C leg of its acceptance cannot be evaluated.
- The CI job log is the equivalent of the FR run log: the CI step calls `Invoke-PoshQCTest` with a logger that writes to the job output.
- Other population lines in both logs are `source=settings; files=1` lines emitted by unit tests that call `Invoke-PoshQCTest` with injected caller-supplied settings; they do not match the `source=config` pattern.
- Acceptance (AC-05, AC-10): each of the A and C logs has exactly one matching line. A: met. C: pending. B (additional): met.
