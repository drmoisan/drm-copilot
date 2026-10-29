# Publication and consumer handoff (issue #980)

This handoff states what must be published and what each consuming repository's owners do
locally afterwards. It does not inspect, populate or modify any consumer. `drmoisan/TaskMaster`
(legacy source) and `drmoisan/TMW` (modernization target) are named only here and in the
separated example `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`;
every repository-specific value below is a placeholder their owners resolve locally.

## Built artifacts (reconciled with the feature evidence)

| Artifact | Version | SHA-256 | Evidence |
|---|---|---|---|
| `drm_copilot_discovery-2.0.0-py3-none-any.whl` (built to `dist/discovery/`; runtime identity build `dc7bff83fb56a7867826bae2adcd54e295beacd5b87cbfe31eaac051c764522d`, policy version 2, policy `d73c68cd04e18dee0d4d26a29d0cea8a34b8ed21bbd054baecf37952987d72b9`) | 2.0.0 | `566679a0a929837d0c9145e0d6a2ca86da1e4b68fdcc3c3412427c274406131a` | `evidence/qa-gates/discovery-installed-runtime.2026-10-29T12-26.md` (build sequence in `evidence/other/discovery-wheel-build.2026-10-29T12-26.md`) |
| `drm-copilot.vsix` (extension) | 1.1.22 | `efe92788da4fe743f4ee46f41edc38407c11e4f5de1e7085fc5dcc22dad73fbc` | `evidence/qa-gates/discovery-installed-runtime.2026-10-29T12-26.md` (build sequence in `evidence/other/discovery-host-packages.2026-10-29T12-26.md`) |
| `danmoisan-drm-copilot-mcp-1.1.22.tgz` (`@danmoisan/drm-copilot-mcp`) | 1.1.22 | `ca38e6fb63a2295c2d40c7a3bfcd32d3f69575fa0fe6ce67f37283899d36dbca` | `evidence/qa-gates/discovery-installed-runtime.2026-10-29T12-26.md` (build sequence in `evidence/other/discovery-host-packages.2026-10-29T12-26.md`) |

The digests are those of the artifacts rebuilt in P14-T12 from the final tree, after the
schema-registry correction (the registry is built and verified once per catalog) and the
rebase onto main; they supersede the P12-T12 digests (wheel `dca943be…`, VSIX `bc33e805…`,
npm `7cc66e5e…`), the P12-T11 digests (wheel `59652fe9…`,
VSIX `834cb081…`, npm `1bebefbc…`) and the P11-T7/P11-T8 digests (wheel `19e7dd45…`, VSIX
`a3bf8eed…`, npm `1e170906…`). The P12-T12 native host controls were not repeated for the
P14-T12 build because Phase 14 changes no TypeScript, PowerShell, hook or adapter file; the
rationale is recorded in `evidence/qa-gates/discovery-installed-runtime.2026-10-29T12-26.md`. The wheel's resource
manifest now carries 40 entries, including `schemas/discovery/v2/start-attestation.schema.json`,
and the runtime policy version advanced from 1 to 2 with the Phase 12 request rules. A rebuild
after further commits produces new digests, and the published artifacts must be re-digested
and the table updated at release time. The installed-runtime proof for these artifacts is
P14-T12 (the lexicographically greatest `evidence/qa-gates/discovery-installed-runtime.*.md`);
the native host-control proof is P12-T12 (the lexicographically greatest
`evidence/qa-gates/discovery-native-capabilities.*.md`), which covers host-side code unchanged
since that build; the earlier P11-T7 proof covered a previous build.

## Installed-host agent path (proven in P12-T12; closes the P11-T7 blocker)

The installed runtime now carries both principals. The root prepares a specialist through
`prepare_discovery_agent`: the Python `prepare-agent` route pins the pre-invocation baseline
as `local-user`, and the gateway client writes the five protected records
(`invocation.json`, `baseline-result.json`, `required-outputs.json`, `model-receipt.json`,
`topology-receipt.json`). The native start hook attests the launch, the tool gate records a
one-use `tool-authorization` per admitted controlled call, and the gateway client consumes
that grant by binding before it runs the Python gateway with `--principal host` and the
agent's `--author-id`, `--session-id`, `--host-name` and `--agent-role`. The host
composition verifies every protected record, replays the pinned baseline and admits the
request; `finalize_discovery_agent` runs the `finalize-agent` route, and the gateway client
mints the `agent-output` `validation-receipt` that the stop hook accepts. Observed on Claude
Code, Codex and the Copilot Local harness against the shipped digests above
(`evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md`): prepare, attested
start, agent-scoped `read_discovery_source`, granted `create_discovery_artifact`, finalize
`pass` with `output_valid` true, the stop allowed with that receipt, the stop blocked after
an input edit, a replayed controlled call denied `AUTHORIZATION_CONSUMED`, `finalize-agent`
as `local-user` refused `SERVICE_AUTHORITY` (exit 3) and an unattributed host principal
refused at exit 2. `docs/engineering/legacy-discovery-and-parity/enforcement.md`
(`## Host-principal path`) describes the route, the records and every refusal class.

What remains for the consumers is the work itself, not a framework gap: step 6 and step 7
below can be run through discovery agents or through the console path (`validate-all`,
reports, `snapshot-export`, `snapshot-import`), and each attempt needs its own prepared
invocation (one prepared invocation admits one start; a second prepare for the same
specialist in one session makes the start ambiguous and is denied).

## Publication prerequisites

1. The feature branch has passed review, the full QA pass and the orchestration completion
   validator, and is merged.
2. Rebuild from the merged head: `poetry run python -m scripts.dev_tools.build_discovery_runtime`
   (wheel), `npm run compile` then `npx --yes @vscode/vsce package` in
   `extensions/drm-copilot` (VSIX), `npm run build` then `npm pack` in `packages/mcp-server`
   (npm tarball). Record the three digests.
3. Publish deliberately and separately: the wheel to the chosen package location, the VSIX
   through `publish-extension.yml` or the sideload script, the npm package through
   `npm publish`. Publication is not performed by this feature.
4. Install the published extension or MCP server wherever the consumers' engineers run
   agents; the native customizations are pushed down from the installed bundles, so a stale
   installation publishes stale hooks.

## Per-repository local work (owners of each consumer)

Performed in each repository after publication, in this order. Nothing in this list is
done by the framework.

1. **Interpreter and wheel.** Create or select the repository `.venv` and install the wheel
   into it: `<repo>/.venv/Scripts/python.exe -I -m pip install <published-path>/drm_copilot_discovery-2.0.0-py3-none-any.whl`
   (`.venv/bin/python` on macOS and Linux). Verify the published SHA-256 first. The gateway
   client selects the workspace `.venv` interpreter before `py` or `python`, which is the
   interpreter setting; there is no separate configuration key. Run
   `python -I -m drm_copilot_discovery.cli doctor --workspace-root <repo>`.
2. **Host package.** Install the tested extension (1.1.22) or configure the standalone
   server (`npx @danmoisan/drm-copilot-mcp`) in the agent client. A customization push alone
   installs no Python.
3. **Push down the native customizations** with the installed MCP tools, one call per host
   the repository uses:
   - `push_down_copilot_customizations` with `{"workspace_root": "<repo>"}`
   - `push_down_claude_customizations` with `{"workspace_root": "<repo>", "packs": ["core"], "memory_mode": "skip"}`
   - `push_down_codex_and_agents_customizations` with `{"workspace_root": "<repo>", "packs": ["core"], "memory_mode": "skip"}`
4. **Review and probe.** Review the native changes, enable the hooks and workspace trust the
   host requires, then run `Test-DiscoveryHostCapability.ps1 -HostName <host>` (or
   `run_discovery_doctor`). Proceed only on `supported`; an unsupported host must not launch
   discovery roles.
5. **Initialize and activate.** `dev.discovery.init` with the repository's actual
   `--system-id`, `--system-name`, `--role` and roots, `--dry-run` first; resolve any
   `conflict` explicitly; complete the profile (clients, platforms, modes, runtime
   capability, analyzers, evidence roots, decision owners, pins, exclusions); then
   `dev.discovery.configure --activate`.
6. **Source discovery (legacy source).** `inventory --write`, confirm scope, draft and
   review feature contracts, dispositions, characterization and evidence, adjudicate
   unspecified behavior through the declared owners, `validate-all --mode
   discovery-complete`, then `snapshot-export` the approved identities.
7. **Target work (modernization target).** `snapshot-import` the source manifest, record
   implementation records and verification evidence, reconcile the parity matrix, generate
   target acceptance specifications, `validate-all --mode parity-complete`, and satisfy the
   configured gates before ordinary implementation planning (the planning gate requires the
   receipt named by `planning_prerequisite`).

## Consumer-owned artifacts

Everything under each repository's `config/discovery.json` and `docs/migration/discovery/`
(or its configured `artifacts` root) is consumer-owned: the profile, scope, inventory
snapshots, feature contracts, coverage ledger, characterization scenarios, evidence,
unspecified-behavior and product-decision records, source snapshots, implementation records,
parity matrix, acceptance specifications and reports; so are the target architecture
decisions and the implementation tests under the roots the target's owners select. The
example page lists the expected tree for each role. Framework output is limited to the
validated structure, generated drafts with explicit unknowns, receipts and reports; it
contains no feature catalog, no runtime result and no verification claim.

## Open items the owners must resolve locally

The framework cannot and does not answer these; they are discovered in each repository:

- missing source evidence for any feature whose observation state is `inferred`,
  `unknown` or `contradictory`;
- unresolved product decisions (`proposed`) and the owners who approve them;
- host or runtime capability reported `unsupported` by the probe or doctor;
- target implementation and verification work, including offline and mobile dimensions
  once the profile declares them applicable;
- repository-specific characterization tooling for manual or automated runtime capability.

## Reference

`docs/engineering/legacy-discovery-and-parity/` documents the architecture, profile,
artifacts, enforcement, migration, commands and maintenance; the separated example is
`docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`.
