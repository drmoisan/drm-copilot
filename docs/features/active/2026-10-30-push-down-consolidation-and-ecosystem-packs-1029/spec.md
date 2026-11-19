# push-down-consolidation-and-ecosystem-packs — Spec

- **Issue:** #1029
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 4
- **Owner:** drmoisan
- **Last Updated:** 2026-11-18
- **Status:** Draft
- **Version:** 0.4 (amendment A-1, `## Spec Amendments`)
- **Work Mode:** full-feature (AC sources: this file and `user-story.md`)
- **Primary research input:** `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/research/research.2026-10-30T23-07.md` (cited below as "the research")

In this document `<FEATURE>` means `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029`.

## Overview

The repository pushes its agent harness down to destination repositories through three separate push-downs (Claude, Codex, Copilot), each exposed as its own MCP tool with its own payload layout and pack manifests. Epic #1018 makes the shared layer (`AGENTS.md`, `.agents/skills`, generated rules, MCP configuration and agents produced by child 3) the source for all three ecosystems. Three independent push-downs cannot install one shared layer once, cannot let a destination omit an ecosystem it does not use, and cannot protect a destination's own edits consistently.

This child replaces the three push-down flows with one TypeScript pipeline that runs inside the MCP server and the VS Code extension host. The three existing MCP tools and the three existing extension commands remain and become thin wrappers over that pipeline. The pipeline installs the shared layer on every run, installs only the selected ecosystem's layer and packs, computes a plan before any write, offers a dry run that writes nothing, and never overwrites a destination file that the destination changed since the last push-down. Local changes are detected against a destination-root manifest that records a SHA-256 hash per pushed-down file.

The settled design in `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md` and the epic's `## Shared Design` are not re-opened by this spec.

## Scope

In scope (from the epic's child 4 scope and issue #1029):

- The Claude, Codex and Copilot push-downs become one pipeline. The existing MCP tools `push_down_claude_customizations`, `push_down_codex_and_agents_customizations` and `push_down_copilot_customizations` stay as thin wrappers; their input and result changes are additive only.
- Per-ecosystem pack selection. The shared layer is always installed. An ecosystem that is not selected installs no files.
- A dry-run report is available before any write, and every apply run computes and reports the same plan before its first write.
- No overwrite of a destination's own edits, detected against the last pushed-down manifest (`.push-down-manifest.json` at the destination root, SHA-256 per file).
- A second run with no source change and no destination change is a no-op.
- Pack manifests list the generated files that child 3 (#1028) produces, as re-checked at the Phase 0 gate.
- Existing Python ports (`scripts/dev_tools/push_down_*.py`) may be reused or called; they are not added to.

Out of scope:

- A new unified MCP tool (owner question O-2; default is wrappers only).
- Deleting orphaned destination files (O-7; report only).
- Pushing generators down to destinations (O-9).
- Any destination-side hook or skill helper that checks local edits (none is planned; see `## Language Classification`).
- Changes to enforcement hooks.

## Behavior

1. **One pipeline.** A single pipeline entry point accepts a workspace (source) root, a destination root, an ecosystem selection, and options (`dryRun`, `overwriteUnmanaged`). The Claude, Codex and Copilot service calls in `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` call that entry point with exactly one ecosystem each. Enumeration, pack resolution, planning, comparison, writing, manifest handling and reporting happen only inside the pipeline. Per-ecosystem specifics (root folders, Copilot `rewriteTextReferences`, Claude memory scope and mode, Claude blast-radius derive and overlay, C# variant source prefixes, Codex virtual resource pairs) are supplied to the pipeline as ecosystem descriptors and are not reimplemented.
2. **Shared layer always installed.** Every run installs the shared layer: `AGENTS.md`, the shared `.agents/skills/<name>/**` set (skills whose child 1 matrix entry `codex:skill:<name>` has disposition `shared`, including `references/standard.md` per the Q1 default), and the shared configuration `config/orchestration-routing.json` (merged, not overwritten), `config/orchestration-handoff-registry.json` and `config/orchestration-handoff.schema.json`. A file of a shared skill folder whose runtime dependencies lie outside the shared layer is excluded from it and stays in its ecosystem layer as a named ecosystem-layer exception with a stated reason (amendment A-1). The exact shared-layer set is confirmed at the Phase 0 gate.
3. **Ecosystem layers.** Claude: `.claude/**`, `config/blast-radius.json`, and per O-10 `CLAUDE.md` and `.mcp.json` when bundled. Codex: `.codex/**` (including `.codex/lib/**` and the virtual resource pairs) and Codex-only `.agents/skills/**`. Copilot: `.github/**` sub-roots published today plus `.github/copilot-instructions.md` per O-10.
4. **Pack selection.** Each ecosystem layer is filtered by `core` plus the selected packs of that ecosystem's pack manifests. Copilot gains pack manifests and a `packs` input. C# variant routing and mutual exclusion keep today's rules. When `packs` is omitted: if the destination manifest records a selection for that ecosystem, that selection is reused (O-5); otherwise the full ecosystem tree is published, as today.
5. **Unselected ecosystem.** A run writes no file under the roots of an ecosystem that was not selected for that run, and no Codex-only skill under `.agents/skills` unless Codex is selected.
6. **Planning before writing.** The pipeline reads `.push-down-exclusions`, reads `.push-down-manifest.json`, resolves the selection, enumerates the shared layer then the ecosystem layer, and classifies every payload file using the decision table in `### Decision Table`. Only after the full plan exists does an apply run write anything.
7. **Dry run.** With `dry_run: true` the pipeline performs every read and the full plan and writes nothing to the destination: no payload file, no manifest, no summary artifact. The plan is returned as `push_down_report`.
8. **No overwrite of local edits.** A destination file whose hash differs from its manifest entry and from the payload is reported as `conflict` and not written. A destination file with no manifest entry that differs from the payload is reported as `unmanaged-conflict` and not written unless `overwrite_unmanaged: true` (O-4).
9. **Merged paths.** `config/orchestration-routing.json`, `config/blast-radius.json` and `.gitignore` keep their merge behavior, are reported with action `merge`, and are written only when the merged text differs from the current destination text. The Codex push-down, which writes `config/orchestration-routing.json` today without a merge, now merges it like the Claude push-down.
10. **Exclusions.** Paths listed in the destination's `.push-down-exclusions` are withheld for every ecosystem (O-8) and reported as `excluded`.
11. **Orphans.** Manifest entries without a payload counterpart (deselected pack or ecosystem, retired file) are reported as `orphaned`; nothing is deleted (O-7).
12. **Idempotence.** A second apply run with no source change and no destination change writes no file outside `artifacts/` and reports every file as `unchanged`, `merge` (no write), or `excluded` (O-11).
13. **Failure before any write.** The run fails with a specific error and writes nothing when: a pack manifest is missing or malformed; both C# variants are selected; `.push-down-exclusions` is malformed; `.push-down-manifest.json` is invalid JSON, has an unknown `schema_version` major, or misses a required field; the destination is missing or equals the source.

## Interface Contracts

### Destination Manifest

| Item | Value |
| --- | --- |
| File name | `.push-down-manifest.json` |
| Location | destination root; outside every published root; guarded like `EXCLUSION_MANIFEST_RELATIVE_PATH` (root-level assertion as in `assertManifestPathIsRootLevel`) so it is never enumerated, excluded or overwritten as payload |
| Scope | one file for all ecosystems and the shared layer |
| Encoding | UTF-8 without BOM, LF line endings, sorted-key JSON rendered through the existing `stringifySorted` helper |
| Forbidden content | timestamps, absolute paths (no leading `/`, no drive letter, no UNC prefix, no `..` segment), host or user names |
| Tracking | intended to be committed in destinations (O-11 default) |
| Rewrite rule | written after an apply run only when its rendered text differs from the current file; never written by a dry run |

Fields:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `schema_version` | string | yes | semantic version; initial `1.0.0`; a reader rejects an unknown major version |
| `payload_version` | string | yes | extension version that produced the payload (from the extension package metadata); identical across runs of the same build |
| `selection` | object | yes | keys are ecosystem names (`claude`, `codex`, `copilot`) that have been pushed down to this destination; each value records `packs` (sorted array of pack names, always including `core`) and, where applicable, `csharp_variant` and `memory_mode` |
| `files` | object | yes | keys are destination-relative POSIX paths; sorted |
| `files.<path>.layer` | string | yes | `shared`, `claude`, `codex` or `copilot` |
| `files.<path>.pack` | string | yes | owning pack name (`core` for unscoped publishes) |
| `files.<path>.sha256` | string | yes | lowercase hex SHA-256 of the UTF-8 bytes of the LF-normalized text, which is exactly the text `PushDownFileSystem.writeTextFile` writes; destination text is LF-normalized before hashing so a CRLF checkout of an unchanged file compares equal |

Entry maintenance: `create`, `update`, `adopt` and `converged` record the payload hash; `conflict`, `deleted-locally` and `orphaned` keep the previous entry unchanged; `unmanaged-conflict` creates no entry unless it is overwritten through `overwrite_unmanaged`; `merge` and `excluded` paths are not entries in `files`. Selection entries for ecosystems not selected in a run are kept unchanged.

### Decision Table

D = destination file, M = manifest entry, P = payload text after reference rewrites and C# variant routing. Hashes are of LF-normalized text.

| D | M | Comparison | Action | Write in apply mode |
| --- | --- | --- | --- | --- |
| absent | absent | | `create` | yes |
| absent | present | | `deleted-locally` (reported) | no |
| present | present | hash(D) = M and hash(P) = M | `unchanged` | no |
| present | present | hash(D) = M and hash(P) differs from M | `update` | yes |
| present | present | hash(D) differs from M and hash(D) = hash(P) | `converged` (manifest updated) | no |
| present | present | hash(D) differs from M and from hash(P) | `conflict` (reported) | no |
| present | absent | hash(D) = hash(P) | `adopt` (manifest updated) | no |
| present | absent | hash(D) differs from hash(P) | `unmanaged-conflict` (reported) | no; yes only with `overwrite_unmanaged: true` |

Additional actions outside the comparator: `merge` (merged paths), `excluded` (`.push-down-exclusions`), `orphaned` (manifest entry with no payload counterpart).

### Dry-Run and Apply Report

Returned in the new optional result field `push_down_report` (internal name `pushDownReport` on `RepoAutomationExecutionResult` and `PushDownServiceCallResult`), mapped in `toMcpToolResult` in `extensions/drm-copilot/src/mcp-tools.ts`:

```json
{
  "mode": "dry-run",
  "ecosystems": {
    "claude": { "packs": ["core", "python"], "csharp_variant": "modern", "memory_mode": "overwrite" }
  },
  "files": [
    { "path": ".agents/skills/orchestrate/SKILL.md", "layer": "shared", "pack": "core", "action": "create", "reason": "absent in destination and manifest" }
  ],
  "counts": { "create": 1 }
}
```

- `mode` is `dry-run` or `apply`. `files` is sorted by `path`, contains destination-relative POSIX paths only, and includes every planned, merged, excluded and orphaned path. `counts` has one key per action that occurs.
- For identical inputs, the `files` and `counts` of a dry run equal those of the subsequent apply run.
- In apply mode the same per-file `action` is added next to the existing `destination_status` in the per-run summary artifact.
- `conflict`, `unmanaged-conflict` and `deleted-locally` lines are also returned in `warnings`, using a new line-prefix constant distinct from `EXCLUSION_CONFLICT_LINE_PREFIX`, so existing exclusion-conflict counting in the extension commands is unchanged.

### MCP Wrapper Input Additions

All additions are optional; existing properties keep their names, types, enums and defaults (`extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`, `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts`, and both definition lists `REPO_AUTOMATION_TOOL_DEFINITIONS` and `toolDefinitions`).

| Property | Tools | Type | Default | Meaning |
| --- | --- | --- | --- | --- |
| `dry_run` | all three | boolean | `false` | plan and report only; write nothing |
| `overwrite_unmanaged` | all three | boolean | `false` | O-4 opt-in: overwrite `unmanaged-conflict` files |
| `packs` | `push_down_copilot_customizations` | string array | omitted | Copilot pack selection with the same semantics as the Claude and Codex `packs` property |

Ecosystem selection: under the O-2 default each wrapper selects exactly its own ecosystem, so no `ecosystems` property is added to an existing tool. The pipeline's internal input is an `ecosystems` map (ecosystem name to selection); only a unified tool, if O-2 is answered in its favor, would expose it.

### MCP Result Compatibility

- Tool names in `extensions/drm-copilot/src/repo-automation-tool-names.ts` are unchanged.
- For a call that supplies none of the new properties, the result keeps `ok`, `tool`, `workspace_root`, the existing `summary` strings, `artifacts` as a one-element array with the normalized summary-artifact path, and `warnings` present only when non-empty. The only addition is `push_down_report`.
- A dry-run call returns no summary-artifact path in `artifacts`, because no file is written.

### Pack Manifests

- Existing per-bundle `pack-manifests/` directories under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/` keep their location and format (`{ "name", "label", "paths", "source_prefix"? }`), because the Pester `*.Manifest.Tests.ps1` suites and `scripts/dev_tools/generate_codex_agent_variants.py` read them.
- New Copilot manifests under `extensions/drm-copilot/resources/customizations/pack-manifests/`, same format.
- One new shared-layer manifest named `shared`, same format, loaded on every run; its bundle location is fixed in the plan. Its `paths` are exactly the shared-layer set of Behavior 2 (`AGENTS.md`, the shared `.agents/skills/<name>/**` files minus the ecosystem-layer exceptions of amendment A-1, and the three shared configuration paths), and the Phase 0 gate, the manifest, the shared-layer tests and the completeness test use that one set.
- Partitioning `.agents/skills` entries between the shared manifest and the Codex `core.json` keeps every required agent path that the Codex generator `--check` demands.

## Language Classification

Owner LANGUAGE RULE (verbatim): "Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The language depends on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and extension commands."

Owner exception E2: a language-native analyzer is allowed when it analyzes that same language and ships only with that language's pack; PowerShell remains the baseline.

| Planned artifact | Runs where | Language | Rule clause that applies |
| --- | --- | --- | --- |
| Pipeline core: ecosystem descriptors, shared-layer and pack resolver, planner, apply step (new modules under `extensions/drm-copilot/src/lib/push-down/`) | MCP server process (bundled into `@danmoisan/drm-copilot-mcp`) and VS Code extension host; never copied to a destination (`packages/mcp-server/prepack.cjs` copies resources only) | TypeScript | Clause (2): MCP-command and extension-command code. Recorded as owner question O-1 with this default. |
| Manifest reader, writer and hash comparator (new module, `node:crypto`) | same | TypeScript | Clause (2) |
| Report builder (pure function) | same | TypeScript | Clause (2) |
| MCP wrapper changes: schema properties, input parsing, dispatch, `toMcpToolResult` mapping | MCP server | TypeScript | Clause (2): MCP commands |
| Extension command changes (optional dry-run step, Copilot pack QuickPick) in `repo-automation-command-registration-admin.ts` | VS Code extension host | TypeScript | Clause (2): extension commands |
| Pack manifests (existing, new Copilot, new shared) | bundled data | JSON | Not code; neither clause restricts data files |
| Destination `.push-down-manifest.json` | written into destinations | JSON | Not code; clause (1) covers skills, skill helpers, hooks and libs only |
| New Jest tests and test helpers under `extensions/drm-copilot/test/` | CI and local test runs only | TypeScript | Tests of clause (2) code; no new Python ("Avoid new Python") |
| Existing Python contract and completeness tests under `tests/scripts/dev_tools/` | CI | existing Python, edited in place only where a contract changes | "extend in place only"; no new `.py` file |
| Existing Python ports `scripts/dev_tools/push_down_*.py` | repository tests only | existing Python, unchanged | "reuse, call"; not added to (issue #1029); O-6 |
| Destination-side check of local edits (hook or skill helper) | destination | not planned; would be PowerShell or bash | Clause (1); none is created in this child |
| Generators (child 3) | repository | PowerShell (owned by child 3) | Not created or pushed down by this child (O-9) |
| Language-native analyzer | none | none | E2 not applicable |

No new Python file is added by this child, including tests. No TypeScript or Python file is added under a pushed-down root (`.claude`, `.codex`, `.agents`, `.github`, `config` and their bundle copies).

## Upstream Dependencies and Phase 0 Gate

Owner decision E3 applies: this child is planned before its upstream outputs exist on `main`. The plan carries a Phase 0 gate that re-checks every assumption below at execution time.

### Assumed child 1 outputs (#1025, branch `feature/harness-survey-gold-standard-contracts-parity-matrix-1025`)

- Parity matrix at `config/harness-parity-matrix.json`, schema at `config/harness-parity-matrix.schema.json` (JSON Schema Draft 2020-12, `$id` `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json`, `schema_version` major `1`).
- This child selects matrix entries by the fields `ecosystem`, `kind`, `name`, `disposition`, `target_paths` and `generated_from`; it does not parse `id`.
- Shared-skill set: entries with `kind` `skill`, `ecosystem` `codex` and `disposition` `shared`.
- Contract format: `.agents/skills/<name>/references/standard.md` for each skill in that set, with a byte-identical bundle copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`, and no pack-manifest entry from child 1 (Q1 deferred to this child).

### Assumed child 3 outputs (#1028, branch `feature/shared-source-generators-skills-rules-mcp-agents-1028`; research only at planning time)

- `.agents/skills/<name>/` is the shared-skill source and `.claude/skills/<name>/` its generated mirror, with bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills`.
- Rules generated into `.claude/rules/*.md` (`paths:`) and `.github/instructions/*.instructions.md` (`applyTo`), with bundle copies under `claude-customizations` and `customizations`; possibly also `.agents/skills/<rule>/SKILL.md` (child 3 OQ-2).
- MCP configuration generated into the root `.mcp.json` and the `[mcp_servers]` table of `.codex/config.toml`; bundle copies at `codex-and-agents-customizations/.codex/config.toml` and a `.mcp.json` bundle location that child 3 names.
- Agents generated into `.claude/agents/*.md` and `.codex/agents/*.toml` with bundle copies; Codex variants still produced by `scripts/dev_tools/generate_codex_agent_variants.py`, which keeps appending agent paths to the Codex manifests.
- `AGENTS.md` is the hand-authored instruction source with its bundle copy at `codex-and-agents-customizations/AGENTS.md`; `CLAUDE.md` is `@AGENTS.md` plus Claude-only text; no `CLAUDE.md` bundle copy exists unless child 3 adds one.
- Generators are PowerShell and repository-internal (child 3 OQ-1 default); destinations receive generated outputs only.
- Child 3 adds manifest entries for the files the existing completeness tests enumerate; this child owns the remaining work so that pack manifests list every generated file.

### Phase 0 gate (execution time)

- Runs as the first plan phase, before any edit, against current `origin/main` after the epic orchestrator's wave sync.
- Confirms that child 1 and child 3 have merged, and re-checks each assumption above: file paths, schema `$id` and `schema_version` major, the fields used, the contract path and bundle-copy path, each generated path and bundle-copy location, and which generated files already have manifest entries.
- Records the result, the resolved shared-layer file set, and the list of child 3 generated files that the pack manifests must list, under `<FEATURE>/evidence/qa-gates/` with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.
- If any assumption differs, or an upstream child has not merged, execution stops and returns for re-planning. One plan revision is accepted when the upstream survey invalidates the plan.

## Execution Preconditions

- The parallel run `bugs-1001-1002-1003-1006` and issue #1013 merged before the 2026-11-14 planning refresh, and issues #1001, #1002, #1003, #1006, #1009, #1010, #1011, #1012 and #1013 are closed (read-only `gh issue view`, 2026-11-14). There is no execution-time wait on that run, and the plan carries no gate for it.
- Hook registration is one PreToolUse dispatcher per runtime (#1159): `.claude/hooks/invoke-pretooluse-dispatch.ps1` with its registry `.claude/hooks/pretooluse-dispatch.json` and the Codex counterparts. A Claude or Codex pack that installs hooks installs the dispatcher and its registry with them; `test_push_down_pack_manifest_dependency_closure.py` already reads the hooks the registry names, and this child keeps it green without editing a hook.
- An execution-time gate re-checks every file, symbol and heading that the plan edits or pins (including `DESTINATION_WRITE_DECORATORS`, `VIRTUAL_RESOURCE_DIRECTORIES`, and the TypeScript declarations pinned by the static parity tests) against the merge base of `origin/main` and `HEAD`, and stops for re-planning if any has moved, been renamed or changed shape.

## Planning Refresh Decisions (2026-11-14)

Recorded by the preparation-mode orchestrator under the coordinator's autonomous-mode relay; each is task direction within the existing scope and changes no owner default above.

- R-1 Superseded-work check: partial. `main` already removed `.agents/skills/ci-workflows/SKILL.md` from the Codex completeness test's skill exception set; the O-12 work closes only the exceptions still present. No other cited behavior is delivered by `main`: none of the planned pipeline modules exists under `extensions/drm-copilot/src/lib/push-down/`.
- R-2 The execution wait on the parallel run `bugs-1001-1002-1003-1006` is removed, because the run merged and its issues are closed.
- R-3 The seeded shuffled Jest run is removed from the non-functional requirements, because the repository's test policy now forbids shuffled, reversed and serial runs as gates or evidence; test-order independence is still required.
- R-4 Hook registration through the PreToolUse dispatcher (#1159) is recorded under `## Execution Preconditions`; this child edits no hook and keeps the dependency-closure test green.
- R-5 `VIRTUAL_RESOURCE_DIRECTORIES` in `codex-agents-customizations.ts` gained the `.codex/lib/epic-wave` pair (#1134). It stays a pinned declaration that the Codex layer reuses unchanged.
- R-6 #1025 and #1028 are still open on 2026-11-14, so the Phase 0 upstream gate (owner decision E3) is kept unchanged.
- R-7 The destination manifest location (`.push-down-manifest.json` at the destination root), its field names, and the pack names (`core`, `python`, `powershell`, `typescript`, `csharp-modern`, `csharp-legacy`, Copilot `csharp`, and `shared`) are unchanged, because the prepared plans of #1049, #1050 and #1051 cite them.

## Spec Amendments

- A-1 (2026-11-18, the one plan revision accepted under `### Phase 0 gate (execution time)`). The Phase 0 gate recorded `Result: BLOCKED` (`<FEATURE>/evidence/qa-gates/phase0-upstream-recheck.2026-11-18T07-25.md`): the shared skill `test-execution-policy` bundles `scripts/Invoke-PesterSuite.ps1`, `scripts/Invoke-TestSuite.ps1` and `scripts/run-test-suite.sh`; `Invoke-TestSuite.ps1` dot-sources helpers from `.claude/hooks` or `.codex/hooks` and reads `config/test-execution-policy.json`, none of which is in the shared layer, so a Copilot-only destination would receive a launcher that exits 2. Amendment: the shared-layer set of Behavior 2 and `### Pack Manifests` excludes a named list of ecosystem-layer exceptions, each with its owning layer and reason. The list holds exactly those three files, owned by the Codex layer through their existing Codex `core.json` entries; the Claude layer keeps its own `.claude/skills/test-execution-policy/scripts/` copy. The Phase 0 assumption becomes: no `.py` or `.ts` file in a shared skill's bundle folder, and every `.ps1`, `.psm1` or `.sh` file there either has all runtime dependencies inside the shared-layer set or is on the exception list. The single shared-set definition, the manifest name, and every other behavior are unchanged. The plan records the list as decision D16.

## Open Owner Questions

Rule: execution proceeds on the recommended defaults below unless the owner answers otherwise before execution starts. An owner answer that differs from a default is applied by a plan revision before execution starts. No owner stop is placed inside the executor plan, because the executor stop hook requires every task to be ticked.

| ID | Question | Recommended default | Behavior change and affected existing tests |
| --- | --- | --- | --- |
| Q1 (from child 1) | Do `.agents/skills/<name>/references/standard.md` contracts reach destinations through pack-manifest entries, or stay repository-local? | Not settled here. Recommended: deliver each contract with its skill (same layer and pack as its `SKILL.md`), because the contract is part of the shared skill and an unlisted bundled file is already published by any call without `packs`. If answered "repository-local", the pipeline also withholds them on the no-`packs` path. | New files delivered to destinations; manifest completeness tests extended in place. |
| O-1 | Is the pipeline core MCP-command code (TypeScript), with the epic's "if a skill or hook invokes it" clause not applying to MCP tool calls? | TypeScript; the core runs only in the MCP server and extension host and is reached from agent content only as an MCP tool call. | None. |
| O-2 | Add a unified MCP tool with `ecosystems` and per-ecosystem `packs`? | No; the three wrappers only. | None. |
| O-3 | Must apply refuse to run until a dry run was made? | No. `dry_run` is optional (default `false`); every apply run computes and reports the plan before its first write; conflicts are never overwritten. | None. |
| O-4 | How are differing files in a destination with no manifest handled? | Report as `unmanaged-conflict` and skip; opt-in `overwrite_unmanaged: true` overwrites them. | Behavior change: today such files are overwritten and classified `overwritten`; under the default they are reported and left untouched. Existing tests that pre-populate a destination and assert `overwritten` are updated, with the reason recorded in the plan and in the test: `copilot-customizations-engine.test.ts`, `copilot-customizations.test.ts`, `claude-customizations.test.ts`, `codex-agents-customizations.test.ts`, `codex-bundle-publish.integration.test.ts`, `push-down-service-call.test.ts`, `repo-automation-service.push-down-claude.test.ts`, `repo-automation-service.push-down-codex.test.ts`, plus any further test the preflight search finds asserting `overwritten`. |
| O-5 | Does an omitted `packs` reuse the selection recorded in the manifest? | Yes when a selection for that ecosystem exists; otherwise publish everything as today. | No existing test changes (no destination has a manifest today). |
| O-6 | If a TypeScript declaration pinned by the Python parity tests must change, update the Python port in place or retire it? | Pinned TypeScript declarations read by Python parity tests (`ROOT_FOLDERS`, `MERGED_RELATIVE_PATHS`, `DESTINATION_WRITE_DECORATORS`, `EXCLUDED_RELATIVE_PATHS`, the Codex virtual pairs, `TS_FILESYSTEM_ADAPTER`, `TS_DERIVE_CORE`, `TS_OVERLAY` targets) are not changed; the shared layer is a separate declaration. If planning finds a change unavoidable, the question is put to the owner before execution starts. | None under the default; `test_push_down_claude_parity.py`, `test_push_down_claude_overlay_parity.py`, `test_push_down_claude_exclusion_parity.py`, `test_push_down_claude_gitignore_parity.py` and `test_skill_bundle_contract_repo.py` pass unmodified. |
| O-7 | Delete managed, unmodified files of a deselected pack or ecosystem? | No; report as `orphaned`. | None. |
| O-8 | Apply `.push-down-exclusions` to Codex and Copilot as well as Claude? | Yes. | Behavior change only for destinations that have the file; Codex and Copilot tests are unaffected unless their fixtures contain it (preflight checks). |
| O-9 | Push generators down? | No; destinations receive generated outputs only. | None. |
| O-10 | Write `AGENTS.md`, `CLAUDE.md` and `.mcp.json` to destination roots? | Yes, as whole files under the no-overwrite rule (a destination's own file becomes a reported conflict); `AGENTS.md` in the shared layer, `CLAUDE.md` and `.mcp.json` in the Claude layer; `.github/copilot-instructions.md` in the Copilot layer. | Behavior change: these files are published where they were not before. Resource-contract and service-call tests that assert the published set are updated with the reason. |
| O-11 | Is `.push-down-manifest.json` committed in destinations, and does "no-op" exclude the per-run summary artifact? | Committed; no-op means no file outside `artifacts/` changes. | None. |
| O-12 | Close the pre-existing manifest gaps (completeness tests' exception sets; rules, libs and supporting files not checked)? | Yes, in this child, with a full-bundle completeness test in Jest. | Behavior change: manifest-scoped runs (including every extension-command run) now publish previously dropped files. `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_codex_and_agents_pack_manifest_completeness.py` are edited in place to remove closed exceptions. |
| Consolidation side effect | (not a question; recorded for review) | The Codex push-down merges `config/orchestration-routing.json` instead of overwriting it. | Behavior change; Codex tests that assert the unmerged write (`codex-agents-customizations.test.ts`, `codex-bundle-publish.integration.test.ts` if applicable) are updated with the reason. |

## Inputs / Outputs

- Inputs: MCP tool arguments (`workspace_root` plus the optional properties in `### MCP Wrapper Input Additions` and the existing `packs`, `csharp_variant`, `memory_mode`); bundled payload under `extensions/drm-copilot/resources/`; destination `.push-down-exclusions` and `.push-down-manifest.json`.
- Outputs: destination files per the plan; `.push-down-manifest.json`; the existing per-run summary artifact under `artifacts/<ecosystem>-customizations/` (apply mode only), extended with `action`; MCP result with `push_down_report`.
- Config keys and defaults: `dry_run=false`, `overwrite_unmanaged=false`, `packs` omitted (O-5 rule).
- Backward compatibility: see `### MCP Result Compatibility`; behavior changes are limited to those listed in `## Open Owner Questions`.

## API / CLI Surface

- `push_down_claude_customizations { workspace_root, packs?, csharp_variant?, memory_mode?, dry_run?, overwrite_unmanaged? }`
- `push_down_codex_and_agents_customizations { workspace_root, packs?, csharp_variant?, memory_mode?, dry_run?, overwrite_unmanaged? }`
- `push_down_copilot_customizations { workspace_root, packs?, dry_run?, overwrite_unmanaged? }`
- Example: a Codex call with `dry_run: true` against an empty destination returns `push_down_report.mode = "dry-run"`, every shared-layer and Codex-layer file with action `create`, and leaves the destination unchanged.
- Example: repeating an apply call with unchanged inputs returns every file `unchanged` (merged paths `merge` without a write) and changes no file outside `artifacts/`.

## Data & State

- New persistent state: `.push-down-manifest.json` in each destination (schema above).
- Invariant: the manifest hash of a managed file equals the hash of the text last written or adopted by the push-down.
- No migration of existing destinations is performed; a destination without a manifest is handled by the first-run rules (`adopt`, `unmanaged-conflict`).

## Constraints & Risks

- Depends on child 3 (generators) and on child 1 (parity-matrix dispositions, contract format), neither of which exists on `main` at planning time (owner decision E3); see `## Upstream Dependencies and Phase 0 Gate`.
- The parallel run `bugs-1001-1002-1003-1006` has merged; no execution wait remains (see `## Execution Preconditions`).
- Language rule: see `## Language Classification`.
- Risk: existing tests that assert `overwritten` change meaning under O-4; mitigated by naming each affected test with its disposition in the plan and a wrapper-compatibility test for old inputs.
- Risk: new manifests or moved `.agents/skills` entries break resource-contract, completeness or closure tests; mitigated by running the contract tests in `## Non-Functional Requirements` after each manifest change.
- Risk: CI-only failures from drive-letter fixture paths or committed CRLF fixtures; mitigated by POSIX in-memory roots (for example `/dest`) and CRLF content built in test code.

## Non-Functional Requirements

- File size: every new or changed file stays at or below 800 lines. New logic goes into new modules; `claude-customizations.ts` (near 500 lines) receives no new logic, and each edited file is re-measured before commit.
- Coverage: changed TypeScript meets line >= 85% and branch >= 75%. Each new production file gets its own `coverageThreshold` entry (lines 85, branches 75) in `extensions/drm-copilot/jest.config.cjs`.
- Tests create no temporary files and touch no real file system; destinations are in-memory `PushDownFileSystem` fakes, and the payload is read through the existing real-bundle reader helper. Each test builds a fresh fake; the pipeline holds no module-level mutable state. Test gates are parallel only: Jest runs through its normal parallel workers, pytest as one `pytest -n auto` run, and Pester as one `Invoke-PoshQCParallelTest` run; no serial, single-process, shuffled or reversed run is a gate or evidence, and test-order dependence is a defect.
- Bundle mirrors and the contract tests named in `.claude/skills/execution-environment/SKILL.md` (`## Contract Tests That Pin Mirrored Files`) stay green, plus `test_push_down_pack_manifest_dependency_closure.py`, `test_codex_core_manifest_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_push_down_tier_rule_adoption_gate.py`, the static parity tests, the Pester `*.Manifest.Tests.ps1` suites and the Codex generator `--check`. If the brief's contract-test list or push-down facts change, all byte-identical copies of the brief are updated in the same change.
- Enforcement hooks under `.claude/hooks`, `.codex/hooks` and `.github/hooks` are unchanged.
- `extensions/drm-copilot` remains tier T3 in `quality-tiers.yml`; no new project entry is required because no PowerShell module is added.

## Implementation Strategy

- New TypeScript modules under `extensions/drm-copilot/src/lib/push-down/`: ecosystem registry and descriptors, shared-layer and pack resolver (one loader keyed by ecosystem, replacing the duplicated load and union logic while keeping the pinned declarations), planner and comparator, destination-manifest reader and writer, report builder, pipeline entry point.
- The existing engine (`copilot-customizations-engine.ts`) keeps enumeration, validation and the summary artifact; the copy loop is replaced by plan application.
- The three customization modules and `push-down-service-call.ts` become adapters that build an ecosystem descriptor and call the pipeline.
- MCP layer: additive schema properties, input parsing, `toMcpToolResult` mapping of `push_down_report`.
- Pack manifests: new Copilot manifests, a shared-layer manifest, closed completeness gaps (O-12), entries for child 3 generated files per the Phase 0 record.
- Dependency changes: none (`node:crypto` is built in and already used in `extensions/drm-copilot/src`).
- Rollout: ships with the next extension and MCP package release; no feature flag.

## Acceptance Criteria

- [x] `push_down_claude_customizations`, `push_down_codex_and_agents_customizations` and `push_down_copilot_customizations` each delegate to the same pipeline entry point with a selection that names only their own ecosystem; a Jest test per wrapper verifies the delegation, and no wrapper module contains its own enumeration, planning or write loop.
- [x] For each ecosystem, an apply run into an empty in-memory destination writes every file of the shared-layer set resolved at the Phase 0 gate; verified by a data-driven Jest test over the Claude, Codex and Copilot wrappers.
- [x] For each ecosystem, every path written by a run lies in the shared-layer set or under that ecosystem's layer roots, and no path lies under another ecosystem's layer (including Codex-only `.agents/skills` entries for non-Codex runs); verified by a data-driven Jest test.
- [x] Each wrapper, including `push_down_copilot_customizations`, accepts `packs` and publishes only `core` plus the selected packs for its ecosystem layer, with C# variant rules unchanged; verified by Jest tests.
- [x] A call with `dry_run: true` leaves the in-memory destination byte-identical (no payload file, no `.push-down-manifest.json`, no summary artifact) and returns `push_down_report` with `mode` `dry-run` listing every planned path with its action.
- [x] An apply run returns `push_down_report` with `mode` `apply`, and for identical inputs its `files` and `counts` equal those of the preceding dry run; the plan is computed before the first write.
- [x] Each row of the decision table in `### Decision Table` has a Jest unit test asserting the action and whether the file is written.
- [x] A destination file edited locally after a push-down (hash differs from its manifest entry and from the payload) is not overwritten, is reported as `conflict` in `push_down_report` and in `warnings`, and keeps its previous manifest hash.
- [x] A second apply run with no source change and no destination change writes no file outside `artifacts/` and reports every path as `unchanged`, `merge` or `excluded`; verified by an integration-style Jest test using the real bundle reader and an in-memory destination.
- [x] A first run against a destination with no manifest creates absent files, adopts identical files, and reports differing files as `unmanaged-conflict` without writing them; with `overwrite_unmanaged: true` those files are overwritten. Every existing test changed by this behavior is listed in the plan with its reason.
- [x] `.push-down-manifest.json` is written at the destination root as sorted-key LF JSON with `schema_version`, `payload_version`, `selection` per pushed-down ecosystem, and a `layer`, `pack` and SHA-256 of LF-normalized text for each managed file; a Jest test asserts it contains no timestamp and no absolute path, and that a CRLF destination copy of an unchanged file is classified `unchanged`.
- [x] A malformed or unknown-major `.push-down-manifest.json`, a malformed pack manifest, both C# variants selected, or a malformed `.push-down-exclusions` fails the run with a specific error before any write; verified by Jest tests.
- [x] Merged paths (`config/orchestration-routing.json`, `config/blast-radius.json`, `.gitignore`) are reported as `merge`, preserve destination content, and are written only when the merged text differs, for every wrapper that delivers them (including the Codex wrapper for `config/orchestration-routing.json`).
- [x] Paths in `.push-down-exclusions` are withheld and reported as `excluded` for the Claude, Codex and Copilot wrappers (O-8 default).
- [x] Manifest entries without a payload counterpart are reported as `orphaned` and no destination file is deleted.
- [x] An omitted `packs` reuses the selection recorded for that ecosystem in `.push-down-manifest.json`, and publishes the full ecosystem tree when no selection is recorded (O-5 default).
- [x] The pack manifests list every generated file that child 3 produces, as recorded by the Phase 0 gate, and a Jest full-bundle completeness test passes: every file under a published root of each bundle is listed by a layer manifest or by a documented exception with a stated reason.
- [x] The Phase 0 gate and the execution-precondition gate ran before any edit and their records are under `<FEATURE>/evidence/qa-gates/`, including confirmation that child 1 (#1025) and child 3 (#1028) have merged.
- [x] The language classification holds: the branch diff against `origin/main` adds no `.py` file, adds no TypeScript or Python file under a pushed-down root or its bundle copy, and adds or changes no `scripts/dev_tools/push_down_*.py` file.
- [x] Existing MCP tool names are unchanged, existing input properties keep their types, enums and defaults, and for calls without the new properties the result keeps `ok`, `tool`, `workspace_root`, `summary`, a one-element `artifacts` and `warnings` only when non-empty, with `push_down_report` as the only added field; verified by a wrapper-compatibility Jest test.
- [x] The static parity tests (`test_push_down_claude_parity.py`, `test_push_down_claude_overlay_parity.py`, `test_push_down_claude_exclusion_parity.py`, `test_push_down_claude_gitignore_parity.py`, `test_skill_bundle_contract_repo.py`) pass without modification (O-6 default).
- [x] The bundle-mirror and contract tests listed in `## Non-Functional Requirements`, the Pester `*.Manifest.Tests.ps1` suites and the Codex generator `--check` pass, with results recorded under `<FEATURE>/evidence/qa-gates/`.
- [x] Each new production TypeScript file has its own `coverageThreshold` entry (lines 85, branches 75) in `extensions/drm-copilot/jest.config.cjs`, and the Jest run meets every threshold.
- [x] No new or changed file exceeds 800 lines, no test creates a temporary file, and no file under `.claude/hooks`, `.codex/hooks` or `.github/hooks` is changed.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: pack selection, shared-layer-always rule, unused-ecosystem-installs-nothing, dry-run report, no-overwrite against the last manifest.
- [x] Integration scenarios: a destination pushed down twice with the second run a no-op; a destination with a local edit preserved.
- [ ] CLI/API examples
