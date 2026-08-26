# 2026-08-25-epic-orchestrator-always-on-context-footprint (Plan)

- **Issue:** #559
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-26
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** `full-bug` — `spec.md` is the sole acceptance-criteria source. This is a full-bug
  plan; the three-phase minimal-audit contract does not apply.
- **Spec:** `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`
- **Research:** `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/research/2026-08-25T23-10-epic-orchestrator-context-footprint-research.md`
- **Issue record:** `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/issue.md`
- **Narrative:** `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/user-story.md`

**Source precedence.** Where the research and `issue.md` disagree, the research is authoritative.
Five issue statements did not survive verification (research §0, corrections C1 through C5) and this
plan is written against the verified facts, not the issue text.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks,
and coverage-comparison tasks for each in-scope language where policy requires coverage. If any
required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit
verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its exact artifact path. Every
command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Do not
mark evidence-backed work complete without the artifact.

**Evidence location is non-overridable.** Every artifact in this plan resolves under
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/` per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No artifact is written to
`artifacts/baseline/`, `artifacts/qa-gates/`, `artifacts/coverage/`, or any other `artifacts/`-rooted
evidence path.

**Fixed filename timestamp.** Every evidence filename in this plan uses the literal timestamp token
`2026-08-26T00-00`. The executor uses that exact literal so the declared blast radius below is exact
rather than approximate. The real wall-clock time of each run is recorded in the artifact's own
`Timestamp:` field.

---

## DECLARED BLAST RADIUS

This plan executes inside a live parallel run. Conflict edges against concurrent items are computed
from this radius. It is declared wide on purpose: an under-reported radius lets two conflicting items
run concurrently and corrupt each other.

### paths — every file this implementation writes

Production and runtime surface (10 files):

- `CLAUDE.md`
- `.claude/agents/epic-orchestrator.md`
- `.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/rules/parallel-orchestration.md`
- `.claude/rules/plan-acceptance-gates.md`
- `.claude/rules/orchestrator-state.md`
- `.claude/rules/ci-workflows.md`
- `.claude/rules/benchmark-baselines.md`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`

Bundled-payload mirrors, forced into this same commit by the byte-identity test
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` (8 files, all CERTAIN, not a
follow-up):

- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/ci-workflows.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/benchmark-baselines.md`

New test files (2 files, created by this change):

- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
- `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`

Feature-folder documents (3 files):

- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/plan.2026-08-25T22-07.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/issue.md`

Evidence artifacts (29 files, all concrete literals, no placeholder markers):

- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/phase0-instructions-read.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-git-state.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-black.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-ruff.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pyright.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-digest-pin.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-rules-frontmatter-inventory.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/always-on-line-count-before.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/always-on-line-count-after.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/always-on-line-count-comparison.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/fail-before-rules-frontmatter.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/fail-before-epic-contract.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-black.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-ruff.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-pyright.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-codex-agent-variants.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/scope-containment.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/push-down-mirror-parity.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/frozen-epic-digest-repin.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/f3-glob-justification.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/f5-reserved-human-decision.2026-08-26T00-00.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md`

Orchestration checkpoint (written by the orchestrator, not by this plan's implementation tasks;
recorded here for completeness and excluded from derivation because `artifacts/` is a configured
mandate-read prefix and is not a known top-level segment):

- `artifacts/orchestration/orchestrator-state.json`

**Total declared writes: 52 concrete files** (10 runtime + 8 mirrors + 2 new tests + 3 feature
documents + 29 evidence artifacts), plus the orchestration checkpoint.

### Four extraction notes the scheduler must apply by hand

1. **`CLAUDE.md` is separator-free.** `classify_path_token` admits a separator-free token only when
   it is an exact ordinal member of the configured root-surface set in `config/blast-radius.json`,
   and `CLAUDE.md` is not in that set. A bare citation of it is therefore dropped by automatic
   derivation. It is a genuine write by this change and must be present in the declared radius. This
   is the single highest under-report risk in this plan.
2. **The five `.claude/rules/*.md` writes survive the mandate-read exclusion only because they are
   declared.** `config/blast-radius.json` lists `.claude/rules/**` under `mandate_reads`, so a
   citation of a rules file is removed from the derived harvest as a read. Constraint 1 of the
   mandate-read doctrine in `.claude/rules/parallel-orchestration.md` requires the planner to append
   the exact path when the item genuinely writes an excluded path. This change genuinely writes five
   of them, so all five appear above as explicit entries after normalization.
3. **`[P4-T5]` and `[P6-T8]` cite many paths as NON-writes, and none of them belongs in the radius.**
   Both tasks are `git diff HEAD --exit-code` guards whose entire purpose is to prove a path was left
   alone; a path appearing in one of those pathspecs is evidence of the opposite of a write. This is
   the largest source of cited-but-not-written tokens in the plan, and `[P4-T5]` in particular cites
   twenty-one operands, nine of which are bundled mirrors. Two classes of them survive the
   mandate-read exclusion
   and would be harvested by automatic derivation: `.claude/skills/python-qa-gate/SKILL.md` and
   `.claude/skills/powershell-qa-gate/SKILL.md`, which are not mandate-read entries; and every
   `extensions/drm-copilot/resources/claude-customizations/` mirror path, because the `mandate_reads`
   glob `.claude/rules/**` is anchored at the start of the path and does not match a mirror. The
   scheduler must drop all of them by hand. The eight bundled mirrors that ARE genuine writes are
   listed explicitly in the mirror block above; no other mirror path in this document is a write.
4. **`.claude/state/python-batch-budget.default.json` is cited by `[P0-T11]` and is NOT a write.**
   It is the gitignored, untracked, machine-local file named in the pre-existing baseline failure
   `[P0-T11]` records. It is cited so the recorded observation is specific rather than vague. No task
   in this plan creates, edits, moves, or deletes it, and it must not enter the radius. Deleting it
   was considered and rejected: it is a mutation of the developer's environment outside this
   change's scope, and tooling may regenerate it mid-run.

### modules

**Empty.** No write falls inside any of the seven subsystem module globs in
`config/blast-radius.json` (`powershell-dev-tools` = `scripts/dev-tools/**`, `poshqc` =
`scripts/powershell/**`, `benchmarks` = `scripts/benchmarks/**`, `codex-runtime` = `.codex/**`,
`mcp-server` = `packages/mcp-server/**`, `config` = `config/**`, `schemas` = `schemas/**`). This
change writes nothing under any of those roots. `config/orchestration-routing.json` and
`config/blast-radius.json` are read and cited but never written, so the `config` module is not
claimed. An empty `modules` list is valid under parallel-orchestration invariant 9.

### shared_surfaces

**Empty.** None of the ten declared `shared_surfaces` entries and none of the three
`shared_surface_globs` in `config/blast-radius.json` is written by this change:

- `config/orchestration-routing.json` — read only; its `epic` route `required_skills` obligation is
  satisfied at the run level, not by agent preloads, so no edit is required. Explicitly asserted
  unmodified by a task in Phase 6.
- `extensions/drm-copilot/resources/config/orchestration-routing.json` — not written.
- `.claude/settings.json` — not written.
- `poetry.lock`, `package-lock.json`, `extensions/drm-copilot/package-lock.json`,
  `packages/mcp-server/package-lock.json` — no dependency change.
- `quality-tiers.yml` — declared as a shared surface and a mandate-read entry in
  `config/blast-radius.json`, but **no file of that name exists in this repository**; the path is a
  declared surface with no current file behind it. Not written, and not created by this change. No
  tier classification changes.
- `config/blast-radius.json` — read only.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — not written; no PowerShell file is
  added or edited by this change (see Decision 2).
- `scripts/dev_tools/validate_*.py`, `scripts/dev_tools/_orchestrator_state_*.py`,
  `scripts/dev_tools/_epic_orchestrator_state_*.py` — read and cited; none written. No file under
  `scripts/dev_tools/` changes at all.

### contracts

Four cross-surface contracts are altered or re-baselined:

- `epic-mode-child-return-contract` — F6 adds a fourth `Epic mode` effect binding
  `.claude/skills/epic-orchestrate/SKILL.md` (parent) to `.claude/skills/orchestrate/SKILL.md`
  (child). Additive: a child returning more than the bounded shape is not an error; the excess is
  discarded.
- `claude-bundled-payload-byte-identity` — the mirror contract between `.claude/` and
  `extensions/drm-copilot/resources/claude-customizations/.claude/`, re-satisfied for eight files.
- `frozen-epic-surface-digest-pin` — the two pinned SHA-256 constants in
  `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, re-baselined (Decision 1).
- `claude-rules-frontmatter-scoping` — the `paths:` and `description:` frontmatter contract for
  `.claude/rules/*.md` consumed by the Claude Code runtime, extended from fourteen files to all
  nineteen.

### Highest contention points against concurrent items

1. `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` — owned by the
   concurrently-active feature `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/`.
2. `CLAUDE.md` — repository-root standing instructions.
3. `.claude/rules/parallel-orchestration.md` — any item touching the parallel surface or
   blast-radius derivation.
4. `.claude/skills/orchestrate/SKILL.md` — the most widely cited procedure file in the runtime.
5. `extensions/drm-copilot/resources/claude-customizations/.claude/` — any item editing any
   `.claude/` file lands here too, by the byte-identity mirror test.

### Files deliberately NOT written

`AGENTS.md`; `.github/instructions/`; `.agents/`; `.codex/`;
`extensions/drm-copilot/resources/codex-and-agents-customizations/`;
`config/orchestration-routing.json` and its resources mirror; `.claude/rules/csharp.md`;
`.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`;
`.claude/rules/general-code-change.md`; `.claude/skills/feature-review-workflow/SKILL.md`;
`.claude/skills/python-qa-gate/SKILL.md`; `.claude/skills/powershell-qa-gate/SKILL.md`; the
fourteen already-scoped rules files; `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`;
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`;
`docs/engineering/claude-code-architecture.md`; the six other skills carrying the same F1
`## Prerequisites` defect. Each exclusion is asserted by a task in Phase 4 or Phase 6: the
threshold-and-stage-count set by `[P4-T5]`, the remainder by `[P6-T8]` and `[P6-T9]`.

---

## THREE TECHNICAL DECISIONS

### Decision 1 — the digest pin (B1): RE-BASELINE, do not remove

`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins the SHA-256 of both epic
files; `test_frozen_epic_surface_matches_pinned_baseline_digest` consumes them. F1, F2, F4, and F6
each break the pin.

**Chosen: update the two digest constants in place and keep the consuming test.**

Rationale. The consuming test lives in
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, which belongs to feature
441, still in `docs/features/active/`. Removing a control that another in-flight item owns requires
coordinating with that item and adds a second contended file to the radius; re-baselining touches
only the constants file, which is contended either way. Re-baselining also keeps the guard live, so
a later accidental edit to either epic file still fails loudly. The cost is that the pin no longer
anchors the state feature 441 produced; that cost is paid down by rewriting the pin's own comment to
record that issue #559 re-baselined it and why, which leaves feature 441's audit claim readable
rather than silently re-anchored.

Consequence for the radius: `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
is **not** written and does not enter the radius.

### Decision 2 — the regression-test home: pytest under `tests/scripts/dev_tools/`

**Chosen: two new pytest files under `tests/scripts/dev_tools/`. No Pester file is added.**

Rationale. Every existing assertion over `.claude/` content in this repository is pytest:
`test_epic_run_kickoff_discovery_contract.py`, `test_push_down_claude_resource_contracts.py`, and
`test_parallel_orchestrator_surface_contracts.py`. YAML parsing is already available to that suite.
Choosing pytest adds no new toolchain gate; choosing Pester would pull the PoshQC format, analyze,
and test gate into a change that otherwise contains no PowerShell, and would add
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and the `poshqc` module to the
contention surface. The two options are mutually exclusive and Pester is not taken.

Consequence for the radius: `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` is
**not** written, the `poshqc` module is not claimed, and PoshQC is recorded as a not-applicable gate.

### Decision 3 — F6's return shape: the six required fields plus `branch_name` and `worktree_path`

**Chosen: an eight-field fixed shape.** The six the issue requires are `issue_num`,
`feature_folder`, `merge_status`, `pr_number`, `merge_commit_sha`, `blocked_reason`. Two are added:
`branch_name` and `worktree_path`.

Rationale. Both added fields already exist in the epic checkpoint's `features[]` records, so the
child has them at hand and the parent has somewhere to put them. They are the two inputs to
`git worktree remove` in the skill's `## Worktree Cleanup` section, so including them removes a
re-derivation round-trip per child at a marginal cost of two short scalars — which is the correct
trade for a context-reduction feature only because the alternative is re-parsing
`git worktree list --porcelain` output per child. `pr_url` is not added because it is derivable from
`pr_number`; `plan_path` is not added because no parent step after merge consumes it. Adding them
would grow the shape without removing work.

---

## RESERVED HUMAN DECISION — F5's decision half is OUT OF SCOPE

F5 splits into a mechanical half, which this plan delivers, and a decision half, which it does not.

**The decision half is reserved for a human and is not resolved by this plan.** The two open
questions are (a) which coverage floor is authoritative, together with the denominator it attaches
to, and (b) whether the authoritative toolchain loop is the four-step form or the seven-stage form.
This plan does not select a value for either, does not infer one, does not narrow the options, and
does not characterize either option as obvious, likely, preferable, safer, or correct. Both remain
open.

No task in this plan changes a coverage threshold value. No task changes a toolchain stage count. No
task edits `AGENTS.md`, and no task edits any file under `.github/instructions/`. Task `[P4-T5]`
exists specifically to verify that neither class of value was altered.

The heading `### F5 — decision half` in `spec.md` carries **two** acceptance criteria, not one, and
they have different dispositions:

- The first, at `spec.md` line 644, is the BLOCKED coverage-floor and toolchain-stage-count
  selection. It **remains unchecked at delivery.** That is the expected and correct outcome, not a
  delivery failure.
- The second, at `spec.md` line 652, requires the checkpoint to carry a `human_interaction`
  requirement with `response: "halt"`. That criterion **is** delivered, by task `[P4-T7]`.

The decision is therefore recorded as a `human_interaction` requirement with `response: "halt"` in
`artifacts/orchestration/orchestrator-state.json`; per the human-interaction invariants in
`.claude/rules/orchestrator-state.md`, a `halt` requirement needs no `runbook_path`.

---

## Literals this plan instructs the executor to create

Quoted verbatim here, outside any command span, so that an acceptance condition asserting one of
them is exonerated by the plan-quotation rule of `.claude/rules/plan-acceptance-gates.md`:

- `## Bounded Child Return Contract` — the new section heading in
  `.claude/skills/epic-orchestrate/SKILL.md`.
- `## Epic Mode Bounded Return` — the new child-side section heading in
  `.claude/skills/orchestrate/SKILL.md`.
- The eight field names of the fixed return shape: `issue_num`, `feature_folder`, `merge_status`,
  `pr_number`, `merge_commit_sha`, `blocked_reason`, `branch_name`, `worktree_path`.
- `test_claude_rules_frontmatter` and `test_epic_bounded_child_return_contract` — the two new pytest
  module names.

Acceptance conditions in this plan are expressed as named pytest node IDs wherever a test can carry
the assertion, because a node ID is stable under reformatting while a prose phrase is not. No
acceptance condition asserts a token containing `<`, `>`, `${`, `$(`, or `%`. Every coverage
argument uses the importable dotted form with `=`.

---

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, and
      `.claude/rules/general-unit-test.md` in that order, then the Python rules
      `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, and
      `.claude/rules/self-explanatory-code-commenting.md`, then
      `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/orchestrator-state.md`,
      `.claude/rules/parallel-orchestration.md`, and `.claude/rules/quality-tiers.md`. Write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/phase0-instructions-read.2026-08-26T00-00.md`
      containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: the
      artifact exists and lists every file above in the stated order.
- [x] [P0-T2] Record the branch and commit baseline by running `git rev-parse --abbrev-ref HEAD` and
      `git rev-parse HEAD` and `git status --porcelain`, writing
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-git-state.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      records a branch name, a full commit SHA, and the working-tree status.
- [x] [P0-T3] Run `poetry run black --check .` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-black.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      exists and its `EXIT_CODE:` is the observed baseline exit code.
- [x] [P0-T4] Run `poetry run ruff check` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-ruff.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      exists and records the baseline diagnostic count.
- [x] [P0-T5] Run `poetry run pyright` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pyright.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      exists and records the baseline error and warning counts.
- [x] [P0-T6] Run `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the numeric
      passed and failed counts and the numeric total line-coverage percentage for
      `scripts.dev_tools`. Acceptance: the artifact records a numeric coverage headline, not a
      placeholder.
- [x] [P0-T7] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest`
      and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-digest-pin.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      records `EXIT_CODE: 0`, proving the pin is live before Phase 3 breaks it.
- [x] [P0-T8] Record the current frontmatter inventory of all nineteen files matching
      `.claude/rules/*.md` — for each file, whether a YAML frontmatter block is present and, when
      present, its `paths:` entries — into
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-rules-frontmatter-inventory.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      lists nineteen files, identifies exactly five as carrying no frontmatter block, and identifies
      exactly four as carrying an unconditional entry.
- [x] [P0-T9] Capture the before-half of the always-on line-count measurement by running
      `poetry run python -c "import sys,pathlib;c=[(p,len(pathlib.Path(p).read_bytes().splitlines())) for p in sys.argv[1:]];[print(n,p) for p,n in c];print('TOTAL',sum(n for _,n in c))" CLAUDE.md .claude/agents/epic-orchestrator.md .claude/skills/policy-compliance-order/SKILL.md .claude/skills/epic-orchestrate/SKILL.md .claude/skills/feature-promotion-lifecycle/SKILL.md .claude/skills/atomic-plan-contract/SKILL.md .claude/skills/acceptance-criteria-tracking/SKILL.md .claude/skills/evidence-and-timestamp-conventions/SKILL.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/tonality.md .claude/rules/parallel-orchestration.md .claude/rules/plan-acceptance-gates.md .claude/rules/orchestrator-state.md .claude/rules/ci-workflows.md .claude/rules/benchmark-baselines.md`
      and writing
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/always-on-line-count-before.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the per-file
      counts and the four component subtotals. The command payload is a **single line**: a
      multi-line `python -c` payload is a known silent no-op in this environment that exits 0 without
      executing, which would fabricate the measurement rather than take it. Do not reformat the
      payload across lines. `bytes.splitlines()` is used rather than `str.splitlines()` so the line
      boundaries are the three ASCII forms — line feed, carriage return, and the pair — and not the
      wider Unicode set that the text method would also split on. Acceptance: the artifact records a
      before total of
      2158 lines with subtotals 221, 936, 316, and 685; if the observed total differs, the artifact
      records the observed value and names each file whose count differs from research §1.
- [x] [P0-T10] Confirm the feature-document preconditions: `spec.md` exists in the feature folder and
      carries an `## Acceptance Criteria` section; `user-story.md` exists and carries no acceptance
      criteria; `issue.md` records `- Work Mode: full-bug`. Record the confirmation in
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/phase0-instructions-read.2026-08-26T00-00.md`
      as an appended `Preconditions:` block. Acceptance: all three statements are confirmed true, and
      the count of checkboxes under `## Acceptance Criteria` in `spec.md` is recorded.
- [x] [P0-T11] Establish whether the known unrelated bundled-payload failure is present at baseline
      on this worktree. Run `poetry run pytest` and append to the existing artifact
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`
      a block headed `Known Baseline Failure:` recording, in this order: (a) whether the test
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, in
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, failed at baseline —
      recorded as exactly `PRESENT` or exactly `ABSENT`; (b) if `PRESENT`, the exact untracked
      repository path the failure names, expected to be
      `.claude/state/python-batch-budget.default.json`; and (c) the full baseline pass, fail, and
      skip counts. The known cause is that `list_scoped_files` enumerates the filesystem rather than
      consulting git, so a gitignored, untracked, machine-local state file enters the repo-side set
      and has no bundled counterpart. That defect is **out of scope**: no task in this plan fixes it,
      and no task deletes, moves, or otherwise mutates that file or any other gitignored file. This
      task only records the observed baseline. Acceptance: the artifact carries a
      `Known Baseline Failure:` block whose first field is exactly `PRESENT` or exactly `ABSENT`, and
      the baseline pass, fail, and skip counts are numeric.

### Phase 1 — Regression Tests Authored and Failing

- [ ] [P1-T1] Create `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` containing exactly
      these test functions and no others: `test_every_claude_rule_carries_parseable_paths_and_description`,
      `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`,
      `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer`,
      `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers`,
      `test_parallel_orchestration_rule_paths_cover_blast_radius_config`,
      `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`,
      `test_epic_orchestrator_preloads_exactly_three_skills`, and
      `test_no_unqualified_spec_section_citation_under_claude`. **A rules file that carries no YAML
      frontmatter block at all counts as unconditional** for the purposes of
      `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`: a file with no `paths:`
      scoping loads on every turn, so it is unconditional in effect, and the test must classify it
      that way. Without this definition the pre-change repository — where five files carry no
      frontmatter and four carry an unconditional entry — would satisfy a four-file expectation that
      counted only explicit unconditional entries, the test would pass before the fix, and the
      `[expect-fail]` acceptance of `[P1-T3]` would be wrong. Under this definition the pre-change
      unconditional set has nine members, the test fails before `[P2-T1]` through `[P2-T5]`, and it
      passes after. The file must be under 500 lines and must not create temporary files. Acceptance:
      the file exists and
      `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py --collect-only`
      collects exactly eight test items.
- [ ] [P1-T2] Create `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` containing
      exactly these test functions and no others:
      `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions`,
      `test_epic_orchestrate_skill_has_no_prerequisites_heading`,
      `test_epic_skill_documents_bounded_child_return_contract_section`,
      `test_bounded_return_shape_names_every_required_field`,
      `test_bounded_return_section_states_discard_and_rederivation`,
      `test_epic_mode_kickoff_line_carries_child_facing_constraint`, and
      `test_orchestrate_skill_carries_matching_child_side_statement`. Each prose assertion must
      normalize whitespace across adjacent lines before searching, so that a reflow of the target
      file cannot silently turn the assertion into a zero-match no-op. The file must be under 500
      lines and must not create temporary files. Acceptance: the file exists and
      `poetry run pytest tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py --collect-only`
      collects exactly seven test items.
- [ ] [P1-T3] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
      and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/fail-before-rules-frontmatter.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:`
      naming each failing test. Acceptance: at least
      `test_every_claude_rule_carries_parseable_paths_and_description`,
      `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`,
      `test_epic_orchestrator_preloads_exactly_three_skills`, and
      `test_no_unqualified_spec_section_citation_under_claude` fail.
- [ ] [P1-T4] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`
      and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/fail-before-epic-contract.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:`
      naming each failing test. Acceptance: all seven tests fail, because none of the F1 or F6 edits
      has been applied yet.
- [ ] [P1-T5] Run `poetry run black --check tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`
      and `poetry run ruff check tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`;
      apply any formatting change the first command reports and re-run both. Acceptance: both
      commands exit 0 on the same pass over both new files.

### Phase 2 — F3: Scope the Five Unscoped Rules Files and Mirror Them

- [ ] [P2-T1] Insert a YAML frontmatter block at the top of `.claude/rules/ci-workflows.md` whose
      `paths:` list is the single double-quoted entry `.github/workflows/**` and whose
      `description:` is a non-empty single-line scalar containing no colon, followed by a closing
      `---`, one blank line, then the existing `# CI Workflow Authoring` heading. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_every_claude_rule_carries_parseable_paths_and_description"`
      no longer reports this file, and the file's body below the block is byte-unchanged.
- [ ] [P2-T2] Insert a frontmatter block at the top of `.claude/rules/benchmark-baselines.md` whose
      `paths:` list is `scripts/benchmarks/**` and `**/baseline*.json`, in the same shape as P2-T1.
      Acceptance: the block parses as YAML, `paths:` holds two non-empty strings, and the file's body
      below the block is byte-unchanged. No task asserts that this glob set matches any file.
- [ ] [P2-T3] Insert a frontmatter block at the top of `.claude/rules/plan-acceptance-gates.md` whose
      `paths:` list is `scripts/dev_tools/plan_gate_*`,
      `scripts/dev_tools/validate_orchestration_artifacts.py`,
      `extensions/drm-copilot/src/lib/validate/plan-gate-*`,
      `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`,
      `docs/features/**/plan.*.md`, `docs/features/**/remediation-plan.*.md`, and
      `.claude/skills/atomic-plan-contract/SKILL.md`, in the same shape as P2-T1. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_plan_acceptance_gates_rule_paths_cover_both_dispatchers"`
      passes.
- [ ] [P2-T4] Insert a frontmatter block at the top of `.claude/rules/orchestrator-state.md` whose
      `paths:` list names the checkpoint artifacts `artifacts/orchestration/*orchestrator-state.json`
      and `artifacts/orchestration/*planner-state.json`; the validators
      `scripts/dev_tools/*orchestrator_state*`,
      `extensions/drm-copilot/src/lib/validate/orchestrator-state-*`; the two reference
      implementations `scripts/dev_tools/compute_complexity_floor.py` and
      `scripts/dev_tools/resolve_delegation_model.py`; the two hooks
      `.claude/hooks/validate-orchestrator-output.ps1` and
      `.claude/hooks/enforce-model-routing-receipt.ps1`; `config/orchestration-routing.json`; and all
      ten checkpoint-writer surfaces explicitly — `.claude/agents/orchestrator.md`,
      `.claude/agents/epic-orchestrator.md`, `.claude/agents/parallel-orchestrator.md`,
      `.claude/agents/epic-planner.md`, `.claude/agents/parallel-planner.md`,
      `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`,
      `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, and
      `.claude/skills/parallel-plan/SKILL.md`. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_orchestrator_state_rule_paths_reach_every_checkpoint_writer"`
      passes.
- [ ] [P2-T5] Insert a frontmatter block at the top of `.claude/rules/parallel-orchestration.md` whose
      `paths:` list is the four parallel-artifact globs `artifacts/orchestration/parallel-*`,
      `docs/features/parallel/**`, `scripts/dev_tools/*parallel*`,
      `extensions/drm-copilot/src/lib/validate/parallel-*`, plus the blast-radius doctrine surface
      `scripts/dev_tools/*blast_radius*`, `config/blast-radius.json`, `**/config/blast-radius.json`,
      `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`,
      `.claude/lib/blast-radius/**`, `.claude/lib/bash/parallel-yaml-scan.sh`, plus
      `scripts/dev_tools/validate_orchestration_artifacts.py`,
      `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`,
      `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/agents/parallel-orchestrator.md`,
      `.claude/agents/parallel-planner.md`, and `.claude/skills/parallel-*/SKILL.md`. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_parallel_orchestration_rule_paths_cover_blast_radius_config"`
      passes.
- [ ] [P2-T6] Verify that each of the five edited rules files has exactly one diff hunk and that the
      hunk is the insertion at the top of the file, by inspecting
      `git diff HEAD --unified=0 -- .claude/rules/ci-workflows.md .claude/rules/benchmark-baselines.md .claude/rules/plan-acceptance-gates.md .claude/rules/orchestrator-state.md .claude/rules/parallel-orchestration.md`.
      The `HEAD` operand is required: a bare `git diff` compares the worktree against the index and
      reports nothing once a change is staged, so it would read as clean whether or not the edits
      were correct. Acceptance: every hunk header in that diff begins at line 0 of the original file
      and no hunk removes an original line.
- [ ] [P2-T7] Write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/f3-glob-justification.2026-08-26T00-00.md`
      recording, per rules file, the quotation from that file's own scope or enforcement section that
      justifies each glob; recording explicitly that the glob set for
      `.claude/rules/benchmark-baselines.md` matches zero current files because `scripts/benchmarks/`
      does not exist in this repository and that this is the correct outcome under that rule's own
      scope statement; and recording that no repository code reads `paths:` frontmatter from
      `.claude/rules/`, so glob correctness is unverifiable in-repository and only structural
      assertions are made. Acceptance: the artifact covers all five files and both recorded
      limitations.
- [ ] [P2-T8] Copy `.claude/rules/ci-workflows.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/ci-workflows.md` so the
      two files are byte-identical. Acceptance: a byte comparison of the two files reports no
      difference.
- [ ] [P2-T9] Copy `.claude/rules/benchmark-baselines.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/benchmark-baselines.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P2-T10] Copy `.claude/rules/plan-acceptance-gates.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P2-T11] Copy `.claude/rules/orchestrator-state.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P2-T12] Copy `.claude/rules/parallel-orchestration.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P2-T13] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
      Acceptance: exit code 0, confirming the five mirrors satisfy the byte-identity contract; **or**,
      only if the `[P0-T11]` artifact recorded `PRESENT`, exactly one failure, that failure being
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, and no other. If `[P0-T11]`
      recorded `ABSENT`, strict exit code 0 applies with no exception. Any second failure fails this
      task under either branch.

### Phase 3 — F1, F2, F4, F6: Epic Surface Edits, Digest Re-baseline, and Mirrors

Edits within a shared file are applied bottom-up so that each edit's line numbers are unaffected by
the preceding edits.

- [ ] [P3-T1] In `.claude/agents/epic-orchestrator.md`, replace the F4 citation at line 136 so the
      checkpoint schema authority is `validate_epic_orchestrator_state_text`, implemented in
      `scripts/dev_tools/validate_epic_orchestrator_state.py`, and the unqualified section citation
      is removed. Acceptance: the sentence names `validate_epic_orchestrator_state_text` and no
      longer carries an unqualified section reference.
- [ ] [P3-T2] In `.claude/agents/epic-orchestrator.md`, replace the F4 citation at line 107 so the
      authority is `.claude/skills/epic-orchestrate/SKILL.md`, naming the two headings
      `## Merge-on-Green Kickoff Parameter` and `## Context Handoff to Dependent Features`, and the
      unqualified section citation is removed. Acceptance: both heading literals appear in the
      replaced sentence and both exist in `.claude/skills/epic-orchestrate/SKILL.md`.
- [ ] [P3-T3] In `.claude/agents/epic-orchestrator.md`, delete the two `## Startup Protocol` steps at
      lines 57 and 58 that instruct reading `CLAUDE.md` and reading `.claude/rules/` files, then
      renumber the remaining three steps contiguously to `1.`, `2.`, `3.`, changing only the leading
      ordinals and leaving every continuation line unchanged. Add no replacement text. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions"`
      passes.
- [ ] [P3-T4] In the `.claude/agents/epic-orchestrator.md` frontmatter, delete the three `skills:`
      entries `feature-promotion-lifecycle`, `atomic-plan-contract`, and
      `evidence-and-timestamp-conventions`, leaving exactly `policy-compliance-order`,
      `epic-orchestrate`, and `acceptance-criteria-tracking`. Make no other edit; no prose in either
      epic file references a removed skill, so no `Skill` invocation is inserted. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_epic_orchestrator_preloads_exactly_three_skills"`
      passes.
- [ ] [P3-T5] Confirm that the `## Prepared-Epic Execution (epic-planner Handoff)` section of
      `.claude/agents/epic-orchestrator.md` is unchanged and unreflowed. That section spans lines 78
      through 99 before this phase's edits, and shifts to lines 76 through 97 once `[P3-T3]` has
      removed the two `## Startup Protocol` steps above it. Run the single node ID
      `poetry run pytest "tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py::test_epic_orchestrator_precondition_establishes_kickoff_presence"`.
      Only that one node is run here: the same module also contains
      `test_discovery_fix_is_mirrored_into_bundled_payload`, which asserts the agent file is
      byte-identical to its bundled copy and therefore cannot pass at this point, because the mirror
      is not written until `[P3-T15]`. The full module is run at `[P3-T18]`, after every mirror.
      Acceptance: one passed.
- [ ] [P3-T6] In `.claude/skills/epic-orchestrate/SKILL.md`, delete the F4 clause at line 268 that
      cites an unqualified section for the checkpoint schema. The surrounding
      `## Epic-Level Checkpoint` section is itself the schema statement and already names the
      validator and its module path, so no replacement text is added. Acceptance: the sentence reads
      correctly without the clause and carries no unqualified section reference.
- [ ] [P3-T7] In `.claude/skills/epic-orchestrate/SKILL.md`, insert a new section headed
      `## Bounded Child Return Contract` immediately after the `## Merge-on-Green Kickoff Parameter`
      section and immediately before `## Model Selection`. The section must name the eight fields of
      the fixed return shape — `issue_num`, `feature_folder`, `merge_status`, `pr_number`,
      `merge_commit_sha`, `blocked_reason`, `branch_name`, `worktree_path` — must state that content
      beyond the fixed shape is discarded, and must state that authoritative state is re-derived
      regardless from `git worktree list --porcelain`, `git branch`, and
      `gh pr view --json state,mergedAt,headRefOid`, citing the cache doctrine already recorded in
      `.claude/rules/parallel-orchestration.md` rather than restating it. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_skill_documents_bounded_child_return_contract_section" "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_bounded_return_shape_names_every_required_field" "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_bounded_return_section_states_discard_and_rederivation"`
      reports three passed.
- [ ] [P3-T8] In `.claude/skills/epic-orchestrate/SKILL.md`, append the child-facing half of the
      constraint to the epic-mode kickoff line at line 126, in the same imperative form as the
      existing trailing directive, requiring the child's final report to be exactly the bounded
      return shape and nothing else and stating that additional narrative is discarded because the
      parent re-derives authoritative state regardless. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_mode_kickoff_line_carries_child_facing_constraint"`
      passes.
- [ ] [P3-T9] In `.claude/skills/epic-orchestrate/SKILL.md`, delete the `## Prerequisites` block. The
      block occupies lines 22 through 28; delete lines 22 through 29 so that exactly one blank line
      separates the paragraph ending at line 20 from the `## Epic Dependency Manifest` heading. Line
      21 is already that blank line and is retained; line 29 is the blank line below the block and is
      what the deletion removes, which is why the range ends at 29 rather than 28. Add
      no replacement text. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_orchestrate_skill_has_no_prerequisites_heading"`
      passes and no two consecutive blank lines precede that heading.
- [ ] [P3-T10] In `.claude/skills/orchestrate/SKILL.md`, add a new section headed
      `## Epic Mode Bounded Return`, placed adjacent to the existing `## Preparation Mode` section,
      stating the same eight-field bounded return shape and that content beyond it is discarded. The
      section must be ten lines or fewer, because this is a context-reduction change. Acceptance:
      `poetry run pytest "tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_orchestrate_skill_carries_matching_child_side_statement"`
      passes and the section body is ten lines or fewer.
- [ ] [P3-T11] Recompute the SHA-256 digest of `.claude/agents/epic-orchestrator.md` from the exact
      working-tree bytes that will be committed, using
      `poetry run python -c "import hashlib,pathlib;print(hashlib.sha256(pathlib.Path('.claude/agents/epic-orchestrator.md').read_bytes()).hexdigest())"`,
      and record the value in
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/frozen-epic-digest-repin.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact
      records a 64-character hexadecimal digest.
- [ ] [P3-T12] Recompute the SHA-256 digest of `.claude/skills/epic-orchestrate/SKILL.md` using
      `poetry run python -c "import hashlib,pathlib;print(hashlib.sha256(pathlib.Path('.claude/skills/epic-orchestrate/SKILL.md').read_bytes()).hexdigest())"`
      and append the value to the same artifact
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/frozen-epic-digest-repin.2026-08-26T00-00.md`.
      Acceptance: the artifact records both digests, each 64 hexadecimal characters.
- [ ] [P3-T13] Update the two pinned digest constants in
      `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` to the two values
      recorded in P3-T11 and P3-T12, and rewrite the block comment above them so it records that
      issue #559 re-baselined the pin, why the epic surface legitimately changed, and that the pin
      remains live as a guard against an unintended future edit. Do not remove the constants and do
      not remove the consuming test. Acceptance: the file contains both new digests and the rewritten
      comment names issue #559.
- [ ] [P3-T14] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
      Acceptance: exit code 0, confirming the re-baselined pin matches the edited epic files and that
      no other assertion in that module regressed.
- [ ] [P3-T15] Copy `.claude/agents/epic-orchestrator.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P3-T16] Copy `.claude/skills/epic-orchestrate/SKILL.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P3-T17] Copy `.claude/skills/orchestrate/SKILL.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
      so the two files are byte-identical. Acceptance: a byte comparison reports no difference.
- [ ] [P3-T18] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`
      and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/push-down-mirror-parity.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: exit code 0,
      confirming all eight mirrors are byte-identical to their originals; **or**, only if the
      `[P0-T11]` artifact recorded `PRESENT`, exactly one failure, that failure being
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, and no other. If `[P0-T11]`
      recorded `ABSENT`, strict exit code 0 applies with no exception. Under the exception branch
      every test in `test_epic_run_kickoff_discovery_contract.py` must still pass, including
      `test_discovery_fix_is_mirrored_into_bundled_payload`.
- [ ] [P3-T19] Run `poetry run pytest "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_no_unqualified_spec_section_citation_under_claude" "tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file"`.
      Acceptance: two passed, confirming F4's criterion holds across `.claude/` and that every
      `skills:` entry of every agent file resolves.

### Phase 4 — F5 Mechanical Half and Reserved-Decision Guard

- [ ] [P4-T1] In `CLAUDE.md`, replace the four duplicated tone-policy bullets at lines 11 through 14
      with a single-line pointer naming `.claude/rules/tonality.md` as the runtime-loaded
      authoritative source. Retain the lead-in sentence at line 9 and the existing authority sentence
      at line 16. Change nothing else in the file. Acceptance: the `## Tone Policy` section no longer
      restates the bullet list and names `.claude/rules/tonality.md`.
- [ ] [P4-T2] Verify that the `## Policy Compliance Reading Order` section of `CLAUDE.md` is
      byte-unchanged, by inspecting `git diff HEAD --unified=0 -- CLAUDE.md` and confirming no hunk
      overlaps lines 18 through 32 of the original file. The `HEAD` operand is required: a bare
      `git diff` compares the worktree against the index and is falsely clean once a change is
      staged. Acceptance: no diff hunk touches that section, so the compliance order is preserved
      verbatim.
- [ ] [P4-T3] Verify that the C#-specific toolchain command list is preserved by running
      `git diff HEAD --exit-code -- .claude/rules/csharp.md`. That list lives in
      `.claude/rules/csharp.md`, not in `CLAUDE.md`; leaving the file untouched satisfies the
      preservation requirement. Acceptance: exit code 0.
- [ ] [P4-T4] Verify that `## Language-Specific Rules` and `## Architecture` in `CLAUDE.md` are
      unchanged, by confirming that `git diff HEAD --unified=0 -- CLAUDE.md` contains no hunk
      overlapping lines 34 through 59 of the original file. The `HEAD` operand is required for the
      reason given in `[P4-T2]`. Acceptance: the only hunk in the `CLAUDE.md` diff is the tone-policy
      replacement from P4-T1.
- [ ] [P4-T5] Verify that no coverage threshold value and no toolchain stage count was altered
      anywhere by this change, by running
      `git diff HEAD --exit-code -- .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/general-code-change.md .claude/rules/python.md .claude/rules/typescript.md .claude/rules/powershell.md .claude/rules/shell.md .claude/skills/feature-review-workflow/SKILL.md .claude/skills/python-qa-gate/SKILL.md .claude/skills/powershell-qa-gate/SKILL.md AGENTS.md .github/instructions/ extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`
      and writing
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The `HEAD` operand is
      required: a bare `git diff` compares the worktree against the index and is falsely clean once a
      change is staged, which on this task in particular would report the F5 reservation intact when
      it had been violated. Those paths are the files known to state a coverage threshold or a
      toolchain stage count that this change does not write. This is an enumeration, **not** a
      completeness assertion: no claim is made that the repository contains no other such file. The
      six additions beyond the original nine, and their bundled mirrors, are
      `.claude/rules/python.md` (lines 16, 88, 89), `.claude/rules/typescript.md` (line 50),
      `.claude/rules/powershell.md` (lines 63, 64), `.claude/rules/shell.md` (lines 28, 68),
      `.claude/skills/python-qa-gate/SKILL.md` (line 46), and
      `.claude/skills/powershell-qa-gate/SKILL.md` (line 45). Acceptance: exit code 0 over every path
      above, proving no threshold and no stage count in the enumerated set changed.
- [ ] [P4-T6] Write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/f5-reserved-human-decision.2026-08-26T00-00.md`
      recording the two open questions with their file-and-line evidence and no recommendation, and
      stating that this change selected neither value, that `AGENTS.md` and `.github/instructions/`
      were not written, and that the first `spec.md` acceptance criterion under
      `### F5 — decision half`, at spec line 644, remains unchecked. Acceptance: the artifact states
      both questions,
      cites their locations, and contains no recommendation, preference, or characterization of
      either option as obvious, likely, or correct.
- [ ] [P4-T7] Record a `human_interaction.requirements[]` entry with `response: "halt"` in
      `artifacts/orchestration/orchestrator-state.json`, whose text is the requirement text from
      P4-T6. Per the human-interaction invariants in `.claude/rules/orchestrator-state.md`, a `halt`
      requirement carries no `runbook_path`. Validate with the subcommand form
      `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json`,
      not the module-direct form, which exits 0 without validating and would gate nothing.
      Acceptance: that command exits 0, reports no `human_interaction` error, and the entry's
      `response` value is `halt`.
- [ ] [P4-T8] Leave the **first** `spec.md` acceptance criterion under `### F5 — decision half`, at
      spec line 644 (the BLOCKED coverage-floor and stage-count selection), unchecked, and annotate
      the `spec.md` `## Acceptance Criteria` section, if annotation is needed, to record that the
      criterion is blocked on the reserved human decision. The second criterion under that heading,
      at spec line 652, is the `human_interaction` halt entry and is delivered by `[P4-T7]`; this
      task does not leave it unchecked. Acceptance: the line-644 checkbox is unchecked at delivery
      and no task in this plan has selected a coverage floor or a stage count.

### Phase 5 — Post-Change Measurement

- [ ] [P5-T1] Capture the after-half of the always-on line-count measurement by running
      `poetry run python -c "import sys,pathlib;c=[(p,len(pathlib.Path(p).read_bytes().splitlines())) for p in sys.argv[1:]];[print(n,p) for p,n in c];print('TOTAL',sum(n for _,n in c))" CLAUDE.md .claude/agents/epic-orchestrator.md .claude/skills/policy-compliance-order/SKILL.md .claude/skills/epic-orchestrate/SKILL.md .claude/skills/acceptance-criteria-tracking/SKILL.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/tonality.md`
      — the `-c` payload is byte-identical to the one in `[P0-T9]` and only the file operands differ,
      and it is likewise a **single line**, so the before and after halves are measured by the same
      counting rule — and writing
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/always-on-line-count-after.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the per-file
      counts and the component subtotals. The five now-scoped rules files are excluded from the
      after-state list because they no longer load unconditionally, and the three de-preloaded skills
      are excluded because they are no longer preloaded. Acceptance: the artifact records an after
      total and a three-component breakdown covering standing instructions plus agent file, three
      preloaded skills, and the four deliberate unconditional rules.
- [ ] [P5-T2] Write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/always-on-line-count-comparison.2026-08-26T00-00.md`
      comparing the before total from P0-T9 against the after total from P5-T1, stating the absolute
      line reduction and the percentage reduction, attributing the reduction to F1, F2, F3, and F5
      individually, and stating explicitly which components are excluded from the after-state list
      and why. Acceptance: the artifact states a before total, an after total, and a signed
      difference; the after total is strictly less than the before total.
- [ ] [P5-T3] Record in the same comparison artifact the one un-measured component: the
      `memory: project` declaration on `.claude/agents/epic-orchestrator.md` loads
      `.claude/agent-memory/epic-orchestrator/`, which is gitignored and therefore machine-local and
      not measurable from committed files. Acceptance: the artifact states that the measured totals
      exclude agent memory and are therefore a lower bound on injected context.

### Phase 6 — Final QA Loop, Scope Containment, and Reconciliation

The loop below runs formatting, then linting, then type checking, then testing. **If any stage fails
or changes a file, restart the loop from `[P6-T1]`.** Do not proceed past `[P6-T5]` until all four
stages complete without error in a single uninterrupted pass.

- [ ] [P6-T1] Run `poetry run black --check .` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-black.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If the check reports a file
      needing reformatting, run `poetry run black .`, then restart the loop from this task.
      Acceptance: `EXIT_CODE: 0`.
- [ ] [P6-T2] Run `poetry run ruff check` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-ruff.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If any fix changes a file,
      restart the loop from `[P6-T1]`. Acceptance: `EXIT_CODE: 0` with zero diagnostics.
- [ ] [P6-T3] Run `poetry run pyright` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-pyright.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If any change is made to
      satisfy the type checker, restart the loop from `[P6-T1]`. Acceptance: `EXIT_CODE: 0` with zero
      errors, and the error count is not greater than the baseline recorded in P0-T5.
- [ ] [P6-T4] Run `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing` and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the numeric
      passed and failed counts and the numeric total line-coverage percentage for
      `scripts.dev_tools`. If any change is made in response, restart the loop from `[P6-T1]`.
      Acceptance: `EXIT_CODE: 0`, zero failures, and a numeric coverage headline recorded; **or**,
      only if the `[P0-T11]` artifact recorded `PRESENT`, exactly one failure, that failure being
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, no other failure, and a
      numeric coverage headline recorded. If `[P0-T11]` recorded `ABSENT`, strict `EXIT_CODE: 0` with
      zero failures applies with no exception. Under the exception branch the artifact must name the
      single tolerated failure explicitly and cite the `[P0-T11]` baseline record; a summary that
      reports a non-zero failure count without naming the failing test does not satisfy this task.
- [ ] [P6-T5] Run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` and
      write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/final-codex-agent-variants.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. This stage is run because
      it is part of the repository quality-checks workflow and must be green for the branch, **not**
      because it verifies anything about the epic edits: `generate_codex_agent_variants.py` reads
      only `.codex/agents/*.toml` and never reads any path under `.claude/`, so it cannot observe the
      `.claude/agents/epic-orchestrator.md` or `.claude/skills/` changes this plan makes. The
      assertion that `.codex/` is untouched is carried by `[P6-T8]`, not by this task. Acceptance:
      `EXIT_CODE: 0`.
- [ ] [P6-T6] Write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`
      recording the baseline coverage percentage from P0-T6, the post-change coverage percentage from
      P6-T4, the signed delta, and the changed-code coverage statement: no file under `src` or
      `scripts/dev_tools` is written by this change, and `pyproject.toml` sets the coverage source to
      exactly those two roots, so the coverage denominator is unchanged and the metric cannot
      regress. Acceptance: the artifact records two numeric percentages and a delta of zero, or names
      each file responsible if the delta is non-zero.
- [ ] [P6-T7] Write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md`
      recording, with a reason for each, the gates that do not apply: PoshQC, because Decision 2
      chose pytest and no PowerShell file is added or edited; the extension TypeScript test workflow,
      because no file under `extensions/drm-copilot/src/` changes; the shell coverage workflow,
      because no shell or bats file changes; architecture-boundary checks, because they are scoped to
      TypeScript and C# and neither changes; contract and schema compatibility checks, because no
      contract schema file changes; integration tests, because no adapter to an external system
      changes. Record also that **no Markdown lint or format gate exists in this repository** —
      `.github/workflows/_docs-validation.yml` checks only that `README.md` is non-empty and
      `LICENSE` exists, the `dev.format-markdown` entry point is a chat-transcript formatter rather
      than a policy-file gate, and the prettier globs in `package.json` cover no Markdown file — so
      no Markdown gate is claimed, invented, or run. Acceptance: the artifact names every gate above
      with its reason and states the Markdown finding explicitly.
- [ ] [P6-T8] Verify scope containment by running
      `git diff HEAD --exit-code -- .agents/ .codex/ extensions/drm-copilot/resources/codex-and-agents-customizations/ AGENTS.md .github/instructions/ config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json config/blast-radius.json .claude/settings.json docs/engineering/claude-code-architecture.md`
      and writing
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/scope-containment.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The `HEAD` operand is
      required: a bare `git diff` compares the worktree against the index and is falsely clean once a
      change is staged. `quality-tiers.yml` is deliberately **removed** from this pathspec: no file
      of that name exists in the repository, so that operand could never contribute a difference and
      the assertion over it could not fail. The guarantee that this change creates no such file is
      carried by `[P6-T9]`, which reconciles `git status --porcelain` — untracked entries included —
      against the declared radius. Acceptance: exit code 0, confirming every declared non-write
      stayed a non-write and that no declared shared surface with a file behind it was touched.
- [ ] [P6-T9] Verify that the set of files changed by this branch equals the declared blast radius,
      by running `git status --porcelain` and comparing the result against the path list in the
      `## DECLARED BLAST RADIUS` section of this plan. Acceptance: every changed path appears in the
      declared list and every declared runtime, mirror, and test path that was expected to change has
      changed; any difference is reconciled by amending this plan's radius section before the change
      is reported complete.
- [ ] [P6-T10] Run `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py` and
      write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/pass-after-rules-frontmatter.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE: 0`
      with eight passed, pairing with the fail-before artifact from P1-T3.
- [ ] [P6-T11] Run `poetry run pytest tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`
      and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/pass-after-epic-contract.2026-08-26T00-00.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE: 0`
      with seven passed, pairing with the fail-before artifact from P1-T4.
- [ ] [P6-T12] Reconcile every checkbox under `## Acceptance Criteria` in
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`
      against the evidence artifacts produced by this plan, and write
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md`
      mapping each criterion to its evidence artifact path or to its blocking reason. `spec.md`
      carries 42 checkboxes in total, which partition as follows and must be reconciled on that
      basis. Acceptance: the artifact covers all 38 acceptance criteria (spec lines 559-706); the
      four severity markers at spec lines 56-59 are excluded as inherited template markers and are
      not acceptance criteria, with spec line 57 already carrying a checked `High` marker and the
      other three at lines 56, 58, and 59 unchecked; the heading
      `### F5 — decision half` carries **two** criteria, not one, and they are recorded separately —
      the first, the BLOCKED coverage-floor and stage-count selection at spec line 644, is recorded
      as unchecked and blocked on the reserved human decision, and the second, the
      `human_interaction` halt entry at spec line 652, is recorded as delivered by `[P4-T7]` with its
      evidence artifact path; and exactly one criterion of the 38 is recorded as unchecked and
      blocked.
- [ ] [P6-T13] Update
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/issue.md`
      to check the delivered items under `## Proposed Fix / Validation Ideas` and `## Next Step`,
      leaving unchecked anything not delivered. Acceptance: no checkbox is checked without a
      corresponding evidence artifact path recorded in the AC reconciliation artifact.
- [ ] [P6-T14] Record the required follow-ups without acting on them: regenerating the `.agents/`
      converted copies of the changed `.claude/` originals and mirroring the result into
      `extensions/drm-copilot/resources/codex-and-agents-customizations/`; adding a converter-parity
      test so `.claude/` to `.agents/` staleness fails loudly; reconciling the stale embedded rule
      copies in `AGENTS.md`, which is blocked on the same reserved human decision as F5; scoping the
      six other skills that carry the same `## Prerequisites` re-read defect; the possible split
      of `.claude/rules/parallel-orchestration.md` into a schema rule and a blast-radius rule; and
      the bundled-payload parity defect observed at baseline by `[P0-T11]` —
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails because
      `list_scoped_files` enumerates the filesystem rather than consulting git, so a gitignored,
      untracked, machine-local file such as `.claude/state/python-batch-budget.default.json` enters
      the repo-side set and is reported as missing from the bundle. Record that last item as an
      observation for a future issue, stating that the correct fix is for the scan to consult git
      rather than for a developer to delete a machine-local file, and stating explicitly that this
      change does **not** widen its scope to fix it and deletes no gitignored file. Record all of
      them in
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md`
      under a `Follow-ups:` heading. Acceptance: all six follow-ups are recorded and none is acted
      on by this change.
