# `2026-08-29-remove-remaining-python-invocations` — User Story

- Issue: #599
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-29T17-40
- Epic: `docs/features/epics/claude-runtime-portability/epic.md` (Feature D, wave 2, complexity C3)

All file:line citations use the corrected spans in the `## Citation Corrections` table of
`docs/features/active/2026-08-29-remove-remaining-python-invocations-599/research/2026-08-29T17-10-remove-remaining-python-invocations-research.md`.

## Story Statement

- As a **parallel planner agent running in a consumer repository that received a push-down**, I want the
  lane-assertion diagnostic to be executable with the tools the destination actually guarantees, so
  that the mandatory seeding step and its required completion-report line item produce a real result
  rather than silently doing nothing.
- As an **epic or parallel orchestrator running in that same destination**, I want the checkpoint
  validation step to be stated only in the form I can actually run there, so that a procedure step does
  not read as available when it is not.
- As a **maintainer of the `.claude/**` payload**, I want the ported diagnostic to keep its
  advisory-only behavior byte-for-byte, so that adding a destination-runtime implementation does not
  change any scheduling decision the orchestration surface makes.

## Problem / Why

The `.claude/**` payload is published into consumer repositories by the push-down mechanism. Those
destinations guarantee no Python interpreter, no Poetry, and no `scripts/dev_tools` tree. Issue #475
already removed the Python dependency from the two discovery-gate hooks on the same reasoning. An
executable Python invocation that remains in the published payload makes the procedure step that
depends on it silently unavailable at its destination.

**The justification is not a rule contradiction.** `.claude/rules/parallel-orchestration.md` (invariant
M8) and `.claude/skills/parallel-plan/SKILL.md:322-329` agree that the diagnostic's FINDINGS are
advisory-only and never block. Nothing in the payload disagrees with anything else on that point.

The genuine defect concerns the diagnostic's INVOCATION, not its findings:

- The invocation is a **mandatory procedure step**: `.claude/skills/parallel-plan/SKILL.md:313-315`
  states "Immediately after the conflict-edge set is derived and before anything consumes it, run the
  lane-assertion diagnostic". The invocation literal is line **315**.
- Its result is a **required planner completion-report line item** spanning
  `.claude/skills/parallel-plan/SKILL.md:569-573`, opened at line 569.
- Its only implementation is `scripts/dev_tools/parallel_lane_assertion.py`, which the destination
  runtime does not guarantee.

`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md:51` records
that this port was deferred when the diagnostic landed, on the rationale that the diagnostic "degrades
gracefully on the no-Python path"; line 266 lists it as a deferred follow-up. Degrading gracefully is
precisely the problem: the mandatory step quietly does nothing at the destination while the skill
continues to call it mandatory.

A second, smaller problem ships alongside it. `.claude/skills/parallel-plan/SKILL.md:316` says the
lane-assertion call is "covered by the planner's existing `Bash(poetry run *)` grant", while
`.claude/agents/parallel-planner.md:185-186` says that grant "is not required by any step above". Both
statements are in the payload and they contradict each other.

## Personas & Scenarios

### Persona: the parallel planner agent at a destination

- **Who:** the `parallel-planner` persona running inside a consumer repository that received a
  push-down of `.claude` and `config`, with no repository checkout of this project.
- **What it cares about:** completing the seeding procedure in `parallel-plan/SKILL.md` and emitting a
  completion report whose required line items all carry real values.
- **Constraints:** its `tools:` allowlist is narrower than project settings. It has three
  entry-point-scoped bash grants, a PowerShell blast-radius module, and `Bash(poetry run *)`, which
  resolves to nothing at the destination. There is no `Bash(pwsh *)` grant on this persona.
- **Frustration:** a step the skill calls mandatory has no runnable implementation, and the persona
  file and the skill file disagree about which grant covers it.

### Persona: the epic / parallel orchestrator at a destination

- **Who:** the `epic-orchestrator` and `parallel-orchestrator` personas running the checkpoint
  validation step.
- **What it cares about:** validating orchestration artifacts through a form that works where it is
  running.
- **Constraints:** the MCP form `mcp__drm-copilot__validate_orchestration_artifacts` is available and
  supports `require_complete`; the CLI spelling offered beside it is not available at the destination.
- **Frustration:** two spellings are offered as equivalents when only one of them runs.

### Persona: the payload maintainer

- **Who:** the engineer who owns `.claude/**` and its bundle mirror.
- **What they care about:** that a destination-runtime implementation does not become a second source
  of truth, and that every added or edited `.claude/**` file reaches the bundle.
- **Constraints:** the repository-to-bundle copy has no automation; two tests are the only guards, and
  `pack-manifests/core.json` is guarded by a third, separate assertion.
- **Frustration:** a missed mirror or a missed manifest entry fails in one narrow suite, or silently
  drops files from a manifest-scoped push-down.

### Scenario: seeding a parallel run at a destination

1. The planner derives the conflict-edge set with `Test-BlastRadiusConflict` (step 1 of the seeding
   procedure, `parallel-plan/SKILL.md:304-312`).
2. Before anything consumes that edge set, the planner must run the lane-assertion diagnostic
   (step 2, lines 313-329).
3. **Today:** the only invocation offered is `poetry run python -m scripts.dev_tools.parallel_lane_assertion`.
   At the destination there is no Poetry, no Python, and no `scripts/dev_tools`. The step cannot run.
   The planner either reports the required line item with no value or fabricates one.
4. **After this feature:** the planner runs
   `bash .claude/lib/bash/report-lane-assertion.sh --manifest <path> --edges "<a>:<b> ..."` under a
   grant of the same shape as the three entry-point grants the persona already carries. The command
   prints the header line, zero or more `ADVISORY` lines, and the closing advisory-only line, and exits
   0. The planner records that report as the required completion-report line item.
5. The edge set the planner then hands to `compute-cohorts.sh` is **unchanged** by the diagnostic. No
   scheduling decision differs.

### Scenario: validating a checkpoint at a destination

1. The orchestrator reaches the checkpoint validation step.
2. **Today:** two spellings are offered — the MCP tool and an "equivalent CLI invocation". The CLI form
   does not run at the destination.
3. **After this feature:** only the MCP form is offered, and `require_complete` remains available
   through it, so no capability is lost.

## Acceptance Criteria

- [x] A planner at a destination with no Python interpreter can complete the mandatory seeding step:
      `tests/shell/parallel_payload_only.bats` passes and contains at least one case that invokes
      `.claude/lib/bash/report-lane-assertion.sh` from the bundle root under the four-shim `PATH`,
      asserting exit 0 and the expected report text.
- [x] The ported diagnostic produces the same report as the Python reference over a shared corpus:
      `tests/shell/parallel_lane_assertion_parity.bats` and
      `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` both pass over
      `tests/fixtures/parallel_lane_assertion/*.json`, each declaring and asserting a
      `MINIMUM_FIXTURE_COUNT` floor, with the bats lane also asserting `python3` is available so the
      suite cannot pass vacuously.
- [x] The corpus exercises the diagnostic's full reporting surface: a parity-lane case asserts each of
      `expected_together_derived_apart`, `expected_apart_derived_together`, `member_names_no_item`, and
      `item_covered_by_no_component` appears in the `expected_stdout` of at least one fixture, and a
      further fixture covers a manifest carrying no `expected_conflict_components` key whose expected
      report lists every item as uncovered with 0 disagreements.
- [x] The advisory-only semantics are preserved and are pinned by tests, not only by prose: a
      parity-lane case asserts `expected_status` is 0 for every fixture including at least one whose
      report contains an `ADVISORY` line, and a case in `tests/shell/parallel_lane_assertion.bats`
      asserts that no file under `.claude/lib/bash/` other than `report-lane-assertion.sh` sources
      `parallel-lane-assertion.sh` and that no file under `.claude/lib/bash/` sources
      `report-lane-assertion.sh`.
- [x] The planner's procedure and grants agree with each other:
      `git grep -n -F "parallel_lane_assertion" -- .claude/skills/parallel-plan/SKILL.md` returns no
      executable invocation, the same file carries the literal
      `bash .claude/lib/bash/report-lane-assertion.sh` in the seeding-procedure step, and
      `.claude/agents/parallel-planner.md` `tools:` contains
      `Bash(bash .claude/lib/bash/report-lane-assertion.sh*)` with the stale sentence at lines 185-186
      reconciled.
- [x] The orchestrator is offered only runnable spellings for checkpoint validation:
      `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/` returns exactly **one** match,
      at `.claude/skills/parallel-orchestrate/SKILL.md:817` for the drift-detection CLI, down from
      **four** matches before this feature, so the drop from four to one is the evidence that all three
      in-scope sites are closed; `git grep -n -F "poetry run python" -- .claude/skills/` returns exactly
      **two** matches, `.claude/skills/parallel-orchestrate/SKILL.md:817` and
      `.claude/skills/parallel-remove/SKILL.md:112`, both of which are declared non-goals; and
      `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md`
      reports a non-zero count for both files.
- [x] The grant rationale that named a deleted consumer no longer does:
      `git grep -n -F "checkpoint-validator CLI fallback" -- .claude/agents/parallel-orchestrator.md`
      returns no match.
- [x] Everything the maintainer must mirror is mirrored:
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes.
- [x] Both new files survive a manifest-scoped push-down:
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists
      `.claude/lib/bash/parallel-lane-assertion.sh` and `.claude/lib/bash/report-lane-assertion.sh` in
      its `paths` array, and `tests/shell/parallel_bash_manifest_membership.bats` passes with
      `MINIMUM_LIB_FILE_COUNT` raised from 9 to 11.
- [x] The entry-point enumerations that read as authoritative are current: both
      `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:242-244` and
      `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:451-453` include
      `.claude/lib/bash/report-lane-assertion.sh`, and both suites pass.
- [x] The deliberate behavior difference is observable rather than indistinguishable from a defect:
      `tests/shell/parallel_lane_assertion.bats` contains a case pinning that an `--edges` endpoint
      token bearing a leading zero, a leading `+`, an underscore digit separator, or a non-ASCII decimal
      digit causes the port to drop the edge token, and no such input appears in any file under
      `tests/fixtures/parallel_lane_assertion/`. Interior whitespace inside an endpoint is not in that
      enumeration: it is unreachable in both implementations, so the spec's Divergence class 3 covers it
      as a convergence fixture in the shared corpus instead.
- [x] The new modules meet the shell quality bar: `bash scripts/bash/shell-qc.sh check` exits 0, and
      `bash scripts/bash/shell-qc.sh test --coverage` reports bash line coverage >= 85% with per-file
      rows for both new files present in `artifacts/pester/kcov/cov.xml` and neither file excluded from
      measurement, with the run output recorded under
      `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/qa-gates/`.
- [x] The non-goals stay untouched: `git diff --stat origin/main...HEAD` shows no changed line in
      `.claude/rules/parallel-orchestration.md` or `.claude/skills/parallel-remove/SKILL.md`, the
      drift-detection invocation at `.claude/skills/parallel-orchestrate/SKILL.md:817` is unchanged, and
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with its
      allowlist still empty.

## Non-Goals

Full rationale for each item is recorded in `spec.md` under `## Non-Goals`.

1. **`parallel_drift_detection_cli`** (`.claude/skills/parallel-orchestrate/SKILL.md:817`). The
   `Bash(poetry run python -m *)` grant is deliberately retained for it at
   `.claude/agents/parallel-orchestrator.md:92-96`, scoped to two invocation forms only. The dependency
   is a recorded decision, not drift. Porting it is a second net-new implementation outside this epic's
   approved scope.
2. **`parallel_mutation_abandon_cli.py`** (`.claude/skills/parallel-remove/SKILL.md:112`). Never
   identified by the epic intake. `.claude/hooks/enforce-parallel-abandon-gate.ps1` matches on this
   invocation's tokens, declared in exactly one place beginning at line **38**, and
   `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses both sides so a one-sided rename
   fails. Changing the invocation without co-designing the gate would break the confirmation contract
   the gate exists to enforce.
3. **`.claude/rules/parallel-orchestration.md`.** No edit. The `policy-compliance-order` skill prohibits
   modifying documents under `.claude/rules/`, and the file's M8 passage identifies the Python module as
   the authoritative reference implementation — exactly the legitimate prose-citation class this feature
   places out of scope.
4. **The discovery-gate hook rationale comments**
   (`.claude/hooks/enforce-discovery-artifact-gate.ps1:49-52` and
   `.claude/hooks/validate-discovery-artifact-gate.ps1:50-53`). Live rationale, not stale drift.
   Preserve; reword at most. **No change at all is an acceptable outcome.**

Additionally out of scope: any `--keys` flag on the new entry point, any new validator or checkpoint
field, and any change to `scripts/dev_tools/parallel_lane_assertion.py`, which remains the repository
authority.

## Known Residual

The epic manifest's broad leading indicator at **manifest line 14** — "No file under `.claude/**`
contains an executable python or poetry invocation that a mandatory procedure step depends on" — is
**not fully satisfied** after this feature lands, because non-goals 1 and 2 remain by deliberate
decision. The narrow indicator at **manifest line 15** — "The lane-assertion diagnostic runs to
completion on a destination runtime with no Python interpreter present" — **is** fully satisfied, and
its evidence is the payload-only suite case in the first acceptance criterion above.

The corrective action for the residual is an epic-owner rewording of manifest line 14 to scope it to the
sites this epic actually closes. It is not additional implementation work here, and no acceptance
criterion above depends on the broad indicator.

## Dependency Status — Features A and C

Neither sibling feature folder exists on this branch; this was verified by globbing
`docs/features/active/*/spec.md` (25 folders, neither sibling present) and by globs for
`*calling-convention*` and `*caller-site*` under `docs/features/**` (no files). The following absences
are deliberate, not omissions:

- **Feature A's PowerShell fail-fast import convention has no application surface here.** Under the
  bash-only design this feature adds no PowerShell file, and `$ErrorActionPreference` and
  `Import-Module -ErrorAction Stop` have no bash analogue. The port follows the bash conventions the
  existing entry points already use instead: `set -euo pipefail`, self-directory resolution before
  sourcing, and `pc_enforce_c_locale` before any work.
- **Feature A's date-coercion work has no application surface here.** It targets the three
  `ConvertFrom-Json` sites under `.claude/lib/**`. The port parses no JSON and reads no timestamp; it
  consumes `expected_conflict_components` and `items[].issue_num` only.
- **Feature C contends with this feature at section level in one file.** Both edit
  `## Upstream Library Invocation` in `.claude/agents/parallel-planner.md`. Feature C rewrites the
  PowerShell paragraph at lines **147-156**. This feature confines its edits in that section to the
  `tools:` list and the bash paragraph and leaves 147-156 untouched.
