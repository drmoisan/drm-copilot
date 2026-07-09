# Remediation Plan — CI Failure: Bundled Claude Payload Missing Files (Issue #334)

- Cycle: 1
- Entry timestamp: 2026-07-09T15-35
- Source: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/remediation-inputs.2026-07-09T15-35.md`
- Scope: mirror four repo `.claude/**` files byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/` so that
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  passes. No production code, no contract test, and no `.claude/**` source
  file is modified.

## Blocking Finding Addressed

- Failing required check: `quality-checks7 / Code Quality & Tests (3.10)`.
- Reproduced locally: the byte-identical mirror assertion in
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails
  because the bundle at
  `extensions/drm-copilot/resources/claude-customizations/.claude/` is
  missing three files and holds a divergent `settings.json`:
  - `.claude/hooks/persist-session-id.ps1` (missing in bundle)
  - `.claude/skills/identify-session-id/SKILL.md` (missing in bundle)
  - `.claude/skills/show-my-agent-tree/SKILL.md` (missing in bundle)
  - `.claude/settings.json` (divergent — bundle lacks the `SessionStart` hook
    block, the `render_subagent_tree` MCP permission, and the
    `identify-session-id`/`show-my-agent-tree` skill permissions present in
    the repo copy)

## Mechanism Note

`scripts/dev_tools/push_down_claude_customizations.py` copies the bundle at
`extensions/drm-copilot/resources/claude-customizations/.claude/`
**outward** to an external destination workspace; it never writes back into
the bundle from the repo-root `.claude/` tree. There is no generator that
produces the bundle from the repo root. The bundle is a manually maintained
mirror, so the correct remediation mechanism is a direct byte-identical file
copy, confirmed in Phase 1 below.

---

### Phase 0 — Baseline Capture and Policy Read

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, and `.claude/rules/python-suppressions.md` in that order, then write `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of the five files read. Acceptance: the file exists with all three fields populated and the five file paths listed in the stated order.
- [x] [P0-T2] `[expect-fail]` Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q` and write the fail-before result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/regression-testing/fail-before-contract-test.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the missing file assertion. Acceptance: `EXIT_CODE` is non-zero and the `Output Summary` quotes the `AssertionError: Repo file missing from bundle` message.
- [x] [P0-T3] Run `poetry run black --check .` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/baseline-black.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists with all four fields populated and `EXIT_CODE` recorded exactly as returned.
- [x] [P0-T4] Run `poetry run ruff check .` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/baseline-ruff.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists with all four fields populated and `EXIT_CODE` recorded exactly as returned.
- [x] [P0-T5] Run `poetry run pyright` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/baseline-pyright.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists with all four fields populated and `EXIT_CODE` recorded exactly as returned.
- [x] [P0-T6] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/baseline-pytest-coverage.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the numeric total line-coverage percent, the numeric total branch-coverage percent, and a note that the one known failure is the test captured in P0-T2. Acceptance: the artifact exists with all four fields populated, both numeric coverage values are present (not placeholders), and the single expected failure is identified by name.

### Phase 1 — Confirm Mirror Mechanism and Copy the Four Files

- [x] [P1-T1] Run `git grep -n "claude-customizations" -- scripts/dev_tools` and inspect `scripts/dev_tools/push_down_claude_customizations.py`'s `push_down_customizations()` to confirm it reads the bundle only as a manifest/variant source and writes exclusively to an external `destination_root`, never back into `extensions/drm-copilot/resources/claude-customizations/.claude/`. Write the finding to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/other/generator-investigation.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, and `Output Summary:` stating that no repo script auto-generates the bundle from the repo-root `.claude/` tree and that a direct file copy is the correct remediation mechanism. Acceptance: the artifact exists and explicitly states the no-generator conclusion.
- [x] [P1-T2] Copy `.claude/hooks/persist-session-id.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/persist-session-id.ps1` byte-identically, without modifying the source file. Acceptance: the destination file exists and a byte/text comparison against the source shows zero differences.
- [x] [P1-T3] Create the directory `extensions/drm-copilot/resources/claude-customizations/.claude/skills/identify-session-id/` if absent and copy `.claude/skills/identify-session-id/SKILL.md` into it as `extensions/drm-copilot/resources/claude-customizations/.claude/skills/identify-session-id/SKILL.md`, byte-identically, without modifying the source file. Acceptance: the destination file exists and a byte/text comparison against the source shows zero differences.
- [x] [P1-T4] Create the directory `extensions/drm-copilot/resources/claude-customizations/.claude/skills/show-my-agent-tree/` if absent and copy `.claude/skills/show-my-agent-tree/SKILL.md` into it as `extensions/drm-copilot/resources/claude-customizations/.claude/skills/show-my-agent-tree/SKILL.md`, byte-identically, without modifying the source file. Acceptance: the destination file exists and a byte/text comparison against the source shows zero differences.
- [x] [P1-T5] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` with the byte-identical content of `.claude/settings.json`, without modifying the source file. Acceptance: a byte/text comparison between the two files shows zero differences.
- [x] [P1-T6] Run `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/pack-manifests extensions/drm-copilot/resources/claude-customizations/.claude-variants` and write the output to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/other/pack-manifest-variant-integrity.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, and `Output Summary:`. Acceptance: the command output is empty and the artifact records that `pack-manifests/**` and `.claude-variants/**` are unmodified by the Phase 1 copy operations.

### Phase 2 — Targeted Verification

- [x] [P2-T1] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/remediation-targeted-test.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE` is `0`.
- [x] [P2-T2] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/remediation-contract-file-test.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reporting the pass count for the full contract test file. Acceptance: `EXIT_CODE` is `0` and every test in the file is reported as passed.

### Phase 3 — Full Python Toolchain Final QA Loop

- [x] [P3-T1] Run `poetry run black .` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-black.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If any file is reformatted, restart this Phase 3 loop from P3-T1 after the reformat. Acceptance: a final recorded run has `EXIT_CODE` `0` and reports zero files reformatted.
- [x] [P3-T2] Run `poetry run ruff check .` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ruff.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If this step reports any error or auto-fixes a file, restart this Phase 3 loop from P3-T1. Acceptance: a final recorded run has `EXIT_CODE` `0` and zero lint errors.
- [x] [P3-T3] Run `poetry run pyright` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-pyright.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If this step reports any type error, restart this Phase 3 loop from P3-T1. Acceptance: a final recorded run has `EXIT_CODE` `0` and zero type errors.
- [x] [P3-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-pytest-coverage.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the total pass count, the numeric total line-coverage percent, and the numeric total branch-coverage percent. If any test fails, restart this Phase 3 loop from P3-T1. Acceptance: a final recorded run has `EXIT_CODE` `0`, all tests pass, and both numeric coverage values are present.
- [x] [P3-T5] Compare the baseline coverage from `evidence/baseline/baseline-pytest-coverage.2026-07-09T15-35.md` (P0-T6) against the final coverage from `evidence/qa-gates/final-pytest-coverage.2026-07-09T15-35.md` (P3-T4) and write the comparison to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T15-35.md` with `Timestamp:`, baseline line/branch percentages, final line/branch percentages, and an explicit note that zero `.py` production or test lines were changed in this remediation (only non-Python bundle resource files were copied in Phase 1), so the changed-code coverage figure is not applicable. Acceptance: the artifact records both numeric coverage pairs and shows no regression (final >= baseline for both line and branch percentages).
- [x] [P3-T6] Confirm the Phase 3 toolchain loop (P3-T1 through P3-T4) completed in a single clean pass with zero restarts; record this confirmation, or the restart count and the evidence filenames of each restart iteration if any occurred, in `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-pytest-coverage.2026-07-09T15-35.md`'s `Output Summary:` field. Acceptance: the restart count is explicitly stated as an integer (0 or greater).

### Phase 4 — Packaging / Rebuild Confirmation

- [x] [P4-T1] Inspect `extensions/drm-copilot/esbuild-extension.cjs`, `extensions/drm-copilot/.vscodeignore`, and `extensions/drm-copilot/package.json` to determine whether `resources/claude-customizations/**` is routed through the esbuild compile step or is packaged as a static resource, then write the determination to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/other/packaging-investigation.2026-07-09T15-35.md` with `Timestamp:` and `Output Summary:`. Acceptance: the artifact states explicitly whether a rebuild (`npm run build`) is required for the Phase 1 file changes to be reflected in a packaged extension.
- [ ] [P4-T2] Based on the P4-T1 determination: if a rebuild is required, run `npm run build` in `extensions/drm-copilot` and write the result to `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/extension-rebuild.2026-07-09T15-35.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if no rebuild is required (static resource files packaged directly, as `esbuild-extension.cjs` bundles only `src/extension.ts` and `.vscodeignore` does not exclude `resources/claude-customizations/**`), run `npm run test` in `extensions/drm-copilot` instead and write the result to the same evidence path with the same required fields, as a smoke confirmation that the existing extension test suite (including `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts` and `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts`) still passes with the updated bundle. Acceptance: `EXIT_CODE` is `0` for whichever branch applies.

---

## Verification Summary (restated from remediation inputs)

- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` passes (Phase 2).
- Full Python toolchain (Black -> Ruff -> Pyright -> Pytest) is clean in a single pass (Phase 3).
- Re-run of the S9 CI gate against the new PR head SHA, once these changes are committed, is outside the scope of local plan execution and remains the responsibility of the calling orchestrator after this remediation lands.
