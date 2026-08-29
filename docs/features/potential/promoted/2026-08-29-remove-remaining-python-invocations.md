# remove-remaining-python-invocations (Issue #599)

- Date captured: 2026-08-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/remove-remaining-python-invocations/ (Issue #599)
- Epic: `docs/features/epics/claude-runtime-portability/epic.md` (Feature D, wave 2, complexity C3)
- Depends on: Feature C (`caller-site-invocation-correctness`), by file contention on
  `.claude/skills/parallel-plan/SKILL.md`

- Issue: #599
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/599
- Last Updated: 2026-08-29
## Problem / Why

The `.claude/**` payload is published into consumer repositories by the push-down mechanism. Those
destinations guarantee no Python interpreter, no Poetry, and no `scripts/dev_tools` tree. Issue #475
already removed the Python dependency from the two discovery-gate hooks on exactly this reasoning.
Executable Python invocations that remain in the published payload make the procedure steps that
depend on them silently unavailable at their destination.

The substantive case is the lane-assertion diagnostic. Its *invocation* is a mandatory procedure
step — `.claude/skills/parallel-plan/SKILL.md:313-315` states "Immediately after the conflict-edge
set is derived and before anything consumes it, run the lane-assertion diagnostic" — and a required
planner completion-report line item at `.claude/skills/parallel-plan/SKILL.md:571`. Its only
implementation is `scripts/dev_tools/parallel_lane_assertion.py`, which the destination runtime does
not guarantee.

The justification is **not** a rule contradiction. `.claude/rules/parallel-orchestration.md`
(invariant M8) and `.claude/skills/parallel-plan/SKILL.md:322-329` agree that the diagnostic's
FINDINGS are advisory-only and never block. The defect is narrower: a required step is not
executable on the runtime the payload targets. The port must preserve the advisory-only semantics
exactly.

`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md:51`
records that this port was explicitly deferred when the diagnostic landed, and line 266 lists it as
a deferred follow-up.

## Proposed Behavior

Remove the two trivial CLI spellings that already have an MCP equivalent alongside them, and port
the lane-assertion diagnostic to the destination-portable runtime.

Verified site table (see "Constraints & Risks" for the intake corrections):

| # | site | disposition |
| --- | --- | --- |
| 1 | `.claude/skills/epic-orchestrate/SKILL.md:296` | In scope, trivial. Delete the CLI spelling; the MCP form `mcp__drm-copilot__validate_orchestration_artifacts` is already offered alongside it. |
| 2 | `.claude/skills/parallel-orchestrate/SKILL.md:482` | In scope, trivial. Introduced as "or the equivalent CLI invocation"; delete the alternative, keep the MCP form. |
| 3 | `.claude/skills/parallel-orchestrate/SKILL.md:817` | **Non-goal.** `parallel_drift_detection_cli`. |
| 4 | `.claude/skills/parallel-plan/SKILL.md:315` | In scope, substantive. `parallel_lane_assertion`; requires the new port. |
| 5 | `.claude/skills/parallel-remove/SKILL.md:112` | **Non-goal.** `parallel_mutation_abandon_cli.py`. Not identified by the epic intake; see below. |

The port ships as a destination-portable module under `.claude/lib/` following the existing
cross-runtime parity precedent set by `.claude/lib/bash/compute-cohorts.sh` and
`.claude/lib/bash/validate-parallel-manifest.sh`, with a parity suite over a shared corpus
equivalent to `tests/shell/parallel_cohorts_parity.bats` and
`tests/shell/parallel_manifest_parity.bats`.

## Acceptance Criteria (early draft)

- [ ] A destination-portable lane-assertion port exists under `.claude/lib/` and produces output
      identical to `scripts/dev_tools/parallel_lane_assertion.py` over a shared parity corpus.
- [ ] The port always exits 0, never blocks, never feeds `compute_cohorts`, and never influences
      scheduling — the advisory-only semantics are preserved unchanged.
- [ ] `.claude/skills/parallel-plan/SKILL.md` invokes the port instead of
      `poetry run python -m scripts.dev_tools.parallel_lane_assertion`.
- [ ] The CLI spellings at `.claude/skills/epic-orchestrate/SKILL.md:296` and
      `.claude/skills/parallel-orchestrate/SKILL.md:482` are removed, leaving the MCP form.
- [ ] A parity test suite asserts port-vs-reference output identity over the shared corpus.
- [ ] Every added or edited `.claude/**` file has a byte-identical copy under
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`, and
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes.
- [ ] The two explicit non-goals (sites 3 and 5) are recorded in `spec.md` with their rationale.

## Constraints & Risks

**Intake corrections carried from the epic manifest.**

- `parallel-plan/SKILL.md` contains ONE executable site, not two.
- The lane-assertion literal is at line **315**, not 317. The manifest's `315-317` span covers the
  mandatory-step sentence (313-315) plus the following prose; the invocation itself is line 315.
- The claimed rule contradiction does not exist; both documents agree the findings are advisory.

**New discrepancy found during promotion, not present in the epic manifest.** The manifest asserts
exactly four executable Python invocation sites under `.claude/**`. There are **five**.
`.claude/skills/parallel-remove/SKILL.md:112` invokes
`poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py` and is mandatory in the
strongest available terms: the surrounding text requires the abandon disposition to run "through the
single deterministic CLI invocation below and through nothing else" and prohibits ad hoc
alternatives. It is nonetheless an explicit **non-goal** here, on the same reasoning as site 3 and
one additional one: `.claude/hooks/enforce-parallel-abandon-gate.ps1:29` matches on the tokens of
that exact invocation, so replacing the invocation without co-designing the gate would break the
confirmation contract the gate exists to enforce. That is a separate design decision outside this
epic's approved scope.

**Non-goal: the drift-detection CLI (site 3).** `.claude/agents/parallel-orchestrator.md:92-96`
explicitly retains the two `poetry run python -m` grants "for the repository-local paths that still
need an interpreter" and names the drift-detection CLI as one of them. The dependency is deliberate,
not accidental drift. Porting it is a second net-new implementation outside this epic's approved
scope.

**Narrowed: the discovery-gate hook comments.** The `scripts/dev_tools` references in
`.claude/hooks/enforce-discovery-artifact-gate.ps1:49-52` and
`.claude/hooks/validate-discovery-artifact-gate.ps1:50-52` are live rationale comments, not stale
drift. Both read "This no longer invokes a Python interpreter (issue #475)" and record WHY the
payload must not depend on Python. Preserve the rationale; reword at most. Removal is out of scope,
and no change at all is an acceptable outcome for this item.

**Out of scope generally.** The many legitimate prose citations that identify the Python modules as
the authoritative reference implementations per `.claude/rules/parallel-orchestration.md` stay.

**Mandatory cross-cutting constraint.**
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 101-126) asserts every repository `.claude/**` file — excluding `settings.local.json` and the
`.claude/agent-memory/**` subtree — is byte-identical to its copy under
`extensions/drm-copilot/resources/claude-customizations/.claude/**`. Every `.claude/**` file edited
or ADDED, including the new port module, needs an identical bundle copy in the same change.

**Toolchain and size constraints.**

- `scripts/dev_tools/parallel_lane_assertion.py` is 499 lines against a 500-line cap, so the port
  may need splitting across modules.
- `.claude/lib/bash/parallel-yaml-scan.sh` is the destination-runtime YAML subset parser and rejects
  non-empty flow collections, which constrains how `expected_conflict_components` can be read.
- The bash toolchain per `.claude/rules/shell.md` is native bash with no Python or Poetry
  dependency; `.claude/lib/bash/` is a discovery root, so the port is held to the same format, lint,
  test, and coverage standards.
- PowerShell per-batch cap: 3 production plus 3 test files.
- Uniform coverage thresholds apply: line >= 85%; branch >= 75% except for bash/PowerShell, whose
  tooling does not measure branch coverage.
- A new `.claude/lib/**` module must follow the fail-fast import and date-coercion conventions that
  Feature A establishes.

## Test Conditions to Consider

- [ ] Parity: port output byte-identical to the Python reference over a shared corpus covering all
      four ADVISORY finding classes (expected-together-but-derived-apart,
      expected-apart-but-derived-together, member naming no manifest item, and the informational
      uncovered-item class).
- [ ] Manifest with no `expected_conflict_components` key: the diagnostic still runs and reports
      every item as uncovered.
- [ ] Exit code is 0 in every case, including when disagreements are reported.
- [ ] `expected_conflict_components` expressed in the YAML subset the destination parser accepts.
- [ ] Push-down bundle parity test passes with the new and edited files mirrored.
- [ ] Coverage for the new module meets the uniform line threshold.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/remove-remaining-python-invocations/` folder from the template
