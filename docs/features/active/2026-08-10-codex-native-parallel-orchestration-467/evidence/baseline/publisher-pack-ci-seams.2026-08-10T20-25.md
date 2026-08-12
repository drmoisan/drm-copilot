# Publisher, Pack, Portable Asset, and CI Discovery Baseline

Timestamp: `2026-08-10T22-52`

## Required discovery command

Command: `rg -n 'codex-and-agents-customizations|blast-radius|compute-cohorts|parallel-manifest|core.json|pack|collision|destination|route|recursive|Pester|Bats' scripts extensions tests .github/workflows config`

EXIT_CODE: `0`

Output Summary: The search resolved the Python and TypeScript Codex publisher adapters, pack selectors and manifests, Claude routing-merge owner, issue-462 portable files, publisher/pack/parity tests, PoshQC discovery, shell discovery, Jest configuration, and reusable CI workflows. It returned 4,005 matching lines.

## Current publisher ownership

- Python entry point: `scripts/dev_tools/push_down_codex_and_agents_customizations.py`.
- Python selection/filtering helpers: `scripts/dev_tools/push_down_codex_pack_selection.py` and `scripts/dev_tools/push_down_codex_filesystem.py`.
- TypeScript entry point: `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`.
- TypeScript selection helper: `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`.
- Both current Codex publishers enumerate `.codex`, `.agents`, and a virtual `config/orchestration-routing.json` source. Neither currently selects the issue-462 `.claude` libraries or generic blast-radius configuration.
- `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` is the existing TypeScript destination-aware routing merge. There is no Python equivalent on the Codex publisher path.

The Phase 5 route-merge owner is therefore a generalized helper that preserves the existing `claude-routing-merge.ts` exports and Claude behavior, with a Python peer beside the Codex publisher. The Codex call sites will use the shared additive policy: retain destination-only routes and unrelated configuration, append source-only routes deterministically, accept identical same-name values, and reject substantive same-name collisions with the same stable reason in Python and TypeScript.

## Fixed issue-462 portable selection

The Codex publisher allowlist is exactly these destination-relative paths:

1. `.claude/lib/bash/compute-cohorts.sh`
2. `.claude/lib/bash/compute-concurrency-batches.sh`
3. `.claude/lib/bash/parallel-cohorts.sh`
4. `.claude/lib/bash/parallel-common.sh`
5. `.claude/lib/bash/parallel-items-validate.sh`
6. `.claude/lib/bash/parallel-manifest-validate.sh`
7. `.claude/lib/bash/parallel-yaml-emit.sh`
8. `.claude/lib/bash/parallel-yaml-scan.sh`
9. `.claude/lib/bash/validate-parallel-manifest.sh`
10. `.claude/lib/blast-radius/BlastRadius.psm1`
11. `.claude/lib/blast-radius/BlastRadiusConfig.psm1`
12. `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`
13. `.claude/lib/blast-radius/BlastRadiusGlob.psm1`
14. `.claude/lib/blast-radius/BlastRadiusValidation.psm1`
15. `config/blast-radius.json`

The 14 `.claude/lib` files are sourced from their canonical root paths for repository publication and from the sibling `extensions/drm-copilot/resources/claude-customizations/` tree for packaged publication. All 14 root/bundle pairs exist and have identical SHA-256 bytes.

The destination `config/blast-radius.json` must be sourced from `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, the pinned repo-agnostic issue-462 default. It must not use this repository's root `config/blast-radius.json`: their SHA-256 values differ (`e3db9fdecf9f4260f2164aec6525ba3288ed2333e5161ca79841d780ed29dd9b` versus `83af37a6c346b318dda679f41d4a950e022f03513fabd57755e4b1df41d67229`). The generic document contains none of `scripts/dev_tools`, `packages/mcp-server`, `poetry.lock`, or `package-lock.json`.

The allowlist excludes every containing `.claude/` directory, `.claude/rules/parallel-orchestration.md`, and every unrelated Claude asset. Equal existing portable files may be skipped; unequal portable collisions must reject identically in both publishers. The routing document is handled only by the additive merge policy.

## Pack closure decision

`core.json` is automatically loaded for every explicit selected pack in both `push_down_codex_pack_selection.py` and `codex-pack-selection.ts`. The complete Codex parallel dependency closure therefore belongs in `core.json`:

- the six `parallel-*` skills;
- the `parallel-planner` and `parallel-orchestrator` agents;
- all registered parallel hooks and shared hook modules;
- all generalized launcher and parallel runtime scripts;
- `.codex/config.toml`, `AGENTS.md`, and `config/orchestration-routing.json` changes;
- the exact 15-path portable allowlist above.

Exact applicable manifest: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` and its root/bundle counterpart established during Phase 5.

Justified exclusions: `python.json`, `powershell.json`, `typescript.json`, `csharp-modern.json`, and `csharp-legacy.json` receive no duplicate parallel entry. The new surface is language-neutral, and every selected language pack already includes `core`; duplicate membership must remain invalid. A later language-specific production dependency may enter its corresponding language manifest only if the Phase 5 closure tests demonstrate that dependency.

Current Codex manifest counts are core 84, Python 14, PowerShell 14, TypeScript 8, C# modern 9, and C# legacy 9. The existing Claude `core.json` independently confirms the issue-462 precedent by owning all 15 portable paths while every Claude language manifest owns zero of them.

## Root/bundle and contract baselines

Read-only SHA comparison of `.agents/**` and `.codex/**` produced:

- root scoped files: 207;
- bundle scoped files: 207;
- missing from bundle: 0;
- bundle-only scoped files: 0;
- SHA-256 mismatches: 0.

Existing validation owners to extend and rerun:

- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` — root/bundle runtime inventory and shared-config carriage.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` — real-filesystem manifest membership.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` and `test_push_down_codex_pack_selection.py` — Python publisher/selection behavior.
- `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` and `codex-pack-selection.test.ts` — TypeScript publisher/selection behavior.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` — established root/bundle SHA and registration-existence pattern.
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — config-driven registration/process coverage.

Focused Python command:

`poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_pack_selection.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`

Result: `PASS` — 35 tests passed in 0.30 seconds.

Focused TypeScript command:

`npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-pack-selection.test.ts test/lib/push-down/claude-config-carriage.test.ts --runInBand`

Result: `PASS` — 3 suites and 39 tests passed.

## Current recursive CI discovery

- Python: `.github/workflows/_quality-checks.yml` runs unfiltered `poetry run pytest`; `pyproject.toml` sets `testpaths = ["tests"]`. `poetry run pytest --collect-only -q tests/scripts/dev_tools` exited 0 and collected 3,691 tests.
- Extension TypeScript: `.github/workflows/_drm-copilot-extension-tests.yml` runs `npm --prefix extensions/drm-copilot run test`; `extensions/drm-copilot/jest.config.cjs` matches `**/test/**/*.test.ts`. Jest `--listTests` exited 0 and listed 183 files, including three current Codex push-down suites.
- PowerShell: `.github/workflows/_poshqc.yml` runs `Invoke-PoshQCTest -Root`; `config/poshqc-scan.json` and the Pester runsettings scan `scripts`, `tests/powershell`, and `tests/scripts`, while `PoshQC.Testing.psm1` uses recursive `*.Tests.ps1` enumeration. The current scan finds 110 Pester files, including 19 under `tests/scripts/codex-hooks`.
- Bats: `.github/workflows/_shell-coverage.yml` runs `bash scripts/bash/shell-qc.sh test --coverage`; `shell_qc_lib.sh` passes the `tests/shell` and `tests/bash` directories to Bats. The current `tests/shell` tree contains 21 Bats files, including 9 `parallel*` suites.
- Root TypeScript remains covered separately by `.github/workflows/_root-typescript-tests.yml` through `npm test` and the root Jest recursive match.

No current discovery gap exists for the planned test locations. Workflow edits are not authorized by this Phase 0 evidence. At `P5-T10`, enumerate the files actually created against these same selectors. `P5-T11` must record `NO_WORKFLOW_DELTA_REQUIRED` with zero workflow diff unless that final enumeration demonstrates an unmapped suite or a missing required G16 completion-validation gate; any permitted edit is limited to that demonstrated gap.
