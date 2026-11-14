# 2026-10-31-push-down-ci-workflows-per-ecosystem-pack — Spec

- **Issue:** #1050
- **Parent (optional):** epic #1018 (shared agent-harness layer), child 9
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Ready for planning
- **Version:** 1.0
- **Design basis:** `research/research.2026-11-14T14-35.md` sections 2 to 9, Approach A

## Problem

The push-down ships rules, skills, agents, hooks and libraries per ecosystem pack but no CI; `extensions/drm-copilot/resources/` holds no workflow files. The harness assumes CI exists: the epic merge gate selects runs of the workflow named `CI`, S9 evaluates the checks on the PR head, and the feature-review coverage hooks read fixed artifact paths. A destination without matching CI makes those gates unsatisfiable or vacuous, and destinations that build their own CI drift from the names the harness expects.

No existing reusable workflow in `.github/workflows/` can be called from another repository: each runs paths that exist only in this repository (research 2.2). There is no .NET CI in this repository.

## Scope

1. New destination-generic reusable workflows in this repository: `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml` (input `variant`: `modern` or `legacy`). Each is triggered by `workflow_call` only.
2. A new resources bundle `extensions/drm-copilot/resources/ci-workflows/`: caller template, per-pack job fragments, the data file, and the opt-in branch-protection command.
3. A new TypeScript module under `extensions/drm-copilot/src/lib/push-down/` that renders the destination caller and contributes the CI files to #1029's `shared` layer.
4. A new optional push-down input `ci_workflows` on every push-down MCP tool.
5. One bullet added to every execution-environment brief copy naming the data file.
6. Documentation of the pin and bump process.

## Non-Goals

- No edit to any hook, to S9 (`.claude/skills/orchestrate/SKILL.md`), to `.claude/rules/ci-workflows.md`, or to any canonical policy file.
- No change to this repository's `ci.yml` or to any existing `_*.yml` workflow; no smoke job (AD-8).
- No shell (bats/kcov) pack (AD-8).
- No new manifest layer value and no manifest schema change; schema stays `1.0.0` (AD-3).
- No vendoring of PoshQC into destinations (AD-5).
- No `integration-needed` file and no detect or validate tool; those belong to #1051.
- No repository-settings change by the push-down; no MCP tool that writes rulesets.
- No YAML parser dependency; template checks are text-based.

## Superseded Scope

SUPERSEDED: partial — required-check data narrows to workflow CI plus context CI Required Gate; no per-pack list; merge-gate consumption by pinned contract test — evidence: ci.yml job ci-required-gate, scripts/ci/CiRequiredGate.psm1 Get-CiRequiredGateDecision, ruleset 15241672, enforce-epic-merge-gate-child-ci.ps1 Get-EpicMergeGateChildCiDecision.

Issue criterion 4 ("consumed by the merge gate and the brief") is met as follows: the merge gate consumes the data through a contract test that pins the template workflow name and gate context to the merge-gate literal `CI` and to the data file; the hooks are not edited. The brief consumes it through one added bullet.

## Behavior Semantics

### Enablement (`ci_workflows`)

| Value | Effect |
|---|---|
| `off` (default) | No CI file is planned. Previously delivered CI files are left in place and handled by #1029's `orphaned` rule. |
| `reference` | Caller and data file are delivered; caller jobs call this repository's `harness-<pack>.yml` at the pinned tag. |
| `copy` | Caller, data file, and the selected packs' reusable workflow copies `.github/workflows/drm-copilot-<pack>.yml` are delivered; caller jobs use the local copies. |

Omitted input: the recorded mode is reused, as #1029 O-5 does for packs. The mode is inferred from the manifest without a schema change: no entry for `.github/drm-copilot/ci-required-checks.json` means `off`; that entry plus at least one `drm-copilot-<pack>.yml` entry means `copy`; otherwise `reference`. A call without the input on a destination with no data-file entry plans exactly what it planned before this feature.

### Success

An apply run with CI enabled writes the caller `.github/workflows/drm-copilot-ci.yml`, the data file, and in copy mode the selected copies. Each is recorded in `.push-down-manifest.json` by #1029's writer with layer `shared`, the canonical SHA-256, and pack `core` (caller, data file) or the language pack name (copies). A second identical run reports every CI file `unchanged`. A dry run writes nothing, including the manifest.

### Selection

The caller holds one job per language pack in the union of `selection.<ecosystem>.packs` recorded in the manifest after the run, plus the inline gate job. `core` contributes only the gate job. A Python-only selection renders no PowerShell, TypeScript, or .NET job. `csharp-modern` and `csharp-legacy` (Copilot: `csharp` with its variant) render the .NET job with `variant: modern` or `variant: legacy`. When the union holds no language pack, the caller holds only the gate job.

### Failure Before Write

The run fails before any write when `ci_workflows` is not one of `off`, `reference`, `copy` (the error names the value), or when the union contains both C# variants (existing `assertSingleCsharpToolchain` semantics).

### Conflicts

- No CI file is ever written over an existing unmanaged file. An unmanaged differing file at a CI path is reported `unmanaged-conflict` and is not written, even with `overwrite_unmanaged: true`.
- A locally edited managed CI file is reported `conflict` and kept (#1029 decision table).
- Name collision: before planning, the top-level `name:` of every other `.github/workflows/*.yml` and `*.yaml` file is read. When one declares `CI` (quoted or unquoted), the caller is withheld and a warning starting with `push-down conflict:` names that file. The data file and any copy-mode copies are still delivered (copies trigger only on `workflow_call`). The check also runs in a dry run.
- No path under `.github/workflows/` other than the caller and the selected copies is ever written.

### Opt-in Branch Protection Command

`.github/drm-copilot/Set-CiRequiredChecks.ps1` is delivered with the CI files and never run by the push-down.

- Default is a dry run that prints the planned ruleset body and makes no write.
- `-Apply` creates a new ruleset on the default branch requiring the context read from the data file (`CI Required Gate`), through one `gh api --method POST repos/<owner>/<repo>/rulesets` call.
- It never edits or deletes an existing ruleset. When a ruleset with its name already exists, it reports that and makes no write.
- `SupportsShouldProcess` (`-WhatIf` makes no write); all `gh` calls go through an injectable `Invoke-GhExe` seam.

## Data File Schema

Path `.github/drm-copilot/ci-required-checks.json`, sorted-key LF JSON, constant per destination:

```json
{
  "required_contexts": ["CI Required Gate"],
  "schema_version": "1.0.0",
  "workflow": "CI",
  "workflow_file": ".github/workflows/drm-copilot-ci.yml"
}
```

Readers: the opt-in command, #1051's tools, and agents through the brief bullet. Additive fields bump the minor version.

## Template Contract

Caller `.github/workflows/drm-copilot-ci.yml`:

- `name: CI`.
- Triggers: `pull_request` on `main` and `"epic/**"`; `push` on `main`; `workflow_dispatch`; `merge_group`.
- Reference mode: `uses: drmoisan/drm-copilot/.github/workflows/harness-<pack>.yml@v<payload_version>`, where `payload_version` is #1029 D6. Copy mode: `uses: ./.github/workflows/drm-copilot-<pack>.yml`.
- Gate job id `ci-required-gate`, name `CI Required Gate`, `needs` every rendered pack job, `if: always()`, fails when any needed result is not `success`. It does not use `Invoke-CiRequiredGate.ps1`.

Reusable workflows (`harness-<pack>.yml` and their copies) use only destination-generic steps, contain no `NPM_TOKEN` text, pin Node `26.13.0` and Poetry `2.5.1` where used, and write:

| Pack | Artifact paths | Notes |
|---|---|---|
| Python | `artifacts/python/coverage.json`, `artifacts/python/lcov.info` | `--cov-report=lcov:artifacts/python/lcov.info` passed explicitly; threshold step is inline `pwsh` over `coverage.json` totals (line 85, branch 75 by default inputs), not `scripts.dev_tools.*` |
| PowerShell | `artifacts/pester/powershell-coverage.xml` (JaCoCo), `artifacts/pester/pester-junit.xml` | Reference mode loads PoshQC from a checkout of `job.workflow_repository` at `job.workflow_sha`; copy mode runs Pester 6 directly |
| TypeScript | `coverage/lcov.info` | Runs the npm scripts named in the TypeScript rule (`format`, `lint`, `typecheck`, `test:unit:coverage`) |
| .NET | `artifacts/csharp/coverage.xml` | JaCoCo form with `counter type="LINE"` and `counter type="BRANCH"`, the format read by `Get-JacocoRepoCoverage` and `Get-JacocoBranchCoverage` in `validate-feature-review-coverage-metrics.ps1`; an inline `pwsh` step converts the collected Cobertura totals. `modern` runs on `ubuntu-latest`; `legacy` (msbuild, vstest) on `windows-latest` |

Pin and bump: the pin is the release tag `v<payload_version>`. To bump, upgrade the extension and re-run the push-down; an unedited caller is reported `update` and rewritten. Residual risks: no tag ruleset protects tags from moving; a build without a published tag references a missing tag; a private source requires copy mode.

## Dependencies

To be re-confirmed at plan Phase 0 on the integration branch; a mismatch stops the plan.

- #1029 (`spec.md`, `plan.2026-10-30T18-37.md`): `PushDownLayer`, `LAYER_ROOT_FILES`, `buildSharedLayer`, `pushDownHarness`, `runPushDownPipeline`, `applyPushDownPlan`, `parseDestinationManifest` (the `layer` enum and whether `pack` is free text), `hashPayloadText`, `PUSH_DOWN_CONFLICT_LINE_PREFIX`, `assertSingleCsharpToolchain`, the O-5 reuse rule, `overwrite_unmanaged`, and D6 `payload_version`.
- #1049 (`spec.md` `## Destination Manifest Schema`): schema `1.0.0`, canonical hash, reader tolerance. The #1049 vendored-code exemption is unavailable in copy mode because PoshQC is not in the destination tree.
- #1028 (`spec.md`): the brief bullet is written to the `.agents` source and regenerated when #1028 has merged; otherwise every existing copy is edited directly.

## Language Classification

| Artifact | Language |
|---|---|
| `harness-*.yml`, caller template, per-pack fragments, copy-mode copies | YAML (inline steps in `pwsh` or the ecosystem tool) |
| `ci-required-checks.json` | JSON |
| Renderer, layer contribution, MCP input parsing, service call | TypeScript (MCP and extension code) |
| Jest unit and contract tests | TypeScript |
| `Set-CiRequiredChecks.ps1` and its Pester tests | PowerShell |
| Brief bullet, READMEs, CHANGELOG | Markdown |

No Python file is added or modified, and no hook is added or changed.

## Resolved Open Questions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 (OQ-2) | SUPERSEDED: partial (see `## Superseded Scope`). Data file holds `workflow` `CI` and `required_contexts` `["CI Required Gate"]`. Merge-gate consumption is a pinned contract test; hooks are not edited. The brief gains one bullet in every byte-identical copy (six at research time). | Main already requires only `CI Required Gate` (#1074/#1077; ruleset 15241672 confirmed read-only on 2026-11-14). S9 already evaluates every check. Editing byte-identical hook twins gains nothing once the literal is pinned. |
| AD-2 (OQ-1) | `ci_workflows` with `off`, `reference`, `copy`; default `off`; omitted reuses the recorded mode. | Default-on would change the published set for every existing call and break #1029's compatibility criteria. |
| AD-3 | One caller `drm-copilot-ci.yml` named `CI` with one job per selected language pack and an inline gate; new `harness-<pack>.yml` reusable workflows; existing `_*.yml` not reused; delivery in the `shared` layer, schema `1.0.0` unchanged. | One required context stays stable under selection changes; existing workflows run repository-specific paths; a new layer value breaks #1029 readers. |
| AD-4 (OQ-7) | Pin `v<payload_version>`; bump by upgrading the extension and re-running the push-down. | Ties CI to the extension release. Residual risk: tags are unprotected. |
| AD-5 (OQ-3) | Copy mode writes the selected copies, hashed by #1029's writer. PowerShell copy mode runs Pester 6 directly to `artifacts/pester/powershell-coverage.xml`; PoshQC is not vendored; the #1049 exemption is documented as unavailable in copy mode. | Keeps PoshQC out of destinations, consistent with #1049 OQ-1. |
| AD-6 (OQ-4) | .NET writes `artifacts/csharp/coverage.xml` in JaCoCo form (confirmed from the hook functions named above), converting in the workflow; legacy on `windows-latest`. | Matches the reader without a hook edit. |
| AD-7 (OQ-5) | Opt-in `Set-CiRequiredChecks.ps1`, dry run by default, `-Apply` creates a new ruleset, never edits one; ShouldProcess and an injectable `gh` seam. The push-down never changes settings. | Settings changes stay explicit and reviewable; follows the existing runbook pattern. |
| AD-8 (OQ-6) | Shell pack deferred; no smoke job in `ci.yml`. | No shell pack in the pack model; a smoke job changes the gate's `needs` and pinned tests. |
| Name collision | Another workflow named `CI` withholds the caller with a `push-down conflict:` warning; the data file is still delivered; no existing workflow is overwritten. | Two `CI` workflows make the child-CI run selection ambiguous; #1051 owns the resolution. |

## Acceptance Criteria

- [ ] S1: Every push-down MCP tool accepts `ci_workflows` with values `off`, `reference`, `copy` (default `off`). Any other value fails before any write with an error naming the value. A Jest test shows that a call without the input on a destination with no CI data-file entry plans no CI path.
- [ ] S2: With `ci_workflows` omitted, the mode inferred from the manifest (data-file entry and copy entries) is reused; Jest tests cover reuse of `reference` and `copy` and an explicit `off` that plans no CI file.
- [ ] S3: The rendered caller holds one job per language pack in the selection union plus the `CI Required Gate` job; Jest tests show a Python-only selection renders no PowerShell, TypeScript, or .NET job, a PowerShell-plus-TypeScript selection renders PowerShell and TypeScript jobs and no Python or .NET job, and `csharp-modern` versus `csharp-legacy` render `variant: modern` versus `variant: legacy`.
- [ ] S4: A selection union containing both C# variants fails before any write (Jest).
- [ ] S5: In reference mode each caller job uses `drmoisan/drm-copilot/.github/workflows/harness-<pack>.yml@v<payload_version>` with the run's `payload_version`, and no `drm-copilot-<pack>.yml` copy is planned (Jest).
- [ ] S6: In copy mode each caller job uses `./.github/workflows/drm-copilot-<pack>.yml`; only the selected packs' copies are written; the caller, data file, and copies each have a manifest entry with layer `shared` and the canonical hash of the written bytes; the manifest `schema_version` is `1.0.0` (Jest).
- [ ] S7: The data file is written with exactly the content in `## Data File Schema` in both enabled modes and when the caller is withheld (Jest).
- [ ] S8: A second identical apply run reports every CI file `unchanged`, and a dry run writes no file and no manifest (Jest).
- [ ] S9: An unmanaged differing file at a CI path is reported `unmanaged-conflict` and left unchanged, including with `overwrite_unmanaged: true`; an edited managed caller is reported `conflict` and left unchanged; no other path under `.github/workflows/` is written (Jest, in-memory file system).
- [ ] S10: When another destination workflow declares top-level `name: CI`, the caller is not written, the warnings contain a `push-down conflict:` line naming that file, and the data file is still delivered; the same warning appears in a dry run (Jest).
- [ ] S11: `harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, and `harness-dotnet.yml` exist, trigger only on `workflow_call`, reference no path specific to this repository (`scripts/`, `extensions/drm-copilot`, `packages/`), contain no `NPM_TOKEN` text, and write the artifact paths in `## Template Contract`; the .NET workflow writes JaCoCo `counter` elements and runs `legacy` on `windows-latest` (Jest text contract test).
- [ ] S12: A Jest contract test asserts that the caller `name: CI` equals the merge-gate literal in the bundled `enforce-epic-merge-gate-child-ci.ps1` and the data file `workflow`; that the gate job name equals the data file `required_contexts` entry; that the caller declares `"epic/**"` and `workflow_dispatch`; and that each pack's artifact path appears in the bundled `validate-feature-review-coverage-metrics.ps1`. A negative case with a diverging in-memory template makes the assertion fail.
- [ ] S13: Every execution-environment brief copy gains one bullet, after the "Refresh rule" bullet and outside the process-reduction ledger revert blocks, naming `.github/drm-copilot/ci-required-checks.json` as the source of the destination workflow name and required context; the brief byte-identity test, the brief CI-section test, and `ProcessReductionChain.Ledger.Tests.ps1` pass.
- [ ] S14: `Set-CiRequiredChecks.ps1` Pester tests with a mocked `Invoke-GhExe` show: the default run prints the ruleset body and issues no write; `-WhatIf` issues no write; `-Apply` issues one POST that creates a ruleset requiring `CI Required Gate` read from the data file; an existing ruleset with the same name produces no write; no PUT, PATCH, or DELETE is issued. Line coverage of the command is at least 85%. A Jest text test shows the new push-down modules contain no `gh` invocation.
- [ ] S15: `extensions/drm-copilot/README.md` and `CHANGELOG.md` document the pin, the bump process, the unprotected-tag and missing-tag risks, the copy-mode requirement for a private source, and the unavailability of the #1049 exemption in copy mode; `.github/workflows/README.md` lists the `harness-*.yml` workflows.
- [ ] S16: The branch diff adds or modifies no `.py` file, changes no file under `.claude/hooks/` or `.codex/hooks/`, and its new production code is TypeScript, PowerShell, YAML, or JSON.
- [ ] S17 (CI-dependent, orchestrator-owned): A rendered reference-mode caller for each language pack, dispatched once in a scratch destination, parses and completes, and its check list shows the pack's check and `CI Required Gate`; evidence is recorded under `evidence/` with clock-read timestamps.

## Issue-to-Spec Mapping

| Issue criterion | Spec criteria |
|---|---|
| 1. Pack template; selection writes only that pack's workflows | S3, S4, S5, S6, S11 |
| 2. Check names and artifact paths match; contract test fails on divergence | S11, S12, S17 |
| 3. Thin caller with pinned ref by default; copy mode records hashes | S1, S2, S5, S6 |
| 4. Required checks as data, consumed by merge gate and brief (SUPERSEDED: partial) | S7, S12, S13 |
| 5. Never overwrite; report each conflict | S8, S9, S10 |
| 6. Branch protection only by an explicit opt-in command | S14 |
| 7. No new Python; TypeScript push-down, PowerShell or bash helpers | S16 |
