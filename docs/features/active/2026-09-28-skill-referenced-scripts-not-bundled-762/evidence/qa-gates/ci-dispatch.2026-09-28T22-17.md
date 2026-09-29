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

