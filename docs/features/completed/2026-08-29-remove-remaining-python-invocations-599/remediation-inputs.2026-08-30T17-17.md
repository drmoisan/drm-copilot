# Remediation Inputs — remove-remaining-python-invocations (Issue #599)

- Timestamp: 2026-08-30T17-17
- Branch: `feature/remove-remaining-python-invocations-599-r2`
- Base branch: `main`, merge base `8b94217e198a484956a20297922db211d51d3faa`

## Source Artifacts

- `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/policy-audit.2026-08-30T17-17.md`
- `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/code-review.2026-08-30T17-17.md`
- `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/feature-audit.2026-08-30T17-17.md`

## Summary

One remediation-required finding. It does not fail any of the 33 acceptance criteria, all of
which pass. It is a completeness defect in the spec's own exhaustive divergence claim, together
with the missing test that would make the behavior observable.

Three optional findings are listed for the implementer's judgment and are not required.

## R-1 — REQUIRED — undeclared parity divergence on a newline-bearing `--edges` value

- **Cross-reference:** policy-audit PA-1, code-review CR-1, feature-audit "Gap Against the
  Feature's Own Claim".
- **Severity:** Major. Remediation required before this feature is treated as closed.
- **Blocks merge:** No, on its own. The defect is in documentation completeness and test
  coverage, not in a shipped capability, and the diagnostic is advisory-only.

### Evidence

Location: `.claude/lib/bash/parallel-lane-assertion.sh:86` and its byte-identical mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh:86`.

```bash
read -ra tokens <<<"$text"
```

`read` consumes exactly one line, so every `--edges` token after the first newline is silently
discarded. The Python authority uses `str.split()`
(`scripts/dev_tools/parallel_lane_assertion.py:425`), which treats `\n` as an ordinary
whitespace separator.

Reproduced against both lanes on the same manifest
(`tests/fixtures/parallel_manifest_payload/parallel.md`) with the same input:

```
--edges $'999:998\n101:202'
  bash   -> Lane assertion: 2 derived conflict component(s); 0 disagreement(s).
  python -> Lane assertion: 1 derived conflict component(s); 0 disagreement(s).
```

### Why this is remediation-required

`spec.md:328-366` presents the divergence set as exhaustive, and `spec.md:484-485` states the
purpose of that enumeration: without it a deliberate behavior difference "would be
indistinguishable from a porting defect". A divergence outside the enumerated set defeats that
purpose for a future reader. The specific justification the spec gives for excluding whitespace
from class 3 (`spec.md:352-358`) is factually incomplete: it holds for space and tab, not for
newline.

Neither parity lane nor the unit suite covers the newline input in any direction, so the gap is
currently invisible to every gate.

### Bounding context (do not over-scope the fix)

- The diagnostic is advisory-only, always exits 0, feeds nothing, and never influences
  scheduling. No scheduling decision can differ because of this.
- Both documented invocation forms — `parallel-plan/SKILL.md:321` and
  `parallel-planner.md:189` — are single-line space-separated strings.
- The pattern is pre-existing precedent. `.claude/lib/bash/compute-cohorts.sh` was probed with
  the equivalent input and exhibits the same class of behavior
  (`--keys "101 202 303" --edges $'101:202\n202:303'` yields `[[101,303],[202]]`, not a valid
  partition of that graph). This feature does not introduce a regression.

### Acceptable remediations — either is sufficient

**Option A (recommended, smaller, consistent with the siblings).** Declare and pin it.

1. Add a `Divergence class 6 (new) — newline inside the --edges value` entry to `spec.md`
   `### Declared divergences from the Python reference`, stating that the port consumes only the
   first line of the `--edges` value while the reference splits on all whitespace.
2. Correct the class-3 whitespace paragraph at `spec.md:352-358` to scope its "cannot observe"
   claim to space and tab, and cross-reference the new class 6.
3. Mirror the same declaration into the header comment of
   `tests/shell/parallel_lane_assertion_parity.bats` and
   `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`, which
   `spec.md:330-331` requires of every lane that reads the shared corpus.
4. Add a bash-only unit case in `tests/shell/parallel_lane_assertion.bats` in the same shape as
   the existing class-3 case at `:395-429`, including a control assertion, pinning that a
   newline-separated `--edges` value drops the trailing tokens.
5. Confirm the input appears in no file under `tests/fixtures/parallel_lane_assertion/`, as the
   existing class-3 and class-5 cases do for their inputs.

**Option B.** Close the divergence.

1. Change `pla_parse_edges` to split on all whitespace, for example by iterating lines of the
   here-string and appending each line's tokens.
2. Add a convergence fixture to `tests/fixtures/parallel_lane_assertion/` whose `edges` value
   carries a newline and whose `expected_stdout` is identical to the single-line equivalent, so
   both lanes assert the convergence.
3. Consider whether `.claude/lib/bash/compute-cohorts.sh` should change in the same way. If it
   is left alone, the two entry points will disagree on tokenizing, which is a new consistency
   cost that must be recorded.

Option A is recommended: it is a documentation and test change only, it leaves the port
consistent with its siblings, and it matches how this feature already handles its other known
divergences.

### Mandatory follow-through for either option

- If `.claude/lib/bash/parallel-lane-assertion.sh` is edited, re-copy it byte-identically to
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh`.
  The repository-to-bundle copy has no automation; the only guards are
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  and the `cmp -s` case in `tests/shell/parallel_bash_manifest_membership.bats:56-71`.
- Restart the shell toolchain from stage 1 per `.claude/rules/shell.md`:
  `shell-qc.sh format` -> `shell-qc.sh check` -> `shell-qc.sh test --coverage`.
- Re-record the coverage gate under
  `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/qa-gates/`
  at a new timestamp. Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`,
  `artifacts/evidence/`, or `artifacts/coverage/`.
- If `spec.md` gains a class 6, no acceptance criterion needs to change: no listed criterion
  asserts newline handling. Do not add a phantom acceptance criterion.

## R-2 — OPTIONAL — `pc_enforce_c_locale` runs at source time

- **Cross-reference:** code-review CR-2.
- **Location:** `.claude/lib/bash/report-lane-assertion.sh:37`.
- The call sits at top level, outside the `BASH_SOURCE[0] == "${0}"` guard whose stated purpose
  (`:163`) is that the file can be sourced without executing anything. Sourcing therefore does
  mutate the sourcing shell's `LC_ALL`. `tests/shell/report_lane_assertion_dispatch.bats:36`
  relies on the sourcing path.
- Suggested change: move the call to the first statement of `rla_main`. This preserves the
  ordering property that `tests/shell/parallel_lane_assertion.bats:255` pins, which compares the
  source position of the locale call against the first `printf`; that case would need its
  pattern updated from `^pc_enforce_c_locale$` to match the indented in-function call.
- Not required. The current behavior is benign and matches the sibling entry points.

## R-3 — OPTIONAL — narrow the file-wide `SC2034` suppression

- **Cross-reference:** code-review CR-3, policy-audit row 10.
- **Location:** `.claude/lib/bash/parallel-lane-assertion.sh:26-30`.
- The suppression is justified inline with a correct reason and satisfies
  `.claude/rules/shell.md`. The concern is scope only: file-wide, it will also mask a genuinely
  unused variable added later to this 495-line file.
- Suggested change: replace with per-declaration `# shellcheck disable=SC2034` comments on the
  affected globals.
- Not required.

## R-4 — INFORMATIONAL — quadratic membership scans

- **Cross-reference:** code-review CR-4.
- **Locations:** `pla_count_distinct` (`:280-295`) and the `pc_contains_word` guards in
  `pla_derive_components` (`:227-230`).
- Immaterial at the documented scale (13 lanes over 69 items, exercised by
  `tests/fixtures/parallel_lane_assertion/scale_thirteen_lanes_matching.json`). Recorded so a
  future scale increase has a known place to look.
- No action recommended.

## Explicitly Not Remediation Triggers

Recorded so a subsequent pass does not re-open settled items.

- **Absent `coverage/lcov.info` at repo root.** The TypeScript coverage artifact exists at the
  workspace-native path `extensions/drm-copilot/coverage/lcov.info`, which is where Jest writes
  it in this monorepo layout. The artifact is present and the figures are verified. The
  canonical path named in the reviewer's own definition does not match this repository's layout.
- **Absent `artifacts/pester/powershell-coverage.xml` and `artifacts/csharp/coverage.xml`.**
  Zero `.ps1`, `.psm1`, and `.cs` files are in the branch diff, confirmed by
  `git diff --name-only main...HEAD | grep -Ec "\.(ps1|psm1|cs)$"` returning `0`. The
  absent-artifact FAIL rule applies only to languages with changed files.
- **Bash branch coverage.** kcov measures line coverage only. `.claude/rules/quality-tiers.md`
  and `.claude/rules/shell.md` apply no bash branch gate. This is a capability exemption, not a
  missing metric.
- **Python lcov carries no `BRDA:` records.** Zero Python production files changed on this
  branch, so no changed production line's branch coverage can regress. Recorded as an
  evidence-quality observation only.
- **The Known Residual against epic manifest line 14.** Deliberate, documented in
  `spec.md:538-552`, and already routed to the epic owner as a manifest-wording action in
  `evidence/other/known-residual.2026-08-30T20-45.md` and `epic-status.md:79-83`. Not
  implementation work for this feature.
- **The four unchecked `## Definition of Done` items in `spec.md`.** Completion gates, not
  acceptance criteria, and outside the reviewer check-off protocol. Their substance is satisfied
  and is assessed in the feature audit.

## Remediation Scope Boundary

Remediation is confined to R-1. Do not re-open closed acceptance criteria, do not alter
`scripts/dev_tools/parallel_lane_assertion.py` (it remains the repository authority and is an
explicit non-goal), and do not touch the declared non-goals: `.claude/rules/parallel-orchestration.md`,
`.claude/skills/parallel-remove/SKILL.md`, or the drift-detection invocation at
`.claude/skills/parallel-orchestrate/SKILL.md:817`.
