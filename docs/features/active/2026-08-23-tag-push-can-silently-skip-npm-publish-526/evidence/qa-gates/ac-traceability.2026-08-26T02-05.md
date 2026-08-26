# Acceptance-Criteria Traceability Matrix — P7-T11

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

AC source: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`,
section "Acceptance Criteria" (AC1 through AC28). Work Mode is `full-bug`, so `spec.md` is the sole
acceptance-criteria source and no `user-story.md` exists.

Every row names a concrete Pester test name, a concrete command result, or a concrete artifact path.
No row is left unmapped.

Suite state at the time of this matrix: 3638 passed, 0 failed, 9 skipped, recorded in
`evidence/qa-gates/final-pester.2026-08-26T02-05.md`. Every named test below is therefore a passing
test.

## Matrix — 28 rows

| AC | Satisfied by | Kind | Status |
|---|---|---|---|
| AC1 | Test `dot-sources the module and resolves all three mocked seams` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | Pester test | SATISFIED |
| AC2 | Test `passes the package operand in exact-version form to the npm seam` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | Pester test | SATISFIED |
| AC3 | Test `reports failure when the exact version is absent while the latest dist-tag resolves` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | Pester test | SATISFIED |
| AC4 | Test `pushes the mcp-server tag before the extension tag` in `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`; fail-before evidence at `evidence/regression-testing/fail-before-push-order.2026-08-25T23-46.md`, pass-after at `evidence/regression-testing/pass-after-tag-push.2026-08-26T01-32.md` | Pester test + artifact | SATISFIED |
| AC5 | Test `performs zero extension tag operations when the mcp verification does not resolve` in `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | Pester test | SATISFIED |
| AC6 | Six tests in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`: `returns RESOLVED on a fully successful verification`, `returns NO_RUN when the run-existence budget is exhausted`, `returns RUN_FAILED when the run conclusion is failure`, `returns STEP_SKIPPED when the publish step concluded skipped`, `returns STEP_MISSING when the named step is absent from the payload`, `returns UNRESOLVED when the registry budget is exhausted after the publish step succeeded` | Pester tests | SATISFIED |
| AC7 | Test `treats a missing publish step as a non-zero failure rather than absence of evidence` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | Pester test | SATISFIED |
| AC8 | Test `emits pairwise distinct recovery instructions for NO_RUN, STEP_SKIPPED, and UNRESOLVED` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | Pester test | SATISFIED |
| AC9 | Nine tests in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, three per check: `check (a) finds the run on the first attempt without sleeping`, `check (a) finds the run on a later attempt and sleeps once per prior attempt`, `check (a) returns NO_RUN when its attempt budget is exhausted`, `check (b) reads a completed run on the first attempt without sleeping`, `check (b) reads a completed run on a later attempt and sleeps once per prior attempt`, `check (b) returns RUN_FAILED when its attempt budget is exhausted`, `check (c) resolves the version on the first attempt without sleeping`, `check (c) resolves the version on a later attempt and sleeps once per prior attempt`, `check (c) returns UNRESOLVED when its attempt budget is exhausted` | Pester tests | SATISFIED |
| AC10 | Test `distinguishes an exhausted run-existence budget from a negative publish-step result` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | Pester test | SATISFIED |
| AC11 | Test `aborts with VERSION_CONSUMED_ELSEWHERE and pushes nothing when the target version already resolves` in `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | Pester test | SATISFIED |
| AC12 | Tests `reads the pinned mcp version from in-memory config content and passes it to the registry check` and `fails when the pinned version does not resolve on the registry` in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, plus `requires the Codex-pinned version itself to resolve after the mcp verification succeeds` in `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | Pester tests | SATISFIED |
| AC13 | Test `declares a pull_request trigger scoped to the mcp-server package and the workflow file` in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; fail-before evidence at `evidence/regression-testing/fail-before-workflow-invariants.2026-08-25T23-46.md` | Pester test + artifact | SATISFIED |
| AC14 | Test `guards the publish step on the tag ref and not on the event name` in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; fail-before evidence at `evidence/regression-testing/fail-before-workflow-invariants.2026-08-25T23-46.md` | Pester test + artifact | SATISFIED |
| AC15 | Test `asserts tag and manifest version equality in a ref-guarded step ordered before the publish step` in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | Pester test | SATISFIED |
| AC16 | Tests `polls the exact published version after publishing and fails the job on budget expiry` and `ref-guards the post-publish registry poll step` in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | Pester tests | SATISFIED |
| AC17 | Test `resets or explicitly exits after every deliberately-failing nested command in an added pwsh step` in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, and test `resets or explicitly exits after every deliberately-failing nested command in a pwsh step` in `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` | Pester tests | SATISFIED |
| **AC18** | **DEFERRED.** Artifact: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md`. Deferral owner: **`pr-author`**. Both per-workflow sections of that artifact record the literal `DEFERRED` for `Run URL:` and `Run Conclusion:`, because no task in this plan pushes a branch or opens a pull request and both operations are prohibited to the executor, so the branch-head run cannot exist during this execution. No satisfying test or command result is claimed. | Deferral record | **DEFERRED — not satisfied** |
| AC19 | Production file `.github/workflows/verify-published-releases.yml`; pure-function tests in `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1`: `returns an empty result when every tag version is published`, `returns the single unpublished version when one tag version is missing from the registry set`, `returns an empty result for an empty tag set`; workflow-existence test `declares a schedule trigger` in `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` | Pester tests + file | SATISFIED |
| AC20 | Absence confirmed by search: `grep -nE "Should -Be 5\|Times 5\|-Exactly 5" tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` returned exit code 1 (zero matches), and the file's ordering assertion is now `pushes the mcp-server tag before the extension tag`. The whole file passes under the repository Pester runner per `evidence/regression-testing/pass-after-tag-push.2026-08-26T01-32.md` | Command result + artifact | SATISFIED |
| AC21 | `evidence/qa-gates/final-pester.2026-08-26T02-05.md` (0 failed of 3647) and `evidence/qa-gates/test-purity.2026-08-26T02-05.md` (per-file clean verdicts for all five test files) | Artifacts | SATISFIED |
| AC22 | `evidence/qa-gates/test-purity.2026-08-26T02-05.md` — zero matches for `New-TemporaryFile`, `GetTempFileName`, TEMP, `TestDrive`, and `Start-Sleep` across all five test files | Artifact | SATISFIED |
| AC23 | `evidence/qa-gates/final-file-size-check.2026-08-26T02-05.md` — eight line counts recorded (499, 278, 166, 346, 491, 89, 150, 106), every one at most 500 | Artifact | SATISFIED |
| AC24 | `evidence/qa-gates/coverage-delta.2026-08-26T02-05.md` (per-file 90.2174 percent and 97.4026 percent, both >= 85) and `evidence/qa-gates/coverage-denominator.2026-08-26T02-05.md` (both new files registered in `CodeCoverage.Path` and present as measured rows; no exclusion list contains either) | Artifacts | SATISFIED |
| AC25 | `evidence/qa-gates/final-actionlint.2026-08-26T02-05.md` — `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1` returned `EXIT_CODE: 0` with both in-scope workflow files named | Command result + artifact | SATISFIED |
| AC26 | `evidence/qa-gates/toolchain-loop.2026-08-26T02-05.md` — format, analyze, test consecutive, all exit code 0, 0 files changed, 0 analyzer errors, 0 loop restarts | Artifact | SATISFIED |
| AC27 | `docs/engineering/missed-npm-publish.runbook.md`, verified by `evidence/qa-gates/runbook-state-coverage.2026-08-26T02-05.md`, which enumerates nine located single-line literals with line numbers | Artifact | SATISFIED |
| AC28 | `evidence/qa-gates/scope-boundary.2026-08-26T02-05.md` — 49-path union from `git status --porcelain` and `git diff --name-only main...HEAD`; zero matches for `README` and zero for `quality-tiers` | Artifact | SATISFIED |

Row count: **28**. Unmapped rows: **0**.

## AC18 row — conditional branch taken

The plan makes the AC18 row conditional. The condition evaluated as follows.

The P7-T12 artifact
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md`
records the literal `DEFERRED` in **both** per-workflow sections. The two read-only listing
invocations that established this were:

```
gh run list --workflow=publish-mcp-npm.yml --limit 5 --json databaseId,headBranch,conclusion,url
gh run list --workflow=verify-published-releases.yml --limit 5 --json databaseId,headBranch,conclusion,url
```

The first returned exit code 0 and five runs, every one against an `mcp-server-v*` tag ref
(`mcp-server-v1.1.3`, `mcp-server-v1.1.2`, `mcp-server-v1.1.1`, `mcp-server-v1.1.0`,
`mcp-server-v1.0.27`). None has a `headBranch` of
`bug/tag-push-can-silently-skip-npm-publish-526`, so no branch-head run exists for that workflow.

The second returned exit code 1 with `HTTP 404: workflow verify-published-releases.yml not found on
the default branch`, which is the expected result for a workflow file that has not yet merged to the
default branch.

The deferred branch is therefore the one taken: the AC18 row above records the criterion as
deferred, names the artifact path, and names `pr-author` as the deferral owner, rather than claiming
a satisfying test or command result. The AC18 checkbox in `spec.md` remains unchecked.

## Summary

| Disposition | Count | ACs |
|---|---|---|
| Satisfied and checked off in `spec.md` | 27 | AC1 through AC17, AC19 through AC28 |
| Deferred, checkbox left unchecked | 1 | AC18 (owner `pr-author`) |
| Unmapped | 0 | — |

Output Summary: The traceability matrix carries 28 rows, one per acceptance criterion, each naming a
concrete Pester test name, a concrete command result, or a concrete artifact path. No row is
unmapped. Twenty-seven criteria are satisfied. AC18 takes the conditional deferral branch: both
per-workflow sections of the P7-T12 artifact record `DEFERRED`, so the AC18 row records the
criterion as deferred, names that artifact path, and names `pr-author` as the deferral owner.
