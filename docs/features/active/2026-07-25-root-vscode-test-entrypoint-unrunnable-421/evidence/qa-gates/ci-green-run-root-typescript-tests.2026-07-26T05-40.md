# QA Gate — CI Green Run of the Root TypeScript Tests Workflow (#421)

Timestamp: 2026-07-26T05-40

Task: [P5-T4] — AC4 (CI half), AC6, and `modified-workflow-needs-green-run` evidence for the workflow diff.

Command:

```
gh workflow run ci.yml --ref bug/vscode-test-integration-entrypoint
gh run list --workflow=ci.yml --branch bug/vscode-test-integration-entrypoint --limit 5
gh run watch 30189336124 --exit-status --interval 20
gh run view 30189336124 --json status,conclusion,url,headSha
gh run view 30189336124 --json jobs --jq '.jobs[] | "\(.conclusion)\t\(.name)"'
gh run view --job 89759541798 --log
gh run view --job 89759541831 --log
```

EXIT_CODE: 0

## Run Identification

| Field | Value |
|---|---|
| Run URL | https://github.com/drmoisan/drm-copilot/actions/runs/30189336124 |
| Workflow | `ci.yml` (CI) |
| Trigger | `workflow_dispatch` |
| Ref | `bug/vscode-test-integration-entrypoint` |
| Head SHA | `df874e81fc9e741921376e621e171cfb2d2a31e2` |
| Status | `completed` |
| Overall conclusion | **`success`** |

The head SHA `df874e81fc9e741921376e621e171cfb2d2a31e2` is identical to the pushed local HEAD verified in [P5-T2] (`git rev-parse HEAD origin/bug/vscode-test-integration-entrypoint` returned the same SHA twice), so this run exercised the branch head.

Dispatch rationale: `ci.yml` was dispatched rather than `_root-typescript-tests.yml` because GitHub's `workflow_dispatch` resolves only workflow files present on the default branch, and the new callable workflow has not yet landed on `main`. A dispatched run executes the workflow files from the supplied `--ref`, so this run used the branch's `ci.yml` and reached the new callee through its `uses: ./.github/workflows/_root-typescript-tests.yml` reference. `ci.yml`'s `push` trigger covers only `[main, development]`, so the explicit dispatch was required.

## Per-OS Job Conclusions for the New Workflow

| Job | OS | Job ID | Conclusion | Duration |
|---|---|---|---|---|
| `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` | ubuntu-latest | 89759541798 | **`success`** | 05:24:38Z – 05:25:06Z (28s) |
| `root-typescript-tests / Root TypeScript Tests (windows-latest)` | windows-latest | 89759541831 | **`success`** | 05:24:37Z – 05:25:43Z (66s) |

Both matrix legs concluded `success`, satisfying the [P5-T3] acceptance condition.

## Log Excerpt — ubuntu-latest (job 89759541798)

```
2026-07-26T05:24:50.6876751Z ##[group]Run npm test
2026-07-26T05:24:50.6877107Z npm test
2026-07-26T05:24:50.7849699Z > drm-copilot@1.0.0 pretest
2026-07-26T05:24:50.8787423Z > drm-copilot@1.0.0 compile
2026-07-26T05:24:51.8752567Z > drm-copilot@1.0.0 lint
2026-07-26T05:24:52.7326178Z > drm-copilot@1.0.0 test
...
2026-07-26T05:25:04.6677289Z PASS tests/unit/vscode-test-removal.test.ts
2026-07-26T05:25:05.1273445Z PASS tests/unit/hello-typescript.test.ts
2026-07-26T05:25:05.1743914Z Test Suites: 170 passed, 170 total
2026-07-26T05:25:05.1744577Z Tests:       2038 passed, 2038 total
2026-07-26T05:25:05.1745082Z Snapshots:   0 total
2026-07-26T05:25:05.1745668Z Time:        11.971 s
2026-07-26T05:25:05.1746115Z Ran all test suites.
```

## Log Excerpt — windows-latest (job 89759541831)

```
2026-07-26T05:25:14.6697833Z > drm-copilot@1.0.0 pretest
2026-07-26T05:25:15.0030794Z > drm-copilot@1.0.0 compile
2026-07-26T05:25:16.7415312Z > drm-copilot@1.0.0 lint
2026-07-26T05:25:18.2719628Z > drm-copilot@1.0.0 test
...
2026-07-26T05:25:36.9478668Z PASS tests/unit/vscode-test-removal.test.ts
2026-07-26T05:25:37.6717997Z PASS tests/unit/hello-typescript.test.ts
2026-07-26T05:25:37.7621583Z Test Suites: 170 passed, 170 total
2026-07-26T05:25:37.7622146Z Tests:       2038 passed, 2038 total
2026-07-26T05:25:37.7622587Z Snapshots:   0 total
2026-07-26T05:25:37.7622931Z Time:        18.425 s
2026-07-26T05:25:37.7623271Z Ran all test suites.
```

## Guard-Suite Evidence (AC4, CI half)

The [P5-T4] task text permitted substituting the `Test Suites: N passed` summary if per-suite `PASS` lines were unavailable. **No substitution was needed.** Both job logs contain the explicit per-suite line:

```
PASS tests/unit/vscode-test-removal.test.ts
```

The guard test is listed as an executed, passing suite on both `ubuntu-latest` and `windows-latest`. Combined with the local evidence in [P2-T2] and [P4-T5], AC4 is satisfied on both its local and CI halves.

## Root `npm test` Defined, Passing State (AC6)

The logs confirm the repaired entry point behaves as specified:

1. `npm test` triggers `pretest`, which runs `compile` then `lint` — and notably **not** `compile:integration-tests`, confirming the [P1-T4] trim is in effect on the runner.
2. `npm test` then runs `node run-jest.cjs`, which executes the full root jest suite: **170 suites passed / 170 total, 2038 tests passed / 2038 total**, `Ran all test suites.`
3. The step exits 0 and the job concludes `success`.

This is the authoritative verification of a passing root `npm test`, per the spec's Test Strategy verification constraint. The runner checkout path contains no dot-directory component, so the pre-existing #414 Condition 3 jest `<rootDir>` glob-escape artifact does not reproduce — confirmed by the run finding and executing all 170 suites, versus the `No tests found, exiting with code 1` observed for plain `npm test` in the local `.claude`-containing worktree.

Local-versus-CI suite parity: the CI run reports the same 170 suites / 2038 tests as the local path-independent invocation in [P4-T5], confirming the local `--testMatch` workaround selects exactly the suite set the committed `jest.config.cjs` intends.

## Policy Evidence: `modified-workflow-needs-green-run`

This change set modifies `.github/workflows/ci.yml` and adds `.github/workflows/_root-typescript-tests.yml`. Run 30189336124 is a green run of `ci.yml` against the branch head SHA `df874e81fc9e741921376e621e171cfb2d2a31e2`, which exercises both the modified orchestrator and the new callee on the runner. This satisfies the feature-review policy rule `modified-workflow-needs-green-run` for the workflow diff.

Per `.claude/rules/ci-workflows.md`: the new workflow contains no `pwsh` step and no deliberately-failing nested command, so the `$LASTEXITCODE` reset pattern is not triggered. All steps use default failure propagation, and the green run confirms correct exit-code behavior on both runner classes.

Output Summary: `gh workflow run ci.yml --ref bug/vscode-test-integration-entrypoint` produced run **30189336124** (https://github.com/drmoisan/drm-copilot/actions/runs/30189336124) against head SHA **`df874e81fc9e741921376e621e171cfb2d2a31e2`**, which concluded **`success`**. Both new jobs concluded `success`: `Root TypeScript Tests (ubuntu-latest)` and `Root TypeScript Tests (windows-latest)`. Both logs show root `npm test` running `pretest` (compile + lint, with `compile:integration-tests` correctly absent) and then the jest suite, reporting **170 suites passed / 170 total and 2038 tests passed / 2038 total**, with the explicit per-suite line `PASS tests/unit/vscode-test-removal.test.ts` on both operating systems. AC4 (CI half), AC6, and `modified-workflow-needs-green-run` evidence established.
