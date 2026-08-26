# Coverage Delta and Threshold Verification [P6-T10]

Timestamp: 2026-08-24T23-22

Task: [P6-T10]
Gate applied: the uniform gate of `.claude/rules/quality-tiers.md` — line coverage at or above
**85 percent** and branch coverage at or above **75 percent**, applied identically across T1 through
T4 — plus the no-regression-on-changed-lines rule of `.claude/rules/general-unit-test.md`.
`quality-tiers.yml` is absent from the repository root, so no tier-specific overlay applies.

Sources read for this verification (numbers taken from the artifacts, not from any summary):

| Group | Artifact |
| --- | --- |
| Python baseline | `evidence/baseline/baseline-python-test-coverage.2026-08-24T22-20.md` ([P0-T6]) |
| Python post-change | `evidence/qa-gates/final-python-test-coverage.2026-08-24T23-13.md` ([P6-T4]) |
| TypeScript baseline | `evidence/baseline/baseline-typescript-test-coverage.2026-08-24T22-23.md` ([P0-T10]) |
| TypeScript post-change | `evidence/qa-gates/final-typescript-test-coverage.2026-08-24T23-19.md` ([P6-T8]) |

---

## Python

### Group 1 — Baseline coverage ([P0-T6])

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| Whole `scripts.dev_tools` package | 92.61% | 89.82% | 13841 / 14946 lines; 4931 / 5490 branches |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 97.39% | 94.44% | 112 / 115 statements; 51 / 54 branches |

Baseline uncovered lines in the changed module: 185, 217, 277.

### Group 2 — Post-change coverage ([P6-T4])

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| Whole `scripts.dev_tools` package | 92.61% | 89.82% | 13845 / 14950 lines; 4933 / 5492 branches |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 97.48% | 94.64% | 116 / 119 statements; 53 / 56 branches |

Post-change uncovered lines in the changed module: 185, 224, 287.

### Group 3 — New/changed-code coverage (lines added by [P3-T1] through [P3-T3])

The diff adds 13 lines to the module (`git diff --stat`: 13 insertions, 0 deletions), in five hunks:

| New line numbers | Content | Task |
| --- | --- | --- |
| 202-207 | `_carries_launch_path` definition, docstring, and `return` | [P3-T1] |
| 215 | `require_launch_paths: bool = False` keyword-only parameter | [P3-T2] |
| 228-229 | `if require_launch_paths and not _carries_launch_path(feature): continue` | [P3-T2] |
| 270 | `require_launch_paths=False` from `validate_epic_planner_child_launch_bindings` | [P3-T2] |
| 295-297 | `require_launch_paths=not (require_codex_model_routing or require_codex_topology)` | [P3-T3] |

Coverage of that added code, established two independent ways:

1. **Counter arithmetic.** Statements rose 115 to 119 (+4) and branches rose 54 to 56 (+2), while
   missed statements stayed at **3** and partial branches stayed at **3**. Zero of the added
   statements and zero of the added branch arms are uncovered.
   **New-code line coverage: 100 percent (4 / 4). New-code branch coverage: 100 percent (2 / 2).**
2. **Uncovered-line identity.** The three post-change uncovered lines are the same three pre-existing
   lines as at baseline, displaced by the insertions above them: 185 is unmoved (it precedes every
   hunk); baseline 217 moved to 224 (+6 from the 202-207 hunk, +1 from line 215); baseline 277 moved
   to 287 (+6, +1, +2 from the 228-229 hunk, +1 from line 270). Line 185 is inside
   `_validate_model_receipt`, line 224 is the `continue` for a non-dict feature entry, and line 287 is
   the non-list `features` early return. **No line number in the added set {202-207, 215, 228, 229,
   270, 295-297} appears in the uncovered list.**

### Python threshold and regression verdict

| Scope | Measure | Baseline | Post-change | Delta | Gate | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Whole package | Line | 92.61% | 92.61% | 0.00 pp | >= 85% | PASS |
| Whole package | Branch | 89.82% | 89.82% | 0.00 pp | >= 75% | PASS |
| Changed module | Line | 97.39% | 97.48% | +0.09 pp | >= 85% | PASS |
| Changed module | Branch | 94.44% | 94.64% | +0.20 pp | >= 75% | PASS |
| Changed lines | Line | n/a | 100% (4 / 4) | n/a | no regression | PASS |
| Changed lines | Branch | n/a | 100% (2 / 2) | n/a | no regression | PASS |

No coverage measure decreased. Suite result moved from 4116 passed / 0 failed to 4117 passed /
0 failed.

---

## TypeScript

### Group 1 — Baseline coverage ([P0-T10])

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| All files | 96.66% | 90.04% | 43071 / 44558 lines; 6122 / 6799 branches |
| `src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 95.83% | 92.30% | reported by the `text` reporter |

Baseline uncovered lines in the changed module: 45-46, 56-61, 215-217, 250-251.

### Group 2 — Post-change coverage ([P6-T8])

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| All files | 96.66% | 90.05% | 43084 / 44571 lines; 6128 / 6805 branches |
| `src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 96.00% | 92.72% | reported by the `text` reporter |

Post-change uncovered lines in the changed module: 45-46, 56-61, 215-217, 256-257.

### Group 3 — New/changed-code coverage (lines added by [P3-T4])

The diff adds 13 lines to the module (`git diff --stat`: 13 insertions, 0 deletions), in five hunks:

| New line numbers | Content |
| --- | --- |
| 234-238 | `featureCarriesLaunchPath` doc comment and definition |
| 244 | `readonly requireLaunchPaths: boolean;` on `LaunchBindingContext` |
| 261-263 | `if (context.requireLaunchPaths && !featureCarriesLaunchPath(item)) { return; }` |
| 296 | `requireLaunchPaths: false` from `validateEpicPlannerChildLaunchBindings` |
| 321-323 | `requireLaunchPaths: options.requireCodexModelRouting !== true && options.requireCodexTopology !== true` |

Coverage of that added code:

1. **Uncovered-line identity.** The post-change uncovered set is the same four spans as at baseline,
   with only the last span displaced by the six inserted lines above it (250-251 becomes 256-257;
   +5 from the 234-238 hunk, +1 from line 244). The first three spans are unmoved because they
   precede every hunk. **No line number in the added set {234-238, 244, 261-263, 296, 321-323}
   appears in the uncovered list.** The added `return` at line 262 is inside the new skip branch and
   is exercised by `skips launch binding for a feature with no launch paths under requireComplete`;
   the non-skip path through line 261 is exercised by `rejects a partial launch binding under
   requireComplete` and by every preserved Codex-flag test.
   **New-code line coverage: 100 percent. New-code branch coverage: 100 percent.**
2. **Percentage movement.** Both per-file measures rose (line 95.83 to 96.00, branch 92.30 to 92.72)
   despite the file growing, which is only possible if the added lines and branch arms are covered at
   a rate above the file's prior rate.

### TypeScript threshold and regression verdict

| Scope | Measure | Baseline | Post-change | Delta | Gate | Result |
| --- | --- | --- | --- | --- | --- | --- |
| All files | Line | 96.66% | 96.66% | 0.00 pp | >= 85% | PASS |
| All files | Branch | 90.04% | 90.05% | +0.01 pp | >= 75% | PASS |
| Changed module | Line | 95.83% | 96.00% | +0.17 pp | >= 85% | PASS |
| Changed module | Branch | 92.30% | 92.72% | +0.42 pp | >= 75% | PASS |
| Changed lines | Line | n/a | 100% | n/a | no regression | PASS |
| Changed lines | Branch | n/a | 100% | n/a | no regression | PASS |

No coverage measure decreased. Suite result moved from 195 suites / 2657 tests passed to 195 suites /
2658 tests passed, 0 failed in both.

---

## Verdict

**PASS.**

- Both changed production modules exceed the 85 percent line gate:
  `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` at **97.48 percent** and
  `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` at
  **96.00 percent**.
- Both exceed the 75 percent branch gate: **94.64 percent** and **92.72 percent** respectively.
- Both whole-scope totals also clear both gates in both languages.
- No regression on changed lines: every line and branch added by [P3-T1] through [P3-T4] is covered,
  established by unchanged missed/partial counters on the Python side and by the unchanged
  uncovered-span set on both sides.
- Every value in all three groups is a real number read from a named artifact. No placeholder is
  present, so the fail-closed INCOMPLETE condition of the plan does not apply.

The other files in the diff carry no coverage obligation: `.claude/rules/orchestrator-state.md` and
its bundle twin are Markdown, and the two test files are excluded from the coverage denominator by
policy.
