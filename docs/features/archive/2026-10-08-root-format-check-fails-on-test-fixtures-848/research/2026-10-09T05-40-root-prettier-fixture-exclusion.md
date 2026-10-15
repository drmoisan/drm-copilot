# Research: root Prettier fixture exclusion (Issue #848)

Date: 2026-10-09. Work mode: minor-audit. Scope: facts for planning the smallest safe fix for the root `npm run format:check` failure.

Verification limits: the worktree has no `node_modules` and no shell tool was available to this researcher, so no command was executed. Prettier behavior is taken from the Prettier documentation (prettier.io/docs/cli, prettier.io/docs/ignore) and repo evidence, and is marked "unverified at runtime" where relevant.

## 1. Prettier invocation, version, ignore-file behavior

- Scripts: `package.json:32` (`format`, `--write`) and `package.json:33` (`format:check`, `--check`). Both are `node run-node-tool.cjs prettier/bin/prettier.cjs --no-error-on-unmatched-pattern <flag> "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" "tsconfig*.json" "run-*.cjs"`.
- Working directory: `run-node-tool.cjs:126-132` calls `runNodeTool(moduleRequest, toolArgs)` with default `cwd = process.cwd()` (`run-node-tool.cjs:106`); `spawnSync` is passed `cwd` (`run-node-tool.cjs:107-115`). So Prettier runs in the directory `npm run` was started from, which is the repo root for the root scripts.
- Tool resolution searches `<cwd>` and `<cwd>/extensions/drm-copilot` `node_modules` (`run-node-tool.cjs:5-7`), unrelated to ignore handling.
- Pinned version: `package.json:49` `"prettier": "^3.9.9"`; `package-lock.json:6619-6620` resolves `node_modules/prettier` to `3.9.9`.
- Ignore-file default (Prettier docs, CLI page): `--ignore-path` defaults to `./.gitignore` and `./.prettierignore`, resolved relative to cwd; `.prettierignore` uses gitignore syntax. Ignored files are dropped from glob expansion. Unverified at runtime in this repo.
- `--no-error-on-unmatched-pattern`: suppresses the error when a pattern matches no files. The docs do not state whether an all-ignored pattern is treated as unmatched. Not relevant here because the `tests/**` pattern still matches `tests/unit/*.test.ts` (3 files, verified by Grep) and so is never fully unmatched.
- Existing config: Glob `**/.prettier*` over the worktree returned no files, so there is no root `.prettierignore` and no `.prettierrc*`. `package.json` contains no `prettier` config key (Grep on `prettier` returned only `package.json:32,33,49`). A root `.gitignore` exists and contains no `tests/fixtures` rule other than `/tests/fixtures/poshqc-consumer/artifacts/` (`.gitignore:8`); it is read by Prettier by default but does not affect this failure.

## 2. Baseline failure list (non-fixture paths)

Source: `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/baseline/root-format-check.2026-10-07T15-00.md`. Command line recorded at line 2: `npx --yes npm@11 run format:check`; `EXIT_CODE: 2` (line 3).

- `[warn]` lines: file lines 14-227 = 214 lines, every path begins `tests/fixtures/`. Non-fixture `[warn]` count: 0.
- `[error]` lines: file lines 228-231. Line 228 is `tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json: SyntaxError ...`; lines 229-231 are the code-frame continuation of that same error. Non-fixture `[error]` count: 0.
- Line 232 `Error occurred when checking code style in the above file.` is Prettier's trailer for the single parse error.
- Conclusion: after excluding `tests/fixtures/` the baseline list leaves zero failing paths. Caveat: the baseline dates from 2026-10-07; the 830 QA-gate rerun `.../evidence/qa-gates/root-format-check.2026-10-07T16-00.md:3-5` shows the same exit 2 and the same summary. Any `src/` or `tests/*.ts` file changed after 2026-10-07 is unchecked by this evidence, so the plan must run the check on the branch head (AC-1 does so).
- Corroboration that non-fixture `tests/` content is TypeScript only: Grep with `type: ts` over `tests/` excluding fixtures found 3 files (`tests/unit/hello-typescript.test.ts`, `tests/unit/jest-config-resolution.test.ts`, `tests/unit/vscode-test-removal.test.ts`); `type: json` excluding `**/fixtures/**` found none; `type: js` found none.

## 3. Other byte-sensitive data under tests/

- Outside `tests/fixtures/`: no JSON/JS/MJS/CJS/TSX under `tests/` (Grep results above). `tests/scripts/` contains none of the Prettier-matched extensions. `tests/` top level holds `conftest.py` and `test_pytest_collection.py` only as files; `tests/unit/` holds the 3 TypeScript tests.
- Inside `tests/fixtures/`: no `.ts/.tsx/.js/.mjs/.cjs` files (Grep over `tests/fixtures` returned none), so the exclusion removes only JSON. Byte-sensitivity evidence: `.gitattributes:2-3,9,14` mark fixture files `-text`/`-eol` (CRLF plan files, `crlf-*.csproj`, `cleanup_worktrees/preserve/eol-crlf/**`); fixtures such as `tests/fixtures/parallel_manifest_bash/manifest_crlf_line_endings.json` and `.../blast_radius/derivation-crlf.json` exist.
- No other corpus directory exists outside `tests/fixtures/` that Prettier's globs match, so excluding `tests/fixtures/` alone is sufficient.

## 4. Other Prettier invocations

- `extensions/drm-copilot/package.json:207`: `"format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\" \"*.json\" \"*.cjs\""`; `:239` pins `^3.9.9`. Evidence shows it is run with cwd `extensions/drm-copilot` (`.../830/evidence/qa-gates/extension-format-check.2026-10-07T16-00.md:2`). Prettier reads `./.prettierignore` relative to cwd, so a root `.prettierignore` is not picked up there (per docs; unverified at runtime). Its patterns cover only `src`, `test`, `*.json`, `*.cjs` of the extension, none under `tests/fixtures/`, so there is no behavioral overlap anyway.
- `extensions/drm-copilot` has no `.prettierignore` (Glob returned none).
- `.github/workflows/`: Grep for `prettier` returned 0 matches; no workflow runs Prettier or `format:check`.
- Repo hooks/scripts mention Prettier only as command-pattern strings (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:137-138`, `.codex/hooks/...:156-157`, `scripts/dev_tools/plan_gate_observability.py:175-177`), not as invocations whose scope a root ignore file would change.
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py:470` and `test_cli_part3.py:183` reference `["npm","run","format"]` as a step name/command list, not the script text.
- Repo-root quality-gate runs (`npm run format`) from the root in the toolchain loop would change in intended fashion (fixtures skipped).

## 5. Mirrors, inventories, assertions

- Searched `tests/` for tests enumerating repo-root files (`iterdir`, `readdirSync(repoRoot)`, `Get-ChildItem -Force $repoRoot`): 0 matches. Searched `tests/` for `format:check`, `run-node-tool`, `"format"`: only the two `atomic_executor` command-list references above. No test asserts the text of the `format` or `format:check` scripts.
- Search of `extensions/drm-copilot/src` for root-file allowlists found only `copilot-customizations-engine.ts:166-167` (sorting listed files of a source root, not a root dotfile allowlist). The push-down distributes `resources/` content, not repo-root dotfiles. No `.prettierignore` reference exists outside docs/evidence. Conclusion: no bundled mirror or parity test requires a matching update (search-based; a bundle-parity test run was not executed).
- `.gitattributes:1` is `* text=auto eol=lf`; a new `.prettierignore` will be normalized to LF. Write it with LF endings and a final newline.

## 6. Candidate comparison and recommendation

(a) New root `.prettierignore` containing `tests/fixtures/`.
- Advantages: one location serves `format`, `format:check`, direct `npx prettier` calls, and editor integrations; script text unchanged; AC-2 satisfied for both scripts by one edit; conventional Prettier mechanism; no change to the 1k-char script lines.
- Limits: new root file; relies on Prettier's default `--ignore-path` (documented, unverified at runtime here; the plan verifies by running the check).

(b) Negated glob (for example `"!tests/fixtures/**"`) added to both package.json scripts.
- Advantages: no new file.
- Limits: must be kept in sync in two long script lines; does not protect direct Prettier invocations or editors; negation-pattern ordering behavior is another variable.

Recommendation: (a). Smallest change (one new file, one line), no script edits.

Exact file `C:\...\<worktree>\.prettierignore` (repo root `.prettierignore`), LF, trailing newline:

```
# Fixtures keep exact bytes (CRLF, intentionally invalid JSON); see issue #848.
tests/fixtures/
```

Repository files the implementation would write (non-doc): exactly one, `.prettierignore`. Documentation artifacts the workflow adds (plan, evidence, issue.md AC check-offs) are feature-folder files only. No file under `tests/fixtures/` and no `package.json` change.

## 7. Verification commands

- Format check (the invocation recorded as working on Windows): `npx --yes npm@11 run format:check` from the repo root (`.../830/evidence/baseline/root-format-check.2026-10-07T15-00.md:2`). The equivalent `npm run format:check` is the AC-1 form. Do NOT run `npm run format` in a verification step to avoid rewriting files; if run, check `git status` for no `tests/fixtures/` changes.
- Expected success output (from `.../830/evidence/qa-gates/extension-format-check.2026-10-07T16-00.md:7-10` for the same Prettier family): the lines `Checking formatting...` then `All matched files use Prettier code style!`, `EXIT_CODE: 0`. No `[warn]` or `[error]` lines should appear. (The root-run success text is expected to be identical; the last recorded root run exited 2, so no root success output has been captured on main.)
- AC-3 check: `git diff --name-only <base>..HEAD -- tests/fixtures` returns empty (a git read command, not previously recorded as run in this form).
- Pester suites (AC-4): paths `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` exist (Glob). Invocations seen in prior evidence: `pwsh -NoProfile -Command "Invoke-Pester -Path <test-path> -Output Detailed"` (for example `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-pester-publish-mcp-npm-workflow.md:4`), and the PoshQC MCP `run_poshqc_test` route (`.../543/evidence/other/pwsh-task-classification.2026-10-02T05-00.md:44`). Issue #690 evidence used `sh SCRATCH/run-ps.sh ... pester-counts.ps1 -Path <suite>` because the agent-worktree guard denies text containing `pwsh`; a planner should pick the route the executing session permits. The two suites read the invalid fixture via `Get-WorktreeResolutionFixturePath 'shared/item-own-invalid-json'` (`enforce-model-routing-receipt.WorktreeResolution.Tests.ps1:56`, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:61`), resolved under `tests/fixtures/worktree-resolution` by `WorktreeResolutionFixture.Helpers.ps1:41`. Expected result: all tests pass, 0 failed (baseline pass counts for these two suites were not located; unverified, so capture a before/after count).

## Unverified items

- Runtime confirmation that Prettier 3.9.9 skips `tests/fixtures/` with the new file (to be shown by the AC-1 run).
- Any non-fixture formatting regression introduced after 2026-10-07.
- Baseline pass counts for the two WorktreeResolution suites.
