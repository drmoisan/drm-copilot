# Pre-mortem: issue #962 change-scope gating

Timestamp: 2026-10-16T23-12
Branch head before execution: 4e82b3a3c (merge of origin/main 475bb06d5, which includes #953 sharded `_poshqc.yml`; #952 is not on main).
Author: orchestrator, per coordinator directive (stop the preflight loop, merge main, pre-mortem, single execution run).

Assumption for each item: the change has shipped and failed. Each entry states the failure, its mechanism, the design element that prevents it, and the check that proves it.

## 1. Skipped required checks

- Failure: a docs-only commit leaves a required context in "Expected - waiting for status" and the PR cannot merge.
- Mechanism: when a caller job in `ci.yml` is skipped, GitHub never creates the nested `<caller> / <callee job>` check names, so the required context never reports. A job-level skip inside a reusable workflow reports `skipped`, which branch protection accepts, but only if the caller job ran.
- Prevention: every caller of a required context carries `if: ${{ !cancelled() }}` and passes `run-heavy`; the gating is applied at step level inside required jobs (all 11 required contexts run and report `success`). Only non-required jobs (`poshqc-static`, `poshqc-shard`, `poshqc-linux-hooks`, `root-typescript-tests`, `npm-audit-gate`) skip at job level.
- Proof: Phase 7 P2.5/P2.6 (`gh api .../check-runs`, `gh pr checks --required`) on the docs-only head; all 11 required contexts must show `success`.

## 2. merge_group event (#952, not yet on main)

- Failure: a merge-queue run reads empty pull-request fields, decides `code=false`, and lands code without heavy checks.
- Mechanism: `github.event.pull_request.*` and `github.head_ref` are empty on `merge_group`.
- Prevention: F1 returns `EVENT_NOT_PULL_REQUEST` for every event other than `pull_request`, so `merge_group` and `push` always run in full; checkout and `HEAD_SHA` use `github.event.pull_request.head.sha || github.sha`. The `ci.yml` `on:` block is not edited, so #952's two-line `merge_group:` addition merges without textual conflict. Conditional adjustment A2 to `CiWorkflow.Tests.ps1` applies only once #952's event-field row is on HEAD; whichever item merges later resolves it.
- Residual risk: #952 merging after #962 must apply A2 (its row would otherwise fail on the five allowed event-field lines). Recorded for the coordinator.

## 3. #953 shard and aggregator jobs

- Failure: the `poshqc / PowerShell QC` aggregator fails under docs-only because its shards were skipped, or passes under a full run although a shard failed.
- Mechanism: the aggregator has `if: always()` and its first step requires static and shard success.
- Prevention: G6 (sharded shape) gates `poshqc-static`, `poshqc-shard`, and `poshqc-linux-hooks` at job level and every aggregator step at step level, so under docs-only the aggregator runs with all steps skipped and reports `success`; under a full run `inputs.run-heavy` is true and the gate step behaves exactly as before. A4/A4C adjust the result-gate helper in `PoshQcWorkflow.Tests.ps1` to accept only the exact run-heavy condition.
- Proof: W15-W17 suite rows; P1 full-run proof shows every shard job executed; P2 docs-only proof shows the aggregator `success` with skipped steps.

## 4. ci-gate tooling (`.claude/lib/ci-gate`)

- Failure: S9 or the parallel orchestrator treats a docs-only head as not green, or treats an empty check set as green.
- Mechanism: skipped jobs report `skipped`; `CI full run` reports `skipped` under docs-only.
- Prevention: research confirmed `Invoke-CiGateParser.ps1` buckets `skipped`/`neutral` as passing and refuses an empty set; no parser change is made (decision D4). #952's `Invoke-MergeConfirmationParser.ps1` reads merge/queue state, not check buckets.
- Proof: S9 on the docs-only head returns `conclusion: success`.

## 5. Ancestry

- Failure: a force-push or rebase makes the recorded green base unrelated to the head, and the diff since that base hides code changes.
- Prevention: F12 step 6 requires `git cat-file -e <base>^{commit}` and `git merge-base --is-ancestor <base> <head>`; exit 1 gives `BASE_NOT_ANCESTOR`, any other failure `ANCESTRY_CHECK_FAILED`, both `code=true`. Checkout uses `fetch-depth: 0` with `filter: blob:none`, so the base is present. The step ends with an explicit `exit 0` so a nested exit 1 does not leak (`.claude/rules/ci-workflows.md`).
- Proof: P10-P12, I13-I17 unit rows; Phase 7 P3 full run after a code change.

## 6. API failure modes

- Failure: a GitHub API error, rate limit, or payload change yields `code=false`.
- Prevention: every failure path is fail-closed: `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `NO_FULL_GREEN_RUN`, `DIFF_FAILED`, and the `catch` envelope `UNEXPECTED_ERROR` all give `code=true`. The decision step has `continue-on-error: true`; if it dies without writing an output, `needs.changes.outputs.code` is empty and every consumer compares `!= 'false'`, which runs in full. `code=false` can only be produced with a `DOCS_ONLY_SINCE_<base>` reason (F8 invariant). Fork PRs are excluded (`FORK_PULL_REQUEST`).
- Residual risk: the `changes` job itself failing to start (runner outage) leaves dependent jobs with `!cancelled()` running in full; acceptable.

## 7. Related follow-ups in the same files

- `_security-scan.yml`: `poetry export` is absent under Poetry 2 (main run 38948304976 logs "The requested command export does not exist."), so safety scanned zero packages. Fix installs `poetry-plugin-export`, uses `shell: bash` (pipefail), and removes `continue-on-error`. Risk: pre-existing advisories fail the required `security-scan` check. Decision rule (PD-18): if the first full PR run reports findings, record them and restore `continue-on-error` on the scan step only, for the coordinator.
- `_shell-coverage.yml` / `shell_qc_lib.sh`: recursive bats discovery and an 85% line threshold (main measured 95.2%). Risk: none expected; bats is verified in CI only (worktree guard denies local bats).
