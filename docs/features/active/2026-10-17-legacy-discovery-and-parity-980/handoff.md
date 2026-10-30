# Publication and consumer handoff (issue #980)

This handoff states what must be published and what each consuming repository's owners do
locally afterwards. It does not inspect, populate or modify any consumer. `drmoisan/TaskMaster`
(legacy source) and `drmoisan/TMW` (modernization target) are named only here and in the
separated example `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`;
every repository-specific value below is a placeholder their owners resolve locally.

## Built artifacts (reconciled with the feature evidence)

| Artifact | Version | SHA-256 | Evidence |
|---|---|---|---|
| `drm_copilot_discovery-2.0.0-py3-none-any.whl` (built to `dist/discovery/`; runtime identity build `3396ea3ba30a68d644ca8d2e020a21f3d3daaf09eddd162d875445291be716fc`, policy version 2, policy `cfdab7095fe66234358a8da535553b9ac9c73ea7b1639837150722b529fc38a3`) | 2.0.0 | `8993309f9ee392536a6619cf8b5c694e498a712aa72b7873044746ada16deb85` | `evidence/qa-gates/discovery-installed-runtime.2026-10-30T01-47.md` (build sequence in `evidence/other/discovery-wheel-build.2026-10-30T01-47.md`) |
| `drm-copilot.vsix` (extension) | 1.1.23 | `c9eda59dcc170b2572168594286df72cd293ae39f62ab61ee5910dbfd3a5f88a` | `evidence/qa-gates/discovery-installed-runtime.2026-10-30T01-47.md` (build sequence in `evidence/other/discovery-host-packages.2026-10-30T01-47.md`) |
| `danmoisan-drm-copilot-mcp-1.1.23.tgz` (`@danmoisan/drm-copilot-mcp`) | 1.1.23 | `6c04864ea2e9b45ed2248ef4e29424d4c6a0cb8dff3333c18bf6ffe8bd74a56d` | `evidence/qa-gates/discovery-installed-runtime.2026-10-30T01-47.md` (build sequence in `evidence/other/discovery-host-packages.2026-10-30T01-47.md`) |

The digests are those of the artifacts rebuilt in P16-T6 from the remediated tree (remediation
cycle 1: identity from the host hook payload only, fail-closed unbound calls, the
observation-based capability probe and the content-keyed schema registry cache); the package
versions moved from 1.1.22 to 1.1.23 with the rebase onto main. They supersede the P14-T12
digests (wheel `566679a0…`, VSIX `efe92788…`, npm `ca38e6fb…` as
`danmoisan-drm-copilot-mcp-1.1.22.tgz`), the P12-T12 digests (wheel `dca943be…`, VSIX
`bc33e805…`, npm `7cc66e5e…`), the P12-T11 digests (wheel `59652fe9…`, VSIX `834cb081…`, npm
`1bebefbc…`) and the P11-T7/P11-T8 digests (wheel `19e7dd45…`, VSIX `a3bf8eed…`, npm
`1e170906…`). The wheel's resource manifest now carries 42 entries, including
`schemas/discovery/v2/root-grant.schema.json` and
`schemas/discovery/v2/host-observation.schema.json`, and the runtime policy version stays 2. A
rebuild after further commits produces new digests, and the published artifacts must be
re-digested and the table updated at release time. The installed-runtime proof for these
artifacts is P16-T6 (the lexicographically greatest
`evidence/qa-gates/discovery-installed-runtime.*.md`). The per-host observation record for the
payload-identity design is P16-T7 (`evidence/qa-gates/discovery-host-observations.*.md`); the
earlier `evidence/qa-gates/discovery-native-capabilities.*.md` records (P11-T7, P12-T12) were
harness-simulated runs against previous builds, as `## Installed-host agent path` states.

## Installed-host agent path (implemented in Phase 12, requalified in remediation cycle 1)

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
mints the `agent-output` `validation-receipt` that the stop hook accepts. The P12-T12 runs
recorded in `evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md` were
harness-simulated host events: the hooks were driven as real processes from `SCRATCH`
launchers that exported the identity under the retired `DRM_DISCOVERY_*` contract, so they
prove the installed packages and the receipt chain against the shipped digests above
(prepare, attested start, agent-scoped `read_discovery_source`, granted
`create_discovery_artifact`, finalize `pass` with `output_valid` true, the stop allowed with
that receipt, the stop blocked after an input edit, a replayed controlled call denied
`AUTHORIZATION_CONSUMED`, `finalize-agent` as `local-user` refused `SERVICE_AUTHORITY`
(exit 3) and an unattributed host principal refused at exit 2), but they are not
observations of a real Claude Code, Codex or Copilot host payload. Remediation cycle 1 moved
identity to the host hook payload only (`docs/engineering/legacy-discovery-and-parity/enforcement.md`,
`## Identity source`); the per-host observation record of that design is the P16-T7 table
(`evidence/qa-gates/discovery-host-observations.*.md`, lexicographically greatest), and only
a row that cites an observation document claims a host observation.
`docs/engineering/legacy-discovery-and-parity/enforcement.md` (`## Host-principal path`)
describes the route, the records and every refusal class.

What remains for the consumers is the work itself, not a framework gap: step 6 and step 7
below can be run through discovery agents or through the console path (`validate-all`,
reports, `snapshot-export`, `snapshot-import`), and each attempt needs its own prepared
invocation (one prepared invocation admits one start; a second prepare for the same
specialist in one session makes the start ambiguous and is denied).

## Delivery status (executor handoff, P16-T11)

Every plan task is checked with canonical proof (`evidence/qa-gates/p16-handoff-validation.*.md`,
lexicographically greatest): all 156 tasks of Phases 0 to 16, including the 34 tasks of
remediation cycle 1. The final gates ran on the remediated tree in Phase 16:
`evidence/qa-gates/p16-python-*.2026-10-30T00-42.md`, `p16-typescript-*.2026-10-30T01-40.md`,
`p16-powershell-*.2026-10-30T01-29.md`, `p16-coverage-comparison.2026-10-30T01-41.md`,
`evidence/regression-testing/p16-isolation.2026-10-30T01-45.md`,
`discovery-installed-runtime.2026-10-30T01-47.md`, `discovery-host-observations.2026-10-30T01-47.md`,
`p16-repository-contracts.2026-10-30T01-55.md`, `acceptance-criteria-status.2026-10-30T01-58.md`
and `self-review.2026-10-30T02-04.md` (0 FAIL rows); `completion-report.md` lists them. The
review findings of 2026-10-29T13-16 (R1 to R4, the Major and every Minor) are closed by the
tasks named in `acceptance-criteria-status.2026-10-30T01-58.md`. Not yet done, and not claimed:
the independent re-review of remediation cycle 1 (AC-64 "Feature review reports no blocking
defects.", the seeded condition for the final full feature review, deliverable D20), a live
per-host observation (orchestrator-driven, instructions in
`discovery-host-observations.2026-10-30T01-47.md`) and exact-head CI on the pull request the
orchestrator opens. No open blocker remains from the executor's side.

Remediation cycle 2 (Phases 17 and 18) answers the 2026-10-30T10-19 re-review. Its Blocker R5
is closed: the sentinel tool consumes its grant by writing the exclusive `.consumed` latch beside
the observation record, the record is never rewritten, and the capability probe proves
consumption from that latch (shared fixture P17-T2, fail-before run P17-T3, probe correction
P17-T4, cross-runtime smoke over a real filesystem store P17-T5, mirrors P17-T6). Two open items
are deferred to follow-up issues by user decision and are not preconditions of the cycle exit
gate: #1007 (the root-grant Minor: strict decode of every `root-grants/` entry and no pruning)
and #1008 (the shell-observation Nit: the `SHELL` deny observation is matched by `agent_id`
only); the record is `evidence/other/p17-deferred-findings.*.md` (lexicographically greatest).
The Phase 18 gates for the touched languages are recorded by P18-T8.

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
2. **Host package.** Install the tested extension (1.1.23) or configure the standalone
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

Two repository follow-ups are open in this repository rather than resolved locally, deferred by
user decision in remediation cycle 2: #1007 (root-grant pruning and tolerant decode of
neighbouring entries) and #1008 (handler-hash and TTL checks on the `SHELL` deny observation).

## Reference

`docs/engineering/legacy-discovery-and-parity/` documents the architecture, profile,
artifacts, enforcement, migration, commands and maintenance; the separated example is
`docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`.
