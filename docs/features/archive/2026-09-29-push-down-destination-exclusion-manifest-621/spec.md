# 2026-09-29-push-down-destination-exclusion-manifest — Spec

- **Issue:** #621
- **Parent (optional):** Epic push-down-payload-correctness (#770)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-45
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Design source:** `research/2026-09-29T14-25-exclusion-manifest-design.research.md` (section 13 Recommendation, with the orchestrator decisions on section 14 recorded under "Decisions on open questions" below)

## Overview

The Claude push-down does not preserve a destination repository's prior, repository-specific exclusion decisions. Content that a destination explicitly opted out of during an earlier sync is reintroduced by a later push-down, and nothing records that the exclusion decision existed or that it should be respected.

Concrete instance (TaskMaster). In 2026-06, TaskMaster's `.claude/` governance was synced from a reference repository under the directive "keep current policy, adapt mechanism" (TaskMaster issue #178, PR #179). That sync deliberately excluded the reference repository's coverage model: `.claude/rules/quality-tiers.md`, the 85% line / 75% branch coverage floor, and the T1-T4 `quality-tiers.yml` tier-classification system. TaskMaster kept its own 80% line / 90% new-module policy. As of 2026-09, `.claude/rules/quality-tiers.md` is present in TaskMaster again. It asserts the 85%/75% floor and requires a `quality-tiers.yml` at the repository root, which TaskMaster does not have.

Impact:

- Two conflicting coverage floors are simultaneously presented as authoritative in the destination (`CLAUDE.md`: 80%/90%; `quality-tiers.md`: 85%/75%), with no signal to an agent about which one governs.
- The reintroduction is not visible at push-down time. The push-down does not check a destination's prior exclusion decisions before writing `.claude/rules/**`.
- Any destination that has made a deliberate, documented divergence from the bundled defaults can have that divergence reverted by the next push-down.

Evidence: found during the `bugs-638-644-647` parallel-orchestration run in TaskMaster (2026-09-01), reported independently by two execution children as a repository-level finding unrelated to their own item work.

This feature introduces a destination-owned exclusion manifest, `.push-down-exclusions`, at the destination repository root. Both push-down implementations read it before any destination write, skip every effective payload path it matches, report skips, conflicts, and unmatched entries, and never write, merge, or delete the manifest itself. When the manifest is absent, both implementations behave exactly as they do today.

## Behavior

### Manifest location

- Path: `<destinationRoot>/.push-down-exclusions`.
- The location is the destination repository root, outside every published root (`.claude`, `config`). The engines enumerate only `<sourceRoot>/<root>` for each entry of `ROOT_FOLDERS`, so a root-level file can never be part of the payload, even if a file of that name were present at the bundle root.
- Both implementations declare the constant `EXCLUSION_MANIFEST_RELATIVE_PATH = ".push-down-exclusions"` and assert at module load that the value contains no `/` and does not begin with any `ROOT_FOLDERS` entry. A unit test in each language pins the same invariant.
- The push-down never writes, merges, or deletes the manifest. This is enforced by construction (the location is not a payload path, the gitignore delivery and the summary-artifact write target other paths) and by the write guard described below.
- The manifest is authored and maintained by the destination repository. This repository ships no manifest and does not deliver one.

### Manifest grammar

- Encoding: UTF-8 text. A leading byte-order mark is stripped. Line endings may be LF or CRLF.
- One entry per line. Blank lines and lines whose first non-blank character is `#` are ignored. Comments let the destination record the reason and issue reference next to each entry.
- An entry is a destination-relative POSIX path. Normalization: trim surrounding whitespace, convert `\` to `/`, strip a leading `./`, collapse repeated `/`.
- Wildcard-free entry: matches a candidate when `candidate == entry` (exact match) or `candidate` starts with `entry.rstrip("/") + "/"` (directory-prefix match). A trailing `/` is optional and only documents intent; `foo/bar` and `foo/bar/` match the same set.
- Wildcard entry (contains `*` or `?`): `**` matches any run of characters including `/`; `*` matches any run excluding `/`; `?` matches exactly one non-`/` character; every other character is literal; the whole candidate must match. This is the `_blast_radius_glob.py` rule. The TypeScript matcher is a direct port into the new module; `lib/file-system.ts` `compileGlob` is not reused because its `**/` semantics differ.
- Comparison is ordinal and case-sensitive. Payload paths carry the bundle's canonical case on every host, so an entry must use that case. Matching is on payload path strings, never on disk lookups, so host filesystem case-insensitivity does not enter.
- Precedence: entries are evaluated in file order; the first matching entry is the one reported for a path; later entries are not evaluated for that path.

### Malformed manifest

A malformed manifest fails the run with `ExclusionManifestError` (TypeScript: `Error` subclass carrying `path` and `line`; Python: `ValueError` subclass carrying the same, following the `ManifestError` precedent in `push_down_claude_pack_selection.py`). The error is raised after the manifest is read and before any destination write, directory creation, merge, derivation scan, or summary-artifact write. The error message names the manifest path and the offending line number where one applies.

Conditions:

- The manifest path exists but is not a regular file (for example, a directory).
- The text is not decodable as UTF-8. Python wraps `UnicodeDecodeError`; the TypeScript parser rejects any entry containing U+FFFD, because `readFileSync(path, "utf8")` substitutes replacement characters rather than throwing.
- An entry that, after normalization, is empty (for example `./`), absolute (leading `/` or a drive prefix such as `X:`), or contains a `..` segment.
- An entry beginning with `!` (negation is not supported and is not silently treated as a literal).
- An entry containing `[` or `]` (character classes are outside the vocabulary and would silently never match).
- An entry with both a wildcard and a trailing `/` (ambiguous).

A manifest containing only comments and whitespace is valid. It filters nothing, but the run records that the manifest was consulted (the report carries `manifest_path` and empty lists).

### Filter placement

- The manifest is read through the injected filesystem adapter (`isFile` probe, then `readTextFile` / `read_text`) before any decorator is constructed and before the engine validates the destination.
- Absent manifest: no filter decorator is constructed. The engine receives the same object graph it receives today. The only added operation is one `isFile` probe of the manifest path.
- Present manifest: a new decorator, `ExclusionFilterFileSystem` (TypeScript `claude-exclusion-filter.ts`; Python `push_down_claude_exclusion_filter.py`), wraps the existing `ExcludingFileSystem` as the outermost decorator, so the engine iterates its `listFiles` / `list_files` result. Pure parsing, normalization, matching, and the `planExclusions` / `plan_exclusions` decision function live in `claude-exclusion-manifest.ts` / `push_down_exclusion_manifest.py`. Python may import `matches_glob` from `_blast_radius_glob.py` rather than re-implement it.
- Because the filter is outermost, it sees the effective payload after hard exclusions, pack selection, memory scope, and memory mode. A manifest entry is judged against what would actually be written.
- Because the filter precedes every merge and derive decorator (`RoutingMergeFileSystem`, `BlastRadiusDeriveFileSystem`, and any merge registry #508 introduces), a path dropped at enumeration never reaches a `writeTextFile` / `write_text` of those decorators. No merge, derivation, destination read, or destination layout scan occurs for a skipped path. Merged paths such as `config/orchestration-routing.json` and `config/blast-radius.json`, and the blast-radius derivation, are therefore governed by the same rule as any other payload path, with no special case.

### Skip, conflict, and unmatched entries

For each effective payload path `p`:

- If some entry `e` matches `p`, `p` is not enumerated to the engine. The filter records `{relative_path: p, entry: e.normalized, line: e.line, destination_status: "present" | "absent"}`, where `present` means the inner adapter reports a regular file at `<destinationRoot>/p` at enumeration time.
- `destination_status == "present"` is a **conflict**: the destination holds a file at an excluded path, and the payload would have overwritten or merged it. Nothing is written; the destination bytes are unchanged. The conflict is reported through every reporting surface below, and the run still succeeds (exit code 0, no thrown error). Rationale: a present file at an excluded path is the expected steady state after the destination replaced bundled content with its own.
- `destination_status == "absent"` is a plain **skip**, reported the same way.
- A manifest entry that matches no effective payload path is an **unmatched entry** (stale, or out of scope for this run because of pack selection or memory mode). It is reported and is not an error.
- Nothing except a malformed manifest (above) and a write-guard violation (below) fails the run.
- The report is handling-agnostic: it does not classify a skipped path as overwrite, merge, or derive.

### Write guard

The decorator's `writeTextFile` / `write_text` raises `ExclusionViolationError` (TypeScript `Error` subclass; Python `RuntimeError` subclass) when the destination-relative target matches a manifest entry or equals the manifest path. After enumeration filtering this branch is unreachable from the engine; it exists so the invariant "never overwrite an excluded path silently, and never write the manifest" holds against any future write source. It is unit-tested directly in both languages.

### Gitignore delivery

The TypeScript post-copy `.gitignore` delivery (`deliverDestinationGitignore`) writes through the raw adapter and bypasses the decorators, so it consults the manifest separately. If `.gitignore` matches an entry, the merge is skipped and reported with `destination_status` `present` or `absent` like any other path. Python delivers no `.gitignore` today, so the parity corpus carries no `.gitignore` scenario until Python delivers it.

### Summary artifact

The summary artifact under `artifacts/claude-customizations/` is the report itself and is not subject to the manifest. An entry matching it is reported as unmatched.

### Stale-file behavior

The push-down never deletes destination files, with or without a manifest. For the TaskMaster case: adding `.claude/rules/quality-tiers.md` to the manifest stops future reintroduction; the destination removes the already-present file once. A push-down before that removal reports a conflict; a push-down after it reports a plain skip.

## Inputs / Outputs

Inputs:

- `<destinationRoot>/.push-down-exclusions` (optional; grammar above). No new CLI flag, MCP input field, service option, or environment variable is introduced.
- Existing inputs (`packs`, `csharp_variant`, `memory_mode`, destination root, artifact root) are unchanged.

Outputs:

- Returned summary: TypeScript `ClaudePushDownSummary extends PushDownSummary` with optional `exclusions?: ExclusionReport`; Python frozen dataclass subclass of `PushDownSummary` with `exclusions: ExclusionReport | None = None`. `undefined` / `None` when no manifest was read.
- Summary artifact JSON: an `exclusions` object added at top level only when a manifest was read, rendered with the engine's sorted-key JSON (TypeScript exports the engine's `stringifySorted`; Python uses `json.dumps(indent=2, sort_keys=True)`). Shape:

```json
"exclusions": {
  "conflict_count": 1,
  "entries": [".claude/rules/quality-tiers.md", ".claude/agent-memory/**"],
  "manifest_path": ".push-down-exclusions",
  "skipped": [
    {"destination_status": "present", "entry": ".claude/rules/quality-tiers.md", "line": 3, "relative_path": ".claude/rules/quality-tiers.md"}
  ],
  "skipped_count": 1,
  "unmatched_entries": [".claude/agent-memory/**"]
}
```

- Service and MCP result: `warnings` (already declared on `RepoAutomationExecutionResult` and spread into `RepoAutomationMcpToolResult`) carries one line per skipped path, conflict, and unmatched entry. The field is omitted when there is nothing to report and when no manifest was read. No MCP schema change.
- Extension output channel: the same lines, emitted through the service call's `log` sink (currently declared but never invoked).
- VS Code push-down command: a warning notification (`showWarningMessage`) when `conflict_count > 0`, stating the conflict count and pointing to the output channel. No notification when the conflict count is zero, including when a manifest was read with only skips or unmatched entries.
- Python CLI stdout: after the existing `Wrote push-down summary artifact to: <path>` line, one additional line per skipped path, conflict, and unmatched entry, only when a manifest was read. Exit code remains 0.

Line forms (identical text in both languages, pinned by the parity corpus):

- `push-down exclusion: skipped <path> (entry <normalized>, line <n>)`
- `push-down exclusion conflict: destination file present, not overwritten: <path> (entry <normalized>, line <n>)`
- `push-down exclusion: entry matched no payload path: <normalized> (line <n>)`

Absent manifest: no `exclusions` key in the artifact, no `warnings` field, no output-channel lines, no notification, no additional CLI lines. The artifact key set is unchanged from today.

Config keys and defaults: none added.

Versioning and backward compatibility: the artifact schema is extended by one optional key that appears only when the manifest exists. Existing consumers that read the ten known keys are unaffected. The MCP tool schema is unchanged.

## API / CLI Surface

- Python CLI: `poetry run python scripts/dev_tools/push_down_claude_customizations.py <existing arguments>`. No new arguments. Example stdout with a manifest excluding `.claude/rules/quality-tiers.md` while the destination file exists and a stale entry `.claude/agent-memory/**`:

```text
Wrote push-down summary artifact to: <destination>/artifacts/claude-customizations/<timestamp>-push-down-summary.json
push-down exclusion conflict: destination file present, not overwritten: .claude/rules/quality-tiers.md (entry .claude/rules/quality-tiers.md, line 3)
push-down exclusion: entry matched no payload path: .claude/agent-memory/** (line 5)
```

- MCP push-down tool: unchanged input schema. Result gains `warnings: [...]` with the lines above when applicable.
- VS Code command: unchanged invocation. Output-channel lines and the conflict notification as described.
- New public symbols (both languages, names per research section 7): `EXCLUSION_MANIFEST_RELATIVE_PATH`, `ExclusionEntry`, `ExclusionManifest`, `SkippedPath`, `ExclusionReport`, `ExclusionManifestError`, `ExclusionViolationError`, `parseExclusionManifest` / `parse_exclusion_manifest`, `matchesExclusionEntry` / `matches_exclusion_entry`, `planExclusions` / `plan_exclusions`, `ExclusionFilterFileSystem`, `renderExclusionLines` / `render_exclusion_lines`, `ClaudePushDownSummary`.
- Contracts and validation rules: grammar and malformed-manifest set above; `planExclusions(payloadRelativePaths, manifest, destinationExists)` is a pure function whose output partitions the payload into kept and skipped paths.

## Data & State

- State model (pure data, both languages): `ExclusionEntry { raw, normalized, kind: exact | directory | glob, line }`; `ExclusionManifest { path, entries }`; `SkippedPath { relativePath, entry, line, destinationStatus }`; `ExclusionReport { manifestPath, entries, skipped, unmatchedEntries }` with derived `skipped_count` and `conflict_count` in the artifact.
- Data flow: manifest read -> parse (fail fast) -> decorator composition -> enumeration filtering with destination-presence probe -> engine copy loop over the reduced payload -> engine summary and artifact -> Claude entry point post-processes the artifact to add `exclusions` (only when a manifest was read) -> warnings, log lines, CLI lines, notification.
- Invariants: no destination write targets a matched path or the manifest path; the engine's `files`, `created`, and `overwritten` values reflect only paths that were written; a skipped path's destination bytes are unchanged after the run; `entries` in the report preserve manifest order.
- Persistence: none beyond the existing summary artifact. No caching. No migration or backfill.

## Upstream Assumptions (#507 and #508)

#507 (Python publishes `config/`, Python routing merge, Python/TypeScript parity test over published roots and merged paths) and #508 (data-addressable merged-path set, blast-radius merge) are planned in parallel within the same epic and are not merged on this branch. Their feature folders are absent from this worktree.

Dependence of this feature on them (research section 3):

| Element | Depends on | Consequence |
| --- | --- | --- |
| Filter placement, manifest format, matcher, report shape, write guard, CLI/MCP/log/notification surfaces | none | Deliverable without either upstream item; the decorator is outermost and path-agnostic. |
| Parity corpus scenario excluding `config/orchestration-routing.json` with identical results in Python | #507 | Until Python publishes `config/`, that entry is unmatched in Python and skipped in TypeScript. The scenario is added to the plan corpus with a dependency marker and is enabled once #507 is present. |
| "Extend the parity test #507 introduces" | #507 | If the parity test file does not exist when implementation starts, this feature creates `tests/scripts/dev_tools/test_push_down_claude_exclusion_parity.py` and `extensions/drm-copilot/test/lib/push-down/claude-exclusion-parity.test.ts`; the integration branch reconciles them with #507's test. |
| Blast-radius merge governed by the filter | #508 | Holds structurally once #508 lands because the filter precedes every decorator; no #621 code references #508 symbols. |

Edit points that depend on upstream items are expressed by symbol or seam name (`ROOT_FOLDERS`, `RoutingMergeFileSystem`, `ROUTING_MERGE_RELATIVE_PATH`, the merge registry, the #507 parity test), not by line number, so that the implementation plan remains valid after the upstream merges.

## Decisions on open questions

Binding decisions from the orchestrator on research section 14:

1. UI: in addition to output-channel lines and `warnings`, the VS Code push-down command shows a warning notification when `conflict_count > 0`. No notification otherwise.
2. No strict mode. Conflicts and unmatched entries never fail the run; only a malformed manifest fails the run. Strict mode is a follow-up.
3. No new dependencies. Property-style coverage uses the repository's seeded-RNG precedent in both languages, printing the seed on failure.
4. Dangling-reference detection is a non-goal and a documented limitation.
5. The report stays handling-agnostic.
6. `push_down_copilot_customizations.py` is not touched by this feature.
7. The Copilot and Codex publishers do not honor the manifest in this feature.

## Non-Goals

- Strict mode (`--strict-exclusions` or equivalent) that fails the run on conflicts or unmatched entries. Follow-up.
- Detection or reporting of dangling references (an excluded file that other pushed-down content cites). Documented limitation in the README manifest section. Follow-up candidate: a substring scan of published text reported as `referenced_by`.
- Handling classification (`overwrite` / `merge` / `derive`) of skipped paths in the report.
- Any change to `scripts/dev_tools/push_down_copilot_customizations.py` (already over the 500-line cap; the overage is a separate finding).
- Honoring the manifest in the Copilot and Codex publishers. The manifest name and destination-relative entry model were chosen so a follow-up can adopt it without a format change.
- Deleting or pruning destination files; the push-down remains write-only.
- Negation entries, character classes, or any glob vocabulary beyond `**`, `*`, `?`.
- A `.gitignore` delivery in Python (not present today; out of scope).
- Any change to `.claude/hooks/**`, `.claude/lib/**`, or destination runtime components.
- Remediation of the TaskMaster destination itself (authoring its manifest and removing the reintroduced rule) is a downstream consumer action.

## Constraints & Risks

- Pushed-down enforcement hooks gain no Python legs. This feature adds no hook and no destination runtime component.
- `.claude/hooks/enforce-powershell-batch-budget.ps1` and its tests (#769) are not modified.
- No production, test, or reusable script file may exceed 500 lines. New logic lives in two new modules per language; `push_down_claude_customizations.py` (403 lines) gains approximately 50 lines and CLI line rendering moves to the filter module if headroom runs short; `push_down_claude_filesystem.py` (472 lines) and `claude-filesystem-adapter.ts` are not modified; `copilot-customizations-engine.ts` gains only an `export` keyword on `stringifySorted`.
- Coverage: line coverage >= 85% and branch coverage >= 75% for the new and changed modules. Per-file `coverageThreshold` entries are added to `extensions/drm-copilot/jest.config.cjs` for the new and changed TypeScript modules.
- No new runtime or development dependency in either language. Parsing and matching use the standard library and regular expressions only.
- Tier: `quality-tiers.yml` is absent from the repository root, so no tier is machine-declared. The new modules are pure parsing and matching logic whose defects would silently revert destination decisions; the implementation follows T2 obligations (property-style coverage per pure function, no `any`) without asserting a classification the tree does not carry.
- Parity risk: divergent matcher semantics between Python and TypeScript. Mitigated by a direct port of one rule set and a shared corpus that both suites execute.
- Tests use in-memory fakes only (`RecordingFileSystem`, `InMemoryPushDownFileSystem`, `buildInMemoryFileSystem`, `fixedClock`, a `layoutLister` fake). Temporary files are prohibited. The Python engine reads the wall clock, so Python absent-manifest identity assertions compare everything except `started_at` and `finished_at`; the TypeScript `fixedClock` permits full byte-identity assertions.
- The upstream items may rename symbols; the implementation plan references seams by name and is re-validated after the upstream merges.

## Implementation Strategy

Implementation scope (what changes, not sequencing):

- New `extensions/drm-copilot/src/lib/push-down/claude-exclusion-manifest.ts`: constant, entry/manifest types, parser, normalizer, matcher, `planExclusions`, `ExclusionManifestError`.
- New `extensions/drm-copilot/src/lib/push-down/claude-exclusion-filter.ts`: `ExclusionFilterFileSystem`, `ExclusionReport` assembly, artifact extension, warning-line rendering, `ExclusionViolationError`.
- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`: manifest read, decorator composition, gitignore-delivery check, `ClaudePushDownSummary`, artifact post-processing.
- `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts`: `export` on `stringifySorted`.
- `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts`: `warnings` population and `log` invocation.
- VS Code command registration (`repo-automation-command-registration-admin.ts` or its service seam): conflict notification.
- New `scripts/dev_tools/push_down_exclusion_manifest.py` and `scripts/dev_tools/push_down_claude_exclusion_filter.py` with the bundled-import fallback pattern (`try: from scripts.dev_tools... except ModuleNotFoundError: from dev_tools...`).
- `scripts/dev_tools/push_down_claude_customizations.py`: manifest read, composition, summary extension, CLI lines.
- Shared corpus `tests/fixtures/push_down_exclusions/matcher-corpus.json`, `manifest-corpus.json`, `plan-corpus.json`, each carrying `manifest_relative_path`.
- Tests: `tests/scripts/dev_tools/test_push_down_exclusion_manifest.py`, `test_push_down_claude_exclusion_filter.py`, the Python parity module; `extensions/drm-copilot/test/lib/push-down/claude-exclusion-manifest.test.ts`, `claude-exclusion-filter.test.ts`, the jest parity test; extensions to `push-down-service-call.test.ts`, `mcp-tools.push-down-claude.test.ts`, and the command-registration tests.
- README "Push-down customizations" section: manifest location, grammar, semantics, reporting, and the dangling-reference limitation.

Dependency changes: none.

Logging and telemetry: warning lines to the extension output channel through the service-call `log` sink; conflict notification in the VS Code command; CLI lines on stdout. No telemetry.

Rollout: no feature flag. The behavior activates only when a destination places a manifest at its root; destinations without a manifest see no change.

## Acceptance Criteria

- [x] AC-1 Manifest location and grammar are documented in this spec and in the README "Push-down customizations" section: path `.push-down-exclusions` at the destination root, comments, blank lines, destination-relative POSIX entries, exact and directory-prefix semantics, `**` / `*` / `?` semantics, ordinal case-sensitive comparison, first-match precedence, and the malformed-manifest condition list. Verified by reading `README.md` and this file.
- [x] AC-2 Both implementations declare `EXCLUSION_MANIFEST_RELATIVE_PATH == ".push-down-exclusions"`, and a unit test in each language (`test_push_down_exclusion_manifest.py`, `claude-exclusion-manifest.test.ts`) asserts the value contains no `/` and does not begin with any `ROOT_FOLDERS` entry.
- [x] AC-3 With a manifest entry matching a payload path that is absent at the destination, both implementations skip the path: it is not written, does not appear in the summary `files` list, does not count toward `created` or `overwritten`, and is recorded in `exclusions.skipped` with `destination_status: "absent"`. Verified by `test_push_down_claude_exclusion_filter.py` and `claude-exclusion-filter.test.ts` over in-memory fakes.
- [x] AC-4 With a manifest entry matching a payload path that is present at the destination, both implementations leave the destination content byte-identical after the run, record the path in `exclusions.skipped` with `destination_status: "present"`, count it in `conflict_count`, and complete with exit code 0 / no thrown error. Verified by the same two test files.
- [x] AC-5 A manifest entry that matches no effective payload path is recorded in `exclusions.unmatched_entries` and rendered as the unmatched warning line, and the run completes normally, in both implementations. Verified by the same two test files.
- [x] AC-6 Each malformed-manifest condition (directory at the manifest path, undecodable text, empty entry after normalization, absolute entry, `..` segment, `!` prefix, `[` or `]`, wildcard plus trailing `/`) raises `ExclusionManifestError` naming the manifest path and line in both implementations, and no destination write, directory creation, or summary-artifact write occurs before the error. Verified by parametrized cases in `test_push_down_exclusion_manifest.py` and `claude-exclusion-manifest.test.ts` plus a filter-level test asserting the in-memory fake recorded zero writes.
- [x] AC-7 The write guard raises `ExclusionViolationError` in both implementations when a write targets a matched path or the manifest path, verified by direct unit tests of `ExclusionFilterFileSystem.writeTextFile` / `write_text`.
- [x] AC-8 After a push-down with a manifest present, the manifest path is not among the in-memory fake's written paths, and its content is unchanged, in both implementations. Verified by `test_push_down_claude_exclusion_filter.py` and `claude-exclusion-filter.test.ts`.
- [x] AC-9 With a manifest entry matching `config/orchestration-routing.json`, the routing-merge decorator's write is never invoked and the destination routing document is neither read nor modified. Verified in TypeScript by `claude-exclusion-filter.test.ts` with a spy on the inner adapter; verified in Python once #507's routing merge is present, and recorded as unmatched (not written) in Python before then.
- [x] AC-10 With a manifest entry matching `config/blast-radius.json`, the derive decorator's write is never invoked and the destination layout lister is never called. Verified by `claude-exclusion-filter.test.ts` with a `layoutLister` fake that fails if invoked.
- [x] AC-11 With a manifest entry matching `.gitignore`, `deliverDestinationGitignore` performs no write and the report records the skip with the correct `destination_status`. Verified by a TypeScript test in `claude-exclusion-filter.test.ts` or `claude-customizations` tests.
- [x] AC-12 With no manifest at the destination, the TypeScript run produces a summary artifact byte-identical to the pre-change artifact under `fixedClock` (the pre-change top-level key set, with no `exclusions` key), no `warnings` field on the service result, no `log` invocation, and no notification. Verified by a regression test in `claude-exclusion-filter.test.ts` and `push-down-service-call.test.ts`.
- [x] AC-13 With no manifest at the destination, the Python run produces a summary artifact with the pre-change top-level key set (no `exclusions` key), identical to the pre-change artifact except `started_at` and `finished_at`, and stdout consists of the single existing artifact line. Verified by a regression test in `test_push_down_claude_exclusion_filter.py`.
- [x] AC-14 The shared corpus files `matcher-corpus.json`, `manifest-corpus.json`, and `plan-corpus.json` exist under `tests/fixtures/push_down_exclusions/`, each carrying `manifest_relative_path`, and both a pytest parity module and a jest parity test iterate every corpus case, so that a divergence in either implementation fails at least one suite. Verified by running both suites and by a corpus-count assertion in each parity test.
- [x] AC-15 The parity corpus covers exact match, directory prefix with and without trailing `/`, sibling-name non-match (for example `.claude/rules/x` against `.claude/rules/xy.md`), `*` not crossing `/`, `**` crossing `/`, `?`, first-match precedence, unmatched detection, and the pinned warning-line text. Verified by reading the corpus and by the parity tests passing in both languages.
- [x] AC-16 Seeded property-style tests exist in both languages for the pure functions (exact entry matches exactly one candidate; directory entry with and without trailing `/` yields identical results; `*` never matches a segment containing `/`; normalization is idempotent; `planExclusions` output partitions the payload), using the repository's seeded-RNG precedent and printing the seed on failure. Verified by test names in `test_push_down_exclusion_manifest.py` and `claude-exclusion-manifest.test.ts`.
- [x] AC-17 The returned summary carries `exclusions` (TypeScript `ClaudePushDownSummary.exclusions`; Python `exclusions` field) when a manifest was read and `undefined` / `None` otherwise. Verified by the filter tests in both languages.
- [x] AC-18 The summary artifact carries the `exclusions` object with keys `conflict_count`, `entries`, `manifest_path`, `skipped`, `skipped_count`, `unmatched_entries`, rendered with sorted keys, only when a manifest was read. Verified by artifact-content assertions in both filter test files.
- [x] AC-19 The service-call and MCP results carry `warnings` with the pinned line text when a manifest produced skips, conflicts, or unmatched entries, and omit the field otherwise. Verified by `push-down-service-call.test.ts` and `mcp-tools.push-down-claude.test.ts`.
- [x] AC-20 The service call invokes the `log` sink once per warning line so the extension output channel shows them. Verified by `push-down-service-call.test.ts`.
- [x] AC-21 The VS Code push-down command shows a warning notification when `conflict_count > 0` and shows none when `conflict_count == 0`, including when a manifest was read with only skips or unmatched entries. Verified by the command-registration tests with a stubbed `window.showWarningMessage`.
- [x] AC-22 The Python CLI prints one line per skipped path, conflict, and unmatched entry after the artifact line, using the pinned text, and exits 0. Verified by a captured-stdout test in `test_push_down_claude_exclusion_filter.py`.
- [x] AC-23 The `ExclusionFilterFileSystem` is composed outermost, wrapping `ExcludingFileSystem`, in both entry points, so that an entry matching only paths removed by pack selection or memory mode is reported as unmatched. Verified by a filter test in each language.
- [x] AC-24 No file in `.claude/hooks/`, `.claude/lib/`, or the #769 file set is modified, `scripts/dev_tools/push_down_copilot_customizations.py` is unchanged, and no new dependency appears in `pyproject.toml`, `package.json`, or `package-lock.json`. Verified by `git diff --stat main` on the feature branch.
- [x] AC-25 No new or modified production, test, or script file exceeds 500 lines. Verified by a line count over the changed files.
- [x] AC-26 Line coverage >= 85% and branch coverage >= 75% for the new and changed TypeScript modules (per-file `coverageThreshold` entries in `jest.config.cjs`) and for `scripts/dev_tools` under the pytest coverage configuration. Verified by the coverage reports of both suites.
- [x] AC-27 The full toolchain (Black, Ruff, Pyright, Pytest; Prettier, ESLint, TSC, Jest) and the existing bundle-contract tests pass in a single pass on the feature branch.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or observations (AC-1 through AC-27)
- [ ] Behavior matches acceptance criteria in both implementations
- [ ] Tests added: manifest, filter, parity, service-call, MCP, command-registration, property-style
- [ ] Edge cases and error handling covered by tests (malformed manifest set, write guard, absent manifest)
- [ ] Docs updated (README push-down section; this spec)
- [ ] Logging added (output-channel lines, CLI lines, conflict notification)
- [ ] Toolchain pass completed (format -> lint -> type-check -> test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: manifest parsing (valid, empty, malformed, comments), glob matching (exact file, directory prefix, wildcard), filter application ahead of writes and merges.
- [ ] Integration scenarios: push-down into a destination with an exclusion for `.claude/rules/quality-tiers.md`, with and without the file present; exclusion of a merged path.
- [ ] Parity: identical skip sets and reports from Python and TypeScript for a shared fixture.
- [ ] CLI/API examples: Python CLI output and MCP push-down result listing excluded paths.
