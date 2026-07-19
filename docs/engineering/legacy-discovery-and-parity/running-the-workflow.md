# Running the Workflow

The discovery/parity workflow (see [`workflow.md`](workflow.md)) is reachable through
three surfaces, documented here in the order CLI, then MCP tools, then VS Code commands.
**The three surfaces are lockstep equivalents at the capability level**: every discovery
capability reachable through the CLI is reachable through both the MCP tools and the VS
Code commands, and the MCP tools and VS Code commands invoke the same underlying service
calls (each VS Code command is a thin front end over the matching MCP-tool service call).
They are not, however, a naive one-to-one command-name mirror — the CLI exposes finer
granularity (separate commands per validated artifact kind and per report kind) than the
MCP/VS Code layer, which consolidates related CLI commands behind one parameterized tool.
That consolidation is documented explicitly below rather than assumed.

## CLI

Every discovery command is a Poetry console script under the `dev.discovery.*` namespace,
invoked as `poetry run dev.discovery.<command> ...`, matching the repository's established
`dev.*` alias convention (`pyproject.toml`, `[tool.poetry.scripts]`). Poetry console
scripts always resolve through this uniform `poetry run <script-name>` form regardless of
which module implements them — several `dev.discovery.*` commands are entry points into
modules outside the `scripts.dev_tools.discovery` package, and several use a non-`main`
entry function, so `poetry run dev.discovery.<command>` is the invocation form to use; a
guessed `python -m scripts.dev_tools.discovery.<command>` equivalent is not reliable for
every command.

| Command | Entry point |
|---|---|
| `dev.discovery.init` | `scripts.dev_tools.discovery.init_cli:main` |
| `dev.discovery.profile` | `scripts.dev_tools.discovery.profile_cli:main` |
| `dev.discovery.inventory` | `scripts.dev_tools.discovery.analyzer.cli:main` |
| `dev.discovery.dotnet` | `scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet` |
| `dev.discovery.vsto` | `scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto` |
| `dev.discovery.generate-acceptance-scenarios` | `scripts.dev_tools.generate_acceptance_scenarios:main` |
| `dev.discovery.completion-report` | `scripts.dev_tools.discovery.completion_report:main` |
| `dev.discovery.coverage-report` | `scripts.dev_tools.discovery.coverage_report:main` |
| `dev.discovery.parity-report` | `scripts.dev_tools.discovery.parity_report:main` |
| `dev.discovery.validate-all` | `scripts.dev_tools.validate_discovery_artifacts:main` |
| `dev.discovery.validate-profile` | `scripts.dev_tools.validate_discovery_artifacts:main_profile` |
| `dev.discovery.validate-feature-contract` | `scripts.dev_tools.validate_discovery_artifacts:main_feature_contract` |
| `dev.discovery.validate-coverage-ledger` | `scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger` |
| `dev.discovery.validate-runtime-scenario` | `scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario` |
| `dev.discovery.validate-parity-matrix` | `scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix` |
| `dev.discovery.validate-unspecified-behavior` | `scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior` |
| `dev.discovery.validate-product-decision` | `scripts.dev_tools.validate_discovery_artifacts:main_product_decision` |
| `dev.discovery.validate-evidence-reference` | `scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference` |

## MCP Tools

Seven MCP tools expose the discovery capability, defined in
`extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` and available from both the
extension-hosted MCP server and the standalone `@danmoisan/drm-copilot-mcp` npm package
(`packages/mcp-server/`, usable via `npx`):

| MCP tool | CLI equivalent |
|---|---|
| `validate_discovery_artifacts` | The `dev.discovery.validate-*` family, selected by an `artifact_type` input (`all` validates every kind under a supplied path). |
| `run_discovery_init` | `dev.discovery.init` |
| `run_discovery_repo_inventory` | `dev.discovery.inventory` |
| `run_discovery_dotnet_analyzer` | `dev.discovery.dotnet` |
| `run_discovery_vsto_analyzer` | `dev.discovery.vsto` |
| `run_discovery_scenario_generation` | `dev.discovery.generate-acceptance-scenarios` |
| `run_discovery_report` | The `dev.discovery.*-report` family, selected by a `report_type` input (`coverage`, `parity`, or `completion`). |

`dev.discovery.profile` (authoring/updating the domain-profile file directly) has no
dedicated MCP tool; domain-profile authoring is a file-editing activity performed as
described in [`domain-profile.md`](domain-profile.md), not a discrete MCP action.

Each MCP tool invokes the workspace discovery CLI in the target workspace rather than
reimplementing discovery logic in the extension. Where the tool call requires a Python
process, the extension resolves a Python interpreter for the *target workspace* — the
workspace `.venv` interpreter, then `py`, then `python` on PATH — because the extension
itself bundles no Python; the discovery code lives in the consumer workspace.

## VS Code Commands

Seven command-palette entries mirror the MCP tools one-to-one, registered in
`extensions/drm-copilot/src/discovery-command-registration.ts` and contributed in
`extensions/drm-copilot/package.json`:

| Command ID | Palette title |
|---|---|
| `drmCopilotExtension.validateDiscoveryArtifacts` | drm-copilot: Validate Discovery Artifacts |
| `drmCopilotExtension.runDiscoveryInit` | drm-copilot: Run Discovery Init |
| `drmCopilotExtension.runDiscoveryRepoInventory` | drm-copilot: Run Discovery Repo Inventory |
| `drmCopilotExtension.runDiscoveryDotnetAnalyzer` | drm-copilot: Run Discovery .NET Analyzer |
| `drmCopilotExtension.runDiscoveryVstoAnalyzer` | drm-copilot: Run Discovery VSTO Analyzer |
| `drmCopilotExtension.runDiscoveryScenarioGeneration` | drm-copilot: Run Discovery Scenario Generation |
| `drmCopilotExtension.runDiscoveryReport` | drm-copilot: Run Discovery Report |

Each command accepts either a direct argument object (matching its MCP tool's input) or
falls back to an interactive prompt sequence when invoked from the command palette without
arguments, then calls the same in-process service method the corresponding MCP tool calls.
