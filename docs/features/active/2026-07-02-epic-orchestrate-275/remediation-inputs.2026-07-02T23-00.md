# Remediation Inputs: epic-orchestrate (#275)

- Entry timestamp: 2026-07-02T23-00
- Source audit artifacts:
  - `docs/features/active/2026-07-02-epic-orchestrate-275/policy-audit.2026-07-02T23-00.md`
  - `docs/features/active/2026-07-02-epic-orchestrate-275/code-review.2026-07-02T23-00.md`
  - `docs/features/active/2026-07-02-epic-orchestrate-275/feature-audit.2026-07-02T23-00.md`
- Base branch: `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
- Head commit under review: `25a4a3644c9767d27a79d72c2033d68c8561eaf2` (branch `drm-copilot-wt-2026-07-02-19-03`)

## Why remediation is triggered

The policy audit reports two Blocking findings and one Major finding that must be resolved before merge, plus two additional Major/Moderate findings recommended for the same or a prompt follow-up pass:

- Policy audit Section 2.3 / Section 8, Gap #1 (Blocking)
- Policy audit Section 8, Gap #2 (Blocking)
- Policy audit Section 8, Gap #3 (Major)
- Policy audit Section 8, Gap #4 (Major)
- Policy audit Section 8, Gap #5 (Major, design note)
- Feature audit: AC2, AC14, and Generic 6 evaluated PARTIAL

## Enumerated Fix List

1. **File-size limit violation — `.claude/hooks/enforce-pr-author-skill.ps1`**
   - **File(s):** `.claude/hooks/enforce-pr-author-skill.ps1` (543 lines; must return to ≤500 lines), and its byte-identical bundled mirrors at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` and `packages/mcp-server/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` (gitignored; update only if present in the working tree at execution time).
   - **Expected behavior:** Extract a cohesive slice of the file below 500 lines total (for example, `Test-EpicBaseBranchOverride` plus its `Get-PrAuthorCheckpointContent` seam and their doc comments) into a small sibling module that is dot-sourced or otherwise composed back into the hook, without changing any externally observable decision behavior (allow/deny outcomes and reason strings must be byte-identical to today's for every existing test case).
   - **Verification command(s):** `wc -l .claude/hooks/enforce-pr-author-skill.ps1` (must report ≤500); `Invoke-PoshQCAnalyze -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')` (must report zero findings); `Invoke-PoshQCTest -ScanFolders @('tests/scripts/claude-hooks')` (467/467 previously; must remain 467/467 passing, 0 failed, after accounting for any newly added sibling-module test file); re-verify bundled mirror byte-identity via `cmp` against both mirrors.

2. **Absent canonical TypeScript coverage artifact**
   - **File(s)/location:** `extensions/drm-copilot/` (Jest coverage output; no production file changes required).
   - **Expected behavior:** Re-run the final TypeScript coverage gate without excluding the `lcov` reporter — either omit the `--coverageReporters` override entirely (Jest's default reporter set includes `lcov`) or explicitly pass `--coverageReporters=lcov` in addition to any summary reporters used for human-readable evidence. Commit/reference the resulting artifact path (e.g., `extensions/drm-copilot/coverage/lcov.info`) in a new evidence file under `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/`.
   - **Verification command(s):** From `extensions/drm-copilot`: `npx jest --config jest.config.cjs --coverage` (default reporters) or `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`; confirm `coverage/lcov.info` exists afterward and that the measured percentages remain ≥85% lines / ≥75% branch with no regression relative to the figures already recorded in `evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md`.

3. **PowerShell canonical coverage-artifact scope gap (Major, recommended same-pass fix)**
   - **File(s):** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`CodeCoverage.Path` array).
   - **Expected behavior:** Add the 5 new/modified hook files (`enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-pr-author-skill.ps1`, `validate-orchestrator-output.ps1`) to the `CodeCoverage.Path` allowlist so the canonical `artifacts/pester/powershell-coverage.xml` artifact reflects this feature's code going forward. Confirm this does not regress the existing curated-scope baseline numbers for the 5 pre-existing files already in that list.
   - **Verification command(s):** `Invoke-PoshQCTest -ScanFolders @('tests/scripts/claude-hooks')`; inspect `artifacts/pester/powershell-coverage.xml` afterward and confirm per-file entries exist for all 5 newly-added files with line coverage ≥85%.

4. **Oversized test file grown further (Major, recommended same-pass fix)**
   - **File(s):** `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (739 lines; was already 635 at baseline, a pre-existing violation this feature worsened by +104 lines).
   - **Expected behavior:** Extract the new `epic-orchestrator-state` dispatch-integration tests (and, if convenient, the pre-existing `orchestrator-state` dispatch tests) into a new sibling test file (e.g., `test_validate_orchestration_artifacts_dispatch.py` or similar), consistent with the sibling-module convention already used for `test_validate_epic_orchestrator_state.py`. Do not delete or weaken any existing test.
   - **Verification command(s):** `wc -l tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (target ≤500, or as close as achievable); `poetry run pytest tests/scripts/dev_tools -q` (must continue to report 1184 passed + 19 skipped, or more if new test files add additional cases — zero failures).

5. **Wave-computation formula lacks a dedicated tested implementation (Minor/AC2, recommended)**
   - **File(s):** New, small pure-function module (Python and/or TypeScript) implementing `wave(f) = 0 if depends_on(f) is empty else 1 + max(wave(d) for d in depends_on(f))` with cycle detection, plus a new test file exercising it against a diamond-shaped DAG (mirroring `user-story.md`'s own scenario: `child-a` no deps, `child-b`/`child-c` depend on `child-a`, `child-d` depends on both), a linear chain, and a cyclic manifest.
   - **Expected behavior:** `epic-orchestrate/SKILL.md` and `epic-orchestrator.md` should reference this function as the authoritative implementation of the formula they currently only describe in prose (this does not require the epic-orchestrator agent to invoke the function at runtime via a tool call — documenting it as the canonical reference implementation, with passing tests, is sufficient to close the gap).
   - **Verification command(s):** New test file's own toolchain run (format/lint/type-check/test) reporting zero findings and 100% pass; `spec.md`'s "Seeded Test Conditions" checklist item for wave/topological-sort computation may then be checked off.

## Do Not Do

- Do not weaken, remove, or skip any existing passing test to make the file-size extraction easier.
- Do not change any hook's externally observable allow/deny decision behavior or reason-string wording while extracting code for the file-size fix — this is a structural refactor only, not a behavior change.
- Do not silently drop the `text-summary`/`json-summary` reporters when fixing the TypeScript coverage-artifact gap; add `lcov` alongside them (or restore Jest's default reporter set) rather than replacing existing evidence formats.
- Do not expand scope beyond the 5 fixes above (e.g., do not refactor unrelated hooks, do not change the epic checkpoint schema, do not alter the wave-barrier or merge-gate decision logic).
- Do not mark any of the corrected AC2/AC14/Generic-6 checkboxes in `spec.md` as `[x]` until the corresponding fix above has been independently re-verified by a subsequent feature-review pass.
- Do not introduce a dependency-cruiser/architecture-boundary configuration as part of this remediation — that is a separate, pre-existing repository-wide gap out of scope for this fix list.

## Acceptance Criteria Affected

- `spec.md` AC14 (all four toolchains pass with no coverage regression) — blocked on fixes #1 and #2.
- `spec.md` Generic closing item "Toolchain pass completed" — blocked on the same fixes.
- `spec.md` AC2 / `user-story.md` item 2 (wave computation via longest-path-layering) — blocked on fix #5 (recommended, not required for AC14 closure).

## Next Step

Hand off to `atomic-planner` per `remediation-handoff-atomic-planner` to author `remediation-plan.2026-07-02T23-00.md`, then route through the standard preflight → execution → reaudit chain. On reaudit, re-run `feature-review` to produce new `code-review`, `feature-audit`, and `policy-audit` artifacts at the exit timestamp, and re-evaluate AC2/AC14/Generic-6 for check-off in `spec.md` and `user-story.md`.
