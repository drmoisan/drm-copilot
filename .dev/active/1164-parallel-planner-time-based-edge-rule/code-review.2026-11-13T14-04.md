# Code Review: parallel-planner-time-based-edge-rule (#1164)

**Review Date:** 2026-11-13
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1164
**Base Branch:** `main` (merge base `1d62aa292161035aec8058e6c370f133e10a04db`, equal to `origin/main` at review time)
**Head Branch:** `feature/parallel-planner-time-based-edge-rule-1164` (head `90d84af1305f120cf0c7d044c09c0390b99cfde9`)
**Review Type:** Remediation cycle 1 re-audit (exit review). Inputs `remediation-inputs.2026-11-11T04-47.md` (R1 to R4); plan `remediation-plan.2026-11-11T04-47.md` (20 of 20 tasks checked); prior review `code-review.2026-11-11T04-32.md`.

---

## Executive Summary

The prior review graded the branch Go with two Minor and four Info rows. Under owner directive OD-7, the orchestrator opened cycle 1 to fix the two Minor rows (R1, R2) and two of the Info rows (R3, R4) inside the item. Commit `e2d42d831` delivers them; the plain merge `01547c4c7` of `origin/main` brought only issue 1167 changes. The full branch diff against the merge base was reviewed again for anything new.

**Cycle findings, verified at head:**
- R1 resolved. `pythonRepr` in `parallel-state-shared.ts` (lines 121 to 128) selects double quotes when the string holds `'` and no `"`, and otherwise single-quotes with `\'` escaped. This matches CPython. Three corpus stems pin it, and both runtimes consume them. The expected strings (`"docs/it's.md"`, `["it's_overlap"]`) would fail against the former helper, so the stems discriminate.
- R2 resolved. The weight rows are priced through the public `pair_cost` over single-path declared radii. The private import and `# pyright: ignore[reportPrivateUsage]` are gone, and every row name and expected weight is unchanged.
- R3 resolved as specified. `Overwrite` and `Regenerate` were added, and a case-insensitive set holds each verb's regular inflections. The set is a superset of the former list, so the change is fail-safe. The 15 `-ForEach` cases each fail against the former whole-word list, because each title begins with `Run`. The `address` control case guards against prefix matching.
- R4 resolved. The absent-key case covers the former missed line; the module is at 42/42 lines.

**Top 3 risks:**
1. Default scheduling behaviour changes for every run planned after merge (owner-directed, OD-1164-1). The committed minutes rest on a small sample (spec D2). Recorded estimates make each verdict auditable, and destinations can override weights.
2. `access-paths` remains a title-word heuristic. Irregular write forms (`written`, `wrote`, `rewrote`) are not recognized (finding row 1). Drift detection is the backstop.
3. Cross-runtime string parity still excludes control characters (finding row 2). This is pre-existing and does not affect the committed corpus.

**PR readiness recommendation:** **Go.** No Blocker or Major finding. The root TypeScript coverage report, absent at first, was produced by a reviewer run and is recorded in `evidence/qa-gates/jest-gate.2026-11-13T14-11.md`. CI on the PR head and the PR-body statements of US-AC13 remain with the orchestrator.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `coverage/lcov.info` (item worktree root; gitignored) | TypeScript coverage evidence | The cycle Jest gate ran only in `extensions/drm-copilot/`, so the root report the review contract names was absent. The reviewer ran `node run-jest.cjs --coverage` at the worktree root: 5519 passed, 0 failed; 98.29% lines, 93.64% branches. The four changed files show the same figures as the extension gate. Closed in review. | Future gates should run the root configuration so `coverage/lcov.info` exists. | Required by the `validate-feature-review-coverage` Stop hook; it was produced without any tracked-file change. | `evidence/qa-gates/jest-gate.2026-11-13T14-11.md`. |
| Info | `.claude/lib/blast-radius/BlastRadiusAccess.psm1` (and bundle mirror) | `$script:WriteTitleWordSet` builder | The set holds only regular inflections, so the irregular forms `written`, `wrote`, `rewrote`, `rewritten`, and `overwritten` do not mark a write. A title such as "Run the generator; output written to `docs/a.json`." still yields a read-only path. | Optional: add the irregular past forms of `Write`, `Rewrite`, and `Overwrite` to the set (fail-safe direction), with one `-ForEach` row each. | R3 asked for the `-s`, `-es`, `-ed`, and `-ing` forms, which are delivered. Spec B5.2 defines the title-word rule, and drift detection reports a resulting write as an escape, so this is not graded blocking. | Real-process probe `r1164c1_ap2.sh`: `access-paths` returned `docs/a.json` (written), `docs/b.json` (rewrote), and `docs/f.json` (addendum, correct) as read-only, and excluded `regenerates`, `Modifies`, and `wires`. |
| Info | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` | `pythonRepr`, string branch | CPython `repr` escapes control characters (`\n`, `\r`, `\t`, and non-printable characters as `\x..`), and `pythonRepr` does not. For a value containing a newline, the runtimes emit different strings. The `## Enforcement` paragraph of `.claude/rules/parallel-orchestration.md` lists three known divergence classes and does not name this one. | Optional: escape `\n`, `\r`, `\t`, and other non-printable characters as CPython does, with one corpus stem; or record it as a fourth divergence class in the rule and its mirror. | Pre-existing behavior outside R1, which concerned quote selection only. Planner and orchestrator paths and reasons with control characters are not expected inputs, and the committed corpus is identical in both runtimes. | Reviewer probe: esbuild bundle of the worktree helper compared with CPython `repr` over 12 values; 11 identical (apostrophe, both quotes, backslash plus apostrophe, nested list, curly apostrophe), 1 different (newline). |
| Info | `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` | tolerated entry without estimates | Carried from the prior review and accepted as out of scope by the cycle inputs: a hand-written tolerated entry without `cost`/`benefit` produces the message "merge time 0 min does not exceed parallel gain 0 min". | None required. | Message quality only; the engine always returns both estimates. | `remediation-inputs.2026-11-11T04-47.md` `## Out of scope (accepted, no change)`. |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | `Invoke-ParallelAdmissionPrecedenceTest` | Carried from the prior review and accepted as out of scope: `test-precedence` resolves `config/blast-radius.json` relative to the current location and fails loudly elsewhere. | None required. | Matches the helper's existing convention. | Same inputs section. |

No Blocker, Major, or Minor finding. No covered file reaches 700 logical lines (largest: `Invoke-ParallelAdmission.ps1`, 687), so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- `weigh` and the second assertion of `test_no_access_lists_match_legacy_weight` now exercise `pair_cost`, the public entry point. The test therefore also pins the radius-pair aggregation that callers use.
- `single_path_radius` builds a declared `BlastRadius` with tuple fields and no modules, shared surfaces, or contracts, so the cost equals the single path-pair weight.

#### Typing and API notes

- Typed helper signatures; no suppression comment remains in the file. Pyright 0 errors (`python-static.2026-11-12T12-34.md`).

#### Error handling and logging

- No Python production change in this cycle.

### PowerShell implementation audit (if applicable)

#### What changed well

- The write-word set is built once at module scope from `$script:WriteTitleVerb`, so a verb added later gains its inflections automatically.
- `Test-WriteTitleWord` is private, typed, and documented; `Test-ReadOnlyWindowSet` calls it in place of the list test.

#### API and safety notes

- The set is a superset of the former list, so no path classified as written before the change becomes read-only.
- Constructs are PowerShell 5.1 compatible (`[HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)`).

#### Error handling and logging

- No new error path. The R4 case asserts the existing `precedence_not_justified` throw with the default band gain of 30 minutes.

### TypeScript implementation audit (if applicable)

- `pythonRepr` escapes backslashes first, then single quotes only in the single-quote branch. That is correct because the double-quote branch is taken only when the value holds no double quote. The JSDoc `@returns` states the rule.
- The change can only improve parity for every validator that imports this helper, because the Python side always uses CPython `repr`. Jest 5502 passed with no expected-string edits elsewhere.

### C# implementation audit (if applicable)

- N/A: no C# file in the branch diff.

---

## Test Quality Audit

The cycle's new cases discriminate:
- R1: the three stems carry the CPython strings, and the former helper's output (`'docs/it\'s.md'`) differs from them.
- R3: every write-form case starts with the read verb `Run`, so the former list classified the path as read-only and the assertion of zero derived paths would fail.
- R4: the case asserts the exact default-band gain in the throw message.

The reviewer judged discrimination by fixture and code inspection plus real-process probes, not by reverted-mutant test runs, because the owner's parallel-only rule excludes single-file runs.

### Reviewed test and QA artifacts

- `evidence/qa-gates/pester-gate.2026-11-12T13-00.md`, `pytest-gate.2026-11-13T13-51.md`, `jest-gate.2026-11-13T13-52.md`
- `evidence/qa-gates/powershell-static.2026-11-12T12-34.md`, `python-static.2026-11-12T12-34.md`, `typescript-static.2026-11-12T12-35.md`
- `evidence/qa-gates/self-review.2026-11-13T13-53.md`
- `evidence/remediation-baseline/*.2026-11-11T*.md`

### Quality assessment prompts

- Do the tests discriminate? Yes, as stated above.
- Are legacy inputs covered? `accept-without-fields.json` and the unchanged `seed-scheduling-record.json` pin remain; the existing rows of `test_blast_radius_access_weights.py` keep their expected weights.

---

## Security / Correctness Checks

- No absolute path or host name in the new fixtures or cycle evidence (scratch locations are recorded as `SCRATCH`).
- Declared radii are never narrowed: access lists remain members of `blast_radius.paths` (validator rule B10.1).
- No agent `tools:` frontmatter line changed (0 `+tools:`/`-tools:` lines in the diff of `.claude/agents/`).
- No new suppression in the added lines of the branch diff apart from the pre-existing-pattern `shellcheck disable=SC1091` in the two bash copies.

---

## Research Log

- Read the cycle inputs, plan, final-QA evidence, cycle baselines, and the prior review set.
- Reviewed the remediation commit diff `e2d42d831^1..e2d42d831` and the full branch diff `1d62aa292..90d84af13`; confirmed that `01547c4c7..HEAD` changes only feature-folder files.
- Parsed the three canonical coverage artifacts for per-file and repo-wide figures.
- Bundled the worktree `parallel-state-shared.ts` with esbuild and compared `pythonRepr` with CPython `repr` over 12 values.
- Ran real-process `access-paths` probes on the item's plans and on a six-title scratch plan.

---

## Verdict

**Go.** Zero blocking findings. R1 to R4 are resolved. Five Info observations remain: two new code rows (irregular write forms; control-character `repr` divergence), one evidence row closed in review (root TypeScript coverage report), and two rows carried and accepted. None requires a remediation cycle.
