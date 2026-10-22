# Consumer Onboarding

A consumer repository receives the capability through three published packages and
operates it without a checkout of this repository. Consumer names appear only in the
separated example [`examples/taskmaster-tmw.md`](examples/taskmaster-tmw.md), never in the
generic sequence below.

## What is delivered

| Package | Carries | Install |
|---|---|---|
| Python wheel `drm_copilot_discovery-2.0.0-py3-none-any.whl` | The engine, the thirty-one console scripts, the gateway, the staged version 1 and version 2 schemas and the version 2 templates. | `python -I -m pip install <wheel>` into the trusted interpreter the hosts will use. |
| VS Code extension (`drm-copilot`) or standalone MCP server (`@danmoisan/drm-copilot-mcp`) | The TypeScript gateway client, the MCP tools, the VS Code commands and the native customization bundles for all three hosts. | Install the VSIX, or run `npx @danmoisan/drm-copilot-mcp` from an MCP client configuration. |
| Native customization bundle (pushed down from the extension or server resources) | For the chosen host: the four role contracts, nine workflows and seven aliases, the discovery hooks and registrations, the shared PowerShell helpers, the routing config and setup templates. | The push-down tools below. |

The wheel carries every schema and template; no asset must be copied from this repository.
Neither the extension nor the MCP package contains Python business logic.

## Local setup

1. **Install the wheel** into a Python 3.10 or later interpreter you trust for this
   repository, for example the repository's own virtual environment. The gateway client
   detects the workspace `.venv` interpreter first, then `py`, then `python`; an explicit
   interpreter path can be configured per invocation.
2. **Install a host**: the extension (which also registers the MCP server definition) or
   the standalone MCP server in your agent client's MCP configuration.
3. **Push down the native customizations** for your host from the installed resources:
   `push_down_claude_customizations` (Claude Code; writes `.claude/` and `config/`),
   `push_down_codex_and_agents_customizations` (Codex; writes `.codex/` and `.agents/`) or
   `push_down_copilot_customizations` (GitHub Copilot; writes `.github/agents`,
   `.github/hooks`, `.github/instructions`, `.github/prompts`, `.github/skills`). Each is an
   MCP tool, a VS Code command and a Python module (`scripts/dev_tools/push_down_*.py
   --destination <workspace>`). The discovery assets are in the `core` pack, so a
   `--packs`-scoped push-down still receives them.
4. **Probe the host**: `Test-DiscoveryHostCapability.ps1 -HostName <host>` or
   `run_discovery_doctor` must report `supported` before any discovery role is launched.
5. **Initialize**: `dev.discovery.init --system-id <id> --system-name "<name>" --role
   <legacy-source|modernization-target|combined> --production-root <dir>... --test-root
   <dir>...` writes the draft profile, scope and collections under
   `docs/migration/discovery/` without overwriting anything.
6. **Complete the profile** per [`domain-profile.md`](domain-profile.md): repositories,
   clients, platforms, modes, analyzers, evidence roots, decision owners and completion
   gates.
7. **Activate**: `dev.discovery.configure --activate` validates the profile, writes
   `config/discovery.json` and records the protected activation outside the workspace.
8. **Run the workflow** per [`workflow.md`](workflow.md) and
   [`running-the-workflow.md`](running-the-workflow.md), and validate with
   `dev.discovery.validate-all --mode discovery-complete`.

## Separate source and target repositories

Install and activate in both repositories with their own profiles (`legacy-source` and
`modernization-target`, each naming the other in `repositories`). Export validated source
artifacts with `snapshot-export`, import them in the target with `snapshot-import`, record
target implementation and tests as `implementation-record` artifacts, build the parity
matrix there, and validate the target in `parity-complete` mode. See
[`migration.md`](migration.md) for the transport contract.

## What the consumer owns

The profile, scope, inventory snapshots, feature contracts, coverage ledger, runtime
characterization scenarios, evidence, unspecified-behavior and product-decision records,
source snapshots, implementation records, parity matrix, acceptance specifications and
reports are consumer artifacts under the configured `artifacts` root. The target
architecture and its implementation tests are consumer work; the framework reports their
recorded state and never asserts a pass.

## Updating

Install a newer wheel into the same interpreter, push down the matching customization bundle
again (pushes regenerate the delivered files and never touch consumer artifacts or the
destination-owned `config/blast-radius.local.json`), run the doctor, and re-run
`validate-all` to mint receipts for the new runtime identity.
