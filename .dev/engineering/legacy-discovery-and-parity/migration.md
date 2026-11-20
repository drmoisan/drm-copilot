# Migration

Three operations move artifacts between versions, repositories and tools. All are
root-only, write through the engine's mutation boundary, support `--dry-run`, and record
what they produced; none of them approves anything.

## Version 1 to version 2

Version 1 workspaces hold a `profile_version: 1` profile (`legacy_source.root`,
`target.root`, `technology_stack.legacy`, `artifacts.root`) and artifacts validated by the
seven frozen version 1 schemas. `dev.discovery.migrate --from-version 1 --to-version 2
--destination <root> --input <v1 profile> [--path <artifact>]...` plus the `init` options:

1. captures the explicitly selected originals (`migration_capture.py`) without altering
   them;
2. validates each against its frozen version 1 schema from the staged resources;
3. converts the records into honest version 2 drafts (`migration_conversion.py`):
   observation states become `inferred` or `unknown` unless evidence is present, decisions
   stay `proposed`, and nothing is marked verified or approved by conversion;
4. initializes the destination with the version 2 profile, scope and collections
   (`init_flow.py`) and publishes the drafts with exact writes
   (`migration_v1.py`);
5. writes a `migration-report` listing every source, its outcome and every value a person
   must review.

The destination then follows the normal path: complete the profile, `configure --activate`,
re-run the inventory and validate. The compatibility PowerShell module
`DiscoveryValidation.psm1` no longer validates version 1 or version 2 artifacts; it directs
callers to the engine.

## Snapshot transport (separate repositories)

`dev.discovery.snapshot-export --selected-id <artifact id>... [--path <path>]...` writes a
`source-snapshot-manifest` and the exact bytes of the selected artifacts and evidence, each
pinned by digest and repository revision. `dev.discovery.snapshot-import --manifest <path>`
in the target repository verifies every digest, rejects a manifest whose bytes changed or
whose identities collide, and publishes the artifacts as source facts the target's parity
matrix may bind. MCP: `transfer_discovery_snapshot` with the closed `direction` enum.

## Inventory import

`dev.discovery.import-inventory --manifest <extension-result-manifest> [--write]` validates
a separately produced inventory against the captured inputs it claims
(`extension_validation.py`), merges it as inert data (`extension_results.py`) and records the
manifest digest in the resulting snapshot. The producing tool is never executed. MCP:
`import_discovery_inventory`.

## Changing runtime versions

The activation records `required_runtime_major`; a workspace activated by version 2 is
served only by a version 2 runtime, and receipts carry the runtime identity
(`build_sha256`, `package_version`, `policy_sha256`, `schema_version`). Installing a new
wheel invalidates receipts whose runtime pins differ; re-run `validate-all` to mint current
ones. `dev.discovery.doctor` reports the installed identity and whether the activation
accepts it.
