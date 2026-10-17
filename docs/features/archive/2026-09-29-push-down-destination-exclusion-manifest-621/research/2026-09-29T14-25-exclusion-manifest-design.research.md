# Research: Destination-side push-down exclusion manifest (#621)

- Timestamp: 2026-09-29T14-25
- Issue: #621 (epic push-down-payload-correctness, #770; wave 2, depends on #507 and #508)
- Branch: feature/push-down-destination-exclusion-manifest-621
- Mode: preparation research; no source, configuration, or test file was modified.
- Evidence artifacts: none produced. This document is a research note, not a baseline/QA/regression artifact, so the `<FEATURE>/evidence/<kind>/` scheme does not apply to it.
- Numeric derivation evidence: not applicable. No numeric count, enumeration, or population is proposed for any `spec.md` acceptance criterion in this document. Line counts in section 8 are file-size headroom observations, not acceptance criteria.

All file paths below are repo-relative to the worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6cef4cf01904005c`. Line numbers are against the tree at commit `b7b4a2dc` (branch head at research time).

## 1. Current State Analysis

### 1.1 TypeScript pipeline (`extensions/drm-copilot/src/lib/push-down/`)

Entry point: `pushDownCustomizations` in `claude-customizations.ts:239-322`.

| Step | Where | Notes |
| --- | --- | --- |
| Published roots | `claude-customizations.ts:54` `ROOT_FOLDERS = [".claude", "config"]` | Enumeration-order contract. |
| Hard exclusions | `claude-customizations.ts:73-75` `EXCLUDED_RELATIVE_PATHS = [".claude/settings.local.json"]` | Source-side, static. Not a destination decision. |
| Pack selection | `claude-customizations.ts:265-269` -> `resolvePublishedPaths` (`:177-201`) | Null when no `--packs`; no manifest I/O on the default path. |
| Decorator stack (inner to outer) | `claude-customizations.ts:274-306` | `RoutingMergeFileSystem` (`:274-278`) -> `BlastRadiusDeriveFileSystem` (`:284-291`) -> `ExcludingFileSystem` (`:294-306`). The outermost object is what the engine receives (`:311`). |
| Enumeration filter | `claude-filesystem-adapter.ts:266-278` `ExcludingFileSystem.listFiles` | Four filters in sequence: hard exclusions, pack, memory scope, memory mode. `writeTextFile` is a passthrough (`:296-298`). |
| Engine copy loop | `copilot-customizations-engine.ts:376-425` | Per file: `relativeToPosix(sourcePath, effectiveSource)` (`:381`), destination existence classification via `fs.isFile` (`:387-391`), read (`:398`), rewrite (`:399-400`), `ensureDir` (`:416`), `writeTextFile` (`:417`). Destination-relative path equals source-relative path. |
| Routing merge | `claude-routing-merge.ts:281-298` `RoutingMergeFileSystem.writeTextFile` | Merges only when the target resolves to `config/orchestration-routing.json` (`:306-310`) and the destination file exists (`:288-291`). |
| Blast-radius derive | `claude-blast-radius-derive.ts:282-293` | Substitutes a derived document for `config/blast-radius.json` (`claude-blast-radius-derive-core.ts:76`). The derivation inputs are the destination directory layout via `DirectoryLister` (`:163-207`), not payload files. Runs only when the engine writes that path. |
| Gitignore delivery | `claude-customizations.ts:320`, `:346-361` | Post-copy write of the destination `.gitignore` through the raw adapter, bypassing every decorator. Pure merge in `claude-gitignore-merge.ts:112-136`. Not a payload file; no source file behind it. |
| Summary/report | `copilot-customizations-engine.ts:428-447` | `PushDownSummary` (`:62-74`) built and the artifact written (`writeSummaryArtifact` `:314-329`, `renderPushDownSummary` `:251-271`, sorted-key JSON via module-private `stringifySorted` `:283-303`). |

Verified absence: no deletion or pruning of destination files exists anywhere in `src/lib/push-down/` (search for `unlink|rmSync|prune|delete` returned only comments about ancestor pruning inside the derivation core and a `Set.delete` in `codex-pack-selection.ts:113`). The push-down is write-only; a stale destination file is never removed.

### 1.2 Python pipeline (`scripts/dev_tools/`)

Entry point: `push_down_customizations` in `push_down_claude_customizations.py:188-281`.

| Step | Where | Notes |
| --- | --- | --- |
| Published roots | `push_down_claude_customizations.py:101` `ROOT_FOLDERS = (Path(".claude"),)` | Diverges from TypeScript; `config` is added by #507. |
| Hard exclusions | `:102` `EXCLUDED_RELATIVE_PATHS` | Same single path as TypeScript. |
| Decorator stack | `:261-271` | Only `ExcludingFileSystem` (`push_down_claude_filesystem.py:181`). No routing-merge or blast-radius decorator exists in Python today (#507/#508 add them). |
| Enumeration filter | `push_down_claude_filesystem.py:431-448` | Same four filters. `write_text` passthrough (`:466-468`). |
| Engine | `push_down_copilot_customizations.py:335-439` | Loop `:366-404` mirrors the TypeScript engine; `relative_path = source_path.relative_to(effective_source)` (`:372`), existence classification (`:374-376`), write (`:395`). Timestamps come from `datetime.now(timezone.utc)` (`:357`, `:406`) with no injectable clock. |
| Summary/report | `PushDownSummary` `:91-136`; payload `:48-60`; `render_push_down_summary` `:238-270` (`json.dumps(..., indent=2, sort_keys=True)`); `write_summary_artifact` `:273-311` | |
| CLI output | `push_down_claude_customizations.py:398` | Single line: `Wrote push-down summary artifact to: <path>`. |
| Gitignore delivery | none | Python does not deliver `.gitignore` today. |

Verified absence: no `unlink|rmtree|os.remove|delete` in any `scripts/dev_tools/push_down_*.py`.

Bundled-import fallback: every Python push-down module wraps its sibling imports in `try: from scripts.dev_tools... except ModuleNotFoundError: from dev_tools...` (`push_down_claude_customizations.py:23-60`, `:76-97`; `push_down_claude_filesystem.py:38-53`). A new module must follow the same pattern.

### 1.3 The single seam for the exclusion filter

Both engines derive the destination path from the source-relative path of each enumerated file and never consult anything else before writing. Everything a destination may want to veto therefore passes through exactly one point per implementation: the `listFiles`/`list_files` result the engine iterates. The existing `ExcludingFileSystem` already proves the pattern: filtering enumeration is sufficient to prevent the write, the read, and the summary entry for a file.

The exclusion filter belongs as a new decorator composed **outermost** (between `ExcludingFileSystem` and the engine), for three reasons:

1. It then sees the *effective* payload after hard exclusions, pack selection, memory scope, and memory mode. A manifest entry is judged against what would actually be written, which is what "stale entry" must mean.
2. It sits ahead of both merge decorators and the derive decorator by construction: a path dropped at enumeration never reaches `RoutingMergeFileSystem.writeTextFile` or `BlastRadiusDeriveFileSystem.writeTextFile`, so no merge, derivation, or destination read for that path occurs. This is the "exclusion applies ahead of merged paths" requirement in structural form.
3. Its `writeTextFile`/`write_text` can enforce the invariant "never overwrite an excluded path" as a hard guard (throw) rather than a skip, because after enumeration filtering the engine cannot legitimately ask to write such a path. This covers any future decorator that might synthesize a write.

The post-copy `.gitignore` delivery (`claude-customizations.ts:320`) bypasses the decorators and must consult the manifest separately (section 6.6).

## 2. Result Reporting Surfaces

| Surface | Current shape | Field for excluded paths and conflicts |
| --- | --- | --- |
| TypeScript run summary | `PushDownSummary` (`copilot-customizations-engine.ts:62-74`), shared by Copilot, Codex, and Claude entry points. | Claude entry point returns `ClaudePushDownSummary extends PushDownSummary` with optional `exclusions?: ExclusionReport`. Undefined when no manifest. |
| Summary artifact JSON | `PushDownSummaryPayload` (`:77-88`, Python `:48-60`): ten snake_case keys, sorted. Written to `artifactRoot`, which the service call sets to the destination root (`push-down-service-call.ts:185`). | Optional top-level `exclusions` object, present only when a manifest was read. Absent manifest leaves the key set unchanged, so the artifact stays byte-identical. |
| Service call result | `PushDownServiceCallResult` (`push-down-service-call.ts:36-41`): `tool`, `workspaceRoot`, `summary`, `artifacts`. `input.log` is declared (`:54`) but never invoked. | `RepoAutomationExecutionResult` already carries `warnings?: ReadonlyArray<string>` (`repo-automation-service-contract.ts:41`). Emit one warning line per skipped path, conflict, and unmatched entry; omit the field when empty. Invoke `input.log` for each line so the extension Output channel shows them. |
| MCP tool result | `RepoAutomationMcpToolResult.warnings` (`mcp-tools.ts:76`) is already spread from the execution result (`:137`). Tool schema `mcp-repo-automation-tool-definitions.ts:149-162`; input resolver `mcp-tool-inputs-push-down.ts:69-88`. | No schema change. `warnings` carries the report. |
| VS Code command | `repo-automation-command-registration-admin.ts:186-263` shows nothing on success; errors are appended to the output channel (`:254-260`). Service method `repo-automation-service.ts:202-207` -> `repo-automation-service-push-down.ts:150-168`. | Output-channel lines via the `log` sink (no new prompt). A `showWarningMessage` on conflicts is an open question (section 14). |
| Python CLI | `push_down_claude_customizations.py:398` prints one line. | Print one additional line per skipped path, conflict, and unmatched entry after the artifact line, only when a manifest was read. Exit code stays 0. |

## 3. Upstream Dependencies (#507, #508)

Verified absent on this branch: `docs/features/active/2026-09-29-*507*/**` and `*508*/**` match nothing (glob). The Python side has no `config` root, no routing merge, and no parity test.

Expected shape after the upstream children, by symbol name (inferred from the epic contract `docs/features/epics/push-down-payload-correctness/epic.md:49-64`, `:83-86` and the TypeScript precedent; exact names are the upstream children's decision):

- #507: Python `ROOT_FOLDERS == (Path(".claude"), Path("config"))`; a Python `RoutingMergeFileSystem` and `ROUTING_MERGE_RELATIVE_PATH` mirroring `claude-routing-merge.ts`; a Python/TypeScript parity test over published roots and merged paths.
- #508: the single merged path generalized into a data-addressable set (for example `MERGED_RELATIVE_PATHS` / a merge registry) in both languages, plus a `config/blast-radius.json` merge or extension point.

What in #621 depends on them:

| #621 element | Depends on | Reason |
| --- | --- | --- |
| Filter placement, manifest format, matcher, report shape, write guard, CLI/MCP/log surfaces | nothing upstream | The decorator is outermost and path-agnostic; it never inspects the merge registry. |
| Parity fixture excluding `config/orchestration-routing.json` in Python | #507 | Python does not publish `config/` today, so such an entry would be reported as unmatched in Python and skipped in TypeScript. |
| Extending "the parity test #507 introduces" (AC 5 wording in `issue.md:40`) | #507 | If the file does not exist when #621 starts, #621 creates the parity test itself (section 10). |
| Optional `handling` classification of a skipped path (`overwrite` / `merge` / `derive`) in the report | #508 | Requires the merge registry symbol in both languages. Recommended to omit from v1 (section 13); the skip rule is uniform regardless of handling. |

## 4. Existing Parity Tests and In-Memory Fakes

- Python in-memory fake: `RecordingFileSystem` in `tests/scripts/dev_tools/push_down_customizations_test_support.py:31-74` (and a duplicate in `test_push_down_claude_customizations.py:22-66`). Keyed by `Path`; `list_files` filters by `relative_to`.
- TypeScript in-memory fake: `InMemoryPushDownFileSystem` in `extensions/drm-copilot/test/lib/push-down/push-down.test-helpers.ts:43-143`, `buildInMemoryFileSystem` (`:152-165`), `fixedClock` (`:173-176`). Records `writtenPaths` and `ensuredDirs`.
- The TypeScript derive decorator takes an injectable `DirectoryLister` (`claude-blast-radius-derive.ts:76`, option `listEntries` in `claude-customizations.ts:223`) so in-memory destinations are scannable.
- Existing "parity" tests are byte-identity checks between committed copies, not cross-language behavior checks: `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py:33-56`, `test_blast_radius_config_parity.py`, and the TypeScript three-copy pin in `test/lib/push-down/claude-config-carriage.test.ts:84-108`. No Python test invokes the TypeScript engine or vice versa (search for `subprocess|node|jest|npm` across `test_push_down_claude_*.py` returned nothing).
- Precedent for jest reading repo-root fixtures: `test/lib/validate/orchestration-handoff-contract.test.ts:32` (`../../../../../tests/fixtures/orchestration-handoff/contract`) and `REPO_ROOT` in `test/lib/push-down/config-carriage.test-helpers.ts:44`. A shared corpus under `tests/fixtures/` can be consumed by both suites.
- The bundle mirror contract `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` requires every repo `.claude/**` file (except `settings.local.json` and agent memory) to exist byte-identically in the bundle. This has a direct design consequence: a manifest placed inside `.claude/` in this repository would be forced into the bundle and therefore into every destination (section 5.3).

How exclusion semantics enter parity coverage without temporary files: make the decision a pure function of data (`planExclusions(payloadRelativePaths, manifest, destinationExists)`), drive it in both languages from one JSON corpus in `tests/fixtures/push_down_exclusions/`, and exercise the composed pipeline with the two in-memory fakes above. No disk I/O beyond reading committed fixtures. Section 10 details this.

## 5. Candidate Approaches

### 5.1 Filter seam

| Option | Description | Assessment |
| --- | --- | --- |
| A. Outermost enumeration decorator with write guard (selected) | New decorator wraps `ExcludingFileSystem`; `listFiles` drops matches and records the report; `writeTextFile` throws on a matched or manifest path. | Same pattern as the four existing decorators; no engine change; sees the effective payload; structurally ahead of merges/derivation. |
| B. Narrow `publishedPaths` | Subtract matches from the pack-selection set. | Rejected: `publishedPaths` is `null` on the default publish-everything path (`claude-customizations.ts:183`), so there is no set to subtract from without changing the default path's behavior. |
| C. Engine-level filter | Add an `excludeRelativePath` predicate to both engines. | Rejected: the engines are shared with Copilot/Codex, and the Python engine is at 504 lines (section 8), over the cap already. |
| D. Write-time skip only | Let enumeration proceed; skip inside `writeTextFile`. | Rejected: the engine would still classify, read, and count the file (`copilot-customizations-engine.ts:387-424`) and the artifact would list it as created/overwritten, misreporting the run. |

### 5.2 Manifest format

| Option | Both languages parse with no new dependency? | Comments | Assessment |
| --- | --- | --- | --- |
| Line-oriented text (selected) | Yes (`str.splitlines` / `split(/\r?\n/)`). | Yes (`#` lines). | Hand-editable; comments let a destination record the reason and issue reference next to each entry, which is the TaskMaster use case. Parser is ~40 lines per language. |
| JSON | Yes. | No comments. | Rejected: the record's value is the documented rationale; JSON cannot carry it without an ad hoc `"comment"` convention. |
| YAML | Python yes (`PyYAML` in `pyproject.toml:19`); TypeScript no (`js-yaml` appears only as an `overrides` pin in `package.json:221`, not a dependency). | Yes. | Rejected: new runtime dependency on the TypeScript side (`.claude/rules/typescript.md` "Do not add new runtime dependencies unless explicitly approved"). |

### 5.3 Manifest location

Requirements: survives every push-down; never written, merged, or deleted by a push-down; readable by both implementations from the destination root.

| Option | Assessment |
| --- | --- |
| Repo-root dotfile, outside every published root (selected): `<destination>/.push-down-exclusions` | The engines enumerate only `sourceRoot/<root>` for `root in ROOT_FOLDERS` (`copilot-customizations-engine.ts:164-166`; Python `:172-174`). A root-level file is never enumerated, so even a bundled `.push-down-exclusions` at the bundle root could never be published (precedent: `pack-manifests/` and `.claude-variants/` are bundle-root siblings that are never published, pinned by `test_push_down_claude_resource_contracts.py:177-194`, `:211-224`). The name is push-down-generic so the Copilot and Codex publishers can adopt it later without a rename. |
| Inside `.claude/` with a never-write guard | Rejected: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` forces every repo `.claude/**` file into the bundle, and the bundle is the payload. Keeping the file out of the payload would require a new hard exclusion plus a bundle-contract exemption in two tests; the location would then depend on three guards staying aligned. |
| Inside `config/` | Rejected for the same reason once #507 publishes `config/` from Python; `config/` is a published root in TypeScript today. |

Defense in depth regardless of location: (a) both implementations assert at module load (and a unit test pins) that the manifest relative path contains no `/` and does not start with any `ROOT_FOLDERS` entry; (b) the decorator's write guard throws if any write targets the manifest path; (c) the gitignore delivery and artifact write do not target it by construction.

### 5.4 Path and glob semantics

Two glob implementations already exist in the tree with **different** `**` semantics:

- Python `scripts/dev_tools/_blast_radius_glob.py:74-118` translates `**` to `.*`, `*` to `[^/]*`, `?` to `[^/]`, everything else literal, full match (`:137`). It has a PowerShell mirror (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`, verified present) and a coverage rule `is_path_subsumed` (`:140-176`): exact match, listed-directory prefix (`entry.rstrip("/") + "/"`), or glob match.
- TypeScript `extensions/drm-copilot/src/lib/file-system.ts:166-207` (`compileGlob`) translates `**/` to `(?:.*/)?` (`:180-186`) and bare `**` to `.*`. For the pattern `**/foo`, Python matches `xfoo` and TypeScript does not. Reusing `compileGlob` would create exactly the parity divergence the issue warns about (`issue.md:48`).

No third-party matcher is available: `minimatch` is only an `overrides` version pin (`package.json:223`) and is not imported anywhere in `src/` (grep for `minimatch|picomatch|micromatch` returned nothing); Python has no `pathspec`/`wcmatch`.

Selected semantics (identical in both languages, ~40 lines each, corpus-tested):

1. Entries and candidates are destination-relative POSIX strings. Normalization of an entry: trim surrounding whitespace, convert `\` to `/`, strip a leading `./`, collapse repeated `/`.
2. Wildcard-free entry: matches when `candidate == entry` or `candidate.startswith(entry.rstrip("/") + "/")`. A trailing `/` is therefore optional and documents intent. This is the existing `is_path_subsumed` rule.
3. Wildcard entry (contains `*` or `?`): `**` matches any run including `/`; `*` matches any run excluding `/`; `?` matches one non-`/` character; all other characters are literal; the whole candidate must match. This is the existing `_glob_to_regex_text` rule. The TypeScript twin is a direct port into the new module, not a reuse of `compileGlob`.
4. Comparison is ordinal and case-sensitive. Payload paths carry the bundle's canonical case on every host, so an entry must use that case; Windows filesystem case-insensitivity does not enter because matching is on payload strings, not on disk lookups.
5. Precedence: first matching entry in file order is the one reported; later matches are not evaluated.

Globs are needed in v1 because the seeded test conditions name wildcard matching (`issue.md:54`) and because a destination that opted out of a whole capability (for example all agent memory) needs a prefix or `**` form.

### 5.5 Report and artifact

| Option | Assessment |
| --- | --- |
| Post-process the artifact in the Claude entry point (selected) | After the engine returns, when a manifest was read: read the artifact text through `fs`, parse, add `exclusions`, re-serialize with the engine's sorted-key rendering, write. TypeScript needs `stringifySorted` exported from the engine (an `export` keyword on `copilot-customizations-engine.ts:283`); Python uses `json.dumps(indent=2, sort_keys=True)` directly. Engines otherwise untouched; absent manifest performs no second write. |
| Engine hook (`summaryExtensions` parameter) | Cleaner, but the Python engine is at 504 lines and cannot take the ~15 lines without a prior extraction refactor of a Copilot-shared module. Rejected for this item; recorded as a follow-up candidate. |
| Separate exclusions artifact file | Rejected: splits the audit record; the MCP `artifacts` array would need a second entry and consumers would need to correlate two files. |

## 6. Behavior Semantics

### 6.1 Manifest read

- Path: `<destinationRoot>/.push-down-exclusions`. Read through the injected adapter (`fs.isFile` then `fs.readTextFile` / `read_text`) before any decorator is constructed and before the engine validates the destination.
- Absent: the filter decorator is not constructed at all. The engine receives the same object graph it receives today; the only added operation is one `isFile` probe. The artifact, CLI stdout, MCP result, and log output are unchanged.
- Present: parsed into an ordered entry list; malformed input fails fast (6.4).

### 6.2 Skip and report

For each effective payload path `p` (after the four existing filters):

- If some entry `e` matches `p`: `p` is not enumerated to the engine. Record `{relative_path: p, entry: e.normalized, line: e.line, destination_status: "present" | "absent"}` where `present` is `inner.isFile(destinationRoot/p)` at enumeration time.
- `destination_status == "present"` is the **conflict** case of AC 3: the destination holds a file at an excluded path, and the payload would have overwritten or merged it. Nothing is written; the file is untouched. The conflict is reported (artifact, warnings, CLI, log) and the run still succeeds with exit 0. Rationale: the manifest is the destination's statement that it owns that path; a present file is the expected steady state after the destination replaced the bundled content with its own. Failing the run would make every subsequent push-down fail for a destination that did exactly what the manifest is for.
- `destination_status == "absent"`: plain skip, reported.
- Entries that match no effective payload path are reported as `unmatched_entries` (stale or out-of-scope). Not an error: pack selection, memory mode, and bundle changes legitimately change the payload between runs.
- Nothing in v1 fails the push-down except a malformed manifest (6.4) and the write-guard violation (6.3), which cannot occur through the enumeration path.

### 6.3 Write guard

The decorator's `writeTextFile`/`write_text` throws `ExclusionViolationError` (TypeScript) / `ExclusionViolationError(RuntimeError)` (Python) when the destination-relative target matches a manifest entry or equals the manifest path. After enumeration filtering this branch is unreachable from the engine; it exists so the invariant "never overwrite an excluded path silently" holds against any future write source, and it is unit-tested directly.

### 6.4 Malformed manifest

Fail fast with `ExclusionManifestError` (TypeScript `Error` subclass with `path` and `line`; Python `ValueError` subclass, following `ManifestError` in `push_down_claude_pack_selection.py:78`) before any destination write. Conditions:

- The manifest path exists but is not a regular file (`isDir` true).
- Text is not decodable as UTF-8 (Python `read_text` raises `UnicodeDecodeError`; wrap with the specific error). TypeScript `readFileSync(path, "utf8")` substitutes replacement characters, so the TypeScript parser rejects U+FFFD in an entry. A leading BOM is stripped.
- An entry that, after normalization, is empty (for example `./`), absolute (leading `/` or `X:` drive prefix), or contains a `..` segment.
- An entry beginning with `!` (negation is not supported and must not be silently treated as a literal).
- An entry containing `[` or `]` (character classes are outside the vocabulary; the blast-radius rule treats them as literals, but for a manifest that would silently never match).
- An entry with a trailing `/` and a wildcard (ambiguous; reject).

A blank manifest (only comments or whitespace) is valid and equivalent to an absent manifest for filtering, but the report still records `manifest_path` and empty lists, so the artifact shows the manifest was consulted.

### 6.5 Interaction with merged paths and the blast-radius derivation

- `config/orchestration-routing.json` excluded: not enumerated; `RoutingMergeFileSystem.writeTextFile` never runs; the destination document is not read or modified. Reported as conflict when present.
- `config/blast-radius.json` excluded: not enumerated; `BlastRadiusDeriveFileSystem.writeTextFile` never runs; no destination scan (`collectDestinationObservations`) is performed. The derivation's inputs are the destination layout, not payload files, so excluding any *other* payload path cannot change a derived document. After #508 the same holds for the merge.
- `PAYLOAD_MODULES` (`claude-blast-radius-derive-core.ts:111-114`) declares `config: ["config/**"]`. A destination that excludes `config/` entirely receives no blast-radius document, so the claim is moot; a destination that excludes only the routing file still receives a derived map whose `config` module is a harmless over-claim. No change to the derivation is proposed.
- Directory exclusion of `config/` removes the destination-runtime parallel surface's inputs. That is the destination's deliberate choice; the report makes it visible.

### 6.6 Interaction with the gitignore delivery and the artifact

- `.gitignore` is not a payload file, but it is a destination write. To keep the rule "every destination write except the report itself honors the manifest", `deliverDestinationGitignore` consults the manifest: if `.gitignore` matches, the merge is skipped and reported (status `present`/`absent` as above). Python has no gitignore delivery today; the parity fixture must not include a `.gitignore` scenario until Python delivers it.
- The summary artifact under `artifacts/claude-customizations/` is the report and is explicitly not subject to the manifest; an entry matching it is reported as unmatched.

### 6.7 Stale-file pruning

None exists (section 1). Consequence for the TaskMaster case: adding `.claude/rules/quality-tiers.md` to the manifest stops future reintroduction; the file already present must be removed once by the destination. The first push-down after that removal reports a plain skip; a push-down before the removal reports a conflict. The manifest never causes a deletion.

### 6.8 Dangling references

Excluding a file that other pushed-down content references (for example a rule cited by an agent) is **not detected or reported in v1**. Detection would require scanning every published file's text for each excluded path string, which adds a full-payload read pass to every run with a manifest and produces false positives on prose mentions. The limitation is documented in the manifest format documentation. A cheap follow-up (substring scan of published text for excluded relative paths, reported as `referenced_by`) is recorded in section 14.

### 6.9 Pack selection and memory mode

The filter runs after the pack, scope, and memory-mode filters. An entry that matches only paths outside the selected packs is reported as unmatched for that run. `memory_mode: merge` excludes memories already present at the destination (`claude-filesystem-adapter.ts:233-239`) before the manifest is consulted; a manifest entry for such a memory is unmatched when the destination already has it.

## 7. Requirements Mapping

| AC (`issue.md:36-41`) | Design element | Files |
| --- | --- | --- |
| Documented format, location, semantics; location never written | Section 5.2-5.4; constants `EXCLUSION_MANIFEST_RELATIVE_PATH = ".push-down-exclusions"` in both languages; root-level assertion + write guard | New `claude-exclusion-manifest.ts`, new `push_down_exclusion_manifest.py`; README "Push-down customizations" section (`README.md:243-253`); feature `spec.md` |
| Both implementations skip and report every matched path | Outermost decorator; report in summary, artifact, warnings, CLI, log | New `claude-exclusion-filter.ts`, new `push_down_claude_exclusion_filter.py`; `claude-customizations.ts`; `push_down_claude_customizations.py`; `push-down-service-call.ts` |
| Present destination file never overwritten; conflict reported | `destination_status: present` + write guard | Same as above |
| Absent-manifest behavior byte-for-byte identical | Decorator not constructed when absent; optional artifact key; optional `warnings`; no extra CLI/log lines | Regression tests in both suites (section 10) |
| Parity test covers exclusion semantics | Shared corpus + pure `planExclusions` in both languages | `tests/fixtures/push_down_exclusions/*.json`; new pytest and jest parity tests |
| Malformed manifest fails fast | `ExclusionManifestError` before any write | Manifest modules + tests |

Proposed state model (both languages, pure data):

- `ExclusionEntry { raw, normalized, kind: exact | directory | glob, line }`
- `ExclusionManifest { path, entries }`
- `SkippedPath { relativePath, entry, line, destinationStatus: present | absent }`
- `ExclusionReport { manifestPath, entries, skipped, unmatchedEntries }` with derived counts rendered into the artifact as `skipped_count` and `conflict_count`.
- `ClaudePushDownSummary = PushDownSummary + exclusions?` (TypeScript `interface ... extends`; Python frozen dataclass subclass with `exclusions: ExclusionReport | None = None`).

Artifact key (present only with a manifest):

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

Warning/CLI line forms (identical text in both languages so the parity corpus can pin them):

- `push-down exclusion: skipped <path> (entry <normalized>, line <n>)`
- `push-down exclusion conflict: destination file present, not overwritten: <path> (entry <normalized>, line <n>)`
- `push-down exclusion: entry matched no payload path: <normalized> (line <n>)`

## 8. File-Size Headroom (500-line cap)

Line counts from a count-mode search over every line (`^`) at research time.

| File | Lines | Planned change | Headroom |
| --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 361 | +~45 (manifest read, decorator composition, gitignore check, summary extension) | adequate |
| `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` | 201 | +~20 (warnings, log lines) | adequate |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | 448 | `export` on `stringifySorted` only | adequate |
| `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` | 303 | none (do not add the decorator here; keep one decorator per module as the routing/derive precedent) | n/a |
| New `extensions/drm-copilot/src/lib/push-down/claude-exclusion-manifest.ts` | ~200 est. | parse, normalize, match, `planExclusions`, error class; pure | new |
| New `extensions/drm-copilot/src/lib/push-down/claude-exclusion-filter.ts` | ~180 est. | decorator, report assembly, artifact extension, warning rendering | new |
| `extensions/drm-copilot/jest.config.cjs` | per-file thresholds only (`:20-25`); push-down entries at `:238-265` | add entries for the two new modules and the changed modules | n/a |
| `scripts/dev_tools/push_down_claude_customizations.py` | 403 | +~50 (manifest read, composition, summary extension, CLI lines) | tight; move CLI line rendering into the filter module if needed |
| `scripts/dev_tools/push_down_claude_filesystem.py` | 472 | none (28 lines of headroom; decorator goes in a new module) | n/a |
| `scripts/dev_tools/push_down_copilot_customizations.py` | 504 | none | already over the cap; must not grow |
| New `scripts/dev_tools/push_down_exclusion_manifest.py` | ~220 est. | parse, normalize, match, `plan_exclusions`, error class; pure; may import `matches_glob` from `_blast_radius_glob.py:121` rather than re-implement | new |
| New `scripts/dev_tools/push_down_claude_exclusion_filter.py` | ~200 est. | decorator, report dataclasses, artifact extension, line rendering | new |

Observation for the planner: `push_down_copilot_customizations.py` is at 504 lines today, which exceeds the cap in `.claude/rules/general-code-change.md`. This item must not touch it; the pre-existing overage is a separate finding.

## 9. Constraints

- Pushed-down enforcement hooks gain no Python legs: the design adds no hook and no destination runtime component. The manifest is consumed only by the two push-down implementations at publish time. Nothing under `.claude/hooks/` or `.claude/lib/` changes, and `.claude/hooks/enforce-powershell-batch-budget.ps1` and its tests (#769) are untouched.
- No new dependency in either language. Parsing and matching are standard-library/regex only.
- Tier classification: `quality-tiers.yml` does not exist at the repository root (glob `**/quality-tiers*` returned only `.claude/rules/quality-tiers.md` and its bundle mirror plus two historical evidence files). The tier of the affected projects is therefore not machine-declared. The new modules are pure parsing/matching logic whose defects would silently revert destination decisions, which fits T2 (core) by the definitions in `.claude/rules/quality-tiers.md`; this document proceeds on the T2 obligations (property test density, no `any`) without asserting a classification the tree does not carry.
- Property-based testing libraries are absent: no `hypothesis` in `pyproject.toml` or any test import; no `fast-check` in `package.json` or `package-lock.json` (the string appears only in rule/skill prose). Section 10 proposes a compliant substitute already used in the repository.

## 10. Testing Implications

Policy: no temporary files; in-memory fakes; Arrange-Act-Assert; tests under `tests/` mirroring source.

Python (`tests/scripts/dev_tools/`):

- `test_push_down_exclusion_manifest.py`: parse (valid, empty, comments, CRLF, BOM, backslashes, `./` prefix, trailing `/`), each malformed condition raises `ExclusionManifestError` with path and line; matcher boundary matrix via `pytest.mark.parametrize` (exact, directory prefix with and without trailing slash, sibling-name non-match such as `.claude/rules/x` vs `.claude/rules/xy.md`, `*` not crossing `/`, `**` crossing, `?`); `plan_exclusions` first-match precedence and unmatched detection.
- `test_push_down_claude_exclusion_filter.py`: composed pipeline over `RecordingFileSystem`: skip absent, conflict present (destination bytes unchanged, `files` list excludes it, counts unchanged), stale entry, write guard raises, manifest path never written, artifact carries `exclusions`, CLI prints the lines, absent manifest leaves artifact key set at the existing ten keys and stdout at one line. Because the Python engine reads the wall clock (`push_down_copilot_customizations.py:357`), identity assertions compare everything except `started_at`/`finished_at`.
- Property-style coverage without `hypothesis`: seeded `random.Random` generation of path/pattern pairs with the seed printed on failure, following the precedent recorded in `pyproject.toml:108-111` for `test_parallel_mutation_protocol_properties.py`. Properties: (1) exact entry matches exactly one candidate; (2) directory entry with and without trailing `/` yields identical results; (3) `*` never matches a candidate segment containing `/`; (4) normalization is idempotent; (5) `plan_exclusions` output is a partition of the payload into kept and skipped.

TypeScript (`extensions/drm-copilot/test/lib/push-down/`):

- `claude-exclusion-manifest.test.ts` and `claude-exclusion-filter.test.ts` with `buildInMemoryFileSystem` and `fixedClock`; the deterministic clock allows full byte-identity assertions on the artifact for the absent-manifest case. A `layoutLister` (`config-carriage.test-helpers.ts`) fake covers the derive decorator when `config/blast-radius.json` is excluded (assert the lister is never called).
- Service-call and MCP tests (`push-down-service-call.test.ts`, `mcp-tools.push-down-claude.test.ts`): `warnings` present with the pinned line text when a manifest exists; field absent otherwise; `log` invoked per line.
- Seeded property-style cases: a small deterministic PRNG in test helpers (test code only) mirroring the Python properties, seed printed on failure.

Parity (both suites, one corpus):

- `tests/fixtures/push_down_exclusions/matcher-corpus.json`: `{pattern, candidate, expected}` triples.
- `tests/fixtures/push_down_exclusions/manifest-corpus.json`: `{text, expected_entries}` or `{text, expected_error_line}`.
- `tests/fixtures/push_down_exclusions/plan-corpus.json`: `{payload_paths, destination_present, manifest_text, expected_skipped, expected_unmatched, expected_warning_lines}` scenarios, including `config/orchestration-routing.json` (after #507) and `config/blast-radius.json`.
- Each corpus file also carries `manifest_relative_path`; each implementation asserts its constant equals it. A pytest parity module and a jest parity test both iterate the corpus, so a divergence in either implementation fails one suite. If the #507 parity test exists, extend it; otherwise create `test_push_down_claude_exclusion_parity.py` and `claude-exclusion-parity.test.ts`.

Coverage: add per-file `coverageThreshold` entries for the new and changed TypeScript modules (`jest.config.cjs:20-25` documents the per-file convention). Python coverage is measured over `scripts/dev_tools` globally (`pyproject.toml:118-120`).

## 11. Automation Feasibility

No human-interaction step is expected. Every design input was obtained from committed files; every proposed change is a code, test, fixture, or documentation edit; every verification is a toolchain run (Black/Ruff/Pyright/Pytest and Prettier/ESLint/TSC/Jest) plus the existing bundle-contract tests. The manifest is authored by the destination repository, not by this repository, so no destination edit is required to complete #621; the TaskMaster remediation (author `.push-down-exclusions`, delete the reintroduced rule once) is a downstream consumer action outside this item's acceptance criteria. No credentials, network services, or interactive prompts are involved. The one non-automatable decision is the open question on property-test library adoption (section 14), which the recommended seeded-RNG approach avoids.

## 12. Rejected Alternatives (summary)

- Narrowing `publishedPaths`, engine-level filtering, and write-time skipping (section 5.1).
- JSON or YAML manifest (5.2).
- Manifest inside `.claude/` or `config/` (5.3).
- Reusing `lib/file-system.ts` `compileGlob` or adding `minimatch`/`pathspec` (5.4).
- Engine `summaryExtensions` hook or a second artifact file (5.5).
- Failing the run on a conflict or on a stale entry (6.2).
- Dangling-reference detection in v1 (6.8).

## 13. Recommendation

Implement a destination-owned, line-oriented exclusion manifest at `<destination>/.push-down-exclusions`, consumed by an outermost enumeration-filter decorator in both push-down implementations.

1. Format: UTF-8 text; one entry per line; lines whose first non-blank character is `#` and blank lines are ignored; entries are destination-relative POSIX paths. Wildcard-free entries match exactly or as a directory prefix (trailing `/` optional). Wildcard entries use exactly `**`, `*`, `?` with the `_blast_radius_glob.py` semantics. Ordinal, case-sensitive. First matching entry wins. Anything outside this grammar (negation, character classes, absolute paths, `..`, empty entries, wildcard plus trailing `/`, undecodable text, manifest that is a directory) is a fail-fast `ExclusionManifestError` naming path and line, raised before any destination write.
2. Location: repository root of the destination, outside every published root; pinned by a load-time assertion, a unit test, and the decorator's write guard. The push-down never writes, merges, or deletes it.
3. Pipeline: read the manifest through the injected adapter before composing decorators. When absent, construct nothing new. When present, wrap `ExcludingFileSystem` in `ExclusionFilterFileSystem` (TypeScript `claude-exclusion-filter.ts`; Python `push_down_claude_exclusion_filter.py`) whose `listFiles` drops matches and records `{relative_path, entry, line, destination_status}` and whose `writeTextFile` throws on any matched or manifest path. The gitignore delivery consults the same manifest. Pure parsing, normalization, matching, and `planExclusions` live in `claude-exclusion-manifest.ts` / `push_down_exclusion_manifest.py` (Python may import `matches_glob` from `_blast_radius_glob.py`).
4. Semantics: matched paths are skipped; a matched path whose destination file exists is a conflict, reported and never overwritten, with exit 0; entries matching nothing are reported as unmatched; the run fails only on a malformed manifest. Merged paths and the blast-radius document are governed identically because the filter precedes every merge/derive decorator; no destination read or scan occurs for a skipped path.
5. Reporting: `ClaudePushDownSummary.exclusions` in the returned summary; an `exclusions` object appended to the artifact only when a manifest was read (post-processed in the Claude entry point; TypeScript exports the engine's `stringifySorted`); `warnings` on the service/MCP result and `log` lines to the extension output channel; additional CLI lines after the artifact line in Python. Absent manifest: no new key, no `warnings`, no lines.
6. Parity: one shared JSON corpus under `tests/fixtures/push_down_exclusions/` driving matcher, manifest, and plan tests in both suites, plus pinned constant and warning-line text. Property-style coverage via seeded RNG in both languages, following the repository's existing seeded-`random.Random` precedent, because neither `hypothesis` nor `fast-check` is installed.
7. Files: two new modules per language; `claude-customizations.ts`, `push-down-service-call.ts`, `push_down_claude_customizations.py` extended; `copilot-customizations-engine.ts` gains one `export`; no change to the Python engine (504 lines, over cap), `claude-filesystem-adapter.ts`, `push_down_claude_filesystem.py`, any hook, or any `#769` file; README push-down section and the feature `spec.md` document the format.

## 14. Open Questions

1. Should the VS Code command surface a `showWarningMessage` when `conflict_count > 0`, in addition to output-channel lines? The current command shows nothing on success (`repo-automation-command-registration-admin.ts:186-263`); adding a notification is a UI decision outside the parity contract.
2. Should a `--strict-exclusions` / `strict_exclusions` option make conflicts or unmatched entries fail the run (non-zero exit / thrown error) for CI-style destinations? Not required by the acceptance criteria; recommended as a follow-up if requested.
3. Property-based testing: adopt `hypothesis` and `fast-check` as dev dependencies (explicit approval required by `.claude/rules/python.md` and `.claude/rules/typescript.md`), or accept the seeded-RNG substitute already used in the repository? The recommendation assumes the substitute.
4. Dangling-reference reporting (section 6.8): defer, or include a substring scan of published text for excluded relative paths as a `referenced_by` field in a later version?
5. Report classification by handling (`overwrite`/`merge`/`derive`) once #508 lands a merge registry: worth adding to the report, or leave the report handling-agnostic permanently?
6. `push_down_copilot_customizations.py` is 504 lines, over the 500-line cap, before this item. Should the epic or a separate item extract `resolve_cli_path`/CLI wiring to restore headroom, which would also unlock the cleaner engine `summary_extensions` hook?
7. Should the Copilot and Codex publishers honor the same root-level manifest in a follow-up? The name and destination-relative entry model were chosen to allow it without a format change.

## Appendix: Search Records

- Upstream specs: glob `docs/features/active/2026-09-29-*50[78]*/**` -> no files.
- Tier file: glob `**/quality-tiers*` -> `.claude/rules/quality-tiers.md`, its bundle mirror, two evidence files; no `quality-tiers.yml`.
- Deletion/pruning: `unlink|rmSync|prune|\.remove\(|os\.remove|\.unlink\(|delete` over `src/lib/push-down` -> comments and `Set.delete` only; `unlink|rmtree|prune|os\.remove|\.unlink\(|delete` over `scripts/dev_tools/push_down_*.py` -> none.
- Glob libraries: `minimatch|picomatch|micromatch|globToRegExp|globToRegex` over `extensions/drm-copilot/src` -> none; `fnmatch|PurePath.*match|glob\.translate` over `scripts/dev_tools` -> `_blast_radius_glob.py`, `_blast_radius_extraction.py`, `parallel_drift_detection.py`, `discovery/analyzer/inventory.py`.
- Property libraries: `from hypothesis|import hypothesis` over `tests/` -> none; `fast-check` over `extensions/drm-copilot` (excluding `node_modules`) -> rule/skill prose and `package-lock.json` text only; `"node_modules/fast-check"` in `package-lock.json` -> none.
- Cross-language push-down tests: `subprocess|node |jest|npm` over `tests/scripts/dev_tools/test_push_down_claude_*.py` -> none.
- Line counts: count-mode search for `^` over `src/lib/push-down/*.ts`, `scripts/dev_tools/push_down_*.py`.
