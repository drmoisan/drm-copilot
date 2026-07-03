# Human-Exception Runbook — Rotate the `NPM_TOKEN` GitHub Actions Secret for `@danmoisan/drm-copilot-mcp`

Contract-conformant per `.claude/skills/human-exception-runbook/SKILL.md`.

## Cue

Act on this runbook when the orchestrator records an `exception` response for the requirement "restore `npm publish` authorization for `@danmoisan/drm-copilot-mcp`." `.github/workflows/publish-mcp-npm.yml`'s `Publish to npm` step has failed with `npm error code E404 - PUT https://registry.npmjs.org/@danmoisan%2fdrm-copilot-mcp - Not found` on every tagged release since `mcp-server-v1.0.2` (versions `1.0.2`, `1.0.3`, `1.0.4`), while `1.0.0` and `1.0.1` published successfully. `git diff` between the last successful tag (`5e53294`) and the first failing tag (`e52e165`) shows only a `package.json` version bump — no workflow, code, or publish-configuration change — which rules out an in-repo cause and points to the `NPM_TOKEN` GitHub Actions secret having lost publish authorization on the npm side (rotation, expiry, or a granular token missing per-package publish permission) after `2026-06-27T19:28:51Z`. No repository automation has credentials to the npmjs.com account or the GitHub repository Settings UI, so this step is a permitted exception rather than a `scope_change`.

## Prerequisites

- An npmjs.com account that is an owner or has publish rights on the `@danmoisan/drm-copilot-mcp` package (npm scope `@danmoisan`).
- Repository admin access on `github.com/drmoisan/drm-copilot` (required to update Actions secrets).
- Ability to sign in to https://www.npmjs.com and https://github.com.

## Step-by-step Instructions

1. Sign in to https://www.npmjs.com with the account that owns/publishes `@danmoisan/drm-copilot-mcp`.
2. Click the profile picture in the upper right, then select **Access Tokens**.
3. Review the existing token used by `NPM_TOKEN`: check its expiration date (granular tokens show an expiration; classic tokens do not) and confirm it has not already expired or been revoked. If a granular token is listed, open it and confirm its **Packages and scopes** permissions explicitly include `@danmoisan/drm-copilot-mcp` with **Read and write** (publish) access — a granular token that omits this package returns a 404-style "not found" on publish rather than a 403, which matches the observed failure.
4. If the token is expired, revoked, or missing the package permission, click **Generate New Token** and select **Granular Access Token** (or **Classic Token** > **Automation**, if the account still supports classic tokens for CI use).
5. Configure the new token: give it a descriptive name (for example `drm-copilot-mcp-ci`), set an expiration date, and under **Packages and scopes**, select **Only select packages and scopes**, then choose `@danmoisan/drm-copilot-mcp` with **Read and write** permission.
6. Review the summary and click **Generate Token**. Copy the token value immediately — npm displays it only once and later only shows the first/last four characters.
7. Navigate to https://github.com/drmoisan/drm-copilot, click **Settings**.
8. In the left sidebar, under **Security**, click **Secrets and variables**, then **Actions**.
9. Confirm the **Secrets** tab is selected, locate `NPM_TOKEN` under **Repository secrets**, and click its name/pencil icon to open the update dialog.
10. Paste the new token value into the **Value** field and click **Update secret**.

## Verification

- On npmjs.com, under **Access Tokens**, the new token is listed with a non-expired date and (for granular tokens) `@danmoisan/drm-copilot-mcp` listed under its package permissions.
- On github.com, the `NPM_TOKEN` row under **Repository secrets** shows an updated "Updated" timestamp matching the time of step 10.
- Re-run `.github/workflows/publish-mcp-npm.yml` via `workflow_dispatch` (or push a new `mcp-server-v*` tag) and confirm the `Publish to npm` step completes without an `E404` error and the new version appears at https://www.npmjs.com/package/@danmoisan/drm-copilot-mcp.

## Source and Citation

- npm access-token creation and review navigation (third-party UI, web-sourced — no MCP documentation source was available in this session): npm Docs — "Creating and viewing access tokens." Source URL: https://docs.npmjs.com/creating-and-viewing-access-tokens — updated_at: 2026-07-03.
- GitHub Actions repository secret update navigation (third-party UI, web-sourced — no MCP documentation source was available in this session): GitHub Docs — "Using secrets in GitHub Actions." Source URL: https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions — updated_at: 2026-07-03.
- Granular-token per-package permission requirement (root-cause corroboration): npm Docs — "Trusted publishers for npm packages." Source URL: https://docs.npmjs.com/trusted-publishers — updated_at: 2026-07-03.
