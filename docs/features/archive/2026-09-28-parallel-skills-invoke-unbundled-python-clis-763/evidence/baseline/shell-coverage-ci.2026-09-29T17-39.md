# Bash CI Coverage Baseline (P0-T21)

Timestamp: 2026-09-29T17-39
Command: git rev-parse HEAD ; gh workflow run _shell-coverage.yml --ref bug/parallel-skills-invoke-unbundled-python-clis-exec-763 ; gh run list --workflow _shell-coverage.yml --branch bug/parallel-skills-invoke-unbundled-python-clis-exec-763 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion ; sh SCRATCH/ci-wait.sh 36636142693 ; sh SCRATCH/ci-shell-log.sh 36636142693
EXIT_CODE: 0
Output Summary:
- HEAD: `b9fc15943865a0652a9edf05153b65c002fe2566` (equals the pushed branch tip)
- Dispatch: exit 0, run URL `https://github.com/drmoisan/drm-copilot/actions/runs/36636142693`
- Latest dispatched run: databaseId `36636142693`, headSha `b9fc15943865a0652a9edf05153b65c002fe2566` (equals HEAD)
- CI-WAIT: exit 0; `{"conclusion":"success","event":"workflow_dispatch","headSha":"b9fc15943865a0652a9edf05153b65c002fe2566","id":36636142693,"jobs":[{"conclusion":"success","name":"Shell Coverage (Bats + kcov)"}],"status":"completed"}`
- CI-LOG headline (exactly one line): `Bash coverage (lines): 93.3%`
- `NOT-OK-COUNT=0`
- `OK-COUNT=478`

Run id: 36636142693
Baseline bash coverage headline: 93.3
Branch: bug/parallel-skills-invoke-unbundled-python-clis-exec-763 (execution substitution 1)
