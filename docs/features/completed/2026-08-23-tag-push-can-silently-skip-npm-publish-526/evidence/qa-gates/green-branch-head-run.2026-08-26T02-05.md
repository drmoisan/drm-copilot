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

## Deferral discharged — 2026-08-26T09-05

The deferral recorded below was discharged once pull request #564 opened and its `pull_request`
runs completed against the branch head. The discharge observations are recorded in
`evidence/qa-gates/ac18-verification.2026-08-26T09-05.md`; that artifact is authoritative for AC18.
The literal `DEFERRED` values in Section 1 and Section 2 below are replaced with the observed values
in place, and the original deferral text is preserved unedited above and below for the record of
what was and was not knowable at execution time.

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

Run URL: `https://github.com/drmoisan/drm-copilot/actions/runs/32949401667` (observed 2026-08-26T09-05)

Run Conclusion: `success`, with the `Publish to npm` job's `Publish to npm` step concluding `skipped` (observed 2026-08-26T09-05)

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

Run URL: `https://github.com/drmoisan/drm-copilot/actions/runs/32949401794` (observed 2026-08-26T09-05)

Run Conclusion: `success`, with the `Reconcile pushed tags against published versions` step concluding `skipped` (gated off the pull-request event as designed) and `Validate the reconciliation comparison offline` concluding `success` (observed 2026-08-26T09-05)

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

**Update, 2026-08-26T09-05 — deferral discharged.** Pull request #564 opened against `main` from
branch `bug/tag-push-can-silently-skip-npm-publish-526`, and its `pull_request`-triggered runs have
completed. Section 1 above now records the observed run
(`https://github.com/drmoisan/drm-copilot/actions/runs/32949401667`, `event: pull_request`,
`headSha: c8867713453c25ec749bc412308b5516de402616`, matching the branch head at the time of
observation) with overall conclusion `success` and the `Publish to npm` job's `Publish to npm` step
concluding `skipped`. Every clause of AC18 is satisfied. The AC18 checkbox is now checked in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`. The full
per-clause record is `evidence/qa-gates/ac18-verification.2026-08-26T09-05.md`.

The original deferral text below (per the plan task text at execution time) is preserved unedited as
the record of what was and was not knowable when this task ran: no branch existed, no pull request
existed, and the executor was prohibited from pushing a branch or opening one, so a branch-head run
could not exist and this task correctly recorded a deferral rather than an observation.

Original disposition text (unedited): Section 1 records the literal `DEFERRED` for both `Run URL:`
and `Run Conclusion:` as they stood at execution time. Per the plan task text, the executor therefore
left the AC18 checkbox unchecked in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` and reported
AC18 in the completion report as an outstanding acceptance criterion owned by `pr-author`.

Completing the original task recorded the AC18 deferral and its owner; it did not itself satisfy
AC18. AC18 is satisfied now that an observed green branch-head run with a publish-step conclusion of
`skipped` is recorded for `.github/workflows/publish-mcp-npm.yml`, as recorded above.

Output Summary: Both per-workflow sections originally recorded the literal `DEFERRED` for `Run URL:`
and `Run Conclusion:`, because no branch-head run existed for either workflow at execution time. The
first listing invocation returned exit code 0 with five runs, all against `mcp-server-v*` tag refs
and none against the feature branch; the second returned exit code 1 with `HTTP 404: workflow
verify-published-releases.yml not found on the default branch`. One `DEFERRED_TO: pr-author` line was
present. Each section named its workflow path, its `Run URL:` and `Run Conclusion:` values, the
deferral owner `pr-author`, the exact deferred read-only invocation `gh run view RUN_IDENTIFIER
--json conclusion`, and the expected deferred outcome. That deferral is now discharged: AC18 is
checked, and both `Run URL:` and `Run Conclusion:` above record observed values rather than
`DEFERRED`. No branch push, tag push, or publish was performed by this discharge; only read-only
`gh run list` and `gh run view` invocations were used.
