# Research: collect_pr_context explicit target and empty-diff failure (issue #675, epic F6)

- **Feature folder:** `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/`
- **Epic:** `worktree-scoped-state-resolution`, feature F6, scope row 3.5
- **Issue:** #675 (bug, work mode `full-bug`)
- **Research date:** 2026-09-13
- **Tree:** worktree `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a41d019edfae43cb3`, branch `epic/worktree-scoped-state-resolution-integration`, HEAD `499e288a`
- **Verification method:** direct file reads and repository-wide `ripgrep` searches performed in this pass. Every citation below was re-derived in this pass. No command execution was available in this session (see Q9).

---

## Q1 — Where the target is resolved today

### Full call path

| # | Layer | File:line | What happens |
|---|---|---|---|
| 1 | MCP dispatch | `extensions/drm-copilot/src/mcp-tools.ts:176-178` | `case "collect_pr_context": return toMcpToolResult(await handleCollectPrContext(rawInput, service));` |
| 2 | Handler | `extensions/drm-copilot/src/mcp-handlers/collect-context-handlers.ts:18-24` | `resolveCollectPrContextToolInput(rawInput)` then `service.collectPrContext(input)`. **The fallback argument is omitted**, so `workspace_root` is mandatory at this boundary. |
| 3 | Input resolution | `extensions/drm-copilot/src/mcp-tool-inputs.ts:140-152` | Returns `{ workspaceRoot: normalizeWorkspaceRoot(args["workspace_root"], fallbackWorkspaceRoot), base: normalizeRequiredText(args["base"], "base") }`. Two fields only. |
| 4 | Workspace-root normalization | `extensions/drm-copilot/src/workflow-command-arguments.ts:294-308` | With `fallbackWorkspaceRoot === undefined` and `value === undefined`, throws `"workspace_root is required. The MCP server cannot infer the calling agent's checkout; pass the absolute worktree root explicitly."` |
| 5 | Service method | `extensions/drm-copilot/src/repo-automation-service.ts:157-169` | `collectPrContextServiceCall({ runner, fileSystem, workspaceRoot: input.workspaceRoot, base: input.base, log })`. |
| 6 | Service-call body | `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:103-142` | Joins the two artifact paths to `workspaceRoot` (lines 114-119) and calls `collectAndWrite({ base, repoRoot: input.workspaceRoot, out, appendixOut, append:false, includeUntracked:true, fs, runner, log })` (lines 121-131). **No `head` is passed.** |
| 7 | Render/write | `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:365-396` | `collectPrContext(options)` then builders then `writeOutput` twice. |
| 8 | Data pipeline | `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:115-366` | Builds the git client and runs the pipeline. |
| 9 | Git wrapper | `extensions/drm-copilot/src/lib/pr-context/git-client.ts:43-200` | Every invocation is `runner.run(["git", ...args], { cwd: this.cwdValue, allowError })` (lines 73-78). |
| 10 | PR comparison | `extensions/drm-copilot/src/lib/pr-context/render.ts:126-368` | Resolves base, head, merge-base and the range. |

### Every derivation point, classified

**Caller-supplied:**

- `base` — `pr-context-service-call.ts:78` → `collector-core.ts:118` → `render.ts:129,168-169`. Used verbatim as the requested base.
- `workspaceRoot` — the only location input the call accepts. It is used for three distinct purposes that the current design conflates:
  1. artifact output root (`pr-context-service-call.ts:114-119`);
  2. git `cwd` (`collector-core.ts:123,125`);
  3. repo-root probe subject (`git-client.ts:89-95`).

**Inferred from `workspace_root` (not from the call's actual target):**

- **Repository root** — `GitClient.resolveRoot()`, `git-client.ts:89-95`: if `<cwd>/.git` exists (probed through the injected `FileSystem`), returns `cwd`; otherwise runs `git rev-parse --show-toplevel`. Called at `collector-core.ts:124`; the client is then rebuilt against `resolvedRoot` at `collector-core.ts:125`.
- **Head branch** — `GitClient.branchName()`, `git-client.ts:111-113`, runs `git rev-parse --abbrev-ref HEAD` in that cwd. Consumed at `render.ts:143` and again at `collector-core.ts:182` (`extractIssueReferences(git.branchName())`). This is the primary defect site: `render.ts:193` computes `headRefResolved = headRef || branchName`, and because step 6 never supplies `head`, `headRef` is always `null` (`collector-core.ts:119`, `options.head ?? null`). The head is therefore always the invoking workspace's HEAD.
- **Head SHA** — `render.ts:194`, `git.revParse(headRefResolved || "HEAD")` → `git rev-parse --verify <ref>` (`git-client.ts:101-103`).
- **Merge base** — `render.ts:195`, `git.mergeBase(baseSha, headSha)` → `git merge-base <base> <head>` (`git-client.ts:174-176`).
- **Diff base/range** — `render.ts:196`, `revRange = ${mergeBase}..${headSha}`; the range diffs are `git diff --name-status|--numstat|--shortstat|--stat <mergeBase> <headSha>` at `render.ts:207-210` and again at `collector-core.ts:267-276`.
- **Working-tree state** — `git remote -v` (`render.ts:146`), `git status -sb` (`render.ts:147`), `git ls-files --others --exclude-standard` (`render.ts:148`), `git rev-parse --abbrev-ref --symbolic-full-name @{u}` (`render.ts:144`), and the staged/unstaged `git diff --name-status` / `git diff` pairs (`render.ts:344-349`). These are intrinsically per-worktree and cannot be redirected by a ref argument alone.
- **Current PR** — `collector-core.ts:142`, `gh.currentPr()` → `gh-client-details.ts:353-363` runs `gh pr view --json <fields>` with **no branch selector**, so the PR is resolved from the cwd worktree's HEAD. Its `closingIssuesReferences` feed `verifiedClosing` (`render.ts:155-156`).
- **Feature-doc discovery root** — `collector-core.ts:157`, `gatherFeatureExcerpts(fs, resolvedRoot, changedPaths)`.
- **CI target** — `collector-core.ts:305-314`, falls back to `git.revParse("HEAD")` when `headSha` is absent.

**Not derived from `process.cwd()` anywhere on this path.** `inferWorkspaceRoot` (`mcp-tools.ts:88-101`) does pass `process.cwd()` as a fallback, but that value is used only to populate `workspace_root` on the *failure* result (`mcp-tools.ts:129-142`); the success path re-resolves through `resolveCollectPrContextToolInput(rawInput)` with no fallback (`collect-context-handlers.ts:22`). Confirmed by the existing contract test at `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts:216-232`.

### Second entry point (VS Code command, not MCP)

`extensions/drm-copilot/src/repo-automation-command-registration-admin.ts:32-87` registers `drmCopilotExtension.collectPrContext`. It uses `getWorkspaceRoot()` (line 44) and, in prompt mode, `discoverPrBaseBranches(output, commandId, workspaceRoot)` (`pr-context-branches.ts:113-188`) plus `pickPrBaseBranch` (`pr-context-branches.ts:199-227`). `pr-context-branches.ts` resolves **base candidates only** — it enumerates `refs/remotes/origin` and `refs/heads` via `git for-each-ref` run in `workspaceRoot` (`pr-context-branches.ts:128-138,165-174`). It has no head/target resolution and does not participate in the defect except that it, too, runs git in the session's workspace root.

### Summary answer to Q1

The only caller-controlled inputs are `base` and `workspace_root`. Head branch, head SHA, merge base, diff range, working-tree state, and current-PR identity are all derived from whatever `workspace_root` points at. There is **no** explicit target-branch or target-worktree parameter anywhere between the MCP schema and `GitClient`.

One material mitigating fact for the fix: the plumbing for an explicit head already exists below the service-call layer. `CollectPrContextOptions.head` (`collector-core.ts:92`) and `BuildPrContextOptions.headRef` (`render.ts:79`) are already honoured (`render.ts:193`), and `test/lib/pr-context/collector-integration.test.ts:142` already exercises `head: "feature/docs"`. Only the MCP schema, `mcp-tool-inputs.ts`, the service contract, and `pr-context-service-call.ts` omit it.

---

## Q2 — Current empty-diff behaviour

### The code path that produces the summary on an empty diff

There is no empty-diff branch. Every section degrades to a placeholder:

- `collector-core.ts:266-283` — when `mergeBase` and `headSha` are both truthy, `git.diffRange(["--name-status", mergeBase, headSha])` and the `--numstat` variant run; otherwise the **working-tree** diff (`git diff --name-status` with no revisions) is used. Both variants tolerate a non-zero exit (`git-client.ts:197-199`, `allowError: true`).
- Empty text → `parseNumstatDetailed` returns `[0, 0, new Map()]` (`summary-helpers.ts:63-86`) and `parseNameStatusMap` returns an empty map (`summary-helpers.ts:96-114`).
- The bucket loop at `collector-core.ts:316-336` therefore produces three empty arrays.
- `bucketText` renders `` `${name}: 0 files` `` for an empty array (`summary-helpers.ts:270-276`). The summary's "Changed files overview" section (`collector-output.ts:230-235`) becomes exactly:

```
===== Changed files overview =====
Core logic changes: 0 files

Mechanical moves/renames: 0 files

Docs/templates/agents/tooling: 0 files
```

- Inside the appendix's context text, `render.ts:253-256` substitutes `"(none)"` for an empty name-status, shortstat and stat, and `render.ts:286` emits `Additions: 0\nDeletions: 0`.
- `render.ts:250` emits `"(none)"` for an empty `Commits in range`.

### Whether any caller distinguishes empty from populated

No. The evidence is a single literal:

`extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:136-141`

```ts
  return {
    tool: "collect_pr_context",
    workspaceRoot: input.workspaceRoot,
    summary: `Collected PR context against base '${input.base}'.`,
    artifacts: [summaryOut, appendixOut],
  };
```

The `summary` string is a function of `base` alone. `toMcpToolResult` (`mcp-tools.ts:103-127`) copies it through with `ok: true`. Nothing between `collectPrContext` and the MCP boundary reads a change count.

The only failure the surface can currently report is the artifact read-back verification introduced by issue #574 (`pr-context-service-call.ts:47-67`, raising `Failed to verify PR context artifact '<path>': ...`). That check verifies *that the bytes written are the bytes rendered*, not that the bytes describe anything.

### Mechanisms by which an empty diff is reachable

An empty "Changed files overview" is reachable through at least four distinct states, and they are **not** all equivalent. The record carries enough signal to separate three of them:

| # | Mechanism | Observable state on `collected.contextResult` | Distinguishable? |
|---|---|---|---|
| A | Head is an ancestor of base, i.e. `mergeBase === headSha` (branch identical to base, or already fully merged) | `mergeBase` and `headSha` both non-null and equal; `revRange` = `<sha>..<sha>` | Yes — compare `mergeBase` to `headSha`. |
| B | Wrong worktree: the invoking worktree's HEAD happens to be at/behind base | Indistinguishable from A at the data level | **No** — A and B are the same state. This is the #675 field observation. |
| C | Base ref does not resolve (`git rev-parse --verify <base>` exits non-zero, `git-client.ts:101-103` with `allowError` false) | The catch-all at `render.ts:300-316` fires: `resolvedBase`, `baseSha`, `headSha`, `mergeBase`, `revRange` are all reset to `null` and `prBlock` becomes `(FAILED to compute PR context: <message>)` | Yes — any of `mergeBase`/`headSha` is `null`. |
| D | Range is real but its net diff is empty (revert pairs, commits touching nothing) | `mergeBase !== headSha`, both non-null, name-status text empty | Yes — by elimination. |

Case C has a second-order effect worth recording: because `mergeBase`/`headSha` become `null`, `collector-core.ts:277-280` silently falls back to the **working-tree** diff. On a clean tree that is also empty, so a failed base resolution and a no-op branch currently produce visually similar summaries even though the appendix carries a `(FAILED to compute PR context: ...)` marker.

**Wrong-worktree cases that empty-diff detection cannot catch.** If the invoking worktree is on a *different* branch that does have commits ahead of base, the collector emits a fully populated, entirely wrong context. Failing on an empty diff does not address that case; only the explicit-target half of the fix does. The plan should state this boundary explicitly rather than implying the empty-diff guard closes the whole defect.

**Recommendation on error-message granularity.** Distinguish C ("base or head could not be resolved") from A/B/D ("the target has no changes against the base"), because the corrective actions differ: C is a bad `base` argument, A/B is a wrong target, and D is genuinely nothing to describe. Do **not** attempt to distinguish A from B: they are the same state in the git data, and any attempt would be a heuristic. The A/B message should instead name the resolved head ref, head SHA and merge base so the operator can see immediately that the head is not the branch they meant.

---

## Q3 — Tool-declaration parity

### Current schema, surface 1

`extensions/drm-copilot/src/mcp-tool-definitions.ts:37-54`

```ts
  {
    name: "collect_pr_context",
    description:
      "Collect PR context artifacts for an explicit base branch using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        base: {
          type: "string",
          description:
            "Explicit base branch or ref used for PR context collection.",
        },
      },
      required: ["workspace_root", "base"],
      additionalProperties: false,
    },
  },
```

### Current schema, surface 2

`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:50-67` — byte-identical body (verified by reading both). `workspaceRootProperty` is the shared import from `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts` in both files (`mcp-tool-definitions.ts:6`, `mcp-repo-automation-tool-definitions.ts:6`).

Repository-wide search for the description literal `Explicit base branch or ref used for PR context collection` returns exactly two files, both listed above. There is no third copy in `resources/`, `.codex/`, or elsewhere.

### Does a parity test already exist for `collect_pr_context`?

**No. Definitively no.**

Search performed: `ripgrep` for `toolDefinitions|REPO_AUTOMATION_TOOL_DEFINITIONS` across `extensions/drm-copilot/test/`. Five files import both arrays:

| File | What it asserts parity over |
|---|---|
| `test/mcp-repo-automation-tool-definitions.test.ts` | `resolve_policy_audit_template_asset` (lines 51-74), `push_down_copilot_customizations` (92-107), `push_down_codex_and_agents_customizations` (109-136), `run_codex_native_converter` (138-182, as two separate single-surface assertions, not a cross-surface equality). Plus a generic loop asserting **only** that every repo-automation definition lists `workspace_root` in `required` (216-232). |
| `test/mcp-parallel-validation-definitions.test.ts` | `validate_orchestration_artifacts` only (lines 27-118). |
| `test/mcp-epic-validation-definitions.test.ts` | `validate_orchestration_artifacts` epic types only (lines 9-14). |
| `test/mcp-plan-gate-warning-projection.test.ts` | `validate_orchestration_artifacts` warning projection only (lines 114-118). |
| `test/mcp-tools.push-down-claude.test.ts` | `push_down_claude_customizations` and `push_down_codex_and_agents_customizations` (lines 140-206). |

No test names `collect_pr_context` in a definition-parity context. The only `collect_pr_context` schema-adjacent assertion is `test/extension.list-mcp-tools.test.ts:66`, which checks that a rendered list line contains both `collect_pr_context` and `base` — a single-surface display assertion, not a two-surface equality.

**Consequence for the plan:** a parameter added to one definition file and not the other would pass today's suite. The plan must add a parity test. The preferred shape, given the existing precedent, is a generic cross-surface equality over *all* tools (`expect(toolDefinitions).toEqual(REPO_AUTOMATION_TOOL_DEFINITIONS)` or a per-tool `inputSchema` deep-equality loop), because a `collect_pr_context`-specific parity test would leave the same drift hazard open for every other tool. Note that the two arrays are **not** currently equal in full: `mcp-tool-definitions.ts:63-72` carries `enum` constraints on `run_codex_native_converter`'s `mode` and `source_ecosystem` that `mcp-repo-automation-tool-definitions.ts:76-83` omits. A blanket `toEqual` would fail today. A per-tool loop restricted to `properties` key sets and `required` arrays would pass and would still catch the drift class this feature cares about; that is the recommended scope.

---

## Q4 — Existing test surface and its seams

Tests live under `extensions/drm-copilot/test/`. There is no top-level `tests/` tree for this extension.

### `test/lib/pr-context/` inventory (16 files; 1 is infrastructure)

| File | Lines | Role |
|---|---|---|
| `tree-file-system.ts` | 153 | **Test infrastructure, not a test file.** `TreeFileSystem implements FileSystem` — a tree-backed in-memory filesystem with `glob`/`isFile`/`exists`/`isDirectory`/`listDirectory`/`readTextFile`/`writeTextFile`/`ensureDir`, plus a `writtenPaths: string[]` call log (lines 20-27) and an `ensuredDirs` log. |
| `pr-context-service-call.test.ts` | 276 | 8 tests over `collectPrContextServiceCall`. |
| `collector-core.test.ts` | 417 | `collectPrContext` pipeline. |
| `collector-output.test.ts` | 485 | `buildSummaryText` / `buildAppendixText` / `writeOutput` against hand-built `CollectedPrContext` fixtures. |
| `collector-output-freshness.test.ts` | 171 | Shared freshness header across both documents, also from hand-built records. |
| `collector-integration.test.ts` | 171 | One end-to-end `collectAndWrite` test. |
| `git-client.test.ts` | 294 | `GitClient` argv composition. |
| `render.test.ts` | 386 | `buildPrContext`. |
| `render-pr-helpers.test.ts` | 262 | — |
| `render-feature-excerpts.test.ts` | 257 | — |
| `gh-client-core.test.ts` | 262 | — |
| `gh-client-details.test.ts` | 436 | — |
| `feature-docs.test.ts` | 314 | — |
| `models.test.ts` | 147 | — |
| `summary-helpers.test.ts` | 294 | — |
| `verification-evidence.test.ts` | 456 | — |

### Injection seams, per suite

**`test/lib/pr-context/pr-context-service-call.test.ts`**

- `CommandRunner` fake: a local `class ScriptRunner implements CommandRunner` (lines 35-67) that re-implements the throw-on-non-zero contract (lines 37-42) and dispatches on `args.slice(1).join(" ")` prefix matching (lines 45-66). `gh` (matched as `args[0] === GH_PATH || args[0] === "gh"`, line 46) always fails, exercising the graceful-degradation path.
- `FileSystem` fake: `TreeFileSystem` seeded by `seedWorkspace()` (lines 70-76) with a `/workspace/.git` marker file (so `GitClient.resolveRoot()` short-circuits at `git-client.ts:91`) and the two discovery directories.
- Negative-path seam: `class DiscardingFileSystem extends TreeFileSystem` (lines 87-100) overrides `writeTextFile` to record the path and drop the bytes, driving the read-back verification failure.
- **Critical fact for this feature:** the `ScriptRunner` returns `ok("")` for every unmatched git subcommand (line 65), including every `diff`. Every test in this file therefore runs against a **completely empty diff**.

**`test/repo-automation-dispatch-pr-context-verification.test.ts`** (127 lines)

- Constructs the real service via `createRepoAutomationService` (lines 72-85) with an object-literal `fileSystem` (lines 45-62) and an object-literal `runner` whose `run` returns `{ stdout: "", stderr: "", code: 0 }` for git and `code: 1` for gh (lines 76-84).
- Calls `dispatchRepoAutomationTool("collect_pr_context", { workspace_root, base }, service)` — the true MCP dispatch boundary (lines 96-100, 113-117).
- The file's own header comment (lines 18-22) records the rule this feature must also honour: *"Neither test invokes the live MCP tool ... a live call would exercise the installed build rather than this branch."*
- Also runs against a completely empty diff.

**`test/extension.collect-pr-context.test.ts`** (a different seam: module mocks, not constructor injection)

- `jest.mock("vscode", ...)` (lines 32-67), `jest.mock("node:fs", ...)` (69-76), `jest.mock("node:child_process", ...)` (78-81).
- `setCollectorFileSystemState()` (lines 113-137) wires `writeFileSync` into a `writtenFiles: Map` and serves `readFileSync` from it, so the read-back verification passes.
- `setGitBranchDiscoveryState()` (lines 139-195) scripts `spawnSync` for `symbolic-ref` and the two `for-each-ref` calls and returns `{ status: 0, stdout: "", stderr: "" }` for everything else (lines 178-182). Because `SubprocessRunner` reads `completed.stdout` only when it `instanceof Buffer` (`src/lib/subprocess-runner.ts:116-119`), the string `""` yields `""` regardless. Every git call in this suite, including every `diff`, returns empty.
- Six tests drive the success path: lines 297, 321, 345, 401, 423, 442.

**`test/repo-automation-dispatch.test.ts`** — one test, lines 86-140, same object-literal seams, runner returns empty stdout for all git. Asserts `result.summary === "Collected PR context against base 'origin/main'."` (lines 136-138).

**`test/extension.integration.test.ts`** — three tests drive the command handler (lines 301, 317, 344) under the same `spawnSync` mock shape (lines 120-140), also all-empty git output.

**Suites that already drive a non-empty diff** (and would therefore be unaffected by an empty-diff guard): `collector-core.test.ts:145-152, 307-312, 354-362` and `collector-integration.test.ts:105-113` both return `M\t<path>` for `diff --name-status` and `1\t0\t<path>` for `diff --numstat`.

### How a test currently drives a specific git output

The established pattern in this tree is prefix dispatch on the joined subcommand string:

```ts
const sub = args.slice(1).join(" ");
if (sub.startsWith("rev-parse --abbrev-ref HEAD")) { return ok("feature/test"); }
if (sub.startsWith("merge-base")) { return ok("base-sha"); }
if (sub.startsWith("diff --name-status")) { return ok(`M\t${CHANGED}`); }
```

(`pr-context-service-call.test.ts:45-66`, `collector-integration.test.ts:79-115`, `collector-core.test.ts:130-154`.)

For the new table-driven tests this means each row can be expressed as a small map of `{ subcommandPrefix -> stdout }` overlaid on a shared default handler. Argv capture for the "which target did git actually see" assertion is already demonstrated at `repo-automation-dispatch.test.ts:110-111` (`gitCwds.push(options?.cwd)`); the same technique extends to capturing the full argv so a test can assert that the explicit target ref, not the session HEAD, reached `git rev-parse --verify` and `git merge-base`.

### Consequence the plan must absorb

If the empty-diff guard is placed in `collectAndWrite` or `collectPrContextServiceCall`, the following existing tests will begin to fail and must be updated to script a non-empty diff (or to assert the new failure deliberately):

- `test/lib/pr-context/pr-context-service-call.test.ts` — 8 tests.
- `test/repo-automation-dispatch-pr-context-verification.test.ts` — 2 tests.
- `test/repo-automation-dispatch.test.ts` — 1 test.
- `test/extension.collect-pr-context.test.ts` — 6 tests.
- `test/extension.integration.test.ts` — 3 tests.

That is approximately 20 existing tests across 5 files. This is the largest single piece of work in the feature and is not visible from the issue text. It is also the reason a guard placed *below* the service call (for example inside `collectPrContext`) would have a wider blast radius than one placed in `collectPrContextServiceCall`: `collector-core.test.ts` and `collector-integration.test.ts` already produce non-empty diffs and would be unaffected either way, but `collector-output.test.ts` and `collector-output-freshness.test.ts` build `CollectedPrContext` records directly and bypass `collectPrContext` entirely, so they are unaffected regardless of placement.

---

## Q5 — Coverage gates

Source: `extensions/drm-copilot/jest.config.cjs` (278 lines).

### `coverageThreshold`

- **There is no `global` key.** The file states this explicitly at lines 20-24 and repeats the warning at lines 215-216 and 222-223: *"This map carries no `global` key, so a new production file without its own entry here would be completely ungated."*
- The map is **per-file**, keyed by exact `./src/...` path. There are no glob entries.
- Every entry uses the same numbers: `{ lines: 85, branches: 75 }`.

### Entries that cover this feature's likely edit set

| Path | Gated? | Line |
|---|---|---|
| `./src/lib/pr-context/pr-context-service-call.ts` | Yes | 29-32 |
| `./src/lib/pr-context/collector-core.ts` | Yes | 33-36 |
| `./src/lib/pr-context/collector-output.ts` | Yes | 37-40 |
| `./src/lib/pr-context/summary-helpers.ts` | Yes | 41-44 |
| `./src/mcp-tool-definitions.ts` | Yes | 85-88 |
| `./src/mcp-repo-automation-tool-definitions.ts` | Yes | 81-84 |
| `./src/mcp-tool-inputs.ts` | Yes | 89-92 |
| `./src/mcp-tools.ts` | Yes | 170-173 |
| `./src/repo-automation-service.ts` | Yes | 61-64 |
| **`./src/lib/pr-context/git-client.ts`** | **No entry** | — |
| **`./src/lib/pr-context/render.ts`** | **No entry** | — |
| **`./src/lib/pr-context/models.ts`** | **No entry** | — |
| **`./src/mcp-handlers/collect-context-handlers.ts`** | **No entry** | — |
| **`./src/repo-automation-service-contract.ts`** | Deliberately omitted as interface-only (documented at lines 174-180 and 272-276) | — |

**Explicit statement required by the delegation:** if this feature creates a new production file under `src/` (for example a `pr-context-target.ts` or an `empty-diff-guard.ts` extracted to stay under the 500-line cap), that file would land **completely ungated** unless a matching `coverageThreshold` entry is added. The plan must include adding the entry as an acceptance criterion, following the precedent comments already in the file at lines 215-220 (issue #643) and 222-227 (issue #596).

Additionally, if this feature modifies `git-client.ts`, `render.ts`, `models.ts`, or `collect-context-handlers.ts`, those files are currently ungated. Policy requires the changed lines to meet 85/75; the plan should add threshold entries for any of them it touches, consistent with how #574 added the four pr-context entries.

### `collectCoverageFrom` and `coveragePathIgnorePatterns`

- `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` (line 17), with the policy rationale in the comment at lines 14-16.
- **There is no `coveragePathIgnorePatterns` key in the file at all.**
- **No entry excludes a production path under `src/`.** The only negation is `!src/**/*.d.ts`, which is a declaration-file exclusion and is permitted by the Coverage Exclusion Policy (type-only, no executable behaviour).
- The two files omitted from the *threshold map* (`src/lib/subagent-tree/types.ts`, `src/repo-automation-service-contract.ts`) remain inside `collectCoverageFrom`, i.e. they are measured but not gated. That is the policy-conformant treatment and is documented in place (lines 93-101, 174-180).

**Conclusion:** there is no Coverage Exclusion Policy violation to perpetuate. Other config: `coverageProvider: "v8"` (line 10), `collectCoverage: false` by default (line 13), reporters `lcov` + `text-summary` (line 18), output to `<rootDir>/coverage` (line 19).

---

## Q6 — File-size headroom (cap: 500 lines)

Counts re-derived in this pass by line-count over each file. The delegation's known counts are confirmed for `pr-context-service-call.ts`, `git-client.ts`, `collector-core.ts`, `models.ts`, and `pr-context-branches.ts`.

| File | Lines | Headroom | Assessment |
|---|---|---|---|
| `src/repo-automation-service.ts` | **498** | **2** | **Cannot absorb any change.** The `collectPrContext` method at lines 157-169 must forward a new field. Adding one property to the delegated object literal is +1 line, leaving zero. Any doc-comment update overruns. **Extraction or a same-line change is mandatory.** |
| `src/lib/pr-context/collector-output.ts` | **485** | **15** | Tight. Only touched if the guard lands in `collectAndWrite`. A guard plus its doc comment plausibly exceeds 15 lines. |
| `src/mcp-tool-inputs.ts` | **480** | **20** | Tight. `resolveCollectPrContextToolInput` (lines 140-152) must gain the new field plus validation. 20 lines is plausible but leaves nothing. The file already has a split precedent (`mcp-tool-inputs-push-down.ts`, `mcp-tool-inputs-potential-to-issue.ts`, `mcp-tool-inputs-discovery.ts`, `mcp-tool-inputs-subagent-tree.ts`), so extraction is idiomatic here. |
| `src/lib/pr-context/collector-core.ts` | **475** | **25** | **Specifically assessed per the delegation.** 25 lines is enough for a small guard *function call* but not for the guard's implementation plus doc comment plus the error-message construction, which would realistically be 30-50 lines to cover the three distinguishable states from Q2. **Recommendation: do not implement the empty-diff guard inside `collector-core.ts`.** Place it in a new small module (for example `src/lib/pr-context/diff-emptiness.ts`) exporting a pure classifier over `{ mergeBase, headSha, nameStatusText }`, and call it from `pr-context-service-call.ts` (142 lines, 358 of headroom). A pure classifier is also the easiest thing to drive with table-driven tests and the easiest to bring to 85/75 coverage. It requires a new `coverageThreshold` entry (Q5). |
| `src/mcp-tool-definitions.ts` | 457 | 43 | Adequate for one property (~7 lines). |
| `src/mcp-repo-automation-tool-definitions.ts` | 420 | 80 | Adequate. |
| `src/lib/pr-context/render.ts` | 410 | 90 | Adequate; likely no change needed since `headRef` is already honoured. |
| `src/workflow-command-arguments.ts` | 410 | 90 | Adequate if a new normalizer is needed. |
| `src/mcp-tools.ts` | 348 | 152 | Adequate; probably no change needed. |
| `src/lib/pr-context/models.ts` | 312 | 188 | Adequate. |
| `src/pr-context-branches.ts` | 227 | 273 | Adequate; likely out of scope. |
| `src/lib/pr-context/git-client.ts` | 215 | 285 | Adequate. |
| `src/repo-automation-service-contract.ts` | 198 | 302 | Adequate. |
| `src/lib/pr-context/index.ts` | 115 | 385 | Adequate (add exports at lines 100-115 if a new module is introduced). |
| `src/lib/pr-context/pr-context-service-call.ts` | **142** | **358** | The natural home for the new logic. |
| `src/mcp-handlers/collect-context-handlers.ts` | 24 | 476 | Adequate. |

### Test-file headroom

| File | Lines | Headroom |
|---|---|---|
| `test/lib/pr-context/collector-output.test.ts` | **485** | **15** — effectively full. |
| `test/lib/pr-context/collector-core.test.ts` | 417 | 83 |
| `test/lib/pr-context/pr-context-service-call.test.ts` | **276** | 224 — but the new table-driven cross-product suite (target × diff-state) plus the updates to the 8 existing tests will consume much of it. If the table exceeds the budget, add a sibling file (`pr-context-service-call-target.test.ts`), matching the existing split precedent (`collector-output-freshness.test.ts` split from `collector-output.test.ts`). |
| `test/repo-automation-dispatch-pr-context-verification.test.ts` | 127 | 373 |
| `test/lib/pr-context/collector-integration.test.ts` | 171 | 329 |
| `test/lib/pr-context/tree-file-system.ts` | 153 | 347 |
| `test/mcp-repo-automation-tool-definitions.test.ts` | (not re-counted; parity test may go here or in a new file) | — |

**Flagged files that cannot absorb their change in place:** `src/repo-automation-service.ts` (2 lines) and, for the guard specifically, `src/lib/pr-context/collector-core.ts` (25 lines) and `src/lib/pr-context/collector-output.ts` (15 lines). `src/mcp-tool-inputs.ts` (20 lines) is borderline and should be treated as requiring extraction if the new validation is more than a single normalizer call.

---

## Q7 — Required vs optional-with-fallback

### Enumeration of in-repo callers

Repository-wide `ripgrep` for `collect_pr_context|collectPrContext|collect-pr-context`, scoped to `.claude/`, `.codex/`, `scripts/`, `docs/`, and `extensions/drm-copilot/src/`.

**Agent-prompt / configuration callers (11 files under `.claude/`):**

| File | Nature |
|---|---|
| `.claude/skills/orchestrate/SKILL.md:185` | Prose instruction; **no arguments given**. |
| `.claude/skills/epic-orchestrate/SKILL.md:108` | Prose reference. |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md:171` | Prose: *"Refresh the PR-context bundle with `mcp__drm-copilot__collect_pr_context` using base branch `main`"*. Base named in prose; no other argument. |
| `.claude/skills/pr-base-branch-merge-base/SKILL.md:3,13,47` | The only document that prescribes an argument shape: line 47, *"`mcp__drm-copilot__collect_pr_context` with `base=<resolved-PRBaseBranch>`"*. |
| `.claude/agents/orchestrator.md:23,93` | Line 23 is a `tools:` frontmatter allowlist entry; line 93 is prose with no arguments. |
| `.claude/agents/epic-orchestrator.md:17` | Frontmatter allowlist only. |
| `.claude/agents/parallel-orchestrator.md:25` | Frontmatter allowlist only. |
| `.claude/settings.json:19` | Permission allowlist entry only. |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1:57,64,71,85,92` | `required_mcp_tools` arrays — name only, no arguments. |
| `.claude/hooks/enforce-pr-author-skill.ps1:12` | Comment describing the sequence. |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1:215,221,234` | Denial-message text instructing the operator to run the tool. No arguments. |

**Codex-surface callers (7 files under `.codex/`):**

- `.codex/config.toml:9` (`enabled_tools` list) and `:34-35` (`approval_mode = "approve"`). Name only; **no input schema**.
- `.codex/agents/orchestrator.toml:173` and the five variants `orchestrator-c1`..`c4`, `orchestrator-c3-elevated` — each a bullet naming the tool in an allowlist. No arguments.

**Code callers (TypeScript, in-repo):**

1. `extensions/drm-copilot/src/mcp-handlers/collect-context-handlers.ts:18-24` — the MCP handler.
2. `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts:46` and `:80` — the VS Code command, twice (direct-invocation branch and quick-pick branch).
3. `extensions/drm-copilot/src/repo-automation-service.ts:157` — the service implementation.
4. Test callers (not production): `test/repo-automation-dispatch.test.ts:121`, `test/repo-automation-dispatch-pr-context-verification.test.ts:96,113`, `test/lib/pr-context/pr-context-service-call.test.ts` (×8).

**Non-callers that merely rewrite the identifier** (record so they are not mistaken for callers): `src/lib/codex-native-converter/rewrites-rules.ts:148-151`, `src/lib/push-down/reference-rewrites.ts:68`, and the Python equivalents `scripts/dev_tools/codex_native_converter/rewrites.py:216-219` and `scripts/dev_tools/push_down_copilot_customizations_rewrites.py:81`. These map the VS Code command ID to the MCP tool name; they are unaffected by a schema change.

**Counts:** 18 agent-prompt/configuration callers (11 Claude-surface + 7 Codex-surface), 4 production code call sites (3 distinct files), and 11 test call sites. **Both kinds are present.** Not one of the 18 prompt-surface callers currently passes any argument beyond `base`, and most pass nothing at all.

### The call shape `orchestrate` and `orchestrator.md` prescribe

- `.claude/skills/orchestrate/SKILL.md:185`: *"The orchestrator first refreshes the PR-context artifact via `mcp__drm-copilot__collect_pr_context` (or the equivalent context-collection mechanism), which writes `artifacts/pr_context.summary.txt`."* — no parameters named, and an explicit escape hatch ("or the equivalent context-collection mechanism").
- `.claude/agents/orchestrator.md:93`: *"The orchestrator first refreshes the PR-context artifact via `mcp__drm-copilot__collect_pr_context`, then runs the orchestrator-state validator ... before delegating to `Agent(pr-author)`."* — no parameters named.
- The only prescribed argument anywhere is `base=<resolved-PRBaseBranch>` at `.claude/skills/pr-base-branch-merge-base/SKILL.md:47`.

### Recommendation: **optional-with-fallback, with a mandatory observable fallback record**

Reasoning, in order of weight:

1. **A required parameter breaks 18 prompt-surface callers in a way the type system cannot catch.** The 4 production code call sites are compile-checked and would be fixed mechanically. The 18 prompt-surface callers are prose. A required `target_ref` would cause every existing orchestration prompt to produce a hard MCP validation error (`additionalProperties: false` plus `required`) the first time it runs after F7 ships. Because F7 (`taskmaster-push-down-and-resume`) delivers this change into TaskMaster, the failure would land in a consumer repository whose prompts this repository does not control.

2. **The fallback is not a silent fallback if it is recorded.** The epic's prohibition (`epic.md:97-100`, fix 1) is *"Use the session root only when the call genuinely has no target"* — it permits a fallback and forbids silence. The issue text (`issue.md:72`) states the same: *"an optional target must make the fallback observable in the output."* An optional parameter with a mandatory, machine-readable fallback record satisfies both.

3. **A required parameter does not, by itself, prevent the defect.** The #675 field failure was a caller supplying a *correct-looking but wrong* `workspace_root`. A caller who is confused about which worktree it is acting for will supply a wrong `target_ref` just as readily as a wrong `workspace_root`. What actually caught the defect in the field was the human noticing a zero-line diff. The empty-diff guard, not the parameter's requiredness, is the load-bearing half of the fix.

4. **Requiredness is recoverable later; a broken consumer is not.** Shipping optional-with-observability now, and tightening to required in a follow-up once every in-repo prompt has been updated to pass it, is the lower-risk ordering. The epic's own F7 delivery step is the natural point to assess whether the tightening is safe.

### Concretely, how the fallback must be observable

Propose **both** artifacts, because the two have different consumers:

**(a) A field in the returned record.** Extend `CollectPrContextServiceCallResult` (`pr-context-service-call.ts:84-89`) and the MCP result (`mcp-tools.ts:61-86`, and the mapping at `:103-127`) with an explicit provenance field. Recommended shape:

- `target_resolution`: one of `"explicit"` (the caller supplied the target) or `"session-fallback"` (the target was derived from `workspace_root`'s HEAD).
- `resolved_head_ref` and `resolved_head_sha`: the values actually used, sourced from `collected.contextResult.headRef` / `.headSha` (`models.ts:100-101`), so a caller can compare them against what it intended.

This is what an agent caller can branch on. It is machine-readable and cannot be missed by a reader skimming prose.

**(b) A line in `artifacts/pr_context.summary.txt`.** The summary already has the right home: the `Base/Head` block at `collector-output.ts:169-175` prints `Base ref (requested)`, `Base ref (resolved)`, `Head ref (resolved)`, `Merge base` and `Range`. Add a sibling line immediately after `Head ref (resolved)`, of the form:

```
Head ref (source): session fallback — no explicit target supplied; derived from workspace_root '<root>'
```

or `Head ref (source): explicit target '<ref>'` in the supplied case. This is what a human reviewer and `Agent(pr-author)` see, and the `Base/Head` block is already the section a reviewer reads to sanity-check the comparison. Placing it adjacent to `Head ref (resolved)` means a fallback cannot be read without the head it produced being read in the same glance.

The summary line costs roughly 6-10 lines in `collector-output.ts`, which has only 15 lines of headroom (Q6) — a further reason to route the rendering through a small helper in a new module rather than growing `collector-output.ts` in place.

**Naming note.** Prefer `target_ref` (a git ref) over `target_worktree` (a path) as the parameter. A ref is sufficient for the range diff, because all worktrees of a repository share one object store and one ref namespace, so `git rev-parse --verify <target-branch>` and `git merge-base` resolve correctly from any worktree. A path-valued `target_worktree` would additionally change where the *working-tree* sections (`git status -sb`, staged/unstaged diffs, untracked files, `render.ts:146-148,344-349`) are read from and where `gh pr view` resolves its current PR (`gh-client-details.ts:353-363`) — a larger and less well-bounded change. If the plan wants working-tree fidelity too, it should treat `target_worktree` as a *separate, later* decision and keep `workspace_root` as the artifact-output root, because the `enforce-pr-author-skill.ps1` hook reads `artifacts/pr_context.summary.txt` as a **relative** path (`.claude/hooks/enforce-pr-author-skill.ps1:48,64,137,141`) resolved against the hook's own cwd — i.e. the invoking session. Relocating the artifacts to the target worktree would break that hook.

---

## Q8 — Bundled-payload and Codex mirror obligations

### Bundled-payload mirroring

**Does not apply to this feature as currently scoped. Definitive: no.**

The epic's rule (`epic.md:174-184`) is scoped explicitly: *"applies to every child that edits `.claude/**`"* and *"every child that edits a file under `.claude/**` must also update the corresponding file under `extensions/drm-copilot/resources/claude-customizations/.claude/**`"*. F6's edit set is TypeScript under `extensions/drm-copilot/src/` and tests under `extensions/drm-copilot/test/`.

Search performed: `ripgrep` for `collect_pr_context|collectPrContext` across `extensions/drm-copilot/resources/`. 27 files match. Every one of them is a *prose or configuration* reference inside a bundled customization payload (agent markdown, skill markdown, `settings.json`, `orchestration-routing.json`, `OrchestratorStateRoutingMatrix.psm1`, `.codex/config.toml`, `.codex/agents/*.toml`). **None of them contains the tool's input schema.** The schema literal `Explicit base branch or ref used for PR context collection` appears in exactly two files repository-wide, both under `extensions/drm-copilot/src/`.

**One conditional the plan must honour:** if the plan decides to update `.claude/skills/pr-base-branch-merge-base/SKILL.md:47` (the only document prescribing an argument shape) or `.claude/skills/orchestrate/SKILL.md:185` to document the new parameter, then the mirroring obligation **does** activate for those specific files, and the corresponding `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...` copies must be updated in the same change. Both mirrors exist (confirmed in the 27-file match list). The plan should either (a) explicitly defer all `.claude/**` prose updates to F7 or a follow-up, or (b) explicitly include the paired mirror edits. It must not do (a) implicitly.

### Codex mirror of this TypeScript surface

**Does not exist. Definitive: no.**

Search performed: `ripgrep` for `collect_pr_context|collectPrContext` across `.codex/`. Seven files match:

- `.codex/config.toml:9` — the tool name in `enabled_tools`.
- `.codex/config.toml:34-35` — `[mcp_servers.drm-copilot.tools.collect_pr_context]` with `approval_mode = "approve"` and nothing else.
- `.codex/agents/orchestrator.toml:173` and the five variants (`-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`), each a single bullet naming the tool.

None declares an input schema, and none contains TypeScript. Codex consumes the tool through the published npm MCP server (`.codex/config.toml:4-5`: `command = "npx"`, `args = ["-y", "@danmoisan/drm-copilot-mcp@1.1.11"]`), which is built from the same `src/` this feature edits. There is therefore **no Codex parity task** for F6, and the plan must not carry one.

Relatedly, `epic.md:195-202` names Codex parity obligations only for F2 and F3 and explicitly clears F4; F6 is not named, consistent with this finding.

---

## Q9 — Baseline toolchain state

**Not executed. This session had no command-execution tool available** (the tool set was `Read`, `Grep`, `Glob`, `WebFetch`, `Write`, `Edit`). No `npx prettier --check`, `npx eslint`, `npx tsc --noEmit`, or Jest run could be performed, and no exit codes or coverage headline values can be reported. Recording an unmeasured baseline would violate the evidence-first requirement, so none is recorded and no baseline evidence artifact was written.

**This is a gap the plan must close before implementation, not a finding that the baseline is healthy.** The baseline state is **unknown**.

### Prescribed baseline commands for the implementing agent

Run from `extensions/drm-copilot/`. Note that the repository's own scripts differ from the commands named in the delegation; both are listed so the implementer does not silently substitute one for the other.

| Stage | Repository script (`package.json:202-213`) | Underlying command | Note |
|---|---|---|---|
| Format | `npm run format` | `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | The repo script is `--write`, not `--check`. For a baseline, use `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` so the baseline is non-mutating. A bare `npx prettier --check .` would additionally scan `node_modules`, `out/`, and `coverage/` and is not the repository's scope. |
| Lint | `npm run lint` | `eslint --no-error-on-unmatched-pattern src test` | |
| Type check | `npm run typecheck` | `tsc -p ./ --noEmit` | |
| Tests + coverage | `npm run test:coverage` | `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | Note tests are run through `run-jest.cjs`, not `npx jest` directly. |

Scoped pr-context coverage run: `node run-jest.cjs --coverage --coverageReporters=text-summary test/lib/pr-context test/repo-automation-dispatch-pr-context-verification.test.ts test/extension.collect-pr-context.test.ts`. Be aware that a path-scoped run still evaluates the **whole** per-file `coverageThreshold` map against `collectCoverageFrom: ["src/**/*.ts"]`, so a scoped run will report threshold failures for unrelated files that the scoped suites do not exercise. Record the full-suite numbers as the authoritative baseline and use the scoped run only for iteration speed.

Baseline artifacts, if written, go to `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/baselines/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, using the `Timestamp:` / `Command:` / `EXIT_CODE:` / `Output Summary:` schema. Not `artifacts/baselines/`.

---

## Candidate approaches

### Approach A (recommended) — optional `target_ref` threaded to the existing `head` plumbing, plus a pure empty-diff classifier called from the service-call layer

**Description.** Add an optional `target_ref` string to both tool schemas and to `resolveCollectPrContextToolInput`. Thread it through `RepoAutomationService.collectPrContext` into `collectPrContextServiceCall`, which forwards it as `head` to `collectAndWrite` — the parameter that `collector-core.ts:119` and `render.ts:193` already honour. Return `collectAndWrite`'s rendered record augmented with the collected `headRef`/`headSha` and a `target_resolution` discriminant. Add a new pure module classifying the diff state from `{ mergeBase, headSha, nameStatusText }` into `ok` / `unresolved-refs` / `no-changes`, and raise from `collectPrContextServiceCall` on the two failure states. Add a cross-surface schema-parity test.

**Advantages.**
- Reuses plumbing that already exists and is already tested (`collector-integration.test.ts:142`), so the change below `pr-context-service-call.ts` is close to zero.
- Keeps the guard in the file with the most headroom (358 lines) and out of the three files that have almost none.
- The classifier is a pure function, which is the easiest shape to reach 85/75 coverage on and matches the repository's preference for separating pure logic from I/O (`.claude/rules/general-code-change.md`, "Separation of concerns").
- Does not break any prompt-surface caller.

**Limitations.**
- Requires updating ~20 existing tests across 5 files to script a non-empty diff (Q4).
- Requires a new `coverageThreshold` entry for the new module (Q5), and possibly a helpers extraction from `repo-automation-service.ts` (2 lines of headroom, Q6).
- Does not redirect the working-tree sections or `gh pr view`; those remain session-scoped. This must be stated as a documented limitation, not left implicit.

**Alignment with repo conventions.** High. Mirrors the `new-potential-bug-entry-service-call.ts` and `#574` precedents already cited in `pr-context-service-call.ts:1-20`.

### Approach B (rejected) — required `target_worktree` path parameter, with the collector's git cwd redirected to it

Rejected for three reasons, each independently sufficient: it breaks 18 prompt-surface callers with no compile-time signal (Q7); it relocates the artifact outputs or else creates a second root concept, and relocating them breaks `enforce-pr-author-skill.ps1`, which reads `artifacts/pr_context.summary.txt` as a path relative to the invoking session (Q7); and a path parameter widens the change to the working-tree and `gh pr view` paths, which is a materially larger surface than a C2-banded feature (`epic.md:274`) should carry.

---

## Behaviour semantics

### Success conditions

1. `workspace_root` present and absolute → artifacts are written beneath it, unchanged from today.
2. `base` present → used as the requested base, unchanged from today.
3. `target_ref` present → it is the head ref; `resolved_head_ref` reflects it; `target_resolution = "explicit"`.
4. `target_ref` absent → head is `git rev-parse --abbrev-ref HEAD` in `workspace_root`; `target_resolution = "session-fallback"`; the fallback appears in both the returned record and the summary's `Base/Head` block.
5. The computed name-status diff is non-empty → the call returns `ok: true` with both artifacts written and read-back-verified.

### Failure conditions

1. `workspace_root` missing → existing error at `workflow-command-arguments.ts:300-302`, unchanged.
2. `base` missing → existing error from `normalizeRequiredText`, unchanged.
3. Base or head could not be resolved (`mergeBase === null || headSha === null`, i.e. the `render.ts:300-316` catch-all fired) → **new** failure naming the requested base, the head ref attempted, and the underlying git message.
4. Refs resolved but the diff is empty → **new** failure naming the resolved head ref, head SHA, merge base, and the resolved base, phrased so that an operator can see at a glance that the head is not the branch they meant.
5. Artifact read-back mismatch → existing error at `pr-context-service-call.ts:57-66`, unchanged and still checked.

### Ordering rules

The empty-diff check must run **after** `collectAndWrite` returns (so the artifacts are still written and available for diagnosis) and **before** the success record is constructed. Whether the artifacts should be written at all on a failing diff is a design decision the plan must settle; recommendation is to **write them**, because the summary is the operator's primary diagnostic for *why* the diff was empty, and because not writing them would change the `writtenPaths == reportedArtifacts` invariant that `pr-context-service-call.test.ts:156-175` guards. The existing read-back verification (lines 133-134) should still run first, so a write failure is reported as a write failure rather than being masked by an empty-diff error.

### Edge cases

- `target_ref` supplied but does not exist → falls into failure condition 3 via `git rev-parse --verify` raising inside the `render.ts` try block.
- `target_ref` supplied and equal to `base` → failure condition 4.
- Detached HEAD in the fallback path → `branchName()` returns `HEAD`; `revParse("HEAD")` still resolves. Behaviour is unchanged; the fallback record makes it visible.
- `gh` unavailable → unchanged degradation (`collector-core.ts:133-140`); must remain a success, as `pr-context-service-call.test.ts:237-257` asserts.
- Empty `target_ref` string → must be rejected by input validation, not silently treated as absent, or the fallback becomes silent again.

---

## Requirements mapping

| Epic/issue requirement | Source | Proposed realization |
|---|---|---|
| Explicit target branch/worktree | `epic.md:111-112`, `issue.md:35` | Optional `target_ref` on both schemas; threaded to the existing `head` option. |
| Fail loudly on empty diff | `epic.md:111-112`, `epic.md:341` | New pure classifier; raise from `collectPrContextServiceCall`; surfaces as `ok: false` via `mcp-tools.ts:129-142`. |
| Fallback must be observable | `issue.md:72`, `epic.md:97-100` | `target_resolution` + `resolved_head_ref`/`resolved_head_sha` on the result record, plus a `Head ref (source):` line in the summary's `Base/Head` block. |
| Both declarations must not drift | `issue.md:61` | New cross-surface parity test (none exists — Q3). |
| Table-driven tests over target × diff-state | `issue.md:68` | Extend `test/lib/pr-context/pr-context-service-call.test.ts` (or a sibling file) using the existing `ScriptRunner` + `TreeFileSystem` seams. |
| No production file over 500 lines | `epic.md:14` | New module for the classifier; assess extraction for `repo-automation-service.ts` (2 lines) and `mcp-tool-inputs.ts` (20 lines). |
| Line >= 85%, branch >= 75% | `epic.md:15`, `.claude/rules/quality-tiers.md` | Add a `coverageThreshold` entry for every new or newly-touched-but-ungated file (Q5). |
| No acceptance criterion may call the live MCP tool | `issue.md:70` | See Automation Feasibility. |

**No numeric acceptance criterion is proposed in this research.** Where counts appear above (18 prompt-surface callers, 4 production call sites, ~20 affected tests, 16 files in `src/lib/pr-context/`), they are descriptive findings for planning, not proposed `spec.md` assertions. If the plan wishes to promote any of them into an acceptance criterion, a `## Numeric Derivation Evidence` section with primary and independent cross-check enumerations must be added first; this research does not supply one and therefore withholds every numeric assertion from the acceptance criteria.

---

## Testing implications

Consistent with `.claude/rules/general-unit-test.md` and `.claude/rules/general-code-change.md`. No test code is written here.

1. **Table-driven cross-product, at the service-call layer.** Rows over `{ target: explicit | absent } × { diff: populated | empty-refs-resolved | empty-refs-unresolved }`. Six rows. Assertions per row: the argv the runner actually received (does `git merge-base` name the explicit target's SHA or the session HEAD's?), the `target_resolution` value, the presence or absence of the raise, and the error text when raised. Drive it with the existing `ScriptRunner`/`TreeFileSystem` seams; capture argv the way `repo-automation-dispatch.test.ts:110-111` captures `cwd`.

2. **Pure-classifier unit tests.** Direct tests over the new module's input record, covering all four Q2 mechanisms plus the boundary where `mergeBase === headSha`. This is where the branch coverage for the guard is earned; the service-call tests only need one row per outcome.

3. **Schema-parity test.** Assert that for every tool name, the two definition arrays agree on the `properties` key set and the `required` array. Scope it to those two aspects rather than full deep equality, because the arrays already differ on `run_codex_native_converter`'s `enum` constraints (Q3) and a blanket equality would fail on day one.

4. **Dispatch-boundary tests.** Extend `test/repo-automation-dispatch-pr-context-verification.test.ts` with a row asserting `ok: false` and a `summary` naming the empty diff, matching that file's existing `ok: false` precedent (lines 90-106).

5. **Regression guards for the currently-passing behaviour**, per `epic.md:331` ("Currently-passing cases are included as regression guards, not omitted as redundant"): the `gh`-unavailable degradation still succeeds; the artifact read-back verification still raises on a discarded write; `writtenPaths` still equals `result.artifacts`; the returned `summary` string still names the base.

6. **Update, do not delete, the ~20 existing tests** that currently run against an empty diff (Q4). Each should gain a non-empty scripted diff so it continues to assert what it was written to assert. Deleting them would silently drop coverage of the path-identity and freshness guarantees added by #574.

7. **Determinism.** All suites already use injected runners/filesystems and a `FIXED_CLOCK` where time matters (`collector-integration.test.ts:23`). No new temporary files, no real processes, no wall-clock reads. Nothing in this feature requires fake timers.

---

## Automation Feasibility

**Assessment: every verification this feature needs can run unattended. No unautomatable requirement for F6.**

Basis:

- The entire change is TypeScript under `extensions/drm-copilot/src/`, and every behaviour it introduces is observable through constructor-injected `CommandRunner` and `FileSystem` seams that the existing suite already uses (`pr-context-service-call.test.ts:35-108`, `repo-automation-dispatch-pr-context-verification.test.ts:41-87`).
- The two tool declarations are plain exported arrays (`mcp-tool-definitions.ts:23`, `mcp-repo-automation-tool-definitions.ts:36`), directly importable and assertable in Jest without any host.
- The toolchain stages — prettier, eslint, tsc, Jest with coverage — all run as npm scripts (`package.json:202-213`) with asserted exit codes.

**Mandatory constraint, recorded explicitly.** MCP tools resolve their resources from the **installed VS Code extension**, not from the repository tree. Codex resolves them from the published npm package pinned at `.codex/config.toml:5` (`@danmoisan/drm-copilot-mcp@1.1.11`). This change is therefore **inert at the live `mcp__drm-copilot__collect_pr_context` surface until the extension is rebuilt and reinstalled**. That rebuild is epic feature F7 (`taskmaster-push-down-and-resume`, `epic.md:262`) and is **not this feature's responsibility**.

Consequently: **no acceptance criterion for this feature may call the live MCP tool and expect the new behaviour.** Such a call measures the old build and would produce a false pass or a false fail with equal likelihood. This rule is already established in this repository's own test commentary — `test/repo-automation-dispatch-pr-context-verification.test.ts:18-22` records it verbatim for the #574 change, and `issue.md:70` restates it for this one. Every acceptance criterion must assert against the Jest suite or against source inspection.

**Does that leave anything unautomatable for this feature? No.** The live-tool surface is the only thing this feature cannot verify, and it is explicitly out of scope. Jest plus source inspection covers the complete in-scope behaviour set: schema shape, input validation, target threading, fallback observability in both the record and the artifact text, the empty-diff failure classification, the error-message content, the dispatch-boundary `ok: false` projection, and the two-surface declaration parity.

Two secondary items worth recording for the planner, neither of which is unautomatable:

- The `## Numeric Derivation Evidence` requirement means that any count promoted into an acceptance criterion needs two independent enumerations. That is automatable (two differently-expressed `ripgrep` queries plus a member-set comparison) but has not been done in this pass, so no count is offered as a criterion.
- The baseline toolchain run (Q9) was not executed here. It is fully automatable and must be run by the implementing agent before the first edit, with the result recorded under the feature's `evidence/baselines/` directory.

---

## Open decisions for `spec.md`

1. **Parameter name and cardinality.** Recommendation: a single optional `target_ref` (string, a git ref). A path-valued `target_worktree` is rejected for this feature (Approach B).
2. **Artifacts on a failing diff.** Recommendation: write them, then raise. Preserves the `writtenPaths == artifacts` invariant and gives the operator a diagnostic.
3. **Guard placement.** Recommendation: a new pure module under `src/lib/pr-context/`, called from `pr-context-service-call.ts`. Not `collector-core.ts` (25 lines of headroom) and not `collector-output.ts` (15 lines).
4. **Whether to update `.claude/**` prose in this feature.** If yes, the paired `extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror edits become mandatory (Q8). Recommendation: defer prose to F7 and state the deferral explicitly, so the plan carries no phantom parity task and no silent omission.
5. **Scope of the new parity test.** Recommendation: all tools, `properties` key sets and `required` arrays only — not full deep equality, which fails today on `run_codex_native_converter`'s `enum` fields.
