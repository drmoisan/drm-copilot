# TypeScript Formatting Baseline

Timestamp: `2026-08-10T22-58`

Exact command: `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`

Exact command exit code: `2`

Exact command output summary: Prettier reported that matched files used the configured style, then reported `No files matching the pattern were found: "test/**/*.ts"`. `npm --prefix` selected the extension dependency but retained the repository-root process working directory.

Changed-file count: `0`

Corrective scoped command: `npm exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` with working directory `extensions/drm-copilot`.

Corrective exit code: `0`

Corrective output summary: All matched extension files use Prettier code style.

Corrective changed-file count: `0`

No formatter mutation occurred, so no baseline-loop restart was required. The exact-command working-directory defect remains explicit baseline evidence; later scoped TypeScript checks run from the extension directory or use extension-qualified globs.
