# relocate-research-canonical-location - Refactor Plan (Atomic)

- **Issue:** #227
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T13-09
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References (read, do not restate)

- Spec: `docs/features/active/2026-06-24-relocate-research-canonical-location-227/spec.md`
- Research: `docs/features/active/2026-06-24-relocate-research-canonical-location-227/research/2026-06-24T13-02-relocate-research-canonical-location-227-research.md` (relocated from `artifacts/research/` by Phase 8 P8-T1)
- Issue: `docs/features/active/2026-06-24-relocate-research-canonical-location-227/issue.md`
- Policy reading order: `.claude/skills/policy-compliance-order/SKILL.md`
- Atomic plan contract: `.claude/skills/atomic-plan-contract/SKILL.md`
- Evidence conventions: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

## Strategy

Direct substitution with dual-root acceptance (per research Recommended Approach). The change relocates a path contract from `artifacts/research/` to two git-tracked roots: `docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md` (feature-associated) and `docs/research/<timestamp>-<short-name>-research.md` (one-off).

Only three files carry logic changes; each has a root copy plus bundled/translated copies that must change identically:
- `validate-task-researcher-output.ps1` — rewrite `Test-IsUnderResearchRoot` to accept both new roots; update three hard-coded error messages; filename regex unchanged.
- `enforce-evidence-locations.ps1` — add `artifacts/research/` to the forbidden-prefix array; update docstring.
- `scripts/dev_tools/validate_evidence_locations.py` — add `artifacts/research/` to `_FORBIDDEN_PREFIX_TO_CANONICAL`.

All other in-scope edits are write-path allowlist forms and prose/instruction text across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies.

Phase ordering by concern:
- Phase 0 — baseline capture.
- Phase 1 — logic-bearing PowerShell hook (validate-task-researcher-output) + its tests, root copy.
- Phase 2 — logic-bearing PowerShell hook (enforce-evidence-locations) + its tests, root copy.
- Phase 3 — Python validator + its tests.
- Phase 4 — bundled-copy synchronization for all logic-bearing files (PowerShell hooks: Claude bundled mirror + Codex bundled copy).
- Phase 5 — agent write-path allowlist edits (Claude `.md` frontmatter + Codex `.toml`, root + bundled).
- Phase 6 — prose/instruction edits, Claude ecosystem (root + bundled).
- Phase 7 — prose/instruction edits, Codex and GitHub Copilot ecosystems (bundled + root).
- Phase 8 — relocate this feature's own research artifact; documentation accuracy.
- Phase 9 — final QA loop, consistency verification, and residual-reference grep.

Fail-closed evidence rule: each evidence-producing task records its canonical artifact path under `<FEATURE>/evidence/<kind>/`. Missing baseline, QA, or coverage artifacts force a BLOCKED/INCOMPLETE verdict, never PASS.

Constraints honored:
- PowerShell per-batch cap: at most 3 production + 3 test files per batch. Phases 1, 2, 4 are each scoped under the cap.
- 500-line file limit: every edited file remains under 500 lines; no file is expanded past the limit.
- Mandatory toolchain order — PowerShell: PoshQC format -> analyze -> Pester; Python: Black -> Ruff -> Pyright -> Pytest.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: none. Spec and delegation reference `artifacts/research/` only as the contract being retired (not as an evidence path); all plan evidence resolves to `<FEATURE>/evidence/<kind>/`.

`<FEATURE>` = `docs/features/active/2026-06-24-relocate-research-canonical-location-227`

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in required order and record a Phase 0 evidence artifact at `<FEATURE>/evidence/other/phase0-instructions-read.2026-06-24T13-09.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/quality-tiers.md`. Acceptance: artifact exists with all three fields populated.
- [x] [P0-T2] Capture PowerShell format baseline by running `mcp__drm-copilot__run_poshqc_format` (check mode) over `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/enforce-evidence-locations.ps1`, and the two hook test files. Write artifact `<FEATURE>/evidence/baseline/poshqc-format.2026-06-24T13-09.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records the pre-change format state.
- [x] [P0-T3] Capture PowerShell analyze baseline by running `mcp__drm-copilot__run_poshqc_analyze` over the same four files. Write artifact `<FEATURE>/evidence/baseline/poshqc-analyze.2026-06-24T13-09.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records analyzer findings count.
- [x] [P0-T4] Capture PowerShell Pester baseline (coverage mode) by running `mcp__drm-copilot__run_poshqc_test` for `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` and `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`. Write artifact `<FEATURE>/evidence/baseline/pester.2026-06-24T13-09.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric line-coverage and branch-coverage headline values for the two hooks under test. Acceptance: artifact records pass count and numeric coverage values (no placeholders).
- [x] [P0-T5] Capture Python baseline by running `poetry run black --check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`, `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`, `poetry run pyright scripts/dev_tools/validate_evidence_locations.py`, and `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts/dev_tools/validate_evidence_locations --cov-branch --cov-report=term-missing`. Write artifact `<FEATURE>/evidence/baseline/python.2026-06-24T13-09.md` with `Timestamp:`, `Command:` (one per stage), `EXIT_CODE:` (per stage), `Output Summary:` including numeric line and branch coverage for `validate_evidence_locations.py`. Acceptance: artifact records four stage results and numeric coverage values (no placeholders).
- [x] [P0-T6] Capture residual-reference baseline by running a content search for `artifacts[/\\]research` across the repository (Grep, content mode). Write artifact `<FEATURE>/evidence/baseline/residual-references.2026-06-24T13-09.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the operational/enforcement files that match (distinct from historical feature-doc references). Acceptance: artifact enumerates the current matching operational files as the pre-change reference set.

---

### Phase 1 — Logic: validate-task-researcher-output (root copy) + tests

Batch scope: 1 production file + 1 test file (within PowerShell per-batch cap).

- [x] [P1-T1] In `.claude/hooks/validate-task-researcher-output.ps1`, rewrite the `Test-IsUnderResearchRoot` function body so it normalizes the path to forward slashes and returns `$true` when the path `StartsWith('docs/features/', OrdinalIgnoreCase)` AND contains a `/research/` segment, OR when the path `StartsWith('docs/research/', OrdinalIgnoreCase)`; otherwise returns `$false`. Leave `Test-IsValidResearchFileName` and its regex unchanged. Acceptance: function accepts `docs/features/active/x/research/<file>` and `docs/research/<file>`, rejects `artifacts/research/<file>` and `docs/features/active/x/<file>` (no `/research/` segment).
- [x] [P1-T2] In `.claude/hooks/validate-task-researcher-output.ps1`, update the three hard-coded `artifacts/research/` error messages: (a) the missing `research-path` guidance message (currently "pointing to artifacts/research/"), (b) the root-mismatch message (currently "is not under artifacts/research/. All research artifacts must be written to artifacts/research/."), and (c) the filename-convention message (currently "artifacts/research/<timestamp>-<short-name>-research.md"). Each updated message must reference the two new roots `docs/features/<feature>/research/` and `docs/research/`. Acceptance: no `artifacts/research/` substring remains in the three messages; each cites both new roots.
- [x] [P1-T3] In `.claude/hooks/validate-task-researcher-output.ps1`, update the `.DESCRIPTION` SYNOPSIS block (currently "rooted under artifacts/research/") to describe the dual-root contract. Acceptance: docstring references both new roots and contains no `artifacts/research/` substring.
- [x] [P1-T4] In `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`, update the existing tests that assert the old root, old error-message text, and `artifacts/research/...` example paths: the root-check test (`blocks when the research-path is not under artifacts/research/`), the valid-path termination test, the missing-file block test, the quoted-path extraction test, and the `Test-AutomationFeasibilitySection` tests, to use valid paths under the new roots (e.g., `docs/features/active/my-feature/research/2026-05-04T00-00-hook-contract-research.md`). Acceptance: no updated test references `artifacts/research/`; assertions check new-root acceptance and new message text.
- [x] [P1-T5] In `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`, add five new `It` cases: (a) feature-folder path accepted (`docs/features/active/some-feature-227/research/2026-06-24T13-02-some-feature-research.md`), (b) one-off path accepted (`docs/research/2026-06-24T13-02-some-topic-research.md`), (c) old path rejected (`artifacts/research/2026-06-24T13-02-some-topic-research.md`) with a message referencing the new roots, (d) feature path without a `/research/` segment rejected (`docs/features/active/some-feature/2026-06-24T13-02-some-feature-research.md`), (e) feature path with a `/research/` segment but non-conforming filename rejected (`docs/features/active/some-feature/research/bad-name.md`) with the filename-convention message. Acceptance: five new `It` blocks present, each asserting the stated outcome.
- [x] [P1-T6] Run the PowerShell toolchain for the Phase 1 batch: `mcp__drm-copilot__run_poshqc_format`, then `mcp__drm-copilot__run_poshqc_analyze`, then `mcp__drm-copilot__run_poshqc_test` for `validate-task-researcher-output.Tests.ps1` (coverage mode). Restart from format if any stage changes files or fails. Write artifact `<FEATURE>/evidence/qa-gates/phase1-poshqc.2026-06-24T13-09.md` with `Timestamp:`, `Command:` per stage, `EXIT_CODE:` per stage, `Output Summary:` including pass count and numeric coverage for `validate-task-researcher-output.ps1`. Acceptance: all stages clean in a single pass; coverage >= 85% line and >= 75% branch with no regression on changed lines.

---

### Phase 2 — Logic: enforce-evidence-locations (root copy) + tests

Batch scope: 1 production file + 1 test file (within PowerShell per-batch cap).

- [x] [P2-T1] In `.claude/hooks/enforce-evidence-locations.ps1`, add `'artifacts/research/'` to the `$forbiddenPrefixes` array inside `Test-EvidenceLocationForbidden`. Do not change the exclusion-only model or any other prefix. Acceptance: `artifacts/research/` is a member of the forbidden-prefix array; all eight existing prefixes remain.
- [x] [P2-T2] In `.claude/hooks/enforce-evidence-locations.ps1`, update the `.DESCRIPTION` docstring: add `artifacts/research/` to the "Forbidden path prefixes" list and remove `artifacts/research/` from the "permitted artifacts/ sub-paths" enumeration. Acceptance: docstring lists `artifacts/research/` as forbidden and no longer lists it as permitted.
- [x] [P2-T3] In `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`, change the existing `It` block `'allows writes to artifacts/research/ (permitted research path)'` into a rejection test: path `artifacts/research/notes.md` must produce `decision: block` with a reason containing `EVIDENCE_LOCATION_BLOCKED`. Acceptance: the previously-allowing test now asserts a block decision.
- [x] [P2-T4] In `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`, add two allow `It` blocks: (a) `'allows writes to docs/features/ research subfolder (new canonical feature research path)'` with path `docs/features/active/my-feature/research/2026-06-24T13-02-foo-research.md` -> `decision: allow`; (b) `'allows writes to docs/research/ (new canonical one-off research path)'` with path `docs/research/2026-06-24T13-02-foo-research.md` -> `decision: allow`. Acceptance: two new allow `It` blocks present asserting the stated outcomes.
- [x] [P2-T5] Run the PowerShell toolchain for the Phase 2 batch: `mcp__drm-copilot__run_poshqc_format`, then `mcp__drm-copilot__run_poshqc_analyze`, then `mcp__drm-copilot__run_poshqc_test` for `enforce-evidence-locations.Tests.ps1` (coverage mode). Restart from format if any stage changes files or fails. Write artifact `<FEATURE>/evidence/qa-gates/phase2-poshqc.2026-06-24T13-09.md` with `Timestamp:`, `Command:` per stage, `EXIT_CODE:` per stage, `Output Summary:` including pass count and numeric coverage for `enforce-evidence-locations.ps1`. Acceptance: all stages clean in a single pass; coverage >= 85% line and >= 75% branch with no regression on changed lines.

---

### Phase 3 — Logic: Python validator + tests

- [x] [P3-T1] In `scripts/dev_tools/validate_evidence_locations.py`, add the entry `"artifacts/research/": "docs/features/active/<feature>/research/ or docs/research/"` to the `_FORBIDDEN_PREFIX_TO_CANONICAL` dict. The canonical suggestion must reference both new roots. Acceptance: dict contains the new key with a value naming both new roots; existing entries unchanged.
- [x] [P3-T2] In `scripts/dev_tools/validate_evidence_locations.py`, update the module docstring if it enumerates forbidden prefixes so it reflects the added `artifacts/research/` prefix. Acceptance: docstring is consistent with the dict; no stale claim that research under `artifacts/` is permitted. (If the docstring does not enumerate prefixes, record this task as not-applicable with a note; no edit required.)
- [x] [P3-T3] In `tests/scripts/dev_tools/test_validate_evidence_locations.py`, in `test_clean_tree_exits_zero` replace the allowed path `Path("/fake/repo/artifacts/research/notes.md")` with a new-root path such as `Path("/fake/repo/docs/features/active/my-feature/research/note.md")`. Acceptance: the clean-tree test no longer seeds an `artifacts/research/` path and passes.
- [x] [P3-T4] In `tests/scripts/dev_tools/test_validate_evidence_locations.py`, add `test_artifacts_research_is_forbidden`: seed a file at `artifacts/research/seeded.md` under the fake root and assert `find_forbidden_paths` yields exactly one violation whose canonical suggestion references the new paths. Acceptance: new test present and asserts exactly one violation with a suggestion naming the new roots.
- [x] [P3-T5] Run the Python toolchain for the Phase 3 batch in order: `poetry run black scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`, `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`, `poetry run pyright scripts/dev_tools/validate_evidence_locations.py`, `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts/dev_tools/validate_evidence_locations --cov-branch --cov-report=term-missing`. Restart from format if any stage changes files or fails. Write artifact `<FEATURE>/evidence/qa-gates/phase3-python.2026-06-24T13-09.md` with `Timestamp:`, `Command:` per stage, `EXIT_CODE:` per stage, `Output Summary:` including numeric line and branch coverage for `validate_evidence_locations.py`. Acceptance: all four stages clean in a single pass; coverage >= 85% line and >= 75% branch with no regression on changed lines.

---

### Phase 4 — Bundled-copy synchronization for logic-bearing hooks

Batch scope: 3 production PowerShell files (within PowerShell per-batch cap); no test files in this batch.

- [x] [P4-T1] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` so it is byte-for-byte identical to the root `.claude/hooks/validate-task-researcher-output.ps1` after Phase 1. Acceptance: a content diff between the root and bundled file reports no differences.
- [x] [P4-T2] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1` so it is byte-for-byte identical to the root `.claude/hooks/enforce-evidence-locations.ps1` after Phase 2. Acceptance: a content diff between the root and bundled file reports no differences.
- [x] [P4-T3] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1`, apply the equivalent docstring update from Phase 2 (add `artifacts/research/` to forbidden list; remove it from permitted list) and the equivalent forbidden-prefix change. Acceptance: the Codex copy reflects the same forbidden-prefix membership and docstring text as the root hook (translation equivalence, not necessarily byte-identical if the Codex header differs).
- [x] [P4-T4] Run the PowerShell toolchain over the three Phase 4 files: `mcp__drm-copilot__run_poshqc_format`, then `mcp__drm-copilot__run_poshqc_analyze`. (No dedicated test files target the bundled/Codex copies; the root copies are the tested source.) Restart from format if a stage changes files. Write artifact `<FEATURE>/evidence/qa-gates/phase4-poshqc.2026-06-24T13-09.md` with `Timestamp:`, `Command:` per stage, `EXIT_CODE:` per stage, `Output Summary:`. Acceptance: format and analyze clean for the three files in a single pass.

---

### Phase 5 — Agent write-path allowlist edits (Claude .md + Codex .toml)

- [x] [P5-T1] In `.claude/agents/task-researcher.md` frontmatter `tools:` list, replace the entry `"Write(/artifacts/research/**)"` with the two entries `"Write(/docs/features/**/research/**)"` and `"Write(/docs/research/**)"`. Acceptance: frontmatter contains both new Write globs and no `Write(/artifacts/research/**)` entry.
- [x] [P5-T2] In `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md` frontmatter, apply the identical `tools:` allowlist change from P5-T1. Acceptance: bundled frontmatter matches the root frontmatter allowlist exactly.
- [x] [P5-T3] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml`, replace the embedded write-allowlist entry `"Write(/artifacts/research/**)"` with `"Write(/docs/features/**/research/**)"` and `"Write(/docs/research/**)"` (preserving TOML array/string syntax). Acceptance: the embedded allowlist contains both new globs and no `artifacts/research` write glob.

---

### Phase 6 — Prose/instruction edits: Claude ecosystem (root + bundled)

- [x] [P6-T1] In `.claude/agents/task-researcher.md`, update the description metadata (currently "writes structured findings exclusively to artifacts/research/") and the body output-location prose (the "Write all research artifacts to `artifacts/research/`" statement and the "Write only to `artifacts/research/`" constraint) to describe the two new roots and the orchestrator-supplied routing rule (feature-folder research path vs. `docs/research/`). Acceptance: no `artifacts/research/` substring remains; both roots and the routing rule are described.
- [x] [P6-T2] In `.claude/agents/orchestrator.md`, update the delegation prose (currently "task-researcher — performs deep research and writes findings to `artifacts/research/`") to reference the two new roots and the routing rule (orchestrator resolves the output path from `feature-folder` in `orchestrator-state.json`). Acceptance: no `artifacts/research/` substring remains in the delegation prose; routing rule documented.
- [x] [P6-T3] In `.claude/skills/research-issue/SKILL.md`, update the output-path prose (currently "Path: `artifacts/research/<timestamp>-<short-name>-research.md`") and the description metadata (currently "writing structured findings to artifacts/research/") to document both roots and the routing rule. Acceptance: no `artifacts/research/` substring remains; both roots and routing rule documented; filename convention preserved.
- [x] [P6-T4] In `.claude/skills/orchestrate/SKILL.md`, update the delegation prose and remove/replace the `"artifacts/research/ — research outputs from task-researcher"` entry in the Evidence Location Authority permitted-sub-path list, reflecting that research is no longer an `artifacts/` sub-path. Acceptance: permitted-sub-path list no longer contains `artifacts/research/`; delegation prose references both new roots.
- [x] [P6-T5] In `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, remove `artifacts/research/` from the "Allowed `artifacts/` sub-paths" list. Acceptance: the allowed list no longer contains `artifacts/research/`; `artifacts/orchestration/` remains.
- [x] [P6-T6] Apply the identical edits from P6-T1 through P6-T5 to the bundled mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md`, `.../agents/orchestrator.md`, `.../skills/research-issue/SKILL.md`, `.../skills/orchestrate/SKILL.md`, `.../skills/evidence-and-timestamp-conventions/SKILL.md`. Acceptance: each bundled file is content-identical to its root counterpart after the edits.

---

### Phase 7 — Prose/instruction edits: Codex + GitHub Copilot ecosystems

- [x] [P7-T1] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml`, update the embedded body prose (mirrors the Claude agent) and the stop-hook text (currently "Block termination unless research artifact path has been confirmed on disk under artifacts/research/.") to reference the two new roots and the routing rule. Acceptance: no `artifacts/research/` substring remains in the body prose or stop-hook text; both roots documented.
- [x] [P7-T2] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`, update the `developer_instructions` delegation prose (currently "task-researcher: research artifacts under `artifacts/research/`") to reference the two new roots and the routing rule. Acceptance: no `artifacts/research/` substring remains in the delegation prose.
- [x] [P7-T3] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md`, apply the equivalent text changes made to the Claude `research-issue/SKILL.md` in P6-T3. Acceptance: file mirrors the Claude counterpart's research-path prose; no `artifacts/research/` substring remains.
- [x] [P7-T4] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`, apply the equivalent text changes made to the Claude `orchestrate/SKILL.md` in P6-T4. Acceptance: file mirrors the Claude counterpart; permitted-sub-path list no longer contains `artifacts/research/`.
- [x] [P7-T5] In `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, apply the equivalent change made in P6-T5 (remove `artifacts/research/` from the allowed list). Acceptance: file mirrors the Claude counterpart; allowed list no longer contains `artifacts/research/`.
- [x] [P7-T6] In `.github/agents/task-researcher.agent.md`, update the role-definition prose (currently "Your sole responsibility is to write transient research notes in the untracked scratch area `artifacts/research/`"), the operational constraint (currently "You MUST create and edit files ONLY in `artifacts/research/`"), and the collaborative-process reference (currently "Search for existing research files in `artifacts/research/`") to describe the two new tracked roots and the routing rule. Remove the "untracked scratch area" framing since research is now tracked. Acceptance: no `artifacts/research/` substring remains; both roots documented; tracked-location framing used.
- [x] [P7-T7] In `.github/prompts/research-issue.prompt.md`, update the output-path prose (currently "Path: `artifacts/research/<timestamp>-<short-name>-research.md`"), the filename-convention example, and the operating-rules reference (currently "write to `artifacts/research/`, evidence-based") to document both new roots and the routing rule. Acceptance: no `artifacts/research/` substring remains; both roots and routing rule documented; filename convention preserved.
- [x] [P7-T8] In `.github/prompts/fillout-prd-feature.prompt.md`, update the research-path reference (currently "If research exists under `artifacts/research`, the caller must include the specific research file paths") to reference both new roots. Acceptance: no `artifacts/research` substring remains in the reference; both roots named.
- [x] [P7-T9] Apply the identical edits from P7-T6 through P7-T8 to the GitHub Copilot bundled mirrors: `extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md`, `.../prompts/research-issue.prompt.md`, `.../prompts/fillout-prd-feature.prompt.md`. Acceptance: each bundled file is content-identical to its root counterpart after the edits.

---

### Phase 8 — Relocate feature research artifact + documentation accuracy

- [x] [P8-T1] Create the destination directory and relocate this feature's research artifact from `artifacts/research/2026-06-24T13-02-relocate-research-canonical-location-227-research.md` to `docs/features/active/2026-06-24-relocate-research-canonical-location-227/research/2026-06-24T13-02-relocate-research-canonical-location-227-research.md`, preserving the filename and content verbatim. This exercises the new contract after the hooks accept the new location (Phases 1, 2, 4 complete). Acceptance: the file exists at the new `docs/features/.../research/` path with identical content; it no longer needs to be read from `artifacts/research/` for this feature. (Historical `artifacts/research/` copies for other features are not migrated, per spec Non-Goals.)
- [x] [P8-T2] Update the `Required References` line at the top of this plan and the spec's research reference to point at the relocated `docs/features/.../research/...` path. Acceptance: plan and spec reference the new research path.
- [x] [P8-T3] In `docs/engineering/claude-code-architecture.md`, update the architectural description that references `artifacts/research/` to reflect the two new tracked roots, for documentation accuracy. Acceptance: the architectural description names the new roots; no enforcement claim depends on `artifacts/research/`. (Non-blocking accuracy edit per spec Dependencies/Touchpoints.)

---

### Phase 9 — Final QA Loop, Consistency Verification, and Residual-Reference Grep

- [x] [P9-T1] Run the full PowerShell QA loop over all edited PowerShell files (`.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/enforce-evidence-locations.ps1`, the two Claude bundled mirrors, and the Codex `enforce-evidence-locations.ps1`) plus the two hook test files, in order: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` (coverage mode) for both hook test files. Restart from format if any stage changes files or fails. Write artifact `<FEATURE>/evidence/qa-gates/final-poshqc.2026-06-24T13-09.md` with `Timestamp:`, `Command:` per stage, `EXIT_CODE:` per stage, `Output Summary:` including pass count and numeric line/branch coverage for both hooks. Acceptance: all stages clean in a single pass; coverage >= 85% line and >= 75% branch.
- [x] [P9-T2] Run the full Python QA loop in order: `poetry run black scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`, `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`, `poetry run pyright scripts/dev_tools/validate_evidence_locations.py`, `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts/dev_tools/validate_evidence_locations --cov-branch --cov-report=term-missing`. Restart from format if any stage changes files or fails. Write artifact `<FEATURE>/evidence/qa-gates/final-python.2026-06-24T13-09.md` with `Timestamp:`, `Command:` per stage, `EXIT_CODE:` per stage, `Output Summary:` including numeric line/branch coverage for `validate_evidence_locations.py`. Acceptance: all four stages clean in a single pass; coverage >= 85% line and >= 75% branch.
- [x] [P9-T3] Run `poetry run python scripts/dev_tools/validate_evidence_locations.py` against the repository root and confirm it does not report the relocated feature research file at `docs/features/.../research/...` as a violation, and would report a seeded `artifacts/research/` file as a violation. Write artifact `<FEATURE>/evidence/qa-gates/validator-run.2026-06-24T13-09.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: validator exits 0 on the clean tree; the new research location is not flagged.
- [x] [P9-T4] Verify coverage delta: compare baseline coverage (P0-T4, P0-T5) against post-change coverage (P9-T1, P9-T2) for `validate-task-researcher-output.ps1`, `enforce-evidence-locations.ps1`, and `validate_evidence_locations.py`. Write artifact `<FEATURE>/evidence/qa-gates/coverage-delta.2026-06-24T13-09.md` reporting baseline coverage, post-change coverage, and changed-code coverage for each module. Acceptance: no regression on changed lines; all modules retain >= 85% line and >= 75% branch coverage.
- [x] [P9-T5] Verify cross-ecosystem content equality for every root/bundled pair: run a content diff for each of the 11 root-vs-bundled file pairs (the three logic-bearing root hooks vs. their two Claude bundled mirrors; `task-researcher.md`, `orchestrator.md`, `research-issue/SKILL.md`, `orchestrate/SKILL.md`, `evidence-and-timestamp-conventions/SKILL.md` Claude root vs. bundled; the three GitHub Copilot root prompts/agent vs. bundled). Write artifact `<FEATURE>/evidence/qa-gates/cross-ecosystem-equality.2026-06-24T13-09.md` listing each pair and its diff result. Acceptance: each pair reports no content differences (the Codex translations are verified for equivalence separately in P9-T6).
- [x] [P9-T6] Verify Codex translation equivalence: confirm the Codex files (`task-researcher.toml`, `orchestrator.toml`, `enforce-evidence-locations.ps1`, the three `.agents/skills/` SKILL.md files) contain the equivalent text changes (both new roots; no `artifacts/research/` path-routing references; updated stop-hook text). Write artifact `<FEATURE>/evidence/qa-gates/codex-equivalence.2026-06-24T13-09.md` enumerating each Codex file and the confirmed change. Acceptance: each Codex file reflects the new contract; no operational `artifacts/research/` reference remains.
- [x] [P9-T7] Run a residual-reference grep for `artifacts[/\\]research` across the repository and confirm that no operational/enforcement/instruction file (hooks, validators, agent frontmatter/body, skill prose, prompts — root and bundled, all three ecosystems) still references the old path. Compare against the P0-T6 baseline. Historical feature-doc references (plan/audit/archive documents under `docs/features/`), the `translate-claude-to-codex` historical research-basis reference, and generated `testResults.xml` are expected and excluded. Write artifact `<FEATURE>/evidence/qa-gates/residual-reference-final.2026-06-24T13-09.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing remaining matches and classifying each as historical/generated (allowed) or operational (must be zero). Acceptance: zero operational matches remain; all remaining matches are classified historical or generated.

---

## Acceptance-Criteria Mapping

| Spec Acceptance Criterion | Plan Tasks |
|---|---|
| Feature-associated research -> `<FEATURE>/research/`; one-off -> `docs/research/`; `artifacts/research/` no longer canonical | P1-T1..T3, P5-T1..T3, P6-T1, P6-T3, P7-T6, P7-T7, P8-T1 |
| Claude ecosystem reflects new contract (agents, skills, both hooks) | P1-T1..T3, P2-T1..T2, P5-T1, P5-T2, P6-T1..T6, P4-T1, P4-T2 |
| Codex ecosystem reflects new contract (toml agents, three skills, enforce hook docstring) | P5-T3, P4-T3, P7-T1..T5 |
| GitHub Copilot ecosystem reflects new contract (agent + two prompts, root + bundled) | P7-T6..T9 |
| `validate-task-researcher-output.ps1` accepts new roots, rejects old, 3 messages updated; `enforce-evidence-locations.ps1` + `validate_evidence_locations.py` reject `artifacts/research/`; tests updated in all three test files | P1-T1..T5, P2-T1..T4, P3-T1..T4 |
| Both tracked locations resolve to git-tracked paths; no `.gitignore` change | P8-T1, P9-T3 (no `.gitignore` task by design) |
| Root copies content-identical to bundled mirrors; Codex translations equivalent | P4-T1..T3, P6-T6, P7-T9, P9-T5, P9-T6 |
| Filename convention preserved (regex unchanged) | P1-T1 (leaves regex unchanged), P1-T5(e) |
| Non-research evidence enforcement unchanged | P2-T1 (additive prefix only), P3-T1 (additive key only), P9-T3 |

## Rollback / Contingency

All changes are text edits to customization/enforcement files plus one file relocation. Rollback: revert the branch. The file relocation in P8-T1 is a copy-then-delete; if any hook regression is detected after relocation, restore the artifact at `artifacts/research/` from git history and re-run validation. No external consumers depend on the research output path (spec Dependencies/Touchpoints: "No CI/CD configuration or release tooling depends on the research output path").

## Open Questions / Notes

- The `enforce-evidence-locations` exclusion-only model is preserved; only forbidden-prefix membership and docstrings change (spec Invariants).
- `.claude/settings.json` requires no functional change (the `research-path` SubagentStop token and `Write(/artifacts/**)` orchestrator allowlist are unaffected); no task edits it. If a descriptive comment referencing `artifacts/research/` is found there during execution, treat it as a P7-class prose edit and record it; otherwise no change.
- `translate-claude-to-codex/SKILL.md` historical research-basis path reference is out of scope (it points to a specific historical artifact, not a routing rule), per research.
