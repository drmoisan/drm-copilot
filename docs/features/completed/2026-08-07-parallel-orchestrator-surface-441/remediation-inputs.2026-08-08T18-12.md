# Remediation Inputs — parallel-orchestrator-surface (#441)

Timestamp: 2026-08-08T18-12

- **Feature:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441`
- **Issue:** #441
- **Base branch:** `epic/parallel-orchestration-integration`
- **Merge base:** `ee0626e838109fe8d3fe3904fb4631c71879baa3`
- **Head:** `feature/parallel-orchestrator-surface-441` @ `41633ad5e867070853e3e4501c3457b6641d1efc`
- **Work mode:** `full-feature`

## Source Audit Artifacts

These remediation inputs derive from the audit artifacts produced in the same pass:

- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/policy-audit.2026-08-08T18-12.md`
  (Gap G2; verdict PARTIALLY COMPLIANT)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/code-review.2026-08-08T18-12.md`
  (findings CR-01 and CR-02, both Major; recommendation Conditional Go)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/feature-audit.2026-08-08T18-12.md`
  (33/33 acceptance criteria PASS; no criterion is affected by the findings below)

PR context evidence: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (both
regenerated during this audit against the resolved base branch; they were absent at audit start).

## Scope Statement

Everything this branch is responsible for passes: Black clean over 372 files, Ruff clean, Pyright
`0 errors, 0 warnings, 0 informations`, `3004 passed` with the count reconciling exactly as
2968 baseline + 36 added, Python line coverage 91.82% against an 85% floor, branch coverage 83.80%
against a 75% floor, zero coverage regression, JSON governance clean, 19/19 evidence artifacts in
canonical locations, 3/3 bundled mirrors byte-identical, the frozen epic surface provably untouched,
and all 33 acceptance criteria PASS.

Remediation is opened for one class of defect only: **the delivered persona's `tools` allowlist does
not permit two actions the delivered skill text prescribes.** Both instances are internal
contradictions among this feature's own four deliverables. They are explicitly *not* the F7
dependency, which `spec.md` `## Cross-Feature Dependencies` legitimately accepts and which the
delivered text discloses correctly at each affected step.

## Enumerated Fix List

### R-01 — Reconcile the parent-side `remediation-inputs` write with the persona's `Write` grants (Major)

**Files:**
- `.claude/skills/parallel-orchestrate/SKILL.md` (lines 277-283, `## Per-Item Merge-Conflict Handling`
  step 1)
- `.claude/agents/parallel-orchestrator.md` (lines 10-13, frontmatter `tools`)
- Mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
  and `.../.claude/agents/parallel-orchestrator.md` (must stay byte-identical to source)
- `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md` (R2.9 item 1, lines
  289-293 — the divergence originates here and should be corrected alongside the implementation)

**Current behavior.** The skill assigns **the parent** the write of the item's
`remediation-inputs.<timestamp>.md` "in the item's active feature folder under
`docs/features/active/`, not to the run's parallel folder". The persona's only `Write`/`Edit` grants
are `docs/features/parallel/**` and `artifacts/orchestration/**`, so the prescribed write is denied at
runtime.

**Why this is a feature-introduced divergence rather than an inherited pattern.** The frozen epic
precedent assigns the equivalent conflict capture and the finding write to the **child's**
`atomic-executor` (`.claude/skills/epic-orchestrate/SKILL.md:187-194`), not to the parent. The
parallel adaptation reassigned the actor without adding the corresponding grant.

**Expected behavior (preferred fix).** Reassign the write to the child's chain, matching the frozen
epic precedent: the parent detects the conflicted `gh pr merge --merge`, passes the conflict evidence
(the `git diff --name-only --diff-filter=U` file list and the raw conflict-marker content) in the
re-delegation prompt, and the child writes its own `remediation-inputs.<timestamp>.md` through its
existing R1–R5 loop. This resolves the contradiction without widening the parent's write scope and
restores parity with the precedent the feature was adapted from.

**Alternative fix (only if the parent must own the write).** Add `Write(docs/features/active/**)` and
`Edit(docs/features/active/**)` to the persona's `tools` allowlist and record the widened blast radius
explicitly in the persona body.

**Do not** silently widen the allowlist without a one-line rationale in the persona body, and do not
leave the skill text and the allowlist disagreeing.

**Verification commands:**
```bash
# The prescribed write target must be covered by a persona Write grant, or the actor must be the child.
grep -n "remediation-inputs" .claude/skills/parallel-orchestrate/SKILL.md
grep -n "Write(\|Edit(" .claude/agents/parallel-orchestrator.md

# Mirrors must remain byte-identical after any edit.
sha256sum .claude/agents/parallel-orchestrator.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
sha256sum .claude/skills/parallel-orchestrate/SKILL.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md

# The heading layout and reserved-section contract must still hold after any text edit.
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q
```

### R-02 — Give the persona a permitted mechanism for the manifest-validation gate (Major)

**Files:**
- `.claude/skills/parallel-orchestrate/SKILL.md` (lines 75-77, `## Parallel Manifest Consumption`)
- `.claude/agents/parallel-orchestrator.md` (lines 14-17, frontmatter `tools`)
- Mirrors as listed in R-01

**Current behavior.** The section makes manifest validation a hard precondition — "A malformed
manifest is rejected before any kickoff … Do not guess a repair, do not silently skip the offending
item, and do not launch a partial cohort" — and names exactly one mechanism: "Validate by calling
`validate_parallel_manifest_text` from `scripts/dev_tools/parallel_manifest_contract.py`, which is a
library call and deliberately not an MCP artifact type." The persona's Bash grants are `Bash(git *)`
and `Bash(gh *)` only, and it holds no MCP tool for manifest validation, so it cannot invoke the gate
it is required to pass. The function does exist (`scripts/dev_tools/parallel_manifest_contract.py:274`,
verified), so this is purely a permission gap.

**Expected behavior.** Pick one and make it consistent across the skill and the persona:
1. Grant a narrowly scoped invocation, for example
   `Bash(poetry run python -m scripts.dev_tools.validate_orchestration_artifacts *)` plus whatever the
   manifest check needs, and confirm the granted form matches the invocation the skill prescribes; or
2. Restate the obligation as a delegation to a component that can run the check; or
3. Coordinate with F3/F4 to expose the manifest check through a surface the persona already holds.

**Do not** weaken the gate itself, and do not delete the "reject before any kickoff" obligation to
make the inconsistency disappear.

**Verification commands:**
```bash
grep -n "validate_parallel_manifest_text\|malformed manifest" .claude/skills/parallel-orchestrate/SKILL.md
grep -n "Bash(\|mcp__" .claude/agents/parallel-orchestrator.md
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q
```

### R-03 — Add a structural contract test closing this gap class (Major, same cycle)

**File:** `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (and
`parallel_orchestrator_surface_test_support.py` if a parser is needed)

**Current behavior.** No acceptance criterion and no test covers consistency between the persona's
`tools` allowlist and the actions the skill text prescribes, which is why R-01 and R-02 reached review
undetected.

**Expected behavior.** Add at least one test asserting that every filesystem write target the skill
prescribes is covered by a `Write` grant in the persona frontmatter. Keep it in the style already
established in this module: parse the persona's grants at run time rather than restating them, so a
future allowlist narrowing fails the test. Note the 500-line file limit —
`test_parallel_orchestrator_surface_contracts.py` is already at 457 lines and
`parallel_orchestrator_surface_test_support.py` at 465, so a further module split may be required.

**Verification command:**
```bash
poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q
```

## Recommended Non-Blocking Items (may be folded into this cycle)

These are Minor/Nit findings from `code-review.2026-08-08T18-12.md`. They do not gate merge; include
them only if the plan can carry them without expanding scope.

- **CR-03 / G2-adjacent — third instance, inherited.** `parallel-orchestrate/SKILL.md:397-399` offers
  the CLI fallback `python -m scripts.dev_tools.validate_orchestration_artifacts ...`, which the
  persona's Bash grants also do not permit. This pattern is inherited verbatim from
  `epic-orchestrate/SKILL.md:279` under the identical allowlist, so it may be deferred with the rest of
  that pattern rather than fixed here.
- **CR-03 — frozen-surface pin lifetime.**
  `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:78-90`. Record the intended
  lifetime of the two SHA-256 pins, or amend the assertion message at
  `test_parallel_orchestrator_surface_contracts.py:454-457` so a future maintainer editing the epic
  surface is told to update the constant rather than to restore a "pre-feature state" that will no
  longer be meaningful.
- **CR-04 — three untested guard branches.** Add negative tests for `split_frontmatter` (missing fence,
  unterminated fence) and `extract_section` (absent heading) in
  `parallel_orchestrator_surface_test_support.py:151-159, 297-301`. These guards are the suite's
  fail-closed mechanism and are currently unverified; the tests are three lines each over string
  literals, with no I/O.
- **CR-05 — non-reproducible coverage attribution.**
  `evidence/qa-gates/coverage-delta.2026-08-08T17-58.md` lines 25, 44-47, 79-86 record post-change
  branch coverage as 83.82% (`covered_branches` 4191, partial 555) and attribute the +1 destination to
  this branch's content. An independent re-run at the same HEAD produced 83.80%
  (`covered_branches` 4190, partial 556). Amend the attribution sentence to state that the
  single-destination movement is environment-dependent. The verdict is unaffected: both values clear
  the 75% floor and neither is a regression.
- **Spec wording — criteria S8 / S19.** `spec.md` acceptance criteria 8 and 18 are mutually exclusive
  if read literally (one asks the skill to state the literal `Epic mode: true`, the other forbids that
  literal in any delivered runtime file). The implementation resolved this correctly in favour of the
  negative obligation. Reword S8 semantically so a future reader does not mistake the paraphrase for a
  shortfall.

## Out of Scope for This Cycle

- **The F7 dependency.** `EPIC_MERGE_GATE_BLOCKED` and `EPIC_WORKTREE_REMOVAL_BLOCKED` blocking live
  execution is an accepted, spec-documented limitation (`spec.md` `## Cross-Feature Dependencies`;
  `user-story.md` `## Non-Goals`). Do not attempt to work around either gate, and do not touch
  `.claude/hooks/` or `.claude/settings.json` — acceptance criterion S22 requires the branch diff to
  contain no such change.
- **The pre-existing Pester test-isolation defect (policy-audit Gap G1).**
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` has one failing test because the hook
  under test reads the real gitignored `artifacts/orchestration/orchestrator-state.json` rather than a
  test-supplied checkpoint. This branch changes zero PowerShell files and the suite's last
  modification (`72360a22`) predates the merge base, so it is not attributable here. Track it as a
  separate potential-bug entry.
- **F6 and F8 content.** The three reserved sections must keep exactly their one-line reserved bodies;
  `test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body` asserts exact body equality.

## Do-Not-Do List

- Do not weaken, delete, skip, or `xfail` any of the 36 contract tests, and do not relax an assertion
  to accommodate an edit. Test count must remain at 3004 or increase.
- Do not modify `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, or
  `.claude/skills/orchestrate/SKILL.md`. Criteria S20 and S21 require an empty `git diff` for all
  three, and two are additionally content-hash pinned.
- Do not modify anything under `.claude/hooks/` and do not modify `.claude/settings.json` (criterion
  S22).
- Do not modify any policy document under `.claude/rules/` or `.github/instructions/`, including
  `.claude/rules/parallel-orchestration.md` — schema and enum ownership belongs to F3.
- Do not add, rename, remove, or reorder any `##` heading in `parallel-orchestrate/SKILL.md`. The
  layout is pinned by an exact 16-heading count and an exact first-13 ordered tuple.
- Do not introduce any of the literals `Epic mode: true`, `--base epic/`, or `integration-to-main`
  into the three delivered runtime files (criterion S19).
- Do not let a source file and its bundled mirror under
  `extensions/drm-copilot/resources/claude-customizations/` diverge; re-verify by SHA-256 after every
  edit and keep `pack-manifests/core.json` in sorted order.
- Do not add a `depends_on` key or an `integration_branch` key anywhere, in any artifact.
- Do not write evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`,
  `artifacts/evidence/`, or any other non-canonical path. Use
  `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/<kind>/` per
  `evidence-and-timestamp-conventions`.
- Do not add a dependency, a `# noqa`, or a `# type: ignore`. The branch currently carries zero of
  each.
- Do not uncheck any of the 33 acceptance criteria in `spec.md` or `user-story.md`; all 33 are
  independently verified as PASS. Do not add criteria to any source file.
- Do not expand scope into F6, F7, or F8 behavior.
- No scope creep, no policy weakening, no silent skips.

## Exit Criteria for This Cycle

1. R-01, R-02, and R-03 resolved, with the skill text and the persona `tools` allowlist in agreement.
2. Full Python toolchain clean in a single pass: `poetry run black --check .`,
   `poetry run ruff check .`, `poetry run pyright`,
   `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
3. Test count >= 3004, zero failures, zero skips.
4. Python line coverage >= 85% and branch coverage >= 75%, with no regression versus
   `evidence/baseline/baseline-pytest-coverage.2026-08-08T16-47.md`.
5. All three bundled mirrors byte-identical to their sources by SHA-256; `core.json` still passes
   `format_json --check` and `validate_json`.
6. Empty `git diff` for the three frozen paths, for `.claude/hooks/`, and for `.claude/settings.json`.
7. `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exits 0.
8. A reaudit records `blocking_count == 0`.

## Handoff

Plan authorship belongs to `atomic-planner` per
`.claude/skills/remediation-handoff-atomic-planner/SKILL.md`; this reviewer did not author a plan, so
as not to usurp that role. The orchestrator should delegate to `atomic-planner` with these inputs, run
preflight through `atomic-executor` until `PREFLIGHT: ALL CLEAR`, execute task-by-task, then delegate
the reaudit back to `feature-review`.

Plan shape must conform to `.claude/skills/atomic-plan-contract/SKILL.md`: `### Phase N — <Title>`
headings, `- [ ] [P#-T#]` task IDs, Phase 0 capturing policy reads and baseline toolchain results, and
a final phase running the full toolchain QA loop with numeric coverage values recorded.

**Assumption recorded:** no MCP tool surface (`mcp__drm-copilot__*`) was available in this reviewer's
allowlist, so `mcp__drm-copilot__validate_orchestration_artifacts` could not be run against the three
review artifacts or against any plan. Template assets were resolved by the canonical bundled paths
that `extensions/drm-copilot/src/policy-audit-template-assets.ts` maps each selector to. The
orchestrator should run the MCP validators against these artifacts if that surface is available to it.
