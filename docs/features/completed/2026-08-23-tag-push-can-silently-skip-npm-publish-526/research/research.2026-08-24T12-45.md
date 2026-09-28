# Research — Tag push can silently skip npm publish (Issue #526)

- Timestamp: 2026-08-24T12-45
- Feature folder: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/`
- Work Mode: full-bug
- Branch: `bug/tag-push-can-silently-skip-npm-publish-526`
- Repository root for this run: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9cfa72f420dc2eb2`
- Author agent: task-researcher (research only; no source, config, or workflow file was modified)

## 0. Method and Evidence Limits (read first)

**No shell command was executed during this research.** The tool set available to this agent in this
session was `Read`, `Grep`, `Glob`, `WebFetch`, `Write`, `Edit`. No `Bash` or shell-execution tool was
present, so no `git`, `gh`, or `npm` invocation was made. Every repository claim below is grounded in
a file read with a file:line citation; every GitHub-behaviour claim is grounded in a fetched
documentation URL. Nothing here is grounded in a command result.

The hard safety constraint was observed: no release, publish, tag-creation, or tag-push command was
run, and no script under `scripts/dev-tools/` was executed.

`## 12. Diagnostics Not Yet Run` lists the read-only commands that would materially advance the root
cause and that this agent could not execute. Several of them are time-sensitive.

Claims are labelled throughout:

- **FINDING** — verified by direct file read or by official documentation.
- **HYPOTHESIS** — consistent with evidence but not verified; the mechanism is not established.
- **INFERENCE** — a deduction from two or more FINDINGs, stated as such.

The issue text conflates finding and hypothesis (see `## 4`). This artifact does not.

---

## 1. Current State — Workflows

### 1.1 `.github/workflows/publish-mcp-npm.yml` (64 lines, read in full)

**FINDING — Trigger configuration.** `publish-mcp-npm.yml:3-7`:

```yaml
on:
  push:
    tags:
      - "mcp-server-v*"
  workflow_dispatch:
```

Two triggers only: a tag push matching `mcp-server-v*`, and manual dispatch. There is **no
`pull_request` trigger**. This has a downstream consequence for any change to this file — see
`## 9.3`.

**FINDING — Job dependency graph.** Two jobs.

1. `drm-copilot-extension-tests` (`publish-mcp-npm.yml:10-29`) — matrix over
   `[ubuntu-latest, windows-latest]` (`:15`), runs `npm --prefix extensions/drm-copilot ci` (`:26`)
   then `npm --prefix extensions/drm-copilot run test` (`:29`).
2. `publish` (`publish-mcp-npm.yml:31-63`) — `needs: drm-copilot-extension-tests` (`:33`), so it
   runs only if the matrix job succeeds.

**FINDING — Credential mechanism.** `publish` declares `permissions: contents: read` /
`id-token: write` (`publish-mcp-npm.yml:35-37`), sets `registry-url: "https://registry.npmjs.org"`
(`:46`), upgrades npm with `npm install -g npm@11.18.0` (`:49`), and publishes with
`npm publish --provenance --access public` (`:63`). No `NODE_AUTH_TOKEN` and no `secrets.*`
reference appears anywhere in the file. This is npm trusted publishing over OIDC.

**FINDING — Publish guard.** `publish-mcp-npm.yml:60-63`:

```yaml
      - name: Publish to npm
        if: github.event_name == 'push'
```

The guard is on the **event name**, not on the ref.

**FINDING — What a `workflow_dispatch` re-run would and would not do.** A dispatch run executes the
whole `publish` job — checkout, setup-node, npm upgrade, `ci`, `prepack`, `build` — and then
evaluates `github.event_name == 'push'` as **false**, because the event name for a manual run is
`workflow_dispatch`. The publish step is therefore **skipped**. A skipped step does not fail its job,
so the job concludes `success` and the run concludes `success`. **A green `workflow_dispatch` run of
this workflow publishes nothing and reports success.** The issue's claim on this point
(`issue.md:87`) is verified correct.

**FINDING — The dispatch guard is ref-independent, which is the recoverability defect.** The REST
endpoint "Create a workflow dispatch event" documents its `ref` body parameter as: *"The git
reference for the workflow. The reference can be a branch or tag name."*
(https://docs.github.com/en/rest/actions/workflows). A dispatch against `mcp-server-v1.0.25` is
therefore possible, and it would check out the correct tagged tree. It still would not publish,
because the guard tests `event_name` rather than `github.ref`. **The workflow is structurally
incapable of recovering a missed publish, and the reason is one expression.**

**FINDING — `workflow_dispatch` availability precondition is satisfied.** *"To trigger the
`workflow_dispatch` event, your workflow must be in the default branch."*
(https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow). The file
is present on `main`, so dispatch is available.

**FINDING — Nothing in the workflow ties the published version to the tag.** The publish step runs
`npm publish` against `packages/mcp-server/package.json` as it exists at the checked-out ref. No step
extracts the version from `github.ref` and compares it to the manifest. A run triggered by tag
`mcp-server-v1.0.25` whose tree carried manifest version `1.0.24` would publish `1.0.24` (or fail
E403 as already-published) while reporting nothing anomalous about the mismatch. This is a distinct,
currently unguarded hole; see `## 6.2`.

### 1.2 `.github/workflows/publish-extension.yml` (65 lines, read in full)

**FINDING — Trigger configuration.** `publish-extension.yml:3-15`: `push` on tags `v*` (`:5-6`),
`workflow_dispatch` (`:7`), and `pull_request` restricted to paths
`extensions/drm-copilot/**` and `.github/workflows/publish-extension.yml` (`:12-15`).

**FINDING — The `pull_request` trigger exists specifically to satisfy a repository review rule.**
The comment at `publish-extension.yml:8-11` states verbatim: *"The publish step is gated to v\* tag
refs, so PR runs never publish; this provides the green branch-head run required by
modified-workflow-needs-green-run for a new tag-triggered workflow that cannot be dispatched before
it lands."* That rule is defined in `.claude/skills/feature-review-workflow/SKILL.md` and referenced
in `.claude/rules/ci-workflows.md`.

**FINDING — Job dependency graph.** Same two-job shape: `drm-copilot-extension-tests`
(`:18-37`, same matrix) and `publish` (`:39-65`) with `needs: drm-copilot-extension-tests` (`:41`).

**FINDING — Publish guard.** `publish-extension.yml:62-65`:

```yaml
      - name: Publish to Marketplace
        if: startsWith(github.ref, 'refs/tags/v')
        working-directory: extensions/drm-copilot
        run: npx --yes @vscode/vsce publish --pat ${{ secrets.VSCE_PAT }}
```

The guard is on the **ref**, not the event name.

**FINDING — The two guards have materially different re-run semantics.** This is the asymmetry the
delegation prompt flagged, and it is confirmed:

| | `publish-mcp-npm.yml` | `publish-extension.yml` |
|---|---|---|
| Guard expression | `github.event_name == 'push'` (`:61`) | `startsWith(github.ref, 'refs/tags/v')` (`:63`) |
| Tag push | publishes | publishes |
| PR run | n/a (no PR trigger) | skips (`github.ref` is `refs/pull/N/merge`) |
| `workflow_dispatch` against `main` | skips | skips |
| `workflow_dispatch` against the release **tag** | **skips** | **publishes** |
| Missed run recoverable without touching the tag? | **No** | **Yes** |

**INFERENCE.** Had the mcp workflow used the extension workflow's ref-based guard, the `1.0.25`
incident would have been recoverable by a single command
(`gh workflow run publish-mcp-npm.yml --ref mcp-server-v1.0.25`) with no tag deletion and no version
number burned. The recovery cost of the defect is therefore largely a consequence of the guard
expression, not of the missed event itself. Aligning the guard is the cheapest high-value change
available and is recommended in `## 8`.

**FINDING — Marketplace credential.** `secrets.VSCE_PAT` at `publish-extension.yml:65`. This one
*is* a secret, unlike the npm path.

---

## 2. Current State — Release Scripts

### 2.1 `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` (213 lines, read in full)

**FINDING — Seam design.** All external calls go through a single wrapper `Invoke-GitExe`
(`:52-69`) returning `@{ Output; ExitCode }`. There is **no `gh` seam and no `npm` seam** in this
script, and no sleep/poll seam. It talks only to `git`.

**FINDING — Control flow of `Invoke-ReleaseTagPushGuarded` (`:135-205`).**

1. Confirmation guard: `$ConfirmToken -cne 'yes'` returns 2 (`:155-158`).
2. Both manifests must exist, else return 1 (`:163-170`).
3. `git pull origin main` (`:173`); non-zero returns 1 (`:174-177`).
4. Read `version` from both manifests (`:180-181`).
5. Derive `v<ext>` and `mcp-server-v<mcp>` (`:184-185`).
6. Loop over the two tags (`:188-202`).

**FINDING — The tags are pushed as two separate single-ref pushes, in a fixed order.**
`Invoke-ReleaseTagPush.ps1:188-202`:

```powershell
    foreach ($entry in @(
            @{ Tag = $extTag; Message = "Release $extTag" },
            @{ Tag = $mcpTag; Message = "mcp-server $mcpVersion" }
        )) {
        $create = Invoke-GitExe -GitArgs @('tag', '-a', $entry.Tag, '-m', $entry.Message)
        ...
        $push = Invoke-GitExe -GitArgs @('push', 'origin', $entry.Tag)
```

Each iteration issues its own `git push origin <single-tag>`. The extension tag `v<version>` is
created and pushed **first**; the mcp tag `mcp-server-v<version>` is created and pushed **second**.
There is no multi-ref push, no `--tags`, and no `--follow-tags` anywhere in the file.

**FINDING — There is no wait, sleep, poll, or confirmation between the two pushes.** The loop body
proceeds directly from the first `git push` returning 0 to the second `git tag -a`. Grep of the file
for `Start-Sleep`, `gh`, or any poll construct: none present; the only functions defined are
`Write-StderrLine`, `Invoke-GitExe`, `Get-NpmVersion`, `Get-ExtensionTagName`, `Get-McpServerTagName`,
and `Invoke-ReleaseTagPushGuarded`.

**FINDING — The success criterion is `git push` exit code 0, and nothing else.** `:198-201` treats a
non-zero push exit as failure; a zero exit ends the iteration. The function then returns 0 (`:204`).
No verification of any kind follows.

**FINDING — Confirmed by the Pester suite.**
`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1:59-71` asserts, on a confirmed run, exactly
five `Invoke-GitExe` invocations with the comment *"One pull + two tag-creates + two tag-pushes = 5
git invocations"* (`:63-64`), and asserts `$pushArgs.Count | Should -Be 2` (`:70`) with the two push
argument arrays matching `push origin v0\.0\.3` and `push origin mcp-server-v0\.0\.2` (`:68-69`).
The two-separate-pushes behaviour is not incidental; it is pinned by test.

### 2.2 `scripts/dev-tools/Invoke-FullRelease.ps1` (357 lines, read in full)

**FINDING — This script never tags and never publishes.** It verifies a clean tree (`:264-273`),
creates `release/full-<timestamp>` (`:276-281`), patch-bumps both manifests with
`npm version patch --no-git-tag-version` (`:284`, `:289`), rewrites both Codex pins via
`Set-CodexMcpVersionPin` (`:302`), commits six files (`:312-330`), pushes the branch (`:333`), and
opens the PR (`:342`).

**FINDING — The Codex pin is written from the freshly bumped manifest.**
`Set-CodexMcpVersionPin` (`:145-193`) rewrites
`args = ["-y", "@danmoisan/drm-copilot-mcp@<version>"]` in both `.codex/config.toml` copies, and
throws unless each file contains exactly one matching entry (`:178-180`). It is invoked with
`-Version $newMcpVersion` (`:302`), where `$newMcpVersion` is read back from the bumped manifest
(`:296`).

**INFERENCE — This is exactly why the 1.0.25 artifact was internally consistent and externally
broken.** The pin is derived from the manifest at PR-authoring time, which is *before* any publish
has occurred. The pin therefore always matches the manifest by construction, and matching the
manifest carries no information about whether the version was ever published. A pin-equals-manifest
test cannot detect this class of defect. See `## 7`.

### 2.3 `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (402 lines, read in full)

**FINDING — End-to-end sequence of `Invoke-FullReleaseFlowGuarded` (`:260-395`).** Confirmation
(`:279-282`) → clean tree (`:284-294`) → current branch must be `main` (`:296-306`) →
`git fetch origin main` (`:308`) → local `main` SHA must equal `origin/main` SHA (`:314-331`) →
invoke `Invoke-FullRelease.ps1` (`:334`) → resolve release branch (`:340-350`) → resolve PR number via
`gh pr view` (`:352`) → `Wait-ForPullRequestChecks` (`:364`) → `gh pr merge --merge --delete-branch`
(`:369`) → `git checkout main` (`:375`) → `git pull origin main` (`:381`) → invoke
`Invoke-ReleaseTagPush.ps1` (`:388`) → **return 0** (`:394`).

**FINDING — The flow ends at the tag push. There is no post-tag verification of any kind.** Line 394
returns 0 immediately after the child tag-push script returns 0. This is the precise location of the
gap: the last thing the automation asserts is that `git push` was accepted by the remote.

**FINDING — A reusable, test-friendly polling pattern already exists in this file.**
`Wait-ForPullRequestChecks` (`:162-258`) implements exactly the two-phase bounded poll a publish
verifier needs: a **registration phase** (retry while the query itself fails, `:223-232`, default 24
attempts × 5 s) and a **completion phase** (retry while any result is pending, `:237-257`, default 60
attempts × 10 s), with immediate non-zero return on a genuine failure (`:238-241`). Its docstring at
`:167-172` states the rationale: *"GitHub takes several seconds to register workflow checks after a
pull request is opened."* Delay of a queried GitHub resource is already an acknowledged, handled
condition in this codebase.

**FINDING — `Invoke-Sleep` is an explicit mock seam.** `:122-142`, with the docstring *"Isolates
Start-Sleep behind a mockable function so Pester tests can assert on wait behavior (poll counts,
retry intervals) without incurring a real wall-clock delay."* A new poller must reuse this pattern to
satisfy `.claude/rules/general-unit-test.md` ("Banned APIs in test code: ... real wall-clock waits").

**FINDING — `Invoke-GhExe` already exists here** (`:85-100`) returning `@{ Output; ExitCode }`, and
the flow already assumes an authenticated `gh` (used for `pr view`, `pr checks`, `pr merge`). A
verification step using `gh` adds no new external dependency to the flow.

### 2.4 Task wiring

**FINDING — `.vscode/tasks.json`** defines four release tasks: "Release: Open Extension Version-Bump
PR" (`:239`), "Release: Open Full Version-Bump PR" (`:259`), "Release: Push Release Tags (post-merge)"
(`:279`, invoking `Invoke-ReleaseTagPush.ps1` at `:273`), and "Release: Automate Full Release Flow"
(`:299`, invoking `Invoke-FullReleaseFlow.ps1` at `:293`). Each passes a `-ConfirmToken` pick-string
input. A verification step added to either script inherits its task wiring with no `tasks.json`
change; a *new* script would need a new task entry.

### 2.5 Current repository version state

**FINDING.** `packages/mcp-server/package.json:3` is `"version": "1.1.0"`. Both Codex configs pin
`@danmoisan/drm-copilot-mcp@1.1.0` (`.codex/config.toml:5` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml:5`). The pins and
the manifest currently agree.

---

## 3. GitHub's Documented Behaviour (official sources)

**FINDING — The tag-push limit.** From the webhook events reference
(https://docs.github.com/en/webhooks/webhook-events-and-payloads), under the `push` event, verbatim:

> "Events will not be created if more than 5000 branches are pushed at once. Events will not be
> created for tags when more than three tags are pushed at once."

The exact limit is therefore **more than three tags in a single push**, and the exact condition is
that the tags are pushed **at once** — i.e. in one push operation. The companion limits, from the same
source: the `create` event *"will not occur when more than three tags are created at once"*, and the
`delete` event *"will not occur when more than three tags are deleted at once"*. The Actions events
reference
(https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
restates the create/delete form of the limit.

**FINDING — Skip tokens.** From
https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs: the tokens
`[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]`, and the trailer
`skip-checks: true`, in a commit message, suppress workflows that would otherwise be triggered by
`on: push` or `on: pull_request`. *"Skip instructions only apply to the `push` and `pull_request`
events."* This is the one **officially documented** mechanism that produces exactly the reported
signature: no run, no error, no signal anywhere.

**FINDING — `GITHUB_TOKEN` recursion suppression.** From
https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow:
*"When you use the repository's `GITHUB_TOKEN` to perform tasks, events triggered by the
`GITHUB_TOKEN` will not create a new workflow run, with the following exceptions"*. This is a second
documented silent-suppression mechanism. It is **not applicable here**: the tags are pushed from a
developer workstation by `Invoke-ReleaseTagPush.ps1`, not by a workflow. Recorded so it can be
explicitly excluded rather than left as an unexamined possibility.

**FINDING — Path filters are not evaluated for tag pushes.** Same source: *"Path filters are not
evaluated for pushes of tags."* Excludes path-filter suppression as a candidate; neither publish
workflow declares tag-push path filters in any case.

**FINDING — No documented mechanism drops a push event at two refs.** Across the three
documentation pages fetched, there is no statement that pushes in rapid succession, or two separate
single-tag pushes, or two tags pointing at the same commit, cause an event or workflow run to be
dropped. The only tag-count threshold documented anywhere is *more than three tags in one push*.

---

## 4. Adjudication of the Issue's Suspected Cause Against the Code

This section is required to be explicit about divergence. There are four divergences and one
confirmation.

### D1 — The script already pushes the two tags sequentially, as two separate single-ref pushes

**The issue's proposed remedy is half-implemented already.** `issue.md:99` proposes: *"Make
`Invoke-ReleaseTagPush.ps1` push the two tags sequentially and confirm each run has started before
pushing the next, rather than pushing both and returning."*

The phrase *"rather than pushing both and returning"* describes the script inaccurately if it is read
as "pushes both refs in one operation". `Invoke-ReleaseTagPush.ps1:188-202` iterates and issues
`git push origin <tag>` once per tag; the Pester suite pins exactly two push invocations
(`Invoke-ReleaseTagPush.Tests.ps1:67-70`). The pushes are already separate and already ordered.

The phrase is accurate if it is read as "pushes both and returns without confirming anything" — which
is what the script does (`:204`, then `Invoke-FullReleaseFlow.ps1:394`).

**The narrower real gap is therefore precisely this:** the remedy's first clause ("push the two tags
sequentially") is **already in place**; the remedy's second clause ("confirm each run has started
before pushing the next") is **entirely absent**, and so is any confirmation *after* the last push.
The script's only success criterion is `git push` exit code 0.

### D2 — `git push` exit code 0 does not mean a push event was created

**FINDING/INFERENCE.** `git push` exits 0 when the remote accepts the ref update *and* when the ref
is already present and identical (the "Everything up-to-date" case), which produces no ref change and
therefore no push event at all. The script cannot distinguish "GitHub created a workflow run" from
"GitHub received a ref update but created no run" from "there was nothing to update". All three
produce exit 0. This is the structural reason the failure is silent, and it is independent of
whichever root cause produced the missing event: **no achievable improvement to the push command can
make exit code 0 a proof of publication.** Only an out-of-band observation can.

### D3 — The issue's suspected cause has no documented mechanism at two tags

`issue.md:81-83` hypothesises *"GitHub Actions may not start a workflow for every ref when several
are pushed together"*, correctly labelling it a hypothesis.

Against the documentation (`## 3`), the documented threshold is **more than three tags in one push**.
The observed releases involve **two tags** in **two separate pushes** — under the threshold on the
count axis and not "at once" on the mechanism axis. **The documented limit does not explain these
occurrences, and no other documented mechanism covers a two-ref case.** The hypothesis is not
thereby refuted — undocumented event-delivery loss is possible — but it is downgraded: it has no
documented basis, and the remedy derived from it (make the pushes sequential) was already in effect
during both failures.

**This is the single most important divergence for the orchestrator.** A plan built on "make the
pushes sequential" would ship a change that was already present at the time of both failures and
would assert nothing new. Under `.claude/rules/plan-acceptance-gates.md` that is the shape of a gate
that cannot fail.

### D4 — The issue's proposed registry check is itself a gate that cannot fail

`issue.md:98` proposes asserting *"the expected version is retrievable from the registry
(`npm view @danmoisan/drm-copilot-mcp version`)"*.

**FINDING.** `npm view <pkg> version` returns the version behind the `latest` dist-tag, not the
version under test. At the time of the 1.0.25 incident, `latest` was `1.0.24`, so this command would
have returned `1.0.24` and exited 0. **The proposed check would have passed on the exact failure it
is being proposed to catch.** The decisive form is `npm view <pkg>@<exact-version> version`, which
exits non-zero (E404) when the specific version does not exist. This correction must reach the plan;
see `## 6.3`.

### C1 — One issue claim is confirmed exactly as written

`issue.md:87`: *"The publish step is `if: github.event_name == 'push'`
(`.github/workflows/publish-mcp-npm.yml:61`), so a `workflow_dispatch` re-run cannot recover a missed
publish — it builds and skips."* Verified at `publish-mcp-npm.yml:61`. The line number cited in the
issue is correct.

---

## 5. Candidate Root Causes, Ranked

Ranked by how well the available evidence supports each. The observational base is thin (n = 2
failures, both of the same tag family), so the ranking is stated with its uncertainty rather than
presented as a conclusion.

### Common observations that constrain every candidate

- **O1 (FINDING).** Both known failures are the **mcp** tag, which is the **second** ref pushed by
  the loop (`Invoke-ReleaseTagPush.ps1:188-190` orders extension first). 2 of 2.
- **O2 (INFERENCE).** For 1.0.25, the extension publish evidently succeeded — `issue.md:53-56`
  reports the broken pin affected *"anyone on extension 1.0.25"*, which presupposes extension 1.0.25
  shipped. So at the same release, from the same script, the first-pushed tag produced a run and the
  second did not.
- **O3 (FINDING).** Both tags point at the **same commit**. `.git/packed-refs:42-43` records
  `refs/tags/mcp-server-v1.0.12` as annotated object `52a4f294...` peeling to commit
  `d5242b2d3dbb881a5d140da4ba5ed1662fb87209`; `.git/packed-refs:96-97` records `refs/tags/v1.0.12` as
  `78017e0f...` peeling to the **same** commit `d5242b2d...`. (The equivalent check for 1.0.25 could
  not be made here: this `packed-refs` is stale, with `main` at `51b9e91e` and no tag beyond
  `1.0.21`.) By construction the flow tags one commit — `Invoke-ReleaseTagPush.ps1` pulls main once
  (`:173`) and tags HEAD twice.
- **O4 (INFERENCE from O2+O3).** Any candidate whose mechanism keys on the **commit** — a skip token,
  the commit's workflow tree, the commit's presence on the remote — must explain why it suppressed
  one workflow and not the other **at the identical commit**. Skip tokens and commit-availability are
  commit-scoped and therefore cannot; a per-workflow-file defect can.

### R1 — Event-delivery loss for the second of two tag pushes issued milliseconds apart

**HYPOTHESIS.** Rank 1 by evidential fit; rank low by mechanism.

*Fit.* Explains O1 and O2 directly. Explains the intermittency (2 misses across ~28 releases).
Explains the 1.1.0 counter-observation: `issue.md:89` records that the two tags were pushed
sequentially *with confirmation between them* and both fired.

*Against.* No documented mechanism (`## 3`, D3). The documented tag threshold is `> 3` tags in one
push, which does not describe this flow. The 1.1.0 counter-observation is n = 1 and confounded — that
release was also a manual minor bump (`docs/features/potential/promoted/2026-08-23-release-flow-supports-only-patch-increment.md:25-28`
records 1.1.0's manifests were bumped by hand with `npm version minor`), so it differed from a normal
release in more than just the inter-push spacing.

*Confirming evidence.* Only GitHub's internal event log. A repository webhook delivery log
(`gh api /repos/{owner}/{repo}/hooks/{id}/deliveries`) would show it **only if a webhook is
configured** — Actions dispatch is not a webhook, so this most likely yields nothing. The
organization audit log is not available for a personal repository.
**Obtainable now: essentially no.** Confirmation realistically requires a GitHub Support ticket citing
both occurrences (a human action; see `## 10`).

*Refuting evidence.* A future occurrence where the **first**-pushed tag is the one that fails would
refute an "mcp-workflow-specific" reading while supporting this one; an occurrence with wide spacing
between pushes would refute this one. Note that O1 does **not** discriminate R1 from R6 — both
predict that the mcp tag is the one that fails.

### R2 — Absence of any verification, so an event loss from *any* cause is invisible and unbounded

**FINDING.** Rank 1 as the **actionable** cause, whatever the triggering cause turns out to be.

This is not a competing hypothesis about why the event was lost; it is the verified reason the loss
reached production. `git push` exit 0 is the only signal the automation consumes (D2), the flow
returns 0 immediately afterward (`Invoke-FullReleaseFlow.ps1:394`), and the workflow's publish guard
makes the miss unrecoverable without destroying the tag (`## 1.1`). The 1.0.12 miss went undetected
for an unknown period; the 1.0.25 miss shipped a broken artifact for **two days**
(`issue.md:56`: 2026-08-15 to 1.0.26 on 2026-08-17) and was found only by an unrelated manual
inspection on 2026-08-23.

*Evidence.* Already established by file read; nothing further needed.
**This is the cause the fix must address, because it is the only one under repository control.**

### R3 — Skip token in the tagged commit's message

**HYPOTHESIS, expected to be refuted, cheap to check.** Rank 3 by check cost, not by likelihood.

*Fit.* The only **documented** mechanism producing exactly "no run, no error, no signal"
(`## 3`). Release commits are generated by `Invoke-FullRelease.ps1:325` as
`"release: bump extension to X and mcp-server to Y"`, which carries no token — but the **merge**
commit created by `gh pr merge --merge` (`Invoke-FullReleaseFlow.ps1:369`) is the commit actually
tagged, and its message is GitHub-generated.

*Against.* Skip tokens are commit-scoped, so by O4 this would have suppressed **both** workflows.
O2 says the extension published. Expect refutation.

*Confirming/refuting evidence.* `git log -1 --format=%B mcp-server-v1.0.25^{commit}` and the same for
1.0.12. **Obtainable now, locally, in seconds.** Run it to close the candidate.

### R4 — The workflow file was absent, invalid, or carried a different trigger at the tagged commit

**HYPOTHESIS, cheap to check, and the only candidate fully verifiable from the local repository
today.** Rank 4.

*Fit.* For a tag push, Actions evaluates workflow files as they exist at the pushed ref. A file that
is absent, whose `on.push.tags` pattern does not match, or whose YAML does not parse, yields no
matching run. Unlike R3 this is **per-file**, so it survives O4: it can suppress the mcp workflow
while leaving the extension workflow intact.

*Against.* The file is long-established and adjacent releases (1.0.24, 1.0.26) ran. An unparseable
workflow normally surfaces as a `startup_failure` run rather than as silence, though whether such a
run is associated with the workflow ID that `gh run list --workflow=<file>` filters on is
**unverified**.

*Confirming/refuting evidence.*
`git show mcp-server-v1.0.25:.github/workflows/publish-mcp-npm.yml` and the same at
`mcp-server-v1.0.12`, `mcp-server-v1.0.24`, `mcp-server-v1.0.26`, diffed against each other.
**Obtainable now, locally, offline, in seconds.** Do this first — it is the cheapest decisive-for-
refutation check available and the issue did not perform it.

### R5 — `gh run list` observation artifact: a run existed but was not listed

**HYPOTHESIS about the observation, not about the defect.** Rank 5.

*Fit.* `gh run list` defaults to a bounded result set and filters by workflow ID; a workflow file
that was deleted and recreated acquires a new ID, orphaning older runs from the filename filter.

*Against.* `issue.md:47` reports runs present for the **adjacent** tags 1.0.24 and 1.0.26 and absent
for 1.0.25 — a result-count limit cannot skip a middle entry.

*Why it still matters.* The registry evidence (`issue.md:46`: 1.0.25 absent from
`npm view ... versions`) already proves **no successful publish occurred**. R5 can only change the
characterization from "no run at all" to "a run that did not publish", which changes the root-cause
search space substantially. The issue's central premise deserves one confirmation.

*Evidence.* `gh api /repos/drmoisan/drm-copilot/actions/runs --paginate` filtered on
`head_branch == "mcp-server-v1.0.25"` across **all** workflows, not one. **Obtainable now for 1.0.25;
possibly expired for 1.0.12** — see `## 12` on retention.

### R6 — A condition specific to the mcp workflow or the mcp tag pattern

**HYPOTHESIS.** Rank 6.

*Fit.* Explains O1 and O2 without needing a timing mechanism. Sub-cases: the workflow was disabled
and re-enabled around those dates (manual UI action or `gh workflow disable`); an Actions policy or
required-workflow setting; a transient repository-level Actions incident.

*Against.* A disabled workflow would suppress **all** intervening tags, and adjacent releases
succeeded, so it requires a narrow disable/enable window twice. No evidence supports that.

*Evidence.* Current state via `gh api /repos/drmoisan/drm-copilot/actions/workflows/publish-mcp-npm.yml`
(field `state`) is obtainable, but **historical** state is not: there is no audit log for a personal
repository. **Confirmation is not obtainable now.** GitHub Status history
(https://www.githubstatus.com/history) for 2026-08-15 and for the 1.0.12 date is obtainable and would
support or weaken the "transient incident" sub-case.

### R7 — The second push was a no-op because the ref already existed on the remote

**HYPOTHESIS, near-self-refuting, retained for one reason.** Rank 7.

*Fit.* `git push origin <existing-identical-tag>` exits 0, prints "Everything up-to-date", creates no
push event, and therefore no run. That is a perfect match for the reported signature.

*Against.* To reach that state the **local** tag must be absent while the **remote** tag is present —
otherwise `git tag -a` fails at `Invoke-ReleaseTagPush.ps1:192-195` and the script returns 1 loudly.
And a prior push that placed the tag on the remote would itself have produced a run, of which there is
none. The candidate is close to circular.

*Why retained.* The underlying property — **push exit 0 does not imply an event** — is true
regardless of this candidate's likelihood, and any guard design must account for it (D2).

### R8 — The tag was pushed before its target commit was on the remote

**Effectively refuted by the flow's structure.** Rank 8.

`Invoke-FullReleaseFlowGuarded` merges the PR through `gh pr merge` (`:369`), checks out main
(`:375`), and pulls (`:381`) *before* invoking the tag-push script (`:388`), which itself pulls again
(`Invoke-ReleaseTagPush.ps1:173`). The tagged commit therefore originates from the remote and is
already present there. Additionally, git pushes any missing target object along with the tag ref, so
even a locally-created target would arrive with the push.

*Evidence.* `git merge-base --is-ancestor <tagged-commit> origin/main` (exit 0 = ancestor).
**Obtainable now**, and worth running once for completeness.

### R9 — Rate limiting or `GITHUB_TOKEN` recursion suppression

**Refuted for recursion; unsupported for rate limiting.** Rank 9.

Recursion suppression applies only to events triggered by `GITHUB_TOKEN` (`## 3`); these tags are
pushed from a workstation. No documented Actions rate limit silently drops workflow-run creation for
a personal repository at two pushes per minute. No evidence either way; not obtainable.

### R10 — Credential/token expiry

**Refuted.** Rank 10. `publish-mcp-npm.yml` references no secret at all (`## 1.1`), so no token can
expire. The `README.md:402` claim that made this look plausible is stale (`## 9.1`). Recorded because
the README would actively mislead an operator debugging this at release time — which is the point of
the separately filed issue #528.

---

## 6. What a Sound Fail-Loud Verification Must Check

The delegation prompt asks which of three checks is decisive. The answer is (c), with (a) and (b)
required for a different reason.

### 6.1 (a) Run-exists verification — necessary, not sufficient, and uniquely time-critical

*What it is.* After pushing tag `T`, poll for a workflow run whose head ref is `T`.
`gh run list --workflow=publish-mcp-npm.yml --event=push --json databaseId,headBranch,status,conclusion`,
matched on `headBranch == T`. **HYPOTHESIS to confirm at implementation time:** that `head_branch`
carries the short tag name for a tag-triggered run. If it does not, match on `head_sha` plus workflow,
or query `/repos/{owner}/{repo}/actions/runs?event=push` and correlate.

*Power.* This is the **only** one of the three checks that can distinguish "no event was created"
from "the publish failed", and therefore the only one that identifies the failure mode this issue is
about. It is also the only check fast enough to gate the *next* push: a run appears within seconds to
a few minutes, whereas a publish completes only after the full two-OS test matrix.

*Limits.* A run existing proves nothing about publication. Specifically, a run can be green while its
publish step is skipped — which is not a theoretical concern here but the workflow's *designed*
behaviour under `workflow_dispatch` (`## 1.1`).

*Cannot live in the workflow.* **A workflow cannot detect its own non-existence.** Any missing-run
detector must be out-of-band: in the release script, or in a separate scheduled workflow. This is the
governing architectural constraint on the fix.

### 6.2 (b) Step-conclusion verification — necessary, not sufficient

*What it is.* `gh run view <id> --json jobs`, locate job `Publish to npm`, locate step
`Publish to npm`, require `conclusion == "success"`. Require **not** `skipped`.

*Power.* Closes the "green run, nothing published" hole the issue correctly identifies at
`issue.md:102`. A job containing a skipped step still concludes `success`, so run-level conclusion is
not a substitute.

*Limits.* Two residual holes. First, step success proves *a* publish occurred, not that the **tagged**
version was published — nothing in the workflow ties `github.ref` to the manifest version (`## 1.1`).
Second, the check depends on the workflow's internal step naming, so it is coupled to the YAML and
will silently degrade to "step not found" if a step is renamed. A verifier must treat "step not found"
as failure, not as absence of evidence.

### 6.3 (c) Registry-resolution verification — **this is the decisive check**

*What it is.* `npm view @danmoisan/drm-copilot-mcp@<exact-version> version`. Success requires exit 0
**and** stdout equal to `<exact-version>`. Absence yields E404 and a non-zero exit.

*Why decisive.* It interrogates the artifact a consumer actually resolves. It is the same resolution
`npx -y @danmoisan/drm-copilot-mcp@1.0.25` performs, which is precisely the operation that failed for
two days. It is independent of run existence, job naming, step naming, event name, and guard
expression — it would return the correct verdict even if every other part of the pipeline were
rewritten. It requires no authentication for a public package.

*Assumption stated.* (c) is decisive for "did this artifact ship" **given** that the workflow is the
only publisher of this package. If someone published by hand, (c) would pass with (a) and (b) failing.
In this repository that is the intended and only path, so the assumption holds; it is recorded so a
future reader does not treat (c) as decisive in a context where it is not.

*The correction from D4 is load-bearing.* `npm view <pkg> version` resolves the `latest` dist-tag and
would have returned `1.0.24` and exited 0 during the 1.0.25 failure. The `<pkg>@<version>` form is
mandatory. A plan that carries the issue's command verbatim ships a gate that cannot fail.

*Marketplace analogue.* `npx --yes @vscode/vsce show <publisher>.<name> --json`, or the unauthenticated
Marketplace `extensionquery` API
(`POST https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery`, header
`Accept: application/json;api-version=3.0-preview.1`), asserting the exact version appears in the
returned version list. **Both commands are unverified by this research** — neither was executed. The
plan must validate the exact invocation before depending on it.

### 6.4 Verdict, and how the three compose

| Check | Detects "no run" | Detects "green run, no publish" | Detects "artifact absent" | Can run pre-second-push |
|---|---|---|---|---|
| (a) run exists | **yes** | no | no | **yes** |
| (b) step conclusion | indirectly | **yes** | no | no (too slow) |
| (c) registry resolves | no | yes | **yes** | no (too slow) |

**(c) is decisive for the outcome. (a) is decisive for the diagnosis and is the only check that can
gate the second push. (b) is the diagnostic bridge between them.** A sound verifier runs all three,
derives its **exit code from (c)**, and **reports (a) and (b) to make the failure actionable** — a
failure that says "version 1.0.25 does not resolve on the registry; a run exists (id 123) and its
publish step concluded `skipped`" tells the operator which recovery to perform, whereas a bare
registry failure does not.

### 6.5 Polling is mandatory; a single immediate check is unsound

**FINDING.** The report records two independent propagation observations: the Marketplace lagged
roughly five to eight minutes on the 1.1.0 release, and the extension run *"took three polls to
appear, so a single immediate check would have been inconclusive"* (`issue.md:89`, `:98`).

Proposed budgets, **labelled HYPOTHESIS** — they are extrapolated from a single release observation,
not from a measured distribution, and the plan should treat them as initial values:

| Check | Interval | Max attempts | Ceiling |
|---|---|---|---|
| (a) run appears | 10 s | 18 | 3 min |
| (b) run reaches a terminal conclusion | 20 s | 60 | 20 min |
| (c) npm resolves the exact version | 15 s | 40 | 10 min |
| (c') Marketplace lists the exact version | 30 s | 30 | 15 min |

An exhausted budget must be reported as a **distinct** outcome from a negative result — "not yet
visible after N attempts" is operationally different from "the publish step was skipped" — and both
must exit non-zero.

---

## 7. Where the Guard Must Live Relative to the Irreversible Point

The tag push is the point of no return: once `mcp-server-v1.0.25` is pushed and any publish attempt
succeeds, npm reserves `1.0.25` permanently (`issue.md:74-76`). This partitions the guard surface.

**Pre-push (can still prevent burning a version).** Everything cheap and offline: manifests agree,
Codex pins equal the manifest, the tag name derives from the manifest, the target commit is on
origin/main, the target version is **not already present** on npm. That last one is worth stating: a
pre-push `npm view <pkg>@<next-version> version` that *succeeds* means the version is already
consumed and the release must not proceed. It is a cheap check with an inverted sense that nothing
currently performs.

**Between the two pushes (can prevent burning the second version).** Check (a) for the first tag,
optionally (b)/(c). This is the only window in which automation can still decline to consume the
second version number. It is what the issue's remedy clause asks for and what is absent today.

**Post-push (cannot recover anything; can only fail loudly).** Checks (b) and (c) for both tags. Their
entire value is speed of detection and quality of the recovery instruction. They cannot un-burn a
version.

### 7.1 Recommended: reverse the push order and gate on the mcp result

**Recommendation (design, not yet validated by execution).** Push `mcp-server-v<version>` **first**,
verify it publishes, and push `v<version>` only after (c) passes for the mcp package.

*Rationale.* The mcp package is the **dependency**; the extension is the **consumer** that ships a pin
to it. Today the consumer is released first and the dependency second, and the dependency is the one
that failed — which is exactly how a shipped extension came to pin a version that does not exist. With
the order reversed and the gate in place, the 1.0.25 outcome becomes **structurally impossible**: if
mcp `1.0.25` fails to publish, the extension tag is never pushed, `v1.0.25` is never consumed, and no
artifact pinning `1.0.25` ever reaches a user. The failure degrades from "broken release shipped for
two days" to "release did not complete; ext version number still available".

*Costs, stated honestly.* (i) The flow lengthens by one full CI cycle — the two-OS test matrix plus
publish plus registry propagation, plausibly 8-20 minutes — between the two pushes. It is unattended
time, so the cost is wall-clock, not attention. (ii) The mcp version is still burned if mcp publishes
and the ext tag later fails; that leaves an mcp version with no extension consuming it, which is
harmless. (iii) It makes the extension release depend on the npm registry being reachable.

*Interaction with R1.* If R1 is real, this change does **not** by itself remove the drop risk — it
relocates it. The gate is what removes the consequence, not the ordering. The ordering determines
*which* artifact absorbs a drop, and it should be the one whose absence is caught before anything
ships.

### 7.2 Recommended: align the mcp publish guard with the extension's

**Recommendation.** Change `publish-mcp-npm.yml:61` from `if: github.event_name == 'push'` to a
ref-based guard, e.g. `if: startsWith(github.ref, 'refs/tags/mcp-server-v')`.

*Effect.* A missed run becomes recoverable by `gh workflow run publish-mcp-npm.yml --ref
mcp-server-v<version>` — **no tag deletion, no version burned, no destructive git operation**
(`## 1.1`, plus the REST `ref` documentation confirming tag refs are accepted). This converts the most
expensive property of the defect into a one-command recovery. It also makes the two publish workflows
symmetric, which removes a genuine trap for an operator who has learned the extension workflow's
behaviour.

*Preserved safety.* A dispatch against `main` yields `github.ref == 'refs/heads/main'` → skip. A PR
run (if a `pull_request` trigger is added per `## 9.3`) yields `refs/pull/N/merge` → skip. This is the
identical model already proven by `publish-extension.yml:63`.

*Residual risk, stated.* A ref-based guard trusts the tag name. Someone could create an arbitrary
`mcp-server-v*` tag and dispatch against it; the workflow would publish whatever the manifest at that
ref says. Mitigate by adding a version-equality assertion inside the workflow (extract the version
from `github.ref`, compare to `packages/mcp-server/package.json`, fail on mismatch). That assertion
also closes hole one of `## 6.2` and is worth adding regardless of the guard change.

*Policy note.* If that assertion is written as a `pwsh` step that deliberately invokes a failing
nested command, `.claude/rules/ci-workflows.md` requires an explicit `$LASTEXITCODE = 0` reset or an
explicit `exit 0` on the success path. A verification step that runs `npm view` on an absent version
is precisely that pattern.

---

## 8. Recommended Approach

**Selected: a three-layer design — an out-of-band missing-run detector, an in-workflow publish
verifier, and a retroactive reconciliation sweep — combined with the two structural changes in
`## 7.1` and `## 7.2`.**

### Layer A — In-workflow post-publish verification (closes "green run, nothing published")

Inside `publish-mcp-npm.yml`, after the publish step: assert the tag version equals the manifest
version, then poll `npm view <pkg>@<version> version` until it resolves or the budget expires, and
fail the job otherwise. Cheap, always runs, no new infrastructure.

*Cannot close the reported defect on its own* — a workflow that never starts runs no verification
step. Layer A is necessary and insufficient.

### Layer B — Out-of-band per-tag verification in the release tooling (closes "no run at all")

A new function set (recommended location: a new `scripts/dev-tools/Invoke-ReleaseVerification.ps1`,
dot-sourceable, rather than growing `Invoke-ReleaseTagPush.ps1` — see the file-size note in `## 11`),
exposing per-tag checks (a), (b), (c) built on `Invoke-GhExe`, a new `Invoke-NpmExe`, and the existing
`Invoke-Sleep` seam pattern. Called by `Invoke-ReleaseTagPush.ps1` **between** the two pushes and
**after** the last one, and non-zero on any failure so `Invoke-FullReleaseFlow.ps1:389-392` propagates
it.

*This is the layer that would have caught both known occurrences,* and the only layer that can gate
the second push.

### Layer C — Scheduled reconciliation sweep (closes "a miss nobody looked for")

A scheduled workflow comparing the set of `mcp-server-v*` tags on the remote against
`npm view @danmoisan/drm-copilot-mcp versions --json`, and against the extension tag set versus the
Marketplace version list, opening a GitHub issue on any divergence.

*Distinct value.* It is the only **retroactive** layer: it would have surfaced the 1.0.12 gap without
anyone running a release, and it detects the case where the operator's machine dies mid-flow. It is
fully unattended, needs no release to run, and is independent of every root cause. Recommended even if
Layers A and B are descoped.

### Rejected alternatives (brief)

- **Single multi-ref push (`git push origin v<x> mcp-server-v<x>`).** Two tags is under the documented
  `> 3` threshold, so it is not *prohibited* — but it collapses two outcomes into one exit code,
  reducing the observability this fix exists to increase. Rejected.
- **A fixed sleep between the two pushes, with no verification.** Cheap and plausible-looking, but it
  asserts nothing and cannot fail; it would pass identically whether or not the run was created.
  Rejected under `.claude/rules/plan-acceptance-gates.md`.
- **Verification wholly inside the workflow.** Structurally cannot detect a run that never started.
  Rejected as a complete solution; retained as Layer A.
- **Unconditional automatic tag delete-and-re-push on a detected miss.** Destructive and unsafe: if
  the version was in fact consumed, the re-push cannot republish it and the operation has destroyed a
  ref that consumers may already have fetched. Rejected in favour of the precondition-gated single
  retry in `## 10`.
- **Making the pushes "sequential".** Already the case (`## 4`, D1). Not a change.

---

## 9. Secondary Findings

### 9.1 `README.md` misstates the npm publish credential — **verified stale**

**FINDING.** `README.md:402`: *"Credential: publication requires the repository secret `NPM_TOKEN`."*
This is false. `publish-mcp-npm.yml` contains no `secrets.` reference; it authenticates via OIDC
trusted publishing (`id-token: write` at `:37`, `npm publish --provenance` at `:63`, npm upgraded to
`11.18.0` at `:49` for trusted-publishing support). A repository-wide grep for `NPM_TOKEN` returns no
match under `.github/workflows/`; the matches are confined to `README.md:402`, historical feature
documents, a runbook, and issue text.

**FINDING.** `README.md:401` is also inaccurate in a related way: it describes the publish step as
`npm publish --access public`, omitting `--provenance`, which the workflow does pass (`:63`).

**FINDING.** By contrast `README.md:409`, which states the extension publish uses `secrets.VSCE_PAT`,
**is accurate** (`publish-extension.yml:65`).

**Scope recommendation.** This is already filed as **issue #528**
(`docs/features/potential/promoted/2026-08-23-readme-misstates-npm-publish-credential.md:1,9-10`),
which additionally records that the unused `NPM_TOKEN` secret still exists in the repository — making
the stale claim more convincing, not less — and a separate stale runbook assertion about required
approvals. **#526 should not fix the README**; it should cite #528 and let it own the correction. The
material point for #526 is R10: the README would send an operator debugging a failed publish toward a
credential that has no effect, during the exact window when time pressure is highest.

### 9.2 `quality-tiers.yml` is absent from the repository root — **observation only**

**FINDING.** A glob for `quality-tiers.y*ml` across the repository returned no files.
`.claude/rules/quality-tiers.md` states that *"`quality-tiers.yml` at repo root maps every project to
one tier"* and that *"Adding a project without a tier classification fails CI."* The file does not
exist. Recorded as a known pre-existing environment defect per the delegation prompt. **Not in scope
for #526. No fix proposed.** Its practical consequence for this feature is that the tier of the
affected modules cannot be read from the map; treat release tooling as T4 (dev tooling / build
scripts) per the tier descriptions in that rule file, noting that the uniform coverage thresholds
(line >= 85%) apply at every tier regardless.

### 9.3 Modifying `publish-mcp-npm.yml` will be Blocking without a green branch-head run

**FINDING.** The feature-review policy rule `modified-workflow-needs-green-run` makes a workflow diff
Blocking unless a green workflow run against the branch head is present in remediation inputs
(`.claude/rules/ci-workflows.md`, "Enforcement"; `.claude/rules/benchmark-baselines.md` restates it).
`publish-mcp-npm.yml` has **no `pull_request` trigger** (`## 1.1`), so a change to it **cannot produce
a green branch-head run** today. `publish-extension.yml:8-16` shows the repository's own precedent for
resolving exactly this, with the reason written into the file as a comment.

**Recommendation.** Any plan that touches `publish-mcp-npm.yml` should add a `pull_request` trigger
mirroring `publish-extension.yml:12-15` (paths `packages/mcp-server/**` and the workflow file itself),
carrying an equivalent explanatory comment. This is mutually supporting with `## 7.2`: with a
ref-based publish guard, a PR run has `github.ref == refs/pull/N/merge` and therefore never publishes,
which is the same safety property the extension workflow already relies on.

**This constraint should reach the plan.** A plan that changes the workflow without it will be blocked
at review with no available remedy.

---

## 10. Coordination with Issue #522 — Who Owns the Pin Guard

**FINDING — #522's pin test is necessary and provably insufficient.** #522
(`docs/features/potential/promoted/2026-08-23-release-flow-supports-only-patch-increment.md:86`)
specifies a standing test asserting that the version in
`args = ["-y", "@danmoisan/drm-copilot-mcp@<version>"]` equals `packages/mcp-server/package.json`'s
`version`, in **both** config copies. That assertion **held** at 1.0.25 while the artifact was broken
(`issue.md:53-56`), so it cannot detect this defect class. #522 already records this at its line 88 and
defers the publish-side cause: *"Tracked separately for the publish-side root cause; this criterion
covers the pin-side guard."*

**FINDING — the pin is derived from the manifest by construction, so equality carries no information
about publication.** `Invoke-FullRelease.ps1:296,302` reads the bumped manifest and writes that exact
version into both pins in the same run. The two values cannot disagree on any path that goes through
the tooling. Equality is a guard against *hand edits and merge drift*, which is real value — but it is
structurally incapable of saying anything about the registry.

**FINDING — the two assertions cannot live in the same test, for a policy reason.**
`.claude/rules/general-unit-test.md` requires that *"Unit tests must not depend on external services
(databases, networks, remote APIs, external processes)"* and that tests be deterministic. A per-commit
test that resolves the pin against npm would (i) require network in the per-commit suite, violating
that rule, and (ii) **fail on every release PR by construction**, because at PR-authoring time the
pinned version has been bumped but not yet published — the publish happens only after the tag push,
which happens only after the PR merges.

**Recommendation — split by network dependency, not by subject matter:**

- **#522 owns the offline invariant.** Pin == manifest, in both config copies, in the per-commit
  Pester suite, no network, deterministic. Exactly as #522 already specifies.
- **#526 owns the registry-resolution guard.** Executed once per release, **after** the tag push,
  where network access is inherent and a failure is actionable — as Layer A (in-workflow), Layer B
  (release tooling), and Layer C (scheduled sweep).

**What the #526 guard must assert, precisely.** Read the pinned version from the committed
`.codex/config.toml` **at the released ref** and require that exact version to resolve on the registry
(`npm view <pkg>@<pinned> version`). Reading the **pin** rather than the manifest is strictly stronger
and does not depend on #522 having landed: it closes the 1.0.25 case directly, since the shipped pin
is the string that `npx -y` will actually resolve. Given #522's offline test, pin and manifest are
equal and either would do; without it, only the pin is authoritative about what shipped.

**The guard is implemented once, in #526.** #522 should keep its offline test and reference #526's
post-publish check rather than duplicating it. The two entries already agree on this boundary; this
research confirms it and supplies the policy citation that forces it.

---

## 11. Behaviour Semantics and Requirements Mapping

### Proposed per-tag state model

```
PUSH_ACCEPTED        git push exited 0            (necessary; proves nothing further — D2)
   -> RUN_OBSERVED       check (a) found a run for the tag ref
      -> RUN_TERMINAL       run reached a terminal conclusion
         -> STEP_PUBLISHED     check (b): publish step conclusion == success (not skipped)
            -> RESOLVED           check (c): exact version resolves on the registry   [SUCCESS]
```

Failure states, each with a distinct exit signal and a distinct recovery instruction:

| State | Meaning | Recovery |
|---|---|---|
| `NO_RUN` | (a) budget exhausted | With `## 7.2`: `gh workflow run --ref <tag>`. Without it: precondition-gated tag delete + re-push (`## 12.2`). |
| `RUN_FAILED` | run conclusion `failure`/`cancelled` | Read the logs; the version may or may not be consumed — check (c) before any retry. |
| `STEP_SKIPPED` | job success, publish step `skipped` | The guard did not match. Version **not** consumed. Fix the guard or the trigger; re-dispatch. |
| `STEP_MISSING` | named step not found | Workflow was renamed. Treat as failure, not as absence of evidence. |
| `UNRESOLVED` | (c) budget exhausted after (b) succeeded | Likely propagation; re-run the verifier before concluding. Do **not** retry the publish. |
| `VERSION_CONSUMED_ELSEWHERE` | pre-push (c) succeeded | The next version is already taken. Abort before pushing. |

### Ordering rules

1. Push `mcp-server-v<version>` first (`## 7.1`).
2. Require `RESOLVED` for the mcp tag before pushing `v<version>`.
3. On any non-`RESOLVED` mcp outcome, exit non-zero and **do not** push the extension tag. The
   extension version number stays available.
4. After the extension push, verify to `RESOLVED` (npm-analogue for the Marketplace) and exit non-zero
   otherwise.

### Files likely to change

| File | Change |
|---|---|
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | Reverse loop order; call verification between and after pushes; add `Invoke-GhExe`/`Invoke-NpmExe`/`Invoke-Sleep` seams or consume them from a shared module. Currently 213 lines — the 500-line cap in `.claude/rules/general-code-change.md` argues for a separate module. |
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` (new) | Checks (a), (b), (c) with bounded polling behind mock seams. |
| `.github/workflows/publish-mcp-npm.yml` | Ref-based publish guard (`## 7.2`); tag/manifest version equality assertion; post-publish registry poll (Layer A); `pull_request` trigger (`## 9.3`). |
| `.github/workflows/verify-published-releases.yml` (new, optional) | Layer C scheduled reconciliation sweep. |
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` (new) | Per `.claude/rules/general-unit-test.md`, tests mirror the production tree. |
| `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | Existing assertions at `:63-70` pin the current 5-invocation shape and the ext-first order; both change. |
| `README.md` | **Not in this issue** — owned by #528 (`## 9.1`). |

### Testing implications (strategy only; no test code written)

- Reuse the three established seams: `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-Sleep`. All three are
  already mocked in the existing suites (`Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` exists
  specifically for the poll-behaviour case), so poll counts and intervals can be asserted with no
  wall-clock delay — required by the banned-APIs clause of `.claude/rules/general-unit-test.md`.
- Cover per check: found on first poll; found on the Nth poll (the `issue.md:89` three-polls case);
  never found (budget exhausted, non-zero); query itself failing (registration phase); and, for (b),
  `success` / `skipped` / `failure` / step-not-found.
- Cover the ordering rule: an mcp verification failure must result in **zero** extension-tag pushes.
  Assert on the captured git argument arrays, in the style of
  `Invoke-ReleaseTagPush.Tests.ps1:67-70`.
- Non-vacuity per `.claude/rules/plan-acceptance-gates.md`: every added assertion must be shown to
  fail when the behaviour is wired incorrectly. In particular, prove that the registry check fails for
  a version that is absent — a test using `npm view <pkg> version` (the `latest` form) would pass
  either way and is the exact defect D4 identifies.
- No temporary files (prohibited by `.claude/rules/general-unit-test.md`); no real network.
- Workflow changes: `scripts/dev-tools/run-actionlint.ps1` exists and should be run; plus the green
  branch-head run required by `## 9.3`.
- Coverage: line >= 85% uniformly (`.claude/rules/quality-tiers.md`). PowerShell is exempt from the
  branch threshold because Pester does not measure branch coverage; it remains in the line-coverage
  denominator.

---

## 12. Diagnostics Not Yet Run (and their obtainability)

No command was executed by this agent (`## 0`). The following are read-only, safe, and would
materially advance the root cause. **Ordered by value-per-cost.**

### 12.1 Run these first — local, offline, seconds, no network

| # | Command | Settles |
|---|---|---|
| 1 | `git show mcp-server-v1.0.25:.github/workflows/publish-mcp-npm.yml` (and at `mcp-server-v1.0.12`, `-v1.0.24`, `-v1.0.26`), diffed | **R4** — the only candidate fully verifiable offline; not yet checked by the issue |
| 2 | `git log -1 --format=%B mcp-server-v1.0.25^{commit}` (and 1.0.12) | **R3** — skip token present or absent |
| 3 | `git rev-parse mcp-server-v1.0.25^{commit} v1.0.25^{commit}` | Confirms O3 for 1.0.25 (confirmed only for 1.0.12 here, from `.git/packed-refs:42-43,96-97`) |
| 4 | `git log -1 --format=%aI mcp-server-v1.0.25` and `... v1.0.25` | Tagger timestamps — bounds the inter-push interval, the only local evidence bearing on R1 |
| 5 | `git merge-base --is-ancestor <tagged-commit> origin/main` | **R8** |

### 12.2 Network, still obtainable — but time-sensitive

| # | Command | Settles |
|---|---|---|
| 6 | `gh api /repos/drmoisan/drm-copilot/actions/runs --paginate --jq '.workflow_runs[] \| select(.head_branch=="mcp-server-v1.0.25")'` — **all** workflows, not one | **R5** — confirms or refutes the issue's central "no run at all" premise |
| 7 | `gh run list --workflow=publish-extension.yml --json headBranch,createdAt,conclusion` filtered to `v1.0.25` | Confirms O2 by evidence rather than inference; `createdAt` bounds R1 |
| 8 | `gh api /repos/drmoisan/drm-copilot/actions/workflows/publish-mcp-npm.yml --jq .state` | **R6** current state (historical state is not obtainable) |
| 9 | `npm view @danmoisan/drm-copilot-mcp versions --json` | Independent confirmation of the registry gaps; also the Layer C prototype |
| 10 | githubstatus.com history for 2026-08-15 and the 1.0.12 date | **R6** transient-incident sub-case |

**Time sensitivity.** GitHub's default retention for workflow **logs and artifacts** is 90 days.
Whether run **metadata** persists beyond that window is **unverified by this research**. The 1.0.25
release was 2026-08-15, nine days before this artifact — well inside any plausible window. The 1.0.12
release is materially older and its evidence may already be unrecoverable. **Collect the 1.0.25
evidence now; treat 1.0.12 as probably lost.**

**Not obtainable at all:** GitHub's internal event-delivery log (needed to confirm R1); historical
workflow enable/disable state (needed to confirm R6). Both require GitHub Support.

---

## Automation Feasibility

An honest assessment of what can run unattended and what cannot.

### Fully automatable — high confidence

- **Registry resolution of an exact npm version.** `npm view @danmoisan/drm-copilot-mcp@<version>
  version` needs no authentication for a public package, returns a deterministic string, and exits
  non-zero (E404) when the version is absent. It runs identically from a workflow step and from a
  local `pwsh` script. **This is the decisive check (`## 6.3`) and it is unreservedly automatable.**
- **Run-existence and step-conclusion checks.** `gh run list --json` and `gh run view --json jobs`
  require an authenticated `gh`, which the release flow already assumes and uses for `pr view`,
  `pr checks`, and `pr merge` (`Invoke-FullReleaseFlow.ps1:352,364,369`). No new dependency, no new
  credential.
- **Bounded polling with deterministic tests.** The pattern exists and is proven:
  `Wait-ForPullRequestChecks` (`Invoke-FullReleaseFlow.ps1:162-258`) with the `Invoke-Sleep` mock seam
  (`:122-142`).
- **Gating the second push on the first result.** Pure control flow inside
  `Invoke-ReleaseTagPush.ps1`.
- **Layer C reconciliation sweep.** A scheduled workflow diffing the tag set against the published
  version set, opening an issue on divergence. No human input at any point. **This is the
  highest-certainty automation in the whole proposal** and it is also the only retroactive one.

### Automatable with a caveat

- **Marketplace listing verification.** Two candidate mechanisms exist —
  `npx --yes @vscode/vsce show <publisher>.<name> --json`, and the unauthenticated Marketplace
  `extensionquery` REST endpoint. Both are plausibly unattended and unauthenticated. **Neither was
  executed by this research**, so the exact invocation, output shape, and whether `vsce show` supports
  `--json` in the current version are **unverified**. The plan must validate the command before
  depending on it. The five-to-eight-minute lag recorded at 1.1.0 (`issue.md:98`) makes polling
  mandatory and makes a naive single check unsound.
- **Recovery by re-dispatch — automatable only if `## 7.2` lands.** With a ref-based publish guard,
  recovery is `gh workflow run publish-mcp-npm.yml --ref mcp-server-v<version>`: non-destructive,
  idempotent-ish (a second successful publish of the same version fails E403 harmlessly), consumes no
  version number, and is safely scriptable. **Without that change, no automated recovery exists that
  does not destroy a tag.**

### Automatable only under explicit preconditions

- **Delete-and-re-push recovery (the pre-`## 7.2` path).** Mechanically scriptable
  (`git push --delete origin <tag>`, then re-push). It is **not safe unconditionally**: if the version
  was in fact consumed, the re-push cannot republish it and the operation has destroyed a ref that
  consumers may already have fetched.

  Safe only when **both** preconditions are verified first:
  1. `npm view <pkg>@<version> version` exits non-zero — the version is **not** consumed; **and**
  2. no successful run exists for that tag (`gh run list` / `gh api .../actions/runs`).

  Under both, a **single** automated retry is defensible. Cap it at one attempt: a retry loop against
  an unknown-cause event drop can burn tags without bound. Note that the delete side interacts with the
  documented `delete`-event limit of three tags at once (`## 3`), which is not a constraint at one tag
  but is worth knowing before any bulk operation.

### Not automatable — requires a human

- **Confirming the root cause R1.** Nothing in the repository, and nothing available through `gh` for a
  personal repository, can show whether GitHub created and dropped a push event. There is no audit log
  and no webhook delivery record for Actions dispatch. **Confirmation requires opening a GitHub Support
  ticket citing both occurrences with timestamps.** A human must write it, and GitHub controls whether
  a usable answer comes back. This is the honest limit of the investigation: **the fix must be sound
  without ever knowing why the events went missing**, which is why `## 8` recommends detection and
  recoverability rather than a fix targeted at R1.
- **Deciding what to do about an already-consumed version number.** When a version is burned and the
  artifact is broken, the options are `npm deprecate` (advisory, reversible), `npm unpublish` within 72
  hours (policy-restricted, permanently blocks the version, and its exact current policy is
  **unverified here**), shipping a hotfix at the next version, or doing nothing. The choice depends on
  how many consumers resolved the broken version and on the maintainer's tolerance for registry
  churn — a judgment call, not a rule. **Automate the detection and the notification; leave the
  disposition to a human, and give them a runbook.** The repository has an established pattern for
  exactly this: `docs/engineering/npm-token-rotation.runbook.md` is a human-exception runbook for a
  step no automation can perform.
- **Deciding whether an interim broken release warrants a consumer-facing notice.** Out of scope for
  automation entirely.

### Net assessment

The **detection** side of this issue is fully automatable, with high confidence, using mechanisms
already present in the repository. The **prevention** side is partially automatable: the ordering
change plus the inter-push gate (`## 7.1`) makes the specific 1.0.25 failure mode structurally
impossible, but no automation can prevent an event drop whose mechanism is unknown and outside the
repository. The **recovery** side is automatable **if and only if** the publish guard is changed
(`## 7.2`); otherwise recovery is destructive and should stay a documented human procedure. The
**root-cause confirmation** is not automatable at all and may never be answered.

---

## Appendix A — Evidence Index

| Claim | Source |
|---|---|
| mcp publish guard is event-based | `.github/workflows/publish-mcp-npm.yml:61` |
| mcp workflow has no `pull_request` trigger | `.github/workflows/publish-mcp-npm.yml:3-7` |
| mcp OIDC trusted publishing, no secret | `.github/workflows/publish-mcp-npm.yml:35-37,46,49,63` |
| extension publish guard is ref-based | `.github/workflows/publish-extension.yml:63` |
| extension PR trigger exists for the green-run rule | `.github/workflows/publish-extension.yml:8-16` |
| Two separate single-ref tag pushes, ext first | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:188-202` |
| No wait/poll/confirmation between pushes | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:188-202` (whole file read; no sleep/gh construct) |
| Two-push shape is pinned by test | `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1:63-70` |
| Flow returns 0 immediately after the tag push | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:388-394` |
| Reusable two-phase poll pattern | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:162-258` |
| `Invoke-Sleep` mock seam | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:122-142` |
| Codex pin derived from bumped manifest | `scripts/dev-tools/Invoke-FullRelease.ps1:145-193,296,302` |
| `v1.0.12` and `mcp-server-v1.0.12` share commit `d5242b2d...` | `.git/packed-refs:42-43,96-97` |
| Current mcp version 1.1.0; both pins 1.1.0 | `packages/mcp-server/package.json:3`; `.codex/config.toml:5`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml:5` |
| README misstates credential; omits `--provenance` | `README.md:401-402` vs `publish-mcp-npm.yml:63` |
| README VSCE_PAT claim is accurate | `README.md:409` vs `publish-extension.yml:65` |
| `quality-tiers.yml` absent | Glob `quality-tiers.y*ml` — no files found |
| Tag-push limit is `> 3` tags in one push | https://docs.github.com/en/webhooks/webhook-events-and-payloads |
| create/delete limits are `> 3` tags at once | https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows |
| Skip tokens and their scope | https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs |
| `GITHUB_TOKEN` events do not create runs; path filters not evaluated for tag pushes | https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow |
| `workflow_dispatch` requires the file on the default branch | https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow |
| Dispatch `ref` may be a branch **or tag** name | https://docs.github.com/en/rest/actions/workflows |

## Appendix B — Commands Executed

None. See `## 0`. No `Bash` or shell-execution tool was available to this agent in this session, so no
command was run and no exit code can be recorded. Every repository claim in this artifact is traceable
to a file read cited in Appendix A; every GitHub-behaviour claim is traceable to a fetched URL.
`## 12` lists the commands whose results are missing and states, for each, whether the evidence is
still obtainable.
