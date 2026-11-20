# CI Verification — `NPM Audit Gate` on the Branch Head (#414, [P6-T3])

Timestamp: 2026-07-25T22-22

Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/30176168742>
Run head SHA: `478f40b83be80d660e6443fa7756e9729f9f9b36`
Run conclusion: `success`

## Why an Explicit Dispatch Was Required

Neither audit-gate entry point fires on a feature-branch push. `.github/workflows/npm-audit-gate.yml` triggers on `schedule`, `workflow_dispatch`, and `pull_request` restricted to `main`/`development`; `.github/workflows/ci.yml` (the only other caller of the reusable `_npm-audit-gate.yml`) restricts both `push` and `pull_request` to `main`/`development`. This plan opens no pull request, so the run had to be dispatched explicitly.

## Command 1 — dispatch

Command: `gh workflow run npm-audit-gate.yml --ref bug/npm-audit-brace-expansion` (working directory: repository root)
EXIT_CODE: 0

```text
https://github.com/drmoisan/drm-copilot/actions/runs/30176168742
```

## Command 2 — identify the run

Command: `gh run list --workflow npm-audit-gate.yml --branch bug/npm-audit-brace-expansion --limit 5` (working directory: repository root)
EXIT_CODE: 0

```text
in_progress		npm Audit Gate	npm Audit Gate	bug/npm-audit-brace-expansion	workflow_dispatch	30176168742	8s	2026-07-25T21:42:54Z
```

## Command 3 — wait for completion

Command: `gh run watch 30176168742 --exit-status --interval 15` (working directory: repository root)
EXIT_CODE: 0

The run completed with all three matrix legs green. Each leg executed the same two substantive steps: `Install from lockfile (verifies lockfile/manifest sync)` and `Audit dependencies`.

```text
✓ bug/npm-audit-brace-expansion npm Audit Gate · 30176168742
Triggered via workflow_dispatch less than a minute ago

JOBS
✓ npm-audit / npm audit (.) in 21s (ID 89725187213)
  ✓ Install from lockfile (verifies lockfile/manifest sync)
  ✓ Audit dependencies
✓ npm-audit / npm audit (packages/mcp-server) in 18s (ID 89725187216)
  ✓ Install from lockfile (verifies lockfile/manifest sync)
  ✓ Audit dependencies
✓ npm-audit / npm audit (extensions/drm-copilot) in 21s (ID 89725187230)
  ✓ Install from lockfile (verifies lockfile/manifest sync)
  ✓ Audit dependencies
```

(Setup and teardown steps elided; every step in every job reported success.)

## Command 4 — per-job conclusions

Command: `gh run view 30176168742 --json headSha,url,status,conclusion,jobs --jq '{headSha,url,status,conclusion,jobs:[.jobs[]|{name,conclusion,databaseId}]}'` (working directory: repository root)
EXIT_CODE: 0

```json
{"conclusion":"success","headSha":"478f40b83be80d660e6443fa7756e9729f9f9b36","jobs":[{"conclusion":"success","databaseId":89725187213,"name":"npm-audit / npm audit (.)"},{"conclusion":"success","databaseId":89725187216,"name":"npm-audit / npm audit (packages/mcp-server)"},{"conclusion":"success","databaseId":89725187230,"name":"npm-audit / npm audit (extensions/drm-copilot)"}],"status":"completed","url":"https://github.com/drmoisan/drm-copilot/actions/runs/30176168742"}
```

## Per-Leg Results

| Matrix leg (job name) | Job ID | Conclusion | Duration |
|---|---|---|---|
| `npm-audit / npm audit (.)` | 89725187213 | `success` | 21s |
| `npm-audit / npm audit (extensions/drm-copilot)` | 89725187230 | `success` | 21s |
| `npm-audit / npm audit (packages/mcp-server)` | 89725187216 | `success` | 18s |

Job names carry the `npm-audit / ` prefix because the gate is invoked through the reusable-workflow caller. On a pull request, `ci.yml` reports the same legs as `NPM Audit Gate / npm audit (<manifest>)`.

## Head-SHA Match

| | SHA |
|---|---|
| Pushed head recorded in [P6-T1] | `478f40b83be80d660e6443fa7756e9729f9f9b36` |
| Run `headSha` | `478f40b83be80d660e6443fa7756e9729f9f9b36` |

Match confirmed. The run exercised the committed override and lockfile change, not an earlier tree.

## Independent Confirmation of the Local Result

Each leg's `Install from lockfile` step runs `npm ci`, which fails on manifest/lockfile drift, and its `Audit dependencies` step runs the audit at `--audit-level=moderate`. All three passing on a Node 20 `ubuntu-latest` runner independently confirms the local per-root audit results ([P1-T3], [P2-T3], [P3-T4]) on a different OS and Node major version, and confirms both regenerated lockfiles install cleanly on CI.

Output Summary: PASS. The `NPM Audit Gate` workflow was dispatched explicitly against `bug/npm-audit-brace-expansion` (run 30176168742, <https://github.com/drmoisan/drm-copilot/actions/runs/30176168742>) and completed with conclusion `success`. All three matrix legs concluded `success`: `npm audit (.)` (job 89725187213, 21s), `npm audit (extensions/drm-copilot)` (job 89725187230, 21s), and `npm audit (packages/mcp-server)` (job 89725187216, 18s). The run's `headSha` is `478f40b83be80d660e6443fa7756e9729f9f9b36`, matching the head pushed in [P6-T1]. This satisfies the `spec.md` acceptance criterion "All three `NPM Audit Gate` jobs succeed on the branch head SHA, verified via `gh run view <id> --json jobs`". This dispatched run is early evidence; the orchestrator additionally verifies the gate on the pull-request head at its S9 CI gate.
