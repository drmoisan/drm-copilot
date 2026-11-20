# Feature Audit: epic wave-computation push-down (#1129)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129`
**Base Branch:** `origin/main`
**Head Branch:** `bug/epic-wave-computation-pushdown`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `cdcff3871765396183590128e142a929cf78327b`)
- **Head branch/commit:** `bug/epic-wave-computation-pushdown` (commit `ef5f602e25582123cfb29972168a26ab9f82abeb`)
- **Merge base:** `cdcff3871765396183590128e142a929cf78327b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (not read in full; the diff was taken directly with `git diff origin/main...HEAD`)
  - Feature evidence: `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** The caller stated `full-bug`; `issue.md` carries the same marker, so `spec.md` is the only AC source.
- **Scope note:** The head commit is a plain merge of `origin/main`; a freshly fetched `origin/main` equals the merge base, so the branch is current and `git merge-tree --write-tree` against it exits 0.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/spec.md` — only source

### Acceptance criteria

1. `.claude/lib/epic-wave/EpicWave.psm1` and `Invoke-EpicWave.ps1` exist, are byte-equal in `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/`, and are listed in the Claude `core.json`; proven by `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py`.
2. The module returns `0` for no dependencies and `1 + max(wave(d))` otherwise for every non-error corpus case (empty, single, chain, diamond, multiple roots); proven by `EpicWave.Parity.Tests.ps1`.
3. The module rejects a cycle, a self-loop, and an unresolved reference with three distinct, stable messages; proven by `EpicWave.Tests.ps1`.
4. `Invoke-EpicWave.ps1` exits 0 on success, 1 on cycle or unresolved reference, and 2 on a missing argument or unreadable file; proven by `EpicWave.Tests.ps1`.
5. `scripts/dev_tools/epic_wave_computation.py` raises `EpicWaveUnresolvedReferenceError` for an unresolved reference, and a pytest lane and the Pester lane both pass over `tests/fixtures/epic_wave/wave-computation-cases.json`; proven by `test_epic_wave_corpus_parity.py` and `EpicWave.Parity.Tests.ps1`, with `test_epic_wave_computation.py` still passing.
6. The Codex push-down publishes `.codex/lib/epic-wave/` through `VIRTUAL_RESOURCE_DIRECTORIES`; proven by `test_push_down_codex_and_agents_virtual_paths.py` and the Codex `core.json` closure test.
7. `.codex/hooks/enforce-epic-planning-only.ps1` and its bundled twin allow the CLI command and still allow the `epic_wave_computation` Python pattern; proven by new cases in `tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1`.
8. `epic-planner.md` and `epic-orchestrator.md` list `Bash(pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1*)`, with bundled copies and generated Codex variants regenerated; proven by `generate_codex_agent_variants.py --check` and the push-down resource contract tests.
9. The wave-layering sentences in `epic-plan` and `epic-orchestrate` SKILL.md (Claude, Codex, bundled copies) and in `.claude/agents/epic-orchestrator.md` cite the shipped CLI (Codex text cites `.codex/lib/epic-wave/`), keep the Python module only as a repository parity reference, and change nothing else; proven by the mirror contract tests and `test_frozen_epic_surface_matches_pinned_baseline_digest` after re-pinning with a `RE-BASELINED by issue #1129` note.
10. `test_epic_skill_script_citations_shipped.py` passes after the fix, fails on the pre-fix tree, requires an allowlist reason naming the MCP route for `scripts/dev_tools/validate_epic_orchestrator_state.py`, and fails on a stale allowlist entry.
11. The full toolchain (format, lint, type-check, architecture, unit, contract, integration) passes in a single pass, and the PR states that destinations must refresh the push-down after an extension rebuild and reinstall.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Module and CLI exist, bundled byte-equal, listed in Claude `core.json` | PASS | Both files present at `.claude/lib/epic-wave/`; `cmp` reports equal against `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/`; `core.json` lines 272-273 list both; the three named contract tests are green in the pytest gate (16555 passed, 0 failed). | `cmp .claude/lib/epic-wave/EpicWave.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicWave.psm1` | Reviewer ran `cmp` on both files. |
| 2 | Wave formula for every non-error corpus case | PASS | Corpus holds empty, single, chain, diamond, multiple-roots; `EpicWave.Parity.Tests.ps1` (9 tests) green in `ps-pester.2026-11-08T14-47.md`; reviewer ran the CLI on a three-node chain and received `{"a":2,"b":1,"c":0}`. | `pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1 -ManifestPath <chain.json>` | Output keys are ordinal-sorted. |
| 3 | Three distinct, stable messages | PASS | Messages begin `EPIC_WAVE_SELF_LOOP:`, `EPIC_WAVE_CYCLE:`, `EPIC_WAVE_UNRESOLVED_REFERENCE:` at module lines 116, 69, 122; `EpicWave.Tests.ps1` (25 tests) green. | `Invoke-PoshQCParallelTest` | Reviewer saw the unresolved message from the CLI. |
| 4 | CLI exit codes 0, 1, 2 | PASS | Reviewer probe: chain manifest exit 0; manifest with `ghost` dependency exit 1; no argument exit 2; case-differing keys exit 2 with a stated reason. Tests cover 0, 1, 2 in process. | `pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1 -ManifestPath <file>` | The AC lists exit 2 for a missing argument or unreadable file; both are tested. |
| 5 | Python raises the new error; both lanes pass; existing test passes | PASS | `compute_wave_numbers` raises `EpicWaveUnresolvedReferenceError`; reviewer probe confirmed for a dangling key; `test_corpus_case_matches_reference` has 8 cases; `test_epic_wave_computation.py` unchanged and green; Pester lane green. | `poetry run pytest -n auto tests/scripts/dev_tools/test_epic_wave_corpus_parity.py` | Reviewer noted an error-precedence difference on mixed-error manifests (code review, Minor); it does not contradict the AC. |
| 6 | Codex push-down publishes `.codex/lib/epic-wave/` | PASS | `VIRTUAL_RESOURCE_DIRECTORIES` gains the pair in `push_down_codex_and_agents_customizations.py` and `codex-agents-customizations.ts`; stored copies under `extensions/drm-copilot/resources/lib/epic-wave/` are `cmp` equal; Codex `core.json` lines 176-177 list both; Python virtual-path tests and the new Jest test are green. | `cmp .claude/lib/epic-wave/Invoke-EpicWave.ps1 extensions/drm-copilot/resources/lib/epic-wave/Invoke-EpicWave.ps1` | Both runtimes carry the same mapping. |
| 7 | Hook and twin allow the CLI and keep the Python pattern | PASS | Pattern at hook line 161, anchored and path-character-bound; the Python `epic_wave_computation` alternation is retained at line 160; the bundled hook twin is `cmp` equal; five new Pester cases (three allow, two reject). | `cmp .codex/hooks/enforce-epic-planning-only.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` | The reject cases include a chained command. |
| 8 | Agent grants, bundled copies, generated variants | PASS | Both agent files gain the exact grant; bundled agent copies are `cmp` equal; the Codex TOML variants carry no `tools:` list, and `generate_codex_agent_variants --check` exited 0 in `codex-generator-check.2026-11-08T14-24.md`. | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | No TOML change was required; the generator check confirms no drift. |
| 9 | Wave-layering sentences only, shipped CLI cited, re-pin with note | PASS | Diff hunks for the five files touch only the wave-layering sentences and the agent `tools:` line; Codex text cites `.codex/lib/epic-wave/`; Python module described as the parity reference; `RE-BASELINED by issue #1129` note and both new digests present; the frozen-surface test is green. | `git diff origin/main...HEAD -- .claude/skills .agents/skills .claude/agents` | Mirrors `cmp` equal. |
| 10 | Citation test passes after, fails before, reasoned allowlist, stale check | PASS | Reviewer replay on `git show origin/main:<surface>` text and `origin/main` manifests reports `scripts/dev_tools/epic_wave_computation.py` for both runtimes; `HEAD` reports none; the allowlist reason names `validate_orchestration_artifacts`; the stale test fails when no surface cites the entry; fail-before artifact records ExpectedExitCode 1 and EXIT_CODE 1. | `poetry run pytest -n auto tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | Pattern blind spots are recorded as a Minor finding in the code review. |
| 11 | Full toolchain single pass and PR statement | PARTIAL | Local toolchain evidence is green for Python, PowerShell, and TypeScript (all EXIT_CODE 0; pytest 16555 passed; Pester 19623 tests, 0 failures; Jest 5448 passed). The pull request does not exist yet, so CI on the PR head and the PR statement cannot be verified. | `gh pr checks` after the PR opens | Pending CI; owned by the item's orchestrator at S9. Not a defect. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 10 criteria
- **PARTIAL:** 1 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None blocking. AC11 is pending CI and the PR statement; it is expected to stay unchecked until the S9 gate.

**Recommended follow-up verification steps:**

1. Open the pull request with the statement that destinations must refresh the Claude and Codex push-downs after an extension rebuild and reinstall.
2. After CI is green at the final head, the item's orchestrator checks off AC11 and re-runs the CI green gate.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/spec.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: The full toolchain (format, lint, type-check, architecture, unit, contract, integration) passes in a single pass, and the PR states that destinations must refresh the push-down after an extension rebuild and reinstall.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/spec.md` | 11 | 10 | 1 | Checkbox-backed. AC1 through AC10 were already checked by the executor and the reviewer confirmed each; no source change was made. AC11 stays unchecked as pending CI. |
