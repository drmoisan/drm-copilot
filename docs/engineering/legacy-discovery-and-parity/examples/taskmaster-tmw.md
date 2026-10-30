# Example: a separate legacy source and modernization target

This page is a separated, non-canonical example. It names two consumer repositories,
`drmoisan/TaskMaster` as the legacy source and `drmoisan/TMW` as the modernization target,
only to make the generic sequence in [`../consumer-onboarding.md`](../consumer-onboarding.md)
concrete. Nothing here is framework behavior: the framework has not inspected, populated or
modified either repository, and every repository-specific path, platform, client, feature
and decision below is a placeholder that the repository's owners discover and record
locally. The generic pages in [`../README.md`](../README.md) remain the authority.

## Tested packages

The release this example accompanies was built and inspected from the framework repository;
the exact versions and digests are recorded in the feature handoff and must be re-verified
against the published artifacts before installation:

| Package | Version | Install |
|---|---|---|
| `drm_copilot_discovery-2.0.0-py3-none-any.whl` | 2.0.0 | `python -I -m pip install <published-path>/drm_copilot_discovery-2.0.0-py3-none-any.whl` |
| `drm-copilot` VS Code extension | 1.1.22 | Install the VSIX; it registers the `drmCopilotMcpProvider` MCP server. |
| `@danmoisan/drm-copilot-mcp` | 1.1.22 | `npx @danmoisan/drm-copilot-mcp` from the agent client's MCP configuration. |

Known limit of this release, recorded in the feature handoff: the installed runtime cannot
mint a completion receipt (`finalize_discovery_agent` and agent-scoped `read_discovery_source`
are refused), so the agent-driven steps that end in a finalized receipt are unavailable
until a host-principal service composition ships; the console operations (`validate-all`,
reports, `snapshot-export`, `snapshot-import`) and the native start, tool and stop controls
behave as documented.

## Interpreter

There is no separate interpreter setting. The gateway client selects the workspace `.venv`
interpreter first, then `py`, then `python` on `PATH`, so installing the wheel into each
repository's own `.venv` is the deterministic way to bind the runtime a host will use:

```text
<repo>/.venv/Scripts/python.exe -I -m pip install <published-path>/drm_copilot_discovery-2.0.0-py3-none-any.whl
<repo>/.venv/Scripts/python.exe -I -m drm_copilot_discovery.cli doctor --workspace-root <repo>
```

(`<repo>/.venv/bin/python` on macOS and Linux.) The doctor must report the installed
runtime identity before anything else is attempted.

## Push-down argument shapes

Run the installed MCP tools (extension or standalone server) once per repository and per
host the repository's engineers use. `<repo>` is the absolute path of the consumer
checkout. Publication uses the installed bundles, so rebuild and reinstall the packages
first when the framework has changed.

```json
{"tool": "push_down_copilot_customizations", "arguments": {"workspace_root": "<repo>"}}
{"tool": "push_down_claude_customizations", "arguments": {"workspace_root": "<repo>", "packs": ["core"], "memory_mode": "skip"}}
{"tool": "push_down_codex_and_agents_customizations", "arguments": {"workspace_root": "<repo>", "packs": ["core"], "memory_mode": "skip"}}
```

`packs: ["core"]` delivers the discovery roles, skills, hooks and helpers without any
language pack; add the repository's language packs when wanted. `memory_mode: "skip"`
leaves any existing agent memory untouched. Review the resulting native changes, enable
the hooks and workspace trust the host requires, then run the host probe
(`Test-DiscoveryHostCapability.ps1 -HostName <claude-code|codex|github-copilot>` or
`run_discovery_doctor`) and proceed only on `supported`.

## The legacy source (TaskMaster)

Initialize with the repository's real identity, role and roots, with a dry run first:

```text
dev.discovery.init --system-id taskmaster --system-name "TaskMaster" --role legacy-source --production-root <production-root> --test-root <test-root> --dry-run
dev.discovery.init --system-id taskmaster --system-name "TaskMaster" --role legacy-source --production-root <production-root> --test-root <test-root>
```

The owners complete `docs/migration/discovery/domain-profile.yaml` (clients, platforms,
modes, runtime capability, analyzers including `office-vsto` only if they enable it,
evidence roots, decision owners, pins and exclusions), then
`dev.discovery.configure --activate`, `dev.discovery.inventory --write`, confirm the scope,
and run the source workflows. The repository creates locally:

```text
config/discovery.json
docs/migration/discovery/
  domain-profile.yaml
  scope.yaml
  coverage-ledger.json
  unspecified-behaviors.yaml
  product-decisions.yaml
  feature-contracts/<locally-assigned-feature-id>.json
  characterization/<locally-assigned-scenario-id>.yaml
  inventory/<snapshot-id>.json
  evidence/<evidence-id>.json
  evidence/<local-runtime-or-document-capture>
  acceptance/<characterization-spec-id>.json
  acceptance/<characterization-spec-id>.feature
  reports/<coverage-or-completion-report>.json
  reports/<coverage-or-completion-report>.md
  source-snapshots/<export-id>/manifest.json
```

Validation: `dev.discovery.validate-all --mode discovery-complete`, then
`dev.discovery.snapshot-export --selected-id <feature or evidence id>...` for the
identities the target may bind. The framework supplies no feature catalog and no runtime
result; the owners provide architecture context, characterization tooling, evidence and
adjudication through their declared decision owners.

## The modernization target (TMW)

```text
dev.discovery.init --system-id tmw --system-name "TMW" --role modernization-target --production-root <production-root> --test-root <test-root>
```

The profile names the source repository under `repositories`, the target clients,
platforms and modes, and the target's own roots; after `configure --activate` the owners
import the source snapshot (`dev.discovery.snapshot-import --manifest <manifest>`), record
implementation and verification, reconcile parity and generate target acceptance. The
repository creates locally:

```text
config/discovery.json
docs/migration/discovery/
  domain-profile.yaml
  scope.yaml
  coverage-ledger.json
  unspecified-behaviors.yaml
  product-decisions.yaml
  parity-matrix.json
  source-snapshots/<source-revision>/manifest.json
  source-snapshots/<source-revision>/feature-contracts/<feature-id>.json
  source-snapshots/<source-revision>/evidence/<evidence-id>.json
  implementation-records/<feature-client-id>.json
  acceptance/<target-acceptance-id>.json
  acceptance/<target-acceptance-id>.feature
  acceptance/pending.md
  evidence/<verification-evidence-id>.json
  reports/<parity-or-completion-report>.json
  reports/<parity-or-completion-report>.md
<locally-selected-architecture-decision-root>/
<locally-selected-target-tests-root>/
```

Validation: `dev.discovery.validate-all --mode parity-complete`. The target architecture
decisions and the implementation tests under the two locally selected roots are consumer
work, recorded through `implementation-record` artifacts; the framework reports their
recorded verification state and never asserts a pass. Offline and mobile dimensions are
required only once the local profile declares them applicable.

## A single repository

A repository that is both source and target runs the same sequence once with
`--role combined`, keeping separate source and target identities and pins in one profile
and one artifact root.
