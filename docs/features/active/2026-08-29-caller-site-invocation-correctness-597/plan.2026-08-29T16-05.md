# caller-site-invocation-correctness (Plan)

- **Issue:** #597
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T16-05
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (spec.md is the sole acceptance-criteria source; `issue.md` line numbers
  185/64/310-314 are stale — this plan uses spec.md's corrected numbers 183/62/151, 307-311
  throughout, per the research artifact
  `research/caller-site-invocation-correctness.2026-08-29T16-30.md`).

**Coverage note (mandatory statement, not an omission).** No coverage evidence contract applies to
this feature. Zero executable/source lines are added or changed: all six edits are markdown/prose
text inside `.claude/**` instruction files and their byte-identical bundle mirrors. No
PowerShell/Python/TypeScript/C# source file is created or modified. Phase 3 therefore runs two
targeted regression commands (an existing pytest node and an existing Pester spec file) instead of a
coverage-bearing toolchain loop, and no numeric coverage value is recorded anywhere in this plan.

**Preparation-mode scope.** This plan is authored for `DIRECTIVE: PREFLIGHT VALIDATION ONLY` in this
session. No task below is executed now. No PR-authoring or CI-monitoring task is included; that
occurs later during epic execution.

**Evidence location (mandatory).** All evidence artifacts in this plan are written under
`docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/<kind>/`, per
`evidence-and-timestamp-conventions`. No `artifacts/**` evidence path is used anywhere in this plan.

---

### Phase 0 — Context & Baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`,
      `.claude/rules/general-unit-test.md`, and `.claude/rules/powershell.md` (the last read for
      contextual background only — no `.claude/lib/**` `.psm1`/`.ps1` file is edited by this
      feature; the six touched files are PowerShell-invocation instruction text inside markdown).
      Write `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/baseline/phase0-instructions-read.md`
      containing `Timestamp:` (ISO-8601 `yyyy-MM-ddTHH-mm`), `Policy Order:` listing the four files
      above in the order read, and an explicit statement that no language-specific code-change rule
      beyond PowerShell applies because no source file is edited.
      Acceptance: the artifact file exists and contains all four required fields.

- [x] [P0-T2] Capture the pre-edit git state as fail-before evidence. Run
      `git status --porcelain -- .claude/skills/parallel-plan/SKILL.md .claude/skills/parallel-add/SKILL.md .claude/agents/parallel-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`
      and write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/baseline/git-status-baseline.<TIMESTAMP>.md`
      (replace `<TIMESTAMP>` with the actual ISO-8601 `yyyy-MM-ddTHH-mm` value at capture time)
      containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (expected: empty
      porcelain output, confirming no pre-existing uncommitted changes to the six target files).
      Acceptance: the artifact exists with all four required fields and `EXIT_CODE: 0`.

- [x] [P0-T3] Capture fail-before literal-token evidence that the CURRENT (uncorrected) invocation
      text is present at all six target files before any edit lands. Run, as a fixed-string
      (`-F`) search restricted to each of the six paths, the literal token
      `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` against:
      `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`,
      `.claude/agents/parallel-planner.md`,
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`,
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`,
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`.
      Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/baseline/uncorrected-text-baseline.<TIMESTAMP>.md`
      containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reporting exactly one
      match per file (six matches total) and explicitly stating "No coverage evidence applies — this
      is a fail-before literal-token baseline for a markdown-only correction, not a coverage
      baseline."
      Acceptance: the artifact exists, reports six matches (one per file), and `EXIT_CODE: 0`
      (grep/rg exit 0 = matches found).

- [x] [P0-T4] Confirm the two existing truthiness-warning passages and the out-of-scope
      `parallel_lane_assertion` line are present in their pre-edit form, as a second fail-before
      reference point for Phase 2's unchanged-content verification. Run, as fixed-string searches:
      the literal token `unconditionally truthy under PowerShell boolean coercion, so` against
      `.claude/lib/blast-radius/BlastRadius.psm1`; the literal token `The hashtable itself is always
      truthy, so a bare boolean test on the result treats every pair as` against
      `.claude/skills/parallel-plan/SKILL.md`; and the literal token `parallel_lane_assertion`
      against `.claude/skills/parallel-plan/SKILL.md`. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/baseline/unchanged-passages-baseline.<TIMESTAMP>.md`
      containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reporting one match
      for each of the three tokens.
      Acceptance: the artifact exists and reports exactly one match per token, `EXIT_CODE: 0`.

---

### Phase 1 — Implementation (six file edits)

- [x] [P1-T1] In `.claude/skills/parallel-plan/SKILL.md`, replace the fenced ```powershell block
      content at line 183 (block opened at line 182, closed at line 184):
      `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force`
      with the two-line root-anchored, fail-fast form:
      `$repoRoot = git rev-parse --show-toplevel`
      followed on the next line by
      `Import-Module (Join-Path $repoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop`.
      Immediately after the closing ``` ` ``` fence (before the existing "The facade re-exports..."
      paragraph), insert one new sentence documenting the PowerShell 5.1 execution-policy trap:
      "The default PowerShell 5.1 execution policy blocks `Import-Module` of a `.psm1` file, so
      `pwsh` is mandatory here." Do not modify any other line in this file in this task (lines
      307-311 and 315 must remain byte-unchanged; verified separately in Phase 2).
      Acceptance: the file contains the two corrected lines and the new sentence at the stated
      location, and no other line in the file differs from its Phase 0 baseline state.

- [x] [P1-T2] Apply the identical edit from [P1-T1], byte-for-byte, to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`.
      Acceptance: this file is byte-identical to the repo file edited in [P1-T1] after the edit.

- [x] [P1-T3] In `.claude/skills/parallel-add/SKILL.md`, make two corrections within the same
      numbered list item (item 3, lines 59-69):
      (a) at line 62, replace the parenthetical
      `` (`Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force`) ``
      with
      `` (the default PowerShell 5.1 execution policy blocks `Import-Module` of a `.psm1` file, so `pwsh` is mandatory: run as `$repoRoot = git rev-parse --show-toplevel; Import-Module (Join-Path $repoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop`) ``,
      preserving the surrounding sentence structure (do not replace with a fenced code block);
      (b) at lines 67-68, replace
      "Read the verdict from the conflict key of the returned hashtable. The hashtable itself is
      always truthy, so a bare boolean test on the result treats every pair as conflicting."
      with
      "Read the verdict from `$result['conflict']`; do not test the returned hashtable itself, since
      it is always truthy under PowerShell boolean coercion, so a bare `if ($result)` check treats
      every pair as conflicting."
      Do not modify any other line in this file in this task.
      Acceptance: the file contains both corrected passages at the stated locations, and no other
      line in the file differs from its Phase 0 baseline state.

- [x] [P1-T4] Apply the identical edit from [P1-T3], byte-for-byte, to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`.
      Acceptance: this file is byte-identical to the repo file edited in [P1-T3] after the edit.

- [x] [P1-T5] In `.claude/agents/parallel-planner.md`, replace the fenced ```powershell block
      content at line 151 (block opened at line 150, closed at line 152):
      `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force`
      with the two-line root-anchored, fail-fast form:
      `$repoRoot = git rev-parse --show-toplevel`
      followed on the next line by
      `Import-Module (Join-Path $repoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop`.
      Immediately after the closing ``` ` ``` fence (before the existing "The facade exports..."
      paragraph), insert one new sentence documenting the PowerShell 5.1 execution-policy trap:
      "The default PowerShell 5.1 execution policy blocks `Import-Module` of a `.psm1` file, so
      `pwsh` is mandatory here." Do not modify any other line in this file in this task.
      Acceptance: the file contains the two corrected lines and the new sentence at the stated
      location, and no other line in the file differs from its Phase 0 baseline state.

- [x] [P1-T6] Apply the identical edit from [P1-T5], byte-for-byte, to
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`.
      Acceptance: this file is byte-identical to the repo file edited in [P1-T5] after the edit.

---

### Phase 2 — Verification (post-edit literal-token and unchanged-content checks)

- [x] [P2-T1] Confirm the corrected text landed at `.claude/skills/parallel-plan/SKILL.md`. Run
      fixed-string searches restricted to this file for each of the three tokens
      `git rev-parse --show-toplevel`, `-ErrorAction Stop`, and `mandatory here.` (corrected from the
      wrap-fragile `` `pwsh` is mandatory `` token originally specified here: the execution-policy
      sentence Phase 1 inserts wraps across two physical lines in the target file, so a single-line
      fixed-string search must use the single-line tail `mandatory here.` per the
      `atomic-plan-contract` wrap-tolerant assertion rule G6). Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-plan-skill.<TIMESTAMP>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reporting one match per token.
      Acceptance: all three tokens match exactly once; `EXIT_CODE: 0`.

- [x] [P2-T2] Confirm the corrected text landed at
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
      using the identical three-token search from [P2-T1] (as corrected: `mandatory here.` in place of
      `` `pwsh` is mandatory ``) restricted to this mirror path. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-plan-skill-mirror.<TIMESTAMP>.md`
      with the four required fields.
      Acceptance: all three tokens match exactly once; `EXIT_CODE: 0`.

- [x] [P2-T3] Confirm the corrected text landed at `.claude/skills/parallel-add/SKILL.md`. Run
      fixed-string searches restricted to this file for each of the four tokens
      `git rev-parse --show-toplevel`, `-ErrorAction Stop`, `` `pwsh` is mandatory ``, and
      `$result['conflict']`. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-add-skill.<TIMESTAMP>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reporting one match per token.
      Acceptance: all four tokens match exactly once; `EXIT_CODE: 0`.

- [x] [P2-T4] Confirm the corrected text landed at
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
      using the identical four-token search from [P2-T3] restricted to this mirror path. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-add-skill-mirror.<TIMESTAMP>.md`
      with the four required fields.
      Acceptance: all four tokens match exactly once; `EXIT_CODE: 0`.

- [x] [P2-T5] Confirm the corrected text landed at `.claude/agents/parallel-planner.md`. Run
      fixed-string searches restricted to this file for each of the three tokens
      `git rev-parse --show-toplevel`, `-ErrorAction Stop`, and `mandatory here.` (corrected from the
      wrap-fragile `` `pwsh` is mandatory `` token originally specified here, per the same rationale
      recorded at [P2-T1]). Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-planner-agent.<TIMESTAMP>.md`
      with the four required fields, reporting one match per token.
      Acceptance: all three tokens match exactly once; `EXIT_CODE: 0`.

- [x] [P2-T6] Confirm the corrected text landed at
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`
      using the identical three-token search from [P2-T5] (as corrected: `mandatory here.` in place of
      `` `pwsh` is mandatory ``) restricted to this mirror path. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-planner-agent-mirror.<TIMESTAMP>.md`
      with the four required fields.
      Acceptance: all three tokens match exactly once; `EXIT_CODE: 0`.

- [x] [P2-T7] Confirm `.claude/lib/blast-radius/BlastRadius.psm1:432-441` is byte-unchanged. Run a
      fixed-string search restricted to this file for the literal token `unconditionally truthy
      under PowerShell boolean coercion, so` (the same token searched at baseline in [P0-T4]) and
      confirm an identical single match. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-blastradius-psm1-unchanged.<TIMESTAMP>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` explicitly comparing against
      the [P0-T4] baseline count.
      Acceptance: exactly one match, unchanged from [P0-T4]; `EXIT_CODE: 0`.

- [x] [P2-T8] Confirm `.claude/skills/parallel-plan/SKILL.md:307-311` (the sibling truthiness
      warning) is byte-unchanged. Run a fixed-string search restricted to this file for the literal
      token `The hashtable itself is always truthy, so a bare boolean test on the result treats
      every pair as` (the same token searched at baseline in [P0-T4]) and confirm an identical
      single match. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-plan-sibling-warning-unchanged.<TIMESTAMP>.md`
      with the four required fields, explicitly comparing against the [P0-T4] baseline count.
      Acceptance: exactly one match, unchanged from [P0-T4]; `EXIT_CODE: 0`.

- [x] [P2-T9] Confirm `.claude/skills/parallel-plan/SKILL.md:315` and its surrounding
      `parallel_lane_assertion` list item (lines 313-325) are byte-unchanged. Run a fixed-string
      search restricted to this file for the literal token `parallel_lane_assertion` (the same
      token searched at baseline in [P0-T4]) and confirm an identical single match. Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-parallel-lane-assertion-unchanged.<TIMESTAMP>.md`
      with the four required fields, explicitly comparing against the [P0-T4] baseline count.
      Acceptance: exactly one match, unchanged from [P0-T4]; `EXIT_CODE: 0`.

- [x] [P2-T10] Confirm `.claude/skills/parallel-orchestrate/SKILL.md`,
      `.claude/skills/epic-orchestrate/SKILL.md`, and their two bundle mirrors
      (`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`,
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`)
      are not modified by this feature. Run
      `git diff main -- .claude/skills/parallel-orchestrate/SKILL.md .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
      (anchored to the `main` ref per rule G8). Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/verify-orchestrate-skills-untouched.<TIMESTAMP>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reporting empty diff output for
      all four paths.
      Acceptance: the diff output is empty for all four paths; `EXIT_CODE: 0`.

---

### Phase 3 — Final QC (targeted regression commands; no format/lint/type-check loop applies)

No PowerShell, Python, TypeScript, or C# source file is created or modified by this feature, so the
seven-stage mandatory toolchain loop in `.claude/rules/general-code-change.md` has no applicable
stage here beyond the two targeted regression commands below. This IS the final QC gate for this
feature.

- [ ] [P3-T1] Run the bundle-parity pytest node:
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v`.
      This node ID is a real, nameable test confirmed present in
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101`. No `--cov` argument
      applies (no coverage impact for a markdown-only change). Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/pytest-bundle-parity.<TIMESTAMP>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the pytest
      pass/fail count line (e.g. "1 passed").
      Acceptance: `EXIT_CODE: 0` and `Output Summary:` reports `1 passed`.

- [ ] [P3-T2] Run the existing PowerShell regression pair for the `$result['conflict']` truthiness
      hazard:
      `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1"`.
      This is the correct invocation form for this feature: the repo's established PowerShell
      toolchain convention (`.claude/rules/powershell.md`) runs Pester through the
      `mcp__drm-copilot__run_poshqc_test` MCP tool, but that tool accepts only `scan_folders`
      (folder-level scanning against bundled extension resources per its own description — "Run
      bundled PoshQC Pester checks... using bundled extension resources"), not a single test-file
      path; no CI workflow (`.github/workflows/*.yml`) invokes `Invoke-Pester` directly either. A
      direct `pwsh -NoProfile -Command "Invoke-Pester -Path <file>"` invocation against the repo
      working tree is therefore the only form that targets this exact single spec file. No coverage
      table applies (this is a regression confirmation of an unmodified test file, not a new
      coverage measurement). Write
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/qa-gates/pester-blast-radius-conflict.<TIMESTAMP>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the Pester
      pass/fail count line (e.g. "Tests Passed: N, Failed: 0").
      Acceptance: `EXIT_CODE: 0` and `Output Summary:` reports zero failed tests.

---

### Phase 4 — Documentation & Handoff

- [ ] [P4-T1] After [P2-T1] passes, in
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/spec.md`, change the
      Acceptance Criteria checkbox beginning "`.claude/skills/parallel-plan/SKILL.md:183` (fenced"
      from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked and no other AC checkbox in `spec.md` changes as a
      side effect of this task.

- [ ] [P4-T2] After [P2-T2] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
      is byte-identical" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T3] After [P2-T3] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`.claude/skills/parallel-add/SKILL.md:62` (inline parenthetical" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T4] After [P2-T4] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
      is byte-identical" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T5] After [P2-T5] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`.claude/agents/parallel-planner.md:151` (fenced" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T6] After [P2-T6] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`
      is byte-identical" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T7] After [P2-T3] and [P2-T4] pass (both confirm the `$result['conflict']` token), in
      `spec.md`, change the Acceptance Criteria checkbox beginning "Where the surrounding prose at a
      corrected site discusses reading" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T8] After [P2-T7] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`.claude/lib/blast-radius/BlastRadius.psm1:432-441` (the existing truthiness warning)" from
      `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T9] After [P2-T8] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`.claude/skills/parallel-plan/SKILL.md:307-311` (the sibling truthiness warning)" from
      `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T10] After [P2-T9] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`.claude/skills/parallel-plan/SKILL.md:315` (the out-of-scope" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T11] After [P2-T10] passes, in `spec.md`, change the Acceptance Criteria checkbox
      beginning "`.claude/skills/parallel-orchestrate/SKILL.md` and
      `.claude/skills/epic-orchestrate/SKILL.md`" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T12] After [P3-T1] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes" from `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T13] After [P3-T2] passes, in `spec.md`, change the Acceptance Criteria checkbox beginning
      "`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` (the existing" from
      `- [ ]` to `- [x]`.
      Acceptance: this single checkbox is checked.

- [ ] [P4-T14] After all 13 spec.md Acceptance Criteria checkboxes are checked, update
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/issue.md`: change
      `- Status: Promoted -> ...` to reflect delivered state, and check the `- [ ] Move to active fix
      folder / branch` box under `## Next Step`. Write an issue-update mirror artifact at
      `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/issue-updates/issue-597.<TIMESTAMP>.md`
      containing `Timestamp:`, the exact text of the `issue.md` change, and `PostedAs:` per
      `evidence-and-timestamp-conventions`.
      Acceptance: `issue.md`'s Status line and Next Step checkbox are updated, and the mirror
      artifact exists with the required fields.

---

## Requirements Sources

1. `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/issue.md` (stale line
   numbers 185/64/310-314 — superseded).
2. `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/spec.md` (authoritative;
   13 Acceptance Criteria; corrected line numbers 183/62/151, 307-311; locked root-anchoring design
   decision).
3. `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/research/caller-site-invocation-correctness.2026-08-29T16-30.md`.
