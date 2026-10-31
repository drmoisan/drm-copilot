# 2026-10-31-pushed-down-vendored-code-coverage-carve-out — Spec

- **Issue:** #1049
- **Parent (optional):** epic #1018 `shared-agent-harness-layer`, child 8 (wave 3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft (preparation mode; planning only)
- **Version:** 0.2
- **Design input:** `research/research.2026-10-31T18-20.md` (sections `## Recommended Design` and `## Owner Questions`, adopted with their defaults)

## Overview

The push-down copies hooks, skills, agents, libraries and rules into destination repositories. It does not copy the Pester tests that cover them: `extensions/drm-copilot/resources/` contains no `*.Tests.ps1` file. The pushed-down rule `general-unit-test.md` states that no production file may be excluded from coverage, so a destination that enforces it must cover the pushed-down PowerShell files. At least one destination has recreated a Pester suite locally. Those recreated tests duplicate upstream coverage, drift on every push-down, and can fail for reasons unrelated to the destination's own code.

This feature adds a narrow vendored-code exception to the pushed-down coverage rule. A file is exempt only when its exact path is listed in the destination manifest written by the push-down and its content hash still matches. The exemption is derived by tooling at measurement time and is never hand-written. Modified, unlisted and destination-added files stay in the coverage denominator. This repository keeps its own tests and is not exempt.

The pushed-down executable payload is PowerShell (`.ps1`, `.psm1`, `.psd1`) and bash (`.sh`) only (research Q1). This feature covers PowerShell measured by PoshQC. The bash/kcov exemption is deferred (OQ-4).

## Owner Authorization

The owner explicitly authorized, on 2026-10-31 (the decision adding children 8 to 10 to epic #1018, conveyed in the epic-planner delegation for this child), editing the pushed-down coverage rules, meaning the `general-unit-test` rule source and its generated outputs and mirrors, for the vendored-code exception.

- This is a scoped exception to the `policy-compliance-order` skill constraint "Do NOT modify policy documents under `.claude/rules/` or `.github/instructions/`" and to the `CLAUDE.md` `## Policy Compliance Reading Order` statement "Do not modify them".
- The exception covers only the `## Coverage Exclusion Policy` section's new `Vendored push-down files` paragraph and its `**Enforcement:**` sentence, and the related execution-environment brief sentence "No production file may be excluded from measurement." No other policy text is in scope.
- This repository keeps its own tests and is not exempt from the coverage rule.
- The execution plan cites this authorization in its Phase 0 gate record.

## Behavior

1. The pushed-down coverage rule defines a vendored-code exception: a file written by the push-down and unchanged since may be excluded from the destination's coverage measurement, only by exact manifest path and canonical hash, never by a directory glob such as `.claude/**`.
2. The push-down records path and canonical content hash for every file it writes, in `.push-down-manifest.json` at the destination root (child 4 writer; this feature adds normative text and tests).
3. A destination check recomputes hashes and fails closed: a modified, missing or unlisted file is not exempt. A destination-added hook stays in the denominator.
4. The destination's coverage run derives the exemption from the manifest at run time behind a boolean opt-in; no exclusion path is written by hand or committed.
5. The rule paragraph and the PoshQC README document the ownership policy: pushed-down code is tested upstream, a modified copy is owned and tested locally, and recreated duplicate tests of unmodified pushed-down files may be removed.

## Destination Manifest Schema

This section is the normative manifest contract consumed by children 9 (#1050, copy mode with hashes) and 10 (#1051, manifest hash consistency validation). It restates no field definitions beyond what consumers need; the base contract is child 4's `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md`, sections `### Destination Manifest` and `### Decision Table`.

### Ownership

- Child 4 (#1029) owns the writer, in TypeScript: `extensions/drm-copilot/src/lib/push-down/push-down-destination-manifest.ts` (`DESTINATION_MANIFEST_RELATIVE_PATH`, `DESTINATION_MANIFEST_SCHEMA_VERSION`, `DestinationManifest`, `DestinationManifestEntry`, `hashPayloadText`, `parseDestinationManifest`, `readDestinationManifest`, `renderDestinationManifest`) and the apply step that writes it.
- #1049 adds normative text and tests only. It adds no field and does not change the writer's behavior beyond a doc comment, if any.

### File and Fields

- File: `.push-down-manifest.json` at the destination root, outside every published root, as defined by child 4.
- `schema_version`: `1.0.0` (child 4 contract). No new field is added; the version is unchanged.
- Fields: `schema_version`, `payload_version`, `selection`, and `files.<posix relative path>.{layer, pack, sha256}`, with the types and rules in child 4's `### Destination Manifest`.

### Canonical Hash Rule

- `sha256 = lowercase-hex(SHA-256(N(bytes)))`.
- `bytes` are the raw file bytes. On the writer side they are the UTF-8 encoding of the text passed to `PushDownFileSystem.writeTextFile`.
- `N` replaces each CR LF pair (`0D 0A`) with LF (`0A`), then each remaining CR (`0D`) with LF. Nothing else is normalized. A byte-order mark is not stripped.
- PowerShell implementations read with `[System.IO.File]::ReadAllBytes` (never `Get-Content -Raw` or `ReadAllText`, which strip a BOM) and hash with `[System.Security.Cryptography.SHA256]::Create().ComputeHash([byte[]])` so the code runs on Windows PowerShell 5.1.
- Invalid UTF-8, an encoding change, or a symlink or reparse point at a listed path yields a non-matching status (fail closed). File mode and the executable bit are not part of the hash.

### Hash-of-Written-Bytes Invariant

For every `files` entry after an apply run, `sha256` equals the canonical hash of the bytes now at that destination path. This holds for `create`, `update`, `adopt` and `converged` entries.

### Reader Tolerance and Versioning

- A reader rejects an unknown major version (child 4).
- Within a known major version, a reader ignores unknown top-level fields and unknown per-file fields.
- An additive field bumps the minor version. A field removal or semantic change bumps the major version.

### Path Rules

- Keys are POSIX relative paths (forward slashes) from the destination root.
- Matching between manifest keys and coverage-population paths is ordinal and case-sensitive. A case-renamed file does not match and stays in the denominator.
- A reader rejects an absolute path, a drive-letter path, a UNC path, or any `..` segment, with an error that names `.push-down-manifest.json`.

### Status Vocabulary

| Status | Definition | Exempt |
| --- | --- | --- |
| `exempt` | listed in `files`, present at the destination, a regular file (not a symlink or reparse point), and its canonical hash equals the entry's `sha256` | yes |
| `modified` | listed in `files`, present, and the canonical hash differs, or the path is a symlink or reparse point | no |
| `missing` | listed in `files` and absent at the destination | not applicable (nothing to measure) |
| `unlisted` | in the coverage population and not a key in `files` | no |

### Decision-Table Outcomes That Yield Entries

Per child 4 `### Destination Manifest` (entry maintenance) and `### Decision Table`: `create`, `update`, `adopt` and `converged` record the payload hash; `conflict`, `deleted-locally` and `orphaned` keep the previous entry; `unmanaged-conflict` creates no entry unless overwritten through `overwrite_unmanaged`; `merge` and `excluded` paths are never entries. Consequences for exemption:

- A destination edit followed by a re-run is a `conflict`; the old hash is kept, so the file reports `modified` until it is reverted or deleted and the push-down re-runs.
- An `orphaned` entry remains exempt while unchanged (OQ-2 default).
- Merged JSON paths are never entries and are not code.

### Downstream Dependencies

- Child 9 (#1050) depends on: the canonical hash rule, the hash-of-written-bytes invariant, the no-overwrite decision table (child 4), and the minor-bump rule for any additive field it introduces (for example a source ref or copy/reference mode, which child 9 owns). If child 9's destination CI applies the exemption, it runs PoshQC from a checkout of this repository at the pinned ref, because PoshQC is not in the destination tree.
- Child 10 (#1051) depends on: `DESTINATION_MANIFEST_RELATIVE_PATH`, `parseDestinationManifest` and `hashPayloadText` (child 4), the status vocabulary, the canonical hash rule, the path rules and the reader-tolerance rule.

## Destination Check and Derivation Contract

The check and derivation are PowerShell in a new PoshQC submodule, `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1`, with its bundle copy under `extensions/drm-copilot/resources/powershell/PoshQC/`. PoshQC is extension-bundled and runs against a destination through the `mcp__drm-copilot__run_poshqc_*` tools; it is not copied into the destination.

### Functions

- `Get-PoshQCVendoredCoverageStatus -Root <path> -CandidatePaths <string[]> [-ReadBytes <scriptblock>] [-TestPathExists <scriptblock>]` returns one record per manifest entry and per candidate path, each with `path`, `status` (`exempt`, `modified`, `missing`, `unlisted`), `manifest_sha256` and `actual_sha256`. The manifest is read through the `ReadBytes` seam. Seams are injected in the style of `Get-PoshQCCoverageConfigRoot` so tests use no disk and no temporary files.
- `Resolve-PoshQCCoveragePopulation` (existing, `PoshQC.Coverage.psm1`) subtracts paths with status `exempt` only when the population source is `config` and the opt-in is `true`. The `settings` (custom `CodeCoverage.Path`) and scan-folder fallback sources are not changed.
- `Invoke-PoshQCTest` (existing, `PoshQC.Testing.psm1`) writes the exemption report when the opt-in is `true`. New logic lives in `PoshQC.VendoredCoverage.psm1`; the existing files gain call sites only.
- Wiring: the submodule is added to the sub-module list in `PoshQC.psm1` next to `PoshQC.Coverage.psm1`, the public function is added to `FunctionsToExport` in `PoshQC.psd1`, and both new files are added to the hard-coded list in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

### Opt-In

- Key: `"exempt_unchanged_push_down_files": true` in the destination's `config/poshqc-coverage.json`. The file's `version` stays `1`.
- The key is a boolean, not a path, so it cannot point at a hand-built list. Older PoshQC versions ignore the unknown key and exempt nothing, which is the fail-closed direction.
- Absent or `false`: behavior is unchanged and no report is written.

### Fail-Closed Behaviors

- `modified` and `unlisted` files stay in the coverage population.
- A destination-added hook under `.claude/hooks/` has no manifest entry, reports `unlisted`, and stays covered.
- With the opt-in set, an invalid manifest (malformed JSON, unknown major version, or a rejected path per `### Path Rules`) fails the coverage run with a message that names `.push-down-manifest.json` (OQ-5 default).
- With the opt-in set and no manifest present, nothing is exempted and exactly one warning is logged.
- MCP exit semantics are unchanged. Because PoshQC MCP results carry no output, the report file is the evidence of what was exempted.

### Exemption Report

- Path: `artifacts/pester/vendored-coverage-exemptions.json`, next to `powershell-coverage.xml`.
- Content: entries `{ path, status, manifest_sha256, actual_sha256 }`, sorted ordinally by `path`; no timestamps, no absolute paths, no host or user names.

### This Repository

This repository does not opt in: its `config/poshqc-coverage.json` does not declare the key, and it has no root `.push-down-manifest.json` (`validateDestination` refuses destination equal to source). A Pester repo-gate test asserts both facts.

## Rule Change

### Rule Source

Edits go into child 3's rule source `scripts/harness-generation/sources/rules/general-unit-test.md` (and its `general-unit-test.json` section list), not into generated outputs. The generator (`HarnessRuleGeneration.psm1`, `Get-HarnessRuleFileMap`) renders `.claude/rules/general-unit-test.md`, `.agents/skills/general-unit-test/SKILL.md`, `.github/instructions/general-unit-test.instructions.md` (with the Coverage Exclusion Policy section included for Copilot, OQ-3 default) and their bundle copies. If child 3 has not merged at execution time, the Phase 0 gate stops for re-planning (see `## Dependencies and Execution Preconditions`).

### Text Outline

A new paragraph headed **Vendored push-down files** inside `## Coverage Exclusion Policy`:

- A file may be excluded from a destination's coverage measurement only when all three conditions hold: its exact path is a key in `.push-down-manifest.json`; its canonical hash equals the recorded `sha256`; and the exemption is derived by tooling at measurement time, never written by hand.
- Modified files, unlisted files and files the destination adds (for example a hook added under `.claude/hooks/`) stay in the denominator.
- A modified copy is owned and tested by the destination. After a `conflict` re-run it remains non-exempt until reverted or deleted and re-pushed.
- Recreated duplicate tests of unmodified pushed-down files may be removed.
- The repository that is the source of the pushed-down files measures and tests them; the exception does not apply there.

Revised **Enforcement** sentence, in substance:

- A hand-written `exclude`, `omit`, `coveragePathIgnorePatterns`, kcov `--exclude-path` entry, or omitted settings-file coverage path that matches a production source path remains a **Blocking** finding.
- The boolean opt-in is not an `exclude` entry. A manifest-derived run-time exemption is recognized, and the reviewer verifies it through the exemption report.
- A branch diff that changes `.push-down-manifest.json` hashes without a push-down run (no `payload_version` change and no push-down summary) is a **Blocking** finding.

### Text Constraints

- The text must not contain the phrase `not used in this repository` (`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, `test_general_unit_test_copy_drops_repo_scope_phrase`).
- The text must not contain consuming-product names (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, `CONSUMING_NAMES`).
- `.claude/rules/quality-tiers.md` `## Rationale (uniform coverage thresholds)` defers to the Coverage Exclusion Policy and is not edited.

### Execution-Environment Brief

The sentence "No production file may be excluded from measurement." under `## Coverage and File-Size Gates` is updated in every brief copy that exists at execution time (brief maintenance rule): the `.agents/skills/execution-environment/SKILL.md` source and its generated or mirrored `.claude` copy, any `.github/skills` copy not yet retired by child 6, and all bundle copies. The updated sentence references the vendored push-down exception. The PoshQC population fact in the brief is updated in the same change if it describes the population sources.

### Feature-Review

One step is added to `.claude/agents/feature-review.md` `## Coverage Verification` (or to child 3's agent source under `scripts/harness-generation/sources/agents/` if the generator owns that file): read `artifacts/pester/vendored-coverage-exemptions.json` when present, flag any hand-written production-path exclusion as Blocking, and flag hand-edited manifest hashes as Blocking. The policy-audit templates are unchanged (OQ-6 default).

### Destination Documentation

- The rule paragraph above, which reaches Claude, Codex and Copilot destinations.
- `scripts/powershell/PoshQC/README.md` and its bundle copy: the opt-in key, the status vocabulary, the report format, the ownership policy (pushed-down code is tested upstream; a modified copy is owned and tested locally), and the removal of recreated duplicate tests of unmodified pushed-down files.
- No new pushed-down file, so no pack-manifest change.

## Language Classification

Owner rule (epic `## Shared Design`, language directive refined 2026-10-30, summarized): avoid new Python; existing Python may be reused, called or extended in place only. Anything pushed down to destination repositories (skills, skill helpers, hooks, libs) is PowerShell or bash, never TypeScript or Python. TypeScript is only for MCP commands and extension commands. Every planned artifact is classified, and a case that cannot follow the rule is raised as an owner question.

| Artifact | Runs where | Language | Classification |
| --- | --- | --- | --- |
| Manifest writer (`hashPayloadText`, apply step) | MCP server and extension host; owned by child 4 | TypeScript | extension code (clause 2) |
| Hash-parity and manifest-invariant Jest tests | CI | TypeScript test | tests of extension code |
| `PoshQC.VendoredCoverage.psm1` and bundle copy | extension-bundled; invoked through MCP PoshQC tools against a destination; not copied into it | PowerShell | not pushed down (OQ-1 default) |
| Pester suites and repo-gate test | CI | PowerShell test | tests |
| `tests/fixtures/push-down-manifest-hash/corpus.json` | CI | JSON fixture | data |
| Rule source, generated rule outputs, brief, feature-review step, README | pushed down or documentation | Markdown | not code |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | CI | existing Python | extended in place only |

- No new Python file.
- No new TypeScript production file, so no Jest `coverageThreshold` entry is added. If a TypeScript production file is added (for example a shared status type for child 10), it requires its own `coverageThreshold` entry.
- `quality-tiers.yml`: no change; `scripts/powershell/PoshQC` is already classified.

## Dependencies and Execution Preconditions

- Depends on child 4 (#1029): the manifest writer, `push-down-destination-manifest.ts`, the apply step and the decision table, merged into the integration branch `epic/shared-agent-harness-layer-integration`.
- Depends on child 3 (#1028): the rule source `scripts/harness-generation/sources/rules/general-unit-test.md`, `HarnessRuleGeneration.psm1`, the `-Surface rules -Check` mode, and (if it generates `.claude/agents/feature-review.md`) the agent source, merged into the integration branch.
- Child 1 (#1025): its contracts are cited only for the parity-matrix `generated_from` entries that child 3 records for the rule. No new harness surface is added.
- Child 6 (#1032, same wave 3) may retire the `.github/skills` brief copies; the brief update applies to whichever copies exist at execution time.
- Execution begins only after the parallel run `bugs-1001-1002-1003-1006` has merged to `main` (it has) and after children 3 and 4 have merged into the integration branch.
- Phase 0 gate (owner decision E3): at execution time, re-check the merged outputs of children 1, 3 and 4 (the files, symbols and headings named in this spec, including `push-down-destination-manifest.ts` and its exported symbols, `HarnessRuleGeneration.psm1` and `Get-HarnessRuleFileMap`, the rule source pair, `### Destination Manifest` and `### Decision Table`) against current `origin/main` and the integration branch. Stop for re-planning when any named file, symbol or heading differs. The gate record also cites `## Owner Authorization`.

## Acceptance Criteria

- [ ] The `general-unit-test` rule source contains a **Vendored push-down files** paragraph inside `## Coverage Exclusion Policy` that permits exclusion only for an exact path listed in `.push-down-manifest.json` whose canonical hash matches, derived by tooling at measurement time, and every generated output and bundle copy matches the source (`-Surface rules -Check` exits 0).
- [ ] The rule text and every generated copy omit the phrase `not used in this repository` and every consuming-product name, and `test_push_down_tier_rule_adoption_gate.py` and `test_push_down_issue_824_follow_ups.py` pass unmodified.
- [ ] A Jest end-to-end test runs a child 4 apply against an in-memory destination and asserts that every `files` entry's `sha256` equals the canonical hash of the bytes written at that path, for `create`, `update`, `adopt` and `converged` entries.
- [ ] A Jest test and a Pester test read the same committed corpus `tests/fixtures/push-down-manifest-hash/corpus.json` (CRLF, lone CR, BOM, non-ASCII, empty and `abc` cases encoded as JSON escapes) and both produce the expected digest for every case, using no temporary files.
- [ ] Pester tests of `Get-PoshQCVendoredCoverageStatus` with injected seams show `exempt` only for a listed, present, hash-equal regular file, and `modified`, `missing` and `unlisted` for the corresponding inputs, including a case-renamed path and a symlink or reparse point.
- [ ] With the opt-in set, an invalid manifest (malformed JSON, unknown major version, absolute, drive-letter, UNC or `..` path) fails the coverage run with a message naming `.push-down-manifest.json`, and an absent manifest exempts nothing and logs one warning.
- [ ] `Resolve-PoshQCCoveragePopulation` subtracts `exempt` paths only for the `config` source with `exempt_unchanged_push_down_files` set to `true`, leaves the `settings` and fallback sources unchanged, and no exclusion path is written to any configuration file.
- [ ] A Pester case with a destination-added `.claude/hooks/*.ps1` file absent from the manifest shows the file reported `unlisted` and retained in the coverage population.
- [ ] `artifacts/pester/vendored-coverage-exemptions.json` is written when the opt-in is set, with entries sorted by path and no timestamps or absolute paths.
- [ ] The rule's **Enforcement** sentence keeps hand-written production-path exclusions Blocking, recognizes the manifest-derived run-time exemption verified through the exemption report, and makes hand-edited manifest hashes without a push-down run Blocking; `.claude/agents/feature-review.md` `## Coverage Verification` (or its generator source) contains the matching step.
- [ ] The rule paragraph and `scripts/powershell/PoshQC/README.md` (and its bundle copy) state that pushed-down code is tested upstream, that a modified copy is owned and tested locally, and that recreated duplicate tests of unmodified pushed-down files may be removed.
- [ ] A Pester repo-gate test asserts that this repository's `config/poshqc-coverage.json` does not declare `exempt_unchanged_push_down_files` and that the repository root has no `.push-down-manifest.json`.
- [ ] Every existing execution-environment brief copy carries the updated "No production file may be excluded from measurement." sentence and the copies are identical to their source or mirror.
- [ ] `test_poshqc_bundled_parity.py`, `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass, with the new PoshQC submodule and edited PoshQC files byte-equal to their bundle copies.
- [ ] Coverage shows no regression on changed lines, at least 85% line coverage for each changed PowerShell production file, and at least 85% line and 75% branch coverage for each changed TypeScript production file, read per file from the coverage reports.

## Owner Questions

Defaults are adopted provisionally; the plan proceeds on them unless the owner answers otherwise.

- **OQ-1.** Place the check and derivation inside PoshQC (extension-bundled, not pushed down) instead of a pushed-down module? Default adopted provisionally: yes.
- **OQ-2.** Do `orphaned` manifest entries (retired or deselected files) stay exempt? Default adopted provisionally: yes while unchanged, with the residual risk recorded.
- **OQ-3.** Does child 3's Copilot target for `general-unit-test` include the Coverage Exclusion Policy section? Default adopted provisionally: yes.
- **OQ-4.** Is the bash/kcov exempt `.sh` list in scope, or deferred to #1050's CI templates? Default adopted provisionally: deferred.
- **OQ-5.** With the opt-in set, does an invalid manifest fail the coverage run or warn and exempt nothing? Default adopted provisionally: fail with a message naming the file.
- **OQ-6.** Edit the feature-review agent and the policy-audit templates in addition to the rule? Default adopted provisionally: the agent's `## Coverage Verification` gets one step; the templates are unchanged.
- **OQ-7.** Should PoshQC also verify manifest hashes against its installed bundle when `payload_version` matches? Default adopted provisionally: deferred.

## Risks

- "Unchanged since" means hash equality with the current entry. `adopt` and `converged` entries are exempt because their content equals the upstream payload.
- A re-run over a modified file is a `conflict` that keeps the old hash; the file stays in the denominator until reverted or deleted and re-pushed. `overwrite_unmanaged` does not apply to `conflict`.
- `orphaned` entries remain and match, so they stay exempt even when upstream no longer tests that version (OQ-2).
- A destination can edit `sha256` values to exempt a modified file. The mitigation is the Blocking review rule for hand-edited hashes; bundle comparison is deferred (OQ-7).
- Environment-specific regressions in destinations are no longer caught by recreated local tests. The Linux hook-suite job covers `tests/scripts/claude-hooks` and `codex-hooks` only; libraries and Copilot hooks have Windows-only upstream runs.
- Activation latency: MCP runs the installed extension, so the exemption reaches destinations only after an extension release and reinstall.
- A custom Pester settings file with `CodeCoverage.Path` bypasses the `config` source; the exemption does not apply there, and a hand list there stays subject to the Blocking rule.
- Reviewers may read the rule edit as an unauthorized policy-file change or the opt-in key as an exclusion. Mitigation: `## Owner Authorization` cited in the Phase 0 gate, and the Enforcement sentence defines the opt-in and report as the only permitted mechanism.

## Non-Goals

- The bash/kcov exemption list (deferred per OQ-4).
- Any new Python file.
- Any change to this repository's coverage measurement, thresholds or opt-in state.
- New manifest fields or a `schema_version` change.
- A pushed-down checker module, pack-manifest changes, or edits to the policy-audit templates.
- Comparing manifest hashes against the installed bundle (OQ-7).

## Definition of Done

- [ ] Acceptance criteria mapped to tests or evidence under `<FEATURE>/evidence/`
- [ ] Toolchain loop passes (format, lint, type check, architecture, unit, contract, integration)
- [ ] Generated, mirror and bundle parity checks pass
- [ ] Owner question answers recorded or defaults confirmed

## Seeded Test Conditions (from potential)

- [x] Unit coverage areas: manifest generation (paths, hashes, ordering); the destination check (unchanged, modified, added, removed file); exclusion-list derivation.
- [x] Integration scenarios: push to a scratch destination, run its coverage configuration, modify one hook and confirm it re-enters the denominator.
- [ ] CLI/API examples
