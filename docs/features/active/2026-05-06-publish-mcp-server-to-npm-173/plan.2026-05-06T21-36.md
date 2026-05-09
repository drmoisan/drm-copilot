# 2026-05-06-publish-mcp-server-to-npm - Plan

- **Issue:** #173
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-05-06T21-36
- **Status:** In Progress
- **Version:** 0.2

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- TypeScript Code Change: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- GitHub Actions Policy: [`.github/instructions/github-actions.instructions.md`](../../../../.github/instructions/github-actions.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Capture

- [x] [P0-T1] Read required policy files in compliance order and record evidence in `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/phase0-instructions-read.md`
  - Files to read in order: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/github-actions.instructions.md`
  - Acceptance: `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/phase0-instructions-read.md` exists and contains the fields `Timestamp:`, `Policy Order:`, and an explicit list of each file read.

- [x] [P0-T2] Capture baseline ESLint result from `extensions/drm-copilot/` and save to `artifacts/evidence/baseline/eslint-baseline.md`
  - Command: `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: `artifacts/evidence/baseline/eslint-baseline.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T3] Capture baseline TypeScript typecheck result from `extensions/drm-copilot/` and save to `artifacts/evidence/baseline/typecheck-baseline.md`
  - Command: `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: `artifacts/evidence/baseline/typecheck-baseline.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T4] Capture baseline Jest test result from `extensions/drm-copilot/` and save to `artifacts/evidence/baseline/jest-baseline.md`
  - Command: `npm --prefix extensions/drm-copilot run test`
  - Acceptance: `artifacts/evidence/baseline/jest-baseline.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test`, `EXIT_CODE:`, `Output Summary:` including a numeric coverage percentage value.

### Phase 1 — packages/mcp-server/ Directory Creation

- [x] [P1-T1] Create `packages/mcp-server/.gitignore` listing `out/` and `resources/` as ignored paths
  - Acceptance: `packages/mcp-server/.gitignore` exists; `grep -F 'out/' packages/mcp-server/.gitignore` exits with code 0; `grep -F 'resources/' packages/mcp-server/.gitignore` exits with code 0.

- [x] [P1-T2] Create `packages/mcp-server/package.json` with all required metadata fields: `name` (`@danmoisan/drm-copilot-mcp`), `version` (matching `extensions/drm-copilot/package.json` value `0.0.1`), `description`, `license` (`MIT`), `type` (`commonjs`), `bin` (mapping `drm-copilot-mcp` to `./out/mcp-server.js`), `files` (array containing `"out/mcp-server.js"` and `"resources"`), `engines.node` (`>=18.0.0`), `repository` (with `directory: packages/mcp-server`), `bugs`, `homepage`, `keywords`, `author`, `scripts.build` (`"node esbuild-mcp-server.cjs"`), `scripts.prepack` (Node.js one-liner invoking `fs.cpSync` to copy `../../extensions/drm-copilot/resources` to `./resources`), and `devDependencies` containing `esbuild`
  - Acceptance: `packages/mcp-server/package.json` exists; `node -e "const p=require('./packages/mcp-server/package.json');process.exit(p.name==='@danmoisan/drm-copilot-mcp'&&p.version==='0.0.1'&&p.bin['drm-copilot-mcp']==='./out/mcp-server.js'&&p.files.includes('out/mcp-server.js')&&p.files.includes('resources')&&p.engines.node==='>=18.0.0'&&p.type==='commonjs'?0:1)"` exits with code 0.

- [x] [P1-T3] Create `packages/mcp-server/esbuild-mcp-server.cjs` adapted from `extensions/drm-copilot/esbuild-mcp-server.cjs` with `entryPoints` set to `["../../extensions/drm-copilot/src/mcp-server.ts"]`, `outfile` set to `"out/mcp-server.js"`, `banner: { js: "#!/usr/bin/env node" }` added to the esbuild build call, and the `vscodeShimPlugin` definition retained verbatim from the extension script
  - Acceptance: `packages/mcp-server/esbuild-mcp-server.cjs` exists; `grep -F '"../../extensions/drm-copilot/src/mcp-server.ts"' packages/mcp-server/esbuild-mcp-server.cjs` exits with code 0; `grep -F '"#!/usr/bin/env node"' packages/mcp-server/esbuild-mcp-server.cjs` exits with code 0; `grep -F 'vscodeShimPlugin' packages/mcp-server/esbuild-mcp-server.cjs` exits with code 0.

- [x] [P1-T4] Create `packages/mcp-server/tsconfig.json` extending `../../extensions/drm-copilot/tsconfig.json` and including `../../extensions/drm-copilot/src` to enable IDE navigation over MCP server source files
  - Acceptance: `packages/mcp-server/tsconfig.json` exists; `python -c "import json; json.load(open('packages/mcp-server/tsconfig.json'))"` exits with code 0.

- [x] [P1-T5] Create `packages/mcp-server/README.md` documenting installation via `npx -y @danmoisan/drm-copilot-mcp`, the MCP client configuration JSON snippet with `"command": "npx"` and `"args": ["-y", "@danmoisan/drm-copilot-mcp"]`, and runtime prerequisites (Node >=18 required; Python 3 and PowerShell 7+ required for script-backed tools)
  - Acceptance: `packages/mcp-server/README.md` exists; `grep -F 'npx -y @danmoisan/drm-copilot-mcp' packages/mcp-server/README.md` exits with code 0; `grep -F '"command": "npx"' packages/mcp-server/README.md` exits with code 0; `grep -F 'Node >=18' packages/mcp-server/README.md` exits with code 0; `grep -F 'Python 3' packages/mcp-server/README.md` exits with code 0.

- [x] [P1-T6] Create `packages/mcp-server/LICENSE` containing MIT license text with copyright holder `Dan Moisan`
  - Acceptance: `packages/mcp-server/LICENSE` exists; `grep -F 'MIT License' packages/mcp-server/LICENSE` exits with code 0; `grep -F 'Dan Moisan' packages/mcp-server/LICENSE` exits with code 0.

### Phase 2 — Build Verification

- [x] [P2-T1] Run `npm install` in `packages/mcp-server/` to install the `esbuild` devDependency declared in `packages/mcp-server/package.json`
  - Command: `npm --prefix packages/mcp-server install`
  - Preconditions: P1-T2 complete.
  - Acceptance: Command exits with code 0; `packages/mcp-server/node_modules/.bin/esbuild` exists.

- [x] [P2-T2] Run `npm run build` in `packages/mcp-server/` to produce `packages/mcp-server/out/mcp-server.js` from the TypeScript source at `extensions/drm-copilot/src/mcp-server.ts`
  - Command: `npm --prefix packages/mcp-server run build`
  - Preconditions: P2-T1 complete; `extensions/drm-copilot/src/mcp-server.ts` exists.
  - Acceptance: Command exits with code 0; `packages/mcp-server/out/mcp-server.js` exists.

- [x] [P2-T3] Verify the first line of `packages/mcp-server/out/mcp-server.js` is the Node.js shebang
  - Command: `head -1 packages/mcp-server/out/mcp-server.js`
  - Preconditions: P2-T2 complete.
  - Acceptance: Command output is exactly `#!/usr/bin/env node`.

- [x] [P2-T4] Run `npm run prepack` in `packages/mcp-server/` and verify `packages/mcp-server/resources/` is created with contents from `extensions/drm-copilot/resources/`
  - Command: `npm --prefix packages/mcp-server run prepack`
  - Preconditions: P2-T1 complete; `extensions/drm-copilot/resources/` exists.
  - Acceptance: Command exits with code 0; `packages/mcp-server/resources/` directory exists and contains at least one child entry (verified via `ls packages/mcp-server/resources/ | head -1`).

- [x] [P2-T5] Run `npm pack --dry-run` in `packages/mcp-server/` and verify the projected file listing includes `out/mcp-server.js` and at least one `resources/` entry
  - Command: `npm --prefix packages/mcp-server pack --dry-run 2>&1`
  - Preconditions: P2-T4 complete.
  - Acceptance: Command exits with code 0; output contains the string `out/mcp-server.js`; output contains at least one line matching `resources/`.

### Phase 3 — License File

- [x] [P3-T1] Create `LICENSE` at the repository root containing standard MIT license text with copyright holder `Dan Moisan`
  - Acceptance: `LICENSE` exists at the repository root; `grep -F 'MIT License' LICENSE` exits with code 0; `grep -F 'Dan Moisan' LICENSE` exits with code 0.

- [x] [P3-T2] Verify the repository root `LICENSE` file satisfies the `docs-validation` CI job license check at `.github/workflows/ci.yml` line 127
  - Command: `test -f LICENSE && echo LICENSE_EXISTS`
  - Preconditions: P3-T1 complete.
  - Acceptance: Command output contains `LICENSE_EXISTS` and exits with code 0.

### Phase 4 — GitHub Actions Publish Workflow

- [x] [P4-T1] Create `.github/workflows/publish-mcp-npm.yml` with a `push` trigger on tags matching `mcp-server-v*`, a `drm-copilot-extension-tests` matrix job running on `[ubuntu-latest, windows-latest]` that installs extension dependencies (`npm --prefix extensions/drm-copilot ci`) and runs extension tests (`npm --prefix extensions/drm-copilot run test`), and a `publish` job declaring `needs: drm-copilot-extension-tests` that runs on `ubuntu-latest`, checks out the repo with `actions/checkout@v4`, sets up Node 20 with `registry-url: https://registry.npmjs.org`, runs `npm --prefix packages/mcp-server ci`, runs `npm --prefix packages/mcp-server run build`, and runs `npm --prefix packages/mcp-server publish --access public` with `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}`
  - Acceptance: `.github/workflows/publish-mcp-npm.yml` exists; `grep -F 'mcp-server-v' .github/workflows/publish-mcp-npm.yml` exits with code 0; `grep -F 'NPM_TOKEN' .github/workflows/publish-mcp-npm.yml` exits with code 0; `grep -F 'npm publish --access public' .github/workflows/publish-mcp-npm.yml` exits with code 0; `grep -F 'needs: drm-copilot-extension-tests' .github/workflows/publish-mcp-npm.yml` exits with code 0; `grep -F 'registry-url' .github/workflows/publish-mcp-npm.yml` exits with code 0.

- [x] [P4-T2] Verify `.github/workflows/publish-mcp-npm.yml` is syntactically valid YAML
  - Command: `python -c "import yaml; yaml.safe_load(open('.github/workflows/publish-mcp-npm.yml'))" && echo YAML_VALID`
  - Preconditions: P4-T1 complete.
  - Acceptance: Command output contains `YAML_VALID` and exits with code 0.

### Phase 5 — TypeScript QC Loop

> Run steps P5-T1 through P5-T4 in order. If P5-T1 (Prettier) modifies any file, restart the loop from P5-T1. If any step exits with a non-zero code, fix the reported issue and restart the loop from P5-T1. All tasks in this phase are unconditional.

- [x] [P5-T1] Run Prettier format on `extensions/drm-copilot/` source files and save the result to `artifacts/evidence/post-change/prettier-qc.md`
  - Command: `npm --prefix extensions/drm-copilot run format`
  - Acceptance: Command exits with code 0; `artifacts/evidence/post-change/prettier-qc.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, `Output Summary:`.

- [x] [P5-T2] Run ESLint on `extensions/drm-copilot/` source files and save the result to `artifacts/evidence/post-change/eslint-qc.md`
  - Command: `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: Command exits with code 0; `artifacts/evidence/post-change/eslint-qc.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, `Output Summary:`.

- [x] [P5-T3] Run TypeScript type check on `extensions/drm-copilot/` and save the result to `artifacts/evidence/post-change/typecheck-qc.md`
  - Command: `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: Command exits with code 0; `artifacts/evidence/post-change/typecheck-qc.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, `Output Summary:`.

- [x] [P5-T4] Run Jest tests on `extensions/drm-copilot/` and save the result to `artifacts/evidence/post-change/jest-qc.md`
  - Command: `npm --prefix extensions/drm-copilot run test`
  - Acceptance: Command exits with code 0; `artifacts/evidence/post-change/jest-qc.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test`, `EXIT_CODE: 0`, `Output Summary:` including a numeric coverage percentage value.

### Phase 6 — Final QA

- [x] [P6-T1] Run `npm pack` in `packages/mcp-server/` to produce the tarball and capture the projected file listing
  - Command: `(cd packages/mcp-server && npm pack 2>&1)`
  - Preconditions: P2-T2 complete; `packages/mcp-server/out/mcp-server.js` exists; `packages/mcp-server/resources/` exists (from the prepack step triggered by pack).
  - Acceptance: Command exits with code 0; file `packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz` exists; save listing to `artifacts/evidence/post-change/npm-pack-listing.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P6-T2] Verify tarball contents from `packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz` include `package/out/mcp-server.js` and at least one `package/resources/` entry, and exclude `.ts` source files and the `.cjs` build script
  - Command: `tar -tzf packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz`
  - Preconditions: P6-T1 complete.
  - Acceptance: Command exits with code 0; output contains `package/out/mcp-server.js`; output contains at least one line matching `package/resources/`; output contains no line matching `\.ts$`; output contains no line matching `esbuild-mcp-server\.cjs`.

- [x] [P6-T3] Run `npm publish --dry-run --access public` in `packages/mcp-server/` and save the result to `artifacts/evidence/post-change/npm-publish-dry-run.md`
  - Command: `npm --prefix packages/mcp-server publish --dry-run --access public`
  - Preconditions: P6-T1 complete.
  - Acceptance: Command exits with code 0; `artifacts/evidence/post-change/npm-publish-dry-run.md` exists and contains `Timestamp:`, `Command: npm --prefix packages/mcp-server publish --dry-run --access public`, `EXIT_CODE: 0`, `Output Summary:` containing `@danmoisan/drm-copilot-mcp`.

- [x] [P6-T4] Compare post-change Jest coverage percentage from `artifacts/evidence/post-change/jest-qc.md` against baseline percentage from `artifacts/evidence/baseline/jest-baseline.md` and record the delta in `artifacts/evidence/post-change/coverage-comparison.md`
  - Preconditions: P0-T4 and P5-T4 complete; both artifact files contain numeric coverage percentages.
  - Acceptance: `artifacts/evidence/post-change/coverage-comparison.md` exists; it contains `Baseline Coverage:`, `Post-change Coverage:`, and `Delta:`; the post-change percentage is greater than or equal to the baseline percentage.

- [x] [P6-T5] Verify acceptance criteria AC1 through AC7 from `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/issue.md` are each satisfied and record results in `artifacts/evidence/post-change/ac-verification.md`
  - Acceptance: `artifacts/evidence/post-change/ac-verification.md` exists; it contains one row for each of AC1 through AC7 with a status of `PASS` or `FAIL` and a supporting artifact path or command reference; all seven rows show `PASS`; the file contains no occurrence of `FAIL`.

## Test Plan

- Unit: No new TypeScript source files are added by this feature. Existing Jest tests in `extensions/drm-copilot/` must continue to pass (verified in P5-T4 and compared in P6-T4).
- Integration: Validated via `npm pack` tarball inspection (P6-T1, P6-T2) and `npm publish --dry-run` (P6-T3). No automated integration tests are added.
- Manual smoke test: Not automated in this plan; runtime behavior requires Node >=18, Python 3, and PowerShell 7+ on the consumer machine as documented in the README (P1-T5).
- Coverage evidence:
  - Baseline: `artifacts/evidence/baseline/jest-baseline.md`
  - Post-change: `artifacts/evidence/post-change/jest-qc.md`
  - Comparison: `artifacts/evidence/post-change/coverage-comparison.md`

## Open Questions / Notes

- External prerequisite (out of scope for this PR): The `danmoisan` npm account, npm automation token, and `NPM_TOKEN` GitHub repository secret must be configured before a live publish can succeed. These do not block implementation or local verification.
- The `prepack` npm lifecycle script uses `fs.cpSync` (available in Node 16.7+). The package requires Node >=18, so this is safe across all supported environments.
- The publish workflow at `.github/workflows/publish-mcp-npm.yml` duplicates the `drm-copilot-extension-tests` steps from `ci.yml` rather than using `workflow_call` because `ci.yml` does not expose a `workflow_call` trigger (confirmed: `ci.yml` triggers are `push`, `pull_request`, and `workflow_dispatch` only).
- The `extensions/drm-copilot/` ESLint command (`eslint --no-error-on-unmatched-pattern src test`) explicitly scopes to `src` and `test` directories inside the extension; files added under `packages/mcp-server/` are not in its scan path and will not cause ESLint errors in Phase 5.
