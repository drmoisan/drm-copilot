# 2026-09-13-collect-pr-context-explicit-target (Spec)

- **Issue:** #675
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T23-05
- **Status:** Ready for planning
- **Version:** 0.3 — verification-command corrections only (diff anchor moved from the moving ref `main` to the fixed commit `499e288a`; tracked-only diffs paired with `git status --porcelain` companions). No criterion was added, removed, split, merged, or rescoped.
- **Epic:** `worktree-scoped-state-resolution`, feature F6 (wave 0, complexity C2), scope row 3.5
- **Work Mode:** `full-bug` — `spec.md` is the sole acceptance-criteria source; `user-story.md` is not authored for this mode.
- **Research record:** `research/2026-09-13T21-30-collect-pr-context-explicit-target-research.md`

## Context
`mcp__drm-copilot__collect_pr_context` resolves the branch and diff base from the invoking session's workspace rather than from an explicit target supplied by the caller, and it emits a context containing a zero-line diff without signalling an error. The two defects compound: a call made from a coordinating session produces a vacuous PR context that is indistinguishable from a legitimately empty result, and that context propagates into a PR body.

This is defect 3.5 of the `worktree-scoped-state-resolution` epic and shares the epic's root cause: state resolved against the invoking session's current working directory instead of against the call's actual target.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable; the affected surface is TypeScript under `extensions/drm-copilot/`
- Command/flags used: `mcp__drm-copilot__collect_pr_context` with `workspace_root` and `base`
- Data source or fixture: TaskMaster parallel run `bugs-2026-09-11` (2026-09-12/13)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A vacuous PR context is a silent failure. It is consumed by `Agent(pr-author)` to author a PR body, so an empty diff summary reaches a human reviewer as an assertion that the branch contains no changes.


## Repro & Evidence
Steps to Reproduce:
1. From a coordinating orchestration session whose current worktree is worktree A, invoke `collect_pr_context` intending to collect context for the change that lives in worktree B.
2. Observe the returned summary artifact `artifacts/pr_context.summary.txt`.
3. Re-run the same collection from inside worktree B and compare the two artifacts.

Expected:
The call identifies the branch and diff base it pertains to from an explicit caller-supplied target, not from the invoking session's workspace. When the resulting diff is empty, the call fails with a specific, actionable error rather than returning a context that reports no changes.

Actual:
The first invocation returned a PR context whose diff was empty, because it reflected the invoking session's worktree branch rather than the target branch. The call returned `ok`, so the empty result read as a successful collection. It was corrected only by re-running the tool from inside the fix worktree.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: not captured at the time; the observation is recorded in the epic manifest `docs/features/epics/worktree-scoped-state-resolution/epic.md` under scope row 3.5.


## Scope & Non-Goals

### In scope

1. An optional `target_ref` input on the `collect_pr_context` tool, declared identically on both tool-definition surfaces, resolved in `mcp-tool-inputs.ts`, and threaded through `RepoAutomationService.collectPrContext` and `collectPrContextServiceCall` into the collector's existing `head` option.
2. Rejection of an empty or whitespace-only `target_ref` at input resolution.
3. A machine-readable target-provenance record on the returned result: `target_resolution`, `resolved_head_ref`, `resolved_head_sha`, projected onto the MCP result by `mcp-tools.ts`.
4. A human-readable `Head ref (source):` line in the summary artifact's `Base/Head` block.
5. A new pure module classifying the collected diff state, and a loud failure raised from `collectPrContextServiceCall` for the two failing states (refs unresolved; refs resolved but no file changed), with distinct messages.
6. A cross-surface tool-definition parity test, which does not exist today for any tool at `properties`/`required` granularity.
7. **Updating the existing tests that currently run against an empty git diff.** The research record establishes that the command-runner fakes in five suites return an empty string for every unmatched git subcommand, so every collector-driving test in those suites currently computes a zero-file diff and will fail the moment the guard lands. The affected files are `test/lib/pr-context/pr-context-service-call.test.ts`, `test/extension.collect-pr-context.test.ts`, `test/extension.integration.test.ts`, `test/repo-automation-dispatch-pr-context-verification.test.ts`, and `test/repo-automation-dispatch.test.ts`. Each affected test is **updated to script a non-empty diff**, not deleted. Deletion would silently drop the path-identity and freshness coverage added by issue #574. This is the largest single piece of work in the feature and is not visible from the issue text.
8. A `coverageThreshold` entry in `jest.config.cjs` for every production file this change adds or brings into scope that is not interface/type-only.
9. Whatever extraction is required to keep every changed file under the 500-line cap. `src/repo-automation-service.ts` is 498 lines and must forward a new field; extraction or an equivalently line-neutral change is required there. `src/lib/pr-context/collector-output.ts` (485) and `src/mcp-tool-inputs.ts` (480) are similarly constrained.

### Out of scope / non-goals

- **All `.claude/**` prose.** No file under `.claude/` is edited by this feature. This is a deliberate decision, recorded so that no phantom parity task and no silent omission is carried — see Decision 7 under **Proposed Fix**. Consequently the epic's bundled-payload mirroring rule (`epic.md` "Bundled-payload mirroring") does **not** activate, and no edit is made under `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- **Rebuilding and reinstalling the VS Code extension.** MCP tools resolve their resources from the installed extension, not from the repository tree, so this change is inert at the live `mcp__drm-copilot__collect_pr_context` surface until that rebuild happens. The rebuild is epic feature F7 (`taskmaster-push-down-and-resume`). No acceptance criterion here calls the live MCP tool.
- **A path-valued `target_worktree` parameter**, and therefore any relocation of the working-tree sections (`git status -sb`, staged/unstaged diffs, untracked files) or of `gh pr view` resolution. Those remain scoped to `workspace_root`. See Decision 2.
- **Tightening `target_ref` to required.** Assessed at F7 or later, once every in-repo prompt passes it.
- **Codex parity.** No `.codex/` file declares this tool's input schema; Codex consumes the published npm MCP server built from the same `src/`. `epic.md` names Codex parity obligations for F2 and F3 only.
- **Detecting a wrong target that is not empty.** If the invoking worktree is on a different branch that does have commits ahead of base, the collector emits a fully populated but wrong context. The empty-diff guard cannot detect that case; only supplying an explicit `target_ref` does. This boundary is stated rather than implied.
- **Weakening the pre-implementation gate's pathspec, option, or metacharacter restrictions, and widening the epic-merge gate's `pr_number` matcher.** Both are epic must-not-regress constraints and neither is touched by this feature.
- `src/pr-context-branches.ts` (base-candidate discovery for the VS Code quick pick). It resolves base candidates only and has no head/target resolution.

### Explicitly excluded systems, integrations, or datasets

- The live MCP surface and the installed VS Code extension build.
- The published npm package `@danmoisan/drm-copilot-mcp` pinned in `.codex/config.toml`.
- The TaskMaster consumer repository, which is not present in this checkout.
- `.claude/hooks/enforce-pr-author-skill.ps1`, which reads `artifacts/pr_context.summary.txt` as a path relative to the invoking session. Its resolution must remain valid, which is one reason the artifact output root stays `workspace_root`.

## Root Cause Analysis
Files to inspect (verified present 2026-09-13):

- `extensions/drm-copilot/src/lib/pr-context/` — 16 files, including `pr-context-service-call.ts`, `git-client.ts`, `collector-core.ts`, `collector-output.ts`, `models.ts`, `render.ts`.
- `extensions/drm-copilot/src/pr-context-branches.ts`.
- `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` — the tool is declared in both; a parameter addition must be applied consistently to both or the declarations drift.
- `extensions/drm-copilot/src/mcp-tools.ts` — dispatch.

`CollectPrContextServiceCallInput` in `pr-context-service-call.ts` currently carries `workspaceRoot` and `base` only; there is no target branch or target worktree parameter, so the branch under description is whatever the workspace root resolves to.

### Defect 1 — the head is always the invoking session's HEAD

The only caller-controlled inputs are `base` and `workspace_root`. `workspace_root` is used for three distinct purposes that the current design conflates: the artifact output root, the git working directory, and the repo-root probe subject.

`collectPrContextServiceCall` calls `collectAndWrite` without a `head` option, so `CollectPrContextOptions.head` is `null` at `collector-core.ts`. `render.ts` then computes `headRefResolved = headRef || branchName`, where `branchName` is `git rev-parse --abbrev-ref HEAD` executed in the workspace root. Head ref, head SHA, merge base, the `mergeBase..headSha` range, and every range diff therefore follow the invoking session's worktree. `gh pr view` is likewise invoked with no branch selector, so the "current PR" is the cwd worktree's PR.

One mitigating fact bounds the fix: the plumbing for an explicit head already exists below the service-call layer. `CollectPrContextOptions.head` and `BuildPrContextOptions.headRef` are already honoured, and `test/lib/pr-context/collector-integration.test.ts` already exercises `head: "feature/docs"`. Only the MCP schema, `mcp-tool-inputs.ts`, the service contract, and `pr-context-service-call.ts` omit it.

`process.cwd()` is not on this path. `inferWorkspaceRoot` in `mcp-tools.ts` uses it only to populate `workspace_root` on the failure result; the success path re-resolves with no fallback, and `workspace_root` is mandatory at that boundary.

### Defect 2 — no empty-diff branch exists

There is no code path that distinguishes an empty result from a populated one. An empty name-status text parses to empty maps, the bucket loop produces three empty arrays, and `bucketText` renders `"<bucket>: 0 files"`. The returned `summary` string is a function of `base` alone, so `toMcpToolResult` copies it through with `ok: true`. The only failure this surface can currently report is the artifact read-back verification added by issue #574, which checks that the bytes written are the bytes rendered — not that the bytes describe anything.

An empty overview is reachable through four states, three of which are distinguishable from the collected record:

| # | Mechanism | Observable state | Distinguishable |
| --- | --- | --- | --- |
| A | Head is an ancestor of base (`mergeBase === headSha`) | both non-null and equal | yes |
| B | Wrong worktree whose HEAD is at or behind base | identical to A in the git data | no — A and B are the same state; this is the #675 field observation |
| C | Base ref does not resolve | the `render.ts` catch-all fires; `baseSha`, `headSha`, `mergeBase`, `revRange` are all `null` and the appendix carries a `(FAILED to compute PR context: ...)` marker | yes |
| D | Range is real but its net diff is empty | both non-null, unequal, zero changed files | yes, by elimination |

C has a second-order effect: because `mergeBase`/`headSha` become `null`, `collector-core.ts` silently falls back to the working-tree diff, which on a clean tree is also empty. A failed base resolution and a no-op branch therefore produce visually similar summaries today.

The fix distinguishes C from A/B/D because the corrective actions differ: C is a bad `base` argument, A/B is a wrong target, and D is genuinely nothing to describe. It does **not** attempt to distinguish A from B, which are the same state in the git data; any such attempt would be a heuristic.


## Proposed Fix

### Design summary (what changes where):

Add an optional `target_ref` (a git ref string) to both `collect_pr_context` tool schemas and to `resolveCollectPrContextToolInput`. Thread it through `RepoAutomationService.collectPrContext` into `collectPrContextServiceCall`, which forwards it as the collector's existing `head` option. Return a target-provenance record alongside the existing result fields, and render a `Head ref (source):` line into the summary's `Base/Head` block. Add a new pure module that classifies the collected diff state and raise from `collectPrContextServiceCall` on the two failing states, after both artifacts have been written and read-back-verified. Add a cross-surface tool-definition parity test. Update the existing suites that currently compute an empty diff.

This is Approach A from the research record. Approach B — a required, path-valued `target_worktree` with the collector's git cwd redirected to it — is rejected; see Decisions 1 and 2.

### Settled decisions

**Decision 1 — the parameter is OPTIONAL with a fallback, and the fallback is mandatorily recorded.** This adopts the research recommendation. The epic and the issue both forbid a *silent* fallback; neither forbids a fallback. `epic.md` fix 1 reads "Use the session root only when the call genuinely has no target", and `issue.md` reads "an optional target must make the fallback observable in the output". An optional parameter with a mandatory, machine-readable provenance record satisfies both. Reasoning, in order of weight:

1. A required parameter would break every prompt-surface caller with no compile-time signal. The production code call sites are compile-checked and would be fixed mechanically; the prompt-surface callers are prose, and `additionalProperties: false` plus `required` would turn each one into a hard MCP validation error the first time it runs after F7 ships — inside a consumer repository whose prompts this repository does not control.
2. A required parameter does not by itself prevent the defect. The field failure was a caller supplying a correct-looking but wrong `workspace_root`; a caller confused about which worktree it is acting for will supply a wrong `target_ref` just as readily. What caught the defect was a human noticing a zero-line diff. **The empty-diff guard, not the parameter's requiredness, is the load-bearing half of the fix.**
3. Requiredness is recoverable later; a broken consumer is not. Tightening to required once every in-repo prompt passes it is a strictly lower-risk ordering, and F7 is the natural point to assess it.

The research record enumerates the callers (18 prompt-surface, 4 production call sites, none passing anything beyond `base`). Those figures are descriptive findings carried from research; no count is asserted as an acceptance criterion.

**Decision 2 — the parameter is a single optional `target_ref` (a git ref string), not a path-valued `target_worktree`.** This adopts the research recommendation. All worktrees of a repository share one object store and one ref namespace, so `git rev-parse --verify` and `git merge-base` resolve a sibling worktree's branch correctly from any worktree; a ref is sufficient for the range diff. A path parameter would additionally relocate the working-tree sections and `gh pr view` resolution, and would either relocate the artifact outputs or introduce a second root concept. Relocating the artifacts would break `.claude/hooks/enforce-pr-author-skill.ps1`, which reads `artifacts/pr_context.summary.txt` as a path relative to the invoking session. That is a materially larger surface than a C2-banded feature should carry.

Documented limitation accepted as a consequence: the working-tree sections and the current-PR lookup remain scoped to `workspace_root` even when `target_ref` is supplied. This is recorded in the new module's doc comment rather than left implicit.

**Decision 3 — the fallback is made observable in BOTH the returned record and the summary artifact.** This adopts the research recommendation, because the two have different consumers. The record is what an agent caller can branch on; the summary line is what a human reviewer and `Agent(pr-author)` read. The summary line is placed immediately after `Head ref (resolved):` so a fallback cannot be read without the head it produced being read in the same glance.

**Decision 4 — on a failing diff state, the artifacts are written first and the error is raised after.** This adopts the research recommendation. The summary is the operator's primary diagnostic for *why* the diff was empty, and not writing it would change the `writtenPaths == result.artifacts` invariant that `test/lib/pr-context/pr-context-service-call.test.ts` ("writes exactly the paths it reports in result.artifacts") guards. The existing read-back verification still runs before the classification, so a write failure is reported as a write failure rather than being masked by an empty-diff error.

**Decision 5 — the guard lives in a new pure module called from `pr-context-service-call.ts`.** This adopts the research recommendation. `collector-core.ts` (475 lines, 25 of headroom) and `collector-output.ts` (485 lines, 15 of headroom) cannot absorb the classifier plus its message construction, which realistically runs 30-50 lines across the three distinguishable states. `pr-context-service-call.ts` is 142 lines. A pure classifier is also the shape most easily driven by table-driven tests and most easily brought to 85/75 branch coverage, and it matches the repository's separation-of-concerns rule.

Acknowledged consequence: `src/repo-automation-service.ts` is 498 lines with 2 of headroom and must forward the new field and accept the widened input type. An extraction is expected to be required there — for example, moving the `collectPrContext` input type to `repo-automation-service-contract.ts` (198 lines) so the implementation file's method signature does not grow. The implementer measures the file after the edit and extracts if it exceeds 500 lines; this is part of the change, not optional cleanup.

**Decision 6 — an empty or whitespace-only `target_ref` is rejected by input validation.** It is not silently treated as absent. Treating `""` as absent would restore exactly the silent fallback the epic forbids, because the caller would believe it supplied a target and the record would report `session-fallback` for a reason the caller never sees at the call boundary.

**Decision 7 — this feature edits no `.claude/**` prose, and the deferral is explicit.** The only document that prescribes an argument shape for this tool is `.claude/skills/pr-base-branch-merge-base/SKILL.md` (`base=<resolved-PRBaseBranch>`); `.claude/skills/orchestrate/SKILL.md` and `.claude/agents/orchestrator.md` name the tool with no parameters. Documenting `target_ref` in any of those files would activate the epic's bundled-payload rule and make the paired `extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror edits mandatory in the same change. Because the parameter is optional (Decision 1), no prompt is incorrect without the update, and because the change is inert at the live tool until F7 rebuilds the extension, documenting it now would describe a capability the installed build does not have. **All `.claude/**` prose for `target_ref` is therefore deferred to epic feature F7.** This deferral is stated here so the plan carries neither a phantom parity task nor a silent omission. It is verified negatively by an acceptance criterion asserting that no file under `.claude/` or `extensions/drm-copilot/resources/` is modified.

### Boundaries and invariants to preserve:

- **Epic must-not-regress, carried verbatim:** "Epic and standalone topologies must behave exactly as now when cwd and target coincide." A single-worktree caller that supplies no `target_ref` and has a non-empty diff observes byte-identical behaviour apart from the added `Head ref (source):` summary line. The only behavioural change such a caller can observe is the new empty-diff failure.
- **Epic must-not-regress, carried verbatim:** "Do not weaken the pre-implementation gate's pathspec, option, or metacharacter restrictions." Entirely out of scope; no hook is touched.
- **Epic must-not-regress, carried verbatim:** "Do not widen the merge gate's matcher as a side effect of fixes 1-3." Entirely out of scope; no hook is touched.
- **Epic must-not-regress, carried verbatim:** "Gates must still deny when a required document is genuinely absent." No gate is touched; the analogous invariant here is that the read-back verification introduced by #574 still raises on a discarded write.
- `writtenPaths == result.artifacts` — the set of paths written equals the set reported, including on the failing-diff path where the error is raised after both writes.
- `workspace_root` remains the artifact output root in every case, so `.claude/hooks/enforce-pr-author-skill.ps1` continues to resolve `artifacts/pr_context.summary.txt` relative to the invoking session.
- `workspace_root` and `base` remain required, with their existing error messages unchanged.
- Graceful degradation when the GitHub CLI is unavailable remains a success, as `test/lib/pr-context/pr-context-service-call.test.ts` ("writes both artifacts and succeeds when the GitHub CLI is unavailable") asserts.
- The returned `summary` string continues to name the base on the success path.
- No production file under `src/` is added to any coverage exclusion.

### Dependencies or blocked work:

- `depends_on: []`. F6 is a wave-0 feature and consumes nothing from F1.
- F7 (`taskmaster-push-down-and-resume`) depends on this feature. F7 owns the extension rebuild, the push-down, and the deferred `.claude/**` prose.
- `npm ci` in `extensions/drm-copilot/` is a hard prerequisite before any toolchain stage. `node_modules` was absent in the fresh worktree at baseline capture; without `npm ci`, `npx eslint` exits 2 and `npx tsc` exits 1.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| Path | Lines today | Change |
| --- | --- | --- |
| `src/mcp-tool-definitions.ts` | 457 | Add the `target_ref` property to `collect_pr_context`; `required` stays `["workspace_root", "base"]`. |
| `src/mcp-repo-automation-tool-definitions.ts` | 420 | Identical addition. |
| `src/mcp-tool-inputs.ts` | 480 | `resolveCollectPrContextToolInput` resolves and validates `target_ref`. 20 lines of headroom; extract to a sibling `mcp-tool-inputs-*.ts` if the validation exceeds it, following the existing split precedent. |
| `src/repo-automation-service-contract.ts` | 198 | Widen the `collectPrContext` input type and add the optional provenance fields to `RepoAutomationExecutionResult`. Interface-only; remains deliberately omitted from the threshold map for the documented reason. |
| `src/repo-automation-service.ts` | 498 | Forward `targetRef`. **2 lines of headroom — extraction expected.** |
| `src/lib/pr-context/pr-context-service-call.ts` | 142 | Accept `targetRef`, forward it as `head`, classify the returned diff state, raise on the two failing states, and build the provenance fields. |
| `src/lib/pr-context/collector-output.ts` | 485 | Return enough of the collected record from `collectAndWrite` for the service-call layer to classify without re-running git, and emit the `Head ref (source):` line. **15 lines of headroom — measure after the edit and extract if over.** |
| `src/lib/pr-context/summary-helpers.ts` | 389 | Host the pure `Head ref (source):` line renderer, which is where the repository already keeps summary-text helpers. Already gated at 85/75. |
| `src/lib/pr-context/diff-emptiness.ts` | new | The pure diff-state classifier and its message construction. |
| `src/lib/pr-context/index.ts` | 115 | Export the new module. |
| `src/mcp-tools.ts` | 348 | Project the three provenance fields in `toMcpToolResult` and declare them on `RepoAutomationMcpToolResult`. |
| `jest.config.cjs` | 278 | Add the `coverageThreshold` entry for the new module and for any other newly-in-scope non-interface file. |

No change is expected in `git-client.ts`, `render.ts`, `models.ts`, `collect-context-handlers.ts`, or `pr-context-branches.ts`. If any of them does change, it is currently ungated and requires a new `coverageThreshold` entry.

#### Functions/classes/CLI commands impacted:

- `resolveCollectPrContextToolInput`, `CollectPrContextToolInput`.
- `RepoAutomationService.collectPrContext`, `RepoAutomationExecutionResult`.
- `collectPrContextServiceCall`, `CollectPrContextServiceCallInput`, `CollectPrContextServiceCallResult`.
- `collectAndWrite`, `CollectAndWriteResult`, `buildSummaryText`.
- `toMcpToolResult`, `RepoAutomationMcpToolResult`.
- New: `classifyPrContextDiffState` in `src/lib/pr-context/diff-emptiness.ts`.
- The VS Code command `drmCopilotExtension.collectPrContext` is unchanged. It passes no `targetRef` and therefore takes the session-fallback path, which is its correct behaviour: a command invoked from a workspace genuinely has that workspace as its target.

#### Data flow and validation changes:

1. `target_ref` is resolved at the MCP boundary. Absent key → the field is omitted from the resolved input. Present and a non-empty, non-whitespace string → carried as `targetRef`. Present and empty, whitespace-only, or a non-string → rejected with an error naming `target_ref`.
2. `targetRef` is forwarded as the collector's `head` option. When it is absent, `head` stays `null` and the collector resolves the head from `workspace_root` exactly as today.
3. `collectAndWrite` returns the collected diff state to its caller so the classification needs no second git invocation. The classifier's input is the merge base, the head SHA, and the changed-file count derived from the three buckets already present on the collected record.
4. `target_resolution` is `"explicit"` when a `targetRef` was supplied and `"session-fallback"` otherwise. `resolved_head_ref` and `resolved_head_sha` are the values the collector actually used, so a caller can compare them against what it intended.

#### Error handling and logging updates:

Two new failure conditions, each with a distinct message so an operator can grep them apart:

- **Refs unresolved** (`mergeBase === null || headSha === null`; state C). The message names the requested base, the head ref that was attempted, and the underlying git failure text. The corrective action is to fix the `base` argument.
- **Refs resolved, no file changed** (states A, B and D). The message names the resolved head ref, the head SHA, the merge base, and the resolved base, phrased so an operator can see at a glance that the head is not the branch they meant. The corrective action is to supply or correct `target_ref`.

Both raise from `collectPrContextServiceCall` after both writes and both read-back verifications have completed. Both surface as `ok: false` through the existing `toFailureToolResult` path. Existing errors — missing `workspace_root`, missing `base`, artifact read-back mismatch — are unchanged in text and in ordering. The two existing `Wrote context ...` log lines are unchanged.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. The change is additive at the schema boundary, and the empty-diff guard is intentionally not opt-out: an opt-out would reintroduce the silent-success mode the epic exists to eliminate. Rollback is a revert of the branch; because the parameter is optional, a revert leaves no caller broken.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Tool input schema, identical on both definition surfaces:

- `workspace_root` — string, required, unchanged.
- `base` — string, required, unchanged.
- `target_ref` — string, **optional**. A git ref naming the head of the comparison. Resolved through the repository's shared ref namespace, so a ref belonging to a sibling worktree resolves correctly.
- `additionalProperties: false` is retained; `required` remains `["workspace_root", "base"]`.

Result record additions, all optional on `RepoAutomationExecutionResult` and projected to snake_case on the MCP result:

- `target_resolution` — `"explicit" | "session-fallback"`.
- `resolved_head_ref` — the head ref actually used.
- `resolved_head_sha` — the head SHA actually used.

Summary artifact addition, in the `Base/Head` block immediately after `Head ref (resolved):`, one of:

- `Head ref (source): explicit target` followed by the supplied ref, or
- `Head ref (source): session fallback` followed by the reason and the workspace root it was derived from.

The exact wording is the implementer's, subject to the acceptance criterion that the line begins with the literal `Head ref (source):` and that the explicit and fallback cases render distinguishably.

#### Required configuration keys and defaults:

- `jest.config.cjs` gains `"./src/lib/pr-context/diff-emptiness.ts": { lines: 85, branches: 75 }`, matching every other entry in the map. There is no `global` key and there are no glob entries, so a new production file without its own entry is completely ungated.
- No new runtime configuration key, environment variable, or dependency.

#### Backward-compatibility expectations:

- Every existing caller continues to work unchanged, because `target_ref` is optional and no existing caller passes it.
- The only behavioural change an existing caller can observe on a populated diff is the added `Head ref (source):` line in the summary text and the added provenance fields on the result.
- On an empty diff, an existing caller that previously received `ok: true` now receives `ok: false`. That is the defect being fixed, and it is the only intentional breaking behaviour change.
- The two existing declaration surfaces are not currently equal in full — `mcp-tool-definitions.ts` carries `enum` constraints on `run_codex_native_converter` that the repo-automation surface omits — so the new parity test is scoped to `properties` key sets and `required` arrays rather than deep equality, which would fail on day one.

#### Performance constraints (latency/throughput/memory):

No new git or `gh` invocation is introduced. The classifier is a pure function over values already present on the collected record. The added summary line is a single string. No measurable latency or memory change is expected, and no performance budget is asserted.

## Assumptions, Constraints, Dependencies

### Assumptions (environment, data, access)

- All worktrees of the repository share one object store and one ref namespace, so `git rev-parse --verify` and `git merge-base` resolve a sibling worktree's branch from any worktree. This is the assumption that makes a ref-valued parameter sufficient (Decision 2).
- Work is performed in the worktree `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a41d019edfae43cb3` on the epic integration branch.
- `npm ci` is run in `extensions/drm-copilot/` before any toolchain stage. `node_modules` was absent in the fresh worktree.
- Tests are run through `node run-jest.cjs`, not `npx jest`.
- `npm run format` is `prettier --write` and mutates files; the non-mutating gate is `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`. A bare `npx prettier --check .` would additionally scan `node_modules`, `out/`, and `coverage/` and is not the repository's scope.

### Constraints (budget, performance, compatibility)

- **Coverage:** line >= 85% and branch >= 75%, uniform across tiers per `.claude/rules/quality-tiers.md`. TypeScript coverage tooling measures branches, so both gates apply. `jest.config.cjs` has no `global` key; every gate is per-file, so a new or newly-in-scope production file requires its own entry.
- **Coverage Exclusion Policy:** no production file under `src/` may be added to a coverage exclude list, however host-bound. The correct response to an untestable line is to extract the logic into a testable module, not to exclude the file. `jest.config.cjs` has no `coveragePathIgnorePatterns` key today and must not gain one; the only negation in `collectCoverageFrom` is `!src/**/*.d.ts`, which is permitted.
- **File size:** no production, test, or reusable script file may exceed 500 lines. Three source files and one test file are already within 20 lines of the cap (see **Files/modules to change** and **Test Strategy**).
- **Untyped escape hatches:** `quality-tiers.yml` does not exist at the repository root, so no project in this repository carries a recorded tier classification. This surface is adapter code — glue around the `git` and `gh` command-line tools that the team does not own — which is **T3** by the definitions in `.claude/rules/quality-tiers.md`, giving a nominal budget of `<= 5` justified `any` per file. **This feature adopts the stricter budget of 0.** The rationale is evidence-based rather than aspirational: the ESLint configuration mandates `typescript-eslint` strict-type-checked with all `no-unsafe-*` rules at error level, and the measured baseline `npx eslint --no-error-on-unmatched-pattern src test` exits 0, so the current edit set carries no `any` that a new one could be compared against. Introducing one would be a new class of finding in these files, not a continuation of an existing allowance. `unknown` plus narrowing, and discriminated unions for the classifier's states, are the required alternatives.
- **Determinism:** no `setTimeout`, no `Date.now()` outside the injected clock, no temporary files, no real subprocesses in tests. The existing suites already use injected `CommandRunner`/`FileSystem` seams and a `FIXED_CLOCK` where time matters. Nothing in this feature requires fake timers.
- **Mandatory toolchain loop:** format → lint → type-check → test, restarting from the first stage whenever any stage fails or auto-fixes a file.
- The change is inert at the live MCP tool until the extension is rebuilt and reinstalled (F7), so no acceptance criterion may call the live tool.

### External dependencies (services, libraries, releases)

- No new runtime or development dependency is added.
- `git` and `gh` remain invoked through the injected `CommandRunner`; `gh` unavailability remains a graceful degradation, not a failure.
- Downstream consumers — the published npm MCP server and the TaskMaster push-down — are F7's responsibility.

## Data / API / Config Impact

- **User-facing or API changes:** one optional input (`target_ref`) on the `collect_pr_context` MCP tool, declared on both definition surfaces; three optional output fields (`target_resolution`, `resolved_head_ref`, `resolved_head_sha`); one new line in the summary artifact's `Base/Head` block; and one new failure mode where an empty diff previously returned `ok: true`.
- **Data or migration considerations:** none. No persisted schema, no stored state, no migration. The two artifact files keep their paths, their append/overwrite semantics, and their existing sections.
- **Logging/telemetry updates (if any):** none beyond the error messages themselves. The two `Wrote context ...` log lines through the injected sink are unchanged. No telemetry exists on this path and none is added.
- **Compatibility notes (CLI flags, config schemas, versioning):** the schema change is additive and `required` is unchanged, so no existing caller becomes invalid. `additionalProperties: false` means the parameter must land on **both** definition surfaces or a caller that passes it will be rejected by whichever surface lacks it — this is the drift hazard the new parity test closes. The `jest.config.cjs` threshold map gains one entry. No version bump is performed here; publishing is F7's scope.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: table-driven Jest tests over the cross product of invoking-session worktree versus explicit target, and diff-present versus diff-empty. Existing suites to extend live under `extensions/drm-copilot/test/`, specifically `test/lib/pr-context/pr-context-service-call.test.ts`, `test/extension.collect-pr-context.test.ts`, and `test/repo-automation-dispatch-pr-context-verification.test.ts`.
- [x] Integration scenario to retest: a collection whose explicit target differs from the invoking session's worktree must describe the target.
- [x] Manual verification notes: the MCP surface resolves its resources from the installed VS Code extension, so the change is inert at the live tool until the extension is rebuilt and reinstalled. That rebuild is epic feature F7 and is out of scope here. Verification must assert against the Jest suite and the source, not against the installed tool.

Open design decision carried from the issue — **now settled.** The explicit target is optional with a fallback, and the fallback is mandatorily recorded in both the returned record and the summary artifact. See Decision 1 and Decision 3 under **Proposed Fix**.

### Framework

Jest, run through `node run-jest.cjs`. The seeded template checklist named pytest; that was a template artifact and has been replaced. **This feature is TypeScript and there is no Python in scope.** Tests live under `extensions/drm-copilot/test/`, mirroring the production tree; this extension has no top-level `tests/` directory.

### Table-driven cross-product suite (the core of the test matrix)

New file `test/lib/pr-context/pr-context-service-call-target.test.ts`. A sibling file rather than an extension of `pr-context-service-call.test.ts`, matching the existing split precedent (`collector-output-freshness.test.ts` split from `collector-output.test.ts`) and keeping both files clear of the 500-line cap.

Rows over `{ target: explicit | absent } × { diff: populated | empty-with-refs-resolved | empty-with-refs-unresolved }`. Per row the suite asserts: the argv the injected runner actually received, the `target_resolution` value, whether the call raised, and the error text when it raised.

Driven by the established seams — a local `CommandRunner` fake dispatching on the joined subcommand prefix, and `TreeFileSystem` seeded with a `/workspace/.git` marker so `GitClient.resolveRoot()` short-circuits. Argv capture extends the technique already used in `test/repo-automation-dispatch.test.ts`, which captures `options?.cwd`.

Required tests (names are normative, because acceptance criteria cite them):

- `passes the explicit target ref to git rather than the session HEAD`
- `reports target_resolution explicit and the resolved head ref and sha when a target ref is supplied`
- `reports target_resolution session-fallback when no target ref is supplied`
- `raises naming the resolved head ref, head sha, merge base and base when the refs resolve and no file changed`
- `raises naming the requested base when the base or head could not be resolved`
- `writes both artifacts and then raises when the diff is empty`

### Pure-classifier unit tests

New file `test/lib/pr-context/diff-emptiness.test.ts`, testing `classifyPrContextDiffState` directly over its input record. Covers all four mechanisms from **Root Cause Analysis**, including the `mergeBase === headSha` boundary and the populated case. This is where the classifier's branch coverage is earned; the service-call suite needs only one row per outcome.

### Input-validation tests

Added to the existing `test/mcp-tool-inputs.test.ts`:

- `resolves target_ref when supplied and omits it when absent`
- `rejects an empty target_ref instead of treating it as absent` — covers `""`, whitespace-only, and a non-string value.

### Schema-parity test

Added to the existing `test/mcp-repo-automation-tool-definitions.test.ts`:

- `declares the same input-schema properties and required arrays on both tool-definition surfaces`

The assertion iterates the tool names present in both arrays and compares dynamically derived `properties` key sets and `required` arrays. It must not hard-code a property list, or it would not catch the next parameter's drift. Scope is deliberately limited to those two aspects: a blanket deep equality fails today on `run_codex_native_converter`'s `enum` fields.

### Summary-rendering tests

New file `test/lib/pr-context/collector-output-head-source.test.ts` (a sibling, because `collector-output.test.ts` is 485 lines and effectively full):

- `renders Head ref (source) naming the explicit target in the Base/Head block`
- `renders Head ref (source) naming the session fallback in the Base/Head block`

Both assert the line's position relative to `Head ref (resolved):`, not merely its presence.

### Dispatch-boundary tests

Added to the existing `test/repo-automation-dispatch-pr-context-verification.test.ts`, matching that file's existing `ok: false` precedent:

- `returns ok false with the empty-diff failure text when the collected diff is empty`
- `projects target_resolution and the resolved head onto the dispatch result`

### Regression tests to add or update

- **Update, do not delete, every existing test that currently runs against an empty diff.** The five affected files are listed in **Scope & Non-Goals** item 7. Each gains a scripted non-empty diff — `M\t<path>` for `diff --name-status` and `1\t0\t<path>` for `diff --numstat`, following the pattern already used in `collector-core.test.ts` and `collector-integration.test.ts` — so it continues to assert what it was written to assert. Deleting any of them would silently drop coverage of the path-identity and freshness guarantees added by issue #574.
- Per the epic's "Currently-passing cases are included as regression guards, not omitted as redundant", the following existing behaviours must still be asserted and still pass: the `gh`-unavailable degradation still succeeds; the artifact read-back verification still raises on a discarded write and on a stale file; `writtenPaths` still equals `result.artifacts`; the returned `summary` string still names the base; `workspace_root` is still required at the MCP boundary.
- `test/lib/pr-context/collector-output.test.ts` and `collector-output-freshness.test.ts` build `CollectedPrContext` records directly and bypass the collector, so they are unaffected by the guard regardless of its placement. `collector-core.test.ts` and `collector-integration.test.ts` already script non-empty diffs and are likewise unaffected.

### Edge cases and negative scenarios (invalid inputs, missing data, boundary values)

| Case | Expected |
| --- | --- |
| `target_ref` absent | session fallback; `target_resolution: "session-fallback"`; recorded in both the record and the summary |
| `target_ref` empty or whitespace-only | rejected at input resolution with an error naming `target_ref` |
| `target_ref` not a string | rejected at input resolution |
| `target_ref` names a ref that does not exist | refs-unresolved failure, naming the base and the attempted head |
| `target_ref` equal to `base` | empty-diff failure (`mergeBase === headSha`) |
| Detached HEAD on the fallback path | unchanged behaviour; `branchName()` returns `HEAD` and `revParse("HEAD")` still resolves; the fallback record makes it visible |
| Explicit target with a populated diff | success; the context describes the target, not the session |
| Explicit target differing from the session worktree | the argv assertion proves the target's ref reached `git merge-base`, and the session branch name did not |
| `gh` unavailable | unchanged graceful degradation; still a success |
| Write accepted and content discarded | unchanged read-back verification failure, raised before any diff classification |

### Error handling and logging verification

Each of the two new failure messages is asserted by content, not merely by the fact that an error was thrown: the refs-unresolved message names the requested base, and the empty-diff message names the resolved head ref, head SHA, merge base, and resolved base. The two messages are asserted to be distinguishable from each other and from the existing read-back-verification message. Ordering is asserted: a discarded write is reported as a verification failure, not as an empty diff.

### Coverage impact and targets for changed lines/modules

- Every changed file must meet line >= 85% and branch >= 75%.
- `jest.config.cjs` gains `"./src/lib/pr-context/diff-emptiness.ts": { lines: 85, branches: 75 }`. Without it the new module is completely ungated, because the map has no `global` key and no glob entries.
- `git-client.ts`, `render.ts`, `models.ts`, and `collect-context-handlers.ts` are currently ungated. None is expected to change; if any does, it gains a threshold entry in the same change, following the precedent by which issue #574 added the four existing pr-context entries.
- `repo-automation-service-contract.ts` remains interface-only and remains deliberately omitted from the threshold map for the reason already documented in `jest.config.cjs`; it stays inside `collectCoverageFrom`, i.e. measured but not gated.
- No file is added to any exclusion list.

### Toolchain commands to run (format → lint → type-check → test)

Run from `extensions/drm-copilot/`, after `npm ci`:

1. `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
2. `npx eslint --no-error-on-unmatched-pattern src test`
3. `npx tsc -p ./ --noEmit`
4. `node run-jest.cjs --coverage --coverageReporters=text-summary`

Restart from step 1 if any stage fails or modifies a file.

For iteration only, a scoped run is `node run-jest.cjs --coverage --coverageReporters=text-summary test/lib/pr-context test/repo-automation-dispatch-pr-context-verification.test.ts test/extension.collect-pr-context.test.ts`. A scoped run still evaluates the whole per-file threshold map against `collectCoverageFrom: ["src/**/*.ts"]`, so it reports threshold failures for unrelated files it did not exercise. The full-suite run is the authoritative result.

### Baseline (measured 2026-09-13T21:10, after `npm ci`)

| Stage | Command | Result |
| --- | --- | --- |
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | exit 0 |
| Lint | `npx eslint --no-error-on-unmatched-pattern src test` | exit 0 |
| Type check | `npx tsc -p ./ --noEmit` | exit 0 |
| Tests | `node run-jest.cjs --coverage --coverageReporters=text-summary` | exit 0; all suites and tests passed |

Headline coverage at baseline: Statements 96.88%, Branches 90.47%, Functions 90.55%, Lines 96.88%.

Baseline and subsequent evidence artifacts are written to `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/baseline/` — **singular `baseline`**, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. The research record writes `evidence/baselines/` in one place; that spelling is incorrect and must not be propagated. `artifacts/baselines/`, `artifacts/qa/`, and `artifacts/coverage/` are non-canonical and are rejected by the evidence-location hook.

### Manual validation steps (if required)

None. The research record's automation-feasibility assessment concludes that every verification this feature needs runs unattended: the behaviour is observable through constructor-injected `CommandRunner` and `FileSystem` seams, the tool definitions are plain exported arrays importable in Jest without any host, and the four toolchain stages are exit-code-asserted commands.

The one thing this feature cannot verify is the live MCP surface, and that is explicitly out of scope. MCP tools resolve their resources from the installed VS Code extension, so a live call measures the old build and would produce a false pass or a false fail with equal likelihood. That rebuild is F7. Every acceptance criterion below asserts against the Jest suite or against the source.


## Acceptance Criteria

Every criterion below is verified from `extensions/drm-copilot/` after `npm ci`, against the Jest suite or the source. No criterion calls the live `mcp__drm-copilot__collect_pr_context` tool, which resolves its resources from the installed extension and would measure the old build.

**Diff anchor.** Where a criterion cites a `git diff`, the diff is anchored to the fixed commit `499e288a` ("docs(epic): add worktree-scoped-state-resolution epic manifest"), which is the epic-integration base commit this feature branch was created from and this branch's merge base with `origin/epic/worktree-scoped-state-resolution-integration`. It is a fixed ancestor of this branch and stays a valid anchor across a later rebase. The two-dot form against the worktree is used, so the diff compares the anchor commit against the current working tree. `main` is deliberately not used: this branch was created from the epic integration branch, not from `main`, so a `main`-anchored diff sweeps in the epic-manifest commit `499e288a`, which is not this feature's change; and `main` is a moving ref, so a diff anchored to it is not reproducible between two runs of the same criterion.

**Tracked-versus-untracked coverage.** `git diff` and `git diff --name-only` enumerate tracked changes only. Nothing is committed during plan execution, so every file this feature creates — `extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts` and the new test files under `extensions/drm-copilot/test/lib/pr-context/` — is untracked and never appears in an anchored diff. Every criterion that derives a file set from a diff, or greps changed content, therefore pairs the anchored diff with a `git status --porcelain` companion and asserts over the union of the two results. The two mechanisms are complementary and each alone is wrong in one state: the anchored diff is blind to untracked files, and porcelain status reports nothing once the change is committed. A criterion whose target observation is a deletion or a removed line in a pre-existing tracked file needs the anchor correction but no porcelain companion, because that observation is visible to the anchored diff and an untracked file cannot hold a pre-existing test; the one criterion in that category says so explicitly.

**Grep mechanism.** Where a criterion inspects a file this change creates, it uses plain `grep` against the path. `git grep` is not used by any criterion below, because `git grep` does not see untracked files at all and therefore cannot observe a file this feature creates.

**Schema and input resolution**

- [x] Both `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` declare a `target_ref` string property on the `collect_pr_context` input schema, and the `required` array for that tool is unchanged in both files. Verify: `grep -c "target_ref" extensions/drm-copilot/src/mcp-tool-definitions.ts` and the same command against `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` each report at least 1, and `grep -n "workspace_root" extensions/drm-copilot/src/mcp-tool-definitions.ts` still shows `required` listing only `workspace_root` and `base` for that tool.
- [x] The test `declares the same input-schema properties and required arrays on both tool-definition surfaces` exists in `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` and passes. Its assertion derives the compared property key sets from the definition objects rather than hard-coding a property list, so it fails if a future parameter is added to only one surface.
- [x] The test `resolves target_ref when supplied and omits it when absent` exists in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` and passes.
- [x] The test `rejects an empty target_ref instead of treating it as absent` exists in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` and passes, covering an empty string, a whitespace-only string, and a non-string value, and asserting that the raised error names `target_ref`.

**Explicit target reaches git**

- [ ] The test `passes the explicit target ref to git rather than the session HEAD` exists in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` and passes. It captures the argv the injected `CommandRunner` received and asserts both that the supplied target ref appears in the ref-resolution and merge-base argv and that the scripted session branch name does not.
- [ ] The test `reports target_resolution explicit and the resolved head ref and sha when a target ref is supplied` exists in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` and passes.

**Fallback is observable, not silent**

- [ ] The test `reports target_resolution session-fallback when no target ref is supplied` exists in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` and passes, asserting the discriminant value and the presence of the resolved head ref and head SHA on the returned record.
- [ ] The tests `renders Head ref (source) naming the explicit target in the Base/Head block` and `renders Head ref (source) naming the session fallback in the Base/Head block` exist in `extensions/drm-copilot/test/lib/pr-context/collector-output-head-source.test.ts` and pass. Each asserts that the rendered line begins with the literal `Head ref (source):`, that it appears after the `Head ref (resolved):` line, and that the two cases render distinguishable text.
- [ ] The test `projects target_resolution and the resolved head onto the dispatch result` exists in `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` and passes, asserting the three snake_case fields on the result returned by `dispatchRepoAutomationTool`.

**Empty diff fails loudly**

- [ ] The file `extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts` exists and exports the pure classifier. Verify: `grep -c "export function classifyPrContextDiffState" extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts` reports 1.
- [ ] `extensions/drm-copilot/test/lib/pr-context/diff-emptiness.test.ts` exists and passes, with at least one test for each of: refs unresolved; refs resolved with the merge base equal to the head SHA and no changed file; refs resolved and unequal with no changed file; refs resolved with at least one changed file.
- [ ] The test `raises naming the resolved head ref, head sha, merge base and base when the refs resolve and no file changed` exists in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` and passes, asserting that the error message contains all four of those values.
- [ ] The test `raises naming the requested base when the base or head could not be resolved` exists in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` and passes, and asserts that its message text differs from the empty-diff message text.
- [ ] The test `writes both artifacts and then raises when the diff is empty` exists in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts` and passes, asserting that the injected filesystem's `writtenPaths` contains both artifact paths after the raise.
- [ ] The test `returns ok false with the empty-diff failure text when the collected diff is empty` exists in `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` and passes.

**No regression**

- [ ] No existing test is deleted from the five suites that currently run against an empty diff. Verify: `git diff 499e288a -- extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts extensions/drm-copilot/test/extension.collect-pr-context.test.ts extensions/drm-copilot/test/extension.integration.test.ts extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts extensions/drm-copilot/test/repo-automation-dispatch.test.ts` produces no removed line matching `it(`, and the same command produces no `deleted file mode` line for any of the five paths. No `git status --porcelain` companion is required here, and that reasoning holds: all five files are tracked at `499e288a`, so a removed line or a whole-file deletion is visible to the anchored diff, and an untracked file cannot contain a pre-existing test that this criterion protects.
- [ ] The pre-existing tests `writes exactly the paths it reports in result.artifacts`, `writes both artifacts and succeeds when the GitHub CLI is unavailable`, `raises when a stale file is present and the write is discarded`, and `raises naming the appendix when the summary write succeeds and the appendix write fails` in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` all still pass.
- [ ] The pre-existing tests `reports ok false with the failure text when the service call raises` and `reports ok true with artifacts equal to the paths written in the same run` in `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` both still pass.
- [ ] No file under `.claude/` and no file under `extensions/drm-copilot/resources/` is modified, added, or deleted by this change, matching the Decision 7 deferral. Verify both commands produce no output: `git diff --name-only 499e288a -- .claude extensions/drm-copilot/resources` (tracked modifications and deletions) and `git status --porcelain -- .claude extensions/drm-copilot/resources` (untracked additions). The porcelain companion is required because the anchored diff enumerates tracked changes only and would not report a newly added, still-uncommitted file under either tree.

**Policy gates**

- [ ] `extensions/drm-copilot/jest.config.cjs` contains a `coverageThreshold` entry for `./src/lib/pr-context/diff-emptiness.ts` with `lines: 85` and `branches: 75`, and contains an entry for every other production file in this change's source set that is not interface-or-type-only. Verify: `grep -c "diff-emptiness" extensions/drm-copilot/jest.config.cjs` reports at least 1; then derive the source set as the union of the paths reported by `git diff --name-only 499e288a -- extensions/drm-copilot/src` (tracked modifications and additions) and the paths reported by `git status --porcelain -- extensions/drm-copilot/src` (which includes untracked additions, marked `??`); and check every path in that union against the `coverageThreshold` map. The union is required because `extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts` is created by this change, is untracked until commit, and therefore never appears in the anchored diff.
- [ ] `extensions/drm-copilot/jest.config.cjs` still has no `coveragePathIgnorePatterns` key and no exclusion of any production path under `src/`. Verify: `grep -c "coveragePathIgnorePatterns" extensions/drm-copilot/jest.config.cjs` reports 0, and `collectCoverageFrom` still contains exactly `src/**/*.ts` and `!src/**/*.d.ts`.
- [ ] No non-Markdown file added or modified by this change exceeds 500 lines. Verify: derive the change set as the union of the paths reported by `git diff --name-only 499e288a` (tracked modifications and additions) and the paths reported by `git status --porcelain` (which includes untracked additions, marked `??`); run a line count over every non-Markdown path in that union and confirm no path exceeds 500 lines. Markdown documentation is exempt from the cap. Check `extensions/drm-copilot/src/repo-automation-service.ts` and `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` explicitly because each had fewer than 20 lines of headroom before the change, and check `extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts`, `extensions/drm-copilot/test/lib/pr-context/diff-emptiness.test.ts`, `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts`, and `extensions/drm-copilot/test/lib/pr-context/collector-output-head-source.test.ts` explicitly because this change creates them and the anchored diff cannot report them until they are committed.
- [ ] No `any` type annotation and no `as any` assertion is introduced under `extensions/drm-copilot/src`. Verify both mechanisms, because neither alone covers both states. Tracked modifications: `git diff 499e288a -- extensions/drm-copilot/src` contains no added line matching `: any` and no added line matching `as any`. Created files: `grep -nE ": any|as any" extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts` reports no match, and the same `grep -nE ": any|as any"` reports no match for every additional untracked path listed by `git status --porcelain -- extensions/drm-copilot/src`. The direct grep is required because a file this change creates is untracked during execution and its content is invisible to the anchored diff; the anchored diff is required because it is the only mechanism that sees modifications to files that already existed at `499e288a`.
- [ ] No banned determinism construct is introduced under `extensions/drm-copilot/src` or `extensions/drm-copilot/test`. Verify both mechanisms. Tracked modifications: `git diff 499e288a -- extensions/drm-copilot/src extensions/drm-copilot/test` contains no added line matching `setTimeout`, `Date.now(`, `mkdtemp`, or `tmpdir`. Created files: `grep -nE "setTimeout|Date\.now\(|mkdtemp|tmpdir" extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts extensions/drm-copilot/test/lib/pr-context/diff-emptiness.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts extensions/drm-copilot/test/lib/pr-context/collector-output-head-source.test.ts` reports no match, and the same pattern reports no match for every additional untracked path listed by `git status --porcelain -- extensions/drm-copilot/src extensions/drm-copilot/test`. The direct grep is required because these four files are created by this change and are untracked during execution.
- [ ] The full toolchain passes in a single pass from `extensions/drm-copilot/` after `npm ci`: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exits 0; `npx eslint --no-error-on-unmatched-pattern src test` exits 0; `npx tsc -p ./ --noEmit` exits 0; `node run-jest.cjs --coverage --coverageReporters=text-summary` exits 0 with zero failed suites and zero failed tests.
- [ ] The toolchain evidence for the run above is written under `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/`, using the singular `baseline` sub-path for the pre-change capture, and no evidence file is written to `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/`.

**Documented limitation**

- [ ] The doc comment of `extensions/drm-copilot/src/lib/pr-context/diff-emptiness.ts` records that the guard cannot detect a wrong target whose branch has commits ahead of the base, and that the working-tree sections and the current-PR lookup remain scoped to `workspace_root` even when `target_ref` is supplied. Verified by inspection of the file.

## Risks & Mitigations

### Technical or operational risks

| # | Risk | Likelihood / impact | Mitigation |
| --- | --- | --- | --- |
| R1 | The existing-test update is larger than the issue text implies. The research record identifies roughly twenty tests across five files that currently compute an empty diff and will all fail when the guard lands. | High likelihood, medium impact — it is schedule cost, not correctness risk. | Scoped explicitly in **Scope & Non-Goals** item 7 and in the test strategy. Each test is updated to script a non-empty diff using the pattern already established in `collector-core.test.ts`. An acceptance criterion asserts that none is deleted. |
| R2 | `src/repo-automation-service.ts` has 2 lines of headroom and must forward a new field, so the change cannot land in place. | High likelihood, low impact. | Extraction is planned rather than discovered: the input type moves to `repo-automation-service-contract.ts`. An acceptance criterion checks the file's line count explicitly. |
| R3 | A new production file lands completely ungated, because `jest.config.cjs` has no `global` threshold key and no glob entries. | High likelihood if unaddressed, high impact — the coverage gate would report green while measuring nothing for the new module. | The threshold entry is an explicit acceptance criterion naming the file path. |
| R4 | The `target_ref` parameter is added to one definition surface and not the other. Today's suite would not catch it, and `additionalProperties: false` would make a caller that passes it fail against whichever surface lacks it. | Medium likelihood, high impact. | The new cross-surface parity test, scoped to `properties` key sets and `required` arrays. |
| R5 | The optional parameter is read as permission for a silent fallback, reintroducing the defect. | Low likelihood, high impact. | The fallback is recorded in two places (Decision 3), an empty `target_ref` is rejected rather than treated as absent (Decision 6), and the empty-diff guard fails loudly regardless of how the head was resolved. |
| R6 | The fix appears not to work when exercised through the live MCP tool, because the installed extension still carries the old build. | High likelihood if attempted, high impact — it would produce a false fail or, worse, a false pass. | No acceptance criterion calls the live tool. The constraint is recorded in **Scope & Non-Goals**, in the test strategy, and in the acceptance-criteria preamble. |
| R7 | The empty-diff guard is mistaken for a complete fix for the wrong-worktree defect. It does not detect a wrong target whose branch has commits ahead of the base. | Medium likelihood, medium impact. | Stated in **Root Cause Analysis**, in **Scope & Non-Goals**, and required in the new module's doc comment by an acceptance criterion. |
| R8 | `collector-output.ts` (15 lines of headroom) overruns the 500-line cap while gaining the summary line and the widened return value. | Medium likelihood, low impact. | The line renderer is placed in `summary-helpers.ts` (111 lines of headroom, already gated) rather than in `collector-output.ts`, and the file's line count is an acceptance criterion. |

### Mitigations and rollbacks

- Rollback is a revert of the feature branch. Because `target_ref` is optional and no in-repo prompt is updated (Decision 7), a revert leaves no caller broken and no documentation describing a capability that no longer exists.
- There is no feature flag and no partial-enablement path for the empty-diff guard. An opt-out would reintroduce the silent-success mode this feature exists to eliminate.
- If the guard proves too aggressive in practice — for example if a legitimate no-op branch must be describable — the correct response is a follow-up that adds an explicit caller-supplied acknowledgement, not a relaxation of the default.

## Rollout & Follow-up

### Release/rollout steps

1. Land this feature on the epic integration branch `epic/worktree-scoped-state-resolution-integration`. The change is inert at the live tool at this point, by design.
2. Epic feature F7 (`taskmaster-push-down-and-resume`) rebuilds and reinstalls the VS Code extension, which is what makes the new schema and the guard live. F7's first verification action is a grep for changed content under the **installed** extension's payload; if it finds the old content, the push-down verified nothing.
3. F7 also owns the deferred `.claude/**` prose documenting `target_ref`, together with the paired `extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror edits that the epic's bundled-payload rule then makes mandatory.

### Post-fix monitoring or clean-up tasks

- After F7 ships and every in-repo prompt passes `target_ref`, assess whether the parameter can be tightened to required. Decision 1 defers that assessment deliberately; it is recoverable, whereas a broken consumer is not.
- Watch for `target_resolution: "session-fallback"` on calls made from a coordinating session. That value on such a call is the field signature of this defect, and it is now visible in the result record rather than only inferable from a zero-line diff.
- The research record notes that no cross-surface tool-definition parity test existed for any tool before this change. Once the generic parity test lands, consider whether the `run_codex_native_converter` `enum` divergence between the two surfaces is intentional; it is out of scope here and the parity test is deliberately scoped not to fail on it.

### Links: issue, PRs, related docs

- Issue: https://github.com/drmoisan/drm-copilot/issues/675
- Issue record: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/issue.md`
- Research record: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/research/2026-09-13T21-30-collect-pr-context-explicit-target-research.md`
- Parent epic: `docs/features/epics/worktree-scoped-state-resolution/epic.md` (feature F6, wave 0, scope row 3.5)
- Policy: `.claude/rules/typescript.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`
- Evidence conventions: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- PRs: to be recorded on delivery.
