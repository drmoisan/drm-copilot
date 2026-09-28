# 2026-09-13-taskmaster-push-down-and-resume — Spec

- **Issue:** #674
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-14T09-15
- **Status:** Draft
- **Version:** 0.2

## Overview

`.claude/**` (166 files) plus `config/blast-radius.json` and `config/orchestration-routing.json` are
pushed from `drm-copilot` into consumer repositories with zero templating. A fix made in a consumer
repository is overwritten by the next push-down. That has already occurred: a local fix to
`enforce-model-routing-receipt.ps1` in TaskMaster (commit `4389d95b`, 2026-09-02) was lost.

The `worktree-scoped-state-resolution` epic repairs a defect class in which `drm-copilot` hooks and
MCP tools resolve orchestration state against the invoking session's current working directory
instead of against the worktree the tool call actually pertains to. Six upstream features (F1-F6)
produce the corrected hook, library, and MCP content. Without a delivery step, that content never
reaches the repository whose stalled run motivated the epic.

TaskMaster parallel run `bugs-2026-09-11` is the consumer: a 13-item run reached a standstill with
zero agents runnable, three items merged, five blocked behind gates, and one blocked fix the
orchestration that produced it could not land.

**Preparation-mode scope note.** F1-F6 have not executed as of this document's authoring. This spec
describes the ordered, gated procedure the `epic-orchestrator` executes once F2-F6 have merged. It
does not assert that corrected content exists in this repository, the installed extension, or
TaskMaster today.

### The verification trap

`mcp__drm-copilot__push_down_claude_customizations` resolves its bundled source root from the
**running MCP server process's own directory** — the installed VS Code extension — never from
`extensions/drm-copilot/resources/claude-customizations/` in the git checkout (research
`## Q1`, verified by reading `mcp-provider.ts`, `mcp-server.ts`, and
`push-down-service-call.ts`). Consequently, once F2-F6's commits land in this repository, running
the push-down without first rebuilding and reinstalling the extension publishes the **old** files.
If the TaskMaster destination already carries a working local hand-fix (as it did for commit
`4389d95b`), that push-down overwrites the fix with the stale version — the verification step
actively undoes the fix it was meant to confirm.

Four `drm-copilot`-identity extension directories currently coexist on this machine across two VS
Code product lines (`.vscode` and `.vscode-insiders`) and two extension identities
(`undefined_publisher.drm-copilot` and `danmoisan.drm-copilot`), with materially different payload
sizes (8 hooks vs. 44 hooks) (research `## Q1`). The staleness gate must check every discovered
directory rather than assume which one the active VS Code window serves.

### The ordering constraint

Because the rebuild is the only mechanism that can make the installed extension's payload current,
and because an already-activated extension does not pick up files changed on disk without its
window being reloaded (research `## Automation Feasibility`, "Restart/reload requirement" — no
code path calls `.fire()` on `mcpDidChangeEmitter`), this feature's procedure enforces a strict
order: rebuild + reinstall, then human-triggered reload, then a staleness grep that doubles as the
reload-completion signal, then the manifest-registration check, then the destination pre-check,
then the push-down, then the destination-content grep, then the TaskMaster resume confirmation
(research `## Q6`). Skipping the staleness grep and proceeding straight to the push-down after the
rebuild verifies nothing — this is the verification trap itself.

## Behavior

Procedural delivery only. No new logic, and no change to hook or MCP behavior.

1. Rebuild and reinstall the `drm-copilot` VS Code extension
   (`pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force`)
   so the installed extension's bundled payload carries the epic's corrected content.
2. Reload the VS Code window hosting the extension (human exception, HI-2; see
   `runbooks/reload-vscode-window-for-mcp-payload.runbook.md`), because no automated,
   non-disruptive path exists in this repository's tooling to make an already-running MCP server
   process pick up the newly installed files.
3. Grep the installed extension's `resources/claude-customizations/.claude/hooks/` directory,
   under every discovered `drm-copilot`-identity directory, for a changed literal selected at
   execution time (research `## Q3`) to confirm the reload took effect.
4. Confirm F1's new `.claude/lib/` module path is registered exactly once in
   `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`'s `paths[]`
   array, so a pack-scoped push-down does not silently omit it.
5. Check the TaskMaster destination for any known, still-unsuperseded local hand-fix before the
   push-down runs, since the tool has no dry-run, diff, or backup mode to protect against
   overwriting one.
6. Push the corrected customizations down to TaskMaster via
   `mcp__drm-copilot__push_down_claude_customizations`, with an explicit, operator-supplied
   `workspace_root`.
7. Confirm the destination files carry the new content by grepping for the identical changed
   literal used in step 3 — not by trusting the push-down's exit code or its JSON summary
   artifact, neither of which carries content, hash, or version information (research `## Q3`).
8. Confirm TaskMaster run `bugs-2026-09-11` can resume its remediation cycles (human exception,
   HI-1; see `runbooks/confirm-taskmaster-run-resume.runbook.md`), only after step 7 has passed.

## Inputs / Outputs

- **Inputs:**
  - `workspace_root` (required, string, no default): the TaskMaster destination's absolute path.
    The tool has no discovery logic for this value and no notion of "TaskMaster" — it must be
    supplied by the operator or a prior-session record at execution time (research `## Q3`,
    "TaskMaster destination path — not discoverable from this checkout").
  - `packs` (optional array, e.g. `["core"]`): selects which pack manifests' `paths[]` gate the
    copy. Omitting it publishes the entire bundled tree unfiltered and does not exhibit the
    silent-omission risk described below; supplying it activates that risk for any path missing
    from the selected manifest(s) (research `## Q2`).
  - `csharp_variant` (optional enum) and `memory_mode` (optional enum: `overwrite`/`merge`/`skip`,
    scoped to the agent-memory subtree) — additional caller-supplied tool arguments (research
    `## Q4`, citing `mcp-push-down-schema-properties.ts`).
  - The changed literal used in steps 3 and 7 of Behavior: cannot be fixed in this document because
    F2-F6 have not executed and no such literal exists yet. The executor derives it at execution
    time by running `git diff <pre-epic-base>..HEAD -- .claude/hooks/ .claude/lib/`, selecting one
    added, single-line, non-interpolated literal unique to the new content, and confirming it does
    not appear in the pre-fix version of the same file (research `## Q3`). The identical literal
    must be used for both the pre-push-down and post-push-down greps.
- **Outputs:**
  - The destination file tree under the TaskMaster `workspace_root`: this is what steps 6-7
    actually change and verify.
  - The push-down's return value and its written JSON summary artifact (`PushDownServiceCallResult`
    / `renderPushDownSummary`): `repo_root`, `destination_root`, `started_at`/`finished_at`,
    `created_count`, `overwritten_count`, `rewritten_reference_count`,
    `placeholder_rewrite_count`, `unmatched_references`, and a `files[]` array of
    `relative_path` / `destination_status` (`created`/`overwritten`) pairs (research `## Q3`).
    **This output proves that a copy action ran and which destination-relative paths were touched
    and whether each was created or overwritten. It does not prove content, hash, or source
    version of any copied file** — there is no content hash, no byte comparison, no source mtime,
    and no version marker anywhere in this schema. It must not be used as a substitute for the
    step 7 grep.
- **Config keys and defaults:** none introduced by this feature; the push-down tool's schema is
  pre-existing (see API / CLI Surface).
- **Versioning or backward-compatibility constraints:** none — this feature changes no tool
  contract, hook, or MCP behavior.

## API / CLI Surface

- **Rebuild + package + install** (non-interactive, verified in the research's
  `## Automation Feasibility`):
  ```powershell
  pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force
  ```
  Runs `npm ci`, `npm run compile`, `npx --yes @vscode/vsce package`, and
  `code-insiders --install-extension <vsix> --force`, in that order. The script is
  `SupportsShouldProcess = $true, ConfirmImpact = "Medium"`; PowerShell's default
  `$ConfirmPreference` is `High`, so no interactive prompt is triggered by default.
- **Push-down tool** — `mcp__drm-copilot__push_down_claude_customizations`. Complete input surface
  (`mcp-tool-definitions.ts:133-146`, `mcp-push-down-schema-properties.ts:38-59`,
  `additionalProperties: false`):
  - `workspace_root` (required, string)
  - `packs` (optional, array of strings; `core` is always included when a pack list is supplied)
  - `csharp_variant` (optional, enum)
  - `memory_mode` (optional, enum: `overwrite` | `merge` | `skip`)
  - No `dry_run`, `diff`, `backup`, or equivalent argument exists or is accepted (research `## Q4`).
- **Example invocation shape** (concrete `workspace_root` supplied by the operator at execution
  time; not fixable now):
  ```
  mcp__drm-copilot__push_down_claude_customizations(
    workspace_root: "<TaskMaster destination absolute path>",
    packs: ["core"]
  )
  ```
  Expected output: a `PushDownServiceCallResult` as described under Inputs / Outputs. This output
  alone does not satisfy this feature's acceptance criteria; it must be paired with the step 7 grep.
- **Contracts and validation rules:** the tool has no `dry_run` mode. A pack-scoped call
  (`packs` supplied) silently omits any source path absent from the selected manifest's `paths[]`
  — no error, no log entry distinguishing intentional exclusion from omission by oversight
  (research `## Q2`, `ExcludingFileSystem.listFiles` / `isPackIncluded`).

## Data & State

- **Data transformations and invariants:** the push-down copies files under `.claude/**` and
  `config/**` (`ROOT_FOLDERS = [".claude", "config"]`) from the installed extension's bundled
  `resources/claude-customizations/` tree to the destination workspace root. Most published paths
  are plain overwrites (`writeTextFile`, no pre-read comparison, no diff).
- **Two destination files are not plain overwrites**, and this matters directly to the overwrite
  hazard this feature exists to prevent (research `## Q2`):
  - `config/orchestration-routing.json` is **merged** at the destination
    (`RoutingMergeFileSystem`), not overwritten wholesale.
  - `config/blast-radius.json` is **derived** at the destination (`BlastRadiusDeriveFileSystem`
    replaces the bundled bytes with a destination-specific module map), not copied verbatim.
  Because these two paths do not behave like every other published file, the pre-push-down
  hand-fix check (Behavior step 5) must account for the possibility that a destination
  "difference" in these two files is expected merge/derivation behavior rather than evidence of an
  unsuperseded local fix, and must not treat them identically to a plain-overwrite hook file.
- **Caching or persistence details:** none beyond the destination file tree and the JSON summary
  artifact described under Inputs / Outputs; the push-down holds no cache of prior runs.
- **Migration or backfill requirements:** none. This feature performs a single delivery pass; it
  does not migrate destination data formats.

## Constraints & Risks

- **No new logic.** This is procedural delivery. A plan that grows an implementation phase changing
  hook or MCP behavior has taken on another feature's scope.
- **No file over 500 lines.**
- Evidence paths must resolve to `<FEATURE>/evidence/<kind>/`. Paths under `artifacts/baselines/`,
  `artifacts/qa/`, and `artifacts/evidence/` are forbidden.
- Every negative claim ("the destination does not carry the old content") must record `SearchScope`,
  `SearchPatterns`, and `SearchResult`.
- The push-down's exit code and JSON summary report that files were copied and their
  created/overwritten status, not which version of them was copied. Neither is acceptable
  verification evidence on its own (research `## Q3`).
- TaskMaster is a different repository and is not present in this checkout; its destination path
  is not discoverable from this checkout and must be supplied by the operator (research `## Q3`).
- **Four installed extension directories coexist** on this machine across two product lines and
  two extension identities, with different payload sizes; the staleness gate must check all of
  them rather than guess which one is served (research `## Q1`).
- **Silent omission by pack manifest.** A file absent from a pack manifest's `paths[]` is dropped
  by a pack-scoped push-down with no error and no log entry. F1's `.claude/lib/` module must be
  registered in `core.json`'s `paths[]` before the push-down or it is not delivered (research
  `## Q2`).
- **No dry-run, diff, or backup mode.** The tool's input schema sets `additionalProperties: false`;
  the only available safety check against overwriting a destination hand-fix is an external
  read-and-compare step performed before the call (research `## Q4`).
- **No self-triggered MCP refresh path.** `mcpDidChangeEmitter` is declared and wired but never
  fired anywhere in `extensions/drm-copilot/src/`; a rebuilt-and-reinstalled extension is not
  served by an already-activated VS Code window until that window is reloaded or restarted
  (research `## Automation Feasibility`, "Restart/reload requirement"). No automated,
  non-disruptive trigger for that reload exists in this repository's tooling today.
- **Must-not-regress:** the push-down must not overwrite any destination fix with a stale version.
  This is the exact failure that already occurred once — the TaskMaster local fix to
  `enforce-model-routing-receipt.ps1` (commit `4389d95b`, 2026-09-02) was lost to a prior
  push-down.

## Implementation Strategy

- **Implementation scope:** None — this feature adds no code. It produces an ordered, gated
  operational procedure (this spec's Behavior section) plus two human-exception runbooks already
  authored under `runbooks/`.
- **New classes/functions/commands to add or update:** None — this feature adds no code.
- **Dependency changes (new/removed packages) and rationale:** None — this feature adds no code.
- **Logging/telemetry additions and locations:** None — this feature adds no code. Evidence of each
  gated step is recorded as a file under
  `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/`, per
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, not as application telemetry.
- **Rollout plan:** Sequential, single-pass execution of the eight Behavior steps by
  `epic-orchestrator` after F2-F6 have merged into the epic integration branch. No feature flag,
  staged deploy, or fallback path applies — a failed gate (e.g., the step 3 grep still finding the
  old literal) halts progression to the next step rather than rolling back a deployment.

## Acceptance Criteria

- [ ] Before any push-down runs, the installed extension's bundled payload is confirmed to carry
      the epic's corrected content, proven by a grep for the changed literal selected per the
      research's `## Q3` guidance, run against `resources/claude-customizations/.claude/hooks/`
      under every installed `drm-copilot`-identity directory discovered at execution time, not by
      the rebuild command's exit code alone.
- [ ] The rebuild-and-reinstall command
      (`pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force`)
      is run and the VS Code window hosting the extension is reloaded per
      `runbooks/reload-vscode-window-for-mcp-payload.runbook.md` (HI-2 exception) before the
      staleness grep above is attempted.
- [ ] F1's `.claude/lib/` module path is confirmed present exactly once in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`'s
      `paths[]` array (by the parameterized grep in research `## Q2` or F1's own
      `<ModuleName>.Manifest.Tests.ps1` passing both `It` blocks) before the push-down call uses
      `--packs core`.
- [ ] Before the push-down call, the TaskMaster destination is checked for any known,
      still-unsuperseded local hand-fix (for example, the fix TaskMaster commit `4389d95b` made to
      `enforce-model-routing-receipt.ps1`, if still present and not yet matched by an equivalent
      upstream fix from F5); if one is found without an equivalent upstream fix, the push-down does
      not run against that path.
- [ ] `mcp__drm-copilot__push_down_claude_customizations` is invoked with an explicit,
      operator-supplied `workspace_root` naming the TaskMaster destination.
- [ ] After the push-down call, the destination files are confirmed to carry the new content by
      grepping the destination for the identical literal used in the pre-push-down staleness grep
      — the same literal, not a newly chosen one — and this grep result, not the push-down's exit
      code or JSON summary artifact, is the evidence of record.
- [ ] No destination fix is overwritten with a stale version: the pre-push-down hand-fix check
      found either no un-superseded local fix, or one confirmed superseded by the pushed-down
      content, and this is stated in the evidence record.
- [ ] TaskMaster run `bugs-2026-09-11` is confirmed to resume its remediation cycles, per
      `runbooks/confirm-taskmaster-run-resume.runbook.md` (HI-1 exception), which requires
      distinguishing genuine resumption from a false-approval sibling-checkpoint read.
- [ ] Every negative claim recorded in this feature's evidence (for example, "the old literal is
      absent from the destination") carries `SearchScope`, `SearchPatterns`, and `SearchResult`.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Staleness check: grep the installed extension payload for a changed literal before push-down.
- [ ] Manifest registration check: F1's module path present exactly once in `core.json` `paths[]`.
- [ ] Post-push-down destination content check for the same changed literal.
- [ ] Negative-claim auditability: absence claims carry SearchScope / SearchPatterns / SearchResult.
