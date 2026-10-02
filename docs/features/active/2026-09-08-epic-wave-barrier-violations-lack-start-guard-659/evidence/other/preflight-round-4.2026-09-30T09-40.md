# Preflight Round 4

Timestamp: 2026-09-30T09-40

Directive: DIRECTIVE: PREFLIGHT VALIDATION ONLY

Plan: `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md` (revision 3, version 1.3)

Issue: #659

Branch: `bug/epic-wave-barrier-violations-lack-start-guard-659`

Result: PREFLIGHT: ALL CLEAR

CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Review method

- Read the whole plan (sections 0 to 4, Phase 0 to Phase 2, 199 lines), not only the revision-3 delta (`git diff HEAD -- <plan>`).
- Re-derived every revision-3 citation against the current tree.
- Enumerated every cited path that the origin/main merge changed, using `git diff --stat 37096891 a24a1ce3 -- <cited paths>` (37096891 is the pre-merge base, from `git merge-base 09750b68^1 a24a1ce3`). Changed cited paths: `.claude/skills/epic-orchestrate/SKILL.md` and its bundled mirror (+2 lines), `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (digest literal), `pyproject.toml` (+1 line), `.claude/hooks/enforce-epic-wave-barrier.ps1` (68 lines), `extensions/drm-copilot/jest.config.cjs` (+31 lines), `extensions/drm-copilot/package.json` (version and overrides). Each was re-checked, including the sibling regions.
- Current refs: HEAD branch `bug/epic-wave-barrier-violations-lack-start-guard-659`; `git merge-base HEAD origin/main` = `a24a1ce30c4c386d8ff2529f5b904092c3f12a52`.

## Revision-3 citations re-derived

| Plan location | Claim | Observation | Result |
|---|---|---|---|
| Section 1 Frozen digest pin, [P0-T14], [P1-T15] | skill pin `4e9c47c3...93c8` at expectations line 150 | line 150 carries it; `sha256sum` of skill and mirror both print it | verified |
| Section 1 | agent pin `0d01e548...27ba` at line 146 | line 146; `sha256sum .claude/agents/epic-orchestrator.md` matches | verified |
| Section 1 | `PINNED_FROZEN_SURFACE_HASHES` lines 143-152 | 143-152 | verified |
| Section 1 | 8ae639e3 (#690) re-baselined the pin, reached branch via a24a1ce3, added no paragraph | `git show --stat 8ae639e3`: expectations file `2 +-`; `git merge-base --is-ancestor 8ae639e3 a24a1ce3` exit 0; no #690 paragraph in lines 105-142 | verified |
| Section 1 | test at lines 470-485; `file_sha256` at support line 92 | decorator 470, def 473, assert ends 485; `def file_sha256` line 92 | verified |
| Section 1 | only pin outside `docs/` is line 150; mirror path unreferenced | `git grep --untracked -n -F` for the digest: only expectations:150; mirror-path search: exit 1, empty; old `620183f5...` digest: no match | verified |
| Section 1 | `.gitattributes` line 1 `* text=auto eol=lf` | line 1; `git ls-files --eol` shows `i/lf w/lf` for skill, mirror, expectations file | verified |
| Section 4 | Layer 2 bullet at lines 243-247 in skill and mirror, text unchanged | both files: bullet begins line 243, old-text line 246, ends 247; `diff --stat origin/main` of both is empty | verified |
| Section 4, [P1-T13] | `9 insertions(+), 3 deletions(-)` | new lines 1-2 equal old lines 243-244; old 245-247 have no identical counterpart in new lines 3-11 | consistent |
| [P0-T4] | 492, 453, 496, 463, 325, 325, 359 | `wc -l` prints the same seven values | verified |
| Rule 5 | `addopts` at `pyproject.toml` line 116 | `116:addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` | verified |
| [P1-T15] | comment block 105-142; #762 paragraph 138-142; constant at 143 | lines 105, 138-142, 143 as stated | verified |
| [P1-T15] | file at or under 500 lines (359) | 359 | verified |

## Sibling and merge-affected regions re-checked

- Rule 6: `extensions/drm-copilot/jest.config.cjs` still has no entry for `epic-orchestrator-state-core.ts`; the merge added push-down entries only. Verified.
- Rule 3 and [P0-T11], [P2-T5] to [P2-T8]: `package.json` scripts `format`, `lint`, `typecheck`, `test`, `test:coverage` unchanged by the merge (lines 207-212). Verified.
- Rule 9: `.gitignore` line 6 `/artifacts`, line 60 `extensions/drm-copilot/coverage`. Verified.
- Section 1 grep claim: `MERGED_STATUSES` / `_validate_wave_barrier_ordering` occur at validator lines 60, 243, 296, 385, 455 (test-function names in `test_validate_epic_orchestrator_state.py` are substrings, not imports). Verified.
- Section 3 fail-before derivation: validator lines 294-306 and TS lines 274-287 unchanged. Verified.
- Section 1 parity locations: TS parity test lines 58-68, Python parity test lines 61-62, `_has_started` at cohort-barrier line 221. Verified.
- [P2-T11]: `git grep -n -F -e "started before"` over the six scoped files returns exactly the six research C1-C6 sites (skill 246, mirror 246, TS core 285, TS test 211, validator 304, Python test 262). Verified.
- [P2-T12]: the skill currently has no line containing either new token, and only line 246 contains `EPIC_WAVE_BARRIER_VIOLATION: `; after the section 4 replacement the counts 1, 1, 2 follow. Consistent.
- [P2-T13]: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` exists at line 118; observed now: `1 passed`. The pre-declared rule admits the pass case.
- [P2-T14] / [P0-T14]: recorded Phase 0 run printed `36 passed`; the pin test parametrizes over two entries, so the count is unchanged by [P1-T15].
- [P1-T16]: agent line 127 (`SubagentStop` time), validate-orchestrator-output lines 152, 218, 267, validator planning-time lines 235 and 385 all verified. See Advisory A1 for the hook citation.
- Other tests that name the skill path (`test_epic_bounded_child_return_contract.py`, `checkpoint-hygiene-skill-contract.Tests.ps1`, `test_claude_rules_frontmatter.py`) do not assert Layer 2 bullet text (`git grep` for `timing invariant`, `Layer 2`, `It appends` in test trees found no epic-skill assertion).
- `.agents/skills/epic-orchestrate/SKILL.md` does not contain the old text (repository-wide `git grep` for `started before dependency`).

## Defects

None blocking.

## Advisories (non-blocking; no plan revision required)

- A1. [P1-T16] cites `.claude/hooks/enforce-epic-wave-barrier.ps1` "line 26". The merge added three header lines; the statement now spans lines 26-29 (`SubagentStop time.` is line 29, previously line 26). Line 26 is still the first line of the sentence that carries the claim, so the task remains satisfiable. The executor should record `lines 26-29` in the `Evidence:` field of follow-up entry (2), which the task text requires to carry file and line citations.
- A2. Rule 9 states that the plan's "own artifacts are uncommitted". Commit 65999d0e committed the Phase 0 artifacts. No acceptance condition depends on that statement: [P2-T16] and [P2-T17] accept feature-folder paths in both the porcelain and the anchored name-status outputs, and `git diff --merge-base --name-status origin/main` currently lists only feature-folder paths.
- A3. The header `Status:` line says "awaiting validator run"; the caller reports that the MCP plan validator passed on this revision. This reviewer did not re-run the validator.

## Delta self-check

This report proposes no plan delta. Advisory text was checked against `.claude/rules/tonality.md`.
