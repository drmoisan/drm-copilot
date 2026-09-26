# Research: PR-context `gh` detection false negative (Issue #588)

- **Issue:** #588
- **Branch:** `bug/pr-context-gh-detection-false-negative-588`
- **Requirements source:** `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/issue.md`
- **Timestamp:** 2026-09-26T02-10
- **Author role:** task-researcher (read-only analysis; no source changes)

All paths are repo-relative. Every `file:line` citation was read in this session from the worktree at `d754f83f`.

## 1. Which implementation the MCP tool runs

| Link in the chain | Evidence |
|---|---|
| `mcp__drm-copilot__collect_pr_context` is served by the `drm-copilot` stdio server launched as `npx -y @danmoisan/drm-copilot-mcp` | `.mcp.json:3-6`; push-down copy `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json:3-6` |
| That npm package's binary is `out/mcp-server.js` | `packages/mcp-server/package.json:2`, `:7-9` |
| `out/mcp-server.js` is an esbuild bundle of `extensions/drm-copilot/src/mcp-server.ts` | `packages/mcp-server/esbuild-mcp-server.cjs:29-34` |
| The VS Code extension's MCP definition launches the same entry point from the installed VSIX | `extensions/drm-copilot/src/mcp-provider.ts:34-38` |
| Server builds a `RepoAutomationService` per call and dispatches | `extensions/drm-copilot/src/mcp-server.ts:68-74`, `:105-111` |
| `collect_pr_context` routes to `handleCollectPrContext` -> `service.collectPrContext` | `extensions/drm-copilot/src/mcp-tools.ts:188-190`; `extensions/drm-copilot/src/mcp-handlers/collect-context-handlers.ts:23` |
| Service calls `collectPrContextServiceCall` with `runner`, `fileSystem`, `workspaceRoot`, `base`, `targetRef`, `log` only | `extensions/drm-copilot/src/repo-automation-service.ts:158-169` |
| Service call invokes `collectAndWrite` without a `whichGh` option | `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:71-87` (input has no `whichGh` field), `:133-144` |
| `collectAndWrite` forwards its options to `collectPrContext` | `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:49`, `:366` |
| `collectPrContext` passes `whichGh` to `GhClient` only when defined | `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:98`, `:120`, `:127-132` |

Conclusion (confirmed by code reading): the MCP tool runs the **TypeScript in-process port**. No Python is spawned (also pinned by `extensions/drm-copilot/test/extension.collect-pr-context.test.ts:439-456`). The VS Code command `drmCopilotExtension.collectPrContext` uses the same service method (`extensions/drm-copilot/src/repo-automation-command-registration-admin.ts:46`, `:80`).

The Python collector remains reachable only through the Poetry script `dev.pr-context` (`pyproject.toml:79`), which constructs `GhClient(runner, resolved_root)` (`scripts/dev_tools/pr_context/collector.py:143`).

## 2. Root cause

### 2.1 Confirmed: the TypeScript `GhClient` never resolves `gh` in production

- `WhichGh` is declared as an injected resolver "mirrors Python `shutil.which("gh")`" (`extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts:37-38`, `:56-59`).
- The constructor default is a resolver that always returns `undefined`: `const whichGh = options.whichGh ?? (() => undefined);` (`gh-client-core.ts:85`), then `this.ghPath = options.ghPath ?? whichGh() ?? undefined;` (`:87`).
- With `ghPath` undefined, `hydrateAvailability` returns immediately with `"GitHub CLI (gh) is not installed. Install from https://cli.github.com/."` and never invokes the runner (`gh-client-core.ts:142-146`).
- No production caller supplies `ghPath` or `whichGh` (chain in section 1; a repository-wide search for `whichGh|WhichGh` under `extensions/drm-copilot/src` returns only the declaration, the option plumbing in `collector-core.ts:29,98,120,131`, and the barrel re-export `index.ts:36`).
- `collectPrContext` then records `ghStatusOverride = "GitHub CLI unavailable: " + message` (`collector-core.ts:133-140`), which is exactly the observed summary line.

The defect was introduced by the Python-to-TypeScript port (issue #240, F9). Its plan specified "an injected `whichGh: () => string | undefined` resolver (so `shutil.which("gh")` is testable without touching PATH)" (`docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/plans/F9-pr-context.plan.md:66`), but no production default equivalent to `shutil.which` was wired. The Python original defaults to `shutil.which("gh")` (`scripts/dev_tools/pr_context/github.py:27`).

Consequences:

- The false negative is **deterministic and platform-independent** for every MCP and VS Code command invocation. It is not specific to Windows, PATH, or PATHEXT. It reproduces on Linux and macOS equally.
- PATH inherited by the MCP server process is **irrelevant to this defect**, because PATH is never consulted. What PATH the MCP server process had in the original 2026-08-28 session is **unknown** and is not needed to explain the observation.
- `.exe`/`.cmd` suffix handling and shell vs non-shell spawn are not reached. `SubprocessRunner` spawns with `shell: false` (`extensions/drm-copilot/src/lib/subprocess-runner.ts:107-112`), but no `gh` argv ever reaches it.

### 2.2 Why existing tests did not catch it

- Every collector-level test injects a resolver: `collector-core.test.ts:185,212,230,324,375,409`, `collector-integration.test.ts:148`, `gh-client-details.test.ts:385`.
- The service-call tests inject none and script `gh` as failing. `pr-context-service-call.test.ts:45-51` comments that "gh is unavailable in this hermetic test (auth fails)", but `gh` is never invoked; the test at `:247-267` passes through the not-installed path, not the auth-failure path it describes. The same fake pattern appears in `pr-context-service-call-target.test.ts:62` and `repo-automation-dispatch-pr-context-verification.test.ts:91`.
- `extension.collect-pr-context.test.ts` exercises the composition root but asserts only artifact paths and base refs (`:337-498`), never the GitHub CLI status line.

### 2.3 Likely (not confirmed): the Python CLI path is not defective

- `shutil.which("gh")` (`github.py:27`) applies PATHEXT on Windows per the Python standard-library contract, so a `gh.exe` on the process PATH resolves. No in-repo evidence indicates a Python resolution defect.
- The issue's reproduction (`issue.md:22`, `:27`) used the MCP tool, which section 1 shows is the TypeScript port. The Python CLI was named as "equivalent", but no observation of the Python CLI failing is recorded.
- A local probe (`where gh`, `node -e` through the resolver, `poetry run python -c "import shutil; print(shutil.which('gh'))"`) was **not run**: this research agent's tool allowlist has no shell tool. The Python conclusion is therefore **unverified** and rated likely.

### 2.4 Secondary risk (external knowledge, not verified in repo)

Once a real resolver is wired, PATHEXT order (`.COM;.EXE;.BAT;.CMD`) could return a `gh.cmd`/`gh.bat` shim if no `gh.exe` precedes it. Node releases patched for CVE-2024-27980 (18.20.2+, 20.12.2+) refuse to spawn `.bat`/`.cmd` with `shell: false` (spawn error). `SubprocessRunner` maps a `null` status to code 1 (`subprocess-runner.ts:130`) with empty stderr, which `hydrateAvailability` would render as "installed but not authenticated ... Details: unknown error" (`gh-client-core.ts:152-161`). Official `gh` installers ship `gh.exe`, so this is an edge case. It is recorded as decision D5.

## 3. Current text outputs and the collapsed states

### 3.1 Strings emitted today (TS and Python are verbatim twins)

| Summary location | gh unavailable (any cause) | gh available |
|---|---|---|
| `===== GitHub CLI status =====` body | `GitHub CLI unavailable: <availability error>`; for the not-resolved case: `GitHub CLI unavailable: GitHub CLI (gh) is not installed. Install from https://cli.github.com/.` (`collector-core.ts:139`, `gh-client-core.ts:143-144`; `collector.py:150`, `github.py:49`) | `GitHub CLI authenticated for <owner/repo>` (`gh-client-core.ts:174`; `github.py:75`) |
| `===== Issues to autoclose (verified or pending) =====` body when the list is empty | `None (no verified closing issues and readiness not PASS)` or `None (no verified closing issues and no deterministic pending issue)` | **identical strings** |
| Source of those strings | `render-pr-helpers.ts:366-374`; `render_pr_helpers.py:261-270` | same |
| Close-candidates "verified" reason | `None (GitHub CLI unavailable)` (`collector-core.ts:203-204`; `collector.py:230-231`) | `None (no PR exists yet for this branch)` / `None (closingIssuesReferences empty)` |
| Referenced-issues note | `NOTE: Unverified (GitHub unavailable)` (`collector-output.ts:205-206`; `collector_documents.py:249-251`) | absent |
| Fallback status when no override | `GitHub CLI unavailable; references unverified.` (`collector-output.ts:413-415`; `collector.py:372-373`) | n/a |

The collapse is specific to the `Issues to autoclose (verified or pending)` section. `buildIssuesToAutocloseSection` receives only `verified`, `pendingPrimary`, and `readinessSignals` (`render-pr-helpers.ts:352-357`; `render_pr_helpers.py:228-233`); it has no availability input. When `gh` is unavailable, `verified` is forced to `[]` (`collector-core.ts:201`; `collector.py:229`), and the empty-body text is the same text produced when `gh` is available and there are genuinely no candidates. A reader of that section alone cannot tell a probe failure from an absence of candidates, which is the section `pr-author` is instructed to read first.

### 3.2 Proposed textually distinct states

| State | `Issues to autoclose` body (empty list) | Status line |
|---|---|---|
| S1 gh unavailable (not resolved, not authenticated, or repo unresolved) | `None (GitHub CLI unavailable; closing issues not verified)` (new) | unchanged `GitHub CLI unavailable: <reason>` |
| S2 gh available, readiness PASS, no candidate | unchanged `None (no verified closing issues and no deterministic pending issue)` | unchanged |
| S3 gh available, readiness not PASS | unchanged `None (no verified closing issues and readiness not PASS)` | unchanged |

S1 takes precedence over S2/S3 because the absence claim in S2/S3 is only meaningful when verification ran. The new string keeps the word `unavailable`, so the existing consumer rule "If the context notes GitHub validation is unavailable/unverified, do not emit `Closes`" continues to apply without edits.

When the list is **non-empty** while `gh` is unavailable (pending-primary refs from PASS feature docs), #588 does not change rendering; see section 4.

### 3.3 Consumers of these strings

Production consumers (prose instructions, no parser):

- `.claude/skills/pr-author/SKILL.md:43`, `:77-78`
- `.github/agents/pr-author.agent.md:39-43`, `:104-108`; mirror `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md`
- `.github/prompts/generate-pr.prompt.md:134-139`; mirror `extensions/drm-copilot/resources/customizations/.github/prompts/generate-pr.prompt.md:139`
- `.agents/skills/pr-author/SKILL.md`, `.agents/skills/pr-authoring/SKILL.md`, and their mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, plus `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md`

None of these match the autoclose-body strings literally; they key on the section title and the words "unavailable/unverified". Under the recommended design **no consumer or mirror needs editing**, which avoids bundle-parity churn.

No validator or hook parses these strings. A search of `.claude/hooks/**`, `scripts/**/*.ps1`, `scripts/**/*.sh`, `scripts/dev_tools/*.py`, and `extensions/drm-copilot/src/lib/validate/**` for `autoclose|GitHub CLI` matched only `potential_to_issue.py`, `new_active_feature_folder_io.py`, and `Invoke-ReleaseVerification.ps1`, all of which are unrelated `gh` callers. `enforce-pr-author-skill.ps1` reads only the summary's timestamp and existence (`.claude/hooks/enforce-pr-author-skill.ps1:48`, `:129`, `:246`).

Tests that pin current strings:

| Test | Pins | Affected by recommendation? |
|---|---|---|
| `extensions/drm-copilot/test/lib/pr-context/gh-client-core.test.ts:108-118` | not-installed message | No (message unchanged under D3-A) |
| `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts:227`, `:238` | S2/S3 bodies | No (new param optional, default available) |
| `collector-output.test.ts:71`, `:240-247`; `collector-output-head-source.test.ts:55`; `collector-output-freshness.test.ts:66` | prebuilt section string, `NOTE`, override text | No (section string is supplied by the fixture) |
| `collector-core.test.ts:219-239` | `GitHub CLI unavailable:` prefix | No; add an assertion for S1 body |
| `pr-context-service-call.test.ts:247-267` | `GitHub CLI unavailable` substring | No; comment at `:48-49` should be corrected and resolver injected |
| `tests/scripts/dev_tools/test_collect_pr_context_part4.py:1026` | S3 body with `StubGh.available = True` (`:930-938`) | No |
| `tests/scripts/dev_tools/test_collect_pr_context_part3.py:376-406` | `unavailable` substring | No |
| `tests/scripts/dev_tools/test_pr_context_integration.py:167`, `:281-288` | Offline case asserts `(none)` or author-asserted text | No |
| `tests/scripts/dev_tools/test_pr_context_integration.py:300-315` | prompt contains `None (GitHub validation unavailable; no verified closing issues listed)` | No (prompt unchanged) |
| `tests/scripts/dev_tools/test_github.py:29-32`, `:66-69`, `:243-246` | Python not-installed via `monkeypatch.setattr("shutil.which", ...)` | No |

There is no automated TS/Python output parity test for the pr-context collector. Parity is maintained by convention ("Every error message string is preserved verbatim", `gh-client-core.ts:22`).

## 4. Scope boundary with #622

#622 ("collect_pr_context fabricates auto-close issue numbers while falsely reporting gh CLI unavailable") lists three remediations: fix the availability probe, filter non-numeric/unverified tokens, and omit the auto-close section when validation is unavailable (fetched from `https://github.com/drmoisan/drm-copilot/issues/622` in this session). Per the delegation, #588 owns the probe and the unavailable-vs-absent distinction; #622 owns scraping and filtering.

The code boundary:

| Owner | Code |
|---|---|
| #588 | `gh-client-core.ts:85-88` (resolver default); new resolver module; `pr-context-service-call.ts` input/forwarding; `collector-core.ts:238-242` (passing availability into the section builder); `render-pr-helpers.ts:352-374` empty-body branch only; Python twins `render_pr_helpers.py:228-272` empty-body branch and `collector.py:260-264` call site |
| #622 | Reference extraction `feature-docs-parsers.ts` `extractIssueReferences` (used at `collector-core.ts:182-183`) and its Python twin; the unavailable fallback that adds every raw ref as an issue (`collector-core.ts:421-429`; `collector.py:213-221`); author-asserted derivation (`collector-core.ts:213-217`; `collector.py:239-241`); pending-primary derivation (`collector-core.ts:221-232`; `collector.py:245-252`); any change to non-empty autoclose rendering, including omitting the section when unavailable |

#588 must not alter the non-empty autoclose rendering. #622's "omit when unavailable" remediation would supersede the S1 empty-body string if adopted later. The S1 text is additive and does not conflict (decision D6).

Fixing the probe will change #622's observed behavior: with `gh` resolvable, the `collector-core.ts:421-429` fallback stops running, and refs flow through `classifyEntity` instead. This reduces but does not remove #622's fabricated-number symptom. #622 remains necessary.

## 5. Candidate approaches

### A. Shared pure PATH resolver plus a production default wired at the composition root (recommended)

- Add a small module (proposed `extensions/drm-copilot/src/lib/executable-resolver.ts`) with:
  - A pure function `resolveExecutableOnPath({ name, pathValue, pathExtValue, platform, exists })` that selects `path.win32` or `path.posix` from the `platform` argument (join and delimiter), iterates PATH entries x PATHEXT (Windows) or `[""]` (other platforms), and returns the first candidate for which the injected `exists` predicate is true. A `name` that already ends in a PATHEXT extension is tried as-is first, matching `shutil.which`.
  - A process-bound `defaultWhichGh(): string | undefined` that calls the pure function with `process.env.PATH`, `process.env.PATHEXT`, `process.platform`, and `fs.existsSync`.
- Wire the production default at the composition root: add optional `whichGh?: WhichGh` to `CollectPrContextServiceCallInput` and forward `input.whichGh ?? defaultWhichGh` into `collectAndWrite` (which already accepts it through `CollectPrContextOptions`, `collector-core.ts:98`). Keep `GhClient`'s hermetic `() => undefined` default so library-level tests stay PATH-independent.
- Advantages: fixes the confirmed cause, follows the port's existing injection design, makes Windows PATHEXT semantics testable on Linux through the `platform` and `exists` parameters, adds only about 2 lines to `pr-context-service-call.ts` (174 lines), and touches neither `collector-output.ts` (494 lines) nor `collector-core.ts`' resolution code.
- Limitations: adds a fourth PATH-probe implementation next to `runtime-detection.ts:35-65` (private), `new-potential-bug-entry.ts:248-274`, and `new-active-feature-folder/io-launcher.ts:44-70`. Migrating those three is recorded as an option (D4) and kept out of #588's minimal scope.

### Rejected alternatives (brief)

- **B. Default `ghPath` to the literal `"gh"` and let spawn resolve it.** libuv's Windows search appends `.exe`/`.com`, but a missing binary surfaces as a spawn failure that `SubprocessRunner` maps to code 1 with empty stderr (`subprocess-runner.ts:130`). That would report "installed but not authenticated. Details: unknown error". It conflates not-installed with not-authenticated (the inverse collapse) and would need a runner contract change.
- **C. Change `GhClient`'s own default to the process-bound resolver.** Every test that omits `whichGh`/`ghPath` would then consult the real PATH and `fs.existsSync`. GitHub-hosted Linux runners ship `gh` at `/usr/bin/gh`, so `pr-context-service-call*.test.ts` would silently switch code paths between local and CI. This violates the determinism rule.
- **D. Import an existing `defaultWhichLookup`** (`new-potential-bug-entry.ts:248` or `io-launcher.ts:44`). This creates a cross-feature dependency from `pr-context` into unrelated command modules, and those functions read `process.platform` directly, so Windows semantics cannot be exercised on Linux.

## 6. Behavior semantics after the fix

- Resolution order: explicit `ghPath` > injected `whichGh` > (service call only) `defaultWhichGh`. First PATH directory wins; within a directory, PATHEXT order wins (Windows).
- Failure conditions: unresolved produces the unchanged not-installed message. Resolved with `auth status` non-zero produces the unchanged not-authenticated message. Authenticated with repo unresolved produces the unchanged message. All three are S1.
- The autoclose empty body is S1 whenever `ghAvailable` is false, regardless of readiness. When `ghAvailable` is true, the S2/S3 logic is unchanged.
- Edge cases: empty PATH entries are skipped (existing resolvers filter `part.length > 0`); an unset PATHEXT falls back to `.COM;.EXE;.BAT;.CMD`; PATHEXT casing is preserved in the candidate (Windows filesystems are case-insensitive, so test predicates should model that); non-Windows platforms ignore PATHEXT.

## 7. Testing implications

Constraints honored: no remote refs, gitignored state, real `gh`, network, temp files, or real Windows filesystem paths. CI runs on Linux.

Seams available:

| Seam | Location | Use |
|---|---|---|
| `platform`/`pathValue`/`pathExtValue`/`exists` parameters (new) | proposed `executable-resolver.ts` | Pure test of "resolvable extension-suffixed executable on a Windows-style PATH/PATHEXT" on Linux: `platform: "win32"`, `pathValue: "\\tools\\bin;\\apps\\GitHub CLI"`, `pathExtValue: ".COM;.EXE;.BAT;.CMD"`, and `exists` as a case-insensitive set containing `\\apps\\GitHub CLI\\gh.exe`. Expect that path. Drive-letter-free win32 strings avoid drive roots entirely; with an injected predicate the strings are inert data |
| `whichGh` / `ghPath` | `gh-client-core.ts:56-59`; `collector-core.ts:98` | Existing collector and client tests |
| `whichGh` on service-call input (new) | `pr-context-service-call.ts` | Regression test: inject `() => "/opt/gh/gh"` plus a runner answering `auth status` and `repo view`; assert the summary contains `GitHub CLI authenticated for owner/repo` |
| Mocked `node:fs` + `process.env.PATH` | `extension.collect-pr-context.test.ts:69-81`, `:213-234`, `:262-264` | Composition-root fail-first test: set `PATH` to a POSIX directory (for example `/opt/gh-bin`, not `C:/...`), make mocked `existsSync` true for `/opt/gh-bin/gh`, and assert mocked `spawnSync` receives `/opt/gh-bin/gh` with `auth status`. This fails today because `gh` is never spawned. On Linux CI it takes the posix branch deterministically |
| `monkeypatch.setattr("shutil.which", ...)` | `tests/scripts/dev_tools/test_github.py:29` | Python availability tests, unchanged |

Fail-first ordering: the composition-root test above and a `pr-context-service-call.test.ts` assertion that a resolved `gh` is invoked are the red tests. Pure resolver tests and S1-body tests are added with the fix.

Host test files:

- TS: `extensions/drm-copilot/test/lib/executable-resolver.test.ts` (new, mirrors the new source path); `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`; `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts`; `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts`; `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`.
- Python: `tests/scripts/dev_tools/test_render.py` or the existing home of `build_issues_to_autoclose_section` tests (none found by `grep build_issues_to_autoclose_section tests/`; direct unit tests would be new, in a file mirroring `render_pr_helpers.py`); `tests/scripts/dev_tools/test_pr_context_integration.py` (offline scenario asserting the S1 body).

Existing service-call tests (`pr-context-service-call.test.ts`, `pr-context-service-call-target.test.ts`, `repo-automation-dispatch-pr-context-verification.test.ts`) should inject `whichGh` explicitly after the fix. Without injection they consult the real PATH. Their fakes already tolerate `args[0]` ending in `gh`, so outcomes would not flip, but the code path would become environment-dependent.

Coverage gates (`extensions/drm-copilot/jest.config.cjs`, per-file only, no `global` key, `:20-25`):

- Existing entries that apply: `pr-context-service-call.ts` (`:29-32`), `collector-core.ts` (`:33-36`), `collector-output.ts` (`:37-40`).
- No entry exists for `gh-client-core.ts` or `render-pr-helpers.ts`. The map comment (`:215-216`) notes a new production file "without its own entry here would be completely ungated", so add entries for `./src/lib/executable-resolver.ts` and, if touched, `./src/lib/pr-context/render-pr-helpers.ts` (85/75).
- Python: `--cov=scripts.dev_tools.pr_context` (dotted form, with `=`, per `.claude/rules/plan-acceptance-gates.md` G1/G4).

File-size headroom (500-line cap): `collector-output.ts` 494, `render-pr-helpers.ts` 481, `collector-core.ts` 475, `gh-client-core.ts` 437, `pr-context-service-call.ts` 174; Python `collector.py` 474, `render_pr_helpers.py` 291. `scripts/dev_tools/pr_context/github.py` is 549 lines, already over the cap before this change. The recommended design does not modify it.

Bundle/resources parity: no production pr-context code is mirrored under `extensions/drm-copilot/resources/` (glob `resources/**/pr_context/**` returned nothing). Consumer prose mirrors (section 3.3) are unchanged under the recommendation. Reaching the live MCP tool requires rebuilding and publishing `@danmoisan/drm-copilot-mcp` (`packages/mcp-server/package.json:3`), and a VSIX rebuild for the VS Code path. Repo-side source edits alone do not change what `npx -y` runs.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for any `spec.md` acceptance criterion by this research. The consumer and test tables in section 3.3 are informational inventories, not proposed numeric assertions. The line counts in section 7 are headroom observations from a line-count search and are not acceptance criteria.

## Automation Feasibility

No human interaction is expected for implementation or verification up to merge.

- The root cause is confirmed from source alone. The fix and its regression tests are deterministic and hermetic on Linux CI through the seams in section 7.
- The toolchain loops (Prettier/ESLint/tsc/Jest; Black/Ruff/Pyright/Pytest) run unattended.
- The issue's manual step, `gh pr view <N> --json closingIssuesReferences` (`issue.md:67`), and the integration retest against a live authenticated `gh` (`issue.md:66`) depend on a published MCP package and network access. They cannot be satisfied by a pre-merge CI run. They are post-release verification that an agent can run once the package is published (the tag push that publishes is agent-blocked per prior release mechanics). The spec should classify them as post-release follow-up, not as merge gates.

## Recommendation

Adopt approach A. Decisions for the orchestrator:

- **D1 Resolution mechanism.** Recommended A: new pure `resolveExecutableOnPath` plus process-bound `defaultWhichGh`, wired as the default in `collectPrContextServiceCall`. Alternatives: B (literal `"gh"`) or C (`GhClient` default), both rejected in section 5.
- **D2 Unavailable-vs-absent text.** Recommended: add optional `ghAvailable` (TS param, default `true`; Python keyword, default `True`) to `buildIssuesToAutocloseSection` / `build_issues_to_autoclose_section`. Emit `None (GitHub CLI unavailable; closing issues not verified)` for an empty list when unavailable, and pass availability from `collector-core.ts:238-242` / `collector.py:260-264`. Alternative: add a separate `NOTE:` line under the section and leave the body unchanged (smaller diff, but the `None (...)` body still reads as an absence claim).
- **D3 Not-resolved message wording.** Recommended D3-A: keep `GitHub CLI (gh) is not installed. Install from https://cli.github.com/.` verbatim for parity and zero test churn. Alternative D3-B: reword to `GitHub CLI (gh) was not found on PATH ...` in both runtimes and update `gh-client-core.test.ts:116` and `test_github.py` accordingly. This is more accurate, since "not installed" is an inference.
- **D4 Resolver consolidation.** Recommended: out of scope for #588; file a follow-up to migrate `runtime-detection.ts:43-65`, `new-potential-bug-entry.ts:248-274`, and `io-launcher.ts:44-70` onto the shared module. Alternative: migrate within #588 (larger blast radius, three more coverage-gated files).
- **D5 `.cmd`/`.bat` shim handling.** Recommended: follow PATHEXT order (parity with `shutil.which`) and document the CVE-2024-27980 spawn limitation. Alternative: prefer `.exe`/`.com` hits over script extensions within the resolver used for `gh`.
- **D6 Relationship with #622 "omit section when unavailable".** Recommended: #588 ships the additive S1 body only; #622 may later replace it. Alternative: defer D2 entirely to #622 and ship only the resolver fix (leaves the collapse unaddressed in #588, contrary to `issue.md:65`, `:68`).
- **D7 Python parity.** Recommended: apply D2 to the Python twin as well, since `dev.pr-context` remains a live entry point (`pyproject.toml:79`). No Python resolver change. Alternative: TS-only change, which leaves the two runtimes' outputs divergent.

## Files expected to change

Production:

- `extensions/drm-copilot/src/lib/executable-resolver.ts` (new)
- `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (one-line call-site change at `:238-242`)
- `extensions/drm-copilot/jest.config.cjs` (coverage entries)
- `scripts/dev_tools/pr_context/render_pr_helpers.py` (D7)
- `scripts/dev_tools/pr_context/collector.py` (D7, call site at `:260-264`)
- Only under D3-B: `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts`, `scripts/dev_tools/pr_context/github.py` (the latter already exceeds 500 lines)

Tests:

- `extensions/drm-copilot/test/lib/executable-resolver.test.ts` (new)
- `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`
- `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` (explicit `whichGh` injection)
- `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` (explicit injection, if it reaches the service call with the default)
- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
- `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts`
- `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts`
- `tests/scripts/dev_tools/test_pr_context_integration.py` and a Python unit test file for `render_pr_helpers.py` (D7)
- Only under D3-B: `extensions/drm-copilot/test/lib/pr-context/gh-client-core.test.ts`, `tests/scripts/dev_tools/test_github.py`
