# Code Review: epic wave-computation push-down (#1129)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129`
**Feature Folder Selection Rule:** Named by the caller and matching the issue number 1129.
**Base Branch:** `origin/main` (merge base `cdcff3871765396183590128e142a929cf78327b`)
**Head Branch:** `bug/epic-wave-computation-pushdown` (`ef5f602e25582123cfb29972168a26ab9f82abeb`)
**Review Type:** Initial review

---

## Executive Summary

The branch ports the epic wave-layering computation to PowerShell (`.claude/lib/epic-wave/EpicWave.psm1` and `Invoke-EpicWave.ps1`), mirrors it byte-for-byte into the Claude bundle and the Codex stored resources, publishes it for Codex through `VIRTUAL_RESOURCE_DIRECTORIES` in both the Python and TypeScript push-downs, extends the Codex planning-only hook allowlist, grants the CLI to two agents, rewrites only the wave-layering sentences in four skill files and one agent file, makes the Python reference reject unresolved references, adds a shared eight-case corpus, and adds a regression test that fails on an unshipped epic citation. The diff has 74 files; production logic is a 222-line module, a 26-line CLI, a 60-line Python change, and 5 lines of TypeScript.

I verified by execution: the CLI under real `pwsh` (exit 0, 1, 2), a base-versus-head replay of the citation test against `git show origin/main` surface text, `cmp` byte equality of every mirror, the coverage artifacts, and `git merge-tree` against a freshly fetched `origin/main` (clean). No blocking finding was found.

**What changed:**
New PowerShell module and CLI with bundled and Codex mirrors; Python reference extended with `EpicWaveUnresolvedReferenceError`; validator catches the new error; hook gains one anchored pattern; two agents gain one `Bash(...)` grant; skills and the orchestrator agent cite the shipped CLI; two pack manifests gain entries; `quality-tiers.yml` gains a T3 project; frozen-surface digests are re-pinned with a `RE-BASELINED by issue #1129` note; new tests and fixtures.

**Top 3 risks:**
1. The PowerShell and Python implementations differ on two inputs the corpus does not exercise (case-differing keys through the CLI, and a manifest holding both a cycle and an unresolved reference).
2. The citation test's path pattern does not see `./scripts/...` or `-m scripts.dev_tools.<module>` forms, and covers eight surfaces only.
3. AC11 (full toolchain on CI and the PR statement about refreshing the push-down) cannot be verified until the pull request exists.

**PR readiness recommendation:** **Go** — all verifiable ACs are met with execution-level evidence, and the remaining observations are non-blocking hardening.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/epic-wave/EpicWave.psm1` | `ConvertFrom-Json` call, lines 199-203 | A manifest whose keys differ only by case (`{"a":[],"A":["a"]}`) exits 2 with `Manifest is not valid JSON ... keys with different casing`, although the module help states that feature names compare case-sensitively and the Python reference accepts such a manifest. | Parse with `-AsHashTable` (PowerShell 7+) or note in the help that the CLI route rejects case-differing keys. | Parity claim in the help text is true for `Get-EpicWaveNumber` but not for the CLI; the failure is loud (exit 2), so no wrong waves are produced. | Reviewer probe: `pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1 -ManifestPath case.json` printed the casing error and `exit=2`. |
| Minor | `.claude/lib/epic-wave/EpicWave.psm1` and `scripts/dev_tools/epic_wave_computation.py` | `Get-EpicWaveNumber` lines 112-125; `resolve` lines 173-200 | Error precedence differs. PowerShell checks every self-loop, then every unresolved reference, then cycles. Python checks unresolved references lazily during traversal, so `{"b":["a"],"a":["b"],"c":["ghost"]}` raises the cycle error in Python and `EPIC_WAVE_UNRESOLVED_REFERENCE` in PowerShell; with `c` first Python raises the unresolved error. | Either order the Python checks the same way (validate all references before recursing) or add a mixed-error case to the corpus with an agreed expectation. | Both reject the manifest, so safety holds; the divergence only changes which message a planner reads, and the corpus cannot reveal it. | Reviewer probe with `compute_wave_numbers` on two key orders: `EpicWaveCycleError`, then `EpicWaveUnresolvedReferenceError`; PowerShell probe printed the unresolved message with exit 1. |
| Minor | `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | `_PATH_PATTERN` lines 59-63; surface lists lines 37-48 | The pattern skips `./scripts/x.py` and `/repo/scripts/x.py` (the lookbehind excludes `/`), and does not see the module form `python -m scripts.dev_tools.<module>`. The surface list covers four Claude and four Codex files, not `epic-run`, `review-epic`, or `epic-review`. A recurrence in those spellings or files would pass the test. | Add the `./` prefix and the `-m scripts.dev_tools.` form to the pattern, and consider a glob over every `epic-*` skill and agent. | The test is the recurrence guard named by the spec; widening it keeps the guard honest. A scan of the omitted surfaces found no unshipped `scripts/` citation today. | Reviewer probe printed `[]` for `see ./scripts/dev_tools/x.py`, `run python -m scripts.dev_tools.x`, and `path=/repo/scripts/x.py`, and printed the path for backticked and parenthesised forms. |
| Info | `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | `test_every_epic_surface_citation_is_shipped` | The test does fail on the pre-fix surfaces. Replaying the helpers on `git show origin/main:<surface>` text plus the `origin/main` manifests returned `scripts/dev_tools/epic_wave_computation.py` for both the Claude and the Codex set; at `HEAD` both lists are empty. | None. | Confirms the regression test discriminates, independent of the fail-before artifact. | Reviewer replay script output: `origin/main ['scripts/dev_tools/epic_wave_computation.py'] ['scripts/dev_tools/epic_wave_computation.py']`, `HEAD [] []`. |
| Info | `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | `ALLOWLIST` lines 52-57 | The allowlist holds one entry with a reason naming `validate_orchestration_artifacts`; the reason test pins the set and the name, and the stale test fails when no surface cites the entry. Both Claude and Codex surfaces cite it (`epic-orchestrate` SKILL line 346, `epic-orchestrator` agent line 145). | None. | The allowlist is reasoned and stale-checked, as AC10 requires. | Grep of the cited lines; `test_allowlist_has_no_stale_entry` green in the pytest gate. |
| Info | `.codex/hooks/enforce-epic-planning-only.ps1` | pattern added at line 161 | The new pattern is anchored at both ends, fixes the script path, allows only `-ManifestPath` followed by a path-character set (`[A-Za-z0-9_./:\\-]`), and rejects spaces, `;`, `&`, `|`, `$`, quotes, and backticks. The multi-line case fails because `$` matches only at the end (or before a final newline). The existing `epic_wave_computation` Python pattern is kept. | None. | The allowlist widening is minimal; `..` in the path only lets the CLI read a different JSON file, which does not change the write boundary. | Hook diff; new cases in `codex-planning-only-hook.Tests.ps1` (allow three, reject two including a chained command); bundled twin `cmp` equal. |
| Info | `.claude/agents/epic-planner.md`, `.claude/agents/epic-orchestrator.md` | `tools:` lists | Each gains exactly `Bash(pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1*)`, matching the existing `ci-gate` grant form. No Claude-side planning hook references the wave script. The Codex TOML variants carry no `tools:` list, and the generator check exits 0. | None. | Grant scope equals the CLI path only. | Agent diffs; `generate_codex_agent_variants --check` EXIT_CODE 0. |
| Info | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | `PINNED_FROZEN_SURFACE_HASHES` and the note above it | Both digests are re-pinned with a `RE-BASELINED by issue #1129` note stating what changed in each surface and that the pin stays live. The digests are not removed or loosened; the frozen-surface test passes in the pytest gate. | None. | No gate was weakened. | File diff; `test_frozen_epic_surface_matches_pinned_baseline_digest` named green in `py-pytest.2026-11-08T14-47.md`. |
| Info | `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-plan/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md` | diff hunks | Hunks touch only the wave-layering sentence (`epic-plan` step 4; `epic-orchestrate` `## Wave Assignment` reference line; the `## Wave Scheduling` paragraph) plus the one agent `tools:` line. Codex text cites `.codex/lib/epic-wave/`, Claude text cites `.claude/lib/epic-wave/`; the Python module is described as this repository's parity reference. | None. | Meets the confinement invariant that protects concurrent edits from #1130. | `git diff origin/main...HEAD` for the five files; bundled copies `cmp` equal. |

No Blockers or Major findings. No covered file reaches 700 logical lines, so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `EpicWaveUnresolvedReferenceError` carries `feature_folder` and `dependency` and a stable message; `compute_wave_numbers` raises it before recursing into an absent key, and the validator catches it beside the cycle error with a reason comment.
- Python docstrings and intent comments follow the repository commenting rule.

#### Typing and API notes

- Full type annotations; no `Any`; no suppression added. The new exception is a new public API and is listed in the spec.

#### Error handling and logging

- Fail-fast with specific exceptions; no broad catch. See the precedence observation in the Findings Table.

### TypeScript implementation audit

#### What changed well

- The `VIRTUAL_RESOURCE_DIRECTORIES` entry mirrors the Python constant exactly; the new Jest test asserts publication under `.codex/lib/epic-wave/` and `VIRTUAL_ROOT_FOLDERS` membership.

#### Type safety and maintainability

- A two-line data change to a `ReadonlyArray<readonly [string, string]>`; no type change.

#### Error handling and logging

- No new runtime path.

### PowerShell implementation audit

#### What changed well

- `Get-EpicWaveNumber` copies the manifest into ordinal dictionaries, never mutates the caller's dictionary, and sorts names ordinally, so output order is deterministic.
- The module follows the `ClaudeLibModuleConvention` (strict mode, `$ErrorActionPreference`, the sibling-import sentence) and is thin to test through the injected reader.
- The CLI reads at most one path, writes stdout and stderr, and exits with the returned code; I confirmed exit 0 with `{"a":2,"b":1,"c":0}` for a chain, exit 1 with the unresolved message, and exit 2 with no argument.

#### API and safety notes

- Advanced functions with `OutputType`; approved verbs; no state-changing operation, so ShouldProcess does not apply. The recursion is depth-first and fine for manifests of tens of nodes.
- A non-`EPIC_WAVE_*` exception is rethrown from `Invoke-EpicWaveCommand`; under `pwsh -File` an unhandled throw also yields exit 1, which shares the code with a manifest error. This is an unlikely internal-error path and is noted for awareness only.

#### Error handling and logging

- Three distinct stable prefixes; usage errors map to exit 2 with an `EPIC_WAVE_USAGE:` prefix.

---

## Test Quality Audit

The change is well covered by deterministic tests: a shared corpus drives a pytest lane and a Pester lane, error classes and exit codes have direct tests, the hook has positive and negative cases, and the publication path has Python and Jest tests plus a byte-parity test.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/epic-wave/EpicWave.Parity.Tests.ps1` and `EpicWave.Tests.ps1` — 9 and 25 tests, committed fixtures only, module removed in `AfterAll`.
- `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py` — parametrized over the corpus; `self_loop` expects the Python cycle error, which is documented, while Pester distinguishes `EPIC_WAVE_SELF_LOOP`.
- `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` — verified to fail on pre-fix text by replay.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py`, `extensions/drm-copilot/test/lib/push-down/codex-agents-epic-wave-directory.test.ts` — publication and byte equality.
- `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info` — new PowerShell files 56/56 and 5/5 lines; `epic_wave_computation.py` 34/34 lines and 12/12 branches; `codex-agents-customizations.ts` 390/394 lines and 67/70 branches.
- `evidence/regression-testing/citation-test-fail-before.2026-11-08T14-04.md` — ExpectedExitCode 1 and EXIT_CODE 1, one failing test named.

### Quality assessment prompts

- **Determinism:** no clock, randomness, network, or temp file; the reader is injected.
- **Isolation:** one behavior per test; module imported and removed per file.
- **Speed:** in-memory tests; the full gates ran in parallel.
- **Diagnostics:** assertion messages name the unshipped paths and allowlist entries. The Pester `Run`-level corpus tests carry per-case names.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | `ps-leak-scan` artifact EXIT_CODE 0; no credentials in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | The module spawns nothing; the hook pattern is anchored and character-class bound. |
| Input validation at boundaries | ✅ PASS | `ConvertTo-EpicWaveManifest` rejects non-objects, non-array values, and non-string items with exit 2. |
| Error handling remains explicit | ✅ PASS | Three prefixes, usage prefix, rethrow of unknown exceptions. |
| Configuration / path handling is safe | ✅ PASS | `Get-Content -Raw -LiteralPath` avoids wildcard expansion; mirrors and manifests are byte-equal and listed. |
| Mirror and bundle parity | ✅ PASS | `cmp` equal for the two lib files in both bundles, the Claude skills and agents, the Codex skills, and the hook twin; both `core.json` files list the new paths. |
| Branch currency | ✅ PASS | `origin/main` is the merge base; `git merge-tree --write-tree origin/main HEAD` exited 0. |

---

## Research Log

No external research was required; the review relied on repository files, `git show`, and local execution.

---

## Verdict

The change is ready for normal pull-request flow. Each focus area holds: the PowerShell port matches the Python reference on the corpus and fails closed on the two probed differences, the citation test discriminates and its allowlist is reasoned and stale-checked, no gate or pinned digest is weakened, mirrors and manifests are byte-equal, Codex publication is wired in both languages, the hook pattern is tight, the agent grants are scoped to the single CLI path, the re-pin note is present, and skill text edits stay in the wave-layering sentences.

The three Minor findings are optional hardening and do not block. The pull request must still carry the statement that destinations refresh the push-down after an extension rebuild and reinstall, and CI must be green before AC11 is checked.
