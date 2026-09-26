# Code Review: Codex push-down payload self-sufficiency (#697)

---

**Review Date:** 2026-09-26
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-697` suffix matches the branch issue number.
**Base Branch:** `main` (merge base `26d57cb37f91e6a695f4ab4c1f57366229756fdc`)
**Head Branch:** `bug/codex-pushdown-self-sufficiency-697` @ `59c4fda88023355353d0802c826d62347f7d4662`
**Review Type:** Initial review

---

## Executive Summary

The branch makes the Codex customization payload usable in a destination repository. It removes a load-time registry dependency from `enforce-epic-planning-only.ps1`, corrects the `csharp-legacy` role file, publishes PowerShell equivalents of the two Python routing resolvers together with their modules, extends both publishers (Python and TypeScript) with a destination-to-resource pair map, anchors the `prepack.cjs` `scripts` exclusion, adds `commit-steward` to the PowerShell deployment port, and completes `core.json`. The review covered all 46 non-evidence files in the diff against `main`, the executor evidence under `evidence/`, the three coverage artifacts, and reviewer re-runs of every toolchain on the changed files.

**What changed:**
- PowerShell: `.codex/hooks/enforce-epic-planning-only.ps1` (registry read moved into the semantic-MCP branch behind a `-RegistryPath` parameter); new `.codex/scripts/codex-routing-cli-common.ps1`, `Resolve-CodexTopology.ps1`, `Resolve-CodexDeployment.ps1`; `commit-steward` in `CodexDeployment.psm1`; byte mirrors under `extensions/drm-copilot/resources/`.
- Python: `_RoutingConfigFileSystem` generalized to `VIRTUAL_RESOURCE_PAIRS` and `VIRTUAL_ROOT_FOLDERS`.
- TypeScript: `RoutingConfigFileSystem` generalized in the same way, adding the registry and schema pairs the MCP path previously omitted.
- CommonJS: `prepack.cjs` exclusion anchored to the resources root; `shouldCopy` exported; copy guarded by `require.main === module`.
- Data: `core.json` (+17 paths), role TOML, skill text, parity corpus and fixtures.

**Top 3 risks:**
1. Wrapper argument parsing reproduces the argparse behaviors covered by the corpus, but not argparse prefix abbreviation (`--lang`) or `-h/--help`. A caller that relied on those Python behaviors would get exit 2 from the wrapper. The skill text uses only full flag names.
2. Destinations fed by the MCP tool receive the `.codex/scripts` wrappers only after the next `@danmoisan/drm-copilot-mcp` release; until then, a destination under a preparation checkpoint denies registry-dependent MCP calls (intended fail-closed behavior, tracked by the potential entry).
3. The bundled `pester.runsettings.psd1` copy lists drm-copilot-specific coverage paths (`.codex/scripts/*`, joining the pre-existing `.claude/lib/codex-routing/*` entries). This follows the existing mirror contract, but those paths may not exist in every destination that runs PoshQC.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; every toolchain is clean on reviewer re-run, and changed-line coverage is complete in all three measured languages.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.codex/scripts/codex-routing-cli-common.ps1` | `ConvertFrom-CodexRoutingArgument`, lines 151-162 | The parser accepts only exact long-option names. Python argparse (default `allow_abbrev=True`) also accepts unambiguous prefixes such as `--lang` and provides `-h/--help`; the wrapper reports these as unrecognized (exit 2). | Either document the exact-name contract in the wrapper help, or add prefix matching and a help path with corpus cases. | The spec states that wrapper argument contracts equal the Python CLIs; the corpus does not exercise abbreviations, so the difference is untested either way. | `scripts/dev_tools/resolve_codex_topology.py:260`, `resolve_codex_deployment.py:226` (`argparse.ArgumentParser(description=__doc__)`, no `allow_abbrev`) |
| Minor | `.gitignore` | line 59 (`coverage/`) | The canonical evidence folder `evidence/coverage/` is ignored, so the seven AC-6.3 coverage-delta files exist on disk but are not in the branch. Zero `evidence/coverage/` files are tracked repository-wide, so this predates the branch. | Track separately: add `!docs/features/**/evidence/coverage/` (and its contents) to `.gitignore`. | Reviewers of the PR cannot see the AC-6.3 evidence without the local worktree. | `git check-ignore -v` reports `.gitignore:59:coverage/`; `git ls-files` count for `/evidence/coverage/` is 0 |
| Minor | `packages/mcp-server/prepack.cjs` | whole file | The file is outside the Jest collection root, so no committed coverage artifact measures it. Reviewer V8 block coverage shows only the `require.main === module` copy block (lines 55-61) unexecuted. | Optional: measure the script from a runner whose root includes `packages/mcp-server`. | Keeps packaging logic visible in coverage metrics. Not a prohibited exclusion (not under `src/`, T4 packaging script). | Reviewer `NODE_V8_COVERAGE` run over the test's path families; `evidence/coverage/typescript-coverage-delta.2026-09-26T00-25.md` branch mapping |
| Info | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | lines 110-115 | The bundled PoshQC settings now list `.codex/scripts/*.ps1` coverage paths, which exist only in drm-copilot and Codex destinations. | None required on this branch; the byte-parity test mandates the mirror. Consider path-existence filtering in PoshQC if a destination reports it. | Same pattern as the pre-existing `.claude/lib/codex-routing/*` entries. | `test_poshqc_bundled_module_files_match_repo_root_sources` passed |
| Info | `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` | process helpers | Tests start `pwsh` child processes resolved with `Get-Command` (41 hook invocations plus one per corpus case). | None; AC-2.4 and AC-4.7 require process invocation. | Follows `legacy-codex-hook-contracts.Tests.ps1`; stdout is read before stderr, which is safe for the small outputs involved. | Reviewer Pester run: 215 passed |
| Info | `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | lines 22-27, 158-171 | The probe covers the 17 PreToolUse registrations and asserts the 4 non-PreToolUse registrations are exactly the expected set, rather than probing them. | None; AC-2.4 specifies PreToolUse payloads. | The four excluded hooks do not receive PreToolUse input, so a PreToolUse probe would not be meaningful for them. | Test asserts 21 total, 17 probed, 41 invocations |
| Nit | `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | `SHARED_CONFIG_RELATIVE_PATHS` definition (module scope, after `VIRTUAL_ROOT_FOLDERS`) | Filtered generator expression has no intent comment immediately above it; the nearest comment describes `VIRTUAL_RESOURCE_PAIRS`. | Add a one-line comment stating that the tuple keeps the legacy name for the `config/` subset of the pair map. | `.claude/rules/self-explanatory-code-commenting.md` requires intent comments on non-trivial comprehensions. | Diff hunk at line 95 of the new file |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_RoutingConfigFileSystem` now answers each virtual root from the pair map only, and filters listed paths by `virtual_path.parent == root`, so a physical `config/unrelated.json` is never published and `.codex/lib/codex-routing` lists only its two modules.
- `SHARED_CONFIG_RELATIVE_PATHS` is derived from the pair map rather than duplicated, so the two cannot drift.
- The class docstring was expanded to the repository's required Purpose / Responsibilities / Key invariants / Attributes form.

#### Typing and API notes

- `VIRTUAL_RESOURCE_PAIRS: tuple[tuple[Path, Path], ...]` and `VIRTUAL_ROOT_FOLDERS: tuple[Path, ...]` are fully typed. No `Any`, `# noqa`, or `# type: ignore` added. Pyright clean.

#### Error handling and logging

- No exception handling changed. A pair whose resource file is absent is simply not listed, which matches the previous single-path behavior.

### TypeScript implementation audit

#### What changed well

- `RoutingConfigFileSystem` mirrors the Python class: a `ReadonlyMap` from source-rooted destination path to resource path, a `ReadonlySet` of virtual roots, and a single `resolve()` used by `isFile` and `readTextFile`.
- The MCP publishing path now delivers `config/orchestration-handoff-registry.json` and `config/orchestration-handoff.schema.json`, closing research finding F1.
- The new integration test drives the real bundle through production filesystem wrappers with an in-memory destination.

#### Type safety and maintainability

- `ReadonlyArray<readonly [string, string]>` for the pair map; no `any`. ESLint and `tsc` clean. A per-file `coverageThreshold` entry (85/75) was added for the changed module.
- `prepack.cjs` test uses two `@typescript-eslint/no-require-imports` disables, each with a specific rationale (the spy must patch the shared CommonJS `node:fs` object).

#### Error handling and logging

- No new error paths. `prepack.cjs` now performs the copy only when run as the main module, so requiring it has no side effect.

### PowerShell implementation audit

#### What changed well

- The hook fix removes the script-scoped registry load and reads the registry only when a non-lifecycle `mcp__` tool is evaluated in preparation mode. A missing registry now yields `Get-EpicPlanningDenyDecision` with a reason naming the path; a malformed registry still throws to the existing top-level catch (exit 2). This preserves fail-closed behavior while removing the every-call exit 1.
- The wrappers separate parsing, module resolution, resolver invocation, and serialization, return a result object from an `Invoke-*Cli` function, and write to the console only in the entry block guarded by `$MyInvocation.InvocationName -eq '.'`. This makes every branch testable in process, and the reported coverage is 100% for all three new files.
- `ConvertTo-CodexRoutingJsonString` escapes per UTF-16 code unit with lowercase `\uXXXX`, matching Python `ensure_ascii=True`; the corpus includes a non-ASCII `--language` case, settling the research §16 open question by test.

#### API and safety notes

- All new functions use `[CmdletBinding()]`, `[OutputType()]`, and `Mandatory` parameters. `New-CodexRoutingCliResult` declares `SupportsShouldProcess` to satisfy the analyzer rule for the `New` verb and documents that it changes no state.
- Module candidates are fixed relative paths from `$PSScriptRoot`; no user-controlled path reaches `Import-Module`.
- PSScriptAnalyzer (repo settings) reports 0 findings; `Invoke-Formatter` reports no drift.

#### Error handling and logging

- Usage errors exit 2 with an argparse-style message; resolver `ArgumentException` exits 1 with the module message; no candidate module exits 1 with `CODEX_ROUTING_MODULE_NOT_FOUND` and the candidate list. Other exceptions propagate, which makes `pwsh -File` exit non-zero rather than silently succeeding.

---

## Test Quality Audit

The branch adds 6 Python, 5 PowerShell, and 4 TypeScript test files (new or modified). Each AC-bearing test was recorded failing before the fix and passing after it under `evidence/regression-testing/`. Reviewer re-runs: 657 pytest, 19 Jest, and 215 Pester cases passed; the worktree stayed clean.

### Reviewed test and QA artifacts

- `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` — AC-3.1 to AC-3.8, including the AST check that no top-level statement calls the registry reader, and equivalence of `apply_patch`/`Bash` decisions with and without a registry.
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` — runs every bundled PreToolUse hook from the bundle location; rejects the legacy `{"decision":"allow"}` shape; confirms no `.codex/state` is created in the bundle.
- `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` and `tests/scripts/dev_tools/test_codex_routing_cli_corpus.py` — the corpus is proven against the Python CLI in process, and the wrappers are proven against the corpus both in process and through `pwsh -File`.
- `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` — guard computes the dot-source closure for the three forms and fails when a registered hook is absent from `core.json`.
- `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts` — real-bundle publish in full-tree, `typescript` pack, and `csharp-legacy` pack modes.
- `evidence/regression-testing/fail-before-*.md` / `pass-after-*.md` — seven fail-before / pass-after pairs.

### Quality assessment prompts

- **Determinism:** committed corpus and fixtures; no clock, randomness, or network; no temporary files (search of new tests found none).
- **Isolation:** one behavior per test; parametrized cases for matrices.
- **Speed:** pytest 1.01 s and Jest 0.40 s for the targeted sets; Pester process tests are the slowest component.
- **Diagnostics:** the hook probe aggregates every failing pair with exit code and both streams into one message.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or `.env` files. |
| No unsafe subprocess or command construction | ✅ PASS | No `Invoke-Expression`; wrappers call exported module commands through `&` with named parameters; tests use `ProcessStartInfo.ArgumentList`. |
| Input validation at boundaries | ✅ PASS | Choices checked case-sensitively (`-cnotcontains`), integers parsed with `InvariantCulture`, required flags enforced before module import. |
| Error handling remains explicit | ✅ PASS | Missing registry denies (fail closed); malformed registry throws; catch blocks are type-specific. |
| Configuration / path handling is safe | ✅ PASS | Virtual roots never walk the physical `config/` directory; no physical `.codex/lib/` exists (verified by `ls` and by `test_no_physical_codex_lib_directory_exists`). |
| Non-goals preserved | ✅ PASS | `git diff --name-only 26d57cb3..HEAD` lists no change to `packages/mcp-server/package.json`, `.claude/hooks/**`, or either `.codex/config.toml`. |
| Mirror parity | ✅ PASS | `git rev-parse HEAD:<path>` blob hashes equal for all 9 source/mirror pairs checked. |

---

## Research Log

No external research was required. Parity claims were checked against the in-repository Python sources (`scripts/dev_tools/resolve_codex_topology.py`, `resolve_codex_deployment.py`) and the MCP tool definitions (`extensions/drm-copilot/src/mcp-tool-definitions.ts:440-445` confirm the `require_codex_topology` and `require_codex_model_routing` arguments named in the repointed skill; `validate_orchestration_artifacts` is in the bundle `enabled_tools`).

---

## Verdict

The change is ready for the normal PR flow. The implementation matches the spec's design, preserves fail-closed authorization for registry-dependent calls, and keeps the `.claude/lib/codex-routing` modules as the single authored source with test-guarded byte mirrors. Toolchains are clean on reviewer re-run, and no changed line is uncovered in Python, TypeScript, or PowerShell.

The three Minor findings do not block merge: the argparse abbreviation difference is outside the spec'd corpus and the skill uses full flag names; the gitignored `evidence/coverage/` folder is a pre-existing repository-level issue; and `prepack.cjs` coverage is a measurement-scope observation for a fully tested packaging script. They are suitable for follow-up items rather than remediation on this branch.
