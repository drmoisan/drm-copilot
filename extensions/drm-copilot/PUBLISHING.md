# Publishing the drm-copilot Extension

This runbook covers building, validating, and publishing the
`extensions/drm-copilot/` extension to the VS Code Marketplace.

All operations are wrapped by `scripts/powershell/Publish-DrmCopilotExtension.ps1`.
Run the script from the repository root.

## One-Time Setup

These steps run once per machine. Skip if already done.

### 1. Microsoft account and Azure DevOps organization

Sign in at <https://dev.azure.com> with a Microsoft account. Create an
organization if you do not already have one. The organization is only used
to mint a Personal Access Token (PAT); no code needs to live in it.

### 2. Personal Access Token (PAT)

1. In Azure DevOps, open **User settings -> Personal access tokens -> New Token**.
2. Set **Organization** to **All accessible organizations**.
3. Set **Scopes** to **Custom defined**, and under **Marketplace**, select **Manage**.
4. Set an expiration (max 1 year; rotate before it expires).
5. Copy the token value once. It cannot be retrieved later.

### 3. Marketplace publisher

1. Go to <https://marketplace.visualstudio.com/manage>.
2. Sign in with the same Microsoft account.
3. Click **Create publisher**. Use Publisher ID `DanMoisan`. The Publisher ID
   must match the `publisher` field in `extensions/drm-copilot/package.json`.

### 4. Authenticate vsce

Install vsce globally and log in:

```powershell
npm install -g @vscode/vsce
vsce login DanMoisan
# Paste the PAT when prompted.
```

The PAT is stored in the OS credential store. Subsequent publishes do not
require re-entering it until the PAT expires.

## Publish Workflow

Three modes. Always run earlier modes first.

### Mode 1: Dry run

Validate the manifest and list files that would ship. No build, no package,
no publish.

```powershell
pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -DryRun
```

Use this to confirm:

- All required manifest fields are present.
- `vsce ls` shows only intended files (no `.git/`, `.venv/`, Python wheels,
  test fixtures, agent runtime files, etc.).
- File count is reasonable (a few hundred for the current extension).

### Mode 2: Package locally

Validate, build, and produce a timestamped `.vsix` under `artifacts/vsix/`.
No publish.

```powershell
pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -Package
```

Output is at `artifacts/vsix/drm-copilot-<version>-<timestamp>.vsix`.

Install locally for testing:

```powershell
code --install-extension "artifacts/vsix/drm-copilot-0.0.1-20260502-101530.vsix"
# Or for VS Code Insiders:
code-insiders --install-extension "artifacts/vsix/drm-copilot-0.0.1-20260502-101530.vsix"
```

Verify the extension loads, commands appear, and the MCP provider registers
in a real VS Code window before publishing.

### Mode 3: Publish to Marketplace

Validate, build, package, and publish. Requires confirmation by typing the
version number when prompted.

```powershell
pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -Publish
```

Optional flags:

- `-VersionBump patch` (or `minor`, `major`) bumps `package.json` version
  before packaging. Versions must increase; you cannot republish an existing
  version.
- `-Tag` creates a `v<version>` git tag after a successful publish. Push the
  tag manually with `git push origin v<version>`.

Example: bump patch version, publish, and tag:

```powershell
pwsh ./scripts/powershell/Publish-DrmCopilotExtension.ps1 -Publish -VersionBump patch -Tag
```

## Important Notes

- **Marketplace versions are immutable.** A published version cannot be
  republished or deleted, only unpublished. Confirm the version is correct
  before invoking `-Publish`.
- **The script does not push the version-bump commit or the git tag.** After
  publishing, commit the bumped `package.json` and push the tag manually:
  ```powershell
  git add extensions/drm-copilot/package.json extensions/drm-copilot/CHANGELOG.md
  git commit -m "chore(drm-copilot): release v0.0.2"
  git push origin main
  git push origin v0.0.2
  ```
- **The script never runs `vsce publish` automatically.** A confirmation
  prompt requires typing the version number.

## Troubleshooting

### "vsce is not on PATH"

```powershell
npm install -g @vscode/vsce
```

### "Manifest is missing required fields"

The script enforces presence of `name`, `version`, `publisher`,
`engines.vscode`, `main`, `displayName`, and `description`. Add the missing
field to `extensions/drm-copilot/package.json` and re-run.

### "vsce ls flagged potentially unwanted files"

Update `extensions/drm-copilot/.vscodeignore` to exclude the flagged paths,
then re-run `-DryRun` to confirm.

### `secretlint` crash during publish

Indicates a file larger than ~512 MB is being staged. Review `vsce ls` for
unexpectedly large content. The `.vscodeignore` should be excluding it.

### "Both a .vscodeignore file and a 'files' property in package.json were found"

Newer `vsce` versions reject both. Use only `.vscodeignore`. Remove any
`files` array from the extension's `package.json`.

### Authentication failure

PAT may have expired. Mint a new one (see One-Time Setup step 2) and run
`vsce login DanMoisan` again.

## CI/CD (Future)

A GitHub Actions workflow can automate publishing on tag push. Create
`.github/workflows/publish-extension.yml` that:

1. Triggers on push of tags matching `v*`.
2. Restores Node and runs `npm install` in `extensions/drm-copilot/`.
3. Runs `npm run compile`.
4. Calls `vsce publish --pat ${{ secrets.VSCE_PAT }}`.

The PAT is stored as a repository secret named `VSCE_PAT`. This is not yet
implemented; the manual script is the current workflow.
