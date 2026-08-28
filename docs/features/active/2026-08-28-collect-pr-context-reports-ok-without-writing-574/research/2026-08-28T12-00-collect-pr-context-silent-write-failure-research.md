# Research: `collect_pr_context` reports `ok: true` without writing its context artifacts (Issue #574)

- Feature folder: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/`
- Branch: `bug/collect-pr-context-reports-ok-without-writing-574`
- Date: 2026-08-28

## Session constraint (affects the evidence class of every finding below)

No shell tool was available in this session: the Bash tool returned `Error: No such tool available: Bash. Bash is disabled for this session, in subagents as well as here.`, and no PowerShell tool was exposed. **No command was executed, so no command or exit code is recorded anywhere in this document.**

Every claim is therefore one of two kinds, and each is labelled:

- **VERIFIED** — read directly out of a file in the repository or off disk, with an exact path and line number.
- **INFERRED** — a conclusion drawn from verified facts, with the inference stated explicitly.

The document timestamp `2026-08-28T12-00` was assigned without a clock seam for the same reason; the date component is verified from the session context, the time component is nominal.

---

## 1. Current state analysis

### 1.1 The write path

`extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` (VERIFIED):

- Lines 29-32 define the two outputs as repo-relative string constants:
  - `const SUMMARY_OUT = "artifacts/pr_context.summary.txt";`
  - `const APPENDIX_OUT = "artifacts/pr_context.appendix.txt";`
- Lines 71-81 pass those constants **unchanged** to `collectAndWrite` as `out` / `appendixOut`, while separately passing `repoRoot: input.workspaceRoot`.
- Lines 87-90 build the returned `artifacts` array by **joining to the workspace root**: `normalizeGeneratedPath(join(input.workspaceRoot, SUMMARY_OUT))`.

`extensions/drm-copilot/src/lib/pr-context/collector-output.ts` (VERIFIED):

- Lines 359-360: `writeOutput(options.fs, summaryText, options.out, options.append);` — the relative string is forwarded verbatim.
- Lines 320-336 (`writeOutput`): `fs.ensureDir(parent)` then `fs.writeTextFile(outPath, text)`. There is **no join against `repoRoot` anywhere on the write path**. `repoRoot` is consumed only by `collectPrContext` for git/gh/discovery.

`extensions/drm-copilot/src/lib/file-system.ts` (VERIFIED):

- `RealFileSystem.writeTextFile` (line 328-330) is `fs.writeFileSync(path, content, "utf8")`.
- `RealFileSystem.ensureDir` (line 341-343) is `fs.mkdirSync(path, { recursive: true })`.
- Neither resolves against any root. Node resolves a relative path against `process.cwd()`.

`RealFileSystem` is the implementation injected in production. Construction sites (VERIFIED):

- `extensions/drm-copilot/src/repo-automation-service.ts:103` — `this.fileSystem = options.fileSystem ?? new RealFileSystem();`
- `extensions/drm-copilot/src/extension.ts:124` — `fileSystem: new RealFileSystem(),`
- `extensions/drm-copilot/src/poshqc-command-registration.ts:167`, `extensions/drm-copilot/src/subagent-tree-command.ts:69` — unrelated consumers.

### 1.2 How `workspace_root` reaches the service call, and whether cwd can equal it

Chain (VERIFIED):

1. `extensions/drm-copilot/src/mcp-handlers/collect-context-handlers.ts:18-24` — `handleCollectPrContext` calls `resolveCollectPrContextToolInput(rawInput)` then `service.collectPrContext(input)`.
2. `extensions/drm-copilot/src/mcp-tool-inputs.ts:140-152` — resolves `workspaceRoot` via `normalizeWorkspaceRoot(args["workspace_root"], fallbackWorkspaceRoot)` and `base` via `normalizeRequiredText`.
3. `extensions/drm-copilot/src/repo-automation-service.ts:128-140` — `collectPrContext` forwards `workspaceRoot: input.workspaceRoot` to `collectPrContextServiceCall`.

There is **no `process.chdir` call anywhere on this path** and no root-join between the constant and the write.

The repository already documents, in prose, that cwd cannot be assumed equal to `workspace_root`. `extensions/drm-copilot/src/workflow-command-arguments.ts:279-285` (VERIFIED, verbatim):

> The MCP server is a single long-running process shared across concurrent worktree-isolated agents, so it cannot infer which checkout a given call originated from. Returning `process.cwd()` for an omitted value silently misdirects writes to the server's own checkout.

`.mcp.json` (VERIFIED) launches the server as `npx -y @danmoisan/drm-copilot-mcp` with no `cwd` key and no version pin. INFERRED: the server process inherits the cwd of whatever directory the client session was started in and keeps it for the process lifetime, across calls originating from any number of different worktrees.

### 1.3 The sibling port does join — this is a local divergence, not a systemic one

`extensions/drm-copilot/src/repo-automation-service-support.ts:102-125`, `runCollectCommitContext` (VERIFIED):

```ts
const outputPath = path.join(
  input.workspaceRoot,
  "artifacts/commit_context.txt",
);
collectCommitContext({ ..., outputPath, ... });
return { ..., artifacts: [normalizeGeneratedPath(outputPath)] };
```

The commit-context port computes the absolute path **once** and uses the same variable for both the write and the reported artifact. The pr-context port does not. The two ports were written against the same contract and diverge on exactly this point.

### 1.4 Where `ok: true` is produced

`extensions/drm-copilot/src/mcp-tools.ts` (VERIFIED):

- `toMcpToolResult` (lines 90-114) sets `ok: true` **unconditionally** for any service result it is handed.
- `toFailureToolResult` (lines 116-129) sets `ok: false` and carries `stderr_excerpt`.
- `dispatchRepoAutomationTool` (lines 148-165+) wraps the switch in `try {` at line 155; the `collect_pr_context` case at 163-165 is `return toMcpToolResult(await handleCollectPrContext(rawInput, service));`.

INFERRED: a thrown error **does** become `ok: false`. `ok: true` is therefore not a swallowed-exception artifact. The failure is silent because **nothing throws**: `mkdirSync(..., {recursive:true})` followed by `writeFileSync` on a relative path *succeeds*, creating `artifacts/` under the server process's cwd. The write is not lost; it lands in the wrong checkout.

### 1.5 Empirical corroboration from disk

VERIFIED by `Glob`:

- `C:\Users\DanMoisan\repos\drm-copilot\artifacts\pr_context.summary.txt` and `...appendix.txt` **exist** in the main checkout.
- `<worktree>/artifacts/pr_context.*.txt` in this worktree — **no files found**.

VERIFIED by reading those files:

- `C:\Users\DanMoisan\repos\drm-copilot\.git\HEAD` contains `ref: refs/heads/main`.
- `C:\Users\DanMoisan\repos\drm-copilot\artifacts\pr_context.summary.txt` line 17 reads `Head ref (resolved): bug/promotion-lifecycle-loses-promoted-record-487 @ 2ad3c1511fe5b2c6baf1cab2f0633e3b89e59c8d`.
- The appendix at the same location (line 55) records the same head SHA, and line 4 records `2026-08-21 00:10:05 UTC`.

INFERRED, and this is the strongest available field evidence: the main checkout is on `main`, yet its `artifacts/` directory holds a PR-context pair describing the branch `bug/promotion-lifecycle-loses-promoted-record-487`, which lives in a *different* worktree. A run whose git operations resolved against one checkout wrote its output files into another. That is precisely the split the code path predicts — git against `repoRoot`/`workspaceRoot`, file write against `process.cwd()`.

The one competing explanation is a human invoking the Python CLI from the main checkout with an explicit `--repo-root <other-worktree>`. That is possible but does not match the documented workaround, which uses `--repo-root .`.

### 1.6 Three committed tests already encode the defect

This is the decisive verification, and it required no command execution.

**(a) `extensions/drm-copilot/test/repo-automation-dispatch.test.ts:118-135`** (VERIFIED). One test, both halves of the divergence side by side:

```ts
const result = await service.collectPrContext({
  workspaceRoot: "C:/workspace", ...
});
const summary = "C:/workspace/artifacts/pr_context.summary.txt";
...
expect(writes.has("artifacts/pr_context.summary.txt")).toBe(true);
...
expect(result.artifacts).toEqual([summary, appendix]);
```

The injected fake's `writeTextFile` (line 102-103) keys writes by the literal path argument. The write key is the bare relative path; the reported artifact is the joined absolute path. The test asserts both and passes.

**(b) `extensions/drm-copilot/test/extension.collect-pr-context.test.ts:432-446`** (VERIFIED). The test is titled *"collectPrContext writes artifacts against the workspace root in-process"* and its comment reads *"The collector wrote both repo-relative artifacts via node:fs"*, yet with `workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }]` it asserts:

```ts
expect([...writtenFiles.keys()].sort()).toEqual([
  "artifacts/pr_context.appendix.txt",
  "artifacts/pr_context.summary.txt",
]);
```

`writtenFiles` is populated by the `node:fs` `writeFileSync` mock (lines 119-123), i.e. at the exact boundary `RealFileSystem` calls. The recorded argument contains no workspace root. The test name asserts the opposite of what the test verifies.

**(c) `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts:91-112`** (VERIFIED). `ROOT = "/workspace"`. Lines 91-94 assert `result.artifacts` equals the two `/workspace/...` paths; lines 110-112, under the comment *"both files were written (relative to the workspace root)"*, assert `fs.isFile("artifacts/pr_context.summary.txt")`. `TreeFileSystem` (`extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts:17, 28-32, 50-52`) is a literal-key `Map`; `isFile("/workspace/artifacts/pr_context.summary.txt")` would return `false`. The comment is wrong and the assertion pins the relative key.

`extensions/drm-copilot/test/extension.integration.test.ts:302-303, 321-322, 332-334` uses the same relative keys (VERIFIED).

### 1.7 Other silent-failure paths on this call

Enumerated from `extensions/drm-copilot/src/lib/pr-context/**` (VERIFIED):

| Location | Behaviour | Assessment |
| --- | --- | --- |
| `collector-output.ts:91-94` | `catch { continue; }` around `parseVerificationEvidenceFile` | Deliberate Python `OSError` parity. Degrades one section, does not affect the write. Not causal. |
| `collector-core.ts:135-140` | `catch` on `gh.ensureAvailable()` sets `ghAvailable = false` and a status override | Deliberate degradation. **Observed live**: the on-disk summary line 4 reads `GitHub CLI unavailable: GitHub CLI (gh) is not installed.` — the writing process could not find `gh`. A separate, real defect in the same tool's output quality; see Open question O3. Not causal for the write. |
| `collector-core.ts:307-310` | `catch { ciTarget = null; }` | Degrades the CI section only. Not causal. |
| `render.ts:300-305` | Catch-all that replaces the whole PR-Comparison block with `(FAILED to compute PR context: <msg>)` and resets derived fields | **Second real silent-success path.** A total failure to compute the diff still produces a well-formed artifact pair and `ok: true`. Independent of the path defect and worth an explicit acceptance condition. |
| `gh-client-core.ts:247-249, 277-279, 314-316, 424-426` | JSON/lookup failures resolve to `null` | Degrades reference classification. Not causal. |
| `writeOutput` / `collectAndWrite` | **No** try/catch, **no** post-write verification | A genuine `writeFileSync` throw would propagate to `ok: false`. There is no read-back, so a write that succeeds at the wrong location is indistinguishable from success. |

### 1.8 Python parity surface — the Python side is correct and needs no path change

`scripts/dev_tools/pr_context/collector.py` (VERIFIED):

- Line 103-104: `SUMMARY_PATH_DEFAULT = "artifacts/pr_context.summary.txt"`, `APPENDIX_PATH_DEFAULT = "artifacts/pr_context.appendix.txt"`.
- Line 206-207 inside `collect_and_write`: `summary_path = out` and `appendix_path = appendix_out or Path(APPENDIX_PATH_DEFAULT)` — **no join against `repo_root`**, exactly like the TypeScript port.
- Lines 176-180 (`write_output`): `out_path.parent.mkdir(parents=True, exist_ok=True)` then `out_path.open(mode)` — path used as given.
- Lines 607-619 (`main`): `out_path = Path(args.out).expanduser()`, `repo_root = Path(args.repo_root).expanduser().resolve()`. Note the asymmetry: `repo_root` is `.resolve()`d, the output paths are not.

**Conclusion (INFERRED, high confidence): the TypeScript port did NOT diverge from Python on this behaviour. It is a faithful port.** The library contract in both runtimes is *"write to the path you were given, resolved by the host against its own cwd."*

For the Python CLI that contract is coherent, because a CLI's cwd *is* the user's cwd. The documented workaround `python -m scripts.dev_tools.pr_context.collector --base main --repo-root .` works for exactly that reason and for no other: `--repo-root .` and the relative `--out` default resolve against the same cwd, which the operator has set to the repo root. Change the cwd and the same command writes elsewhere.

The defect is that the **TypeScript caller** — `pr-context-service-call.ts` — passes a repo-relative constant into that cwd-relative contract from a long-lived server process whose cwd is unrelated to the per-call `workspace_root`, while reporting the workspace-joined path. **The Python collector requires no change for the root cause.** It is in scope only for the freshness marker (Section 4), where the verbatim-port relationship obliges a matching edit.

### 1.9 Parity obligation between the two runtimes

The module headers declare the port relationship (VERIFIED): `collector-output.ts:4-9` states *"Port of the rendering/write half of `dev_tools/pr_context/collector.py` `collect_and_write`. Build the summary and appendix text verbatim…"*, and individual functions carry `Mirrors Python …` docstrings (e.g. `collector-output.ts:320-319`, `summary-helpers.ts:326-334`).

**No automated Python-to-TypeScript parity test for the pr-context surface was located.** Searches across `tests/scripts/dev_tools/` and `extensions/drm-copilot/test/` surfaced parity tests for blast-radius, orchestration-routing, codex handoff, and parallel-cohort, but none for pr-context. The two surfaces have independent test suites:

- Python: `tests/scripts/dev_tools/test_collect_pr_context.py`, `test_collect_pr_context_part2.py`, `test_collect_pr_context_part3.py`, `test_collect_pr_context_part4.py`, `test_collect_pr_context_expected_exit.py`, `tests/scripts/dev_tools/test_pr_context_integration.py`.
- TypeScript: the fifteen files under `extensions/drm-copilot/test/lib/pr-context/`, plus `extension.collect-pr-context.test.ts`, `extension.integration.test.ts`, `repo-automation-dispatch.test.ts`, `mcp-server.test.ts`.

The parity obligation is therefore **prose-declared and enforced by review, not by a test**. INFERRED consequence: a text-shape change made in one runtime and not the other will not be caught mechanically. Recorded as Open question O2.

Relevant existing behaviours in the Python integration test (VERIFIED, `tests/scripts/dev_tools/test_pr_context_integration.py:171-279`): it passes **absolute** paths (`mem_fs_path / "summary.txt"`) and monkeypatches `write_output` at line 248. No Python test exercises relative-path resolution, so no Python test pins the behaviour either way.

---

## 2. Candidate approaches and the recommendation

### Recommended: resolve the output paths to absolute at the single service-call seam, and verify the write by read-back

Two coordinated changes, both confined to `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`.

**R1 — one variable for both the write and the report.** Compute each absolute path once and use the same value in both places:

```ts
const summaryOut = join(input.workspaceRoot, SUMMARY_OUT);
const appendixOut = join(input.workspaceRoot, APPENDIX_OUT);
collectAndWrite({ ..., out: summaryOut, appendixOut, ... });
return { ..., artifacts: [normalizeGeneratedPath(summaryOut), normalizeGeneratedPath(appendixOut)] };
```

The divergence becomes structurally impossible rather than merely corrected: there is no second expression that could drift. This is the exact shape of `runCollectCommitContext` (`repo-automation-service-support.ts:108-123`), so the fix makes the two ports consistent instead of introducing a new pattern.

**R2 — read-back verification, at the MCP seam only.** After `collectAndWrite` returns, read each file back through the injected `FileSystem` and throw when the content is not the content this invocation produced. A thrown error becomes `ok: false` at `mcp-tools.ts:116-129`, delivering the issue's acceptance condition literally: `ok: true` if and only if this invocation's artifacts were written.

Read-back, not `isFile`. An existence check is satisfied by a stale file and would reproduce the very hazard the issue is about. Read-back requires `collectAndWrite` to return the two rendered strings (it currently returns `void`, `collector-output.ts:348`) or requires the service call to re-render; returning the strings is the smaller change and keeps the rendering single-pass. Verifying against the freshness header token from Section 4 is an acceptable weaker alternative if returning the text proves awkward, since that token is unique per invocation.

**Why this is the right seam.** `pr-context-service-call.ts` is the MCP-facing wiring layer, described in its own header (lines 1-20) as *"In-process wiring for the `collectPrContext` service method"*. It is the only place that knows both the workspace root and the two default paths. Putting the join and the verification there leaves `collectAndWrite` / `writeOutput` byte-faithful to `collect_and_write` / `write_output`, so the verbatim-port relationship of Section 1.9 survives.

Advantages: minimal diff; no signature change to the ported library; matches an existing in-repo precedent; eliminates the class of defect, not the instance.
Limitations: the two `Wrote context …` log lines will change from relative to absolute text, which four committed tests assert (Section 5); does not address freshness, which Section 4 handles independently.

### Rejected alternatives

- **Join inside `writeOutput` / `collectAndWrite` against `options.repoRoot`.** Rejected: it changes the library contract away from Python `collector.py:206` (`summary_path = out`), breaking the verbatim-port relationship that has no test to protect it; and it would double-join the absolute paths already passed by `collector-integration.test.ts:20-21` (`/repo/artifacts/...`) unless an `isAbsolute` guard were added, which is added complexity in a shared module for no gain.
- **`process.chdir(workspaceRoot)` in the handler.** Rejected: `workflow-command-arguments.ts:279-285` records that this server is a single long-running process shared across concurrent worktree-isolated agents. A process-global cwd mutation is a race between concurrent tool calls and would convert a deterministic misdirection into a nondeterministic one.
- **Make the collector reject a relative `out`.** Rejected as the primary fix: it would break the Python CLI's documented and correct relative-path usage if mirrored, and if applied only to TypeScript it introduces a divergence to fix a divergence. Reasonable as a defensive assertion *inside the service call* after R1, but not as the mechanism.

---

## 3. Behaviour semantics

Success and failure conditions the fix must satisfy:

1. **Path identity.** For any `workspace_root` `W`, the tool writes to `W/artifacts/pr_context.summary.txt` and `W/artifacts/pr_context.appendix.txt` and reports exactly those two paths. Reported set and written set are equal, always.
2. **`ok` semantics.** `ok: true` iff both files were written by this invocation and their content read back equals what this invocation rendered. Any other outcome raises, producing `ok: false` with the failure in `summary` / `stderr_excerpt`.
3. **Ordering.** Summary is written before appendix (preserved from `collector-output.ts:359-360`); verification runs after both writes; the result record is built only after verification passes.
4. **Pair atomicity is not claimed.** Two sequential writes are not atomic. If the appendix write fails after the summary write succeeded, the summary is already on disk. Verification converts this into a loud `ok: false`, and the freshness marker of Section 4 lets a consumer detect a mismatched pair. Introducing write-to-temp-then-rename is out of scope and would break Python parity.
5. **Degradation is not failure.** `gh` being unavailable, a missing CI target, or an unreadable evidence file must continue to produce a written artifact and `ok: true`. Only a write or verification failure is an error. The `render.ts:300-305` catch-all is the one boundary case: a `(FAILED to compute PR context: …)` block is a *degraded but written* artifact under the current contract. Recorded as design decision D1 below.
6. **Backward compatibility of consumers.** `.claude/hooks/enforce-pr-author-skill.ps1:48` resolves `artifacts/pr_context.summary.txt` relative to the *hook* process cwd, which is the session worktree. After the fix the file will exist there, so the hook starts working as intended rather than passing on a stale file. No hook change is required by the root-cause fix.

**Design decision D1 (for the planner to ratify):** whether `render.ts:300-305`'s catch-all should also become an error. It is a genuine silent-success path, and the issue's expected behaviour ("any failure to write returns an error") does not cleanly cover it because the write succeeds. Recommendation: leave the behaviour but surface it — add the failure text to the MCP `warnings` array, which `mcp-tools.ts:72` and `112` already support and which requires no schema change. This keeps degradation working offline while making the condition visible.

---

## 4. Freshness markers (independent requirement)

### 4.1 What the artifacts already record — VERIFIED, precisely

**Appendix.** `collector-output.ts:285-286` places `appendGenerationTimestamp(clock)` as the **first** element of `appendixParts`. `summary-helpers.ts:335-341` renders `section("Context generated") + "\n" + timestamp + "\n"`, and `formatUtcTimestamp` (lines 344-352) formats `YYYY-MM-DD HH:MM:SS UTC`. Python equivalent: `collector.py:544` calling `summary_helpers.py:379-386`. Confirmed on disk: `C:\Users\DanMoisan\repos\drm-copilot\artifacts\pr_context.appendix.txt` lines 2-4 are `===== Context generated =====`, blank, `2026-08-21 00:10:05 UTC`.

The appendix carries a head SHA only **buried mid-document**, inside the `PR Comparison` block emitted by `render.ts` — line 55 of the on-disk sample, under the `===== PR Comparison =====` banner at line 51. It is not a header and a consumer would have to parse past ~50 lines of remotes/status/diff output to find it.

**Summary.** `buildSummaryText` (`collector-output.ts:147-258`) builds `summarySections` starting at line 163-173 with `section("GitHub CLI status")`. **There is no generation timestamp anywhere in the summary.** Confirmed on disk: line 1 of the sample summary is blank and line 2 is `===== GitHub CLI status =====`.

The summary does carry `Head ref (resolved): ${ctx.headRef} @ ${ctx.headSha}` at `collector-output.ts:170` — on-disk line 17, inside the `Base/Head` block.

**Summary of the gap:** the appendix has a timestamp but no prominent SHA; the summary has a SHA but no timestamp. Neither file carries both, and neither carries a marker in a fixed position a consumer can read without parsing the body. Nothing links the two files to a single invocation.

### 4.2 Recommended minimal addition

One shared helper emitting a single section, rendered as the **first** section of **both** files:

```
===== Context generated =====

<YYYY-MM-DD HH:MM:SS UTC>
Head SHA: <headSha or (unknown)>
```

Design notes:

- **Reuse the existing `Context generated` section title** rather than adding a new banner. The appendix's existing marker is upgraded in place, so `extension.integration.test.ts:339`, `collector-integration.test.ts:163`, `collector-output.test.ts:240`, and `summary-helpers.test.ts:278` — all of which assert `toContain("===== Context generated =====")` — keep passing, and the change is one new line in the appendix rather than a new section.
- **Head SHA is already on the record.** `CollectedPrContext.contextResult.headSha` is what `collector-output.ts:170` renders. No new git call.
- **A clock must be threaded into `buildSummaryText`.** It currently takes `(collected, fs, appendixPath)` (line 147-151) with no clock; `buildAppendixText` takes one (line 271-274). `collectAndWrite` already resolves `const clock = options.clock ?? (() => new Date())` at line 349, so the change is to pass `clock` into `buildSummaryText` at line 352-356. This satisfies `.claude/rules/typescript.md` ("`Date` … must flow through an injected `Clock`"). Note the Python `append_generation_timestamp()` at `summary_helpers.py:379` takes **no** clock parameter — a pre-existing, deliberate divergence justified by the TypeScript determinism rule; the fix must not "correct" it in either direction.
- **Both files must carry the identical timestamp string.** Render once in `collectAndWrite` and pass the same string to both builders, rather than calling the clock twice. A pair that disagrees on the timestamp is then a detectable defect rather than a rounding artifact.

### 4.3 The deterministic consumer cross-check

Existence is never sufficient. The check a consumer performs before using the pair:

1. **Pair identity** — the `Context generated` timestamp is byte-identical in both files. A mismatch proves the two files came from different invocations (exactly the hazard: a summary refreshed while a stale appendix persists, or the reverse).
2. **Head binding** — the `Head SHA:` value in both files equals the current `git rev-parse HEAD` of the branch under review. A mismatch proves the pair predates the current head, whatever its mtime says.

Both operands are read from the artifacts themselves and from git. Neither requires a wall clock, so the check is deterministic and testable. This supersedes mtime as the freshness signal: mtime is what the current mechanisms use and is precisely what a stale-but-recently-copied file defeats.

Note the existing receipt mechanism is a *different* check and is not a substitute. `.claude/skills/pr-author/SKILL.md:55-63` requires the receipt's `created_at` to be *"newer than pr_context.summary.txt last-write"*, and `.claude/hooks/enforce-pr-author-skill.ps1:122-142` implements the comparison against `LastWriteTimeUtc`. That establishes *receipt-after-summary* ordering only; it says nothing about whether the summary describes the current head. `Get-PrContextArtifactExistence` (line 53-57, `Test-Path`) is the pure existence check the issue names, and a stale file satisfies it.

### 4.4 Where the cross-check must be documented

The skill exists. **VERIFIED path: `.claude/skills/pr-context-artifacts/SKILL.md`** (31 lines). Its `## Refresh Rule` (lines 22-29) currently says only *"If the artifacts are missing or stale relative to the current branch state, re-generate them"* — it defines no test for "stale". That section is where the two-step cross-check belongs.

There are **six** copies of this skill (all VERIFIED to exist):

| Copy | Path |
| --- | --- |
| Self-hosted, Claude | `.claude/skills/pr-context-artifacts/SKILL.md` |
| Self-hosted, Copilot | `.github/skills/pr-context-artifacts/SKILL.md` |
| Self-hosted, Agents | `.agents/skills/pr-context-artifacts/SKILL.md` |
| Bundled, Claude | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md` |
| Bundled, Copilot | `extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md` |
| Bundled, Agents | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md` |

The `.claude` self-hosted and bundled copies are byte-identical today (VERIFIED by reading both in full).

### 4.5 Push-down parity obligation — VERIFIED, and it is enforced

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, asserts for every repo `.claude/**` file (excluding `settings.local.json` and `.claude/agent-memory/**`):

```python
assert read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path), \
    f"Bundle content differs from repo for: {relative_path}"
```

**Editing `.claude/skills/pr-context-artifacts/SKILL.md` without making the byte-identical edit to the bundled Claude copy fails this test.**

`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:35` declares `SCOPED_ROOTS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))` and applies the same pattern at line 116 (VERIFIED), so the `.agents` copy carries the same obligation.

The equivalent Copilot `.github` byte-parity test was **not located**. Recorded as Open question O1.

**Operational note (INFERRED, from verified facts):** a `resources/` edit changes what a *future* push-down writes, not what an already-installed extension writes; and the running MCP server is `npx -y @danmoisan/drm-copilot-mcp` with **no version pin** (`.mcp.json`, VERIFIED). The TypeScript fix therefore does not reach the live `mcp__drm-copilot__collect_pr_context` tool until `@danmoisan/drm-copilot-mcp` is republished and the client re-resolves the package. Until then the documented Python-CLI workaround remains the operative mitigation. This is a release-sequencing constraint on the acceptance evidence, not a code constraint.

---

## 5. Files a fix must touch

Exact repo-relative paths. No globs; no `**/` shapes; no `tests/*` tokens. This list is intended to feed blast-radius derivation directly.

### Production — TypeScript (root cause)

1. `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` — R1 join, R2 read-back verification.

### Production — TypeScript (freshness marker)

2. `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` — render the shared header first in both builders; thread `clock` into `buildSummaryText`; return the rendered strings from `collectAndWrite` if R2 verifies against content.
3. `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` — extend `appendGenerationTimestamp` (or add a sibling) to accept the head SHA and emit the `Head SHA:` line.

### Production — Python (freshness marker parity only; NOT the root cause)

4. `scripts/dev_tools/pr_context/collector.py` — mirror the header into the summary sections and pass the head SHA.
5. `scripts/dev_tools/pr_context/summary_helpers.py` — mirror the helper change at lines 379-386.

### Configuration

6. `extensions/drm-copilot/jest.config.cjs` — the `coverageThreshold` map (lines 25-244) has **no** entry for any `./src/lib/pr-context/` file (VERIFIED). The established pattern in that file, stated in its own comments for issues #305 and #525, is that changed production files get a per-file `{ lines: 85, branches: 75 }` entry. Add entries for `./src/lib/pr-context/pr-context-service-call.ts`, `./src/lib/pr-context/collector-output.ts`, and `./src/lib/pr-context/summary-helpers.ts`.

### Documentation — six copies, byte-identical within each pair

7. `.claude/skills/pr-context-artifacts/SKILL.md`
8. `.github/skills/pr-context-artifacts/SKILL.md`
9. `.agents/skills/pr-context-artifacts/SKILL.md`
10. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md`
11. `extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md`
12. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md`

### Tests — TypeScript (each currently asserts the relative write path or the summary shape)

13. `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` — lines 110-112 (relative key, wrong comment), 125-128 (log-line text).
14. `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` — lines 323-324, 326, 342, 400, 407, 442-445.
15. `extensions/drm-copilot/test/extension.integration.test.ts` — lines 302-303, 321-322, 332-334, 339.
16. `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` — lines 125-135.
17. `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` — lines 82-122 (section ordering), 240, 424-443 (`writeOutput`).
18. `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts` — lines 20-21, 130-163.
19. `extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts` — lines 273-278.
20. `extensions/drm-copilot/test/mcp-server.test.ts` — lines 125-158 (the `ok: true` + absolute-artifacts contract at the MCP boundary).

### Tests — Python (freshness-marker parity only)

21. `tests/scripts/dev_tools/test_pr_context_integration.py`
22. `tests/scripts/dev_tools/test_collect_pr_context.py`
23. `tests/scripts/dev_tools/test_collect_pr_context_part2.py`
24. `tests/scripts/dev_tools/test_collect_pr_context_part3.py`
25. `tests/scripts/dev_tools/test_collect_pr_context_part4.py`

Files 22-25 are listed because they are the Python summary/appendix shape suites and a new first section may cross an ordering or first-line assertion. Whether each is genuinely touched must be settled at plan time by reading them; they are enumerated so blast-radius derivation is not surprised.

**Explicitly NOT touched:** `.claude/hooks/enforce-pr-author-skill.ps1` and `.claude/hooks/enforce-pr-author-skill-helpers.ps1`. The hook resolves its path relative to the session cwd and starts working correctly once the artifacts land in the worktree. Extending the hook to enforce the head-SHA cross-check is a separate, larger change (it would need a git call at PreToolUse time) and should be a follow-up, not part of this bug fix.

---

## 6. Module rigor tier and coverage obligations

**`quality-tiers.yml` does not exist at the repository root.** VERIFIED: a root-level glob for `*.yml` returns only the fifteen files under `.github/`, and a repo-wide search for `quality-tiers*` returns only `.claude/rules/quality-tiers.md`, its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`, and two evidence documents under `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/`.

`.claude/rules/general-code-change.md` and `.claude/rules/quality-tiers.md` both state that `quality-tiers.yml` at repo root is the source of truth and that a project without a tier classification fails CI. That file's absence is a pre-existing repository condition, **out of scope for this bug** but recorded as Open question O4.

**The tier's absence does not change the coverage obligation.** `.claude/rules/quality-tiers.md` states that line and branch thresholds are uniform across T1-T4 (Authoritative Decision #2). The obligations for every file in Section 5 are therefore identical regardless of tier:

- Line coverage >= 85%.
- Branch coverage >= 75% (both TypeScript/Jest and Python/pytest measure branch coverage; the Pester and kcov exemption does not apply here — no PowerShell production file is in scope).
- No coverage regression on changed lines (a Blocking finding per `.claude/rules/typescript.md` and `.claude/rules/python.md`).
- No production file may be excluded from measurement (`.claude/rules/general-unit-test.md`, Coverage Exclusion Policy). All five production files in scope are ordinary runtime modules with no interface-only exemption available.

Jest already measures every `src/**/*.ts` (`jest.config.cjs:17`, `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`), so the pr-context modules are already in the denominator; only the per-file threshold entries are missing.

---

## 7. Test strategy

No test code is written here. Strategy only.

**T1 — path identity at the service seam.** With `workspaceRoot = "/workspace"` and a `TreeFileSystem`, assert the written keys are `/workspace/artifacts/pr_context.summary.txt` and `/workspace/artifacts/pr_context.appendix.txt`, and that `result.artifacts` equals that same pair. Assert the set equality directly so reported and written cannot drift apart again. This is the corrected form of `pr-context-service-call.test.ts:110-112`.

**T2 — path identity at the `node:fs` boundary.** The corrected form of `extension.collect-pr-context.test.ts:432-446`: with the workspace at `C:/workspace`, assert `writeFileSync` was called with the two workspace-joined paths. This is the test that would have caught the defect, because it observes the exact argument `RealFileSystem` passes to Node.

**T3 — negative: a write failure surfaces as an error.** Inject a `FileSystem` whose `writeTextFile` throws for the appendix path, and assert `collectPrContextServiceCall` throws (and, at the dispatch level, that `ok` is `false` with the message in `summary`).

**T4 — negative: a stale file does not satisfy verification.** Pre-seed the in-memory filesystem with content at both target paths, inject a `writeTextFile` that silently discards, and assert the read-back verification throws. This is the test that distinguishes read-back from existence and is the direct expression of the issue's central hazard.

**T5 — freshness header, both files, one timestamp.** With a fixed injected clock and a known `headSha`, assert both rendered texts begin with the `Context generated` section, that both carry the same timestamp string, and that both carry `Head SHA: <sha>`. Determinism comes from the injected clock; no fake timers are needed because no async time passes.

**T6 — section ordering preserved.** Extend `collector-output.test.ts:92-110` so `===== Context generated =====` is the first entry of the ordering array, proving the header precedes `===== GitHub CLI status =====` and that no existing section moved.

**T7 — Python parity of the header text.** Mirror T5 in pytest against `collect_and_write` so the two runtimes emit the same section title and line shape. Given that no automated cross-runtime parity test exists (Section 1.9), consider adding one narrow parity assertion comparing the two header renderings for a fixed input — that is the cheapest available protection for the verbatim-port claim, and its absence is what allowed the divergence class in the first place.

**T8 — MCP boundary contract.** Extend `mcp-server.test.ts:125-158` so the artifacts array asserted in `structuredContent` is the same pair the service reports, and add a companion asserting `ok: false` when the service call rejects.

**Determinism.** All of the above use injected clocks and in-memory filesystems. No temp files (prohibited by `.claude/rules/general-unit-test.md`), no real processes, no sleeps.

---

## 8. Toolchain commands, quoted from the rule files

From `.claude/rules/typescript.md` (lines 13-18), run in order, restarting from step 1 if any step fails or changes files:

1. Formatting — Prettier: `npm run format`
2. Linting — ESLint: `npm run lint`
3. Type Checking — TSC: `npm run typecheck`
4. Testing — Jest: `npm run test:unit`

Coverage command, from line 51: `npm run test:unit:coverage` (the root `package.json` script runs `node run-jest.cjs --coverage`).

From `.claude/rules/python.md` (lines 13-18), run in order, restarting from step 1 if any step fails or changes files:

1. Formatting — Black: `poetry run black .`
2. Linting — Ruff: `poetry run ruff check .`
3. Type Checking — Pyright: `poetry run pyright`
4. Testing — Pytest: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

---

## 9. Acceptance conditions that cannot fail as written — flagged per `.claude/rules/plan-acceptance-gates.md`

The plan author must avoid each of the following. Every item is a rule this feature's shape makes it easy to trip.

- **G1, Blocking — a filesystem path as a `--cov` value.** `--cov=scripts/dev_tools/pr_context/collector.py` is rejected outright: a `--cov` value whose text ends in `.py` proves a filesystem path, which `coverage.py` rejects, so the argument collects nothing and the coverage assertion cannot fail. Write the dotted module: `--cov=scripts.dev_tools.pr_context.collector`, and likewise `--cov=scripts.dev_tools.pr_context.summary_helpers`.
- **G2, Blocking — a separator-bearing `--cov` value with a tracked `.py` sibling.** `--cov=scripts/dev_tools/pr_context/collector` is rejected for the same reason with a known remedy, because `scripts/dev_tools/pr_context/collector.py` is a tracked file. Dotted form only.
- **G4, Warning — the space-separated form.** `--cov <value>` can bind the following positional argument. Always use `--cov=<value>`.
- **G5, Warning — a search for a literal the plan itself creates.** An acceptance condition of the form "grep for `Head SHA:` in the collector source" is a search for a literal that does not exist until the task runs. It is exonerated only if the plan quotes the literal contiguously in prose outside the command span. Prefer a **named test** carrying the assertion over a phrase search, per the authoring guidance.
- **G6, Warning — a literal that only exists across a line wrap.** The section-title strings in `collector-output.ts` sit inside multi-line array literals; a phrase search spanning a wrap returns zero matches from a line-oriented search whatever the executor does.
- **Placeholder guard.** Any search literal containing `<`, `>`, `${`, `$(`, or `%` is treated as documenting a command shape and is never checkable. Note this directly affects the obvious formulations here: `Head SHA: <sha>` and `<YYYY-MM-DD HH:MM:SS UTC>` both carry angle brackets, so an acceptance condition phrased with either is silently unfalsifiable. Assert on a concrete rendered value inside a test instead.
- **Repository-specific hazard — asserting on the generated artifacts.** An acceptance condition of the form "assert `artifacts/pr_context.summary.txt` exists" or "grep the summary for `Head SHA:`" **is the exact defect under repair**. A prior run's file satisfies it. Any acceptance condition touching the real artifacts must assert on freshly-generated content compared against a value computed in the same step (the head SHA), never on existence, and never on mtime.
- **Do not accept the fix on the live MCP tool without a republish.** An acceptance condition that calls `mcp__drm-copilot__collect_pr_context` and checks the result will exercise the *installed* `@danmoisan/drm-copilot-mcp`, not the branch under test (Section 4.5). Such a condition passes or fails for reasons unrelated to the diff. Accept via Jest and pytest against the source, and treat live verification as post-release evidence.

---

## 10. Status of the primary lead

**CONFIRMED as to mechanism; the framing that "the TypeScript port diverged from Python" is REFUTED and replaced.**

Confirmed, with the qualification stated:

- `SUMMARY_OUT` / `APPENDIX_OUT` are repo-relative and are passed unjoined to `collectAndWrite`, while the reported `artifacts` array joins to `workspaceRoot` (`pr-context-service-call.ts:29-32, 71-81, 87-90`).
- `writeOutput` calls `ensureDir` / `writeTextFile` on that relative string with no root join (`collector-output.ts:320-336, 359-360`).
- `RealFileSystem` resolves it through bare `node:fs`, i.e. against `process.cwd()` (`file-system.ts:328-343`).
- The MCP server is documented as a single long-running process shared across worktree-isolated agents and is launched via unpinned `npx` with no `cwd` (`workflow-command-arguments.ts:279-285`; `.mcp.json`).
- Three committed tests assert the reported path and the written path as different strings within the same scenario (`repo-automation-dispatch.test.ts:118-135`; `extension.collect-pr-context.test.ts:432-446`; `pr-context-service-call.test.ts:91-112`).
- Disk state corroborates: the `main` checkout holds a PR-context pair describing a branch that lives in a different worktree.

Replaced framing: `collect_and_write` in Python behaves identically (`collector.py:206`, `summary_path = out`), so the TypeScript library is a **faithful** port. The defect is in the **caller** — `pr-context-service-call.ts` — which supplies a repo-relative constant to a cwd-relative contract from a process whose cwd is unrelated to `workspace_root`, and which reports a different path than it writes. Its sibling caller `runCollectCommitContext` (`repo-automation-service-support.ts:108-123`) does the join correctly, which is why `collect_commit_context` does not exhibit the bug.

Partially explanatory only, in one respect: the mechanism explains a **misdirected** write, not a **skipped** one. The issue text says "fails to write". Both files were in fact written, in the wrong checkout, and the tool's `ok: true` was truthful about the write and false about the location. Everything the reporter observed — success reported, stale content at the named path, existence checks passing, content not matching the branch under review — follows from misdirection. No separate skipped-write mechanism needs to be posited, and none was found.

---

## 11. Open questions

None is blocking. Planning can proceed on all of them.

- **O1 — Copilot `.github` push-down parity test not located.** The `.claude` and `.codex`/`.agents` byte-parity tests are verified (Section 4.5); the `.github` equivalent was not found in `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` or `..._rewrites.py`. The planner should confirm whether one exists before deciding if file 11 is test-enforced or convention-only. Either way the edit should be made, so this does not gate planning.
- **O2 — no automated Python/TypeScript parity test for pr-context.** The verbatim-port relationship is prose-declared only. Adding one narrow parity assertion alongside the freshness header (test strategy T7) is recommended but is a scope decision for the planner.
- **O3 — `gh` unavailable to the writing process.** The on-disk summary records `GitHub CLI unavailable: GitHub CLI (gh) is not installed.` This degrades reference classification and autoclose detection in every artifact that process produces. It is a distinct defect in the same tool, out of scope for #574, and worth a separate potential-bug entry.
- **O4 — `quality-tiers.yml` absent from the repository root.** Required by `.claude/rules/quality-tiers.md` and `.claude/rules/general-code-change.md`, and stated there to fail CI when a project is unclassified. Pre-existing and out of scope; recorded so the planner does not treat the missing tier as a research gap. Coverage obligations are unaffected because the thresholds are uniform across tiers.
- **O5 — design decision D1** (Section 3): whether the `render.ts:300-305` catch-all should surface through the MCP `warnings` array. Recommended, low cost, no schema change.
