# Recreating Your Codespace with Correct Configuration

If a Codespace starts from GitHub's universal image, select this repository's Codespaces configuration explicitly when rebuilding or recreating it.

## Example of an outdated environment
- ⚠️ OS: Ubuntu 24.04 (expected: Debian Bookworm)
- ⚠️ Python: 3.12.1 (expected: 3.13.17)
- ❌ PowerShell: Not installed
- ❌ Shell tools: Missing shellcheck, shfmt, bashdb, actionlint

## Solution: Create New Codespace with Manual Config Selection

### Why Manual Selection?

To prevent VS Code from defaulting to the Codespaces config when opening locally, we keep configs as non-standard filenames that require explicit selection:
- `.devcontainer/codespaces/devcontainer.json` (not at standard location)
- `.devcontainer/local/devcontainer.json` (for local development)

This means **you must manually select** the Codespaces config when creating.

### Step-by-Step Instructions

1. **Delete current Codespace**
   - GitHub.com → Code → Codespaces
   - Find your Codespace → **...** → **Delete**

2. **Create new Codespace with manual selection:**
   - GitHub.com → Repository → **Code** → **Codespaces** tab
   - Click **... (three dots)** next to "Create codespace"
   - Select **"Configure and create codespace"**
   
3. **Select configuration:**
   - In the panel, find **"Dev container configuration"**
   - Click to expand the dropdown
   - Select: **`.devcontainer/codespaces/devcontainer.json`**
   
4. **Create:**
   - Leave other settings as default
   - Click **"Create codespace"**
   - Wait ~5-10 minutes for build

5. **Verify:**
   ```bash
   bash .devcontainer/verify-container.sh
   ```

### Alternative: GitHub CLI Method

```bash
# Delete old Codespace
gh codespace list
gh codespace delete --codespace <name-of-wrong-codespace>

# Create new with explicit config path
gh codespace create \
  --repo drmoisan/drm-copilot \
  --branch main \
  --devcontainer-path .devcontainer/codespaces/devcontainer.json
```

## After Rebuild Checklist

Run these commands to verify everything works:

```bash
# 1. Verify environment
bash .devcontainer/verify-container.sh

# 2. Check Python tools
python --version         # Should be 3.13.17
poetry --version         # Should be 2.3.2
pwsh --version          # Should be PowerShell 7.6.9

# 3. Verify project setup
poetry install          # Install dependencies
poetry run pytest       # Run tests

# 4. Verify PowerShell
pwsh -Command "Get-Module -ListAvailable PSScriptAnalyzer, Pester"

# 5. Test QC tools
poetry run black --version
poetry run ruff --version
poetry run pyright --version
```

## Expected Output After Rebuild

The verification script should show:
```
[OK] .devcontainer/codespaces/devcontainer.json
[OK] Workspace virtual environment Python 3.13.17
All devcontainer checks passed.
```

And you should have:
- Debian Bookworm OS
- Python 3.13.17
- PowerShell 7.6.9
- Poetry 2.3.2
- All shell tools (shellcheck, shfmt, bashdb, actionlint)

## Troubleshooting

### Rebuild doesn't fix it
- Try **Option 2** (delete and recreate)
- Ensure you're on a branch with the latest `.devcontainer/codespaces/devcontainer.json`

### Build fails
- Check Codespace logs in the terminal
- See `.devcontainer/TROUBLESHOOTING.md`
- Report issue with build logs

### Still shows wrong config
- Verify `.devcontainer/codespaces/devcontainer.json` exists and is not disabled
- Check file points to `codespaces/Dockerfile`
- Confirm you're in a Codespace (not local Docker)

## Why This Happened

A default Codespace can use the universal image when the repository configuration is not selected. This repository keeps both configurations in subdirectories; choose `.devcontainer/codespaces/devcontainer.json` for Codespaces and `.devcontainer/local/devcontainer.json` for local Docker. Neither requires creating a second root-level configuration.
