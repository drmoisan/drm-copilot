# Running the Workflow

The capability is reachable through three surfaces: the console scripts installed with the
wheel, the MCP tools of the extension-hosted or standalone MCP server, and the VS Code
commands. All three call the same engine through the same gateway contract, so a result
does not depend on the surface. [`cli-reference.md`](cli-reference.md) lists every entry.

## The gateway contract

A host launches `python -I -m drm_copilot_discovery.gateway --workspace-root <absolute>
--principal <local-user|host>` in the trusted interpreter, writes one `service-request`
document to stdin and reads one `service-result` from stdout. The request carries the
`operation`, the validation `mode`, `workspace_root`, `profile_path`, `dry_run`, `write`,
`format`, typed `inputs`, and for agent calls the `invocation_ref` and `authorization_ref`
that bind it to a protected invocation and a one-use tool authorization. The result carries
findings, artifacts and the exact exit code (`0` success, `1` validation failure, `2` usage
or policy rejection, `3` runtime unavailable or corrupt). Nothing else is exchanged.

## CLI

With the wheel installed in the trusted interpreter, every operation is a console script
`dev.discovery.<command>` (or `python -I -m drm_copilot_discovery.cli <command>`). Common
options are `--workspace-root`, `--profile` and `--repository-id`; writing commands accept
`--dry-run`, and optional-write commands (`inventory`, `import-inventory`,
`generate-acceptance`, the three reports) publish only with `--write`. Validation and report
commands accept `--mode` and `--format json|markdown|both`.

Typical sequence:

```text
dev.discovery.init --system-id <id> --system-name "<name>" --role legacy-source --production-root src --test-root tests
dev.discovery.configure --activate
dev.discovery.inventory --write
dev.discovery.new-contract --feature-id <feature> --name "<name>" --input <proposal>
dev.discovery.validate-all --mode discovery-complete
dev.discovery.coverage-report --format markdown --write
```

## MCP tools

Eighteen discovery tools are registered by both MCP hosts
(`extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` and
`mcp-discovery-authority-tool-definitions.ts`). Root-only tools (`run_discovery_init`,
`configure_discovery_workspace`, `transfer_discovery_snapshot`, `import_discovery_inventory`,
`migrate_discovery_artifacts`, `prepare_discovery_agent`) are rejected for a discovery agent
principal; controlled tools (`read_discovery_source`, `run_discovery_repo_inventory`,
`create_discovery_artifact`, `update_discovery_artifact`, `link_discovery_evidence`,
`run_discovery_scenario_generation`, `validate_discovery_artifacts`, `run_discovery_report`,
`finalize_discovery_agent`) are the only tools a role may call, each under a one-use
authorization written by the tool gate. `run_discovery_doctor` is available to every caller
and grants nothing.

The standalone server runs as `npx @danmoisan/drm-copilot-mcp` (or the `drm-copilot-mcp`
bin) and ships the native customization resources; the extension registers the same server
as the `drmCopilotMcpProvider` definition.

## VS Code commands

Thirteen command-palette entries (`drmCopilotExtension.*`) wrap the MCP service calls:
validate artifacts, run init, repo inventory, .NET analyzer, VSTO analyzer, scenario
generation and report, create artifact, link evidence, configure workspace, transfer
snapshot, migrate artifacts and run doctor. Each accepts a direct argument object or
prompts for its inputs, then calls the same in-process service the MCP tool calls.

## Agent-driven runs

When a discovery role runs under Claude Code, Codex or GitHub Copilot, the root session
prepares the invocation (`prepare_discovery_agent`), the host's start hook attests the
launch, every controlled tool call is authorized by the tool gate, and the agent finishes
through `finalize_discovery_agent`, whose receipt the stop hook requires. Filenames or
success prose in a final message never satisfy a gate. [`enforcement.md`](enforcement.md)
describes the controls; [`workflow.md`](workflow.md) describes which role runs which
workflow.

## Doctor

`dev.discovery.doctor` (MCP `run_discovery_doctor`, command "Run Discovery Doctor") reports
the installed runtime identity, the workspace locator and activation state, the profile's
validity and the host capability attestation, without changing anything. Run it first when a
gate denies unexpectedly.
