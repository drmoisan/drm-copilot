# Research — taskmaster-push-down-and-resume (Issue #674)

- Date: 2026-09-13
- Scope: F7 of epic `worktree-scoped-state-resolution`, wave 2.
- Mode: preparation-mode research. F1-F6 have not executed. No corrected content exists
  anywhere yet. This document characterizes the delivery MECHANISM and resolves HI-2; it does
  not and cannot verify that corrected content is present.
- Workspace root used for every command below:
  `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0c5927faa7a63155`
- Tool constraint that shapes this document: the task-researcher persona invoked for this
  research was given only `Read`, `Grep`, `Glob`, `WebFetch`, `Write` — no Bash/PowerShell
  execution tool. Every claim below is either (a) verified by reading a file/running a
  read-only search tool in this session, or (b) explicitly marked as inferred/not executable
  in this session, per the hard constraint against fabricating verification.

## Q1 — The verification trap

### Resolution trace (verified by reading the current tree)

- `extensions/drm-copilot/src/mcp-provider.ts` registers the MCP server definition provider.
  `provideMcpServerDefinitions` builds a `vscode.McpStdioServerDefinition` that spawns
  `node <extensionUri>/out/mcp-server.js` (line 38: `vscode.Uri.joinPath(context.extensionUri,
  "out", "mcp-server.js")`). `context.extensionUri` is VS Code's own handle to wherever it
  loaded the **installed** extension from — not this repository checkout.
- `extensions/drm-copilot/src/mcp-server.ts:29-31`: `resolveExtensionRoot()` returns
  `path.resolve(__dirname, "..")`. Since the process is launched as
  `node <extensionUri>/out/mcp-server.js`, `__dirname` at runtime is `<extensionUri>/out`, so
  the resolved extension root is `<extensionUri>` itself — the installed extension directory.
- `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:166-201`
  (`pushDownClaudeCustomizationsServiceCall`) builds `sourceRoot =
  bundledSourceRoot(input.extensionRoot, "resources/claude-customizations")` (line 78-81), and
  `extension.ts:113` / `command-runtime.ts:344` supply `extensionRoot:
  context.extensionUri.fsPath` when the extension host constructs these inputs directly (the
  non-MCP command path). Both paths — the extension-host command path and the standalone MCP
  server process path — resolve the bundled source root from the **installed** extension's own
  directory, never from `extensions/drm-copilot/resources/claude-customizations/` in this git
  checkout.
- Wiring citations re-derived against the current tree (all match the epic manifest's 2026-09-13
  citations exactly):
  - `extensions/drm-copilot/src/mcp-tools.ts:198` — `case "push_down_claude_customizations": {`
  - `extensions/drm-copilot/src/mcp-tool-definitions.ts:134` —
    `name: "push_down_claude_customizations",`
  - `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:145` — same
  - `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:195` —
    `tool: "push_down_claude_customizations",`

**Conclusion: verified.** The push-down tool serves whatever is on disk under
`<installed-extension-dir>/resources/claude-customizations/`, where `<installed-extension-dir>`
is resolved by VS Code/Node at MCP-server-process-launch time, not the repository tree.

### Installed extension directories on this machine right now (verified via Glob/Read)

Four directories exist, under two different VS Code product lines and two different extension
identities:

| Directory | Product | Extension ID | Version | `resources/claude-customizations/.claude/hooks/` | Hook count |
| --- | --- | --- | --- | --- | --- |
| `C:/Users/DanMoisan/.vscode/extensions/undefined_publisher.drm-copilot-0.0.1` | VS Code (stable) | `undefined_publisher.drm-copilot` | 0.0.1 | present | 8 |
| `C:/Users/DanMoisan/.vscode-insiders/extensions/undefined_publisher.drm-copilot-0.0.1` | VS Code Insiders | `undefined_publisher.drm-copilot` | 0.0.1 | present | 8 |
| `C:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.1.10` | VS Code Insiders | `danmoisan.drm-copilot` | 1.1.10 | present | 44 |
| `C:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.1.11` | VS Code Insiders | `danmoisan.drm-copilot` | 1.1.11 | present | 44 |

The two `undefined_publisher.drm-copilot-0.0.1` directories are an old unpublished dev-sideload
identity (no `publisher` field was set in `package.json` at that vintage) and carry only 8 hook
files each — a much smaller, older payload that predates most of the current hook set (no
`enforce-epic-merge-gate.ps1`, no `enforce-orchestration-preimplementation-gate*.ps1`, no
`enforce-pr-author-skill*.ps1`, no `.claude/lib/` at all under that resources tree — not
independently re-checked path-by-path beyond the hook glob above). This candidate the task
description named (`undefined_publisher.drm-copilot-0.0.1`) still exists but is stale relative
to the current repository's hook set and is not the identity the repository's own package.json
declares (`publisher: "DanMoisan"`, `version: "1.1.11"`).

The two `danmoisan.drm-copilot-1.1.10` / `1.1.11` directories are the current publisher identity
and both carry the full 44-file hook set, including every hook named in the epic's scope table
(`enforce-orchestration-preimplementation-gate.ps1` + 2 helper files, `enforce-epic-merge-gate.ps1`,
`enforce-model-routing-receipt.ps1`, `enforce-pr-author-skill.ps1` + 2 companion files,
`enforce-prd-feature-before-planner.ps1`).

**SearchScope:** `C:/Users/DanMoisan/.vscode/extensions/`, `C:/Users/DanMoisan/.vscode-insiders/extensions/`
**SearchPatterns:** `**/*drm-copilot*/package.json`, `resources/claude-customizations/.claude/hooks/*.ps1` under each match
**SearchResult:** exactly the four directories listed above; no other `drm-copilot` extension identity or version exists under either product's extensions folder.

### Staleness: live condition, not hypothetical (partially verified, partially inferred)

The repository's `extensions/drm-copilot/package.json` currently declares `"version": "1.1.11"`.
The installed `danmoisan.drm-copilot-1.1.11` directory's own `package.json` has an identical
version string and an `__metadata.installedTimestamp` of `1788969211681` (roughly five days
after the `1.1.10` directory's `1788532804340`). I did not diff file-by-file byte content between
the installed `1.1.11` hooks and the repository tree's hooks in this session (that comparison
requires reading matched pairs, which I did not do for every file); I verified only that the
same 44 filenames are present in both the installed `1.1.11` tree and the repository's
`pack-manifests/core.json` paths list (Q2). Because F1-F6 have not landed yet, there is by
definition no "corrected content" anywhere yet to compare against — the staleness question this
feature must gate on is **prospective**: after F2-F6 land in the repository tree, the installed
`1.1.11` (or whatever version is current at execution time) directory will **not** contain those
commits' changes until a rebuild+reinstall runs, because nothing in the installed-extension
lifecycle re-copies `resources/claude-customizations/` from the repository automatically (there
is no file-watch, no build step tied to `git commit`, and VS Code does not re-read an extension's
files from a git checkout it never installed from).

**Conclusion:** staleness relative to F2-F6's future content is a certainty by construction, not
something that needs demonstrating against today's tree. The plan's staleness-check gating task
(Q1's mandated first verification action) is real and must run at execution time, after F2-F6
have merged and after the rebuild/reinstall step — not now.

### Which installed directory does the MCP server actually serve? (verified logic; execution-time fact)

The MCP server's `extensionRoot` is resolved once per process, from wherever
`context.extensionUri` pointed for the specific VS Code window/product that spawned it
(`mcp-provider.ts` construction) — there is exactly one such value per running VS Code window,
determined by which product (stable vs Insiders) and which installed version VS Code's own
extension-scanner selected for the `danmoisan.drm-copilot` (or, in the stale case, the unrelated
`undefined_publisher.drm-copilot`) extension ID in that window. VS Code's extension scanner
selects the highest installed version for a given extension ID when duplicates exist on disk
(both `1.1.10` and `1.1.11` are the same ID `danmoisan.drm-copilot`), so within VS Code Insiders
the effective served directory is `danmoisan.drm-copilot-1.1.11`, provided that is the version VS
Code Insiders has actually activated in the currently running window (this fact — which window is
running, and which version it activated — is a runtime state of the live VS Code process that
cannot be established by reading files; it must be confirmed at execution time, e.g. via VS
Code's own "Help > About" or the Extensions view, or via `code-insiders --list-extensions
--show-versions` if a CLI is available to the executor).

`undefined_publisher.drm-copilot` is a **different extension ID** from `danmoisan.drm-copilot`
(different publisher segment), so both could theoretically be installed and active
simultaneously in the same window without VS Code deduplicating them against each other; if that
extension is also active, both extensions declare the identical MCP provider ID
`drmCopilotMcpProvider` (verified: `contributes.mcpServerDefinitionProviders[0].id ==
"drmCopilotMcpProvider"` in both `package.json` files), which is a naming collision VS Code would
need to resolve however it resolves duplicate contribution IDs — a further reason the plan should
not assume the stale `undefined_publisher` identity is inert without checking.

**Executor action required (cannot be resolved from this checkout):** before trusting any
single directory as "the" served payload, the executor must either (a) restrict the plan's
gating grep to the directory matching the extension ID and version VS Code's Extensions view (or
an equivalent CLI query) reports as currently active, or (b) gate on all four directories
(grep every one for the staleness literal) so an unexpected duplicate/legacy identity cannot
silently mask a stale serve path. Given the low cost of grepping four directories versus the risk
of gating on the wrong one, **(b) is the safer default for the plan.**

## Q2 — What the push-down actually copies

### Pack model (verified from code and `core.json`)

- `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts` implements
  `loadPackManifests` (loads `<pack>.json` from `pack-manifests/`, always including `core`),
  `computePublishedPaths` (unions every selected pack's `paths[]`, always including `core`'s),
  and `assertSingleCsharpToolchain`.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists 174
  paths under `"paths"`, including all 11 `.claude/lib/` module directories present in the
  repository (`hook-payload`, `requirements`, `model-routing`, `orchestrator-state`,
  `discovery-validation`, `codex-routing`, `blast-radius`, `cleanup-manifest`,
  `project-file-merge`, `mermaid`, `bash`), plus `config/orchestration-routing.json` and
  `config/blast-radius.json` (both confirmed present in the `paths` array, lines 157-158).

### Silent omission — proved from code, not inferred

`extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`
(`ExcludingFileSystem.listFiles`, lines 266-278) filters every enumerated source path through
`isPackIncluded` (lines 179-189) before it reaches the copy engine. `isPackIncluded` returns
`false` for any path not present in `this.publishedPaths` whenever a pack selection is active
(non-null `publishedPaths`, i.e., whenever the MCP call supplies `packs: ["core"]` or similar).
A file excluded at `listFiles()` is never read, never written to the destination, and produces no
error and no log entry distinguishing "correctly excluded" from "missing from the manifest by
omission." **A new file under `.claude/lib/<module>/` that is not added to `core.json`'s `paths[]`
is silently dropped when the caller passes `--packs core` (or any explicit pack list).** Calling
the tool with no `packs` argument at all publishes the entire bundled tree unfiltered
(`resolvePublishedPaths` returns `null` for an empty/omitted selection — no manifest read, no
filtering) and would not exhibit this failure mode; the risk is specific to a pack-scoped
invocation.

### `core.json` registration test — verified to exist

`tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1` exists (confirmed via
Glob) and asserts exactly two things against `core.json`'s `paths` array read via
`ConvertFrom-Json`: that `.claude/lib/model-routing/ModelRouting.psm1` is a member (`Should
-Contain`), and that it occurs exactly once (`Where-Object { $_ -eq $ExpectedPath } | Count`
`Should -Be 1`). This is a **per-module** test, not a single test asserting all 11 modules at
once — the epic's summary ("each `.claude/lib/` module is asserted to appear exactly once")
describes a *pattern* of one such file per module, not one file covering every module. F1 must
add its own `<NewModule>.Manifest.Tests.ps1` following this exact pattern (same `BeforeAll`
shape, same two `It` blocks, `$ExpectedPath` set to F1's new module path) — copying
`ModelRouting.Manifest.Tests.ps1` is not sufficient; a distinct test file naming F1's own path is
required, or F1's registration has no regression guard.

### The exact check the executor must run for F1's module (parameterized; module does not exist yet)

Parameterized shape (substitute `<module-dir>` and `<ModuleName>` with F1's actual directory and
file stem once F1 lands, e.g. `worktree-resolution` / `WorktreeResolution`):

```
grep -c '".claude/lib/<module-dir>/<ModuleName>.psm1"' \
  extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
```

Expected result: `1`. A result of `0` means F1's registration step (adding the path to
`core.json`) did not happen or targeted the wrong manifest; a result `>1` means a duplicate entry
(which the Pester test above would also catch, but the grep is the plan's own gating check, run
before trusting a green Pester run). Equivalently, the executor may run F1's own
`<ModuleName>.Manifest.Tests.ps1` (once it exists) and assert both `It` blocks pass — this is the
"named test over phrase search" preference from `.claude/skills/atomic-plan-contract/SKILL.md`
and should be the primary check; the grep above is the fallback if F1 has not yet produced that
test file at the point this gate runs.

### What else the push-down carries beyond `.claude/**` (confirmed)

`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:54`
(`ROOT_FOLDERS = [".claude", "config"]`) and `core.json` lines 157-158 confirm
`config/orchestration-routing.json` and `config/blast-radius.json` are both published alongside
`.claude/**`, matching the epic's claim exactly. `config/orchestration-routing.json` at the
destination is merged rather than overwritten (`RoutingMergeFileSystem`,
`ROUTING_MERGE_RELATIVE_PATH`), and `config/blast-radius.json` is derived rather than copied
(`BlastRadiusDeriveFileSystem` replaces the bundled bytes with a destination-specific module map)
— both are exceptions to the plain-overwrite rule, relevant to Q4.

## Q3 — Destination-content verification

### What the push-down returns (verified from code)

The MCP tool result (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:194-201`,
`PushDownServiceCallResult`) is `{ tool, workspaceRoot, summary: "Pushed bundled Claude Code
customizations into the destination workspace.", artifacts: [<path to a written JSON summary
artifact>] }`. The artifact itself (`renderPushDownSummary`,
`copilot-customizations-engine.ts:251-271`) records `repo_root`, `destination_root`,
`started_at`/`finished_at`, `created_count`, `overwritten_count`, `rewritten_reference_count`,
`placeholder_rewrite_count`, `unmatched_references`, and a `files[]` array with, per file, only
`relative_path`, `destination_status` (`created`/`overwritten`), and reference-rewrite counts.

**What this proves:** that a copy action ran, which destination-relative paths were touched, and
whether each was newly created or overwritten. **What this does not prove:** the content, hash,
or source version of any copied file. There is no content hash, no byte comparison, no source
file mtime, and no version marker anywhere in this return value or artifact. The issue's framing
("the exit code reports that files were copied, not which version") is confirmed precisely by
this schema, not merely by exit-code absence of detail — even the full JSON artifact carries
no version-identifying information.

### Recommended token form for the destination-content grep

Per `.claude/skills/atomic-plan-contract/SKILL.md` `## Wrap-Tolerant Assertion Authoring`:
prefer a named test over a phrase search where one exists (not available here — the destination
is a different repository with no drm-copilot Pester suite guaranteed to run against it), so a
search is the only option. The token must be short, single-line, non-interpolated, and free of
`<`, `>`, `${`, `$(`, `%`.

**Recommended form:** a single distinctive identifier introduced by the fix — a new reason-code
string constant, a new function/cmdlet name, or a new PowerShell parameter name unique to one of
F2-F6's changes (for example, the kind of value the epic's `### The resolution contract (F1)`
describes as an "ambiguity reason code" is exactly this shape: a short, greppable,
single-token string with no interpolation). This is preferable to a prose phrase from a comment
or error message, which is wrap-fragile across reformatting.

**Why the literal cannot be fixed now:** F2-F6 have not executed; no such identifier exists in
any commit yet. The plan cannot hardcode a specific string today without guessing at
implementation details that are properly F2-F6's decisions.

**How the executor derives it at execution time:** after F2-F6 land, run `git diff
<pre-epic-base>..HEAD -- .claude/hooks/ .claude/lib/` (or the equivalent scoped diff against each
child feature's own commits) and select one added, single-line, non-interpolated literal that is
unique to the new content and does not appear in the pre-fix version of the same file (verified
by grepping the OLD file content for the same literal and confirming zero matches). The plan step
must instruct the executor to quote that concrete literal in the plan step's own prose once
selected (per `.claude/skills/atomic-plan-contract/SKILL.md`'s "quote what the task will create"
rule), and then use the identical literal for both the pre-push-down installed-payload grep (Q1)
and the post-push-down destination-content grep (this section) — using two different literals for
the two checks would not prove the same content moved end to end.

### TaskMaster destination path — not discoverable from this checkout

**SearchScope:** this repository checkout (all directories), plus a repo-wide text search for
`TaskMaster`.
**SearchPatterns:** `Grep "TaskMaster"` across the full worktree; inspection of
`mcp-push-down-schema-properties.ts` for any hardcoded or defaulted destination path; inspection
of the existing runbook at
`docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/confirm-taskmaster-run-resume.runbook.md`.
**SearchResult:** `workspace_root` in the tool's input schema
(`extensions/drm-copilot/src/mcp-push-down-schema-properties.ts:1-5`) is a required, caller-supplied
absolute path with no default and no discovery logic anywhere in the push-down code path — the
tool has no built-in notion of "TaskMaster" or any other named destination. The 30 repository
files matching `TaskMaster` are exclusively this feature's own docs (`issue.md`, `spec.md`,
`user-story.md`, the epic, and the HI-1 runbook) plus unrelated matches in other features' text.
The HI-1 runbook (already authored, see `## Prerequisites`) independently reaches the same
conclusion: "The exact location of run `bugs-2026-09-11`'s state ... is **not knowable from this
checkout**." **Conclusion: the destination path is not discoverable from this repository and must
be supplied by the human operator or a prior-session record at execution time; it is an external,
caller-provided input to the tool, not a resolvable fact.**

## Q4 — The overwrite-a-destination-fix hazard

### No dry-run, diff, or backup mode (verified from the tool's input schema)

`extensions/drm-copilot/src/mcp-tool-definitions.ts:133-146` and
`mcp-push-down-schema-properties.ts:38-59` define the complete input surface for
`push_down_claude_customizations`: `workspace_root` (required), `packs` (optional array),
`csharp_variant` (optional enum), `memory_mode` (optional enum: `overwrite`/`merge`/`skip`,
applies only to files under the agent-memory subtree per `claude-filesystem-adapter.ts`'s
`isMemoryModeIncluded`). `additionalProperties: false` is set, so no other input — no `dry_run`,
no `diff`, no `backup`, no `--whatif` equivalent — is accepted or possible. The only path-scoped
protections that exist at all are the two special-cased destination files noted in Q2
(`config/orchestration-routing.json` merged; `config/blast-radius.json` derived); every other
published path, including every `.claude/hooks/*.ps1` file, is a plain overwrite
(`writeTextFile` with no pre-read comparison) whenever the source path differs in content from
what a prior push-down wrote, and even when it doesn't differ.

### What a pre-push-down safety check looks like given these actual capabilities

Because the tool provides no built-in protection, the only safety check available is external to
the tool call: before invoking `push_down_claude_customizations`, the executor must snapshot (or
grep for) any known local hand-fix literal at the destination (for example, whatever change
commit `4389d95b`'s `enforce-model-routing-receipt.ps1` fix introduced in TaskMaster, if it is
still present and un-superseded by an equivalent upstream fix from F5) and confirm that the
upcoming push-down's source content (the freshly rebuilt installed-extension payload, per Q1)
already contains an equivalent or superseding fix before overwriting. If the destination fix has
no upstream equivalent yet, the push-down must not run against that path until it does, or the
fix is lost a second time. This check has no automatable pass/fail signal from the tool itself;
it requires an explicit read-compare step the plan must author as its own gating task, using the
same wrap-tolerant single-token grep discipline as Q3.

## Automation Feasibility

*(HI-2: rebuild and reinstall the VS Code extension before the push-down)*

### Repository's own build/package/install commands (verified by reading files)

Two distinct, non-Marketplace mechanisms exist in this repository, and one CI-only mechanism that
does not apply here:

1. **`scripts/dev-tools/publish-sideloaded-extension.ps1`** — purpose-built for exactly this
   step. In order: `npm ci` (retryable, `Invoke-NpmCiWithRetry`), `npm run compile` (runs the
   extension's own `compile` script, which per `extensions/drm-copilot/package.json` is `tsc -p
   ./ --noEmit && npm run bundle:extension && npm run bundle:mcp-server`), `npx --yes
   @vscode/vsce package --allow-missing-repository --skip-license --out <timestamped vsix path>`,
   then `code --install-extension <vsix> --force` (or `code-insiders`, auto-resolved via
   `Resolve-VSCodeCliCommand` in the co-located `vscode-cli.helpers.ps1`, which prefers
   `code-insiders` when the invoking session's own environment variables indicate an Insiders
   terminal). The script is `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact =
   "Medium")]`; PowerShell's default `$ConfirmPreference` is `High`, so a `Medium`-impact action
   does not trigger an interactive confirmation prompt by default — the script runs
   non-interactively end to end unless the caller explicitly lowers `$ConfirmPreference` or passes
   `-Confirm`.
2. **`scripts/powershell/Publish-DrmCopilotExtension.ps1 -Package`** (documented in
   `extensions/drm-copilot/PUBLISHING.md`) — validates the manifest, builds, and packages a
   timestamped VSIX under `artifacts/vsix/`, with no publish. Installation is a separate manual
   step per the runbook (`code --install-extension "artifacts/vsix/....vsix"`). `-Publish` mode is
   interactive (typed version confirmation) and is Marketplace-only — not relevant to a local
   rebuild.
3. **`.github/workflows/publish-extension.yml`** — CI-only, triggers on `v*` tag push or
   `workflow_dispatch`; runs on `ubuntu-latest`/`windows-latest` GitHub-hosted runners; its
   `publish` job runs `vsce publish --pat` only `if: startsWith(github.ref, 'refs/tags/v')`. This
   is entirely separate infrastructure from a local rebuild — it cannot install anything into a
   developer's running VS Code instance, and a local rebuild does not touch it.

**Exact unattended command sequence for the rebuild+install sub-step** (PowerShell, from repo
root):

```powershell
pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force
```

This performs `npm ci`, `npm run compile`, `npx --yes @vscode/vsce package`, and
`code-insiders --install-extension <vsix> --force`, in that order, with no interactive prompts
under PowerShell's default confirmation preference.

### `vsce` / `@vscode/vsce` availability (verified: not pre-installed; resolved on demand)

`extensions/drm-copilot/package.json` has **no** `vsce` or `@vscode/vsce` entry in
`devDependencies` or `dependencies` (`Grep` for `vsce` in that file: no matches). No
`node_modules/` directory exists under `extensions/drm-copilot/` in this worktree at all (`Glob`
for `**/vsce/package.json` under that path: directory does not exist). Both build scripts invoke
it via `npx --yes @vscode/vsce ...`, which fetches the package from the npm registry on first use
if it is not already cached — **this requires npm registry network access at rebuild time**,
which I cannot confirm or deny from this session (no execution tool). PUBLISHING.md's own
"Troubleshooting" section documents `npm install -g @vscode/vsce` as the fallback if `npx`
resolution fails, confirming the repository's own maintainers have hit and documented this
dependency-resolution step as a known, expected part of the workflow rather than an unknown.

### `code` / `code-insiders` CLI availability — **not testable in this session (tool constraint)**

I cannot run `code --version`, `code-insiders --list-extensions`, or any other command in this
session: the task-researcher persona was invoked with only `Read`/`Grep`/`Glob`/`WebFetch`/`Write`
tools, with no Bash or PowerShell execution tool provided. **This is a tool constraint of my own
invocation, not an established environment limitation** — the orchestrator's own environment
description (in this same conversation) states a PowerShell/Bash-capable shell is available in
this worktree generally, and the executor role that will run F7's plan is expected to have
execution tools per the epic's own automation expectations for F2-F6.

**Indirect evidence supporting real availability, gathered by reading (not executing):**
- Four installed `drm-copilot` extension directories exist under both `.vscode/extensions/` and
  `.vscode-insiders/extensions/` on this machine (Q1), which is only possible if `code` and/or
  `code-insiders --install-extension` (or equivalent manual sideloading) has run successfully on
  this machine before.
- The installed `danmoisan.drm-copilot-1.1.11` directory's version string matches this
  repository's current `extensions/drm-copilot/package.json` version (`1.1.11`) exactly, and its
  `__metadata.installedTimestamp` postdates the `1.1.10` install by about five days — consistent
  with a working rebuild-and-reinstall cycle having been exercised repeatedly and recently on this
  exact machine, using the exact mechanism described above (no other documented path installs
  this extension locally).

Given this, the CLI-availability question is **not a demonstrated blocker** — it is a fact that
was not (and, with this session's toolset, could not be) directly re-verified, but for which
strong indirect evidence of prior success exists. The plan must still have its executor (who will
hold execution tools) confirm `code-insiders --version` (or `code --version`) succeeds before
relying on the sideload script, as the very first step of that gating task, rather than assuming
it from this research.

### Restart/reload requirement — **verified from code that the extension never signals it**

`extensions/drm-copilot/src/mcp-provider.ts` creates `mcpDidChangeEmitter = new
vscode.EventEmitter<void>()` and wires it as `onDidChangeMcpServerDefinitions:
mcpDidChangeEmitter.event` (line 26), but **no code anywhere in `extensions/drm-copilot/src/`
ever calls `.fire()` on it** (`Grep` for `.fire()` and `DidChangeEmitter` across `src/`: only the
declaration and the two wiring lines match; no invocation). This means the extension has no
self-triggered mechanism to tell VS Code "my server definition changed, re-fetch it." Combined
with the well-established VS Code extension-host lifecycle behavior that an already-activated
extension's in-memory module is not replaced when a newer version is written to disk (activation
happens once per window session; a new version takes effect only on the next activation, which
normally follows a window reload or a full VS Code restart), **a successful, exit-code-0 rebuild
and reinstall does not by itself make the running VS Code window's MCP server process serve the
new payload.** The already-spawned `node <old-extensionUri>/out/mcp-server.js` process (if one is
already running for the current session) keeps resolving `extensionRoot` from the OLD
`__dirname`, unaffected by files changed on disk under a different (or even the same) path,
because Node does not re-read `path.resolve(__dirname, "..")` per call in a way that changes
after the process starts — the value is fixed once, at process start.

This part of the claim (VS Code's general extension-host reactivation behavior) is stated as an
architectural inference grounded in the extension's own code (no self-fire path exists) plus
documented VS Code platform behavior; it was not independently re-verified by triggering an
actual install-then-observe cycle in this session, because I have no execution tool.

**No automated, non-disruptive path to force the specific already-running window to reload exists
in this repository's tooling.** The extension contributes no "reload" or "restart MCP server"
command of its own (confirmed against the full `contributes.commands` list in
`extensions/drm-copilot/package.json`: no such command). VS Code's own "Developer: Reload Window"
action is a Command Palette action with no supported external-CLI equivalent for reloading an
already-running window from outside; the alternative — killing and relaunching the VS Code
process — is disruptive (it would also terminate whatever session, including potentially this
very agent's own tooling connection, is running inside that window) and is not attempted by any
script in this repository.

### Known constraint check — release/publish automation is patch-only and merge-gated

**Conclusion: does not bear on this step.** `.github/workflows/publish-extension.yml` is CI-only,
triggers on `v*` tag pushes to the remote, and its publish step targets the VS Code Marketplace
via `vsce publish --pat`. A local rebuild+reinstall via `publish-sideloaded-extension.ps1` touches
none of that path: it makes no git commit, opens no PR, requires no merge, pushes no tag, and
never calls `vsce publish`. The "patch-only automation" and "agent-blocked merge" properties
described for this repository's release pipeline are properties of the Marketplace-publish path,
which F7 does not use. The Marketplace publish path (`Publish-DrmCopilotExtension.ps1 -Publish`)
is explicitly out of scope for F7 — a local VSIX install requires no version bump, no PR, and no
merge.

### Environment/tool-constraint summary

- Rebuild + package + local install: automatable via an existing, purpose-built, non-interactive
  script (`publish-sideloaded-extension.ps1`). Not independently executed in this session (tool
  constraint); strong indirect evidence of repeated prior success on this machine.
- `code`/`code-insiders` CLI presence: not testable in this session (tool constraint, not an
  environment limitation); indirectly evidenced as present and working.
- Reload/restart required for the new payload to be served: verified from code (no self-fire
  path) plus documented VS Code architecture (not independently re-verified by observation in
  this session); no automated, safe path to trigger it exists in this repository's tooling today.

### HI-2 RESOLUTION: exception

**Justification:** the build/package/install sub-steps of "rebuild and reinstall the VS Code
extension" are automatable today via an exact, existing, non-interactive command
(`pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force`),
and the plan should treat that sub-step as `scope_change` — replace the manual instruction with
this concrete command. However, the step only accomplishes its purpose (making the push-down
serve corrected content) if the running VS Code window's MCP server process picks up the newly
installed files, and this repository's own code contains no self-triggered refresh path
(`mcpDidChangeEmitter` is never fired) and no scripted, non-disruptive way to force an
already-running window to reload. That sub-step — confirming or triggering the reload so the new
payload is actually served — requires a human to either reload the window (Command Palette:
"Developer: Reload Window") or restart VS Code, because no safe automated substitute exists in
this repository today. The plan must therefore:

1. Run the scope_change command above to rebuild and reinstall (automatable).
2. **Exception:** require a human to reload/restart the VS Code window hosting the extension
   before continuing, because no automated non-disruptive trigger exists.
3. Gate all subsequent steps (Q1's staleness grep, and everything after it) on the *result* of
   that reload, not on step 1's exit code — the staleness grep itself is what proves the reload
   happened, so the plan does not need a separate signal for "reload complete," only the ordering
   discipline in Q6 below.

## Candidate approaches (reload-verification mechanism)

- **Approach A (recommended): human-triggered reload + post-reload grep gate.** Simple, matches
  existing repository conventions (manual `code --install-extension` + "verify the extension
  loads... in a real VS Code window" is exactly what `PUBLISHING.md`'s Mode 2 already documents),
  and the grep-based staleness check (Q1) already doubles as the reload-completion signal — no new
  mechanism is needed beyond ordering the exception correctly.
- **Approach B (rejected): forcibly kill and relaunch the VS Code process from a script.** Would
  make the reload step "automatable," but no script in this repository does this, it risks
  terminating the very session the operator (or an agent) is using to run the rest of the plan,
  and it has no graceful equivalent for a window with unsaved state. Not adopted.

## Q6 — Ordering constraints for the plan

1. **Rebuild + package + install** (scope_change command from Automation Feasibility). Gates
   because nothing after it can carry corrected content without it.
2. **Human reload/restart of the VS Code window** (exception). Gates because the install's files
   on disk are inert to the already-running MCP server process until this happens (verified: no
   self-fire refresh path exists).
3. **Installed-payload staleness/freshness grep** (Q1's mandated first verification action),
   against every installed `drm-copilot`-identity directory found relevant at execution time (Q1's
   safer-default recommendation), for the concrete literal derived per Q3. Gates because it is the
   only available proof that step 2 actually took effect; a plan that skips straight to the
   push-down after step 1 verifies nothing (this is the "verification trap" itself).
4. **`core.json` manifest-registration check** for F1's new module path (Q2's parameterized
   grep or Pester test). Gates because it must be confirmed before the push-down call uses
   `--packs core`, or the module is silently omitted with no error.
5. **Destination pre-check for a still-unsuperseded local hand-fix** (Q4). Gates because it must
   run before the push-down call, not after — once the push-down runs, an unsuperseded fix is
   already overwritten and the check is too late to prevent the regression it exists to catch.
6. **The push-down call itself**
   (`mcp__drm-copilot__push_down_claude_customizations`, with an explicit `workspace_root` the
   operator supplies, since it is not discoverable — Q3).
7. **Destination-content grep** (Q3's token, same literal as step 3) against the TaskMaster
   destination. Gates the human-exception runbook (HI-1) — per that runbook's own `## Cue`
   section, the resume-confirmation step must not begin before this passes.
8. **HI-1 human-exception runbook** (already authored at
   `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/confirm-taskmaster-run-resume.runbook.md`).
   Out of this document's scope beyond noting it is the correct terminal step.

## Rejected alternatives

- Treating HI-2 as `scope_change` in full (fully automating install + reload): rejected because no
  safe, repository-native mechanism exists to force reload of an already-running window; forcibly
  killing/relaunching VS Code (the only way to guarantee reactivation without a human) is
  disruptive and unattempted anywhere in this repository's tooling.
- Treating HI-2 as `halt`: rejected because the build/package/install portion is demonstrably
  automatable today (existing script, non-interactive by default, strong indirect evidence of
  prior success on this machine) — a `halt` would discard real, usable automation over a narrower
  problem (the reload) that `exception` already handles correctly.
- Gating the staleness/freshness check on only the single "most likely" installed directory:
  rejected because a second, differently-identified extension (`undefined_publisher.drm-copilot`)
  coexists on this machine and declares the same MCP provider ID; gating on all discovered
  directories is cheap and removes the ambiguity.

## Testing implications

This feature ships no new production logic, so no new unit-test suite is implied. The plan's
verification steps (Q1, Q3, Q4) are themselves the acceptance evidence and must be captured as
evidence artifacts under `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, each carrying the grep command,
its literal output, and (for every negative claim, e.g. "the old literal is absent") the
`SearchScope`/`SearchPatterns`/`SearchResult` triple this document uses throughout. The only
existing regression-guard test relevant to this feature is
`tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1`'s pattern, which F1 (not
F7) is responsible for replicating for its own new module.
