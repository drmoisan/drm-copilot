# publish-mcp-server-to-npm Remediation - Plan

- **Issue:** #173
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-05-07T03-30
- **Status:** Remediation Required
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- GitHub Actions Policy: [`.github/instructions/github-actions.instructions.md`](../../../../.github/instructions/github-actions.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Remediation Source

- Remediation inputs: `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/remediation-inputs.2026-05-07T03-30.md`
- Triggering audit: `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/feature-audit.2026-05-07T03-30.md`
- Failing criterion: AC6 — README.md MCP client config snippet missing `cwd` field

## Scope

This remediation addresses one mandatory fix and one recommended fix identified in the post-implementation review of feature #173.

- **Mandatory (Fix 1):** Add `"cwd"` field to the MCP client configuration snippet in `packages/mcp-server/README.md`.
- **Recommended (Fix 2):** Add explicit `format: "cjs"` to the esbuild build call in `packages/mcp-server/esbuild-mcp-server.cjs`.

No TypeScript source files are modified. No new tests are required. Toolchain regression checks are required.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context Verification

- [x] [P0-T1] Verify current state of `packages/mcp-server/README.md` MCP config snippet to confirm `cwd` is absent before making changes.
  - Command: `grep -F '"cwd"' packages/mcp-server/README.md`
  - Acceptance: Command exits with code 1 (no match), confirming the field is absent and the fix is still required.

### Phase 1 — Fix 1: README.md `cwd` Addition (Mandatory)

- [x] [P1-T1] Update the MCP Client Configuration JSON snippet in `packages/mcp-server/README.md` to add `"cwd": "/absolute/path/to/your/workspace"` as a third field in the `drm-copilot` server entry, followed by a prose note explaining that `cwd` must be set to the consumer's target workspace root.
  - File: `packages/mcp-server/README.md`
  - Location: `## MCP Client Configuration` section, JSON code block
  - Required result: The JSON block contains `"command"`, `"args"`, and `"cwd"` fields. The `cwd` value is a clear placeholder. A sentence below the block states that `cwd` must point to the consumer's target workspace root.
  - Acceptance: `grep -F '"cwd"' packages/mcp-server/README.md` exits with code 0; the JSON block is syntactically valid.

- [x] [P1-T2] Verify the README.md MCP config snippet after the edit matches the canonical shape from `spec.md` API/CLI Surface section:
  ```json
  {
    "mcpServers": {
      "drm-copilot": {
        "command": "npx",
        "args": ["-y", "@danmoisan/drm-copilot-mcp"],
        "cwd": "/absolute/path/to/your/workspace"
      }
    }
  }
  ```
  - Acceptance: Manual inspection of `packages/mcp-server/README.md` lines 18–28 confirms all three fields are present and the JSON is valid.

### Phase 2 — Fix 2: esbuild `format` Explicit Declaration (Recommended)

- [x] [P2-T1] Add `format: "cjs"` to the `esbuild.build({...})` call in `packages/mcp-server/esbuild-mcp-server.cjs`, placed after `target: "node18"`.
  - File: `packages/mcp-server/esbuild-mcp-server.cjs`
  - Acceptance: `grep -F '"cjs"' packages/mcp-server/esbuild-mcp-server.cjs` exits with code 0.

- [x] [P2-T2] Verify the build still produces `out/mcp-server.js` with a `#!/usr/bin/env node` first line after adding the `format` field.
  - Command: `npm --prefix packages/mcp-server run build`
  - Acceptance: Command exits with code 0; `Get-Content packages/mcp-server/out/mcp-server.js -TotalCount 1` outputs `#!/usr/bin/env node`.

### Phase 3 — Toolchain Regression Loop

> Run all steps in this phase in order. If any step exits non-zero, fix the reported issue and restart from P3-T1.

- [x] [P3-T1] Run Prettier format on `extensions/drm-copilot/`.
  - Command: `npm --prefix extensions/drm-copilot run format`
  - Acceptance: EXIT_CODE 0; no files reformatted.

- [x] [P3-T2] Run ESLint on `extensions/drm-copilot/`.
  - Command: `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: EXIT_CODE 0; no errors or warnings.

- [x] [P3-T3] Run TypeScript type check on `extensions/drm-copilot/`.
  - Command: `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: EXIT_CODE 0; no type errors.

- [x] [P3-T4] Run Jest tests on `extensions/drm-copilot/` and confirm coverage is unchanged.
  - Command: `npm --prefix extensions/drm-copilot run test`
  - Acceptance: EXIT_CODE 0; all 348 tests pass; statement coverage ≥ 95.5%.

### Phase 4 — actionlint Verification

- [x] [P4-T1] Run `actionlint` against `.github/workflows/publish-mcp-npm.yml` to close the UNVERIFIED gap identified in `policy-audit.2026-05-07T03-30.md` section G1.
  - Command: `scripts/dev-tools/run-actionlint.ps1` (or `actionlint .github/workflows/publish-mcp-npm.yml` directly)
  - Acceptance: EXIT_CODE 0; no errors reported for `publish-mcp-npm.yml`.

### Phase 5 — AC6 Check-off

- [x] [P5-T1] After Fix 1 is verified (P1-T1, P1-T2) and the toolchain passes (P3-T1 through P3-T4), check off AC6 in `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/user-story.md`.
  - Change: `- [ ] AC6.` → `- [x] AC6.`
  - Acceptance: `grep -F '- [x] AC6.' docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/user-story.md` exits with code 0.

## Test Plan

- Unit: No new TypeScript source files. Existing Jest suite (348 tests) must continue to pass (P3-T4).
- Integration: Not required for this remediation; tarball re-generation is not necessary as the README change does not affect build artifacts.
- Manual/CLI: Not required.
- Coverage evidence:
  - Post-remediation Jest: record exit code and coverage summary in `artifacts/evidence/post-change/jest-qc-remediation.md`.

## Open Questions / Notes

- The README.md is a documentation file. Prettier does not format Markdown in this repo (the format command targets TypeScript/JS files). No Prettier reformatting is expected for the README change.
- The `user-story.md` AC6 item must remain unchecked until Fix 1 is implemented and verified (P5-T1 is the check-off gate).
- `issue.md` already has AC6 marked `[x]`; this pre-existing check is inconsistent with the review finding and will remain as-is (issue.md is not the authoritative source for full-feature work mode).
