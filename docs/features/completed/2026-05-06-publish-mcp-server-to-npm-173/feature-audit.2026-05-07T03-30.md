# Feature Audit: publish-mcp-server-to-npm (#173)

---

**Audit Date:** 2026-05-07  
**Feature Folder:** `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173`  
**Base Branch:** `chore/publish-to-marketplace` (commit `a852089b`)  
**Head Branch:** `feature/publish-mcp-server-to-npm-173` (commit `335c72b6`)  
**Work Mode:** `full-feature`  
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `chore/publish-to-marketplace` (commit `a852089b13e0602950c8f3f0fc685afd669e348a`)
- **Head branch/commit:** `feature/publish-mcp-server-to-npm-173` (commit `335c72b6a65afc1067adb464b8bc36acd07e0c00`)
- **Merge base:** `a852089b13e0602950c8f3f0fc685afd669e348a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-05-07T02:08Z)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `artifacts/evidence/post-change/ac-verification.md`, `artifacts/evidence/post-change/npm-pack-listing.md`, `artifacts/evidence/post-change/npm-publish-dry-run.md`, `artifacts/evidence/post-change/jest-qc.md`, `artifacts/evidence/post-change/coverage-comparison.md`
  - Additional evidence: `packages/mcp-server/package.json`, `packages/mcp-server/esbuild-mcp-server.cjs`, `packages/mcp-server/README.md`, `.github/workflows/publish-mcp-npm.yml`, `LICENSE`
- **Feature folder used:** `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173`
- **Requirements source:** `spec.md` and `user-story.md` (work mode: `full-feature`)
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-feature`. Authoritative AC source files are therefore `spec.md` and `user-story.md` per the acceptance-criteria-tracking contract. Both files contain an `## Acceptance Criteria` section with checkbox-based AC items identical to those in `issue.md`.
- **Scope note:** No PR exists for this branch yet. PR context was generated against the explicit base `chore/publish-to-marketplace`. Review is based on the full feature implementation committed in a single commit (`335c72b`).

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
| AC1 | `packages/mcp-server/` exists with publishable package.json (name, bin, files, engines, license, repository, type) | PASS | `packages/mcp-server/package.json` present. Fields: `name: "@danmoisan/drm-copilot-mcp"`, `bin.drm-copilot-mcp: "./out/mcp-server.js"`, `files: ["out/mcp-server.js","resources"]`, `engines.node: ">=18.0.0"`, `license: "MIT"`, `repository.directory: "packages/mcp-server"`, `type: "commonjs"`. `artifacts/evidence/post-change/ac-verification.md` confirms exit 0. | `node -e "const p=require('./packages/mcp-server/package.json');process.exit(p.name==='@danmoisan/drm-copilot-mcp'&&p.bin['drm-copilot-mcp']==='./out/mcp-server.js'&&p.files.includes('resources')&&p.engines.node==='>=18.0.0'&&p.type==='commonjs'?0:1)"` | All required fields present. |
| AC2 | esbuild build produces `out/mcp-server.js` starting with `#!/usr/bin/env node` | PASS | `packages/mcp-server/out/mcp-server.js` exists (file present in directory listing). `esbuild-mcp-server.cjs` contains `banner: { js: "#!/usr/bin/env node" }`. `artifacts/evidence/post-change/ac-verification.md` records PowerShell `Get-Content ... -TotalCount 1` output: `#!/usr/bin/env node`. | `Get-Content packages/mcp-server/out/mcp-server.js -TotalCount 1` | Build artifact present; shebang verified. |
| AC3 | npm pack tarball includes `out/mcp-server.js` and `resources/` tree; excludes test sources | PASS | `packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz` exists. `artifacts/evidence/post-change/npm-pack-listing.md` records `out/mcp-server.js` and `resources/` entries present, 0 `.ts` files, 0 `.cjs` entries. `artifacts/evidence/post-change/npm-publish-dry-run.md` confirms dry-run exit 0 with correct file listing. | `tar -tzf packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz` | Tarball produced and contents verified. |
| AC4 | Top-level MIT LICENSE at repo root; docs-validation CI job passes | PASS | `LICENSE` file exists at `./LICENSE` (file search confirmed 3 LICENSE files, including root). Content: MIT License, copyright Dan Moisan 2026. The `docs-validation` CI job at `.github/workflows/ci.yml` checks `[ ! -f LICENSE ]` — this condition is now false. | `Test-Path LICENSE`; `Select-String 'MIT License' LICENSE` | LICENSE added in this commit (`packages/mcp-server/LICENSE` is a separate package-level copy; `./LICENSE` is the repo-root file satisfying CI). |
| AC5 | `.github/workflows/publish-mcp-npm.yml` present; triggers on `mcp-server-v*`; depends on extension-tests; uses NPM_TOKEN; runs `npm publish --access public` | PASS | Workflow file present. `on.push.tags: ["mcp-server-v*"]` confirmed. `needs: drm-copilot-extension-tests` confirmed. `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` confirmed. `npm publish --access public` step confirmed. Note: workflow duplicates the `drm-copilot-extension-tests` job inline (acknowledged in plan; required because `ci.yml` has no `workflow_call` trigger). | `Select-String 'mcp-server-v'`; `Select-String 'needs: drm-copilot-extension-tests'`; `Select-String 'NPM_TOKEN'`; `Select-String 'npm publish --access public'` `.github/workflows/publish-mcp-npm.yml` | The extension-tests job dependency intent is met. `actionlint` unverified (see policy-audit G1). |
| AC6 | README.md documents: `npx -y @danmoisan/drm-copilot-mcp`, MCP config snippet (command/args/cwd), runtime prerequisites | **FAIL** | `packages/mcp-server/README.md` contains `npx -y @danmoisan/drm-copilot-mcp` (present), `"command": "npx"` (present), `Node >=18` and `Python 3` prerequisites (present). **Missing:** `"cwd"` field in the MCP config snippet. Spec `API/CLI Surface` section explicitly requires `"cwd": "/absolute/path/to/destination/workspace"`. User-story `Scenario: First-Time Setup` shows `"cwd": "/absolute/path/to/their/workspace"`. The README config block contains only `command` and `args`. | Inspect `packages/mcp-server/README.md` lines 18–26; compare with `spec.md` lines 78–87 | The `cwd` field is functionally necessary: the MCP server uses `process.cwd()` to resolve `workspace_root` when not overridden. AC6 criterion text explicitly lists `(command/args/cwd)`. **FAIL: `cwd` absent from README config snippet.** |
| AC7 | Package version equals `extensions/drm-copilot/package.json` version at release time | PASS | `packages/mcp-server/package.json` version: `0.0.1`. `extensions/drm-copilot/package.json` version: `0.0.1`. Values match. | `node -e "const a=require('./packages/mcp-server/package.json');const b=require('./extensions/drm-copilot/package.json');process.exit(a.version===b.version?0:1)"` | Version synchronization is manual; currently in sync at `0.0.1`. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 6 criteria (AC1, AC2, AC3, AC4, AC5, AC7)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (AC6)

**Top gaps preventing PASS:**

1. **AC6 FAIL** — `packages/mcp-server/README.md` MCP client configuration snippet omits `"cwd"`. The spec and user-story require `command`, `args`, and `cwd` in the snippet. The MCP server resolves `workspace_root` from `process.cwd()` when not overridden by the tool caller; without `cwd` in the client config, tools that operate on workspace files will resolve to an incorrect location. This is a single-line fix: add `"cwd": "/absolute/path/to/your/workspace"` to the config JSON and a sentence explaining that this path must be the consumer's target workspace root.

**Recommended follow-up verification steps:**

1. Add `"cwd": "/absolute/path/to/your/workspace"` (with guidance note) to the MCP config JSON block in `packages/mcp-server/README.md`, then verify: `grep -F '"cwd"' packages/mcp-server/README.md` exits with code 0.
2. Run `actionlint` against `.github/workflows/publish-mcp-npm.yml` via `scripts/dev-tools/run-actionlint.ps1` and confirm no errors.
3. After both items are resolved, re-run the feature-audit to confirm all 7 AC items PASS.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** are checked off below in the authoritative source files (`spec.md` and `user-story.md`).
- AC6 (FAIL) remains unchecked in both source files.
- `issue.md` already has all 7 items marked `[x]`. The `issue.md` AC6 check-off is inconsistent with this review's finding; the discrepancy is noted here. The authoritative sources for `full-feature` work mode are `spec.md` and `user-story.md`.

### AC Status Summary

- Source: `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/spec.md`, `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/user-story.md`
- Total AC items: 7 (per file; identical across both files)
- Checked off (delivered): 6 (AC1–AC5, AC7)
- Remaining (unchecked): 1 (AC6)
- Items remaining: AC6 — README.md MCP client config snippet (command/args/cwd).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 7 | 6 | 1 (AC6) | Checkbox-backed. AC1–AC5, AC7 marked `[x]`. AC6 remains `[ ]`. |
| `user-story.md` | 7 | 6 | 1 (AC6) | Checkbox-backed. AC1–AC5, AC7 marked `[x]`. AC6 remains `[ ]`. |
| `issue.md` | 7 | 7 (pre-existing) | 0 | Already fully checked by implementer. AC6 `[x]` in issue.md is inconsistent with review finding. Not the authoritative source for full-feature work mode. |
