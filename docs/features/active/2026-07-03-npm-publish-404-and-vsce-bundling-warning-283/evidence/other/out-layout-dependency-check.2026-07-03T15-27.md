# Out-Layout Dependency Check

Timestamp: 2026-07-03T15-27

## Search Scope and Commands

1. `Grep pattern="out/[a-zA-Z0-9_-]+\.js" path="extensions/drm-copilot/test"` (equivalent to `grep -rn -E "out/[a-zA-Z0-9_-]+\.js" extensions/drm-copilot/test`)
   - Result: No matches found.
2. `Grep pattern="out/" path="extensions/drm-copilot/jest.config.cjs"` (equivalent to `grep -n "out/" extensions/drm-copilot/jest.config.cjs`)
   - Result: one match — `testPathIgnorePatterns: ["/node_modules/", "/out/"]`. This is a directory-level exclusion, not a dependency on individual per-file names; it excludes the entire `out/` tree from test discovery regardless of how many files it contains.
3. `Grep pattern="out/" path=".github/workflows/publish-extension.yml"` (equivalent to `grep -n "out/" .github/workflows/publish-extension.yml`)
   - Result: No matches found. The workflow invokes `npm --prefix extensions/drm-copilot run compile` generically and does not reference any individual `out/*.js` filename.
4. Manual read of `extensions/drm-copilot/.vscodeignore`:
   - Contains directory/glob-level exclusions (`src/**`, `test/**`, `*.ts`, etc.) and does not name any individual `out/<name>.js` file. It does not exclude or reference `out/` contents by name, so it packages whatever `out/` produces (whether 128 files or the new 2-file bundled layout) without modification.

## Result

None found. No file under `extensions/drm-copilot/test/**`, `extensions/drm-copilot/jest.config.cjs`, `.github/workflows/publish-extension.yml`, or `extensions/drm-copilot/.vscodeignore` depends on the previous one-file-per-source-file `out/*.js` layout. No changes were needed to any of these four files.
