# Human-Exception Runbook — Delete the Unused `NPM_TOKEN` Secret and Revoke the npm Access Token

- **Issue:** #712 (Bug: unused-npm-token-secret)
- **Branch:** `bug/unused-npm-token-secret-712`
- **Runbook contract:** `.claude/skills/human-exception-runbook/SKILL.md`
- **Authored:** 2026-09-27

This runbook is the human follow-up for the one step of issue #712 that repository automation cannot perform. It does not require, request, or display any secret or token value at any point. Do not paste a secret value, a token value, or an abbreviated token string into the issue, the feature folder, a terminal transcript you share, or any other record.

## Cue

Act on this runbook when the orchestrator has recorded an `exception` response for the issue #712 requirement "delete the unused GitHub Actions repository secret `NPM_TOKEN` from `drmoisan/drm-copilot` and revoke the corresponding npm access token on npmjs.com."

The step is unautomatable because no repository automation holds credentials for the GitHub repository settings or for the npmjs.com account that owns `@danmoisan/drm-copilot-mcp`.

Background:

- `.github/workflows/publish-mcp-npm.yml` publishes `@danmoisan/drm-copilot-mcp` through npm trusted publishing: the `publish` job declares `permissions: id-token: write` and runs `npm publish --provenance --access public`. It does not reference `NPM_TOKEN` or `NODE_AUTH_TOKEN`.
- Issue #528 (PR #701) corrected the README and marked `docs/engineering/npm-token-rotation.runbook.md` superseded. Its decision D4 deferred deletion of the secret to issue #712.
- The `NPM_TOKEN` secret and its npm access token are therefore unused credentials. Removing them reduces the number of long-lived publish credentials in existence.

## Prerequisites

- A GitHub account with **admin** access to `drmoisan/drm-copilot` (repository secrets can only be managed by a repository admin).
- A local clone of `drmoisan/drm-copilot` with `git` available.
- Optional, for the CLI path: GitHub CLI (`gh`) installed and authenticated (`gh auth status`) as an account with admin access to the repository.
- Access to the npmjs.com account that owns (or maintains) `@danmoisan/drm-copilot-mcp`, including any two-factor authentication device required to sign in and to manage tokens.
- Optional, for the CLI path on npm: `npm` installed and logged in to that account (`npm whoami` prints the expected user name).

### Pre-check A — no workflow references `NPM_TOKEN`

Run from the repository root. Check the default branch, because the tag-triggered publish runs from the tagged commit on `main`.

```
git fetch origin main
git grep -n -e NPM_TOKEN -e NODE_AUTH_TOKEN origin/main -- .github/
```

Expected result: no output and exit code `1` (no match). If any line is printed, stop: a workflow still references the token, and deleting the secret could break that workflow. Record the finding on issue #712 and do not continue.

References to `NPM_TOKEN` outside `.github/` (for example in the superseded `docs/engineering/npm-token-rotation.runbook.md`) are documentation only and do not block this runbook.

### Pre-check B — the npm trusted publisher configuration still lists this repository and workflow

1. Sign in to https://www.npmjs.com.
2. Open the package page for `@danmoisan/drm-copilot-mcp` (**Packages** > `@danmoisan/drm-copilot-mcp`).
3. Select the **Settings** tab, then locate the **Trusted publishing** section.
4. Confirm a GitHub Actions trusted publisher is configured with these values:
   - Organization or user: `drmoisan`
   - Repository: `drm-copilot`
   - Workflow filename: `publish-mcp-npm.yml`
   - Environment name: empty (the `publish` job declares no `environment:`)

Expected result: all four values match. If the trusted publisher is missing or any value differs, stop. Publishing currently depends on that configuration, and it must be corrected before any credential cleanup. Record the finding on issue #712 and do not continue.

Note: npm does not validate a trusted publisher configuration when it is saved, so a mismatch surfaces only at publish time. The visual check above is the available pre-check.

## Step-by-step Instructions

### Part 1 — Delete the `NPM_TOKEN` repository secret

Before deleting, record the date the secret was last set. This date is used in Part 2 to identify the matching npm token. The command below prints the name and the last-updated timestamp only; `gh` has no command that prints a secret value.

```
gh secret list --repo drmoisan/drm-copilot --app actions --json name,updatedAt
```

Note the `updatedAt` value for `NPM_TOKEN`. If `NPM_TOKEN` is not listed, the secret has already been deleted; skip to Part 2.

Delete the secret using one of the two paths below.

**Path A — GitHub CLI (preferred):**

1. Run:
   ```
   gh secret delete NPM_TOKEN --repo drmoisan/drm-copilot --app actions
   ```
2. Confirm the command completes without an error.

**Path B — GitHub web UI:**

1. Open https://github.com/drmoisan/drm-copilot.
2. Select the **Settings** tab.
3. In the sidebar, under **Security**, select **Secrets and variables**, then **Actions**.
4. Select the **Secrets** tab and locate `NPM_TOKEN` under **Repository secrets**.
5. Use the delete (trash-can) control on the `NPM_TOKEN` row, then confirm the removal in the dialog.

Note on Path B: the cited GitHub documentation describes steps 1 through 4. It does not describe the delete control in step 5; that control is labelled in the UI itself. If the control is not present as described, use Path A.

### Part 2 — Identify and revoke the matching npm access token

The token must be identified from metadata only. Do not attempt to view or compare token values.

1. Sign in to https://www.npmjs.com.
2. Select the profile picture in the upper-right corner, then select **Access Tokens**.
3. Review the token list and identify the token that was stored as `NPM_TOKEN`, using the metadata shown for each token:
   - **Name / description** — a name that refers to GitHub Actions, CI, publishing, `drm-copilot`, or `drm-copilot-mcp`.
   - **Creation date** — on or shortly before the `updatedAt` date recorded in Part 1.
   - **Type and scope** — a publish-capable token (automation, publish, or granular read-and-write) scoped to `@danmoisan/drm-copilot-mcp` or to all packages.
   - **Last-used date**, where shown — no use on or after the date the workflow moved to trusted publishing. Publishing through OIDC does not use a stored token, so a token that remains the `NPM_TOKEN` credential is expected to show no recent use.
4. Apply this decision rule before revoking:
   - Exactly one token matches: continue to step 5.
   - A candidate token shows a last-used date after the move to trusted publishing: stop. The token is in use elsewhere and is not the unused `NPM_TOKEN` credential, or another system depends on it. Record the finding on issue #712 without recording any token value.
   - No token or more than one token matches, and the match cannot be resolved from the metadata above: stop and record the ambiguity on issue #712. Do not revoke tokens by guesswork, because revoking a token that another system uses would break that system.
5. Revoke the identified token by selecting the **×** control next to it (or select it and choose **Delete Selected Tokens**), then confirm the deletion when prompted.

Alternative CLI path for step 5 (requires `npm` logged in to the owning account):

1. Run `npm token list`. The output shows a token ID, an abbreviated token string, and metadata for each token. Do not copy or share the abbreviated token string.
2. Using the same identification rule as step 3, select the token by its **ID**.
3. Run `npm token revoke <token-id>`, substituting the ID. The npm website documentation also names this operation `npm token delete`; either form accepts the token ID.

## Verification

1. Confirm the secret is gone:
   ```
   gh secret list --repo drmoisan/drm-copilot --app actions
   ```
   Expected result: `NPM_TOKEN` is not listed. Alternatively, reload **Settings** > **Secrets and variables** > **Actions** > **Secrets** and confirm `NPM_TOKEN` no longer appears under **Repository secrets**.
2. Confirm the npm token is revoked: reload the npmjs.com **Access Tokens** page, or run `npm token list`, and confirm the token identified in Part 2 is no longer listed. npm's website documentation states revocation can take up to one hour to take effect; if the token is still listed, re-check after that interval.
3. Optional — confirm publishing still works through OIDC: on the next release, confirm the tag-triggered run of **Publish MCP Server to npm** (`publish-mcp-npm.yml`) succeeds, including the step "Verify the published version resolves on the registry." Do not push a tag solely to perform this check; a publish consumes a version number.

### Rollback

No rollback is needed for the deletion. Publishing does not depend on `NPM_TOKEN` or on the revoked npm token: the workflow authenticates through npm trusted publishing (OIDC). Do not recreate the secret or a replacement long-lived token as a remedy for a later publish failure.

If a publish fails after this runbook is completed, the cause is the OIDC or trusted-publisher configuration, not the removed token. Investigate these in order:

- The npm **Trusted publishing** entry for `@danmoisan/drm-copilot-mcp` (owner `drmoisan`, repository `drm-copilot`, workflow filename `publish-mcp-npm.yml`, no environment).
- The `publish` job's `permissions: id-token: write` in `.github/workflows/publish-mcp-npm.yml`.
- The npm CLI version installed by the workflow (trusted publishing requires a recent npm CLI; the workflow installs `npm@11.18.0`).

### Recording completion

1. Add a comment to issue #712 stating that the `NPM_TOKEN` repository secret was deleted and the corresponding npm access token was revoked, with the completion date and the verification results from steps 1 and 2 above. Do not include any secret value, token value, abbreviated token string, or token ID in the comment.
2. Update the pending evidence record `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md`: change `Status: pending` to `Status: complete`, and add the completion date and a link to the issue #712 comment from step 1. Do not change acceptance criterion AC4 in `spec.md`; AC4 was satisfied when the human action was recorded as pending (spec decision D5), and completion is recorded only by this follow-up note and the issue comment. Do not record any secret value, token value, abbreviated token string, or token ID in the record. This update may be made by the human or requested from an agent with a link to the comment.

## Source and Citation

- Pre-check B, trusted publisher location and fields (third-party UI navigation, web-sourced): npm Docs — "Trusted publishing for npm packages." Source URL: https://docs.npmjs.com/trusted-publishers — updated_at: 2026-09-27 (capture date; the page shows no revision date).
- Part 1, Path A and Part 1 date capture (CLI): GitHub CLI manual — "gh secret delete." Source URL: https://cli.github.com/manual/gh_secret_delete — updated_at: 2026-09-27 (capture date).
- Part 1 date capture and Verification step 1 (CLI): GitHub CLI manual — "gh secret list" (documents the `name` and `updatedAt` JSON fields). Source URL: https://cli.github.com/manual/gh_secret_list — updated_at: 2026-09-27 (capture date).
- Part 1, Path B, steps 1 through 4 (third-party UI navigation, web-sourced): GitHub Docs — "Using secrets in GitHub Actions." Source URL: https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets — updated_at: 2026-09-27 (capture date). The page does not document the delete control in step 5.
- Part 2, website revocation and the up-to-one-hour delay (third-party UI navigation, web-sourced): npm Docs — "Revoking access tokens." Source URL: https://docs.npmjs.com/revoking-access-tokens — updated_at: 2025-11-05 (page revision date; captured 2026-09-27).
- Part 2 CLI alternative and Verification step 2 (CLI): npm Docs — "npm token" (npm v11 CLI). Source URL: https://docs.npmjs.com/cli/v11/commands/npm-token — updated_at: 2026-09-27 (capture date).
- Repository facts (workflow authentication, absence of `NPM_TOKEN` and `NODE_AUTH_TOKEN` references under `.github/`): `.github/workflows/publish-mcp-npm.yml` read on branch `bug/unused-npm-token-secret-712` — updated_at: 2026-09-27.

Sourcing note: no MCP documentation-retrieval tool is available in this repository, so the MCP-first step of the sourcing rule could not be applied. All third-party UI steps were sourced from the vendors' current published documentation (web-second), fetched on 2026-09-27. Items not covered by the fetched documentation (the GitHub delete control label and the exact metadata columns on the npm Access Tokens page) are stated as such rather than asserted.
