# 2026-08-28-pr-context-gh-detection-false-negative (Spec)

- **Issue:** #588
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-26T05-25
- **Status:** Draft
- **Version:** 0.3
- **Research:** `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/research/2026-09-26T02-10-pr-context-gh-detection-research.md`

## Context
The PR-context collector reports `GitHub CLI unavailable: GitHub CLI (gh) is not installed` in sessions where `gh` is installed and working. Because the `pr-author` skill correctly refuses to emit an unverified `Closes #<N>` keyword, the false negative silently produces a PR body with no autoclose link, and the issue stays open after merge.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment (`poetry run`)
- Command/flags used: `mcp__drm-copilot__collect_pr_context` with `base=origin/main`; equivalent CLI entry point writes `artifacts/pr_context.summary.txt`
- Data source or fixture: worktree `drm-copilot-wt/2026-08-28T19-50`, branch `feature/atomic-preflight-convergence-586`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Severity rationale: the failure is silent and produces a wrong end state (issue left open on merge) rather than an error. It is recoverable by a second `pr-author` pass, but only if a human or orchestrator notices the missing link. Every PR authored from a bundle generated under this condition is affected.


## Repro & Evidence
Steps to Reproduce:
1. In a worktree where `gh auth status` succeeds, run the PR-context collector against a base branch (`collect_pr_context` with `base=origin/main`).
2. Read `artifacts/pr_context.summary.txt` and look at the GitHub CLI availability line and the `Issues to autoclose (verified or pending):` line.
3. In the same shell and same working directory, run `gh issue view <N> --json number,state,title`.

Expected:
The collector detects the working `gh` binary, verifies the candidate issue, and lists it under `Issues to autoclose (verified or pending):` so that `pr-author` can emit `Closes #<N>` on the verified path.

Actual:
The summary records `GitHub CLI unavailable: GitHub CLI (gh) is not installed` and `Issues to autoclose (verified or pending): None`, while `gh issue view 586` in the same session returns `{"number":586,"state":"OPEN","title":"Feature: atomic-preflight-convergence"}` and `gh pr create` succeeds moments later. `pr-author` therefore applies its documented no-`Closes` fallback and the PR body ships with the issue recorded only as author-asserted.

Logs / Screenshots:
- [x] Attached minimal logs or snippet
- Snippet:
  - `artifacts/pr_context.summary.txt`: `GitHub CLI unavailable: GitHub CLI (gh) is not installed`
  - `artifacts/pr_context.summary.txt`: `Issues to autoclose (verified or pending): None`
  - Same session: `gh issue view 586 --json number,state,title` -> `{"number":586,"state":"OPEN","title":"Feature: atomic-preflight-convergence"}`
  - After manual remediation: `gh pr view 587 --json closingIssuesReferences` returns issue 586


## Scope & Non-Goals
- In scope:
  - GitHub CLI availability detection for the TypeScript PR-context collector reached through `mcp__drm-copilot__collect_pr_context` and the VS Code command `drmCopilotExtension.collectPrContext`: a new pure PATH/PATHEXT executable resolver, a process-bound `defaultWhichGh`, and its wiring as the default in `collectPrContextServiceCall`.
  - Making the "GitHub CLI unavailable" state textually distinct from the "no autoclose candidates" state in the empty body of the `Issues to autoclose (verified or pending)` section, in both the TypeScript port and the Python twin (`dev.pr-context`).
  - Regression tests, coverage-gate entries in `extensions/drm-copilot/jest.config.cjs` for new or touched TypeScript production files, and explicit `whichGh` injection in existing service-call tests so they remain environment-independent.
- Out of scope / non-goals:
  - Everything owned by sibling issue #622: auto-close issue-number scraping and filtering (`extractIssueReferences` and its Python twin), the raw-reference fallback that adds every raw reference as an issue when `gh` is unavailable, author-asserted derivation, pending-primary derivation, any rendering of a non-empty autoclose list (including #622's appended line `Unverified: the issues listed above come from feature metadata only and were not checked against GitHub (GitHub CLI unavailable).` when `gh` is unavailable and the list is non-empty), the not-open pending fallback, the relocation of the autoclose builders into `autoclose.ts` / `autoclose.py`, and omission of the autoclose section. #588 owns only `gh` availability detection and the empty-list unavailable-vs-absent status text.
  - Changing the not-installed, not-authenticated, or repository-unresolved message wording (D3).
  - Consolidating the existing PATH-lookup implementations in `runtime-detection.ts`, `new-potential-bug-entry.ts`, and `new-active-feature-folder/io-launcher.ts` onto the new resolver (D4; follow-up).
  - Special handling of `gh.cmd`/`gh.bat` shims beyond PATHEXT order (D5).
  - Any change to the Python `gh` resolution (`shutil.which("gh")` in `scripts/dev_tools/pr_context/github.py`), which is not implicated by the evidence.
  - Edits to consumer prose (`pr-author` skills, agents, prompts) or their resource mirrors; the new text keeps the word `unavailable`, which those consumers already key on.
  - Publishing the MCP package or VSIX, and the live `closingIssuesReferences` check (post-release follow-up).
- Explicitly excluded systems, integrations, or datasets:
  - `scripts/dev_tools/pr_context/github.py` (already 549 lines, over the 500-line cap) and `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts` are not modified.
  - `SubprocessRunner` spawn semantics (`shell: false`) are not modified.

## Root Cause Analysis
Confirmed by code reading (research section 2.1) and spot-checked by the orchestrator:

- The MCP tool `collect_pr_context` runs the TypeScript in-process port, not the Python collector (research section 1: `.mcp.json` -> `@danmoisan/drm-copilot-mcp` -> `out/mcp-server.js` bundle of `extensions/drm-copilot/src/mcp-server.ts` -> `collectPrContextServiceCall` -> `collectAndWrite` -> `collectPrContext` -> `GhClient`).
- `GhClient` defaults its resolver to one that always returns `undefined`: `const whichGh = options.whichGh ?? (() => undefined);` (`extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts` near line 85), then `this.ghPath = options.ghPath ?? whichGh() ?? undefined;`.
- `pr-context-service-call.ts` never supplies `whichGh` or `ghPath`, and no other production caller does. With `ghPath` undefined, `hydrateAvailability` returns the not-installed message without invoking the runner, and `collectPrContext` records `GitHub CLI unavailable: GitHub CLI (gh) is not installed. Install from https://cli.github.com/.`
- The defect is deterministic and platform-independent for every MCP and VS Code command invocation. PATH, PATHEXT, and spawn mode are never consulted, so the issue's original Windows/PATHEXT hypothesis is not the cause.
- It was introduced by the Python-to-TypeScript port (issue #240, F9), whose plan specified an injected `whichGh` resolver but no production default equivalent to Python's `shutil.which("gh")`.
- Existing tests did not detect it: collector-level tests always inject a resolver; service-call tests inject none and fake `gh` as failing, so they pass through the not-installed path while their comments describe an auth-failure path; the composition-root test does not assert the GitHub CLI status line.
- Separate defect: when `gh` is unavailable, `verified` is forced to `[]`, and `buildIssuesToAutocloseSection` / `build_issues_to_autoclose_section` have no availability input, so the empty body renders the same `None (...)` text as a genuine absence of candidates.
- Python CLI path: likely not defective (`shutil.which` honors PATHEXT); unverified by a local probe. No Python resolver change is made.

Observed first on issue #586 / PR #587 on 2026-08-28.


## Design Decisions

- **D1 Resolution mechanism.**
  - Option A (adopted): new pure module `extensions/drm-copilot/src/lib/executable-resolver.ts` exporting `resolveExecutableOnPath({ name, pathValue, pathExtValue, platform, exists })` plus a process-bound `defaultWhichGh()` that supplies `process.env.PATH`, `process.env.PATHEXT`, `process.platform`, and `fs.existsSync`.
  - Option B (rejected): default `ghPath` to the literal `"gh"` and let spawn resolve it.
  - Option C (rejected): change `GhClient`'s own default to a process-bound resolver.
  - Option D (rejected): import an existing `defaultWhichLookup` from an unrelated command module.
  - Rationale: A fixes the confirmed cause, follows the port's injection design, and makes Windows PATHEXT semantics testable on Linux; B conflates not-installed with not-authenticated, C makes existing tests environment-dependent, D adds a cross-feature dependency with untestable platform branches.
- **D2 Unavailable-vs-absent text.**
  - Option A (adopted): add an optional availability flag (`ghAvailable`, TS default `true`, Python keyword default `True`) to the autoclose-section builder; when unavailable and the list is empty, emit `None (GitHub CLI unavailable; closing issues not verified)`; the existing no-candidate texts are unchanged when available.
  - Option B: add a separate `NOTE:` line under the section and leave the body unchanged.
  - Rationale: the `None (...)` body is what readers and `pr-author` read first, so the body itself must not read as an absence claim when verification did not run.
- **D3 Not-resolved message wording.**
  - Option D3-A (adopted): keep `GitHub CLI (gh) is not installed. Install from https://cli.github.com/.` verbatim.
  - Option D3-B: reword to `GitHub CLI (gh) was not found on PATH ...` in both runtimes.
  - Rationale: preserves TS/Python parity and avoids editing `gh-client-core.ts` and `github.py`, the latter already over 500 lines.
- **D4 Resolver consolidation.**
  - Option A (adopted): defer migration of the existing PATH lookups in `runtime-detection.ts`, `new-potential-bug-entry.ts`, and `new-active-feature-folder/io-launcher.ts` to a follow-up issue.
  - Option B: migrate them within #588.
  - Rationale: keeps #588's blast radius and coverage-gated surface minimal.
- **D5 `.cmd`/`.bat` shim handling.**
  - Option A (adopted): follow PATHEXT order (parity with `shutil.which`) and document that Node releases patched for CVE-2024-27980 refuse to spawn `.cmd`/`.bat` with `shell: false`.
  - Option B: prefer `.exe`/`.com` hits over script extensions for `gh`.
  - Rationale: official `gh` installers ship `gh.exe`; parity with Python semantics is simpler and the limitation is documented rather than special-cased.
- **D6 Relationship with #622.**
  - Option A (adopted): #588 owns the empty-list unavailable body and its precedence; #622 owns every non-empty rendering change, including the appended unverified annotation line (#622 D4-C) and the not-open fallback. #588 asserts nothing about non-empty rendering beyond "the bulleted list is emitted and the empty-list unavailable text is not".
  - Option B: defer D2 entirely to #622 and ship only the resolver fix.
  - Rationale: B leaves the collapse that `issue.md` asks to address unresolved in #588. Under A, #588's assertions hold whether or not #622's annotation is present, so neither item's tests constrain the other's merge order. (Revised 2026-09-26: the earlier text allowed #622 to omit the section; #622 adopted D4-C, which keeps the section.)
- **D7 Python parity.**
  - Option A (adopted): apply the D2 status-distinction change to `build_issues_to_autoclose_section` (in `scripts/dev_tools/pr_context/render_pr_helpers.py`, or `autoclose.py` after #622 per D10) and its call site in `scripts/dev_tools/pr_context/collector.py`; no Python resolver change.
  - Option B: TypeScript-only change.
  - Rationale: `dev.pr-context` remains a live entry point and the two runtimes' outputs are kept verbatim-equivalent by convention.
- **D8 Merge order with #622 (added 2026-09-26).** The parallel run schedules by blast-radius contention only, and the derived cohorts place #622 before #588 on the conflict edge 588:622. No item may depend on another item's merge.
  - Option A (adopted): the plan is merge-order agnostic. Its first execution step synchronizes the branch with the then-current `origin/main`, detects which #622 changes are present, and every later task that touches a shared region locates it by symbol name and carries explicit instructions for both states (#622 merged first, the expected order; #622 not yet merged).
  - Option B: require #622 to merge first and fail closed otherwise.
  - Option C: require #588 to merge first (the previous assumption in #622's plan).
  - Rationale: B and C both create a cross-item merge dependency, which the parallel scheduler prohibits, and either would block when the cohort table is recolored.
- **D9 Synchronization method and scope anchor (added 2026-09-26).**
  - Option A (adopted): `git fetch origin`, record `git rev-parse origin/main` as the explicit sync SHA, and `git merge --no-edit <sync-sha>` into the branch (skipped when the sync SHA is already an ancestor of `HEAD`). Every scope diff is anchored to that recorded 40-character sync SHA. The SHA is re-derived and re-recorded if a later synchronization is required.
  - Option B: rebase onto `origin/main`.
  - Option C: anchor scope diffs to the parent of the commit that created the feature folder, or to the local `main` ref.
  - Rationale: a merge keeps the pushed branch fast-forward-only, so no force push is needed. Before synchronization the branch contains only this feature folder, so the merge cannot conflict. C is rejected because after synchronization a folder-creation anchor would attribute every upstream change (including #622's) to this item, and the local `main` ref is stale or absent in agent and parallel worktrees.
- **D10 Builder work already present after #622 (added 2026-09-26).** #622's plan may implement #588's builder parameter itself when #622 runs first (#622 spec "Composition with #588", second route).
  - Option A (adopted): detect presence by symbol. When the optional `ghAvailable` / keyword-only `gh_available` parameter, the exact empty-list unavailable body, its precedence, and the call-site argument are already present and behave as specified, #588 does not re-edit them. It verifies them, keeps its own tests as regression guards, and records a fail-before exception dossier for the builder-level criteria instead of a failing run. When any part is absent, #588 implements that part as specified here.
  - Option B: always re-implement and resolve conflicts manually.
  - Rationale: A avoids duplicate parameters and conflicting edits in files #622 has restructured, and the resolver fix (the root cause) keeps a genuine fail-before run in both orders.
- **D11 Assertions that cross #622's rendering (added 2026-09-26).**
  - Option A (adopted): tests for a non-empty list with `gh` unavailable assert that the bulleted entries are present and that the empty-list unavailable body `None (GitHub CLI unavailable; closing issues not verified)` is absent. They do not assert the absence of the phrase `GitHub CLI unavailable`, because #622's annotation line contains that phrase. No #588 test asserts that non-empty autoclose rendering is byte-for-byte unchanged from any earlier tree.
  - Option B: keep the absence-of-phrase assertion and require #622 to edit it.
  - Rationale: B makes #588's test fail as soon as #622 is merged, which is the cross-item dependency D8 removes.
- **D13 Ownership of tests for #622's annotation line (added 2026-09-26).** #622's spec (D14) anticipated that #588's H3 would assert #622's annotation line in the order where #588 merges first.
  - Option A (adopted): #588 adds no assertion about the annotation line in either order. Tests for the annotation belong to #622, which adds or updates them in its own change set whichever order applies; #588's H3 and its Python twin follow D11 only.
  - Option B: #588 asserts the annotation line when #622 has merged first.
  - Rationale: under A neither item's tests reference behaviour the other item introduces, so both remain correct under either merge order. B would couple #588's test to #622's text. #622's spec D14 should be reconciled with this decision on #622's side.
- **D12 Home of the composition-root test (added 2026-09-26; previously an in-execution amendment in the plan).**
  - Option A (adopted): place the test in a new sibling file `extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts`.
  - Option B: add it to `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`.
  - Rationale: that file was 499 lines when planned, so B would breach the 500-line cap. Recording the amendment here removes a spec edit from the execution phase.


## Proposed Fix

### Design summary (what changes where):
- Add `extensions/drm-copilot/src/lib/executable-resolver.ts` (D1): a pure resolver and a process-bound `defaultWhichGh`.
- Add optional `whichGh?: WhichGh` to `CollectPrContextServiceCallInput` in `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` and forward `input.whichGh ?? defaultWhichGh` into `collectAndWrite`. `GhClient`'s library default (`() => undefined`) stays inert so library-level tests remain PATH-independent.
- Add the optional availability flag to `buildIssuesToAutocloseSection` and pass availability from its call site in `collector-core.ts` (D2).
- Apply the equivalent change to `build_issues_to_autoclose_section` and its call site in `collector.py` (D7).
- Builder location (D8, D10): before #622 merges, the builders live in `render-pr-helpers.ts` and `render_pr_helpers.py`. #622 may move them into `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` / `scripts/dev_tools/pr_context/autoclose.py` and re-export them from the original modules, and may already have added the availability parameter. The implementation locates each builder by its definition at execution time and edits only the defining file, and only for the parts that are absent.

### Boundaries and invariants to preserve:
- Resolution order: explicit `ghPath` > injected `whichGh` > (service call only) `defaultWhichGh`.
- Not-installed, not-authenticated, and repository-unresolved messages are unchanged (D3).
- #588 makes no change to non-empty autoclose rendering, reference extraction, the raw-reference fallback, or the author-asserted and pending-primary derivations (#622 boundary). Whatever #622 has changed in those areas by execution time is preserved, not reverted.
- The existing empty-body texts `None (no verified closing issues and readiness not PASS)` and `None (no verified closing issues and no deterministic pending issue)` are unchanged when `gh` is available.
- The new unavailable text contains the word `unavailable`, so consumer rules keyed on "unavailable/unverified" continue to apply without edits.
- No file exceeds the 500-line cap after the change.

### Dependencies or blocked work:
- None blocking, and no merge-order dependency in either direction (D8). Sibling #622 is expected to merge first; it edits the same builders, the collectors, `jest.config.cjs`, and may create `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py`. The execution-time synchronization (D9) and presence detection (D10) handle both orders.
- Reaching the live MCP tool requires publishing `@danmoisan/drm-copilot-mcp` and rebuilding the VSIX after merge.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `extensions/drm-copilot/src/lib/executable-resolver.ts` (new)
- `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`, or `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` when #622 has moved the builder there (conditional, D10)
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (call-site change only; conditional, D10)
- `extensions/drm-copilot/jest.config.cjs` (coverage entries; each added only when absent)
- `scripts/dev_tools/pr_context/render_pr_helpers.py`, or `scripts/dev_tools/pr_context/autoclose.py` when #622 has moved the builder there (conditional, D10)
- `scripts/dev_tools/pr_context/collector.py` (call-site change only; conditional, D10)

#### Functions/classes/CLI commands impacted:
- New: `resolveExecutableOnPath`, `defaultWhichGh`.
- `collectPrContextServiceCall` and `CollectPrContextServiceCallInput`.
- `buildIssuesToAutocloseSection` / `build_issues_to_autoclose_section`.
- Observable through `mcp__drm-copilot__collect_pr_context`, `drmCopilotExtension.collectPrContext`, and `poetry run dev.pr-context`.

#### Data flow and validation changes:
- The service call now supplies a real resolver, so a resolvable `gh` reaches `gh auth status` and `gh repo view` through the injected runner, and the verified-closing-issues path runs when authentication succeeds.
- Resolver semantics: iterate non-empty PATH entries in order; on `win32`, try each PATHEXT extension in order (name already ending in a PATHEXT extension is tried as-is first); on other platforms, try the bare name; return the first candidate for which `exists` is true, else `undefined`. Unset PATHEXT falls back to `.COM;.EXE;.BAT;.CMD`. PATHEXT matching of an existing suffix is case-insensitive. Path joining and delimiter are selected from the `platform` argument (`path.win32` or `path.posix`).

#### Error handling and logging updates:
- No new error types. An unresolved `gh` yields the unchanged not-installed message; a resolved `gh` whose `auth status` fails yields the unchanged not-authenticated message.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the change set; a caller may also inject `whichGh: () => undefined` to restore the previous behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `resolveExecutableOnPath(options: { name: string; pathValue: string | undefined; pathExtValue: string | undefined; platform: NodeJS.Platform; exists: (candidate: string) => boolean }): string | undefined`.
- `defaultWhichGh(): string | undefined`.
- `CollectPrContextServiceCallInput.whichGh?: WhichGh` (optional).
- `buildIssuesToAutocloseSection(..., ghAvailable = true)` and `build_issues_to_autoclose_section(..., gh_available: bool = True)`; exact parameter shape follows each function's existing signature style.
- New summary text (empty list, `gh` unavailable): `None (GitHub CLI unavailable; closing issues not verified)`.

#### Required configuration keys and defaults:
- None. Environment inputs are `PATH` and `PATHEXT` as read by `defaultWhichGh`.

#### Backward-compatibility expectations:
- All new parameters are optional with defaults that preserve current behavior for existing callers of the builders and of `GhClient`.
- Summary output changes only in the empty autoclose body when `gh` is unavailable.

#### Performance constraints (latency/throughput/memory):
- Resolution performs at most one `exists` check per PATH entry and extension combination per call; no measurable latency constraint is imposed.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the MCP server process inherits a PATH that contains the `gh` install directory in the environments where `gh` works from the shell. The PATH of the original 2026-08-28 session is unknown and is not needed to explain the defect.
- Constraints (budget, performance, compatibility): 500-line file cap (on the 2026-09-25 tree `collector-output.ts` 494, `render-pr-helpers.ts` 481, `collector-core.ts` 475 lines; these counts change when #622 merges, so file-size budgets and line citations are re-derived from the synchronized tree at execution time); TS/Python output parity by convention; tests must be hermetic on Linux CI.
- External dependencies (services, libraries, releases): Node `path` and `fs` only; no new packages. Live effect depends on a later MCP package and VSIX release.

## Data / API / Config Impact
- User-facing or API changes: `collect_pr_context` reports GitHub CLI as available and authenticated where `gh` is resolvable and authenticated; the empty autoclose body distinguishes unavailable from absent.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or schema changes. New optional exported symbols in the extension library.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: the `gh` availability probe, with a test that a resolvable-but-extension-suffixed executable is detected on Windows; and the autoclose-verification path, with a test distinguishing "gh unavailable" from "gh available and issue not found", since those two states currently collapse to the same `None` output.
- [x] Integration scenario to retest: run the collector in a session where `gh auth status` succeeds and assert the summary reports the CLI as available and lists the verified autoclose issue.
- [x] Manual verification notes: after any fix, confirm end to end with `gh pr view <N> --json closingIssuesReferences`, which is GitHub's own parse of the keyword and therefore stronger evidence than grepping the PR body for the literal text.
- Consider making the two states textually distinct in the summary so a reader can tell a probe failure from a genuine absence of autoclose candidates.

- Regression tests to add or update:
  - Fail-first: `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` asserts that with an injected resolvable `gh` and a runner answering `auth status` and `repo view`, the summary contains `GitHub CLI authenticated for <owner/repo>`; and `extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts` (a sibling of `extension.collect-pr-context.test.ts`, per D12) sets a POSIX `PATH` (for example `/opt/gh-bin`), makes mocked `existsSync` true for `/opt/gh-bin/gh`, and asserts mocked `spawnSync` receives `/opt/gh-bin/gh` with `auth status`. Both fail on current code.
  - Existing service-call tests (`pr-context-service-call.test.ts`, `pr-context-service-call-target.test.ts`, `repo-automation-dispatch-pr-context-verification.test.ts`) inject `whichGh` explicitly; the misleading "auth fails" comment is corrected.
- Unit tests (Jest and pytest) for the fixed behavior and boundaries:
  - `extensions/drm-copilot/test/lib/executable-resolver.test.ts` (new) for the resolver.
  - `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts` and `collector-core.test.ts` for the unavailable body.
  - A Python unit test file mirroring `render_pr_helpers.py`, and `tests/scripts/dev_tools/test_pr_context_integration.py` offline scenario, for the Python unavailable body.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): empty or undefined PATH, empty PATH entries, unset PATHEXT, mixed-case PATHEXT, name already carrying an extension, first-match-wins across directories, non-win32 platform ignoring PATHEXT, not-found.
- Error handling and logging verification: resolved-but-unauthenticated `gh` produces the unchanged not-authenticated status and the unavailable autoclose body.
- Coverage impact and targets for changed lines/modules: line >= 85% and branch >= 75% for new and touched TS and Python production files; per-file `coverageThreshold` entries in `extensions/drm-copilot/jest.config.cjs` for `./src/lib/executable-resolver.ts` and `./src/lib/pr-context/render-pr-helpers.ts`; Python measured with `--cov=scripts.dev_tools.pr_context`.
- Toolchain commands to run (format -> lint -> type-check -> test): TS: Prettier, ESLint, `tsc`, dependency-cruiser, Jest with coverage. Python: Black, Ruff, Pyright, Pytest with coverage.
- Testing constraints: tests run on Linux CI and must not depend on remote refs such as `origin/main` (CI uses a depth-1 checkout), gitignored state, a real `gh` binary, network access, temporary files, or Windows drive roots/paths. Windows semantics are exercised through the resolver's `platform`, `pathValue`, `pathExtValue`, and `exists` parameters using drive-letter-free strings.
- Manual validation steps (if required): none before merge. The live `gh pr view <N> --json closingIssuesReferences` check is a post-release follow-up.


## Acceptance Criteria
- [ ] `resolveExecutableOnPath` with `platform: "win32"`, a Windows-style `pathValue` and `pathExtValue: ".COM;.EXE;.BAT;.CMD"`, and an injected `exists` containing only `<dir>\gh.exe` returns that `gh.exe` path for `name: "gh"`, verified by a test in `extensions/drm-copilot/test/lib/executable-resolver.test.ts`.
- [ ] `resolveExecutableOnPath` on `win32` matches PATHEXT extensions case-insensitively (for example PATHEXT `.exe` or a name `gh.EXE` resolves against an existing `gh.exe`), verified by a test.
- [ ] `resolveExecutableOnPath` with `platform: "linux"` returns `<dir>/gh` for the first PATH directory where `exists` is true, ignores PATHEXT, and returns the earlier directory's match when multiple directories contain `gh`, verified by tests.
- [ ] `resolveExecutableOnPath` returns `undefined` when no candidate exists, verified by a test.
- [ ] `resolveExecutableOnPath` returns `undefined` for an empty or undefined `pathValue` and skips empty PATH entries without error, verified by tests.
- [ ] `defaultWhichGh` delegates to `resolveExecutableOnPath` using `process.env.PATH`, `process.env.PATHEXT`, `process.platform`, and `fs.existsSync`, verified by a test that controls those inputs through mocks without touching the real filesystem.
- [ ] `collectPrContextServiceCall` accepts an optional `whichGh` and defaults it to `defaultWhichGh`; with an injected resolvable `gh` and a fake runner answering `auth status` and `repo view`, the runner receives the resolved path with `auth status` and the summary contains `GitHub CLI authenticated for <owner/repo>`. The test fails on the pre-fix code.
- [ ] The composition-root test in `extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts` (a sibling of `extension.collect-pr-context.test.ts`, per D12), with a POSIX `PATH` and mocked `existsSync`, asserts that mocked `spawnSync` receives the resolved `gh` path with `auth status`. The test fails on the pre-fix code.
- [ ] `GhClient`'s library default resolver remains `() => undefined`, and existing service-call tests inject `whichGh` explicitly so their code path does not depend on the host PATH.
- [ ] In the TypeScript port, when `gh` is unavailable and the autoclose list is empty, the `Issues to autoclose (verified or pending)` body is exactly `None (GitHub CLI unavailable; closing issues not verified)`, verified by tests in `render-pr-helpers.test.ts` and `collector-core.test.ts`.
- [ ] In the Python collector, when `gh` is unavailable and the autoclose list is empty, the same section body is exactly `None (GitHub CLI unavailable; closing issues not verified)`, verified by a Python unit test for `render_pr_helpers.py` and the offline scenario in `tests/scripts/dev_tools/test_pr_context_integration.py`.
- [ ] When `gh` is available, the empty-body texts `None (no verified closing issues and readiness not PASS)` and `None (no verified closing issues and no deterministic pending issue)` are unchanged in both runtimes, verified by existing and new tests.
- [ ] Relative to the execution-time sync SHA (D9): the not-installed, not-authenticated, and repository-unresolved status messages are unchanged; `gh-client-core.ts` and `github.py` have no diff; #588's diff does not modify the #622-owned derivation code or non-empty rendering branches; and with `gh` unavailable and a non-empty list, the bulleted entries are rendered and the empty-list unavailable body is not emitted (D11), verified by tests in both runtimes.
- [ ] New and touched TypeScript production files meet line coverage >= 85% and branch coverage >= 75%, and `extensions/drm-copilot/jest.config.cjs` contains exactly one per-file `coverageThreshold` entry each for `./src/lib/executable-resolver.ts`, `./src/lib/pr-context/render-pr-helpers.ts`, and, when the TypeScript builder is defined in `./src/lib/pr-context/autoclose.ts`, that file (an entry already supplied by #622 satisfies this).
- [ ] Touched Python production files under `scripts/dev_tools/pr_context` meet line coverage >= 85% and branch coverage >= 75%, measured with `--cov=scripts.dev_tools.pr_context`.
- [ ] All new and modified tests run on Linux CI and do not depend on remote refs (including `origin/main`; CI uses a depth-1 checkout), gitignored state, a real `gh` binary, network access, temporary files, or Windows drive roots/paths.
- [ ] No touched production or test file exceeds 500 lines.
- [ ] The full TypeScript toolchain loop (Prettier, ESLint, `tsc`, dependency-cruiser, Jest) and the full Python toolchain loop (Black, Ruff, Pyright, Pytest) complete clean in a single pass.
- [ ] The D5 `.cmd`/`.bat` spawn limitation is documented in the resolver module's documentation comment.

## Risks & Mitigations
- Technical or operational risks:
  - A PATHEXT hit on a `gh.cmd`/`gh.bat` shim fails to spawn under `shell: false` on patched Node releases and reports "installed but not authenticated" (D5).
  - Fixing the probe changes #622's observed behavior: the raw-reference fallback stops running when `gh` is resolvable. This reduces but does not remove #622's symptom.
  - Existing service-call tests could become host-PATH-dependent if not updated.
  - The fix has no effect on the live MCP tool until the package and VSIX are republished.
- Mitigations and rollbacks:
  - Document the shim limitation; official installers ship `gh.exe`.
  - Keep #622 open and scoped to scraping/filtering.
  - Require explicit `whichGh` injection in service-call tests (acceptance criterion).
  - Track the release and live verification as a post-release follow-up; rollback is a revert.

## Rollout & Follow-up
- Release/rollout steps: merge; publish `@danmoisan/drm-copilot-mcp` and rebuild the VSIX through the normal release process.
- Post-fix monitoring or clean-up tasks:
  - Post-release follow-up (not an acceptance criterion): run `collect_pr_context` in a session where `gh auth status` succeeds, confirm the summary reports `GitHub CLI authenticated for <owner/repo>` and lists the verified issue, then confirm with `gh pr view <N> --json closingIssuesReferences`.
  - File a follow-up issue for resolver consolidation (D4).
- Links: issue #588; sibling issue #622; originating PR #587 / issue #586; research `research/2026-09-26T02-10-pr-context-gh-detection-research.md`.
