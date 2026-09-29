# `2026-09-29-push-down-destination-exclusion-manifest` — User Story

- Issue: #621
- Epic: push-down-payload-correctness (#770)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-29T14-45
- Work Mode: full-feature
- Spec: `spec.md` (authoritative behavior; the acceptance criteria below are consistent with it and reference its AC numbers)

## Story Statement

- As a destination repository maintainer, I want to record in my repository which push-down paths I have deliberately excluded, so that a later push-down does not reintroduce content I opted out of and I do not have to re-apply the exclusion after every sync.
- As a destination repository maintainer, I want the push-down to tell me when it skipped an excluded path and when it found my own file at an excluded path, so that I can see that my exclusion decision was honored and keep the manifest current.
- As an orchestrating agent that runs the push-down through the MCP tool, I want the result to list skipped paths, conflicts, and unmatched entries in a fixed line format, so that I can report the destination's divergence from the bundled defaults without reading the destination filesystem.
- As a maintainer of the two push-down implementations, I want one shared corpus to drive exclusion semantics in both the Python and TypeScript test suites, so that a matcher or reporting divergence between the two languages fails a test instead of reaching a consumer.

## Problem / Why

The Claude push-down does not preserve a destination repository's prior, repository-specific exclusion decisions. Content that a destination explicitly opted out of during an earlier sync is reintroduced by a later push-down, and nothing records that the exclusion decision existed or that it should be respected.

Concrete instance (TaskMaster). In 2026-06, TaskMaster's `.claude/` governance was synced from a reference repository under the directive "keep current policy, adapt mechanism" (TaskMaster issue #178, PR #179). That sync deliberately excluded the reference repository's coverage model: `.claude/rules/quality-tiers.md`, the 85% line / 75% branch coverage floor, and the T1-T4 `quality-tiers.yml` tier-classification system. TaskMaster kept its own 80% line / 90% new-module policy. As of 2026-09, `.claude/rules/quality-tiers.md` is present in TaskMaster again. It asserts the 85%/75% floor and requires a `quality-tiers.yml` at the repository root, which TaskMaster does not have.

Impact:

- Two conflicting coverage floors are simultaneously presented as authoritative in the destination (`CLAUDE.md`: 80%/90%; `quality-tiers.md`: 85%/75%), with no signal to an agent about which one governs.
- The reintroduction is not visible at push-down time. The push-down does not check a destination's prior exclusion decisions before writing `.claude/rules/**`.
- Any destination that has made a deliberate, documented divergence from the bundled defaults can have that divergence reverted by the next push-down.

Evidence: found during the `bugs-638-644-647` parallel-orchestration run in TaskMaster (2026-09-01), reported independently by two execution children as a repository-level finding unrelated to their own item work.

## Personas & Scenarios

### Persona: Destination repository maintainer

- Who: owns a consumer repository (for example TaskMaster) that receives the Claude payload from this repository through the VS Code command, the MCP tool, or the Python CLI.
- Cares about: keeping a documented, repository-specific policy divergence intact across syncs; knowing at sync time when the payload and the local decision collide.
- Constraints: does not control the bundle contents or the push-down schedule; may not be the person who runs the push-down; edits only files in the destination repository.
- Goals: record an exclusion once, next to its rationale; see that record honored on every subsequent push-down; be told when a local file sits at an excluded path.
- Frustrations: an earlier exclusion decision existed only in an issue thread and a PR description, and the next push-down silently reverted it.

#### Scenario 1: Record an exclusion

1. The maintainer notices `.claude/rules/quality-tiers.md` has reappeared and conflicts with `CLAUDE.md`.
2. The maintainer creates `.push-down-exclusions` at the repository root:

   ```text
   # Coverage model kept local; see issue #178, PR #179.
   .claude/rules/quality-tiers.md
   # Agent memory is authored here, not pushed.
   .claude/agent-memory/**
   ```

3. The maintainer commits the file. No push-down step, flag, or configuration in the source repository is involved.
4. Expected outcome: the file is a durable record in the destination that survives every subsequent push-down because the push-down never writes, merges, or deletes it.

#### Scenario 2: See the exclusion honored

1. A push-down runs against the destination (any entry point).
2. The manifest is read before any write. `.claude/rules/quality-tiers.md` is still present in the destination from the earlier reintroduction.
3. Expected outcome: the push-down does not touch that file; the run succeeds; the output channel or CLI shows `push-down exclusion conflict: destination file present, not overwritten: .claude/rules/quality-tiers.md (entry .claude/rules/quality-tiers.md, line 2)`; the VS Code command shows a warning notification because one conflict was found; the summary artifact carries `exclusions.conflict_count: 1`.
4. The maintainer deletes the reintroduced file once. The next push-down reports `push-down exclusion: skipped .claude/rules/quality-tiers.md (entry .claude/rules/quality-tiers.md, line 2)` with no notification, because the file is now absent and only a plain skip occurred.

#### Scenario 3: See a stale entry reported

1. Some time later the bundle no longer ships agent memory under `.claude/agent-memory/`, or the run uses `memory_mode: skip`.
2. A push-down runs. The entry `.claude/agent-memory/**` matches nothing in the effective payload.
3. Expected outcome: the run succeeds and reports `push-down exclusion: entry matched no payload path: .claude/agent-memory/** (line 4)`. The maintainer can leave the entry in place or remove it; either way nothing fails.

#### Scenario 4: Malformed manifest

1. The maintainer adds a line `!.claude/rules/quality-tiers.md`, expecting negation.
2. A push-down runs.
3. Expected outcome: the run fails before any destination write with an error naming `.push-down-exclusions` and the line number, stating that `!` entries are not supported. No file in the destination is created or modified. The maintainer corrects the line and re-runs.

### Persona: Orchestrating agent reading MCP results

- Who: an automation session that invokes the push-down through the MCP tool as one step in a larger workflow and reports outcomes to its operator.
- Cares about: a machine-readable result; a stable line format; the ability to distinguish "nothing to report" from "the destination declared exclusions".
- Constraints: cannot inspect the destination filesystem directly during the run; must not treat a destination's deliberate divergence as an error.
- Goals: surface skipped paths, conflicts, and unmatched entries in its summary; continue the workflow when the run succeeded with exclusions.

#### Scenario 5: Read the MCP result

1. The agent calls the push-down MCP tool with the existing input shape. No new input field exists.
2. The destination has a manifest with one conflict and one unmatched entry.
3. Expected outcome: the result `warnings` array contains exactly two lines in the pinned format; the `artifacts` array still points at the single summary artifact, whose `exclusions` object lists the same information with counts; the tool result is a success.
4. On a destination without a manifest, the result has no `warnings` field and the artifact has no `exclusions` key, so the agent can detect "no manifest consulted" by the absence of the key.

### Persona: Maintainer of the two push-down implementations

- Who: a contributor to this repository responsible for keeping `scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/src/lib/push-down/*` in agreement.
- Cares about: identical matcher semantics, identical report shape, identical warning text; no temporary files in tests; the 500-line cap; coverage thresholds.
- Constraints: `hypothesis` and `fast-check` are not installed and no new dependency is approved; #507 and #508 are in flight in parallel and may rename seams.
- Goals: a single corpus that both suites execute, so any divergence fails a test; edit points expressed by symbol name so the plan survives the upstream merges.

#### Scenario 6: Extend the parity coverage

1. The maintainer adds a case to `tests/fixtures/push_down_exclusions/matcher-corpus.json` (for example `**/foo` against `xfoo`, expected `false`).
2. The maintainer runs `pytest` for the Python parity module and `jest` for the TypeScript parity test.
3. Expected outcome: both suites read the same file; if one implementation disagrees with the expected value, that suite fails and names the case; the corpus-count assertion in each suite guards against a suite silently iterating a stale copy.

#### Scenario 7: Verify absent-manifest identity

1. The maintainer runs the absent-manifest regression tests in both suites after any push-down change.
2. Expected outcome: the TypeScript artifact is byte-identical under `fixedClock`; the Python artifact has the pre-change key set and identical values apart from `started_at` and `finished_at`; stdout is the single existing line; no `warnings`, no `log` call, no notification.

## Acceptance Criteria

### Destination repository maintainer

- [ ] US-1 The README "Push-down customizations" section and `spec.md` document the manifest path `.push-down-exclusions` at the destination root, the comment and blank-line rules, the entry normalization, exact / directory-prefix / wildcard semantics, ordinal case-sensitive comparison, first-match precedence, the malformed-manifest conditions, and the dangling-reference limitation. Verified by reading both documents (spec AC-1).
- [ ] US-2 A manifest entry that matches a payload path absent at the destination results in the path not being written and a `push-down exclusion: skipped ...` line in the CLI output and output channel, in both implementations. Verified by the filter tests in both languages (spec AC-3, AC-22, AC-20).
- [ ] US-3 A manifest entry that matches a payload path present at the destination leaves the destination file byte-identical, emits the `push-down exclusion conflict: ...` line, sets `exclusions.conflict_count` accordingly, and the run completes successfully, in both implementations. Verified by the filter tests in both languages (spec AC-4).
- [ ] US-4 A manifest entry that matches no effective payload path emits the `push-down exclusion: entry matched no payload path: ...` line and does not fail the run, in both implementations. Verified by the filter tests in both languages (spec AC-5).
- [ ] US-5 A malformed manifest fails the run before any destination write with an error that names the manifest path and the line number, in both implementations. Verified by the parametrized manifest tests and the zero-writes filter test in both languages (spec AC-6).
- [ ] US-6 After any push-down, the manifest file is unchanged and is not among the written paths, in both implementations. Verified by the filter tests in both languages (spec AC-7, AC-8).
- [ ] US-7 The VS Code push-down command shows a warning notification when at least one conflict was found and shows none otherwise. Verified by the command-registration tests with a stubbed `showWarningMessage` (spec AC-21).
- [ ] US-8 A destination with no manifest sees no change in push-down behavior: no `exclusions` key, no warnings, no extra lines, no notification, in both implementations. Verified by the absent-manifest regression tests in both languages (spec AC-12, AC-13).
- [ ] US-9 Excluding `config/orchestration-routing.json` or `config/blast-radius.json` results in no merge, derivation, destination read, or layout scan for that path. Verified by the TypeScript filter tests with adapter spies and a failing-if-called `layoutLister` fake; the Python routing case is verified once #507 is present (spec AC-9, AC-10).
- [ ] US-10 Excluding `.gitignore` results in the gitignore delivery performing no write and the skip being reported. Verified by a TypeScript test (spec AC-11).

### Orchestrating agent reading MCP results

- [ ] US-11 The MCP push-down tool accepts the existing input shape with no new field, and its result carries `warnings` with one pinned-format line per skipped path, conflict, and unmatched entry when a manifest produced any. Verified by `mcp-tools.push-down-claude.test.ts` (spec AC-19).
- [ ] US-12 The `warnings` field is absent from the service and MCP results when no manifest was read or when the manifest produced nothing to report. Verified by `push-down-service-call.test.ts` and `mcp-tools.push-down-claude.test.ts` (spec AC-19).
- [ ] US-13 The summary artifact referenced by the result `artifacts` array carries an `exclusions` object with `conflict_count`, `entries`, `manifest_path`, `skipped`, `skipped_count`, and `unmatched_entries` when a manifest was read, and no such key otherwise, so the agent can distinguish "no manifest consulted" from "manifest consulted, nothing matched". Verified by artifact-content assertions in both filter test files (spec AC-17, AC-18).
- [ ] US-14 A run with conflicts or unmatched entries is reported as a success (exit code 0 / no thrown error), so the agent's workflow continues. Verified by the filter tests in both languages (spec AC-4, AC-5).
- [ ] US-15 The returned summary object carries `exclusions` (TypeScript `ClaudePushDownSummary.exclusions`; Python `exclusions` field) when a manifest was read and `undefined` / `None` otherwise. Verified by the filter tests in both languages (spec AC-17).

### Maintainer of the two implementations

- [ ] US-16 The shared corpus files `matcher-corpus.json`, `manifest-corpus.json`, and `plan-corpus.json` exist under `tests/fixtures/push_down_exclusions/`, each carrying `manifest_relative_path`, and both a pytest parity module and a jest parity test iterate every case with a corpus-count assertion. Verified by running both suites (spec AC-14).
- [ ] US-17 The corpus covers exact match, directory prefix with and without trailing `/`, sibling-name non-match, `*` not crossing `/`, `**` crossing `/`, `?`, first-match precedence, unmatched detection, and the pinned warning-line text. Verified by reading the corpus and by both parity tests passing (spec AC-15).
- [ ] US-18 Both implementations declare `EXCLUSION_MANIFEST_RELATIVE_PATH == ".push-down-exclusions"` and a unit test in each language asserts it is a root-level path outside every `ROOT_FOLDERS` entry. Verified by `test_push_down_exclusion_manifest.py` and `claude-exclusion-manifest.test.ts` (spec AC-2).
- [ ] US-19 Seeded property-style tests exist for the pure functions in both languages, using the repository's seeded-RNG precedent, printing the seed on failure, with no new dependency. Verified by test names in both manifest test files and by `git diff` of `pyproject.toml`, `package.json`, and `package-lock.json` (spec AC-16, AC-24).
- [ ] US-20 The exclusion filter is composed outermost, wrapping `ExcludingFileSystem`, in both entry points, so that entries matching only pack-excluded or memory-mode-excluded paths are reported as unmatched. Verified by a filter test in each language (spec AC-23).
- [ ] US-21 All tests introduced by this feature use in-memory fakes and committed fixtures only; no test creates a temporary file. Verified by review of the test files for `tempfile`, `mkdtemp`, `fs.mkdtemp`, `os.tmpdir`, and equivalents.
- [ ] US-22 No new or modified file exceeds 500 lines; `scripts/dev_tools/push_down_copilot_customizations.py`, `.claude/hooks/**`, `.claude/lib/**`, and the #769 file set are unchanged. Verified by a line count over the changed files and `git diff --stat main` (spec AC-24, AC-25).
- [ ] US-23 Line coverage >= 85% and branch coverage >= 75% for the new and changed TypeScript modules and for `scripts/dev_tools`, and the full toolchain plus the bundle-contract tests pass in a single pass. Verified by the coverage reports and toolchain output of both suites (spec AC-26, AC-27).

## Non-Goals

- Strict mode that fails the run on conflicts or unmatched entries (follow-up).
- Dangling-reference detection or reporting (documented limitation; follow-up candidate).
- Handling classification (`overwrite` / `merge` / `derive`) of skipped paths in the report.
- Any change to `scripts/dev_tools/push_down_copilot_customizations.py`.
- Honoring the manifest in the Copilot and Codex publishers (follow-up).
- Deleting or pruning destination files.
- Negation entries, character classes, or any glob vocabulary beyond `**`, `*`, `?`.
- A `.gitignore` delivery in Python.
- Any change to `.claude/hooks/**`, `.claude/lib/**`, or destination runtime components.
- Remediating the TaskMaster destination itself (authoring its manifest and removing the reintroduced rule).
