# Jest Threshold Entries ([P9-T5])

Timestamp: 2026-09-26T22-31

Command: `grep -c -F -e '"./src/lib/executable-resolver.ts": {' extensions/drm-copilot/jest.config.cjs`

EXIT_CODE: 0

Command: `grep -n -A 3 -F -e '"./src/lib/executable-resolver.ts": {' extensions/drm-copilot/jest.config.cjs`

EXIT_CODE: 0

Command: `grep -c -F -e '"./src/lib/pr-context/render-pr-helpers.ts": {' extensions/drm-copilot/jest.config.cjs`

EXIT_CODE: 0

Command: `grep -n -A 3 -F -e '"./src/lib/pr-context/render-pr-helpers.ts": {' extensions/drm-copilot/jest.config.cjs`

EXIT_CODE: 0

Command: `grep -c -F -e '"./src/lib/pr-context/autoclose.ts": {' extensions/drm-copilot/jest.config.cjs` (run because `<TS_BUILDER_FILE>` is `autoclose.ts`)

EXIT_CODE: 0

Command: `grep -n -A 3 -F -e '"./src/lib/pr-context/autoclose.ts": {' extensions/drm-copilot/jest.config.cjs`

EXIT_CODE: 0

Output Summary:
- executable-resolver count: `1`; entry: `69:    "./src/lib/executable-resolver.ts": {` / `70-      lines: 85,` / `71-      branches: 75,` / `72-    },` (added by #588).
- render-pr-helpers count: `1`; entry: `63:    "./src/lib/pr-context/render-pr-helpers.ts": {` / `64-      lines: 85,` / `65-      branches: 75,` / `66-    },` (supplied by #622).
- autoclose count: `1`; entry: `47:    "./src/lib/pr-context/autoclose.ts": {` / `48-      lines: 85,` / `49-      branches: 75,` / `50-    },` (supplied by #622).
- Every `grep -c` printed `1`; every `grep -n -A 3` output contains `lines: 85` and `branches: 75`. Acceptance met.
