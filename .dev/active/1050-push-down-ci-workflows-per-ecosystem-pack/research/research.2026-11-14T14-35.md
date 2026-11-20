# Research: Push Down CI Workflows per Ecosystem Pack (Issue #1050)

- Issue: #1050 (epic #1018, child 9, wave 4)
- Branch: `feature/push-down-ci-workflows-per-ecosystem-pack-1050`
- Mode: preparation (research only; no code written)
- Timestamp: 2026-11-14T14-35 (fallback stamp supplied by the orchestrator; the researcher has no clock tool)
- Inputs read: this folder's `issue.md`, `spec.md`, `user-story.md`, `plan.2026-11-14T09-31.md` (all four are unfilled templates apart from the issue text); `docs/features/potential/promoted/2026-10-31-push-down-ci-workflows-per-ecosystem-pack.md`; `docs/features/epics/shared-agent-harness-layer/epic.md`; #1029 `spec.md` and `plan.2026-10-30T18-37.md`; #1049 `spec.md`; #1028 `spec.md`; the #1051 promoted record `docs/features/potential/promoted/2026-10-31-push-down-integration-mcp-tools-and-skill.md`.

All paths below are repository-relative. No line numbers or commit identifiers are cited.

## 1. Executive Summary

- No reusable workflow in `.github/workflows/` can be called from another repository as-is. Every heavy one checks out the caller's repository and then runs paths that exist only here (`scripts/powershell/PoshQC/PoshQC.psm1`, `scripts.dev_tools.*`, `scripts/bash/shell-qc.sh`, `extensions/drm-copilot`, the three npm manifests). Thin callers therefore need new, destination-oriented reusable workflows in this repository; the existing `_*.yml` files stay as they are.
- There is no .NET CI anywhere in `.github/workflows/`.
- The required-check surface is already small. `ci.yml` exposes one aggregate context, `CI Required Gate` (#1074/#1077). S9 already evaluates every check on the head rather than a required list. The epic-child merge gate keys on the workflow name `CI`, not on a list of contexts. The required-check data therefore reduces to one workflow name and one context per destination.
- #1029 (pipeline, `.push-down-manifest.json`) and #1049 (manifest contract) are not on this branch. `extensions/drm-copilot/src/lib/push-down/` has none of the #1029 modules, and no source file references `.push-down-manifest.json`. The plan must carry a Phase 0 gate that re-checks the #1029 symbols it plugs into.
- Recommended design: one rendered caller workflow named `CI` per destination, with one thin-caller job per selected language pack and an inline aggregate `CI Required Gate` job. It is delivered as an opt-in contribution to #1029's `shared` layer, uses no manifest schema change, and adds no hook edit.

## 2. Current State

### 2.1 `.github/workflows/ci.yml`

- Workflow `name: CI`. Triggers: `push` to `main` and `development`; `pull_request` to `main`, `development`, and `"epic/**"` (#1130); `workflow_dispatch`; `merge_group` (`checks_requested`). No path filters.
- Jobs: `changes` (`Change scope`, runs `scripts/ci/Invoke-CiChangeScope.ps1`, output `code`), `full-run-marker` (`CI full run`), `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`, `root-typescript-tests`, `npm-audit-gate` (`NPM Audit Gate`, calls `_npm-audit-gate.yml`, which the delegation list omitted), and `ci-required-gate` (`CI Required Gate`, `needs` every other job, `if: always()`, runs `scripts/ci/Invoke-CiRequiredGate.ps1` with `NEEDS_JSON: ${{ toJSON(needs) }}`).
- Every caller uses the same-repository form `uses: ./.github/workflows/<file>`.

### 2.2 Reusable workflows: inputs and repository-specific assumptions

| Workflow | `workflow_call` inputs | Outputs / secrets | Repository-specific content that breaks a cross-repository caller |
| --- | --- | --- | --- |
| `_quality-checks.yml` | `run-heavy` (boolean, default true) | none | Poetry 2.5.1 with an in-project venv; `poetry check --lock` plus a `poetry.lock` diff; `scripts.dev_tools.generate_codex_agent_variants --check`; `scripts.dev_tools.check_quality_tiers`; `scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`; Python matrix 3.11/3.12/3.13 with coverage on 3.13 only; Codecov upload |
| `_poshqc.yml` | `run-heavy` | none | Every job imports `${{ github.workspace }}/scripts/powershell/PoshQC/PoshQC.psm1`; the shard matrix `[1, 2, 3]`; `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` paths in the Linux job; artifact names `poshqc-test-results-shard-*`; `config/poshqc-scan.json` (`scanFolders`) is read by PoshQC from the checked-out root |
| `_root-typescript-tests.yml` | none | none | Closest to generic: `npm ci`, `npm run format:check`, `npm test` at the root with `package-lock.json`; Node pinned to `26.13.0`; OS matrix `windows-latest`, `ubuntu-latest` |
| `_shell-coverage.yml` | `run-heavy` | none | `bash scripts/bash/shell-qc.sh check` and `test --coverage`; kcov v43 built from source; artifacts `artifacts/pester/kcov/**` |
| `_drm-copilot-extension-tests.yml` | `run-heavy` | none | `npm --prefix extensions/drm-copilot ...` throughout |
| `_security-scan.yml` | `run-heavy` | none | Poetry export plus `safety check`; `continue-on-error: true` |
| `_build-check.yml` | `run-heavy` | none | `poetry build`, then `atomic-executor --help` and `scripts/bash/shell-qc.sh --help` |
| `_docs-validation.yml` | none | none | Requires `README.md` and `LICENSE`; warns on `docs/code-change.instructions.md` |
| `_npm-audit-gate.yml` | `audit-level` (string) | none | Hard-coded manifest matrix `"."`, `extensions/drm-copilot`, `packages/mcp-server` |

No reusable workflow declares `secrets:` or `outputs:`.

Cross-repository call semantics, checked against GitHub documentation on 2026-11-14 (pages "Reusing workflow configurations" and "Contexts"):

- The `github` context of a called workflow is the caller's. `actions/checkout` defaults to `github.repository`, so it checks out the destination, and every repository-relative script path above is absent there. This is an inference from the default input and needs a live confirmation.
- A private caller may use public or private reusable workflows. A private source needs its Actions **Access** policy set explicitly, and a public caller can use public workflows only.
- `job.workflow_repository`, `job.workflow_sha`, and `job.workflow_ref` identify the reusable workflow's own repository and commit inside a called job. A thin-caller job can therefore check out this repository at its own pinned commit (for example, to load PoshQC) without a second, duplicated ref input. The documentation states that these properties are unavailable on GitHub Enterprise Server.
- `jobs.<id>.if` accepts only the `github`, `needs`, `vars`, and `inputs` contexts, and `hashFiles` is unavailable there. A caller cannot skip a pack job based on whether files exist, so the caller must be rendered per selection.
- The documentation recommends a commit SHA as the safest pin; a tag or branch is also accepted.

Conclusion for question 1: no reusable workflow is callable cross-repository as-is. `_root-typescript-tests.yml` would run, but its check names and Node pin belong to this repository, and it depends on destination script names that match this repository's root `package.json`.

### 2.3 CI Required Gate and change scope

- `scripts/ci/CiRequiredGate.psm1` hard-codes job ids. `$script:CiRequiredGateSkippableJobs` is `full-run-marker`, `npm-audit-gate`, `root-typescript-tests`, and `$script:CiRequiredGateDocsOnlyRequiredJobs` holds eight ids. `ConvertFrom-CiRequiredGateNeedsJson` rejects a `needs` object that lacks `changes`, `docs-validation`, or any skippable id (`missing job: ...`). The module is not reusable for a destination with another job set. It is not pushed down: no pack manifest lists `scripts/ci/`.
- `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` (WG01 to WG05) pins the gate job's shape and `needs` set against `ci.yml`, using line-based regex rather than a YAML parser. That is a usable pattern for template contract tests.
- `Invoke-CiChangeScope.ps1` and `config/ci-docs-only-paths.json` (docs-only scope) are specific to this repository and are not pushed down.

Meaning of "required-check list emitted as data" after #1074: once the owner edits the ruleset, the single required context of this repository is `CI Required Gate`, per the brief's `## CI Shape and Required Checks`. A destination template that also ends in one aggregate job named `CI Required Gate` needs exactly one required context, whichever packs are selected. The data file is then constant per destination. It is not a per-pack list.

Recommendation: a single aggregate gate per destination, not a list of per-pack contexts. Reasons:

1. A per-pack list changes every time the selection changes, so branch protection would drift from the selection. One aggregate context does not.
2. A matrix job skipped at job level reports no expanded context, and a skipped reusable caller reports no nested contexts. The brief's "Skipped-check semantics" bullet records both. Listed per-job contexts can therefore stay pending forever, and the aggregate gate removes that failure class.
3. It matches this repository's direction (#1074) and the epic's superseded-work note for 1050 ("the required-check data becomes smaller").

The destination gate must not reuse `Invoke-CiRequiredGate.ps1`, which is specific to this repository and is not pushed down. An inline gate is enough: `needs:` lists the rendered pack jobs, `if: always()`, and one step fails when any needed result is not `success`. A test against `needs.*.result` for `failure`, `cancelled`, or `skipped` is the common form; its object-filter behavior needs a live check (see Unverified Facts). A destination has no change-scope job, so no result is accepted as `skipped`.

SUPERSEDED: partial — the required-check data narrows to one workflow name (`CI`) and one aggregate context (`CI Required Gate`) per destination. The per-pack required-context list is not needed, and S9 needs no data because it already evaluates every check on the head — evidence: `ci.yml` job `ci-required-gate`, `scripts/ci/CiRequiredGate.psm1` `Get-CiRequiredGateDecision`, `.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate` (step 2 queries every check), `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` parameter `RequireWorkflow`.

### 2.4 Consumers that hard-code check names or the workflow name

| Consumer | What it hard-codes | Pushed down? (pack manifest) | Change needed under the recommended design |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1` and its byte-identical `.codex/hooks/` twin, `Get-EpicMergeGateChildCiDecision` (stage 4 filters `workflowName -cne 'CI'`) | Workflow name `CI`; accepts only `pull_request` and the recorded `workflow_dispatch` run | Yes: Claude `core.json`, Codex `core.json` | None if the template's workflow is named `CI` and triggers on `pull_request` with `"epic/**"` and on `workflow_dispatch`. A contract test pins the template name to this literal. |
| `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | Nothing check-specific: reads `ci_gate.conclusion` and `ci_gate.head_sha` from the checkpoint and the live head through `gh pr view` | Yes (Claude `core.json`) | None |
| `.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate` | Queries every check (`gh pr checks --json bucket,name,state,link,workflow`); `-RequireWorkflow CI` for epic children; dispatch fallback `gh workflow run CI --ref <child branch>` | Yes (skills tree) | None. The fallback needs the destination `CI` workflow to declare `workflow_dispatch`. |
| `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | Workflow name supplied by the caller (`-RequireWorkflow`) | Yes (Claude `core.json`) | None |
| `## CI Shape and Required Checks` in the execution-environment brief | Jobs, contexts, and ruleset 15241672 of this repository; the 20-context list plus `CI Required Gate` | Yes. The six copies are listed in `_BRIEF_COPIES` of `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (three repository copies, three bundle copies) | Add one bullet saying that, in a destination, the push-down's data file names the workflow and required context and the bullets above describe the source repository. Do not edit the pinned bullets. |
| `.claude/rules/ci-workflows.md` `## Epic Integration-Branch Trigger` | Workflow name `CI` with `"epic/**"` | Yes (Claude `core.json`; Codex skill `.agents/skills/ci-workflows/SKILL.md`) | None. The template satisfies it. This is a canonical policy file, so it is not edited. |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Names `poshqc / PowerShell QC` jobs and cites the brief's CI section | Yes | None |

Tests that pin these consumers: `test_execution_environment_brief_contracts.py` (`test_brief_ci_section_names_jobs_and_required_contexts`, `_REQUIRED_CONTEXTS`, `test_brief_copies_are_byte_identical`); `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (S9 wording, `-RequireWorkflow CI`); `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci.Tests.ps1`; `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`; `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1`.

Where the data file is read from: no existing file. The recommended destination path is `.github/drm-copilot/ci-required-checks.json`, beside the workflow it describes and outside `config/` (whose `orchestration-routing.json` is a merged path). Readers: the opt-in branch-protection command (section 5), #1051's validate tool, and agents through the brief bullet. Enforcement hooks are not changed to read it (see `## Rejected alternatives`).

### 2.5 Pack model (#1029) and manifest contract (#1049)

State on this branch: the push-down is the pre-#1029 code. `extensions/drm-copilot/src/lib/push-down/` holds the separate Claude, Codex, and Copilot flows (`claude-customizations.ts`, `codex-agents-customizations.ts`, `copilot-customizations-engine.ts`, `push-down-service-call.ts`, and others), and no file references `.push-down-manifest.json`. The planned design that 1050 must plug into is taken from #1029 `spec.md` and `plan.2026-10-30T18-37.md`.

- Pack ids. Claude and Codex bundles each have `pack-manifests/{core,python,powershell,typescript,csharp-modern,csharp-legacy}.json`, in the format `{ name, label, paths, source_prefix? }`. `MANIFEST_PACK_NAMES` in `codex-pack-selection.ts` holds the same six. The public Codex input uses `csharp` plus `csharp_variant` (`PUBLIC_CSHARP_PACK_NAME`). #1029 adds Copilot manifests `{core,python,powershell,typescript,csharp}.json` under `resources/customizations/pack-manifests/` and a `shared.json` under `resources/codex-and-agents-customizations/pack-manifests/`.
- Option selection. The `packs` input on each MCP wrapper (Copilot gains it in #1029); `core` is always included; C# variants are mutually exclusive (`assertSingleCsharpToolchain`). O-5: an omitted `packs` reuses the selection recorded in the manifest, otherwise publishes the full tree. O-2: each wrapper selects exactly one ecosystem.
- Pipeline. `pushDownHarness` (`push-down-harness.ts`) builds the shared layer and then the selected layers through `push-down-ecosystem-registry.ts`. `runPushDownPipeline` (`push-down-pipeline.ts`) plans before any write, and the first layer to claim a path keeps it. `applyPushDownPlan` (`push-down-apply.ts`) writes. `PushDownLayer` (`push-down-layer.ts`) carries root folders, root-file pairs `[destination path, resources-relative source path]` (`LAYER_ROOT_FILES`), a rewrite function, merged paths, merged deliveries, and an owning-pack lookup. Root folders today: Claude `ROOT_FOLDERS` `[".claude", "config"]` (pinned by `test_push_down_claude_parity.py`, O-6), Codex `[".codex", ".agents"]` plus virtual roots, Copilot `COPILOT_ROOT_FOLDERS` (five `.github/<sub-root>` folders, which do not include `.github/workflows`).
- Decision table (#1029 `### Decision Table`): `create`, `update`, `unchanged`, `converged`, `adopt`, `conflict`, `unmanaged-conflict` (written only with `overwrite_unmanaged`), `deleted-locally`, and outside the comparator `merge`, `excluded`, `orphaned`. Conflict lines go to `warnings` with `PUSH_DOWN_CONFLICT_LINE_PREFIX` (`push-down conflict:`).
- Manifest (#1029 `### Destination Manifest`, normative for consumers per #1049 `## Destination Manifest Schema`): `.push-down-manifest.json` at the destination root; `schema_version` `1.0.0`; `payload_version`; `selection.<ecosystem>.{packs, csharp_variant?, memory_mode?}`; and `files.<posix path>.{layer, pack, sha256}`. `layer` is one of `shared`, `claude`, `codex`, `copilot`, and #1029 P1-T1's `parseDestinationManifest` rejects any other value. The hash is lowercase hex SHA-256 of CR LF and lone CR normalized to LF, with no BOM stripping. The manifest is written by the apply step and never by a dry run. Readers ignore unknown fields within a major version, and an additive field bumps the minor version (#1049 `### Reader Tolerance and Versioning`). #1049 names 1050 explicitly: copy mode relies on the canonical hash rule and the hash-of-written-bytes invariant, and "if child 9's destination CI applies the exemption, it runs PoshQC from a checkout of this repository at the pinned ref, because PoshQC is not in the destination tree".
- #1049 status: its preflight halted on unrelated local defects. Its manifest section is treated as the contract, as instructed.

Implication: a new layer value (for example `ci`) would make every #1029 reader reject the manifest. That is a breaking change, so CI files must travel in an existing layer.

### 2.6 Toolchain artifact paths a template must match

| Pack | Path expected by pushed-down consumers | Source |
| --- | --- | --- |
| Python | `artifacts/python/lcov.info` (LCOV); `artifacts/python/coverage.json` (CI threshold report, brief) | `validate-feature-review-coverage-metrics.ps1` `Get-LanguageRepoCoverage`/`Get-LanguageBranchCoverage`; `validate-feature-review-coverage-freshness.ps1`; `.claude/agents/feature-review.md` coverage table; `.claude/skills/feature-review-workflow/SKILL.md`; `_quality-checks.yml`. This repository gets the LCOV report through `pyproject.toml` `addopts`, which a destination lacks, so the template must pass `--cov-report=lcov:artifacts/python/lcov.info` explicitly |
| PowerShell | `artifacts/pester/powershell-coverage.xml` (JaCoCo; `//counter[@type="LINE"]`), `artifacts/pester/pester-junit.xml` | same hook functions; brief `## PowerShell Route and PoshQC MCP Limits` |
| TypeScript | `coverage/lcov.info`; scripts `npm run format`, `lint`, `typecheck`, `test:unit`, `test:unit:coverage` | same hook functions; `.claude/rules/typescript.md` |
| C# | `artifacts/csharp/coverage.xml`, read as JaCoCo (`counter type="LINE"`) | same hook functions. Conflict: `.claude/rules/csharp.md` prescribes `dotnet test --collect:"XPlat Code Coverage"`, which writes Cobertura under `TestResults/<guid>/`, a different format and path. The legacy variant (`.claude-variants/csharp-legacy/rules/csharp.md`) uses msbuild and vstest, which run on Windows only |
| Shell | `artifacts/pester/kcov` | `.claude/rules/shell.md`. No shell pack exists in the pack model, and #1049 OQ-4 deferred the bash exemption to 1050 |

Contract-test pattern: a Jest test reads the bundled templates and the bundled consumer texts (`resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.../enforce-epic-merge-gate-child-ci.ps1`, `.../agents/feature-review.md`). It asserts that each template's artifact path and command token appears in the consumer for that language, and that the caller's `name: CI`, its `"epic/**"` and `workflow_dispatch` triggers, and the gate name `CI Required Gate` match the hook literal and the data file. The line-based style of `CiRequiredGateWorkflow.Tests.ps1` and `test_quality_checks_workflow_contracts.py` applies. No YAML parser exists in the TypeScript dependencies (none in the root, extension, or MCP `package.json`), so the checks are text-based unless the owner approves a dependency.

### 2.7 Overwrite and reporting behavior

- Today (pre-#1029) a differing destination file is overwritten and classified `overwritten`. After #1029, a file with no manifest entry that differs is `unmanaged-conflict`, is not written by default, and is reported in `push_down_report` and in `warnings`. A locally edited managed file is `conflict` and keeps its previous hash.
- A path collision is not the main CI risk, because the template uses its own file name (`drm-copilot-ci.yml`). The risk is a name collision: a destination workflow already named `CI`. The child-CI helper picks the newest run whose `workflowName` is `CI`, so two such workflows make its selection ambiguous. #1029's decision table cannot detect this, because the paths differ.
- #1051 seam: #1051 owns the `integration-needed` file ("an existing `ci.yml`, a different version matrix, a missing required check") and the detect and validate tools that read "the required-check data and templates (#1050)". 1050 should not write `integration-needed`. It should report a name collision as a conflict warning, withhold the caller, and leave the decision to #1051.
- Existing opt-in pattern for repository settings: owner-run runbooks with a read-only GET, a saved backup, an explicit `gh api --method PUT`, verification, and rollback (`docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/runbook/ruleset-single-required-gate.md`; `docs/features/archive/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`). No code path in this repository writes a ruleset.

### 2.8 Upstream generator dependency (#1028)

- #1028 makes `.agents/skills/<name>/` the source and `.claude/skills/<name>/` a generated mirror (`scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check`). After #1028, an edit to the brief goes into the `.agents` source and is regenerated. #1032 may retire the `.github/skills` copies. A brief edit applies to whichever copies exist at execution time.
- #1028 excludes `.github/workflows/**` from its edits, so workflow templates are not a generated surface.

## 3. Candidate Approaches

### A (selected). Rendered single `CI` caller in the shared layer, opt-in

- New reusable workflows in this repository for destinations: `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml` (input `variant`: `modern` or `legacy`). Each uses only destination-generic steps and writes the artifact paths in section 2.6. The PowerShell workflow checks out `${{ job.workflow_repository }}` at `${{ job.workflow_sha }}` into a side folder to load PoshQC. That satisfies #1049's pinned-ref requirement for the vendored-coverage exemption.
- New bundle `extensions/drm-copilot/resources/ci-workflows/`: a caller template, per-pack job fragments, the constant data file, and the opt-in command. `packages/mcp-server/prepack.cjs` copies `resources` wholesale, except the resources-root `scripts/` subtree.
- A new TypeScript module under `extensions/drm-copilot/src/lib/push-down/` renders `.github/workflows/drm-copilot-ci.yml`. The rendered file holds: `name: CI`; the triggers `pull_request` (`main`, `"epic/**"`), `push` (`main`), `workflow_dispatch`, and `merge_group`; one caller job per language pack in the union of `selection.*.packs` recorded in the manifest after this run; and the inline `CI Required Gate` job. The pin is `v<payload_version>`, from #1029 D6. Copy mode renders local `uses: ./.github/workflows/drm-copilot-<pack>.yml` and adds those copies.
- Delivery: when the new optional input enables CI, the files are added to the #1029 `shared` layer as root-file pairs, with the selection-dependent text produced by the layer rewrite. Manifest entries use layer `shared` and pack `core` for the caller and data file, and the language pack name for copy-mode files. The manifest schema stays `1.0.0`. Hashes come from #1029's writer, which satisfies "copy mode records content hashes in the manifest" with no new field.
- Enablement: a new optional MCP input, for example `ci_workflows` with values `off`, `reference`, and `copy`, default `off`. When it is omitted and the manifest already lists the caller path, the recorded mode is reused, as O-5 does for packs. The default `off` keeps #1029's wrapper-compatibility and idempotence acceptance criteria true for calls without the new input.
- Name-collision check: before planning, read the destination's `.github/workflows/*.yml` top-level `name:` values. When another file declares `CI`, withhold the caller and emit a `push-down conflict:` warning naming the file. The data file is still delivered.
- Advantages: one required context, stable under selection changes; no hook, S9, or rule edit; no manifest schema change; uses existing #1029 extension points (root-file pairs, rewrite, report warnings).
- Limitations: it depends on #1029 symbols that do not exist on this branch yet. The rendered caller's hash changes when the selection changes, which yields `update` (or `conflict` when the file was edited). The new reusable workflows are not exercised by this repository's `ci.yml` unless a smoke job is added.

### Rejected alternatives

- **Thin callers to the existing `_*.yml` workflows.** Rejected: they run paths specific to this repository (section 2.2).
- **One static workflow per pack, each with its own name.** Rejected: only one workflow can be named `CI`, an aggregate job cannot `needs` across workflows, and per-pack contexts reintroduce a required list that changes with the selection.
- **A new manifest layer value `ci`.** Rejected: #1029 readers reject an unknown `layer` (section 2.5).
- **Hooks read the data file.** Rejected for this child. It edits byte-identical Claude and Codex twins and their Pester suites, and gains nothing when the template is pinned to the hook's literal `CI` by a contract test. It remains an owner question.
- **An MCP tool that writes rulesets.** Rejected: a settings mutation through an MCP tool bypasses the Bash merge and command hooks.

## 4. Behavior Semantics

- Success: an apply run with CI enabled writes the caller, the data file, and (in copy mode) the selected packs' reusable copies. Each is recorded in the manifest with the canonical hash. A second identical run reports them `unchanged`.
- Selection: only packs in the recorded selection union get a caller job. `core` contributes the gate job only. Selecting Python writes no PowerShell job.
- Failure before write: an invalid `ci_workflows` value; both C# variants in the union (existing `assertSingleCsharpToolchain` semantics).
- Conflicts: an edited caller is `conflict` (kept, reported). A pre-existing unmanaged file at the caller path is `unmanaged-conflict`. A different workflow named `CI` causes the caller to be withheld and reported. No workflow file outside the CI paths is ever written.
- Branch protection: never changed by the push-down. The opt-in command defaults to a dry run that prints the planned ruleset body; only an explicit switch issues the `gh api` write, and it creates a new ruleset rather than editing an existing one (owner question OQ-5).

## 5. Requirements Mapping (proposed state and file changes)

| AC (issue) | Mechanism |
| --- | --- |
| Pack option includes a template; selecting writes only that pack's workflows | Per-pack job fragments; renderer over the selection union; copy mode writes only the selected packs' copies; Jest tests per pack |
| Check names and artifact paths match rules and merge gate; contract test | Jest contract test of section 2.6 |
| Thin caller with pinned ref by default; copy mode records hashes | `reference` is the default once enabled; `copy` files are ordinary `files` entries |
| Required-check list emitted as data, consumed by merge gate and brief | `.github/drm-copilot/ci-required-checks.json` `{ schema_version, workflow: "CI", workflow_file, required_contexts: ["CI Required Gate"] }`. Merge-gate consumption is through the pinned literal (narrowed; SUPERSEDED line). The brief gains one bullet in all existing copies |
| Never overwrite; report each conflict | #1029 decision table plus the name-collision warning |
| Branch protection only by an explicit opt-in command | Opt-in PowerShell command, dry run by default (OQ-5) |
| No new Python | TypeScript (MCP/extension), YAML, JSON, PowerShell, Markdown only |

Likely files (to be re-checked at the plan's Phase 0 gate): new `.github/workflows/harness-*.yml`; new `extensions/drm-copilot/resources/ci-workflows/**`; new `extensions/drm-copilot/src/lib/push-down/push-down-ci-workflows.ts` (renderer and layer contribution) plus its test; edits to #1029's `push-down-shared-layer.ts` or `push-down-harness.ts`, `push-down-service-call.ts`, `mcp-push-down-schema-properties.ts`, `mcp-tool-inputs-push-down.ts`, `mcp-tool-inputs.ts`, and `repo-automation-service-contract.ts`; `extensions/drm-copilot/jest.config.cjs` (new `coverageThreshold` entries); the brief copies; `.github/workflows/README.md` (the new reusable workflows); `extensions/drm-copilot/README.md` and `CHANGELOG.md` (pin-bump process).

## 6. Language Classification

| Artifact | Runs where | Language |
| --- | --- | --- |
| Destination-oriented reusable workflows `.github/workflows/harness-*.yml` | GitHub Actions (called from destinations) | YAML |
| Caller template and per-pack fragments under `resources/ci-workflows/` | Rendered into destinations | YAML |
| `ci-required-checks.json` | Destination data | JSON |
| Renderer, layer contribution, MCP input parsing | MCP server and extension host | TypeScript (clause 2) |
| Jest unit and contract tests | CI | TypeScript |
| Opt-in branch-protection command (OQ-5 default) | Destination, run by a person or agent on request | PowerShell, with `SupportsShouldProcess` and an `Invoke-GhExe` wrapper seam |
| Its Pester tests | CI (PoshQC shards) | PowerShell |
| Python coverage-threshold step in `harness-python.yml` | GitHub Actions | Inline `pwsh` reading `coverage.json` totals, or the opt-in PowerShell helper. No new Python, and no call to `scripts.dev_tools.check_python_coverage_thresholds`, which is absent in a destination and in copy mode |
| Brief bullet, READMEs, CHANGELOG | Documentation | Markdown |

No hook is added or changed, so the rule that hooks never invoke Python is not touched.

## 7. Testing Implications

- Jest (parallel workers): the renderer per pack and combination (python only; powershell plus typescript; csharp-modern versus csharp-legacy); the pin equals `v<payload_version>`; copy mode emits local `uses:`; data-file content; the name-collision check over in-memory destinations; enable, disable, and O-5-style reuse; dry run writes nothing. Use in-memory `PushDownFileSystem` fakes, POSIX roots, and CRLF built in code.
- Contract test (Jest): section 2.6 paths and names against the bundled consumer texts.
- Pester (one `Invoke-PoshQCParallelTest` gate): the opt-in command's dry run and apply paths through a mocked `Invoke-GhExe`.
- Optional smoke: a `ci.yml` job that calls `harness-typescript.yml` against a fixture subfolder. This adds a `ci.yml` job, so `CiRequiredGateWorkflow.Tests.ps1` (WG02 counts eleven other jobs), the gate's `needs`, the brief, and possibly `$script:CiRequiredGateSkippableJobs` all change. Recommended default: no smoke job, and record the residual risk. A green run of each new reusable workflow is obtained through `workflow_dispatch` on a scratch destination (orchestrator-owned).

## 8. Risks

- Upstream absence: none of the #1029 modules exist here, and #1049's plan has not cleared preflight. Phase 0 must confirm `PushDownLayer`, `LAYER_ROOT_FILES`, `buildSharedLayer`, `pushDownHarness`, `runPushDownPipeline`, `parseDestinationManifest` (the `layer` enum and whether `pack` is free text), `hashPayloadText`, `PUSH_DOWN_CONFLICT_LINE_PREFIX`, and D6 `payload_version` on the integration branch.
- Process-reduction ledger: entry `0002-concurrent-review.md` holds revert blocks for the brief bullets "Concurrent-review join", "Merge guard (#1097)", "Merge text under the concurrent-review key", and "Concurrent checkpoints", and for passages of `.claude/skills/orchestrate/SKILL.md` around S9 and the join. A search of `docs/engineering/process-reductions/` and `patches/` found no record of other `## CI Shape and Required Checks` bullets (the only hit was test code in `0001` patch text). The new brief bullet must be added outside those blocks, after the "Refresh rule" bullet and not adjacent to the "Concurrent-review join" block. S9 is not edited. `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` enforces this.
- Brief contract tests: `test_brief_copies_are_byte_identical` and `test_brief_ci_section_names_jobs_and_required_contexts` must stay green. Add text only and keep every pinned token.
- Mirror and bundle tests: `test_push_down_*_resource_contracts.py` and the pack-manifest completeness tests cover the `.claude`, `.agents`, and `.codex` bundles. A new `resources/ci-workflows/` bundle is outside their scope, so #1029's full-bundle Jest completeness test (P5-T1) must be extended or the bundle listed as a documented exception. `test_poshqc_bundled_parity.py` is unaffected unless PoshQC is vendored (OQ-3).
- Workflow guards: `npm_token_guard_test_support.py` scans every `*.yml` under `.github/`, so the new workflows must not reference `NPM_TOKEN`. `test_host_environment_contracts.py` (`test_development_node_workflow_matches_host_baseline`, `..._poetry_...`) may parametrize over named workflows; a new workflow that pins Node or Poetry should use `26.13.0` and `2.5.1`.
- File size: `extensions/drm-copilot/jest.config.cjs` is about 596 lines before #1029 adds its entries. Measure it at Phase 0, because #1029 adds about eleven entries and 1050 adds more. `mcp-tools.ts` (about 473) and `mcp-repo-automation-tool-definitions.ts` (about 434) are near the 500-line guidance. New logic goes into new modules.
- Batch budget: the opt-in command adds one PowerShell production file plus its bundle copy. That is within the direct cap, but the plan should run on the orchestrated route.
- Pin semantics: `v<payload_version>` requires the release tag to exist and to stay where it is. A destination pushed from an unreleased build references a tag that does not exist yet. Tags can move; GitHub recommends SHA pins.
- .NET coverage format conflict (section 2.6), and legacy .NET needs Windows runners with msbuild and vstest.
- Copy mode and PowerShell: a destination that cannot reach this repository cannot load PoshQC, so #1049's exemption cannot run there (OQ-3).
- Tests that assert behavior this plan changes: none of the consumer tests in section 2.4 under the recommended design. The new MCP input changes `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` (#1029 renames a case that expects an exact key set) and any exact key-set assertion over the push-down schemas. Preflight must search for these.

## 9. Owner Questions (recommended defaults)

- OQ-1. Is CI delivery opt-in (`ci_workflows` default `off`)? Default: yes, because a default-on delivery changes the published set for every existing call and breaks #1029's compatibility acceptance criteria.
- OQ-2. Does the merge gate read the data file? Default: no. A contract test pins the template's `CI` to the hook literal, and the AC is narrowed as stated in the SUPERSEDED line.
- OQ-3. In copy mode, does the PowerShell pack vendor PoshQC into the destination (recorded in the manifest), or run plain Pester with JaCoCo output and no vendored exemption? Default: vendor under `.github/drm-copilot/poshqc/` with pack `powershell`. #1049 OQ-1 kept PoshQC out of the destination for the check module, so this needs an explicit answer.
- OQ-4. .NET: produce `artifacts/csharp/coverage.xml` in JaCoCo form (conversion step), or change the review hook to accept Cobertura? Default: the template converts to the path and format the hook reads; legacy runs on `windows-latest`.
- OQ-5. Opt-in branch protection: a PowerShell command (dry run by default, `-Apply` creates a new ruleset requiring `CI Required Gate`) or a Markdown runbook only? Default: the PowerShell command, delivered at `.github/drm-copilot/Set-CiRequiredChecks.ps1`.
- OQ-6. Shell (bats and kcov) pack: still deferred (#1049 OQ-4)? Default: deferred, because there is no shell pack in the pack model.
- OQ-7. Pin form: release tag `v<payload_version>` or a commit SHA? Default: the tag, with the bump process documented as "upgrade the extension, re-run the push-down; an unedited caller updates".

## 10. Numeric Derivation Evidence

### Claim N1: the execution-environment brief has six copies carrying `## CI Shape and Required Checks`

- Complete Family: every `SKILL.md` that holds the full brief text.
- Exhaustive Search Scope: the whole worktree, every `SKILL.md`.
- Inclusion Rules: the file is an `execution-environment/SKILL.md` that contains the heading.
- Exclusion Rules: files that only cite the heading (`atomic-plan-contract/SKILL.md` and its bundle copy).
- Primary Search Strategy or Query Expression: content search for the heading literal over `**/SKILL.md`.
- Primary Member Set: `.claude/skills/execution-environment/SKILL.md`; `.agents/skills/execution-environment/SKILL.md`; `.github/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` (eight hits, two excluded).
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: the `_BRIEF_COPIES` tuple in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
- Cross-check Member Set: the same six paths.
- Cross-check Count: 6.
- Member-set Comparison: identical sets.

### Claim N2: the Claude and Codex pack sets each have six packs

- Complete Family: pack names usable for selection in the Claude and Codex bundles.
- Exhaustive Search Scope: `extensions/drm-copilot/resources/**/pack-manifests/*.json` and `extensions/drm-copilot/src/lib/push-down/`.
- Inclusion Rules: the `name` value of each manifest file, per bundle.
- Exclusion Rules: the #1029-planned Copilot and `shared` manifests, which do not exist on this branch.
- Primary Search Strategy or Query Expression: content search for `"name"` in the pack-manifest JSON files.
- Primary Member Set: `core`, `python`, `powershell`, `typescript`, `csharp-modern`, `csharp-legacy` (identical in both bundles).
- Primary Count: 6 per bundle.
- Cross-check Search Strategy or Query Expression: the `MANIFEST_PACK_NAMES` declaration in `codex-pack-selection.ts`.
- Cross-check Member Set: `core`, `python`, `powershell`, `typescript`, `csharp-modern`, `csharp-legacy`.
- Cross-check Count: 6.
- Member-set Comparison: identical sets.

## Pre-Mortem

- Review checklists: a reviewer flags the new reusable workflows as "modified workflow needs a green run" (`modified-workflow-needs-green-run`) and the AC narrowing as a scope cut. Mitigation: the plan records the SUPERSEDED line and OQ-2 in the spec, and it adds an orchestrator-owned task that dispatches each new reusable workflow once against a scratch destination before review.
- Coverage: each new TypeScript production file needs its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` (lines 85, branches 75), and the PowerShell command needs at least 85% line coverage from the Pester gate. Mitigation: a threshold-entry task per new file, and per-file figures read from `coverage/lcov.info` and `artifacts/pester/powershell-coverage.xml` of the single gate runs.
- Mirror parity: the brief bullet must land in every brief copy that exists at execution time (six today, through #1028's `.agents` source and generator), and the opt-in command must match its bundle copy. Mitigation: one brief-update task that regenerates or copies, followed by `test_brief_copies_are_byte_identical`, the #1028 `-Surface skills -Check`, and a bundle-parity assertion for the new `resources/ci-workflows/` files.
- File size: `jest.config.cjs` may cross the 700-line advisory once #1029 and 1050 add entries, and `mcp-tools.ts` is near 500. Mitigation: measure physical lines at Phase 0 with a line-count method (not `Measure-Object -Line`), keep new logic in new modules, and stop for re-planning before 800.
- Test isolation: the renderer and collision check read destination workflow files, which tempts temporary files. Mitigation: in-memory `PushDownFileSystem` fakes with POSIX roots, CRLF built in code, no module-level mutable state; Pester tests mock `Invoke-GhExe`; one parallel gate per language.
- CI-only behavior: new workflows are first exercised only on GitHub runners; a drive-letter fixture or committed CRLF fixture fails on Linux; the npm-token guard scans every new `.github` YAML. Mitigation: POSIX fixtures, no `NPM_TOKEN` text, Node and Poetry pins equal to the host baseline, and the dispatch task above.
- Evidence: Phase 0 must record that #1029 and #1049 are merged into the integration branch, along with the symbol re-check, under `<FEATURE>/evidence/qa-gates/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, each timestamp read from the clock and each record append-only. Mitigation: gate tasks that write `Result: BLOCKED` and stop on any mismatch.

## Unverified Facts (need git, gh, or a live run)

- Whether #1029, #1049, and #1028 are merged into `epic/shared-agent-harness-layer-integration`, and the final names of #1029's symbols.
- Repository visibility of `drmoisan/drm-copilot` and its Actions access policy for reusable workflows (decides whether reference mode works for private destinations).
- Whether `v*` release tags exist for each published extension version, and whether tags are protected from moving.
- Whether ruleset 15241672 now requires only `CI Required Gate` (owner edit from the #1074 runbook).
- Live behavior of `job.workflow_repository` and `job.workflow_sha` inside a cross-repository call, of `needs.*.result` object filtering in a gate step, and the check-name rendering `<caller job> / <called job>` for a cross-repository call.
- Whether #1032 has retired the `.github/skills` brief copies by execution time.
- The physical line count of `extensions/drm-copilot/jest.config.cjs` on the integration branch after #1029.
