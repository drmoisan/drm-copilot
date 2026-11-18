# CI Gate (S9) - Issue #1028

Timestamp: 2026-11-18T07-07
Command: gh run view 44252301324 --json status,conclusion,headSha; gh api repos/drmoisan/drm-copilot/actions/runs/44252301324/jobs
EXIT_CODE: 0
Output Summary:
- Workflow CI, run 44252301324, event pull_request, PR #1203 into epic/shared-agent-harness-layer-integration.
- Head SHA 3e207ad8998c0f1666bd5fa716562c78a9e601a1 (merge of origin/epic/shared-agent-harness-layer-integration at 781bc4c33, which carries the npm audit exception from issue #1204 / PR #1205).
- Run conclusion: success. 29 of 29 jobs success, including CI Required Gate, CI full run, poshqc / PowerShell QC (static, shards 1-6, aggregator), poshqc / PowerShell hook suites (Linux), quality-checks7 (3.11, 3.12, 3.13, 3.13 static, coverage shards 1-2), root-typescript-tests (ubuntu, windows), drm-copilot-extension-tests (ubuntu, windows), shell-coverage, security-scan, build-check, docs-validation, and NPM Audit Gate (., extensions/drm-copilot, packages/mcp-server).
- This run is the CI stage of the toolchain loop (stage 7, integration, runs in CI) for the final head; the local stages 1-6 are recorded in final-gates.2026-11-18T02-20.md.
- Prior S9 failure (run 44225709935, NPM Audit Gate on GHSA-fc5q-39xc-vjpf) is superseded by this run.
