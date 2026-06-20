# Runbook: Provision VSCE_PAT for CI Marketplace Publishing

Issue: #214

## Cue

Act when the orchestrator has recorded an `exception` for the `VSCE_PAT` requirement — that is, when the new `.github/workflows/publish-extension.yml` workflow is merged but the GitHub Actions repository secret `VSCE_PAT` does not yet exist. Until this runbook is completed, a `push` of a `v*` tag will trigger the workflow but the `vsce publish` step will fail (an absent secret resolves to an empty string and authentication fails).

## Prerequisites

- You are the Marketplace publisher owner for publisher id `DanMoisan` (the value of `publisher` in `extensions/drm-copilot/package.json`).
- You can sign in to Azure DevOps at `https://dev.azure.com` with the account that owns or co-owns the `DanMoisan` publisher.
- You have admin access to the GitHub repository `drmoisan/drm-copilot` (required to create repository secrets).
- `@vscode/vsce` is available locally if you choose to verify the token with `vsce login` before storing it.

## Step-by-step Instructions

### Part A — Create the Azure DevOps Personal Access Token

1. Sign in to `https://dev.azure.com/{your-organization}`.
2. Select the user-settings gear in the top-right, then select **Personal access tokens**.
3. Select **New Token**.
4. Set **Organization** to **All accessible organizations**. Selecting a single specific organization is the common misconfiguration that causes `vsce` publish authentication to fail.
5. Set an expiration. Use a bounded expiry (for example 1 year) and record the expiry date for rotation. Note: the VS Code documentation states global PATs retire on **December 1, 2026**; plan rotation accordingly.
6. Under **Scopes**, select **Custom defined**, choose **Show all scopes**, locate **Marketplace**, and enable **Manage**.
7. Select **Create**. The token value is displayed only once. Copy it immediately to a secure temporary location.

### Part B — (Optional) verify the token locally

8. Run `vsce login DanMoisan` and paste the token when prompted. A successful token reports: "The Personal Access Token verification succeeded for the publisher 'DanMoisan'."

### Part C — Store the token as a GitHub Actions secret

9. In the GitHub repository, go to **Settings** > **Secrets and variables** > **Actions**.
10. On the **Secrets** tab, select **New repository secret**.
11. Set **Name** to `VSCE_PAT` (uppercase; alphanumeric and underscores only; must not start with `GITHUB_` or a digit).
12. Paste the token value into **Secret**.
13. Select **Add secret**.

## Verification

- The optional local check (Part B) prints the publisher-verification success message.
- In GitHub, `Settings > Secrets and variables > Actions` lists a secret named `VSCE_PAT` with an "Updated" timestamp matching now. The value is not displayed (write-only), which is expected.
- End-to-end: after a `v<version>` tag is pushed against a merged commit, the `publish-extension.yml` run completes the `vsce publish` step without an authentication error, and the new version appears on the Marketplace listing for `DanMoisan.drm-copilot`.

## Source and Citation

- VS Code — Publishing Extensions (PAT creation, "All accessible organizations" requirement, Marketplace > Manage scope, global-PAT retirement date): `https://code.visualstudio.com/api/working-with-extensions/publishing-extension` — captured 2026-06-19.
- Azure DevOps — Use personal access tokens to authenticate: `https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate` — captured 2026-06-19.
- GitHub Docs — Using secrets in GitHub Actions (secret creation navigation and naming rules): `https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions` — captured 2026-06-19.
