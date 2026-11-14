# Preflight Fixes (Issue #1032, main plan)

Timestamp: 2026-10-30T23-43
Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan.2026-10-30T18-39.md
Mode: single-pass preflight (DIRECTIVE: PREFLIGHT VALIDATION ONLY); task text and preamble edits only; no task added, removed or reordered.

## Fixes

1. `## Upstream Assumptions` UA-C3c | stale anchor spelling | The `AGENTS.md` heading is cited in the form it has in the tree, ``## Source: `tonality.md` `` (the heading carries backticks around the file name).
2. `## Edit Set` (`docs/engineering/claude-code-architecture.md` row) | stale anchor spelling | The heading is cited as ``### Canonical `.github/skills` migration map``, matching the backticks in the document.
3. [P2-T4] | stale anchor spelling; asserted literal not quoted | The old heading is cited with its backticks, and the retirement statement is required to contain the literal `retired by issue #1032`, which the same task's updated Pester `It` asserts. The previous wording ("a statement that issue #1032 retired `.github/skills`") did not contain the asserted literal.
4. [P2-T5] | stale docstring left out of the edit text | The `test_brief_copies_are_byte_identical` docstring ("All six brief copies") is added to the docstrings that state four copies.
5. [P1-T4] | test disposition not named | `test_push_down_overwrites_existing_destination_file` in `test_push_down_copilot_customizations.py` also uses `_seed_scoped_source_files`; it asserts only `overwritten_count` 1 and is named as unchanged because unaffected.
6. [P0-T10] | validator-blind defect class (Jest per-file thresholds) | `extensions/drm-copilot/jest.config.cjs` sets `collectCoverageFrom` to every `src/**/*.ts` file and a per-file `coverageThreshold` map with no `global` key, so a coverage run of the single engine test file fails every other gated entry and `EXIT_CODE: 0` could not be met. The task now runs the full extension suite with coverage, the same route as P5-T7. The asserted values (exit 0, pass count, line and branch percentages of the engine file from `lcov.info`) are unchanged, and the baseline and final runs now measure the same population for P5-T10.
7. [P0-T12] | literal formatting (search scope) | The search is a `git grep -F` over tracked files, excluding `docs/features/`. A plain search of the working tree also reads gitignored output (`artifacts/`, `extensions/drm-copilot/coverage/`), whose hits P5-T11 could not classify. The plan creates no untracked non-evidence file, so tracked-file search covers every file the plan edits.
8. [P5-T11] | class name aligned with the acceptance criterion | `retirement-statement` is defined as a current document's record of the retirement and counted under the historical class of spec AC13, which names only historical, fixture and generic input-format classes.
9. `## Size Justification` | count correction | "fourteen Python modules" corrected to "sixteen Python modules", the number of modules in `CHANGED-PY`.
10. [P4-T1] | policy-authority clarification | The task states that the edit to `.github/copilot-instructions.md` is directed by spec `## Scope` item 3 despite the `CLAUDE.md` `## Policy Compliance Reading Order` statement that the listed files are not modified, and that P4-T2 removes the file from that list. This keeps the task from reading as a policy conflict at execution time.
