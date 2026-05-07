# Remediation Inputs: publish-mcp-server-to-npm (#173)

- **Timestamp:** 2026-05-07T03-30
- **Feature Folder:** `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173`
- **Triggering Audit:** `feature-audit.2026-05-07T03-30.md`
- **Branch:** `feature/publish-mcp-server-to-npm-173`
- **Remediation Scope:** Single targeted fix to `packages/mcp-server/README.md`.

---

## Required Fixes

### Fix 1 — Add `cwd` to README.md MCP client configuration snippet

**File:** `packages/mcp-server/README.md`  
**Section:** MCP Client Configuration  
**Severity:** Major  
**AC blocked:** AC6

**Problem:**  
The MCP client configuration JSON snippet in the README.md does not include a `cwd` field. The spec (`spec.md` API/CLI Surface section, lines 78–87) and user-story (`user-story.md` Scenario: First-Time Setup, lines 34–41) both specify that the published snippet must include `"cwd": "/absolute/path/to/destination/workspace"`. Without this field, consumers following the documented configuration will not set `cwd`, and workspace-relative MCP tool calls will resolve against the wrong directory.

**Expected behavior after fix:**  
The MCP client configuration JSON block in `packages/mcp-server/README.md` must include all three fields: `command`, `args`, and `cwd`. The `cwd` value should be a placeholder (e.g., `"/absolute/path/to/your/workspace"`) with a prose note immediately following or within the block explaining that the value must be set to the consumer's target workspace root.

**Verification command:**  
```
grep -F '"cwd"' packages/mcp-server/README.md
```
Exit code must be 0.

**Canonical reference:**  
`spec.md` lines 78–87 (API/CLI Surface):
```json
{
  "mcpServers": {
    "drm-copilot": {
      "command": "npx",
      "args": ["-y", "@danmoisan/drm-copilot-mcp"],
      "cwd": "/absolute/path/to/destination/workspace"
    }
  }
}
```

---

### Fix 2 — (Optional, recommended) Add explicit `format: "cjs"` to esbuild config

**File:** `packages/mcp-server/esbuild-mcp-server.cjs`  
**Section:** `esbuild.build()` call  
**Severity:** Minor  
**AC blocked:** None  

**Problem:**  
`format` is not explicitly set in the esbuild config. The default for `platform: "node"` is CJS, which matches `"type": "commonjs"` in package.json. The missing explicit declaration creates a maintenance liability.

**Expected behavior after fix:**  
`format: "cjs"` is present in the `esbuild.build({...})` call.

**Verification command:**  
```
grep -F '"cjs"' packages/mcp-server/esbuild-mcp-server.cjs
```
Exit code must be 0.

---

## Do Not Do

- Do not change the MCP config snippet structure in any way other than adding `cwd`.
- Do not change the `command` or `args` values in the snippet.
- Do not add runtime code changes to `extensions/drm-copilot/src/mcp-server.ts` or any other TypeScript source file as part of this remediation.
- Do not alter any CI workflow triggers, job structures, or secrets references.
- Do not refactor `esbuild-mcp-server.cjs` beyond adding the `format: "cjs"` field.
- Do not re-run `npm pack` unless the README change requires tarball verification.
- Do not modify any policy or instruction files under `.github/instructions/` or `.github/skills/`.
- Do not batch-check AC6 in `user-story.md` until the fix is implemented and verified.

---

## Toolchain Verification After Remediation

After applying Fix 1 (and optionally Fix 2), the following commands must pass before re-review:

1. `grep -F '"cwd"' packages/mcp-server/README.md` — exits 0
2. `npm --prefix extensions/drm-copilot run format` — exits 0, no files changed
3. `npm --prefix extensions/drm-copilot run lint` — exits 0, no errors
4. `npm --prefix extensions/drm-copilot run typecheck` — exits 0, no errors
5. `npm --prefix extensions/drm-copilot run test` — exits 0, all 348 tests pass
6. `scripts/dev-tools/run-actionlint.ps1` (or CI actionlint job) — exits 0 for `.github/workflows/publish-mcp-npm.yml`

Coverage must remain at or above 95.5% lines.

---

## Context

- Base audit artifacts: `policy-audit.2026-05-07T03-30.md`, `code-review.2026-05-07T03-30.md`, `feature-audit.2026-05-07T03-30.md`
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`
- Baseline evidence: `artifacts/evidence/baseline/jest-baseline.md`
- Post-change evidence: `artifacts/evidence/post-change/`
