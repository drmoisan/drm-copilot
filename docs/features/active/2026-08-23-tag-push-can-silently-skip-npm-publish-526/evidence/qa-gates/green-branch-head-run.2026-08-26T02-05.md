# Green Branch-Head Run — Deferral Record — P7-T12

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command: `gh run list --workflow=publish-mcp-npm.yml --limit 5 --json databaseId,headBranch,conclusion,url`

EXIT_CODE: 0

The `Command:` and `EXIT_CODE:` fields above record the **first** of the two read-only listing
invocations this task ran. The second invocation and its exit code are recorded in its own
per-workflow section below.

DEFERRED_TO: pr-author

## Why this is a deferral and not an observation

The feature-review policy rule `modified-workflow-needs-green-run` makes a workflow diff Blocking
unless a green workflow run against the branch head is present in remediation inputs. It applies to
both workflow files this change touches.

No task in this plan pushes a branch or opens a pull request, and both operations are prohibited to
the executor. The branch-head run therefore cannot exist during this execution, and this task is
completed by writing this deferral record rather than by observing a run. This task performed no
branch push, no tag push, and no publish. The only network operations it performed are the two
read-only `gh run list` invocations recorded below.

Branch at the time of measurement: `bug/tag-push-can-silently-skip-npm-publish-526`.

---

## Section 1 — `.github/workflows/publish-mcp-npm.yml`

Workflow: `.github/workflows/publish-mcp-npm.yml`

Run URL: `DEFERRED`

Run Conclusion: `DEFERRED`

Listing invocation run by the executor:

```
gh run list --workflow=publish-mcp-npm.yml --limit 5 --json databaseId,headBranch,conclusion,url
```

Observed exit code: **0**

Observed output — five runs, every one against an `mcp-server-v*` tag ref:

| databaseId | headBranch | conclusion | url |
|---|---|---|---|
| 32930241401 | `mcp-server-v1.1.3` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32930241401 |
| 32885709848 | `mcp-server-v1.1.2` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32885709848 |
| 32846558904 | `mcp-server-v1.1.1` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32846558904 |
| 32656062364 | `mcp-server-v1.1.0` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32656062364 |
| 32439743292 | `mcp-server-v1.0.27` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32439743292 |

None of the five carries a `headBranch` of `bug/tag-push-can-silently-skip-npm-publish-526`. No
branch-head run exists for this workflow, so `Run URL:` and `Run Conclusion:` are recorded as the
literal `DEFERRED`.

Deferral owner: **`pr-author`**

Exact read-only invocation to be run once the pull request exists:

```
gh run view RUN_IDENTIFIER --json conclusion
```

`RUN_IDENTIFIER` is to be replaced with the concrete integer run identifier of this workflow's
branch-head run, obtained from the listing invocation above once that run appears.

**Expected deferred outcome.** P4-T2, P4-T3, and P4-T4 ref-guard every tag-dependent step of this
workflow on `startsWith(github.ref, 'refs/tags/mcp-server-v')`. A pull-request run carries
`refs/pull/N/merge`, which does not match that prefix, so the publish step, the tag-versus-manifest
equality step, and the post-publish registry poll are all skipped. The expected outcome is therefore
a **run conclusion of `success` with the publish step concluding `skipped`**, which confirms the run
consumes no version number. `pr-author` checks that expectation against the observed run.

---

## Section 2 — `.github/workflows/verify-published-releases.yml`

Workflow: `.github/workflows/verify-published-releases.yml`

Run URL: `DEFERRED`

Run Conclusion: `DEFERRED`

Listing invocation run by the executor:

```
gh run list --workflow=verify-published-releases.yml --limit 5 --json databaseId,headBranch,conclusion,url
```

Observed exit code: **1**

Observed output:

```
HTTP 404: workflow verify-published-releases.yml not found on the default branch (https://api.github.com/repos/drmoisan/drm-copilot/actions/workflows/verify-published-releases.yml)
```

The 404 is the expected result for a workflow file created by this change and not yet merged to the
default branch: GitHub resolves a `--workflow=<file>` filter against the default branch, where this
file does not yet exist. No run of any kind exists for this workflow, so `Run URL:` and
`Run Conclusion:` are recorded as the literal `DEFERRED`.

Deferral owner: **`pr-author`**

Exact read-only invocation to be run once the pull request exists:

```
gh run view RUN_IDENTIFIER --json conclusion
```

`RUN_IDENTIFIER` is to be replaced with the concrete integer run identifier of this workflow's
branch-head run.

**Expected deferred outcome.** P5-T4 gave this workflow a `pull_request` trigger scoped to the
workflow file and to `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`, and the test
`gates the registry sweep off pull-request runs so a branch-head run cannot fail on a pre-existing
divergence` in `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` asserts that the
sweep itself does not run on a pull-request event. The expected outcome is therefore a **run
conclusion of `success`** with the reconciliation sweep gated off, so a pre-existing tag/registry
divergence (such as the known `1.0.12` gap) cannot make the branch-head run red.

---

## Disposition of AC18

AC18 requires a green run of `publish-mcp-npm.yml` against the branch head, produced by the new
`pull_request` trigger, with the run's publish-step conclusion recorded as `skipped`.

Section 1 records the literal `DEFERRED` for both `Run URL:` and `Run Conclusion:`. Per the plan
task text, the executor therefore **leaves the AC18 checkbox unchecked** in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` and reports
AC18 in the completion report as an outstanding acceptance criterion owned by `pr-author`.

Completing this task records the AC18 deferral and its owner. It does **not** itself satisfy AC18.
The AC18 checkbox is checked only when an observed green branch-head run with a publish-step
conclusion of `skipped` is recorded for `.github/workflows/publish-mcp-npm.yml`.

Output Summary: Both per-workflow sections record the literal `DEFERRED` for `Run URL:` and
`Run Conclusion:`, because no branch-head run exists for either workflow. The first listing
invocation returned exit code 0 with five runs, all against `mcp-server-v*` tag refs and none against
the feature branch; the second returned exit code 1 with `HTTP 404: workflow
verify-published-releases.yml not found on the default branch`. One `DEFERRED_TO: pr-author` line is
present. Each section names its workflow path, its `Run URL:` and `Run Conclusion:` values, the
deferral owner `pr-author`, the exact deferred read-only invocation `gh run view RUN_IDENTIFIER
--json conclusion`, and the expected deferred outcome. AC18 remains unchecked and outstanding, owned
by `pr-author`. No branch push, tag push, or publish was performed by this task.
