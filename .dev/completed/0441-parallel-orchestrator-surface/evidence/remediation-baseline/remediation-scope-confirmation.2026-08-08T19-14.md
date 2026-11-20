# Remediation Scope Confirmation — Cycle 1 (Issue #441)

Timestamp: 2026-08-08T19-14

Branch: `feature/parallel-orchestrator-surface-441` @ `41633ad5e867070853e3e4501c3457b6641d1efc`
Base branch: `epic/parallel-orchestration-integration` (merge base `ee0626e838109fe8d3fe3904fb4631c71879baa3`)

## Inputs Read

- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/remediation-inputs.2026-08-08T18-12.md` (authoritative for this cycle)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/code-review.2026-08-08T18-12.md` (findings table and executive summary; CR-01, CR-02, CR-05)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/policy-audit.2026-08-08T18-12.md` (Gap G2 at line 514; Gap G1 at lines 85, 378, 486)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/feature-audit.2026-08-08T18-12.md` (33/33 acceptance criteria PASS)
- `.claude/skills/parallel-orchestrate/SKILL.md` (436 lines, 16 `##` headings)
- `.claude/agents/parallel-orchestrator.md` (225 lines, 9 `##` headings, 12 `tools` entries)
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (36 tests)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` (14 pure parsers)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (inert pinned data)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md` (`#### R2.9` at line 284; `## Acceptance Criteria` at line 516)

## In-Scope Item 1 — R-01 (Major)

**Current defect location.** `.claude/skills/parallel-orchestrate/SKILL.md:277-283`, step 1 of
`## Per-Item Merge-Conflict Handling`. The sentence reads "the parent converts the conflict into a
synthetic Blocking finding written to that item's own `remediation-inputs.<timestamp>.md` in the
item's active feature folder under `docs/features/active/`, not to the run's parallel folder." The
persona's only write grants are `.claude/agents/parallel-orchestrator.md:10` (`Write(docs/features/parallel/**)`),
`:11` (`Edit(docs/features/parallel/**)`), `:12` (`Write(artifacts/orchestration/**)`), and `:13`
(`Edit(artifacts/orchestration/**)`), none of which covers `docs/features/active/`. The requirement
divergence originates at `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md:289-293`
(`#### R2.9` item 1). The frozen precedent at `.claude/skills/epic-orchestrate/SKILL.md:187-194`
assigns the equivalent capture and write to the child's `atomic-executor`.

**Target end state (one sentence).** Step 1 assigns the conflict capture and the
`remediation-inputs.<timestamp>.md` write to the child's `atomic-executor` inside the item's own
worktree and active feature folder, with the parent limited to detecting the conflicted
`gh pr merge --merge` and re-delegating, so no sentence pairs the parent with a write verb and a path
token and no new persona grant is required.

## In-Scope Item 2 — R-02 (Major)

**Current defect location.** `.claude/skills/parallel-orchestrate/SKILL.md:73-77`, the final bullet of
`## Parallel Manifest Consumption`. The bullet makes manifest validation a hard precondition
("A malformed manifest is rejected before any kickoff") and names exactly one mechanism, the library
call `validate_parallel_manifest_text` from `scripts/dev_tools/parallel_manifest_contract.py` (the
function exists at `scripts/dev_tools/parallel_manifest_contract.py:274`). The persona's execution
grants are `.claude/agents/parallel-orchestrator.md:14` (`Bash(git *)`), `:15` (`Bash(gh *)`), `:16`
(`mcp__drm-copilot__collect_pr_context`), and `:17`
(`mcp__drm-copilot__validate_orchestration_artifacts`), none of which can invoke a Python library
call. A third instance of the same class sits at `.claude/skills/parallel-orchestrate/SKILL.md:398`,
the checkpoint-validator CLI fallback whose bare `python -m` head no grant covers.

**Target end state (one sentence).** The persona `tools` list gains exactly
`"Bash(poetry run python -c *)"` and `"Bash(poetry run python -m *)"` immediately after
`"Bash(gh *)"` with an in-body rationale in `## Skill`, the manifest bullet names the permitted
`poetry run python -c` invocation beneath its unchanged obligation, and the line-398 CLI fallback is
normalized to `poetry run python -m` so every prescribed invocation is grant-covered.

## In-Scope Item 3 — R-03 (Major)

**Current defect location.** `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
(457 lines, 36 tests). No test in that inventory parses the persona `tools` allowlist as a producer
of permissions and the skill procedure as a consumer; the three existing seam tests
(`test_seam_status_template_realises_*`, lines 297-377) bind only skill-prescribed
`parallel-status.md` names to the shipped template. No acceptance criterion in `spec.md`
`## Acceptance Criteria` (line 516) or `user-story.md` covers allowlist/procedure consistency, which
is why R-01 and R-02 reached review undetected.

**Target end state (one sentence).** A new test module
`tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py`, backed by new pure
parsers in `tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py` and three
pinned data constants in `parallel_orchestrator_surface_expectations.py`, asserts at run time that
every parent write target and every command invocation the delivered skill prescribes is covered by a
`Write(...)` or `Bash(...)` grant parsed from the delivered persona frontmatter.

## In-Scope Item 4 — Evidence Correction (Minor, CR-05)

**Current defect location.**
`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.2026-08-08T17-58.md`
lines 25, 44-47, and 79-86. The artifact records post-change branch coverage as 83.82%
(`covered_branches` 4191, `num_partial_branches` 555) and attributes the single-destination movement
to this branch's new `.claude` files and `core.json` entries. An independent re-run at the same HEAD
produced 83.80% (`covered_branches` 4190, `num_partial_branches` 556), so the recorded figure is not
reproducible and the causal attribution is unsupported.

**Target end state (one sentence).** The artifact carries only the branch figures re-measured at
`41633ad5e867070853e3e4501c3457b6641d1efc` and recorded in the P0-T7 artifact, replaces the causal
attribution with a statement that a single-destination difference between runs at the same HEAD is
environment-dependent, adds a dated correction note naming the P0-T7 artifact and CR-05, and keeps its
PASS verdict and every line-coverage figure unchanged.

## Explicitly Out of Scope for This Cycle

- **The F7 dependency.** `EPIC_MERGE_GATE_BLOCKED` (`.claude/hooks/enforce-epic-merge-gate.ps1`) and
  `EPIC_WORKTREE_REMOVAL_BLOCKED` (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`) block live
  end-to-end execution of the parallel surface. This is an accepted, spec-documented limitation
  (`spec.md` `## Cross-Feature Dependencies`; `user-story.md` `## Non-Goals`), not a defect. No work is
  planned against it, no `.claude/hooks/` file is touched, and `.claude/settings.json` is not modified.
- **The Pester test-isolation defect (policy-audit Gap G1).**
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
  `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` read the real gitignored
  `artifacts/orchestration/orchestrator-state.json` rather than a test-supplied checkpoint, so their
  outcome depends on whether an orchestrated run is in progress. The defect is pre-existing and out of
  diff (this branch changes zero PowerShell files; the suites' last modification `72360a22` predates
  the merge base). Neither file is edited and Phase 6 runs no Pester stage.
- **F6 and F8 content.** `## Mutation Protocol (F6)`, `## Enforcement Hooks (F7)`, and
  `## Radius Drift Detection (F8)` must retain exactly their one-line reserved bodies and remain the
  final three top-level headings in that order;
  `test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body` asserts exact body equality.
  No wave-4 behavior is added, and no F3-owned enum in `.claude/rules/parallel-orchestration.md` is
  extended.
- **Non-blocking review items CR-03 (frozen-pin lifetime wording) and CR-04 (three untested parser
  guard branches)**, and the S8/S19 spec-wording note. The directive scopes this cycle to four items and
  none of these three is required for any exit criterion. The CR-03 instance concerning the inherited
  `python -m` CLI fallback is resolved incidentally by the R-02 normalization, because leaving it would
  make the R-03 test unable to serve its purpose.
