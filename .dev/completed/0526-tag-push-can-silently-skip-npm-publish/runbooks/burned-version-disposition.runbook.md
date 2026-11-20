# Human-Exception Runbook — Disposition of a Consumed npm Version Whose Artifact Is Broken or Absent

Contract-conformant per `.claude/skills/human-exception-runbook/SKILL.md`. Scope: issue #526, package `@danmoisan/drm-copilot-mcp`, repository `drmoisan/drm-copilot`.

This runbook covers what a human does **after** release automation has detected and reported a publish failure. The automation's responsibility ends at detection and notification.

## Cue

Act on this runbook when the orchestrator records an `exception` response for the requirement "decide what to do about an npm version number that has already been consumed while the artifact published under it is broken or absent" (issue #526).

npm permanently reserves a version number once it has been used: *"Once `package@version` has been used, you can never use it again. You must publish a new version even if you unpublished the old one."* The number cannot be reissued, so the disposition is a choice among imperfect responses whose relative cost depends on how many consumers already resolved the broken version and on the maintainer's tolerance for registry churn. That is a judgment about acceptable consequences, not a rule a script can evaluate, which is why it is resolved as a permitted exception rather than automated.

### What the operator will have seen

One of the following, in a release-verification failure message, a scheduled reconciliation-sweep issue, or a manual inspection:

| Reported state | Meaning | Is the version consumed? |
|---|---|---|
| `NO_RUN` | No workflow run exists for the pushed tag. | **Almost certainly not** — confirm in Step 2. |
| `STEP_SKIPPED` | A run exists and concluded `success`, but the `Publish to npm` step concluded `skipped`. | **No** — nothing was published. |
| `STEP_MISSING` | The named publish step was not found in the run's job list. | **Unknown** — treat as failure, not as absence of evidence. |
| `RUN_FAILED` | The run concluded `failure` or `cancelled`. | **Unknown** — the failure may have occurred before or after the registry write. |
| `UNRESOLVED` | The publish step concluded `success`, but the exact version did not resolve on the registry within the polling budget. | **Probably yes** — most likely propagation delay. |
| `VERSION_CONSUMED_ELSEWHERE` | A pre-push check found the intended next version already present on the registry. | **Yes**, and no tag has been pushed yet. |
| Shipped-artifact report | A released extension pins `@danmoisan/drm-copilot-mcp@<version>` that does not resolve (the 1.0.25 incident). | **Determine in Step 2.** |

### Routing

**Arriving here with a version that is not yet consumed is a materially different and much cheaper situation.** No disposition decision is required, no destructive registry operation is in scope, and the correct response is a non-destructive republish attempt (Step 6, Branch A). Do not evaluate `npm deprecate` or `npm unpublish` for a version that was never published; neither applies, and `npm unpublish` against an absent version accomplishes nothing while risking an operation against the wrong target.

The disposition decision in Step 7 applies **only** when Step 2 confirms the version is consumed.

### A green workflow run is not proof of publication

`.github/workflows/publish-mcp-npm.yml:60-63` gates the publish step on `if: github.event_name == 'push'`. A skipped step does not fail its job, and a job containing a skipped step still concludes `success`. A `workflow_dispatch` run of this workflow therefore builds, skips the publish, and reports success. Run conclusion is not a substitute for the step conclusion, and neither is a substitute for a registry query.

## Prerequisites

- The exact version string under disposition (for example `1.0.25`) and its tag name (`mcp-server-v<version>`).
- `npm` on `PATH`. The read-only registry queries in Step 2 need no authentication for a public package. Steps 7c and 7d (`npm deprecate`, `npm unpublish`) require an authenticated npm session as an owner or maintainer of `@danmoisan/drm-copilot-mcp`, and an OTP if two-factor authentication for writes is enabled.
- `gh` authenticated with read access to `drmoisan/drm-copilot` (Steps 3 and 4). The release flow already assumes an authenticated `gh`.
- A local clone with tags fetched (`git fetch --tags origin`) if Step 6 is reached.
- Knowledge of whether the publish guard has been changed to a ref-based expression. Read `.github/workflows/publish-mcp-npm.yml` and inspect the `if:` on the `Publish to npm` step before choosing a recovery path; the available recovery differs entirely between the two forms. As of 2026-08-24 the guard is event-based (`publish-mcp-npm.yml:61`).
- Time. Registry and Marketplace propagation is not instantaneous; see Verification.

## Step-by-step Instructions

Steps 1 through 5 establish which situation actually holds. Do not choose a disposition before completing them: the correct response differs per state, and two of the options are irreversible.

### Step 1 — Record the facts

Record, in the feature's evidence folder or the notifying issue: the package name, the exact version, the tag name, the release date, the reported state from the Cue table, and the current UTC time. The unpublish eligibility rules are time-dependent, so the release date is load-bearing.

### Step 2 — Determine whether the version is consumed on the registry

```
npm view @danmoisan/drm-copilot-mcp@<version> version
npm view @danmoisan/drm-copilot-mcp versions --json
```

**The exact-version form is required.** `npm view <pkg> version` with no version specified resolves the `latest` dist-tag — npm's documentation states *"The default version is `"latest"` if unspecified."* During the 1.0.25 incident `latest` was `1.0.24`, so the bare form would have printed `1.0.24` and exited zero. It answers a different question than the one being asked and would have reported success on the exact failure under investigation.

Interpretation:

- Stdout equals `<version>` — the version **is consumed**. Continue to Step 3, then Step 7.
- Stdout is empty and the second command's array omits `<version>` — the version is **not consumed**. Continue to Step 3, then Step 6.
- The two commands disagree — re-run both after a short interval before acting; see Verification.

Judge primarily on stdout content and on the `versions` array. npm's published `npm view` documentation does not state the exit code returned when the requested version does not exist, so do not rely on exit code alone.

### Step 3 — Determine whether a workflow run exists for the tag

Query across **all** workflows rather than filtering by workflow file. A workflow file that was deleted and recreated acquires a new ID, which orphans older runs from a filename filter.

```
gh api /repos/drmoisan/drm-copilot/actions/runs --paginate \
  --jq '.workflow_runs[] | select(.head_branch=="mcp-server-v<version>") | {id, name, event, status, conclusion, created_at}'
```

Record every matching run ID, or record that there are none. Note that GitHub's default retention for workflow logs and artifacts is 90 days; whether run metadata persists beyond that window is not confirmed here, so collect this evidence promptly for a recent release and expect an older release to be unrecoverable.

### Step 4 — Determine the publish step's own conclusion

For each run ID found in Step 3:

```
gh run view <run-id> --json jobs
```

Locate the job `publish` and, within it, the step named `Publish to npm`. Record that step's `conclusion`.

- `success` — a publish was attempted and the step did not fail.
- `skipped` — the guard did not match. Nothing was published. This is the designed behaviour of a `workflow_dispatch` run against the current event-based guard.
- `failure` — read the step log before proceeding; a publish that failed with `E403` indicates the version was already present.
- Step not present — treat as failure, not as absence of evidence. The workflow may have been renamed, in which case Steps 3 and 4 are measuring the wrong thing.

### Step 5 — Classify the situation

| Version consumed (Step 2) | Run exists (Step 3) | Publish step (Step 4) | Situation | Go to |
|---|---|---|---|---|
| No | No | n/a | Event was never delivered, or the tag push produced no ref change. | Step 6, Branch A |
| No | Yes | `skipped` | The guard did not match the trigger. | Step 6, Branch B |
| No | Yes | `failure` | The publish attempt failed before the registry write. | Step 6, Branch B |
| Yes | Yes | `success` | Published; the reported problem is propagation, or the published content is broken. | Verification first, then Step 7 if the content is genuinely broken |
| Yes | Yes | `failure` | Partially completed publish, or a prior publish already consumed the number. | Step 7 |
| Yes | No | n/a | The number was consumed by something other than a run for this tag. Establish what before acting. | Step 7 |

### Step 6 — Version not consumed: non-destructive recovery

**Branch A / B, first: check the publish guard.** Read the `if:` expression on the `Publish to npm` step of `.github/workflows/publish-mcp-npm.yml`.

- **If the guard is ref-based** (for example `startsWith(github.ref, 'refs/tags/mcp-server-v')`), recovery is a single non-destructive command:

  ```
  gh workflow run publish-mcp-npm.yml --ref mcp-server-v<version>
  ```

  This consumes no version number, deletes no ref, and can be repeated. GitHub's REST documentation for creating a workflow-dispatch event states the `ref` parameter *"can be a branch or tag name."* Use this path whenever it is available and stop here; proceed to Verification.

- **If the guard is event-based** (`github.event_name == 'push'`, the state at 2026-08-24), a dispatch run will build and skip. **The dispatch path cannot recover a missed publish.** The only remaining mechanical recovery is delete-and-re-push, which is governed by Step 6a.

For `STEP_SKIPPED` and `RUN_FAILED` where the version is not consumed, prefer fixing the cause (the guard expression, the trigger, or the failing step) and re-running over any operation that touches the tag.

### Step 6a — When deleting and re-pushing a tag is and is not safe

Deleting and re-pushing a tag is safe **only when both** of the following are verified immediately beforehand:

1. **The version is confirmed not consumed** — Step 2 returned empty stdout for the exact-version query and the `versions` array omits it; **and**
2. **No successful run exists for that tag** — Step 3 found no run, or Step 4 shows no run whose publish step concluded `success`.

If either precondition fails, do not delete the tag. If the version is in fact consumed, a re-push cannot republish it, and the deletion has destroyed a ref that consumers, CI systems, or mirrors may already have fetched. The operation would incur the full cost of a destructive change while achieving nothing.

Under both preconditions, a **single** retry is defensible. **Cap it at one attempt.** The cause of the missing event is not established; retrying against an unknown-cause event drop has no basis for expecting a different outcome on attempt N than on attempt 1, and an uncapped loop can create and destroy refs indefinitely, each cycle carrying its own risk of the publish succeeding on a later attempt while an earlier deletion has already been observed downstream. If the single retry does not produce a run, stop and escalate rather than repeating.

Before any bulk tag operation, note that GitHub's `delete` event is not created when more than three tags are deleted at once. This is not a constraint at one tag but is relevant if a cleanup is contemplated.

### Step 7 — Version consumed: the disposition decision

This is the decision the exception exists for. **There is no single correct answer.** The options below are presented with what each costs and what each forecloses so the choice can be made deliberately. Two of them are irreversible; that is stated explicitly against each.

Before choosing, gather the one piece of evidence that most changes the answer: **how many consumers have already resolved the broken version.** Approximations available without special access include the package's weekly download count, whether the version was ever referenced by a shipped artifact (for 1.0.25, the extension's `.codex/config.toml` pinned it, so every user of extension 1.0.25 attempted to resolve it), and how long the broken version was the one a shipped artifact pointed at.

#### Option 7a — Ship a hotfix at the next version number

Publish a corrected artifact at the next version and, where a consumer pins the broken version, release a corrected pin.

- **Cost:** one version number and one release cycle. No registry mutation beyond a normal publish.
- **Forecloses:** nothing. Compatible with every other option.
- **Reversible:** the release itself is not reversible, but it removes no information and blocks nothing.
- **Choose when:** the broken version is reachable by consumers and a working artifact is what they need. This is the baseline response and is almost always part of the answer regardless of which other option is selected.

#### Option 7b — Do nothing

Leave the consumed version in place, unannotated.

- **Cost:** consumers who explicitly request the broken version continue to receive it and continue to fail. The failure mode remains undocumented, so the next person to encounter it repeats the investigation.
- **Forecloses:** nothing.
- **Reversible:** yes, trivially — any other option remains available later.
- **Choose when:** the version is not referenced by any shipped artifact, the download evidence indicates effectively no consumers resolved it, and the registry churn of an annotation is judged not worth it. Record the decision so the next reader does not treat the gap as unexamined.

#### Option 7c — `npm deprecate` the broken version

```
npm deprecate @danmoisan/drm-copilot-mcp@<version> "<message>"
```

npm's documentation states that a deprecated version displays *"a red message ... on that version's package page"* and that users installing that version receive a deprecation notification. Undeprecation is an empty message:

```
npm deprecate @danmoisan/drm-copilot-mcp@<version> ""
```

- **Cost:** a visible annotation on the package page and an install-time warning. It does not remove the version and does not prevent installation.
- **Forecloses:** nothing. Deprecation does not affect later unpublish eligibility.
- **Reversible:** **yes** — undeprecate with an empty message.
- **Choose when:** the version is reachable and consumers should be steered away from it, but removal is either ineligible or not warranted. This is the advisory, low-cost, reversible option, and it is the appropriate default whenever the answer is not plainly "do nothing".
- **Write the message to be actionable:** name the defect and the version to use instead.

#### Option 7d — `npm unpublish` the broken version

```
npm unpublish @danmoisan/drm-copilot-mcp@<version>
```

npm's documentation states that removing a single version does not require the `--force` flag, that this is available through the CLI only and not the website, and that an OTP is required if two-factor authentication for writes is enabled.

**Eligibility is policy-restricted and time-dependent.** Verified from npm's published unpublish policy at the capture date recorded in Source and Citation:

- Within **72 hours** of publishing: *"as long as no other packages in the npm Public Registry depend on your package, you can unpublish anytime within the first 72 hours after publishing."*
- After 72 hours, all of the following must hold: *"no other packages in the npm Public Registry depend on it"*, *"it had less than 300 downloads over the last week"*, and *"it has a single owner/maintainer"*.

**Re-verify these rules against npm's current published policy at the time you act.** They are vendor policy and can change; the text above is a dated capture, not a standing guarantee.

- **Cost:** the version disappears from the registry. Any consumer with a lockfile or explicit pin referencing it experiences a hard resolution failure rather than a warning. This converts a broken install into an impossible install, which is preferable only when the broken install is worse.
- **Forecloses:** **the version number permanently.** npm states: *"Once `package@version` has been used, you can never use it again. You must publish a new version even if you unpublished the old one."* Additionally, *"If you entirely unpublish all versions of a package, you may not publish any new versions of that package until 24 hours have passed."* npm's CLI-facing unpublish page phrases the 24-hour block more broadly, as republishing under the same name being blocked for 24 hours; treat the stricter reading as the planning assumption.
- **Reversible: no.** This is the irreversible option. Once executed it cannot be undone, and the version cannot be restored.
- **Choose when:** the published content is actively harmful (not merely broken), publication was accidental, or the artifact contains material that must not remain distributed — and eligibility holds. **Do not choose it merely because the artifact is broken.** For a broken-but-inert artifact, 7c plus 7a delivers the same consumer-facing outcome with none of the irreversibility.

#### Evidence that should push toward each option

| Evidence | Points toward |
|---|---|
| A shipped artifact pins the broken version and users are hitting it now | 7a immediately, plus 7c |
| Non-trivial weekly downloads on the broken version | 7c (a warning reaches them); avoid 7d (a hard failure does not) |
| Effectively zero downloads and no shipped pin | 7b or 7c; 7d is not justified by the effort or the irreversibility |
| Published content is harmful, secret-bearing, or legally problematic | 7d, if eligible; otherwise escalate |
| Within 72 hours, no dependents, and the publish was accidental | 7d is available and defensible; still weigh it against 7c |
| Any doubt about consumer impact | 7c — it is the only option that is both visible and reversible |

Record the chosen option, the evidence it rested on, and the decision time in the notifying issue or the feature's evidence folder. A later reader must be able to tell that "do nothing" was a decision rather than an omission.

## Verification

**A single immediate check is unsound.** Registry and Marketplace propagation is not instantaneous: on the 1.1.0 release the Marketplace lagged roughly five to eight minutes and the extension workflow run took three polls to appear. Poll rather than checking once, and do not conclude from one negative result.

1. **Confirm the registry state after any registry-affecting action.** Re-run the exact-version query, polling at roughly 15-second intervals for up to about 10 minutes before treating a negative result as final:

   ```
   npm view @danmoisan/drm-copilot-mcp@<version> version
   ```

   - After 7a: the **new** version resolves and prints its own version string.
   - After 7c: the version still resolves. Confirm the deprecation separately with `npm view @danmoisan/drm-copilot-mcp@<version> deprecated`, which returns the message, and by loading the version's page on npmjs.com and observing the deprecation notice.
   - After 7d: the version no longer appears in `npm view @danmoisan/drm-copilot-mcp versions --json`.
   - After Step 6 recovery: the version resolves and equals `<version>` exactly.

2. **Confirm the run and step outcome for any recovery action** by repeating Steps 3 and 4. Require the `Publish to npm` step's conclusion to be `success` and explicitly **not** `skipped`. A green run alone does not satisfy this check.

3. **Confirm the consumer-facing resolution path**, which is the operation that actually failed for two days in the 1.0.25 incident. Verify that the version pinned in the shipped `.codex/config.toml` at the released ref resolves on the registry. Reading the pin is strictly stronger than reading the manifest, because the pin is the string a consumer's `npx -y @danmoisan/drm-copilot-mcp@<version>` will resolve.

4. **Confirm no gap remains** across the tag set by comparing the `mcp-server-v*` tags on the remote against `npm view @danmoisan/drm-copilot-mcp versions --json`. This is the check that would have surfaced the 1.0.12 gap without a release being run.

5. **Close the loop.** Update the notifying issue with the chosen disposition, the commands run, their observed output, and the verification results. If a GitHub Support ticket is warranted for the underlying missing-event cause, note that it is a separate action and is not part of this disposition.

## Source and Citation

Sourcing order per `.claude/skills/human-exception-runbook/SKILL.md` is MCP-first, web-second. No callable MCP documentation-retrieval tool is wired into this repository at this time, so every external source below was obtained via the web-second path. This limitation is recorded in the two-axis model-selection specification and is not resolved by this runbook.

### External sources (web-second; no MCP documentation source available in this session)

- npm unpublish eligibility, the 72-hour window, the post-72-hour conditions, permanent version-number reservation, and the 24-hour block after a full unpublish: npm Docs — "npm Unpublish Policy." Source URL: https://docs.npmjs.com/policies/unpublish — captured 2026-08-24.
- `npm unpublish <pkg>@<version>` command form, the absence of a `--force` requirement for a single version, the OTP requirement, and CLI-only availability: npm Docs — "Unpublishing packages from the registry." Source URL: https://docs.npmjs.com/unpublishing-packages-from-the-registry — captured 2026-08-24.
- `npm deprecate <pkg>@<version> "<message>"` and undeprecation with an empty message, and the install-time warning and package-page notice: npm Docs — "Deprecating and undeprecating packages or package versions." Source URL: https://docs.npmjs.com/deprecating-and-undeprecating-packages-or-package-versions — captured 2026-08-24.
- `npm view` default version resolution (*"The default version is `"latest"` if unspecified."*) and the exact-version form: npm Docs — "npm-view" CLI reference (v11). Source URL: https://docs.npmjs.com/cli/v11/commands/npm-view — captured 2026-08-24.
- `workflow_dispatch` `ref` accepting a tag name: GitHub Docs — "REST API endpoints for workflows." Source URL: https://docs.github.com/en/rest/actions/workflows — cited via the #526 research artifact, captured 2026-08-24.
- Tag-event delivery limits, including the `delete`-event limit of three tags at once: GitHub Docs — "Webhook events and payloads" and "Events that trigger workflows." Source URLs: https://docs.github.com/en/webhooks/webhook-events-and-payloads and https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows — cited via the #526 research artifact, captured 2026-08-24.

### Repository sources

- Event-based publish guard, and why a `workflow_dispatch` re-run builds and skips: `.github/workflows/publish-mcp-npm.yml:60-63` (verified by direct read, 2026-08-24).
- Ref-based guard precedent used by the sibling workflow: `.github/workflows/publish-extension.yml:62-65`.
- Tag creation and push loop; `git push` exit code 0 as the sole success criterion, with no verification following: `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:188-205` (verified by direct read, 2026-08-24).
- Release flow returning immediately after the tag push: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:388-394`.
- Codex pin derived from the bumped manifest before any publish occurs, which is why a pin-equals-manifest assertion held at 1.0.25 while the artifact was broken: `scripts/dev-tools/Invoke-FullRelease.ps1:145-193,296,302`.
- The 1.0.25 incident, the registry gaps at 1.0.12 and 1.0.25, the two-day exposure window, and the permanent-reservation consequence: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/issue.md:44-59,74-76,87-89,98-102`.
- Per-tag state model and its failure states; the exact-version requirement for the registry check; the two preconditions for a safe delete-and-re-push and the one-attempt cap; propagation-delay observations; the statement that this disposition is not automatable: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/research/research.2026-08-24T12-45.md:618-678,682-701,917-944,1056-1091`.
- Runbook structure and register precedent: `docs/engineering/npm-token-rotation.runbook.md`.

### Explicitly unverified

- **The exit code `npm view` returns for a version that does not exist.** npm's published `npm view` documentation does not state it. The #526 research artifact asserts a non-zero exit (E404), but that assertion is not grounded in an executed command — the research agent had no shell tool — and is not corroborated by the vendor documentation reviewed here. Step 2 therefore instructs the operator to judge primarily on stdout content and the `versions` array rather than on exit code alone. Any automation built on this behaviour must confirm it empirically before depending on it.
- **The current-at-time-of-use state of npm's unpublish policy.** The window and conditions quoted above are a dated capture, not a standing guarantee. Re-read https://docs.npmjs.com/policies/unpublish before executing Option 7d.
- **Whether GitHub workflow run *metadata* persists beyond the 90-day log-and-artifact retention window.** Step 3 may therefore return nothing for an older release without that absence being evidence about the original event.
