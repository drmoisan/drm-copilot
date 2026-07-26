# Root `vscode-test` Entry-Point Scope Research (Issue #421)

- Timestamp: 2026-07-25T23-45
- Issue: #421 — root `npm test` / `npm run test:integration` are unrunnable (`vscode-test` with no `.vscode-test.*` configuration)
- Branch: `bug/vscode-test-integration-entrypoint` (base `origin/main` = `fb483b8468204e4385b5583c3b3ec4c0a987eede`)
- Scope question: **(a)** remove the dead entry points and vestigial supporting references, repointing root `test` at a suite that runs, versus **(b)** wire a real VS Code integration-test harness at the repository root.
- Method note: shell access was not available in this research session, so `git log`/`git show` provenance was obtained through the public GitHub API and raw-content endpoints for `github.com/drmoisan/drm-copilot` (the repository is public; all queries returned without authentication). Every claim below cites either a workspace file path or a commit SHA verified through those endpoints.

## 1. Current State Analysis

Root `package.json` (`package.json`, lines 26–40) declares:

- `"test": "vscode-test"` (line 39) and `"test:integration": "vscode-test"` (line 38).
- `"pretest": "npm run compile && npm run compile:integration-tests && npm run lint"` (line 34).
- `compile:integration-tests` (line 29): an inline Node script that exits 0 with a "Skipping" message when `tsconfig.vscode-test.json` is absent — which it always is.
- `format` / `format:check` (lines 32–33): include `".vscode-test.mjs"` in the Prettier glob list under `--no-error-on-unmatched-pattern` — the file has never existed.
- devDependencies (lines 41–54): `@vscode/test-cli` `^0.0.15`, `@vscode/test-electron` `^3.0.0`, `@types/mocha` `^10.0.10`.
- Extension-manifest vestiges: `publisher`, `displayName`, `engines.vscode`, `vscode:prepublish`, `@types/vscode` — but **no `main`, no `activationEvents`, no `contributes`**. The root is not an extension package.

No `.vscode-test.{mjs,js,cjs,json}` and no `tsconfig.vscode-test.json` exists in the working tree (Glob over the whole workspace: zero matches; root tsconfigs are only `tsconfig.json`, `tsconfig.jest.json`, `tsconfig.tests.json`). `@vscode/test-cli` exits 1 in `loadDefaultConfigFile` before starting any runner (verbatim failure captured in `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md` and reproduced identically post-change in `.../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md`).

Root jest configuration (`jest.config.cjs`, lines 4–7 — read-only in this workstream) matches both `<rootDir>/tests/unit/**/*.test.ts` and `<rootDir>/extensions/drm-copilot/test/**/*.test.ts`, so root `test:unit` (`node run-jest.cjs`) runs the one root unit test plus the entire extension jest suite (169 suites / 2032 tests per #414 evidence, `.../evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md`, Condition 3 workaround data).

## 2. RQ1 — Provenance

Complete commit history of root `package.json` (GitHub API, `commits?path=package.json`, 18 commits total, list exhaustive):

| SHA | Date | Message (first line) |
|---|---|---|
| `ac9bd4e8` | 2026-02-22 | `(chore(typescript)): scaffold strict tsconfig and Jest (ts-jest) harness` — **creates `package.json`** |
| `6f3b3e9e` | 2026-02-22 | `(feat(typescript)): add initial TypeScript + Jest configuration baseline` |
| `9fdf3433` | 2026-03-05 | `(feat(scaffold-extension)): expose PR context collection with base-branch picker` |
| `a8c123be` | 2026-03-11 | `(fix(coverage)): align multi-provider coverage outputs and VS Code tasks` |
| `ae7bfba6` | 2026-04-03 | `(feat(mcp)): add stdio MCP bridge for repo automation` |
| `eff6d33e` | 2026-04-04 | `(feat(bundle-sync-agents)): expose AGENTS sync via the extension` |
| `2fb14b93` | 2026-05-02 | `publishing details` |
| `88f699ab` | 2026-05-04 | `feat(extension): bundle agent customizations and add publishing tooling` |
| `fe3ebe99` … `6dc142a9` | 2026-06-20 … 2026-07-25 | dependency bumps, release 1.0.0 (`b3e43efe`), npm-audit overrides (#414) |

Decisive findings:

1. **The dead scripts are original scaffold content.** The raw `package.json` at `ac9bd4e8` (the commit that created the file) already contains `"test": "vscode-test"`, `"test:integration": "vscode-test"`, `compile:integration-tests`, `pretest`, `vscode:prepublish`, and the `".vscode-test.mjs"` Prettier glob (verified via `raw.githubusercontent.com/drmoisan/drm-copilot/ac9bd4e8/package.json`). These lines were copied from a VS Code extension scaffold template into the root manifest on day one.
2. **The repository root was never a VS Code extension.** The top-level tree at `ac9bd4e8` contains **no `src/` directory at all** and no `extensions/` directory (git tree listing: `.github`, `docs`, `scripts`, `tests`, config files only). The GitHub API commit list for path `src/extension.ts` is empty — no root extension entry point has existed at any commit. The root manifest has never had a `main` field (checked at `ac9bd4e8`, `9fdf3433`, and HEAD).
3. **The extension was born under `extensions/`, not moved out of the root.** At `9fdf3433` (2026-03-05) the `extensions/` directory contains exactly one entry: `extensions/scaffold-extension` (GitHub contents API at ref `9fdf3433`). It exists today as `extensions/drm-copilot/` with its own jest-based `test` script (`extensions/drm-copilot/package.json`, lines 202–213). The exact rename commit was not pinpointed (the commits API does not follow renames) and is not decisive for the scope choice.
4. **The vscode-test path has never been runnable at any commit.** GitHub API commit lists for paths `.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, `.vscode-test.json`, and `tsconfig.vscode-test.json` are all empty — none of these files has ever been committed in repository history. Root `npm test` has therefore failed at every commit since `ac9bd4e8` (2026-02-22).

Conclusion: this is not a regression to repair; it is scaffold debris that was dead on arrival.

## 3. RQ2 — Root source/test surface

- `src/hello-typescript.ts` is one line: `console.log("Hello Typescript");`. It is scaffold/sample code with no consumers (nothing imports it; it exists so the root TypeScript toolchain has a compile target — the root `compile`/`typecheck`/`lint` scripts self-skip when no `.ts` files exist under `src/` or `tests/`, per `package.json` lines 28–30).
- `tests/unit/hello-typescript.test.ts` (17 lines) spies on `console.log`, requires the module, and asserts the greeting was logged. It is the **only** root TypeScript test file (Glob `tests/**/*.ts` returns exactly this file; everything else under `tests/` is Python, PowerShell, or fixtures).
- There is no root behavior that could be "integration-tested" in a VS Code host: no extension entry point, no activation event, no contribution point, no host-bound code.

## 4. RQ3 — Coverage impact of removal

**Removing root `test`/`test:integration` reduces zero coverage.** Proof chain:

1. Both scripts execute `vscode-test`, which exits 1 in `loadDefaultConfigFile` **before any test runner starts** (stack trace in `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md`: `at loadDefaultConfigFile (.../@vscode/test-cli/out/cli/config.mjs:33:11)`). No test has ever executed through these scripts.
2. Because no `.vscode-test.*` config was committed at any point in history (RQ1, item 4), this has been true at every commit, on every machine, environment-independently.
3. No CI workflow invokes them. Complete inventory of test-executing CI surfaces at HEAD:

| Workflow | Command | Suite |
|---|---|---|
| `.github/workflows/_quality-checks.yml` (via `ci.yml`) | `poetry run pytest --cov=src/lexile_corpus_tuner ...` (line 76) | Python |
| `.github/workflows/_poshqc.yml` (via `ci.yml`) | `Invoke-PoshQCTest -Root ...` (lines 38–42) | Pester |
| `.github/workflows/_shell-coverage.yml` (via `ci.yml`) | shell coverage | shell |
| `.github/workflows/_drm-copilot-extension-tests.yml` (via `ci.yml`) | `npm --prefix extensions/drm-copilot run test` (line 30) = `node run-jest.cjs` | extension jest, ubuntu + windows |
| `.github/workflows/publish-extension.yml` / `publish-mcp-npm.yml` | `npm --prefix extensions/drm-copilot run test` | extension jest (release gates) |
| `.github/workflows/_npm-audit-gate.yml` | `npm ci` + `npm audit` for manifests `.`, `extensions/drm-copilot`, `packages/mcp-server` (lines 30–33, 48, 54) | dependency audit only, no tests |

No workflow runs any root npm script other than `npm ci`/`npm audit` in the audit gate. Grep of `.github/workflows/**` for `test:integration` and `vscode-test`: zero matches. Root `test:unit` (jest) is itself not invoked by any CI workflow today; it is a local/agent-toolchain gate (invoked by `.vscode/tasks.json` lines 1257/1277, `scripts/dev_tools/atomic_executor/qc_toolchain.py` line 62, and the QC hooks). Nothing anywhere invokes plain root `npm test` programmatically (grep over the repository excluding `docs/**`: no hits outside `package.json` itself and unrelated string fixtures).

## 5. RQ4 — What root `npm test` should do instead

Real root-level test entry points at HEAD:

- `test:unit` = `node run-jest.cjs` (root jest: root `tests/unit/**` + `extensions/drm-copilot/test/**`).
- `test:unit:coverage` = `node run-jest.cjs --coverage`.
- Python: `poetry run pytest` (pyproject-managed).
- PowerShell: PoshQC / `Invoke-PoshQCTest`.

Recommended definition: **`"test": "node run-jest.cjs"`** — the same command as `test:unit`, written as a direct value rather than `npm run test:unit` to avoid an extra npm process layer. This requires **no change** to `run-jest.cjs` or `jest.config.cjs` (both off-limits): the runner and config already exist and already define the suite. `npm test` then runs `pretest` (compile + lint, after removing the dead `compile:integration-tests` link) followed by the full root jest suite, ending in a defined, passing state.

Known interaction (not a blocker, must be documented in the plan): per #414 Condition 3 (`.../evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md`, lines 58–92), jest discovery fails with `No tests found` when the checkout path contains a dot-directory component (e.g., `.claude/worktrees/...`). This is a pre-existing, separately-filed defect in the jest `<rootDir>` testMatch substitution; it does not reproduce on CI runners or normal checkouts. Acceptance verification for #421's repointed `npm test` must run from a normal checkout or use the documented rootDir-free `--testMatch` workaround, since `jest.config.cjs` cannot be modified in this workstream.

## 6. RQ5 — Does the extension need a vscode-test harness?

No current target exists. Verified:

- `extensions/drm-copilot/test/extension.integration.test.ts` (lines 19–58) and `extension.collect-commit-context.integration.test.ts` (lines 9–40) both begin with `jest.mock("vscode", () => ({...}), { virtual: true })` and import from `@jest/globals`. They are **jest unit-style tests with a fully mocked `vscode` module**, not VS Code-host tests. They cannot run under the `vscode-test` mocha runner without a rewrite.
- They ARE executed, twice over: by the extension's own suite (`extensions/drm-copilot/jest.config.cjs` line 4, `testMatch: ["<rootDir>/test/**/*.test.ts"]`, run in CI by `_drm-copilot-extension-tests.yml` on ubuntu and windows) and by the root jest config's second testMatch entry.
- The extension's `package.json` has no `@vscode/test-cli`/`@vscode/test-electron` devDependencies and no `.vscode-test.*` config (lines 228–241).

If genuine extension-host integration testing is ever wanted (e.g., to catch drift between `engines.vscode ^1.108.0` and real host APIs that mocks cannot detect — a gap already noted in `docs/features/completed/2026-06-24-push-down-language-packs-csharp-variant-226/20260624-push-down-claude-opt-in-packs-research.md` line 498), the correct location is `extensions/drm-copilot/`, with its own config, tsconfig, and CI job, and with new mocha-based test sources. That is a new feature with its own issue, not a repair of the root scripts: the root harness never pointed at the extension and could not, since the extension is an independent npm package with its own lockfile.

## 7. RQ6 — Dependency state

Root `package.json` devDependencies include `@vscode/test-cli` `^0.0.15`, `@vscode/test-electron` `^3.0.0`, and `@types/mocha` `^10.0.10` (lines 43, 46–47). Consumption analysis:

- `@vscode/test-cli` provides the `vscode-test` bin (`package-lock.json` line 2096) — consumed only by the two dead scripts. `@vscode/test-electron` is consumed only by `@vscode/test-cli`. `@types/mocha` is a peer of the vscode-test toolchain; the root tsconfigs pin `types` to `["node"]` (`tsconfig.json` line 7) and `["node", "jest"]` (`tsconfig.jest.json` line 5), so mocha types are never loaded, and no root file imports `mocha` (grep excluding `docs/**`: matches only in `package.json`/`package-lock.json`).
- Nothing else in the repository consumes any of the three (grep for `@vscode/test-` excluding `docs/**`: `package.json` and `package-lock.json` only). The extension and `packages/mcp-server` have separate manifests without them.
- Under option (a) all three should be removed and `package-lock.json` regenerated; `_npm-audit-gate.yml` runs `npm ci` on the root manifest (matrix entry `"."`) and will verify lockfile/manifest sync on CI. Removal also deletes the `@vscode/test-cli` dependency subtree from the audit surface (lockfile lines 2078–2258).

## 8. RQ7 — Vestigial reference inventory

References that exist **only** to support the dead root vscode-test path (all evidence cited above):

| # | Reference | Location | Disposition |
|---|---|---|---|
| 1 | `"test": "vscode-test"` | `package.json:39` | Replace with `"node run-jest.cjs"` |
| 2 | `"test:integration": "vscode-test"` | `package.json:38` | Safe to remove (no CI, script, hook, or task references it; grep-verified) |
| 3 | `compile:integration-tests` script | `package.json:29` | Safe to remove (only consumer is `pretest`; self-skips unconditionally because `tsconfig.vscode-test.json` never existed) |
| 4 | `compile:integration-tests` link in `pretest` | `package.json:34` | Edit `pretest` to `npm run compile && npm run lint` |
| 5 | `".vscode-test.mjs"` glob entry | `package.json:32,33` (`format`, `format:check`) | Safe to remove (file never existed in history; glob is inert under `--no-error-on-unmatched-pattern`) |
| 6 | `@vscode/test-cli`, `@vscode/test-electron`, `@types/mocha` devDeps | `package.json:43,46,47` | Safe to remove (RQ6); regenerate `package-lock.json` |
| 7 | `.vscode-test/` ignore entry | `.gitignore:4` | Safe to remove (no tool in this repository ever writes a `.vscode-test/` download directory); optional — retaining it is harmless, but removal is consistent with the cleanup intent |

Load-bearing references that mention `.vscode-test` but must NOT be touched:

| Reference | Location | Why load-bearing |
|---|---|---|
| PoshQC default exclude `'.vscode-test'` | `scripts/powershell/PoshQC/PoshQC.psm1:8` | Generic file-scan hygiene; behavior is asserted by `tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1:8,17` |
| PoshQC byte-mirror | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1:8` | Delivered customization content (mirror of the above) |
| Folder-picker exclude `".vscode-test"` | `extensions/drm-copilot/src/poshqc-folder-picker.ts:39` | Extension production code; generic ignore list |
| `.vscode-test/**` | `extensions/drm-copilot/.vscodeignore:14` | Extension packaging hygiene, unrelated to root scripts |
| Historical mentions | `docs/**` (features, evidence, research) | Immutable historical records |

Related extension-manifest vestiges at the root — in the same debris family but not strictly part of the vscode-test path; recommend the planner treat them as optional secondary cleanup within the same change, each verified unused: `publisher` (`package.json:3`), `displayName` (`:4`), `engines.vscode` (`:7–9`), `vscode:prepublish` (`:27`; `vsce` is never run at the root), and `@types/vscode` devDep (`:45`; no root file imports `vscode`, and root tsconfig `types` arrays exclude it).

## 9. RQ8 — Regression guard

The class of defect is "a declared npm script whose entry point cannot exist." A guard can live entirely inside the existing root jest suite with **no** modification to `jest.config.cjs` or `run-jest.cjs`: the config's `testMatch` already picks up any new file at `tests/unit/**/*.test.ts`.

Proposed guard (one new file, e.g., `tests/unit/package-scripts.test.ts`):

- Arrange: read and parse the committed root `package.json` (reading a versioned repository file is not a prohibited external dependency and is not a temporary file).
- Assert 1: no script value invokes `vscode-test` (the specific dead binary this issue removes).
- Assert 2: for every script value matching `node <file>.cjs` (currently `run-jest.cjs` via `test`/`test:unit`/`test:unit:coverage`, and `run-node-tool.cjs` via `watch`/`format`/`format:check`/`lint`), the referenced file exists at the repository root.
- Assert 3: `scripts.test` equals `scripts["test:unit"]` (root `npm test` and `test:unit` must not drift apart again).

This is deterministic, order-independent, filesystem-read-only, and satisfies Arrange–Act–Assert. A fully general "every npm script is runnable" check is not achievable in a unit test (it would require executing arbitrary scripts), so the guard targets the two concrete failure modes this defect exhibited: a dead binary name and a nonexistent runner file. CI execution of the guard requires a workflow that runs the root jest suite; today none does (RQ3). Adding a root-tests CI job is a reasonable follow-up but expands scope (it would also duplicate the extension suite, since root jest testMatch includes it); the planner should decide whether to include it in #421 or file it separately.

## 10. Candidate approaches

### Option (a) — Remove the dead entry points; repoint root `test` at the real suite (SELECTED)

- Description: apply inventory items 1–7 (section 8); add the regression-guard test (section 9).
- Advantages: restores an honest, passing root `npm test` using only existing, already-green infrastructure; deletes two never-runnable scripts, one always-skipping script, an inert glob, and three unused devDependencies; zero coverage loss (section 4); no new CI moving parts; fully unattended-verifiable.
- Limitations: does not add extension-host testing (which the repository has never had); root `npm test` remains subject to the pre-existing #414 Condition 3 dot-directory artifact (documented workaround exists).
- Convention alignment: matches the extension's own precedent — `extensions/drm-copilot` `test` = `node run-jest.cjs`.

### Option (b) — Wire a real vscode-test harness at the root (REJECTED)

Rejected alternatives summary: the root has no extension to host (no `main`, no `activationEvents`, no extension source — ever, per RQ1/RQ2), so a root harness would download and launch a VS Code instance to run zero host-dependent tests; the only plausible target (the extension's "integration" tests) is jest-based with a mocked `vscode` module and would require a rewrite plus a new config, tsconfig, and CI job **at the extension level, not the root** — a different feature than #421; and the harness adds unattended-execution burdens (section 11) with no compensating coverage. A hybrid "keep `test:integration` pointing at a future harness" variant was also rejected: it preserves exactly the dishonest-entry-point condition #421 exists to eliminate.

## 11. Automation Feasibility

- Option (a) requires no human interaction at any step. Every change is a text edit plus `npm install` to regenerate the lockfile; every verification gate (`npm test`, `npm run format:check`, `npm run lint`, `npm ci`, extension CI) runs unattended on existing runners. The only caveat is environmental: root jest must be verified from a checkout path without a dot-directory component (#414 Condition 3), which CI runners satisfy by default.
- Option (b) is materially worse for unattended execution, and this weighs against it independently of the no-target argument:
  - `@vscode/test-electron` downloads a full VS Code build (order of 100+ MB) from Microsoft's update endpoint at run time; CI runs need network egress and caching to be stable.
  - On `ubuntu-latest`, the downloaded VS Code is a GUI application and requires a display server; unattended runs must wrap the command in `xvfb-run` (VS Code's documented CI pattern). This is automatable but adds a failure mode local feature-review cannot exercise, and per `.claude/rules/ci-workflows.md` any new workflow would need a green run against the branch head before merge.
  - `windows-latest` runs without a display server but launches a real Electron host per run, with correspondingly slower and flakier execution than jest.
  - No step requires an interactive human, so option (b) is not strictly human-gated — but it converts a currently hermetic, sub-minute jest gate into a network-downloading, display-server-dependent Electron launch that tests nothing the mocked suite does not already cover at the root. This is a material argument against (b).

## 12. Testing implications (no test code written here)

- New guard test at `tests/unit/package-scripts.test.ts` (section 9): unit tier, deterministic, no mocks needed, Arrange–Act–Assert, discovered by existing `testMatch` without config changes.
- Existing suites are the regression net: root jest (`npm test` after repoint) must pass; extension CI (`_drm-copilot-extension-tests.yml`) is unaffected because the extension manifest is untouched; `_npm-audit-gate.yml` matrix entry `"."` validates the regenerated lockfile via `npm ci`.
- Coverage: root `test:unit:coverage` is unchanged; the guard test adds covered lines only. No production file's coverage denominator changes (only `package.json`, `package-lock.json`, `.gitignore` are edited — none is coverage-measured).

## Recommendation

**Option (a): remove the dead root vscode-test entry points and their vestigial supporting references, and repoint root `test` at the existing jest runner.**

Decisive evidence:

1. The root vscode-test path has been unrunnable at **every commit in repository history**: `"test": "vscode-test"` and `"test:integration": "vscode-test"` were introduced in the commit that created `package.json` (`ac9bd4e8`, 2026-02-22), and no `.vscode-test.{mjs,js,cjs,json}` or `tsconfig.vscode-test.json` has ever been committed (empty GitHub commit histories for all five paths).
2. The repository root was never a VS Code extension: no `src/` directory existed at `ac9bd4e8`, no `src/extension.ts` has ever existed, and the root manifest has never had a `main` field. The real extension was scaffolded at `extensions/scaffold-extension` (`9fdf3433`, 2026-03-05) and lives today at `extensions/drm-copilot/` with its own jest-based, CI-exercised `test` script (`extensions/drm-copilot/package.json:210`; `.github/workflows/_drm-copilot-extension-tests.yml:30`).
3. Option (b) has no target: the only candidate tests (`extensions/drm-copilot/test/*.integration.test.ts`) mock `vscode` virtually under jest and already run in CI on two OSes; a root harness would host nothing.

Strongest argument against, and why it does not prevail: removing the scripts forecloses the one declared (if broken) placeholder for VS Code-host integration testing, and mocked-`vscode` jest tests cannot detect real host-API drift. This does not prevail because the root harness never provided that protection — it has never executed a single test — and could not provide it, since the extension is an independent package at `extensions/drm-copilot/`. If host-level testing is wanted, the correct implementation is a new, separately-scoped harness inside the extension package with its own CI job and mocha-based sources; keeping a permanently failing root `npm test` contributes nothing toward that and misleads every developer and agent that invokes it. The Automation Feasibility findings (VS Code download, xvfb dependency on Linux runners) further raise the cost side of (b) without adding coverage.

Implied change list (respects the constraint that `run-jest.cjs`, `jest.config.cjs`, `.claude/rules/**`, `.agents/skills/**`, and `extensions/drm-copilot/resources/claude-customizations/**` are not modified):

1. `package.json` — set `"test": "node run-jest.cjs"`; delete `"test:integration"`; delete `"compile:integration-tests"`; set `"pretest": "npm run compile && npm run lint"`; remove `".vscode-test.mjs"` from the `format` and `format:check` glob lists; remove devDependencies `@vscode/test-cli`, `@vscode/test-electron`, `@types/mocha`.
2. `package-lock.json` — regenerate via `npm install` (verified on CI by `_npm-audit-gate.yml` matrix entry `"."` running `npm ci`).
3. `.gitignore` — remove line 4 (`.vscode-test/`). Optional; safe (section 8, item 7).
4. Add `tests/unit/package-scripts.test.ts` — the regression guard defined in section 9 (auto-discovered by the existing root jest `testMatch`; no config edits).
5. Optional secondary cleanup, planner's discretion: remove root extension-manifest vestiges `publisher`, `displayName`, `engines.vscode`, `vscode:prepublish`, and the unused `@types/vscode` devDep (each verified unused, section 8).
6. Explicitly out of scope: PoshQC `.vscode-test` excludes and their tests, `extensions/drm-copilot/.vscodeignore`, all extension sources and resources, all historical `docs/**` records, and any new CI job for the root jest suite (candidate follow-up issue).

Coverage impact: **zero reduction, proven.** The removed scripts fail in `@vscode/test-cli`'s `loadDefaultConfigFile` before any runner starts (verbatim evidence in `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md`), no configuration file for them has ever existed at any commit, and no CI workflow invokes them (section 4 inventory). Every suite that actually executes today — root jest via `test:unit`, extension jest in CI, pytest, Pester/PoshQC, shell coverage — is untouched, and root `npm test` gains the full root jest suite it never had.
