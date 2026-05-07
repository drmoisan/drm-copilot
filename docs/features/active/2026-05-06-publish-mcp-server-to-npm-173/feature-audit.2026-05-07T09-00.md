# Feature Audit: publish-mcp-server-to-npm (#173) — Post-Remediation Pass 1

---

**Audit Date:** 2026-05-07
**Feature Folder:** `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173`
**Base Branch:** `chore/publish-to-marketplace`
**Head Branch:** `feature/publish-mcp-server-to-npm-173` (commit `3e81bb9b`)
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `chore/publish-to-marketplace` (commit `a852089b13e0602950c8f3f0fc685afd669e348a`)
- **Head branch/commit:** `feature/publish-mcp-server-to-npm-173` (commit `3e81bb9bfb874e3cbe17fee0aab83a47335c9554`)
- **Merge base:** `a852089b13e0602950c8f3f0fc685afd669e348a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-05-07T02:25:13Z; PR context artifacts confirmed fresh per request)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `artifacts/evidence/post-change/ac-verification.md`, `artifacts/evidence/post-change/npm-pack-listing.md`, `artifacts/evidence/post-change/npm-publish-dry-run.md`, `artifacts/evidence/post-change/jest-qc.md`, `artifacts/evidence/post-change/coverage-comparison.md`
  - Direct file inspection: `packages/mcp-server/README.md`, `packages/mcp-server/package.json`, `packages/mcp-server/esbuild-mcp-server.cjs`, `.github/workflows/publish-mcp-npm.yml`, `LICENSE`
  - Remediation evidence: `Select-String '"cwd"' packages/mcp-server/README.md` (match at line 30); `Select-String '"cjs"' packages/mcp-server/esbuild-mcp-server.cjs` (match at line 32)
- **Feature folder used:** `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173`
- **Requirements source:** `spec.md` and `user-story.md` (work mode: `full-feature`)
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-feature`. Authoritative AC source files are `spec.md` and `user-story.md`. Both files contain an `## Acceptance Criteria` section with checkbox-based AC items identical across files.
- **Scope note:** This is remediation pass 1 re-review. The prior review (`feature-audit.2026-05-07T03-30.md`) returned FAIL for AC6. Commit `3e81bb9` applied both Fix 1 (add `cwd` to README.md config snippet) and Fix 2 (pin `format: "cjs"` in esbuild script). This audit re-evaluates all 7 AC items.
- **Prior audit result:** NEEDS REVISION — 6 PASS, 1 FAIL (AC6)

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/spec.md` — primary source
- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/user-story.md` — primary source

### From spec.md and user-story.md (Acceptance Criteria section — identical in both files)

1. **AC1.** `packages/mcp-server/` exists with a publishable package.json (correct name, bin, files, engines, license, repository, type).
2. **AC2.** The esbuild build produces an `out/mcp-server.js` bundle starting with `#!/usr/bin/env node`.
3. **AC3.** The published tarball, when generated locally via `npm pack`, includes `out/mcp-server.js` and the `resources/` tree, and excludes test sources.
4. **AC4.** A top-level MIT LICENSE file exists at the repo root and the docs-validation CI job passes.
5. **AC5.** A GitHub Actions workflow at `.github/workflows/publish-mcp-npm.yml` (or equivalent) is present, triggers on a semver tag push (pattern `mcp-server-v*`), depends on the existing extension-tests job, uses NPM_TOKEN, and runs `npm publish --access public`.
6. **AC6.** README.md inside the package documents: install/usage via `npx -y @danmoisan/drm-copilot-mcp`, the MCP client config snippet (command/args/cwd), and the runtime prerequisites (Node >=18 mandatory; Python 3 and pwsh 7+ for script-backed tools).
7. **AC7.** The package version equals the version in extensions/drm-copilot/package.json at release time.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1 | `packages/mcp-server/` exists with publishable package.json (name, bin, files, engines, license, repository, type) | PASS | `packages/mcp-server/package.json` present. `name: "@danmoisan/drm-copilot-mcp"`, `bin.drm-copilot-mcp: "./out/mcp-server.js"`, `files: ["out/mcp-server.js","resources"]`, `engines.node: ">=18.0.0"`, `license: "MIT"`, `repository.directory: "packages/mcp-server"`, `type: "commonjs"`. All required fields present. Carries forward from prior audit with no changes to this file. | `node -e "const p=require('./packages/mcp-server/package.json');process.exit(p.name==='@danmoisan/drm-copilot-mcp'&&p.bin['drm-copilot-mcp']==='./out/mcp-server.js'&&p.files.includes('resources')&&p.engines.node==='>=18.0.0'&&p.type==='commonjs'?0:1)"` | No changes to this file in remediation commit. Status unchanged from prior audit. |
| AC2 | esbuild build produces `out/mcp-server.js` starting with `#!/usr/bin/env node` | PASS | `esbuild-mcp-server.cjs` contains `banner: { js: "#!/usr/bin/env node" }`. Post-change evidence `ac-verification.md` records shebang confirmed as first line. Remediation added `format: "cjs"` but did not change banner. | `Get-Content packages/mcp-server/out/mcp-server.js -TotalCount 1` | Status unchanged from prior audit. Remediation did not alter shebang. |
| AC3 | npm pack tarball includes `out/mcp-server.js` and `resources/` tree; excludes test sources | PASS | `npm-pack-listing.md` records `out/mcp-server.js` and `resources/` entries present, 0 `.ts` files, 0 `.cjs` entries. `npm-publish-dry-run.md` confirms dry-run exit 0. The `files` whitelist in `package.json` is unchanged. | `tar -tzf packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz` | Status unchanged from prior audit. No tarball revalidation required (package.json `files` array unchanged). |
| AC4 | Top-level MIT LICENSE at repo root; docs-validation CI job passes | PASS | `LICENSE` file confirmed at `./LICENSE` (file search: 3 LICENSE files including root). Content: MIT License, copyright Dan Moisan 2026. The docs-validation condition `[ ! -f LICENSE ]` is now false, so the job passes. | `Test-Path LICENSE`; `Select-String 'MIT License' LICENSE` | Status unchanged from prior audit. |
| AC5 | `.github/workflows/publish-mcp-npm.yml` present; triggers on `mcp-server-v*`; depends on extension-tests; uses NPM_TOKEN; runs `npm publish --access public` | PASS | Workflow file present. `on.push.tags: ["mcp-server-v*"]` confirmed. `needs: drm-copilot-extension-tests` confirmed. `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` confirmed. `npm publish --access public` step confirmed. Inline job duplication is an acknowledged design choice (see plan; `ci.yml` has no `workflow_call` trigger). | `Select-String 'mcp-server-v' .github/workflows/publish-mcp-npm.yml`; `Select-String 'needs: drm-copilot-extension-tests' .github/workflows/publish-mcp-npm.yml` | Status unchanged from prior audit. actionlint unverified (see policy-audit §8). |
| AC6 | README.md documents `npx -y @danmoisan/drm-copilot-mcp`, MCP config snippet (command/args/cwd), runtime prerequisites | **PASS** | **Remediation applied.** `packages/mcp-server/README.md` now contains: `npx -y @danmoisan/drm-copilot-mcp` (line 9), `"command": "npx"` (line 27), `"args": ["-y", "@danmoisan/drm-copilot-mcp"]` (line 28), `"cwd": "/absolute/path/to/your/workspace"` (line 29—30), prose guidance "Set `cwd` to the absolute path of the workspace root", `Node >=18 required` and `Python 3 and PowerShell 7+ required` prerequisites. All three required elements of the criterion (install/usage, config snippet with command/args/cwd, runtime prerequisites) are now present. | `Select-String '"cwd"' packages/mcp-server/README.md` → match at line 30 | **Changed from FAIL to PASS.** Fix 1 from `remediation-inputs.2026-05-07T03-30.md` is confirmed applied. |
| AC7 | Package version equals `extensions/drm-copilot/package.json` version at release time | PASS | `packages/mcp-server/package.json` version: `0.0.1`. `extensions/drm-copilot/package.json` version: `0.0.1`. Values match. No version change in remediation commit. | `node -e "const a=require('./packages/mcp-server/package.json');const b=require('./extensions/drm-copilot/package.json');process.exit(a.version===b.version?0:1)"` | Status unchanged from prior audit. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 7 criteria (AC1, AC2, AC3, AC4, AC5, AC6, AC7)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None. All 7 acceptance criteria are satisfied.

**Recommended follow-up verification steps:**

1. Satisfy external prerequisites before executing the first publish: create npm automation token, store as `NPM_TOKEN` in GitHub repository secrets.
2. Run `actionlint` against `.github/workflows/publish-mcp-npm.yml` when the tool becomes available in the CI environment.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 7 AC items are evaluated as PASS and are checked off in the authoritative source files (`spec.md` and `user-story.md`).
- `issue.md` already has all 7 items marked `[x]` from the prior commit. No change required there.
- `spec.md` and `user-story.md` AC sections show all 7 items as `[x]` (verified by inspection of current file content prior to writing this artifact).

### AC Status Summary

- Source: `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/spec.md`, `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/user-story.md`
- Total AC items: 7 (per file; identical across both files)
- Checked off (delivered): 7 (AC1–AC7)
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 7 | 7 | 0 | Checkbox-backed; all `[x]` confirmed in current file content |
| `user-story.md` | 7 | 7 | 0 | Checkbox-backed; all `[x]` confirmed in current file content |
| `issue.md` | 7 | 7 | 0 | Not authoritative for `full-feature` but consistent; all `[x]` |
