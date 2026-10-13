# CI kcov per-file coverage comparison

Timestamp: 2026-10-12T13-16
Command: Orchestrator-supplied source, no local command run (Option A). CI run https://github.com/drmoisan/drm-copilot/actions/runs/38281234678, artifact shell-coverage, file cov.xml, class element name="compute_concurrency_batches_sh__41" filename=".claude/lib/bash/compute-concurrency-batches.sh" (cov.xml line 1447; same element in kcov-merged/cov.xml).
EXIT_CODE: 0
Output Summary: Baseline line coverage 81.82% (P0-T11, kcov CI run 38057811190). Post-change per-file line coverage 100.00% (line-rate 1.000 x 100; branch-rate 1.0). Delta +18.18 percentage points. Threshold: line-rate 1.000 is at least 0.85 and the ci-bats-test-step artifact has EXIT_CODE 0. Changed-code coverage equals the per-file figure because only a test file changed and the production file is unchanged. The job-log aggregate (Bash coverage (lines)) was not used.
