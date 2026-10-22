# Discovery runtime

`drm-copilot-discovery` is the authoritative Python package for the reusable
legacy discovery and parity capability. It requires Python 3.10 or later and
contains domain-neutral artifact behavior. Consuming repositories own their
profiles, observations, evidence, decisions, and target verification.

The canonical implementation lives in `src/drm_copilot_discovery`. Repository
development tooling depends on this package; the legacy modules under
`scripts/dev_tools/discovery` retain compatibility imports without duplicating
the implementation. Version 1 profile values remain available through those
imports. The old repository-only initializer retains its checkout template
resolver in its adapter until its versioned replacement is integrated.

The runtime dependencies are the already-approved PyYAML, jsonschema,
referencing, and lxml packages. This package does not depend on the root
repository's machine-learning or developer-tool dependencies.

Schemas and templates are authored in the repository's canonical resource
directories and staged deterministically into this package by the resource
builder. They are generated resources, not independently maintained copies.
See `docs/engineering/legacy-discovery-and-parity/` in the framework repository
for the complete setup and ownership model.

## Package contents

- `src/drm_copilot_discovery/` is the runtime: the service gateway
  (`python -I -m drm_copilot_discovery.gateway`), the protected authority
  store, artifact validation and reports, and the `dev.discovery.*` console
  entries declared in `pyproject.toml` (one per `cli.main_*` function).
- `src/drm_copilot_discovery/_resources/` holds the staged copies of the
  canonical `schemas/discovery/v1`, `schemas/discovery/v2` and
  `docs/discovery/templates/v2` files listed in `resource-manifest.json`, plus
  `manifest.json`, the sorted SHA-256 manifest the runtime verifies before it
  reads any resource. The v1 schemas are frozen; the v2 schemas and templates
  are exact copies of the repository sources at build time.
- `src/drm_copilot_discovery/_build_manifest.json` records the SHA-256 and
  size of every installed source and resource file so an installation can prove
  its identity against the build that produced it.
- `src/drm_copilot_discovery/py.typed` marks the package as typed.

## Building the wheel

Run the resource builder from the repository root inside the Poetry
environment. It verifies the allowlisted canonical inputs, resolves every
schema reference offline, checks the runtime import closure against the
declared dependencies, refreshes the staged resources and the build manifest,
and then builds the wheel with the approved poetry-core backend without
network access:

```text
poetry run python -m scripts.dev_tools.build_discovery_runtime --check
poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only
poetry run python -m scripts.dev_tools.build_discovery_runtime
```

`--check` fails without writing when a staged resource or the build manifest is
stale; `--stage-only` refreshes the generated files without building; the
default run writes `dist/discovery/drm_copilot_discovery-<version>-py3-none-any.whl`
(`--output` selects another directory) and prints a JSON report with the
resource manifest digest, the imported and declared runtime dependencies, the
checked modules and the wheel SHA-256. The `dist/` directory is not tracked.

## Installing

Install the built wheel into the trusted interpreter a host will use for the
discovery gateway; the host clients name this file explicitly when the module
is missing:

```text
python -I -m pip install dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl
```

The console entries become available as `dev.discovery.<operation>` commands,
and the gateway is reachable as `python -I -m drm_copilot_discovery.gateway`.
