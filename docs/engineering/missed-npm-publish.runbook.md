# Operator Runbook — A Tag Push That Published Nothing to npm

Scope: issue #526, package `@danmoisan/drm-copilot-mcp`, repository `drmoisan/drm-copilot`.

This runbook is the operator-facing companion to the release verification module
`scripts/dev-tools/Invoke-ReleaseVerification.ps1`. That module reports exactly one state token per
verified tag. Each token has one section below, and each section states the recovery for that token
and nothing else.

A `git push` exit code of 0 is not evidence that a workflow run started, and a workflow run that
concludes `success` is not evidence that anything was published. The publish step can be skipped
without failing its job. Only an exact-version registry query settles whether a version exists.

## Reported states at a glance

| State | Meaning | Is the version consumed? | Section |
|---|---|---|---|
| `NO_RUN` | Check (a) budget exhausted; no run observed for the tag ref. | Almost certainly not. | [NO_RUN](#no_run) |
| `RUN_INCOMPLETE` | Check (b) budget expired while the run was still in progress; no conclusion was observed. | Unknown, and the run may still complete. | [RUN_INCOMPLETE](#run_incomplete) |
| `RUN_FAILED` | The run reached conclusion `failure` or `cancelled`. | Unknown. | [RUN_FAILED](#run_failed) |
| `STEP_SKIPPED` | The job concluded `success` but the publish step concluded `skipped`. | No. | [STEP_SKIPPED](#step_skipped) |
| `STEP_MISSING` | The named job or step was absent from the run payload. | Unknown. | [STEP_MISSING](#step_missing) |
| `UNRESOLVED` | Check (c) budget expired after the publish step succeeded. | Probably yes. | [UNRESOLVED](#unresolved) |
| `VERSION_CONSUMED_ELSEWHERE` | The pre-push check found the target version already on the registry. | Yes, and no tag was pushed. | [VERSION_CONSUMED_ELSEWHERE](#version_consumed_elsewhere) |

The single query that settles consumption for a version is read-only and needs no authentication:

```
npm view @danmoisan/drm-copilot-mcp@1.0.25 version
```

Substitute the version under investigation. The exact-version operand form is required. The bare
package operand resolves the `latest` dist-tag and answers a different question; it exited 0 during
the 1.0.25 failure and would have reported success on the exact defect this runbook exists for.

## NO_RUN

**Meaning.** The verifier polled for a workflow run against the pushed tag ref until its budget was
exhausted and never observed one. The push was accepted by the remote, but no run was created.

**Is the version consumed?** Almost certainly not. Confirm with the exact-version query above before
acting.

**Recovery.** The publish step of `.github/workflows/publish-mcp-npm.yml` is guarded on the ref
rather than on the event name, so a dispatch against the tag executes the publish step exactly as a
push-triggered run would. This is non-destructive and consumes no version number:

```
gh workflow run publish-mcp-npm.yml --ref mcp-server-v1.0.25
```

Substitute the tag name. Then confirm the resulting run and re-run the verifier.

Delete-and-re-push of the tag is **not** the first response and is never automated. It is gated on
the two preconditions below and is a human procedure.

## RUN_INCOMPLETE

**Meaning.** A run existed for the tag ref, but the publish-step polling budget expired while the run
was still in progress. The verifier never observed a terminal conclusion, so nothing is known about
whether the publish step succeeded, failed, or has yet to execute. This is not a failure of the run;
it is an expiry of the observation window.

**Is the version consumed?** Unknown, and the run may still complete. The run was live when the
verifier stopped watching, so the registry state can change after this report is produced.

**Recovery.** Re-run the verifier before reading any run log. The logs of a run that has not concluded
cannot answer whether the publish succeeded, and reading them invites a conclusion the evidence does
not support. A second verification run against the same tag is non-destructive and consumes no version
number. If the re-run reports `RUN_INCOMPLETE` again, raise the check (b) budget with
`-StepMaxAttempts` or `-StepIntervalSeconds` rather than treating the run as failed.

Do **not** re-dispatch the workflow and do **not** delete and re-push the tag from this state. A run
is still in progress; a second publishing run against the same version would race the first.

## RUN_FAILED

**Meaning.** A run existed for the tag ref and reached conclusion `failure` or `cancelled`. The
conclusion was observed; this section does not cover a run that never concluded, which is
`RUN_INCOMPLETE` above.

**Is the version consumed?** Unknown. The failure may have occurred before or after the registry
write.

**Recovery.** Read the run logs and identify the failing step. Evaluate the exact-version registry
query before any retry: a retry against a version that was in fact published cannot succeed, because
npm reserves a version number permanently once it has been used. If the version is consumed, the
disposition decision applies (see below). If it is not, correct the failing step and re-dispatch as
in `NO_RUN`.

## STEP_SKIPPED

**Meaning.** The job concluded `success`, but the `Publish to npm` step concluded `skipped`. This is
the exact failure mode a green run conceals: a skipped step does not fail its job.

**Is the version consumed?** No. Nothing was published.

**Recovery.** The publish guard did not match the ref. Confirm that the tag name begins with
`mcp-server-v` and that the guard expression on the publish step still matches that prefix, then
re-dispatch against the tag as in `NO_RUN`. No version number was consumed, so no disposition
decision is required.

## STEP_MISSING

**Meaning.** The named job or the named publish step was not found in the run payload. The workflow
was renamed, restructured, or the job matrix changed.

**Is the version consumed?** Unknown. Treat this as a failure, never as absence of evidence.

**Recovery.** Compare the job and step names in `.github/workflows/publish-mcp-npm.yml` against the
names the verifier looks for in `scripts/dev-tools/Invoke-ReleaseVerification.ps1`. Reconcile them
before retrying anything. Then evaluate the exact-version registry query to establish whether the
version was consumed, and proceed as for `RUN_FAILED`.

## UNRESOLVED

**Meaning.** Checks (a) and (b) both succeeded — a run existed and the publish step concluded
`success` — but the exact version did not appear on the registry within the polling budget.

**Is the version consumed?** Probably yes. This is most likely registry propagation delay.

**Recovery.** Re-run the verifier before concluding anything. Do **not** retry the publish: a
republish of a consumed version cannot succeed and a fresh version bump would be premature while the
first version may still be propagating. If the version still does not resolve after a second
verification pass well outside the propagation window, treat it as `RUN_FAILED` with a consumed
version and apply the disposition decision.

## VERSION_CONSUMED_ELSEWHERE

**Meaning.** The pre-push registry check found the target version already present on the registry
before any tag was created. The release aborted and pushed nothing.

**Is the version consumed?** Yes, and by something other than this release attempt.

**Recovery.** Bump the version again and re-run the release. Do not attempt to reuse the number. No
tag exists for the aborted attempt, so there is nothing to delete.

## Non-destructive re-dispatch

The ref-based publish guard is what makes recovery cheap. Because the publish step is guarded on
`startsWith(github.ref, 'refs/tags/mcp-server-v')` rather than on `github.event_name == 'push'`, a
dispatch against the release tag reaches the publish step exactly as a push-triggered run would.

```
gh workflow run publish-mcp-npm.yml --ref mcp-server-v1.0.25
gh run list --workflow=publish-mcp-npm.yml --limit 5 --json databaseId,headBranch,conclusion,url
```

A dispatch against `main` yields `refs/heads/main` and skips the publish step. A pull-request run
yields `refs/pull/N/merge` and skips it too. Neither consumes a version number.

Attempt the re-dispatch first, in every state where the version is not consumed. Only when a
re-dispatch cannot create a run at all do the delete-and-re-push preconditions come into play.

## Preconditions for a tag delete and re-push

Deleting and re-pushing a release tag is destructive and is never performed by automation. Consider
it only when a non-destructive re-dispatch has already failed to produce a run, and only when
**both** preconditions below hold. Neither precondition alone is sufficient.

### Precondition 1 — version resolves nowhere

The exact version must resolve nowhere on the registry. Run the read-only exact-version query and
require a non-zero exit code:

```
npm view @danmoisan/drm-copilot-mcp@1.0.25 version
```

A zero exit code means the version exists, the number is permanently consumed, and re-pushing the
tag cannot publish it. In that case stop here and go to the disposition decision below.

### Precondition 2 — no successful run for the tag

No successful run may exist for the tag. Enumerate the runs and inspect the publish-step conclusion
of any run that matches the tag ref:

```
gh run list --workflow=publish-mcp-npm.yml --limit 20 --json databaseId,headBranch,conclusion,url
gh run view RUN_IDENTIFIER --json jobs
```

Replace `RUN_IDENTIFIER` with the concrete integer run identifier. A run whose publish step
concluded `success` means a publish occurred, which contradicts precondition 1 and stops the
procedure. A run whose publish step concluded `skipped` is not a successful publish, but it does
mean a run existed, so the correct response is re-dispatch rather than tag deletion.

Only when precondition 1 and precondition 2 both hold is a delete-and-re-push in scope, and it is
then performed by a human with the tag name confirmed in writing beforehand.

## Disposition of a consumed version number

### Human decision — consumed version disposition

Once the exact-version query returns exit code 0, the number is permanently reserved. npm states
that once `package@version` has been used it can never be used again, and that a new version must be
published even if the old one was unpublished. What to do about a consumed number whose artifact is
broken or absent is therefore a choice among imperfect responses, not a rule automation can
evaluate. The candidate responses are no action, a forward hotfix under a new number, `npm
deprecate`, and `npm unpublish`; their relative cost depends on how many consumers already resolved
the broken version and on tolerance for registry churn.

**This decision is made by a human and is never taken by automation.** The current `npm unpublish`
policy is not confirmed in this repository and must be re-checked against npm's published policy
before that option is evaluated.

The full decision procedure, including the confirmation steps for each option, is in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/runbooks/burned-version-disposition.runbook.md`.

## Retroactive detection

`.github/workflows/verify-published-releases.yml` runs on a schedule and compares the remote
`mcp-server-v*` tag version set against the published version set, raising a visible signal on
divergence. It surfaces a missed publish that nobody ran a release to look for, including
divergences that predate this runbook. A signal from that sweep enters this runbook at the
exact-version query above.
