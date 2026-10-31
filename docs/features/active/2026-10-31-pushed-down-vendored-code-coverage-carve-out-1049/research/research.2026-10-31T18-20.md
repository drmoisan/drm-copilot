# Research: Pushed-Down Vendored-Code Coverage Carve-Out (Issue #1049)

- Issue: #1049 (epic #1018 `shared-agent-harness-layer`, child 8, wave 3)
- Mode: preparation research; no code changes
- Tree read: epic integration branch `epic/shared-agent-harness-layer-integration`. Within the candidate surfaces, only `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` and the new `claude-blast-radius-overlay-demote.ts` differ from `origin/main` (orchestrator-verified). Facts that need `git` or `gh` are marked "orchestrator to confirm".

## Summary

- Today no push-down code writes a destination manifest or computes a hash. `extensions/drm-copilot/src/lib/push-down/` has no `createHash` or `sha256` reference. Child 4 (#1029) defines `.push-down-manifest.json` with SHA-256 per file, but that child has not executed.
- The pushed-down executable payload is PowerShell (`.ps1`, `.psm1`, `.psd1`) and bash (`.sh`) only. The three customization bundles contain no `.py`, `.ts`, `.js`, `.cjs`, `.mjs` or `.cs` file. TypeScript and Python coverage configurations in destinations are therefore not affected.
- Destinations measure PowerShell coverage with PoshQC. PoshQC is bundled with the extension (`extensions/drm-copilot/resources/powershell/PoshQC/`) and run against the destination through the `mcp__drm-copilot__run_poshqc_*` tools. It is not pushed into the destination. Its population comes from the destination's `config/poshqc-coverage.json` (`Resolve-PoshQCCoveragePopulation`, `Get-PoshQCCoverageFileSet`).
- Recommendation: keep child 4's manifest schema at `1.0.0` with no new fields. Make normative three items that child 4 leaves implicit: a byte-level hashing rule shared by TypeScript and PowerShell, tolerance of unknown fields within a major version, and the rule that the hash is taken over the final written bytes. Put the destination check and the exclusion derivation in a new PoshQC submodule. It runs at measurement time, behind an explicit boolean opt-in in `config/poshqc-coverage.json`, so no exclusion path is ever written by hand or committed.
- The rule change has one source under child 3 (`scripts/harness-generation/sources/rules/general-unit-test.md` plus `.json`). Child 3 generates the Claude rule, the Codex rule-skill and the Copilot instruction, with bundle copies, from that source. The new text must avoid the phrase `not used in this repository`, which `test_push_down_tier_rule_adoption_gate.py` forbids in every `general-unit-test` copy.

## Q1. Current Push-Down Writes, Hashing, and Payload Enumeration

- Writers. Every destination write goes through `PushDownFileSystem.writeTextFile` in `extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts` (`RealPushDownFileSystem`). It writes UTF-8 and converts CRLF and lone CR to LF (`content.replace(/\r\n/g, "\n").replace(/\r/g, "\n")`). `readTextFile` uses `fs.readFileSync(path, "utf8")`, which keeps a leading U+FEFF in the string. The callers are the three flows `copilot-customizations-engine.ts` (`pushDownCustomizations`, plus `writeSummaryArtifact`), `codex-agents-customizations.ts` and `claude-customizations.ts`. Writes to merged paths are shaped by `DESTINATION_WRITE_DECORATORS` (routing merge and blast-radius derive/overlay, for `config/*.json` only). The doc comment on `ROUTING_MERGE_RELATIVE_PATH` states that every other published file is a plain overwrite. The MCP entry points are in `push-down-service-call.ts` (`pushDownClaudeCustomizationsServiceCall`, `pushDownCodexAndAgentsCustomizationsServiceCall`, `pushDownCopilotCustomizationsServiceCall`).
- Manifest or hash today: none. A search for `createHash|sha256|manifest.json` under `src/lib/push-down/` returns no match. The only destination-root control file is `.push-down-exclusions` (`EXCLUSION_MANIFEST_RELATIVE_PATH`, `assertManifestPathIsRootLevel` in `claude-exclusion-manifest.ts`). Hash helpers exist elsewhere in `src/` (for example `discovery-input-manifest.ts`), but the push-down does not use them.
- Enumeration. Pack manifests (`{ name, label, paths, source_prefix? }`) are read by `claude-pack-selection.ts` (`loadPackManifests`, `computePublishedPaths`) and `codex-pack-selection.ts`. They live in `resources/claude-customizations/pack-manifests/` (core, csharp-legacy, csharp-modern, powershell, python, typescript) and `resources/codex-and-agents-customizations/pack-manifests/` (same set). Copilot has no pack manifests and publishes the whole `customizations/.github` tree. Codex adds the `VIRTUAL_RESOURCE_PAIRS` and `VIRTUAL_RESOURCE_DIRECTORIES` mappings (for example `lib/discovery-validation` to `.codex/lib/discovery-validation`).
- Claim confirmed. A glob for `extensions/drm-copilot/resources/**/*.Tests.ps1` returns no file. A wider glob for names containing `Tests`, `test` or `spec` returns only production files with "test" in the name (for example `check-powershell-test-purity.ps1`, `general-unit-test.md`, `pytest-unit-test-coding.toml`, `templates/run-poshqc-test.ps1`). It returns no test suite.
- Executable payload languages. Bundled roots contain `.ps1`, `.psm1`, `.psd1` and `.sh` (for example `.claude/lib/bash/*.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/*.sh`, `.codex/codex-web-setup.sh`). A glob for `.py`, `.ts`, `.js`, `.cjs`, `.mjs` and `.cs` under the three bundles returns no file.

## Q2. Child 4 Manifest Contract and the Minimal Delta

Child 4 contract (`docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md`, `### Destination Manifest` and `### Decision Table`):

| Item | Child 4 value |
| --- | --- |
| File and location | `.push-down-manifest.json` at the destination root, outside every published root, guarded like `EXCLUSION_MANIFEST_RELATIVE_PATH`; one file for all ecosystems; committed (O-11) |
| Encoding | UTF-8 without BOM, LF, sorted keys via `stringifySorted`; no timestamps, absolute paths, host or user names |
| Fields | `schema_version` (semver, initial `1.0.0`, unknown major rejected), `payload_version` (extension version), `selection` per ecosystem (`packs`, `csharp_variant`, `memory_mode`), `files.<posix path>.{layer, pack, sha256}` |
| Hash | lowercase hex SHA-256 of the UTF-8 bytes of the LF-normalized text, "exactly the text `PushDownFileSystem.writeTextFile` writes"; destination text is LF-normalized before hashing |
| Entries | `create`, `update`, `adopt`, `converged` record the payload hash. `conflict`, `deleted-locally` and `orphaned` keep the previous entry. `unmanaged-conflict` gets no entry unless overwritten. `merge` and `excluded` paths are never entries. |
| No-overwrite | decision table D/M/P: a destination hash differing from M and from P is `conflict` and is not written |
| Planned implementation (plan `plan.2026-10-30T18-37.md`, Phase 1) | `PD/push-down-destination-manifest.ts` (`DESTINATION_MANIFEST_RELATIVE_PATH`, `DESTINATION_MANIFEST_SCHEMA_VERSION`, `DestinationManifest`, `DestinationManifestEntry`, `hashPayloadText`, `parseDestinationManifest`, `readDestinationManifest`, `renderDestinationManifest`); `PD/push-down-plan-comparator.ts` (`classifyPayloadFile`); `PD/push-down-apply.ts` (writes the manifest); `PD/push-down-ecosystem-registry.ts` (root-level assertion); `PD` = `extensions/drm-copilot/src/lib/push-down` |

Fit with #1049. The fail-closed semantics follow from child 4 without schema change:

- A file written or adopted by the push-down and unchanged since is a `files` key whose hash matches. It is exempt.
- A destination edit gives hash(D) ≠ M. A `conflict` re-run keeps the old M, so the file stays non-exempt. It is in the denominator.
- A destination-added file, including a new `.claude/hooks/*.ps1` or an `unmanaged-conflict` file, has no entry. It is in the denominator.
- Merged JSON paths are never entries. They are not code.

Minimal delta (normative text plus tests; no new field; `schema_version` stays `1.0.0`):

1. Byte-level hash rule (see Q7), stated once and implemented identically in `hashPayloadText` and in PowerShell, pinned by a shared fixture corpus.
2. Hash-of-written-bytes invariant. For every `files` entry after an apply run, `sha256` equals the hash of the bytes now at that destination path. This covers `create`, `update`, adopted and converged entries. It is verified end to end with an in-memory destination. Child 4 states this in prose only.
3. Reader tolerance. Within a known major, a reader ignores unknown top-level and per-file fields. Additive fields bump the minor version. Child 4's planned `parseDestinationManifest` rejection list contains no unknown-key rejection, so this formalizes current intent. Children 9 and 10 depend on it.
4. Status vocabulary for consumers: `exempt` (listed, present, hash equal), `modified` (listed, present, hash differs), `missing` (listed, absent), `unlisted` (in the coverage population, not listed).

No ownership or vendored marker is needed. Every entry is push-down-written by construction, and exemption is decided by membership plus hash.

What children 9 (#1050) and 10 (#1051) need. Neither folder exists under `docs/features/active/` (a glob for `*1050*` and `*1051*` matched nothing). Scope is taken from the epic `## Scope`.

- Child 9 (copy-mode CI templates with hashes): `files` entries for copied workflow files under the same hash rule; the no-overwrite decision table, which already gives "never overwrite an existing workflow"; and room for additive fields such as a source ref or a copy/reference mode under item 3 (minor bump). Child 9 owns those fields. If child 9's destination CI must apply the exemption, it has to run PoshQC from a checkout of this repository at the pinned ref, because PoshQC is not in the destination tree.
- Child 10 (detect and validate MCP tools, TypeScript): `DESTINATION_MANIFEST_RELATIVE_PATH`, `parseDestinationManifest` and `hashPayloadText` from child 4, the status vocabulary in item 4, and the schema-version rule in item 3.

## Q3. Pushed-Down Coverage Rule Text

Files carrying the full `## Coverage Exclusion Policy` ("No production file may be excluded", "Permitted `exclude` entries", "Prohibited", "Enforcement ... Blocking"):

| File | Pushed down |
| --- | --- |
| `.claude/rules/general-unit-test.md` | yes, via its bundle copy |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` | Claude `core.json` lists `.claude/rules/general-unit-test.md` |
| `.agents/skills/general-unit-test/SKILL.md` | via its bundle copy |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` | bundled, but not in Codex `core.json`. It is published only on a no-`packs` run; child 4 O-12 closes the manifest gaps. |

Other related copies:

- `.github/instructions/general-unit-test.instructions.md` and its bundle copy under `resources/customizations/.github/instructions/` have no exclusion policy. Section `## 2. Coverage and Scenarios` only says to exclude test files. Copilot publishes the whole tree.
- The execution-environment brief states "No production file may be excluded from measurement." under `## Coverage and File-Size Gates` in six byte-identical copies: `.claude/`, `.agents/` and `.github/skills/execution-environment/SKILL.md` plus the three bundle copies. The Claude copy is in Claude `core.json` and the `.agents` copy in Codex `core.json`.
- `.claude/rules/quality-tiers.md` (and its bundle copy, in Claude `core.json`), `## Rationale (uniform coverage thresholds)`, says PowerShell and bash files "remain in the coverage denominator under the Coverage Exclusion Policy". That stays true because it defers to the policy, so no edit is required.

Under child 3 (#1028, plan `### Phase 3 — Path-Scoped Rules`, P3-T1 and P3-T3): the single source is `scripts/harness-generation/sources/rules/general-unit-test.md` with `general-unit-test.json`. `scripts/harness-generation/HarnessRuleGeneration.psm1` (`Get-HarnessRuleFileMap`) renders from it:

- `.claude/rules/general-unit-test.md` (`claudeUnconditional: true`);
- `.github/instructions/general-unit-test.instructions.md`, restricted to the H2 sections the source lists;
- `.agents/skills/general-unit-test/SKILL.md` (child 3 OQ-2 default);
- all bundle copies.

The brief is a shared skill: `.agents/skills/execution-environment/SKILL.md` is the source after child 3, and the `.claude` copy is generated. `.github/skills` is retired by child 6 (#1032, same wave 3). Orchestrator to confirm at execution which brief copies still exist.

## Q4. Feature-Review Blocking Rule

- The rule exists only as the `**Enforcement:**` sentence of the policy, in the four files in Q3.
- `.claude/agents/feature-review.md` `## Coverage Verification` checks thresholds from artifacts and does not mention exclusion entries.
- `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review/SKILL.md`, `.codex/agents/feature-reviewer*.toml`, `.github/agents/feature-review.agent.md` and `docs/features/templates/policy_audit/*.md` contain no exclusion check. A search for `exclu` returned none.
- No hook checks exclusion entries: `.claude/hooks/*feature-review*` has no match for `exclude`, `omit` or `coveragePathIgnore`.

Recognition design. Under the recommended design no exclusion path is written anywhere; the only configuration is a boolean opt-in. The enforcement sentence becomes:

1. Any hand-written `exclude`, `omit`, `coveragePathIgnorePatterns`, kcov `--exclude-path`, or omitted settings-file coverage path that matches a production source path stays Blocking.
2. The opt-in key is not an `exclude` entry. The reviewer verifies the per-run exemption report written by PoshQC (Q5) instead.
3. A branch diff that changes `.push-down-manifest.json` hashes without a push-down run (no `payload_version` change and no push-down summary) is Blocking, because it would turn a modified file into an exempt one.

## Q5. Destination Coverage Tooling and Output Format

| Language | Destination mechanism | Pushed-down files of this language | Scope |
| --- | --- | --- | --- |
| PowerShell | PoshQC (bundled, run via MCP; `.claude/rules/powershell.md` directs destinations to `mcp__drm-copilot__run_poshqc_test`). Population: `Resolve-PoshQCCoveragePopulation` with precedence custom settings `CodeCoverage.Path`, then `config/poshqc-coverage.json` (`version` 1, `roots`), then scan folders. `Get-PoshQCCoverageFileSet` gives root-relative forward-slash paths, ordinal sort, case-insensitive dedup. | all hooks and libs | in scope |
| bash | kcov through the destination's own tooling. This repository's `scripts/bash/shell-qc.sh` / `shell_qc_lib.sh` (`--include-pattern`, `--exclude-pattern`) is not bundled. | `.claude/lib/bash/*.sh`, skill scripts | deferred (owner question OQ-4) |
| TypeScript | Jest `collectCoverageFrom` / `coveragePathIgnorePatterns` | none | not applicable |
| Python | coverage.py `omit` / `--cov=<package>` | none | not applicable |

Recommended output:

- The primary output is a run-time subtraction inside PoshQC. When `config/poshqc-coverage.json` declares `"exempt_unchanged_push_down_files": true`, the population from the `config` source drops every path whose status is `exempt`. A boolean is used rather than a path so the opt-in cannot point at a hand-built list. Old PoshQC versions ignore the unknown key and exempt nothing, which is the fail-closed direction. `Get-PoshQCCoverageConfigRoot` does not reject unknown keys today, and the version stays 1.
- The secondary output is an exemption report, `artifacts/pester/vendored-coverage-exemptions.json`, next to `powershell-coverage.xml`. It holds sorted entries `{ path, status, manifest_sha256, actual_sha256 }` for the reviewer and for shards. No timestamps or absolute paths.
- Deferred: a plain newline list of exempt `.sh` paths for kcov `--exclude-path`, produced by the same function, if OQ-4 is answered "in scope".

## Q6. Language Classification and Registration

| Artifact | Runs where | Language | Rule clause |
| --- | --- | --- | --- |
| Manifest writer (`hashPayloadText`, apply step) | MCP server and extension host; child 4 owns it | TypeScript | (2) |
| Hash-parity Jest test over the shared corpus | CI | TypeScript test | tests of (2) |
| Check and derivation: new `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` plus bundle copy | invoked by MCP PoshQC tools against a destination; never copied into it | PowerShell | not TS or Python; clause (1) not triggered, because it is not pushed down (owner to confirm, OQ-1) |
| Rule text, brief text | pushed down | Markdown | not code |

Rejected alternative: a pushed-down module under `.claude/lib/vendored-coverage/`.

- It reaches Claude destinations only. `.codex/lib` is fed through the pinned `VIRTUAL_RESOURCE_*` declarations (child 4 O-6), and Copilot has no lib root.
- A destination could edit its own checker.
- It would need a second hashing implementation or an import from PoshQC, which destinations do not hold.
- It would add a `quality-tiers.yml` entry (QT008 otherwise), `core.json` and dependency-closure entries, and bundle contract tests. All of those are in the parallel-run blast radius.

Registrations under the recommendation:

- `quality-tiers.yml`: no change. `scripts/powershell/PoshQC` is already T3, so QT008 is not triggered.
- `config/poshqc-coverage.json`: no change here. The existing `scripts` root covers the new module. This repository does not opt in.
- PoshQC wiring:
  - add the submodule name to the sub-module list in `PoshQC.psm1`, next to `PoshQC.Coverage.psm1`;
  - export the public function in `FunctionsToExport` of `PoshQC.psd1` (a blast-radius file, now merged);
  - add both files to the hard-coded list in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (existing Python, extended in place).
- Pack manifests and dependency closure: no change, because PoshQC is not pushed down.
- Jest `coverageThreshold`: none, unless a TypeScript production file is added. The parity test is test-only. If child 10 later needs a shared status type in TypeScript, that file needs its own entry.
- PoshQC targets `PowerShellVersion = '5.1'` (Desktop and Core), so the hash uses `[System.Security.Cryptography.SHA256]::Create().ComputeHash([byte[]])`, not `HashData`.

## Q7. Hash-Equivalence Hazards and the Canonical Rule

| Hazard | Effect | Handling |
| --- | --- | --- |
| CRLF / lone CR (destination `core.autocrlf=true`, this repo `* text=auto eol=lf`) | bytes differ from what was written | normalize CRLF and lone CR to LF before hashing |
| BOM | Node `readFileSync(...,'utf8')` keeps U+FEFF, so the written bytes keep EF BB BF. PowerShell `Get-Content -Raw` and `ReadAllText` strip it. | hash raw bytes and do not strip a BOM. PowerShell must read with `[IO.File]::ReadAllBytes`. A ripgrep search for U+FEFF under `resources/` found nothing, but ripgrep's BOM sniffing makes that inconclusive. |
| Byte-level vs string-level normalization | CR and LF never occur inside UTF-8 multibyte sequences, so the two agree for valid UTF-8 | invalid UTF-8 in a destination edit gives a PowerShell mismatch: fail closed |
| Encoding change (`working-tree-encoding`, UTF-16) | mismatch | fail closed |
| File mode, executable bit | not part of the content | ignored |
| Path case | Windows `Test-Path` is case-insensitive | match manifest keys to population paths by ordinal equality on the POSIX relative path. A case-renamed file is not matched and stays in the denominator. |
| Symlink or reparse point at a listed path | content may come from elsewhere | treat as `modified` (not exempt) |

Canonical rule: `sha256 = lowercase-hex(SHA-256(N(bytes)))`, where `bytes` are the raw file bytes (TypeScript: the UTF-8 encoding of the text passed to `writeTextFile`) and `N` replaces each `0D 0A` pair, then each remaining `0D`, with `0A`. Nothing else is normalized.

Shared corpus. `tests/fixtures/push-down-manifest-hash/corpus.json` is committed JSON whose cases carry content as JSON string escapes (`\r\n`, `\r`, `﻿`, non-ASCII), so the `eol=lf` attribute cannot alter them, each with an expected digest. Both the Jest parity test and a Pester suite read the same file. No temporary files are created. Two cases anchor the digests independently: empty input `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` and `abc` `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`. Placement relative to the Jest root needs a check at planning: confirm whether existing Jest tests already read repository-root fixtures.

## Q8. Overlap

Parallel-run blast-radius files that #1049 touches (all merged to `main`, so overlap is sequencing only):

- `scripts/powershell/PoshQC/PoshQC.psd1`: edit.
- `.claude/skills/execution-environment/SKILL.md` and its copies: edit, because the PoshQC population fact and the "No production file may be excluded" sentence change.

Not touched: `pssa.settings.psd1`, `jest.config.cjs` (unless OQ-5 adds TypeScript), `core.json`, `file-size-baseline.json` (no PoshQC entry; new logic goes in a new module), the policy-audit templates (the rule carries the change; OQ-6), the two `test_push_down_*` contract tests (they run unchanged and are not edited), and the blast-radius overlay `.ts` files.

Child overlap is shown per file in the inventory table below. Child 1 (#1025): the parity matrix is not affected beyond child 3's `generated_from` entries for the rule; no new harness surface.

## Q9. Policy Authorization

- `.claude/skills/policy-compliance-order/SKILL.md` says "Do NOT modify policy documents under `.claude/rules/` or `.github/instructions/`". `CLAUDE.md` `## Policy Compliance Reading Order` calls those files the canonical policy source with "Do not modify them". The owner authorized editing the pushed-down coverage rules for this exception. The plan should cite that authorization (orchestrator to confirm the decision record and date) in a Phase 0 gate.
- Files needing the policy edit: the child 3 source `scripts/harness-generation/sources/rules/general-unit-test.md`. Its generated outputs are `.claude/rules/general-unit-test.md`, `.agents/skills/general-unit-test/SKILL.md`, `.github/instructions/general-unit-test.instructions.md` (only if the source lists the section for Copilot; OQ-3) and their bundle copies. If child 3 has not merged when #1049 executes, all four existing copies are edited by hand instead.
- The six brief copies are skill text, not policy files, but the brief maintenance rule requires them in the same change.
- This repository is not exempt, and the rule text must say so without the phrase `not used in this repository` (forbidden by `test_general_unit_test_copy_drops_repo_scope_phrase`) and without consuming-product names (`test_push_down_issue_824_follow_ups.py`, `CONSUMING_NAMES`). Proposed wording: "The repository that is the source of the pushed-down files measures and tests them; the exception does not apply there." Enforcement in this repository:
  - this repository's `config/poshqc-coverage.json` does not declare the opt-in;
  - `validateDestination` already refuses destination = source, so this repository has no root `.push-down-manifest.json`;
  - a Pester repo-gate case asserts both facts.

## Q10. Residual Risks and Open Points

- "Unchanged since": defined as hash equality with the current entry. `adopt` and `converged` entries are exempt because their content equals the upstream payload.
- Re-run over a modified file: child 4 reports `conflict` and keeps the old hash, so the file stays in the denominator until the destination deletes or reverts it and re-runs. `overwrite_unmanaged` does not apply to `conflict`. This is documented in the rule text.
- Orphaned entries (deselected pack, retired file) remain and match, so they stay exempt even when upstream no longer tests that version (OQ-2).
- Manifest tampering: a destination can edit `sha256` values to exempt a modified file. The mitigation is the review rule in Q4 item 3. PoshQC could additionally compare entries against its installed bundle when `payload_version` equals the installed version (deferred).
- Environment-specific regressions are no longer caught by recreated destination tests. The Linux hook-suite job (`poshqc / PowerShell hook suites (Linux)`) covers `tests/scripts/claude-hooks` and `codex-hooks` only. Libraries and Copilot hooks have Windows-only upstream runs. This remains a recorded residual risk.
- Activation latency: MCP runs the installed extension, so the exemption reaches destinations only after an extension release and reinstall.
- A custom Pester settings file with `CodeCoverage.Path` bypasses the config source today. The exemption does not apply there, and the hand list stays subject to the Blocking rule.

## Recommended Design

1. Manifest schema delta: none to fields; `schema_version` `1.0.0`. Normative additions to child 4's contract (Q2 items 1 to 4). Tests:
   - a Jest end-to-end invariant: after an apply run, each entry's `sha256` equals the canonical hash of the in-memory destination bytes;
   - Jest and Pester parity over the shared corpus.
2. Check and derivation contract in `PoshQC.VendoredCoverage.psm1`:
   - `Get-PoshQCVendoredCoverageStatus -Root <path> -CandidatePaths <string[]> [-ReadBytes <scriptblock>] [-TestPathExists <scriptblock>]` returns one record per manifest entry and per candidate (`exempt`, `modified`, `missing`, `unlisted`). Seams are injected, in the style of `Get-PoshQCCoverageConfigRoot`.
   - A malformed manifest, an unknown major, or an absolute, drive-letter, UNC or `..` path throws a message that names `.push-down-manifest.json`. With the opt-in set, `Invoke-PoshQCTest` fails the run (fail fast). An absent manifest with the opt-in set exempts nothing and logs one warning.
   - `Resolve-PoshQCCoveragePopulation` subtracts `exempt` paths only for the `config` source with the opt-in true.
   - `Invoke-PoshQCTest` writes `artifacts/pester/vendored-coverage-exemptions.json`.
   - MCP exit semantics are unchanged; the report file is the evidence, because PoshQC MCP results carry no output.
3. Exclusion-list output: run-time subtraction plus the JSON report. The kcov text list is deferred.
4. Rule text outline: a new paragraph **Vendored push-down files** inside `## Coverage Exclusion Policy`:
   - the three conditions: exact manifest path, canonical hash equal, derived by tooling at measurement time and never hand-written;
   - modified, unlisted and locally added files (for example a hook added under `.claude/hooks/`) stay in the denominator;
   - a modified copy is owned and tested locally;
   - recreated duplicate tests of unmodified pushed-down files may be removed;
   - the source repository is not exempt;
   - the revised **Enforcement** sentence (Q4).
5. Feature-review: the rule sentence is required. One added step in `.claude/agents/feature-review.md` `## Coverage Verification` (read the exemption report; flag hand-written production-path exclusions and hand-edited manifest hashes) is recommended, subject to OQ-6.
6. Destination documentation location: the pushed-down rule paragraph, which reaches the Claude, Codex and (per OQ-3) Copilot destinations, plus `scripts/powershell/PoshQC/README.md` and its bundle copy for the opt-in key and report format. No new pushed file, so no pack-manifest change.

## File Inventory

| Path | Change | Language | Overlap |
| --- | --- | --- | --- |
| `scripts/harness-generation/sources/rules/general-unit-test.md` (+ `.json` section list) | edit | Markdown/JSON | child 3 creates |
| `.claude/rules/general-unit-test.md`, `.agents/skills/general-unit-test/SKILL.md`, `.github/instructions/general-unit-test.instructions.md` + 3 bundle copies | regenerate | Markdown | child 3 generates |
| `.agents/skills/execution-environment/SKILL.md` and remaining brief copies | edit/regenerate | Markdown | child 3 (mirror), child 6 (retires `.github/skills`), parallel run (merged), child 4 also edits |
| `.claude/agents/feature-review.md` (OQ-6) | edit | Markdown | child 3 agent generator |
| `extensions/drm-copilot/src/lib/push-down/push-down-destination-manifest.ts` | doc-comment only, if any | TypeScript | child 4 creates |
| `extensions/drm-copilot/test/lib/push-down/push-down-hash-parity.test.ts`, manifest-invariant case | new | TypeScript test | child 4 test area |
| `tests/fixtures/push-down-manifest-hash/corpus.json` | new | JSON | none |
| `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` + bundle copy | new | PowerShell | none |
| `scripts/powershell/PoshQC/PoshQC.Coverage.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `README.md` + bundle copies | edit | PowerShell/Markdown | parallel run (`PoshQC.psd1`, merged) |
| `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.Tests.ps1`; cases in `PoshQC.CoverageConfig.Tests.ps1` and `PoshQC.Coverage.Tests.ps1` | new/edit | Pester | none |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | extend list in place | existing Python | none |
| `extensions/drm-copilot/CHANGELOG.md`, `README.md` | edit | Markdown | child 4 |

## Pre-Mortem

- Review checklists: a reviewer flags the rule edit as a policy-file modification, or flags the opt-in key as a production-path exclusion. Mitigation: cite the owner authorization in a Phase 0 gate record, and have the revised Enforcement sentence define the opt-in and report as the only permitted mechanism.
- Coverage: the new PoshQC submodule falls below 85% line coverage, or the subtraction path is untested for the `settings` and `fallback` sources. Mitigation: injected seams for bytes, existence and manifest text; one test per status and per population source; per-file figures read from `artifacts/pester/powershell-coverage.xml`.
- Mirror parity: a missed bundle copy of the PoshQC files, the rule, or one of the brief copies. Mitigation:
  - run `test_poshqc_bundled_parity.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_push_down_issue_824_follow_ups.py` and child 3's `-Surface rules -Check`;
  - make the brief-update task explicit in the plan.
- File size: `PoshQC.Coverage.psm1` and `PoshQC.Testing.psm1` grow. Mitigation: all new logic goes in `PoshQC.VendoredCoverage.psm1`, and edited files keep only call sites; measure each file before commit.
- Test isolation: the hash and corpus tests read disk or create files. Mitigation: committed corpus read once, injected `ReadBytes` seams, no temporary files; seeded shuffled Jest run and three-seed Pester shuffle recorded under `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: a CRLF fixture is normalized by `eol=lf`, paths are case-sensitive on Linux, and Windows PowerShell 5.1 lacks `SHA256.HashData`. Mitigation: escape-encoded corpus, ordinal POSIX path matching, the `SHA256.Create()` API, and no drive-letter fixtures.
- Evidence: PoshQC MCP results carry no output, so a plan that asserts exemption counts from an MCP call cannot be met. Mitigation: read the exemption report and the JUnit and coverage XML from branch-current `sh`-launched runs; evidence records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

## Numeric Derivation Evidence

- Complete Family: files carrying the full Coverage Exclusion Policy text, outside `docs/`.
- Exhaustive Search Scope: the whole worktree excluding `docs/**`.
- Inclusion Rules: the file contains the policy statement or its enforcement sentence.
- Exclusion Rules: research documents under `docs/`.
- Primary Search Strategy or Query Expression: ripgrep `No production file may be excluded|Permitted \`exclude\` entries`, keeping files that match the "Permitted" heading.
- Primary Member Set: `.claude/rules/general-unit-test.md`; its Claude bundle copy; `.agents/skills/general-unit-test/SKILL.md`; its Codex bundle copy.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: ripgrep `production source path|exclude.{0,40}Blocking|Blocking.{0,80}exclu` (case-insensitive) over the same scope.
- Cross-check Member Set: the same four paths.
- Cross-check Count: 4.
- Member-set Comparison: identical after normalization. The primary query also matched six execution-environment brief copies on the single sentence "No production file may be excluded from measurement". Those are recorded separately in Q3 and are not members of this family. No numeric acceptance criterion is proposed from this count.

## Owner Questions

- OQ-1: Accept the check and derivation inside PoshQC, which is extension-bundled and not pushed down, instead of a pushed-down module? Default: yes.
- OQ-2: Are `orphaned` manifest entries (retired or deselected files) still exempt? Default: yes while unchanged, with the residual risk recorded.
- OQ-3: Should child 3's Copilot target for `general-unit-test` include the Coverage Exclusion Policy section? Today the Copilot instruction has none. Default: yes.
- OQ-4: Is bash/kcov (exempt `.sh` list) in scope, or deferred to #1050's CI templates? Default: deferred.
- OQ-5: An invalid manifest with the opt-in set: fail the coverage run, or warn and exempt nothing? Default: fail with a message naming the file.
- OQ-6: Edit the feature-review agent and policy-audit templates in addition to the rule? Default: the agent's `## Coverage Verification` gets one step; the templates are unchanged.
- OQ-7: Should PoshQC also verify manifest hashes against its installed bundle when `payload_version` matches? Default: deferred.
