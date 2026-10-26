# Publication and consumer handoff (issue #980)

This handoff states what must be published and what each consuming repository's owners do
locally afterwards. It does not inspect, populate or modify any consumer. `drmoisan/TaskMaster`
(legacy source) and `drmoisan/TMW` (modernization target) are named only here and in the
separated example `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`;
every repository-specific value below is a placeholder their owners resolve locally.

## Built artifacts (reconciled with the feature evidence)

| Artifact | Version | SHA-256 | Evidence |
|---|---|---|---|
| `drm_copilot_discovery-2.0.0-py3-none-any.whl` (built to `dist/discovery/`; runtime identity build `41962c07af41d7d073b4f85755b3b8131892c1ebb728f9c083869f4fe77a0a0d`, policy `22ea1fc0d8481000e0706006dbf26480c82024651b66b68ea6779db37e3168dc`) | 2.0.0 | `19e7dd456d854f02503cbfe36cc1b175b1582ee25ce0506beff4c2977121ccdd` | `evidence/qa-gates/discovery-installed-runtime.2026-10-23T14-13.md`, `evidence/qa-gates/p11t8-packaging-closure.2026-10-26T02-42.md` |
| `drm-copilot.vsix` (extension) | 1.1.22 | `a3bf8eedd136b8fe23911e259d232d4eccd1a4db3b3aa58f829f0f132acbd52a` | `evidence/qa-gates/discovery-installed-runtime.2026-10-23T14-13.md`, `evidence/qa-gates/p11t8-packaging-closure.2026-10-26T02-42.md` |
| `danmoisan-drm-copilot-mcp-1.1.22.tgz` (`@danmoisan/drm-copilot-mcp`) | 1.1.22 | `1e1709064ff100e3972738397f8ea1ea6e1690932bf91535b099aa42166eae2a` | `evidence/qa-gates/discovery-installed-runtime.2026-10-23T14-13.md`, `evidence/qa-gates/p11t8-packaging-closure.2026-10-26T02-42.md` |

The digests are those of the artifacts built from the final sources of the feature branch
during P11-T7 and inspected in P11-T8; they supersede the P10-T2 and P10-T3 digests
(`evidence/other/discovery-host-packages.2026-10-22T18-42.md`,
`evidence/other/discovery-wheel-build.2026-10-22T18-49.md`), which were built before the
installed-host repairs of P11-T7. A rebuild after further commits produces new digests, and
the published artifacts must be re-digested and the table updated at release time. The
independent installation proof is P11-T7 (`discovery-installed-runtime.2026-10-23T14-13.md`,
`discovery-native-capabilities.2026-10-23T13-49.md`).

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
