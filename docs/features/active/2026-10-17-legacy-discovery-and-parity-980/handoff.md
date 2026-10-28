# Publication and consumer handoff (issue #980)

This handoff states what must be published and what each consuming repository's owners do
locally afterwards. It does not inspect, populate or modify any consumer. `drmoisan/TaskMaster`
(legacy source) and `drmoisan/TMW` (modernization target) are named only here and in the
separated example `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`;
every repository-specific value below is a placeholder their owners resolve locally.

## Built artifacts (reconciled with the feature evidence)

| Artifact | Version | SHA-256 | Evidence |
|---|---|---|---|
| `drm_copilot_discovery-2.0.0-py3-none-any.whl` (built to `dist/discovery/`; runtime identity build `a4a41346b85867ec445687575c1e94ba7d5478631e81965d272d51051b222b95`, policy version 2, policy `7428cac9564b87547857631946c45493e9d6b70ddeadbdd7b1dcdf537304f276`) | 2.0.0 | `59652fe9ab2c3dc475be9c8c7e35b099fe2d3a0d2db0fae308a007f777c7136f` | `evidence/other/discovery-wheel-build.2026-10-28T13-21.md` |
| `drm-copilot.vsix` (extension) | 1.1.22 | `834cb08195301399242742d06fd19496e406f761757546a4e17e5d47eb9a9b48` | `evidence/other/discovery-host-packages.2026-10-28T13-21.md` |
| `danmoisan-drm-copilot-mcp-1.1.22.tgz` (`@danmoisan/drm-copilot-mcp`) | 1.1.22 | `1bebefbc5899149e461d6fefb39d1369844ae2256584ca23265da4fb56e2b01c` | `evidence/other/discovery-host-packages.2026-10-28T13-21.md` |

The digests are those of the artifacts rebuilt from the Phase 12 sources in P12-T11; they
supersede the P11-T7/P11-T8 digests (wheel `19e7dd45…`, VSIX `a3bf8eed…`, npm `1e170906…`),
which were built before the host-principal completion path landed. The wheel's resource
manifest now carries 40 entries, including `schemas/discovery/v2/start-attestation.schema.json`,
and the runtime policy version advanced from 1 to 2 with the Phase 12 request rules. A rebuild
after further commits produces new digests, and the published artifacts must be re-digested
and the table updated at release time. The installed-host proof for these artifacts is P12-T12
(the lexicographically greatest `evidence/qa-gates/discovery-installed-runtime.*.md` and
`discovery-native-capabilities.*.md`); the earlier P11-T7 proof covered the previous build.

## Known installed-host limit (blocker carried from P11-T7 and P11-T9)

The installed Python runtime provides only the `local-user` principal: `service._local`
refuses `prepare-agent`, `finalize-agent`, agent-output mode and every invocation or
authorization reference, and `installed_local_io` rejects the `host` principal. As a
consequence `finalize_discovery_agent` and agent-scoped `read_discovery_source` fail on
every installed host, no completion receipt (`validation-receipt`) can be minted, and a
discovery specialist's stop is always blocked with "not finalized through
finalize_discovery_agent". The native start, tool and stop controls still fail closed as
observed in P11-T7; the receipt-accepting stop and the stale-receipt block are proven only by
the in-process suites. Step 6 and step 7 below therefore cannot be completed through
discovery agents until a host-principal service composition ships; the console path
(`validate-all`, reports, `snapshot-export`, `snapshot-import`) is unaffected. This is an
explicit open item for the next plan, not a consumer task.

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
