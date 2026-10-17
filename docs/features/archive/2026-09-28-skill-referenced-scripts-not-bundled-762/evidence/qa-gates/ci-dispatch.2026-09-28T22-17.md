# CI Dispatch Record (P10-T2, P10-T3)

## P10-T2 — final commit and FINAL_SHA

Timestamp: 2026-09-28T22-17
Command: git status --porcelain ; git add -- <FEATURE>/evidence <FEATURE>/plan.2026-09-28T23-50.md <Phase 7-9 loop-restart paths> ; git commit -m "docs(762): record final QA evidence" ; git status --porcelain ; git rev-parse HEAD
EXIT_CODE: 0
Output Summary:
- Commit created; `git status --porcelain` printed nothing after the commit.
- FINAL_SHA: 670577f2e94f1d6d50bcf390bc010090bdf73996
- Push: NOT performed by the executor. The orchestrator's binding instruction for this run is "do not push (the orchestrator pushes)", which overrides the plan's CMD-GIT-PUSH steps. `git ls-remote origin refs/heads/fix/skill-bundled-scripts` still reports 9bf3ad623a20ac7d824173954adf83b02a86603d.
- Paths committed beyond evidence and the plan (Phase 9 loop restarts): the six P9-T1 Python files (black reformat, E501 splits, pyright typing fix, docstring condensation for the 500-line limit) and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (re-baselined epic-skill digest; see python-test-coverage-total).

## P10-T3 — CI dispatch

Status before the push: no dispatch was issued, because a dispatch would have tested 9bf3ad62. The orchestrator then pushed FINAL_SHA (9bf3ad62..670577f2), and `git ls-remote` confirmed that origin/fix/skill-bundled-scripts is 670577f2e94f1d6d50bcf390bc010090bdf73996.

Timestamp: 2026-09-28T22-35
Command: gh workflow run ci.yml --ref fix/skill-bundled-scripts ; sh SCRATCH/ci-wait.sh 670577f2e94f1d6d50bcf390bc010090bdf73996 (background) ; gh run list --workflow ci.yml --commit 670577f2e94f1d6d50bcf390bc010090bdf73996 --json databaseId,event,status,conclusion,headSha
EXIT_CODE: 0
Output Summary:
- Dispatched run: 36513322997 (https://github.com/drmoisan/drm-copilot/actions/runs/36513322997).
- Exactly one run exists for FINAL_SHA: event `workflow_dispatch`, status `completed`, conclusion `failure`.
- P10-T3 acceptance (conclusion `success`): NOT MET. The task is left unchecked.
- Cause: the three `NPM Audit Gate` jobs failed (`npm audit (.)`, `npm audit (extensions/drm-copilot)`, `npm audit (packages/mcp-server)`). Each reports `1 moderate severity vulnerability` in the transitive dependency `ip-address`: GHSA-rpw4-54j3-4h4q (Address6.isLinkLocal) and GHSA-2vr4-cq9g-pvrc (NAT64 local-use range).
- The failure is unrelated to this change. `git diff --name-only 9bf3ad62 670577f2` lists no package.json, package-lock.json, or npm file, and the same audit jobs concluded `success` on the baseline main run 36494352285 earlier the same day. The advisories appear to have been published after that run.
- All other 13 jobs concluded `success`: quality-checks7 (3.10, 3.11, 3.12, 3.13), shell-coverage, poshqc, build-check, security-scan, docs-validation, both root-typescript-tests jobs, and both drm-copilot-extension-tests jobs.
- Remediation (outside this plan's scope): bump or override `ip-address` in the three npm workspaces, then re-dispatch CI. The orchestrator has to decide this.


## P10-T3 — re-dispatch after the orchestrator rebase (accepted)

Timestamp: 2026-09-28T22-55
Command: git fetch origin ; git rev-parse HEAD origin/fix/skill-bundled-scripts ; gh workflow run ci.yml --ref fix/skill-bundled-scripts ; sh SCRATCH/ci-wait.sh 7d8234ed778cb95488931f315dc1e65d65f556b5 (background) ; gh run list --workflow ci.yml --commit 7d8234ed778cb95488931f315dc1e65d65f556b5 --json databaseId,event,status,conclusion,headSha
EXIT_CODE: 0
Output Summary:
- Rebase (orchestrator action): origin/main already carried the ip-address fix 3310fda7 ("raise ip-address override to ^10.7.2 for npm audit gate"). The orchestrator rebased fix/skill-bundled-scripts onto origin/main 42e95e27 with no conflicts and force-pushed with lease. All branch commit SHAs were rewritten (for example, 670577f2 became f7603cd7 and 7d694cf1 became 7d8234ed).
- FINAL_SHA (superseding 670577f2e94f1d6d50bcf390bc010090bdf73996): 7d8234ed778cb95488931f315dc1e65d65f556b5. Local HEAD equals origin/fix/skill-bundled-scripts, and the working tree was clean before dispatch.
- Dispatched run: 36514443218 (https://github.com/drmoisan/drm-copilot/actions/runs/36514443218).
- Exactly one run exists for FINAL_SHA: event `workflow_dispatch`, status `completed`, conclusion `success`. P10-T3 acceptance MET.
- All 16 jobs concluded `success`, including the three `NPM Audit Gate` jobs that failed on run 36513322997.
- Re-verification on the rebased head (the P10-T4/T5/T6 results still hold):
  - `shell-coverage / Shell Coverage (Bats + kcov)`, `poshqc / PowerShell QC`, and `quality-checks7 / Code Quality & Tests (3.10, 3.11, 3.12, 3.13)` all concluded success.
  - The 3.12 log shows `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py .....` and `5340 passed, 6 skipped`.
  - `Bash coverage (lines): 93.3%`; COBERTURA-TOTAL line-rate=0.933; shell_qc_lib.sh 0.865.
  - The ten `.claude/skills/cleanup-merged-worktrees/scripts/` files have line-rates 0.976, 0.953, 1.000, 0.942, 0.924, 0.954, 0.870, 0.906, 0.890, 0.875, identical to run 36513322997 and to the P0-T19 baseline. No MISSING line.
