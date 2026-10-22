# Command Reference

All entries below are declared in `packages/discovery-runtime/pyproject.toml` (console
scripts), `packages/discovery-runtime/src/drm_copilot_discovery/cli_commands.py` (syntax),
`extensions/drm-copilot/src/repo-automation-tool-names.ts` (MCP tools) and
`extensions/drm-copilot/package.json` (VS Code commands). Common CLI options:
`--workspace-root`, `--profile`, `--repository-id`; `--dry-run` on every writing command;
`--write` on optional-write commands; `--mode` and `--format` on validation and reports.

## Console scripts (`dev.discovery.*`)

| Command | Operation | Options | Writes |
|---|---|---|---|
| `init` | `init` | `--system-id`, `--system-name`, `--role`, `--production-root`*, `--test-root`*, `--draft` | yes |
| `configure` | `configure` | `--input`, `--activate` or `--deactivate` | yes (root-only) |
| `profile` | `profile` | `--input` | no |
| `inventory` | `inventory` | `--analyzer`* | with `--write` |
| `dotnet` | `inventory` (analyzer `dotnet`) | | with `--write` |
| `vsto` | `inventory` (analyzer `office-vsto`) | | with `--write` |
| `new-contract` | `new-contract` | `--input`, `--feature-id`, `--name`, `--capability-group` | yes |
| `new-scenario` | `new-scenario` | `--input`, `--scenario-id`, `--feature-id`* | yes |
| `update-artifact` | `update-artifact` | `--input`, `--kind`, `--path`, `--expected-sha256` | yes |
| `link-evidence` | `link-evidence` | `--artifact-kind`, `--artifact-id`, `--evidence`, `--expected-sha256` | yes |
| `validate-profile` | `validate-profile` | `--input` | no |
| `validate-feature-contract`, `validate-coverage-ledger`, `validate-runtime-scenario`, `validate-parity-matrix`, `validate-unspecified-behavior`, `validate-product-decision`, `validate-evidence-reference` | the matching operation | `--artifact` | no |
| `validate-decisions` | `validate-decisions` | | no |
| `validate-all`, `validate` | `validate-all` | `--mode`, `--format`, `--output-prefix` | receipt inputs |
| `coverage-report`, `parity-report`, `completion-report` | the matching operation | `--mode`, `--format` | with `--write` |
| `generate-acceptance`, `generate-acceptance-scenarios` | `generate-acceptance` | `--kind`, `--feature-id`*, `--client-id`*, `--mode-id`*, `--platform-id`*, `--output-format markdown|gherkin|both` | with `--write` |
| `snapshot-export` | `snapshot-export` | `--selected-id`*, `--path`* | yes (root-only) |
| `snapshot-import` | `snapshot-import` | `--manifest` | yes (root-only) |
| `import-inventory` | `import-inventory` | `--manifest` | with `--write` (root-only) |
| `migrate` | `migrate` | init options, `--input`, `--from-version 1`, `--to-version 2`, `--destination`, `--path`* | yes (root-only) |
| `doctor` | `doctor` | | no |

`*` marks a repeatable option. Thirty-one scripts map onto the thirty service operations
(`validate` and `generate-acceptance-scenarios` are aliases; `dotnet` and `vsto` are fixed
inventory selections); the `read-source`, `prepare-agent` and `finalize-agent` operations
are reachable only through the gateway because they require a host principal.

## MCP tools

| Tool | Principal | Purpose |
|---|---|---|
| `validate_discovery_artifacts` | any | Validate in a selected mode; publish receipt inputs with `write`. |
| `run_discovery_init` | root | Initialize draft profile, scope and collections. |
| `configure_discovery_workspace` | root | Activate or deactivate the workspace. |
| `run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer` | controlled | Run analyzers; publish with `write`. |
| `create_discovery_artifact` | controlled | Draft a feature contract or runtime scenario. |
| `update_discovery_artifact` | controlled | Replace an artifact from a proposal or approve a decision, pinned by digest. |
| `link_discovery_evidence` | controlled | Attach verified evidence to an artifact, pinned by digest. |
| `run_discovery_scenario_generation` | controlled | Generate acceptance specifications. |
| `run_discovery_report` | controlled | Coverage, parity or completion report. |
| `read_discovery_source` | controlled | List, read or search bounded source under the configured roots. |
| `transfer_discovery_snapshot` | root | Export or import a source snapshot manifest. |
| `import_discovery_inventory` | root | Import an extension result manifest. |
| `migrate_discovery_artifacts` | root | Migrate version 1 artifacts to version 2. |
| `run_discovery_doctor` | any | Read-only runtime, activation and capability diagnostics. |
| `prepare_discovery_agent` | root | Prepare a constrained invocation for one skill and return the launchable deployment. |
| `finalize_discovery_agent` | controlled | Validate the invocation's required outputs and mint the protected receipt. |

## VS Code commands

`drmCopilotExtension.validateDiscoveryArtifacts`, `runDiscoveryInit`,
`runDiscoveryRepoInventory`, `runDiscoveryDotnetAnalyzer`, `runDiscoveryVstoAnalyzer`,
`runDiscoveryScenarioGeneration`, `runDiscoveryReport`, `createDiscoveryArtifact`,
`linkDiscoveryEvidence`, `configureDiscoveryWorkspace`, `transferDiscoverySnapshot`,
`migrateDiscoveryArtifacts` and `runDiscoveryDoctor` (all under the `drmCopilotExtension.`
prefix) wrap the corresponding MCP tools.

## Gateway operations

`init`, `configure`, `profile`, `inventory`, `new-contract`, `new-scenario`,
`update-artifact`, `link-evidence`, `validate-profile`, `validate-feature-contract`,
`validate-coverage-ledger`, `validate-runtime-scenario`, `validate-parity-matrix`,
`validate-unspecified-behavior`, `validate-product-decision`, `validate-evidence-reference`,
`validate-decisions`, `validate-all`, `coverage-report`, `parity-report`,
`completion-report`, `generate-acceptance`, `snapshot-export`, `snapshot-import`,
`import-inventory`, `migrate`, `doctor`, `read-source`, `prepare-agent`, `finalize-agent`.
Modes: `structural`, `agent-output`, `discovery-complete`, `parity-complete`, `planning`.

## Operator scripts

- `scripts/dev-tools/Test-DiscoveryHostCapability.ps1 -HostName <claude-code|codex|github-copilot>`
  runs the host's capability probe and exits 0 (supported), 1 (unsupported) or 2 (unknown
  host or probe not installed).
- `poetry run python -m scripts.dev_tools.build_discovery_runtime` builds the wheel
  (framework maintainers; see [`maintainer-guide.md`](maintainer-guide.md)).
