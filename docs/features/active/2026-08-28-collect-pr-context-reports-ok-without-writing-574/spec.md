# 2026-08-28-collect-pr-context-reports-ok-without-writing (Spec)

- **Issue:** #574
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-28T14-05
- **Status:** Approved
- **Version:** 1.1

## Context
The `collect_pr_context` MCP tool can report `ok: true` without writing its context artifacts, and because earlier artifacts persist at the same paths, a stale file satisfies any existence check. Consumers (pr-author, review workflows) can then build a PR body or review from a previous invocation's context without any error surfacing.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (MCP server tool)
- Command/flags used: `mcp__drm-copilot__collect_pr_context` invoked by orchestrator/pr-author flows
- Data source or fixture: observed repeatedly during the parallel run `critical-bug-fixes` (completed 2026-08-26); recorded in that run's checkpoint receipts

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A PR body or review generated from stale context misdescribes the diff it accompanies. The failure is silent and survives existence checks, so it propagates into outward-facing artifacts.

Restatement after research (see `research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md`, Section 10): the issue text describes the tool as "failing to write". That framing is imprecise. Both files are written on every invocation; they are written into the wrong checkout. The reported `ok: true` was truthful about the write and false about the location. Every symptom the reporter recorded — success reported, stale content at the named path, existence checks passing, content not matching the branch under review — follows from misdirection. No separate skipped-write mechanism exists in the code and none was found.


## Repro & Evidence
Steps to Reproduce:
1. Invoke `collect_pr_context` once successfully; context artifacts are written.
2. Invoke it again under a condition where it fails to write (observed during the run; exact trigger not isolated — candidates include a base-branch resolution failure or a silent internal error).
3. The tool returns `ok: true`; the artifact paths still hold the previous invocation's content; downstream existence checks pass.

Expected:
`ok: true` if and only if the context artifacts for THIS invocation were written. Any failure to write returns an error. Additionally, artifacts should be verifiable as fresh (for example, an embedded invocation timestamp or head SHA the consumer can cross-check), so a stale file cannot masquerade as current.

Actual:
`ok: true` was returned with no write performed. The stale prior artifact satisfied the existence check, so the failure was only detected when content did not match the branch under review. This recurred across multiple items in the run and was worked around by consumers re-verifying artifact content against `git log`/`gh pr view` before use.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: recorded in `artifacts/orchestration/parallel-orchestrator-state.json` receipts of the critical-bug-fixes run (infrastructure-findings notes).

Corroborating disk evidence (research Section 1.5, read-derived): the main checkout is on `main`, yet its `artifacts/` directory holds a PR-context pair describing the branch `bug/promotion-lifecycle-loses-promoted-record-487`, which lives in a different worktree. A run whose git operations resolved against one checkout wrote its output files into another. That is the split the code path predicts.

Evidence class: the research session had no shell tool, so no command was executed and no exit code is recorded anywhere in the research artifact. Every finding it carries is either read directly out of a file (labelled VERIFIED, with path and line) or an explicit inference from those reads (labelled INFERRED). This spec does not re-derive those findings and does not treat any of them as command-verified.


## Scope & Non-Goals

- In scope:
  - **R1 — single-source path resolution at the service-call seam.** Compute each absolute output path once in `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` and use that one value for both the write and the reported `artifacts` entry, so the reported set and the written set cannot drift apart. This is the shape already used by the sibling caller `runCollectCommitContext`.
  - **R2 — read-back verification.** After both writes, read each file back through the injected `FileSystem` and fail when the content is not what this invocation rendered. Read-back, not an existence check: an existence check is satisfied by a stale file and is the exact hazard under repair.
  - **Freshness marker.** One shared `Context generated` section rendered first in both the summary and the appendix, carrying the generation timestamp and the head SHA, with the identical timestamp string in both files. Mirrored in the Python surface so the declared verbatim-port relationship holds.
  - **Coverage configuration.** Per-file Jest `coverageThreshold` entries for the touched pr-context modules in `extensions/drm-copilot/jest.config.cjs`.
  - **Consumer documentation.** The two-step cross-check (pair identity by timestamp, head binding by SHA) documented in all six `pr-context-artifacts` SKILL.md copies. Push-down byte-parity for the `.claude` and `.agents` copies is test-enforced.
  - **One narrow cross-runtime parity assertion over the freshness-header literals** (decision recorded below).

- Decision on research open question O2 (cross-runtime parity test): **in scope, in one narrow form only.**
  Research Section 1.9 records that no automated Python/TypeScript parity test exists for the pr-context surface; the verbatim-port relationship is prose-declared and enforced by review alone, and that is what allowed a divergence class to survive undetected. This bug fix makes a *text-shape* change in both runtimes simultaneously — precisely the change class that a prose-only obligation fails to protect. Adding a general pr-context parity harness would be a separate feature and is not undertaken. Adding one assertion confined to the two literals this fix introduces is cheap, has an established in-repo precedent (`tests/scripts/dev_tools/test_plan_gate_parity.py` reads TypeScript module source from pytest and asserts on literals it contains, per `.claude/rules/plan-acceptance-gates.md`), spawns no process, and creates no new machinery. The assertion compares the generated-context section title literal and the head-SHA label literal used by `scripts/dev_tools/pr_context/summary_helpers.py` against the same literals read from `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts`. A broader output-level parity harness is recorded as a follow-up, not built here.

- Out of scope / non-goals (each recorded as a named follow-up in Rollout & Follow-up):
  - **Research O5 / D1 — surfacing the `render.ts` catch-all degraded-artifact path through the MCP `warnings` array.** That is a distinct silent-success path in which the write succeeds and the content degrades. It is not the reported defect and is not specified here.
  - **Research O3 — the GitHub CLI being unavailable to the MCP server process.** A separate defect in the same tool, affecting reference classification and autoclose detection in every artifact that process produces.
  - **Research O4 — the absent `quality-tiers.yml` at repository root.** Pre-existing repository condition. Coverage obligations for this fix are unaffected because line and branch thresholds are uniform across T1 through T4.
  - **Research O1 — whether a Copilot `.github` push-down byte-parity test exists.** The `.github` skill copy is edited regardless; confirming or adding the parity test is not this fix's work.
  - **A general Python/TypeScript output-parity harness for pr-context** beyond the single literal assertion described above.
  - **Any change to `.claude/hooks/enforce-pr-author-skill.ps1` or `.claude/hooks/enforce-pr-author-skill-helpers.ps1`.** The hook resolves `artifacts/pr_context.summary.txt` against the session worktree cwd and begins working as intended once the artifacts land in that worktree. Extending it to enforce the head-SHA cross-check would require a git call at PreToolUse time and is a separate change.
  - **Write-to-temp-then-rename, or any other pair-atomicity mechanism.** Explicitly not claimed; see Behaviour Semantics item 4.
  - **Any change to the Python collector's output-path resolution.** The Python side is not at fault; see Root Cause Analysis.

- Explicitly excluded systems, integrations, or datasets:
  - The live `mcp__drm-copilot__collect_pr_context` tool as an acceptance surface. `.mcp.json` launches `npx -y @danmoisan/drm-copilot-mcp` with no version pin and no `cwd`, so a live call exercises the installed package, not this branch. Live verification is post-release evidence only.
  - The `.codex` runtime beyond the `.agents` skill copy already enumerated.
  - Branch-protection configuration, required checks, and release automation.

## Root Cause Analysis

**Confirmed mechanism.** The defect is in the MCP-facing caller, not in the ported collector library and not in the Python surface.

1. `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` defines the two outputs as repo-relative string constants at lines 29-32: `SUMMARY_OUT = "artifacts/pr_context.summary.txt"` and `APPENDIX_OUT = "artifacts/pr_context.appendix.txt"`.
2. Lines 71-81 pass those constants **unjoined** to `collectAndWrite` as `out` and `appendixOut`, while separately passing `repoRoot: input.workspaceRoot`.
3. Lines 87-90 build the returned `artifacts` array by **joining the same constants to `input.workspaceRoot`**. The function therefore evaluates the output location twice, by two different expressions, and reports the one it did not write to.
4. `writeOutput` in `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` (lines 320-336, called from lines 359-360) forwards the relative string verbatim to `fs.ensureDir` and `fs.writeTextFile`. There is no join against `repoRoot` anywhere on the write path; `repoRoot` is consumed only for git, gh, and discovery.
5. `RealFileSystem` (`extensions/drm-copilot/src/lib/file-system.ts`, lines 328-343) implements those two methods as bare `node:fs` `writeFileSync` and `mkdirSync`. Node resolves a relative path against `process.cwd()`.
6. The MCP server is a single long-running process shared across concurrent worktree-isolated agents, launched from `.mcp.json` as unpinned `npx` with no `cwd` key. There is no `process.chdir` anywhere on this path. Its cwd is whatever directory the client session started in, and it is unrelated to the per-call `workspace_root`.

The consequence is that `mkdirSync(..., { recursive: true })` followed by `writeFileSync` **succeeds**, creating an `artifacts/` directory under the server process's cwd. Nothing throws, so nothing is swallowed: `dispatchRepoAutomationTool` in `extensions/drm-copilot/src/mcp-tools.ts` does convert a thrown error into `ok: false`, and `ok: true` here is not an exception-swallowing artifact. There is no read-back, so a write that succeeds at the wrong location is indistinguishable from a write that succeeded at the right one.

**Two framing corrections carried from research Section 10.**

- **The write is misdirected, not skipped.** Both files are written on every invocation, into the wrong checkout. The issue's "fails to write" wording is imprecise and is restated in Context above. No skipped-write mechanism exists.
- **The Python collector is not at fault and needs no path change.** `scripts/dev_tools/pr_context/collector.py` line 206 is `summary_path = out`, identical in behaviour to the TypeScript library. The TypeScript library is a faithful port. Both runtimes implement the same coherent library contract: *write to the path you were given, resolved by the host against its own cwd.* That contract is correct for a CLI, whose cwd is the operator's cwd, which is why the documented workaround `python -m scripts.dev_tools.pr_context.collector --base main --repo-root .` works. The defect is that the TypeScript **caller** supplies a repo-relative constant into that cwd-relative contract from a long-lived server process, and reports a different path than it writes. The sibling caller `runCollectCommitContext` (`extensions/drm-copilot/src/repo-automation-service-support.ts`, lines 108-123) computes the absolute path once and uses the same variable for both the write and the reported artifact, which is why `collect_commit_context` does not exhibit the bug.

**Why the defect survived review.** Three committed tests assert the reported path and the written path as different strings within the same scenario, and pass:

- `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` lines 118-135 asserts the write key is the bare relative path and the reported artifact is the joined absolute path, in one test.
- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` lines 432-446 is titled for writing "against the workspace root" but asserts the recorded `node:fs` write keys contain no workspace root.
- `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` lines 91-112 asserts joined paths in `result.artifacts` and a relative key in the filesystem, under a comment that describes the relative key as being "relative to the workspace root".

The secondary contributor is the absence of a freshness marker linking a written pair to a single invocation and a single head. Without one, a consumer that finds a file at the expected path has no deterministic way to establish that the file describes the branch it is about to review. This is independent of the path defect and survives its repair, which is why it is fixed in the same change.

## Proposed Fix

### Design summary (what changes where):

Two coordinated corrections at the MCP wiring seam, plus one independent artifact-content addition mirrored across both runtimes.

- **R1** — `pr-context-service-call.ts` computes `summaryOut` and `appendixOut` once by joining the repo-relative constants to `input.workspaceRoot`, passes those absolute values to `collectAndWrite`, and returns `normalizeGeneratedPath` of the *same two variables* in `artifacts`. The divergence becomes structurally impossible rather than merely corrected: no second expression exists that could drift. The shape matches the existing `runCollectCommitContext` precedent, so the fix makes the two ports consistent rather than introducing a new pattern.
- **R2** — after `collectAndWrite` returns, `pr-context-service-call.ts` reads each file back through the injected `FileSystem` and raises when the content read back is not the content this invocation rendered. `collectAndWrite` is changed to return the two rendered strings (it currently returns `void`) so verification compares against the exact text rendered, single-pass. A raised error becomes `ok: false` at the dispatch boundary, delivering the issue's stated acceptance condition literally.
- **Freshness marker** — one shared section, reusing the existing `Context generated` title, rendered as the first section of both files, carrying the generation timestamp and the head SHA. The timestamp string is rendered once per invocation and passed to both builders, so a pair that disagrees is a detectable defect rather than a rounding artifact.

Rejected alternatives, with the reason each was rejected (research Section 2):

- **Join inside `writeOutput` or `collectAndWrite` against `options.repoRoot`.** Rejected: it moves the library contract away from Python `collector.py` line 206, breaking the verbatim-port relationship that currently has no test to protect it, and it would double-join the absolute paths already supplied by existing tests unless an absoluteness guard were added — added complexity in a shared module for no gain.
- **`process.chdir(workspaceRoot)` in the handler.** Rejected: the server is a single long-running process shared across concurrent worktree-isolated agents, so a process-global cwd mutation is a race between concurrent tool calls and would convert a deterministic misdirection into a nondeterministic one.
- **Make the collector reject a relative `out`.** Rejected as the mechanism: mirrored to Python it would break the CLI's correct and documented relative-path usage; applied only to TypeScript it introduces a divergence in order to fix a divergence. Acceptable as a defensive assertion inside the service call after R1, but not as the fix.

### Boundaries and invariants to preserve:

- `collectAndWrite`, `buildSummaryText`, `buildAppendixText`, and `writeOutput` remain faithful ports of their Python counterparts. No root-joining logic is introduced into any of them. The only permitted signature changes are the added clock parameter on `buildSummaryText`, the added head-SHA input on the timestamp helper, and `collectAndWrite` returning the rendered strings.
- The Python output-path contract is unchanged. `summary_path = out` stays as written.
- Write ordering is preserved: summary first, then appendix.
- The MCP tool result shape is unchanged. No new field, no schema change, no new tool input.
- Degradation paths stay degradation paths (see Behaviour Semantics item 5).
- The Python `append_generation_timestamp` takes no clock parameter while the TypeScript one does. This is a pre-existing, deliberate divergence justified by the TypeScript determinism rule in `.claude/rules/typescript.md`; the fix must not "correct" it in either direction.
- The 500-line file limit applies to every touched file.

### Dependencies or blocked work:

- None blocking. All inputs are in the repository.
- Release sequencing constraint, not a code constraint: a `resources/` edit changes what a future push-down writes, not what an already-installed extension writes, and the running MCP server resolves `@danmoisan/drm-copilot-mcp` through unpinned `npx`. The fix does not reach the live tool until the package is republished and the client re-resolves it. Until then the documented Python-CLI workaround remains the operative mitigation.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production — TypeScript (root cause):
1. `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` — R1 join, R2 read-back verification.

Production — TypeScript (freshness marker):
2. `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` — render the shared header first in both builders; thread the clock into `buildSummaryText`; render the timestamp once and pass the same string to both builders; return the rendered strings from `collectAndWrite`.
3. `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` — extend the generation-timestamp helper (or add a sibling) to accept the head SHA and emit the head-SHA line.

Production — Python (freshness-marker parity only; not the root cause):
4. `scripts/dev_tools/pr_context/collector.py` — render the header once and place it first in both `summary_sections` (currently beginning at line 452 with the GitHub CLI status section) and `appendix_parts` (line 543), passing the head SHA.
5. `scripts/dev_tools/pr_context/summary_helpers.py` — mirror the helper change at lines 379-386.

Configuration:
6. `extensions/drm-copilot/jest.config.cjs` — add per-file `coverageThreshold` entries for the three TypeScript production files above. The file's existing pattern, stated in its own comments for issues #305 and #525, is a per-changed-file entry of 85 line and 75 branch; it currently has no entry for any `src/lib/pr-context/` file.

Documentation — six copies, byte-identical within each self-hosted/bundled pair:
7. `.claude/skills/pr-context-artifacts/SKILL.md`
8. `.github/skills/pr-context-artifacts/SKILL.md`
9. `.agents/skills/pr-context-artifacts/SKILL.md`
10. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md`
11. `extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md`
12. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md`

Tests — TypeScript (each currently asserts the relative write path, the log-line text, or the summary shape):
13. `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`
14. `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
15. `extensions/drm-copilot/test/extension.integration.test.ts`
16. `extensions/drm-copilot/test/repo-automation-dispatch.test.ts`
17. `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts`
18. `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts`
19. `extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts`
20. `extensions/drm-copilot/test/mcp-server.test.ts`

Tests — Python (freshness-marker parity only; whether each is genuinely touched is settled at plan time by reading them, and they are enumerated so blast-radius derivation is not surprised):
21. `tests/scripts/dev_tools/test_pr_context_integration.py`
22. `tests/scripts/dev_tools/test_collect_pr_context.py`
23. `tests/scripts/dev_tools/test_collect_pr_context_part2.py`
24. `tests/scripts/dev_tools/test_collect_pr_context_part3.py`
25. `tests/scripts/dev_tools/test_collect_pr_context_part4.py`

Plus one new or extended Python test module carrying the narrow freshness-header parity assertion.

Explicitly not touched: `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, and the output-path resolution in `scripts/dev_tools/pr_context/collector.py`.

#### Functions/classes/CLI commands impacted:

- `collectPrContextServiceCall` — joins both paths once; verifies both writes by read-back; builds the result record only after verification passes.
- `collectAndWrite` (TypeScript) — returns the two rendered strings; renders the shared timestamp once; passes the clock and the head SHA into both builders.
- `buildSummaryText` — gains a clock parameter and emits the generated-context section first.
- `buildAppendixText` — emits the shared generated-context section (with the head SHA) in place of the current timestamp-only section.
- `appendGenerationTimestamp` (both runtimes) — gains the head-SHA input and emits the head-SHA line.
- `collect_and_write` (Python) — renders the header once and places it first in both documents.
- CLI surface: none. `python -m scripts.dev_tools.pr_context.collector` gains no flag and loses none.
- MCP surface: none. Tool name, input schema, and result schema are unchanged.

#### Data flow and validation changes:

- `workspace_root` becomes the single origin of both output paths. For a given call the value flows: MCP input resolution → `RepoAutomationService.collectPrContext` → `collectPrContextServiceCall`, where it is joined once per artifact and that joined value is used for the write, the log line, the verification read, and the reported artifact entry.
- New validation: after both writes, each file is read back through the injected `FileSystem` and compared to the string this invocation rendered. Inequality, or a read that fails, raises.
- No input validation changes. `workspace_root` normalization is unchanged.

#### Error handling and logging updates:

- A verification mismatch or a failed verification read raises an error naming the artifact path and the nature of the mismatch. The error propagates to the dispatch boundary and becomes `ok: false` with the failure text in the result record.
- A write that throws continues to propagate as before; no new catch is introduced on the write path.
- The two `Wrote context ...` log lines now carry absolute paths, because they log the value actually written to.
- Existing degradation logging (GitHub CLI unavailable, CI target unresolved, unreadable evidence file) is unchanged.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. The change is a defect repair with no configurable behaviour; a flag would preserve the defective path as a reachable option. Rollback is a revert of the change set. The reverted state is the current defective state, so a revert must be accompanied by re-enabling the documented Python-CLI workaround.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Tool input: unchanged (`workspace_root`, `base`).
- Tool output: unchanged in shape. `ok`, `summary`, and `artifacts` keep their existing types. The two values in `artifacts` are textually unchanged from today's output — they were already the workspace-joined paths. What changes is that the files now exist at those paths.
- Artifact text: both files gain a leading `Context generated` section carrying the generation timestamp line and a head-SHA line. In the summary this section is new and precedes the GitHub CLI status section. In the appendix the existing `Context generated` section is extended in place with the head-SHA line and stays first. The section title is reused, not replaced.
- The head-SHA line renders a concrete SHA when the collected context carries one and an explicit unknown token otherwise, matching the existing unknown-value convention used elsewhere in the summary.

#### Required configuration keys and defaults:

None. No new configuration key is introduced in any file. The only configuration edit is three added `coverageThreshold` entries in `extensions/drm-copilot/jest.config.cjs`, each 85 line and 75 branch, matching every existing entry in that map.

#### Backward-compatibility expectations:

- Consumers that read the artifacts by section title are unaffected; no section is renamed or removed.
- Consumers that read the summary positionally — first line, first section — see a new leading section and must tolerate it. The four committed tests that assert the `Context generated` banner by substring keep passing because the title is reused.
- Consumers that parse the reported `artifacts` array see no textual change.
- The Python CLI's relative-path behaviour is preserved exactly, so any script invoking it with `--repo-root .` and the default output paths continues to behave as documented.
- `.claude/hooks/enforce-pr-author-skill.ps1` requires no change and begins finding the artifacts it already looks for, because it resolves them against the session worktree cwd.

#### Performance constraints (latency/throughput/memory):

- R2 adds two file reads per invocation, of documents already bounded by the existing summary and appendix character budgets. The added cost is negligible relative to the git and GitHub CLI work the collector already performs, and no throughput target changes.
- Memory: the two rendered strings are already held in memory during rendering; returning them from `collectAndWrite` extends their lifetime to the end of the service call and adds no copy.
- No performance criterion is asserted for this fix; the constraint is that no measurable regression is introduced, and none is expected from two bounded reads.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - `workspace_root` as supplied to the tool is an absolute path to the checkout the caller intends to write into. This is already the documented contract; `workflow-command-arguments.ts` records that the server cannot infer the checkout and must not fall back to `process.cwd()`.
  - The injected `FileSystem` read-back returns the bytes just written when the write succeeded. This holds for `RealFileSystem` over `node:fs` and for the in-memory test doubles.
  - `contextResult.headSha` is already on the collected record and requires no additional git call.
  - The research findings are read-derived and no command exit code supports them. Implementation is expected to confirm them by executing the toolchain.

- Constraints (budget, performance, compatibility):
  - The verbatim-port relationship between the TypeScript and Python collector modules must survive the change; this is what confines the join and the verification to the caller.
  - `.claude/rules/typescript.md` requires wall-clock reads to flow through an injected clock, which is why the summary builder gains a clock parameter rather than calling `new Date()`.
  - `.claude/rules/general-unit-test.md` prohibits temporary files in tests, so all verification tests use in-memory filesystems.
  - No production file may be excluded from coverage measurement; line coverage of at least 85 and branch coverage of at least 75 apply uniformly.
  - Every touched file stays within the 500-line limit.
  - Six skill copies must be edited together; two of the three self-hosted/bundled pairs are byte-parity enforced by tests.
  - The repository carries two Jest configurations with differently named coverage scripts, and only one of them enforces per-file thresholds. The root `package.json` defines `test:unit:coverage`, which runs against the root `jest.config.cjs`; that configuration carries no `coverageThreshold` key. The per-file `coverageThreshold` map exists only in `extensions/drm-copilot/jest.config.cjs`, and the script that loads it is named `test:coverage` in `extensions/drm-copilot/package.json`. Any coverage-threshold assertion must therefore name the extension-scoped script together with its working directory, because the root script cannot fail on per-file entries it never loads. A bare script name is ambiguous between the two manifests.

- External dependencies (services, libraries, releases):
  - No new library. No new service.
  - Release dependency for live effect only: `@danmoisan/drm-copilot-mcp` must be republished and re-resolved by the client before the live MCP tool changes behaviour. This does not gate acceptance.

## Data / API / Config Impact

- User-facing or API changes:
  - **No change to the MCP tool contract.** Tool name, input schema, and result schema are identical. The `artifacts` array values are textually identical to today's output.
  - **Observable artifact text changes, precisely:**
    - The **summary** gains a new first section titled `Context generated`, containing a UTC timestamp line and a head-SHA line. Today the summary has no generation timestamp at all and its first section is the GitHub CLI status section, which now becomes the second section. The summary already carries the head SHA inside its base-and-head block; that line is unchanged and is not removed, so the SHA appears twice in the summary by design — once in the fixed-position header a consumer can read without parsing, and once in its existing positional context.
    - The **appendix** keeps its existing first section titled `Context generated` and gains one head-SHA line inside it. Today the appendix carries the head SHA only mid-document, roughly fifty lines in, inside the PR-comparison block; that occurrence is unchanged.
    - The timestamp string is byte-identical between the two files because it is rendered once per invocation and passed to both builders.
  - **Observable log text changes, precisely:** the two lines emitted at the end of the collector run, `Wrote context summary to:` and `Wrote context appendix to:`, change from a repo-relative path to the absolute workspace-joined path on the TypeScript service-call path. The Python CLI is unaffected: it continues to print the path it was given.
  - **Committed tests that observe these strings:** four tests assert the `Context generated` banner by substring — in `extension.integration.test.ts`, `collector-integration.test.ts`, `collector-output.test.ts`, and `summary-helpers.test.ts`. Reusing the existing section title is a deliberate choice so those four keep passing; only the added head-SHA line and the summary's new leading section require test updates. Separately, the section-ordering assertions in `collector-output.test.ts` and the log-line assertions in `pr-context-service-call.test.ts` do require updating, because the summary gains a leading section and the log lines gain an absolute path.

- Data or migration considerations:
  - No persisted schema, no database, no state file. The artifacts are regenerated on every invocation and are not versioned.
  - No migration is required for artifacts written by the prior version. A pre-existing pair simply lacks the header and fails the new consumer cross-check, which is the intended outcome: it is stale and should be regenerated.
  - Stale artifact files already present in a server-process checkout are not cleaned up by this change. Cleanup is noted as a post-fix task.

- Logging/telemetry updates (if any):
  - The two `Wrote context ...` lines change as described above.
  - A new error message is emitted on verification failure, naming the artifact path.
  - No telemetry system is involved; no counters or events are added.

- Compatibility notes (CLI flags, config schemas, versioning):
  - No CLI flag added, removed, or changed in either runtime.
  - No config schema changed. `jest.config.cjs` gains three entries in an existing map, following the established per-file pattern.
  - No version bump is required by the contract; the extension and MCP package version bump is handled by the normal release process and is what makes the fix reach the live tool.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage: failure-to-write paths return an error, never `ok: true`.
- [ ] Freshness marker (timestamp + head SHA) embedded in artifacts; consumer-side cross-check documented in `pr-context-artifacts` skill.
- [ ] Integration scenario: invoke against a branch where write fails; assert error surfaces and stale artifact is not consumed.

- Regression tests to add or update:
  - **T1 — path identity at the service seam.** With an in-memory filesystem and a fixed workspace root, assert that the set of paths written equals the set of paths reported in `result.artifacts`, and that both equal the workspace-joined pair. Asserting set equality, rather than two independent literal assertions, is what prevents the two expressions drifting apart again. This is the corrected form of the assertion that currently pins the relative key.
  - **T2 — path identity at the `node:fs` boundary.** With the workspace configured and the `node:fs` write mock in place, assert that the recorded write arguments are the two workspace-joined paths. This is the test that would have caught the defect, because it observes the exact argument `RealFileSystem` hands to Node.
  - **T3 — the dispatch-level test that currently encodes the defect** is corrected so the written key and the reported artifact are the same pair.
  - **T5 — freshness header in both files, one timestamp.** With a fixed injected clock and a fixed head SHA, assert that the first section of each rendered text is the generated-context section, that the timestamp line is byte-identical between the two, and that the head-SHA line carries the fixture SHA.
  - **T6 — section ordering preserved.** Extend the existing ordering assertion so the generated-context section is the first entry of the summary ordering and the relative order of every previously asserted section is unchanged.
  - **T7 — Python freshness header and the narrow parity assertion.** Mirror T5 in pytest against `collect_and_write`, and add the single literal-comparison parity test described in Scope.
  - **T8 — MCP boundary contract.** Assert that the artifacts array in the structured result is the pair the service reports, with a companion asserting `ok: false` when the service call rejects.

- Unit tests (pytest) for the fixed behavior and boundaries:
  - Python `collect_and_write` writes a summary and an appendix whose generated-context blocks are byte-identical.
  - The Python generation-timestamp helper renders the expected concrete head-SHA line for a fixture SHA, and the expected unknown token when no SHA is available.
  - The header is the first section of both Python-rendered documents, and no previously asserted section moved.
  - The literal-comparison parity test over the two runtimes' section-title and head-SHA-label literals.

- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - **T4a — write silently discarded.** Inject a filesystem whose write accepts and discards; assert the service call raises.
  - **T4b — stale file present, write discarded.** Pre-seed both target paths with prior-invocation content, inject a discarding write, and assert the service call raises. An existence-only check would not raise here; this is the test that distinguishes read-back from existence and is the direct expression of the issue's central hazard.
  - **Partial write.** Summary write succeeds, appendix write fails; assert the call raises and the failure names the appendix.
  - **Missing head SHA.** Collected context carries no head SHA; assert the unknown token renders and no error is raised.
  - **Truncation boundary.** A summary long enough to hit the character budget still carries the header, because the header is the first section and truncation removes from the end.
  - **Append mode.** The existing append behaviour of `writeOutput` is unchanged and still verified.

- Error handling and logging verification:
  - Assert that a raised verification failure reaches the dispatch boundary as `ok: false` and that the failure text is present in the result record.
  - Assert the two `Wrote context ...` log lines carry the absolute joined paths.
  - Assert that GitHub CLI unavailability, an unresolved CI target, and an unreadable evidence file each still produce written artifacts and a successful call.

- Coverage impact and targets for changed lines/modules:
  - Line coverage of at least 85 and branch coverage of at least 75 for every changed production file, in both runtimes. Thresholds are uniform across T1 through T4, so the absence of `quality-tiers.yml` at repository root does not change the obligation.
  - Jest already measures every `src/**/*.ts`, so the three pr-context modules are already in the denominator; only the per-file threshold entries are missing and are added.
  - No coverage regression on changed lines.
  - No production file is excluded from measurement.

- Toolchain commands to run (format → lint → type-check → test):
  - TypeScript, in order, restarting from the first on any failure or any file change: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`. Coverage: `npm run test:unit:coverage`.
  - Python, in order, restarting from the first on any failure or any file change: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`.

- Manual validation steps (if required):
  - None are required for acceptance. Post-release only, and recorded as evidence rather than as a gate: after the MCP package is republished and re-resolved, invoke the tool from a worktree and confirm the artifacts appear in that worktree with a header whose SHA matches that worktree's head. This cannot be an acceptance criterion because an unpinned `npx` launch exercises the installed package rather than this branch.

## Acceptance Criteria
- [x] A named Jest test in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` invokes the service call with an in-memory filesystem and asserts that the sorted list of paths written through that filesystem is equal to the sorted `artifacts` list on the returned record, and that both equal the workspace-joined summary and appendix pair. The assertion is a single equality between the written set and the reported set, not two independent literal assertions.
- [x] A named Jest test in `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` asserts that the recorded `node:fs` write arguments for a collect-pr-context invocation are exactly the two workspace-joined artifact paths, and that no recorded write argument is a repository-relative path.
- [x] The dispatch-level test in `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` that today asserts a repository-relative write key alongside a workspace-joined reported path is updated so both assertions name the same workspace-joined pair, and it passes.
- [x] A named Jest test injects a filesystem whose write method accepts the call and discards the content, and asserts that the service call raises. The test fails if read-back verification is removed from the service call.
- [x] A named Jest test pre-seeds both target paths with content from a prior invocation, injects a write method that discards, and asserts that the service call raises. This scenario is the one an existence-only check would pass; the criterion is what distinguishes read-back from existence.
- [x] A named Jest test asserts that when the summary write succeeds and the appendix write fails, the service call raises and the raised message names the appendix artifact path.
- [x] A named Jest test at the tool-dispatch boundary asserts that when the service call raises, the tool result carries `ok` false and the failure text appears in the result record.
- [x] A named Jest test asserts that a successful invocation returns `ok` true and an `artifacts` array whose two entries are equal to the two paths written during that same test run.
- [x] A named Jest test with a fixed injected clock and a fixed head SHA asserts that the first section of the rendered summary text and the first section of the rendered appendix text are both the generated-context section, and that the timestamp line extracted from each text is byte-identical.
- [x] A named Jest test asserts that both rendered texts contain the head-SHA line built from a concrete forty-character fixture SHA supplied by the test.
- [x] A named Jest test asserts that the head-SHA line renders the explicit unknown token when the collected context carries no head SHA, and that no error is raised in that case.
- [x] The section-ordering assertion in `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` asserts that the generated-context section is the first entry of the summary ordering and that the relative order of every section it previously asserted is unchanged.
- [x] A named Jest test asserts that the two collector log lines emitted after the writes carry the absolute workspace-joined artifact paths.
- [x] A named Jest test asserts that when the GitHub CLI is reported unavailable, both artifacts are still written and the service call returns successfully.
- [x] A named pytest test invokes the Python `collect_and_write` with a stubbed runner and asserts that the summary text and the appendix text it writes each open with the generated-context section, and that the generated-context block is byte-identical between the two texts.
- [x] A named pytest test asserts that the Python-rendered head-SHA line for a concrete forty-character fixture SHA equals the expected concrete line, and that the unknown token renders when no SHA is available.
- [x] A named pytest parity test reads the source text of `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` and asserts that the generated-context section title literal and the head-SHA label literal it contains are equal to the corresponding literals used by `scripts/dev_tools/pr_context/summary_helpers.py`.
- [x] `extensions/drm-copilot/jest.config.cjs` carries a `coverageThreshold` entry for each of `./src/lib/pr-context/pr-context-service-call.ts`, `./src/lib/pr-context/collector-output.ts`, and `./src/lib/pr-context/summary-helpers.ts`, each specifying 85 lines and 75 branches, and running `npm run test:coverage -- --coverageReporters=text` from the `extensions/drm-copilot` directory completes with exit code zero and prints a per-file coverage table in which each of those three files reports line coverage at or above 85 and branch coverage at or above 75. That script is the extension-scoped one and is the only coverage command that loads `extensions/drm-copilot/jest.config.cjs`, the sole Jest configuration carrying a `coverageThreshold` map; the added `text` reporter is required because the script's own reporters are `lcov` and `text-summary`, neither of which prints a per-file table. A run in which any of the three files falls below its entry exits non-zero with a Jest coverage-threshold error naming that file.
- [ ] `poetry run pytest --cov=scripts.dev_tools.pr_context.collector --cov=scripts.dev_tools.pr_context.summary_helpers --cov-branch --cov-report=term-missing` reports line coverage of at least 85 percent and branch coverage of at least 75 percent for both named modules.
- [x] All six `pr-context-artifacts` SKILL.md copies enumerated in the implementation strategy carry the two-step consumer cross-check (pair identity by equal generated-context timestamp, head binding by SHA equality against the branch head) in their refresh rule, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passes.
- [ ] The committed diff introduces no join of an output path against the repository root inside `scripts/dev_tools/pr_context/collector.py`, and contains no change to `.claude/hooks/enforce-pr-author-skill.ps1` or `.claude/hooks/enforce-pr-author-skill-helpers.ps1`.
- [ ] Every file changed by this fix is at or under 500 lines.
- [ ] Full toolchain pass in a single run for both runtimes: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`, and `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`.

## Risks & Mitigations
- Technical or operational risks:
  - **Test churn masks a regression.** Twelve committed test files are touched, several of which currently assert the defective behaviour. Correcting them by rote could remove an assertion that was catching something unrelated.
  - **The summary's new leading section breaks a positional consumer.** Any reader that assumes the summary opens with the GitHub CLI status section will see different text.
  - **The two runtimes drift on the header shape.** The change is made twice, in two languages, with only one narrow literal assertion protecting the relationship.
  - **Read-back verification produces a false failure on a filesystem that does not return the bytes just written.** For example a filesystem double in a test that records writes but does not serve reads.
  - **The fix does not reach the live tool until republish.** A reviewer or operator may conclude from a live invocation that the fix did not work.
  - **Stale artifacts remain in the server-process checkout.** They will not be overwritten by corrected invocations, because corrected invocations write elsewhere.
  - **Research findings are read-derived, with no command exit codes recorded.** A claim about line numbers or behaviour could be stale relative to the branch head.

- Mitigations and rollbacks:
  - Each corrected test is updated to assert the intended behaviour explicitly rather than to accommodate the new output, and the set-equality form in the first criterion makes the specific drift structurally unrepeatable.
  - The `Context generated` section title is reused rather than replaced, so the four substring assertions that already exist keep passing; positional consumers are identified by the ordering assertion, which enumerates the full section order.
  - The narrow literal parity test is added in this change specifically to cover the runtime-drift risk for the two literals introduced here; a broader output-parity harness is recorded as a follow-up.
  - Verification runs through the same injected filesystem instance used for the write, and every test double used in a positive-path test serves reads consistently with its writes; the discarding double is used only in negative tests.
  - The release-sequencing constraint is stated in this spec, in the Rollout section, and is the reason no acceptance criterion invokes the live MCP tool.
  - Stale-artifact cleanup is recorded as a post-fix task rather than automated, because deleting files in an unrelated checkout from a tool invocation would be a worse behaviour than leaving them.
  - Implementation confirms each cited line reference against the branch head before editing, and the toolchain run is the authoritative check.
  - Rollback is a revert of the change set. A revert restores the defective behaviour, so it must be paired with re-enabling the documented Python-CLI workaround.

## Rollout & Follow-up
- Release/rollout steps:
  1. Merge the fix to `main` after a green toolchain run in both runtimes.
  2. Publish a new `@danmoisan/drm-copilot-mcp` release through the normal release process. Until this completes, the live tool continues to exhibit the defect because `.mcp.json` resolves the package through unpinned `npx`.
  3. Rebuild and reinstall the extension so a subsequent push-down writes the updated skill copies into destination workspaces. A `resources/` edit does not change what an already-installed extension writes.
  4. After the client re-resolves the published package, capture post-release evidence: invoke the tool from a worktree and confirm the artifacts appear in that worktree with a generated-context header whose SHA matches that worktree's head. This is evidence, not a gate.

- Post-fix monitoring or clean-up tasks:
  - Remove the stale `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` pair from the main checkout, which currently describes a branch that lives in a different worktree.
  - Retire the documented Python-CLI workaround from operator guidance once the republished package is in use.
  - Watch for a verification failure surfacing as `ok: false` in orchestration receipts; a recurrence would indicate a filesystem or permission problem rather than the path defect.

- Named follow-ups (deliberately out of scope for this fix):
  - **Follow-up A (research O5 / D1)** — surface the degraded-artifact catch-all in `extensions/drm-copilot/src/lib/pr-context/render.ts` through the MCP `warnings` array. The result type already supports the field, so no schema change is required. A total failure to compute the diff currently produces a well-formed artifact pair and a successful result.
  - **Follow-up B (research O3)** — the GitHub CLI is unavailable to the MCP server process, which degrades reference classification and autoclose detection in every artifact that process produces. A distinct defect in the same tool; file as a separate bug.
  - **Follow-up C (research O4)** — `quality-tiers.yml` is absent from the repository root although two rule files name it as the source of truth and state that an unclassified project fails CI. Pre-existing repository condition.
  - **Follow-up D (research O1)** — confirm whether a Copilot `.github` push-down byte-parity test exists, and add one if it does not. The `.github` skill copy is edited by this fix regardless.
  - **Follow-up E** — a general Python-to-TypeScript output-parity harness for the pr-context surface, beyond the single literal assertion added here.
  - **Follow-up F** — extend `.claude/hooks/enforce-pr-author-skill.ps1` to enforce the head-SHA cross-check rather than artifact existence plus a last-write-time comparison. This requires a git call at PreToolUse time and is a larger change than a defect repair.

- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/574
  - Research: `research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md`
  - Rules consulted: `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/general-code-change.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/typescript.md`, `.claude/rules/python.md`

## Behaviour Semantics

The fix must satisfy all six conditions below.

1. **Path identity.** For any workspace root W, the tool writes to and reports exactly `W/artifacts/pr_context.summary.txt` and `W/artifacts/pr_context.appendix.txt`. The reported set equals the written set, always.
2. **`ok` semantics.** `ok: true` holds if and only if both files were written by this invocation and their content read back equals what this invocation rendered. Any other outcome raises, producing `ok: false` with the failure text carried in the result record.
3. **Ordering.** The summary is written before the appendix. Verification runs after both writes. The result record is built only after verification passes.
4. **Pair atomicity is not claimed.** Two sequential writes are not atomic. If the appendix write fails after the summary write succeeded, the summary is already on disk. Verification converts that into a loud failure, and the shared timestamp lets a consumer detect a mismatched pair. Write-to-temp-then-rename is out of scope and would break Python parity.
5. **Degradation is not failure.** An unavailable GitHub CLI, a missing CI target, or an unreadable evidence file must continue to produce a written artifact and a successful result. Only a write failure or a verification failure is an error. The degraded-artifact catch-all in `render.ts` remains a written-but-degraded outcome under this contract; changing that is Follow-up A.
6. **Consumer backward compatibility.** `.claude/hooks/enforce-pr-author-skill.ps1` resolves the summary path against the hook process cwd, which is the session worktree. After the fix the file exists there, so the hook begins working as intended rather than passing on a stale file. No hook change is required by this fix.
