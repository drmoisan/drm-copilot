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
