# Feature Audit — cycle 4 exit re-audit (Issue #500)

**Authored:** 2026-08-23T04-45 by feature-review.
**Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `8db37795`
**Base:** `main` @ `bee15c06` (merge-base). Audit scope is the full branch diff.
**Work mode:** `full-bug` (`issue.md:12`) → AC source is **`spec.md` only**.
**AC section:** `spec.md` lines 421-523.

## Verdict

**blocking_count: 0.** Overall recommendation: **Go**.

## Acceptance Criteria Roll-Up

**17 total, 17 checked in `spec.md`.** Confirmed by count: checkbox lines within the
`## Acceptance Criteria` section are at 423, 427, 434, 440, 447, 453, 458, 464, 470, 481, 488, 493, 500,
505, 509, 516, 518 — seventeen, all `- [x]`. The checkboxes at lines 44-47 and 80 are triage severity and
repro-evidence markers outside the AC section and are correctly not counted.

| Verdict | Count |
|---|---|
| PASS | 17 |
| PARTIAL | 0 |
| FAIL | 0 |
| UNVERIFIED | 0 |

No checkbox was changed by this reviewer; all seventeen were already `- [x]` and all seventeen verify.

## Per-Criterion Evaluation

Each row records how I verified it, not what the evidence claims. "Perturbation C/D" refer to the
reviewer battery recorded in `policy-audit.2026-08-23T04-45.md`.

| # | Line | Criterion (abbreviated) | Verdict | Verification performed |
|---|---|---|---|---|
| AC1 | 423 | `PAYLOAD_MODULES` is `{ config: ["config/**"] }`, no `claude-runtime`, `@remarks` states why `.claude` is not a module | **PASS** | Read the diff of `claude-blast-radius-derive-core.ts`: the `"claude-runtime": [".claude/**"]` line is deleted and a 15-line `@remarks` block added stating the granularity criterion, what is not weakened, and why `config` is retained. TypeScript suite 195/195 suites, 2657/2657 tests green on an independent run. |
| AC2 | 427 | `blast-radius-derive-core.test.ts` no longer positively pins `claude-runtime`; the forbidden-glob case asserts key-set exclusion and no `FORBIDDEN_GLOBS` member | **PASS** | `grep -n "claude-runtime"` on the file returns exactly two hits, both inside the *negative* case at lines 472-477: a comment and `expect(names).not.toContain("claude-runtime")`. No positive pin remains. The case `declares no umbrella or forbidden glob in the payload module set` (line 466) carries both assertions, including the `for (const forbidden of FORBIDDEN_GLOBS)` loop. |
| AC3 | 434 | `blast-radius-derive.test.ts` seeded maps updated; `config-carriage.test-helpers.ts` `SOURCE_BLAST_RADIUS` and its doc comment mirror the corrected bundled file | **PASS** | Read `SOURCE_BLAST_RADIUS` at `config-carriage.test-helpers.ts:86-108`: it declares the identical 6-entry portable `shared_surfaces`, `shared_surface_globs: []`, and all ten `mandate_reads` entries present in the committed bundled file. Field-by-field match against `cat` of the bundled config. Jest green. |
| AC4 | 440 | Bundled config declares the exact 6-entry portable `shared_surfaces`, `shared_surface_globs` `[]`, four added `mandate_reads`, `modules` exactly `{config: [config/**]}` | **PASS** | Read the file directly: all four properties hold exactly. Falsifiability established by **perturbation C** (dropping `poetry.lock` and reinstating `claude-runtime` fails the Class 2 portable-set equality and the Class 3 payload subset) and **perturbation D** (dropping `package-lock.json` fails Class 2). |
| AC5 | 447 | `claude-config-carriage.test.ts` AC8 forbidden-substring list no longer forbids `poetry.lock` or `package-lock.json`, with a stated rationale | **PASS** | `grep` confirms the only occurrences of both filenames in the file are inside the rationale comment at lines 315-316, which states the exclusion targets "entries naming this repository's directory layout rather than ecosystem-standard root lockfile names". Neither string is in the forbidden list. Jest green. |
| AC6 | 453 | `config/blast-radius.json` `mandate_reads` carries the four added entries; `shared_surfaces`, `shared_surface_globs`, `modules` otherwise unchanged | **PASS** | `git diff bee15c06...HEAD -- config/blast-radius.json` is a pure 4-line addition to `mandate_reads` (`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/agent-memory/**`, `.agents/skills/**`) and touches nothing else. Class 1 byte-equality falsifiable — perturbation C's `mandate_reads` edit fails `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` in Python and `declares equal values for the runtime-describing keys in both copies` in Pester. |
| AC7 | 458 | `.claude/rules/parallel-orchestration.md` records (a) derived map / bundled `modules` not consumed, (b) `PAYLOAD_MODULES` carries `config` only and `claude-runtime` is disqualified, (c) portable-subset sets with the surfaces/modules asymmetry as the reason | **PASS** | All three located by name in the Blast-Radius Contention Doctrine section: (a) line 268 "A destination's module map is DERIVED, so the bundled `modules` key is not consumed."; (b) line 277 "`PAYLOAD_MODULES` carries `config` only."; (c) line 286 "The bundled `shared_surfaces` and `shared_surface_globs` sets are the destination-portable subset…", followed by the asymmetry paragraph ("An over-matching MODULE glob costs concurrency on every pair… A SURFACE or mandate-read entry naming a path the destination lacks is inert"). |
| AC8 | 464 | The published copy of the rule file is byte-identical after the amendment, same commit | **PASS** | `cmp` → **exit 0**. `sha256sum` on both → `cd5d1a971f838f71cb429ee4a170581bd9bf8cd9ed2142d3f00b92a49219f8e4`, identical. `git show --stat 71641d9c` confirms both copies changed in the same commit. |
| AC9 | 470 | `test_blast_radius_config_parity.py` carries the three-class gate, imports helpers from `test_blast_radius_config.py`, holds constants in the `blast_radius_parity_test_support.py` sibling (PD-1) | **PASS** | Read both modules. Class 1 parametrized over `BYTE_EQUAL_KEYS` (line 183), Class 2 portable-set equality plus subset (242) and empty globs (273), Class 3 payload subset (336). The support module imports `BUNDLED_CONFIG_PATH`, `CONFIG_PATH`, `load_config_file`, `load_module_globs` from `test_blast_radius_config` and declares no assertion, matching its stated contract. Sibling module 249 lines; parity module 499 lines (see policy-audit **I4**). |
| AC10 | 481 | Five disqualified umbrella names denied in both copies; every separator-free bundled `shared_surfaces` entry wildcard-free; non-vacuity floor with `COMMITTED_CONFIGS` at exactly two members and each intended-non-empty collection non-empty | **PASS** | `test_no_committed_copy_declares_an_umbrella_module` parametrized over both copies (line 382); `UMBRELLA_MODULE_NAMES` holds exactly the five names. `test_every_separator_free_bundled_shared_surface_is_wildcard_free` at 403. `test_the_gate_compares_non_empty_collections` at 431 asserts `len(COMMITTED_CONFIGS) == 2` and non-emptiness of six named collections plus `mandate_reads` in both copies. Falsifiable: perturbation C fails the umbrella denylist for the bundled copy in Python and `declares no removed umbrella module in either committed copy` in Pester. |
| AC11 | 488 | `BlastRadius.KeyPartition.Tests.ps1` mirrors the Class 1 equality; `BlastRadius.TruthTable.Tests.ps1` mirrors the Class 3 subset, the five-name umbrella denylist over both copies, and the separator-free-wildcard-free assertion; both files under 500 lines | **PASS** | See the dedicated section below. Every named case resides in the file the criterion names, and both files measure 268 and 325 lines. |
| AC12 | 493 | The comment in `declares no removed umbrella module in either committed copy` no longer states the bundled map describes the destination's subsystems, and records that the bundled `modules` key is never read and `PAYLOAD_MODULES` is the live source | **PASS** | Read the comment at `BlastRadius.TruthTable.Tests.ps1:92-104`. It records both required statements ("The bundled base document's module map is never read: a destination's map is derived from the destination's OWN layout by assembleModules, and PAYLOAD_MODULES … is the live source"). The phrase "describes the destination repository's subsystems" survives only inside the corrective sentence that names it as the *former* comment "which was not true". The criterion's requirement — that the comment no longer *states* it — is met. |
| AC13 | 500 | Fail-closed regression test: two radii from plan text citing unrelated `.claude/**` files report `conflict=False`; fail-before under `evidence/regression-testing/`, pass-after under `evidence/qa-gates/` | **PASS** | `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` (line 114) passes at `HEAD` and **fails under perturbation C** the moment `claude-runtime` is reinstated in the bundled module map — the exact defect state the criterion covers. This is the strongest available evidence for a regression test and it was obtained independently of the recorded fail-before artifacts. Both evidence locations populated: `evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md` and `evidence/qa-gates/powershell-fail-closed-pass-after.2026-08-22T00-10.md`. |
| AC14 | 505 | Fail-open regression test: two items citing the same separator-free root surface report `conflict=True`, with `Get-ConfigRootSurface` returning a non-empty set; evidence in the same two locations | **PASS** | `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` (line 146) passes at `HEAD` and **fails under perturbation D**, when `package-lock.json` is dropped from the bundled `shared_surfaces`. Evidence: `evidence/regression-testing/powershell-fail-open-repro.2026-08-21T23-12.md` and `evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md`. |
| AC15 | 509 | Coverage: Python line >= 85% and branch >= 75%; TypeScript line >= 85% and branch >= 75%; PowerShell line >= 85% with the branch exemption; no regression on changed lines; no `exclude` entry added | **PASS** | Independently measured. Python: statements 92.6033%, branches 85.1859%, combined 90.6105%. TypeScript: lines 96.66%, branches 90.04%; the one modified production file at 100% lines / 95.83% branches. PowerShell: LINE 96.18% with no branch threshold applied. No production Python or PowerShell changed on the branch, so no changed-line regression is possible; the modified TypeScript file is at 100%. No `exclude` entry added anywhere in the diff. Two evidence-quality caveats recorded as policy-audit **M3** and **M5**; neither alters the verdict, since every figure clears its threshold under every measurement taken. |
| AC16 | 516 | Full toolchain pass in a single run for all three languages | **PASS** | Reproduced end to end by the reviewer at `8db37795` with a clean tree: black `440 files unchanged`; ruff `All checks passed!`; pyright `0 errors, 0 warnings, 0 informations`; pytest `4079 passed, 5 skipped`; prettier clean; eslint clean; tsc clean; jest `2657 passed`; PoshQC format clean, PSScriptAnalyzer no findings, Pester `3362 passed, 0 failed, 9 skipped` (3371 total). All stages green; no stage rewrote a file. |
| AC17 | 518 | `git log --follow` captured for both copies of `config/blast-radius.json` confirming the divergence mechanism; `Get-FileHash` byte compare of the `orchestration-routing.json` pair independent of its TypeScript test | **PASS** | Both artifacts present: `evidence/other/divergence-commit-walk.2026-08-21T21-47.md` and `evidence/other/routing-pair-byte-compare.2026-08-22T00-14.md`. The recorded routing-pair digest `D9C6657CBDBE15413E0FB9BC1BE700CE1A8F892D0DB413C3BBC253EA24EA7BDA` was independently re-measured at `HEAD` with `sha256sum`: both files return `d9c6657cbdbe15413e0fb9bc1be700ce1a8f892d0db413c3bbc253ea24ea7bda`. Still byte-identical. |

## AC11 — verified case by case, as required

The brief asked specifically whether each case AC11 names actually resides in the file AC11 names. AC11
was unchecked, its text corrected, and re-checked during this cycle, so its text is the thing most in
need of independent confirmation.

Corrected text (`spec.md:488-492`): "`BlastRadius.KeyPartition.Tests.ps1` mirrors the Class 1 equality;
`BlastRadius.TruthTable.Tests.ps1` mirrors the Class 3 subset, the five-name umbrella denylist applied
to both copies, and the separator-free-wildcard-free assertion; and both files stay under the 500-line
limit."

| Named mirror | Attributed file | Actual location | Match |
|---|---|---|---|
| Class 1 equality | `BlastRadius.KeyPartition.Tests.ps1` | `It 'declares equal values for the runtime-describing keys in both copies'` — **KeyPartition line 68** | yes |
| Class 3 subset | `BlastRadius.TruthTable.Tests.ps1` | `It 'declares only payload modules in the bundled copy'` — **TruthTable line 123** | yes |
| Five-name umbrella denylist, both copies | `BlastRadius.TruthTable.Tests.ps1` | `It 'declares no removed umbrella module in either committed copy'` — **TruthTable line 91**; the loop at 111 walks `@($script:CommittedConfig, $script:BundledConfig)` | yes |
| Separator-free-wildcard-free | `BlastRadius.TruthTable.Tests.ps1` | `It 'gives every separator-free bundled shared surface no wildcard'` — **TruthTable line 218** | yes |
| Both files under 500 lines | both | `wc -l`: KeyPartition **268**, TruthTable **325** | yes |

Full `It` inventories were enumerated with `grep -nE "^\s*(It\|Context\|Describe) "` on both files to
confirm no named case sits in the other file. **AC11 is now true.** The four attributions are also
falsifiable rather than merely present: perturbation C fires the Class 1 equality in KeyPartition and
both the umbrella denylist and the Class 3 subset in TruthTable, in one run.

AC11 does not enumerate Class 2 on the PowerShell side, and correctly so — the Class 2 keys are
consumed in `BlastRadius.TruthTable.Tests.ps1` (verified: `['shared_surfaces']` at lines 171, 180, 209,
227, 259; `['shared_surface_globs']` at 172, 193) and the criterion does not claim to be an exhaustive
inventory.

One procedural note, recorded as policy-audit **I6**: the plan's uncheck (P2-T2) and re-check (P5-T14)
both landed inside commit `71641d9c`, so the net diff for that line is `[x]` → `[x]` with only the text
changed. The intermediate unchecked state is not observable in history. The procedure was followed; it
simply leaves no trace.

## Cycle-4 Remediation Items — closure status

`remediation-inputs.2026-08-22T17-20.md` enumerates R1 through R6; the task brief describes the same work
as R1 through R5. The numbering differs between the two documents and no item was dropped (policy-audit
**I8**). Status against the *inputs* numbering, which is authoritative:

| Item | Severity in inputs | Status | Verification |
|---|---|---|---|
| **R1** — close or withdraw CR-3 (option A: assert consumption) | Major | **CLOSED** | Independently reproduced by construction. Registering an unconsumed key against a real assertion, with the key present in both committed copies, produces exactly one Python failure and exactly one Pester failure. The exhaustiveness gate passed, confirming the silent-pass path CR-3 named is the path now caught. Residual boundary characterized as policy-audit **I1**/**I2**. |
| **R2** — resolve the AC11 discrepancy | Major | **CLOSED** | AC11's text amended along the preferred route (attribute each mirror to its actual file rather than reverse part of the split). Every attribution verified above. |
| **R3** — retire the four stale pointers | Major | **CLOSED** | `grep "BlastRadius.TruthTable.Tests.ps1"` on both rule copies → exit 1, no hits. `grep "BlastRadius.KeyPartition.Tests.ps1"` → exactly four, two per copy at lines 310 and 319. `cmp` exit 0; matching sha256. Both edits in one commit. |
| **R4** — correct the "verbatim" claim | Minor | **CLOSED, with a new defect in the same block** | `grep -n "verbatim"` → exit 1, no hit. The rewritten `.DESCRIPTION` accurately records three cases moved unchanged, one renamed and rewritten, and a fifth added. **But** its read inventory was not updated for the new case's third-file read (policy-audit **M2**), and the line immediately below it still claims the file received TruthTable's `Describe` (policy-audit **M1**). |
| **R5** — distinguish the two Pester files by `Describe` | Minor | **CLOSED** | `grep -n "^Describe "`: TruthTable `'Committed blast-radius truth table shape'`; KeyPartition `'Committed blast-radius truth table cross-copy key partition'`. Distinct. Directory run still reports 384 passed. A failure path now identifies the file. |
| **R6** — record the Python floor's mechanism | Minor | **CLOSED, partially** | The docstring at `test_blast_radius_config_parity.py:431` now names both upstream functions and their `TypeError`, satisfying R6's stated purpose ("naming the upstream functions makes the coverage claim checkable"). It drops R6's requested "six of those at module import" and "seven remaining states" counts in favour of "Most tested cells" / "only the remaining states". Recorded as policy-audit **I7**, not reopened. |
| **R5 method** — hash-based restore verification | (instruction) | **SATISFIED** | `evidence/other/r1-pre-perturbation-hashes.2026-08-23T02-59.md` records external pre-perturbation hashes and `evidence/qa-gates/r1-post-restore-hash-verification.2026-08-23T02-59.md` records the comparison. Independently corroborated: the recorded hash for `blast_radius_parity_test_support.py` (`888CEB51…FEE12`) is byte-identical to my own measurement of that file at `HEAD`. |
| **PRE-1** — `fix_all` cross-thread race | (out of scope) | **FILED** | Issue #505, per the caller. Not re-raised. |

Every "Do not do" constraint in the remediation inputs was honoured: no production file touched
(independently verified — `git diff eeadf582..HEAD` over `scripts/dev_tools/`,
`extensions/drm-copilot/src/`, and `test_blast_radius_config.py` is empty); no assertion weakened,
deleted, or narrowed (the three membership assertions option B would have removed are still present);
no rule amendment beyond the four pointer strings; no evidence artifact renamed; no acceptance criterion
other than AC11 edited (`git diff eeadf582..HEAD -- spec.md` touches exactly AC11's four lines).

## Regressions Against Baseline

None. Comparison of the reviewer's independent run against the recorded Phase-0 baselines:

| Metric | Baseline | At `HEAD` | Delta |
|---|---|---|---|
| Python tests | 4078 passed, 5 skipped | 4079 passed, 5 skipped | +1 (the new consumption test) |
| Python statement coverage | 92.60% | 92.60% | 0.00 |
| Python branch coverage | 85.19% | 85.19% | 0.00 |
| Pester tests | 3370 total, 3361 passed, 9 skipped | 3371 total, 3362 passed, 9 skipped | +1 (the new Pester case) |
| Pester line coverage | 96.47% recorded / 96.18% independently measured | same tool path, same figure | 0.00 (see policy-audit **M5** on denominator stability) |
| TypeScript tests | 2657 passed, 195 suites | 2657 passed, 195 suites | 0 (cycle 4 touched no TypeScript) |
| Skipped-test counts | 5 Python / 9 Pester | 5 Python / 9 Pester | unchanged; both pre-existing |

The +1 in each of Python and Pester matches exactly the one case added per language by R1. No test was
removed, disabled, or skipped by this branch.

## Cycle-4 Scope Containment

Independently verified for adjudication (a).
`git diff eeadf582..HEAD --stat -- scripts/dev_tools/ extensions/drm-copilot/src/ tests/scripts/dev_tools/test_blast_radius_config.py`
→ **no output**. Cycle 4's 31 changed files comprise: `.claude/rules/parallel-orchestration.md` and its
published copy, `spec.md`, `remediation-plan.2026-08-22T18-05.md`,
`tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`,
`tests/scripts/dev_tools/blast_radius_parity_test_support.py`,
`tests/scripts/dev_tools/test_blast_radius_config_parity.py`, twenty evidence artifacts, and the four
relocations in `8db37795`. Nothing production, nothing outside the declared scope. **The substantive
property P5-T12 was meant to assert is true.**

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none
```

No checkbox was modified by this reviewer. All seventeen were already checked and all seventeen were
independently verified to PASS, so no check-off or un-check action was required under
`acceptance-criteria-tracking`.

Plan-task status, for completeness (plan tasks are not acceptance criteria and do not enter the roll-up):
`remediation-plan.2026-08-22T18-05.md` has 56 tasks checked and **one** unchecked, P5-T12, deliberately
and with recorded evidence. Adjudicated as the correct disposition in `policy-audit.2026-08-23T04-45.md`.

## Recommendation

**Go.** Seventeen of seventeen acceptance criteria PASS on independent verification, every one of them
falsifiable against the property it asserts. All six enumerated cycle-4 remediation items are closed,
R1 by construction rather than by reading. `blocking_count` is zero, so the exit gate is satisfied and
no fifth cycle is warranted.

Five Minor findings and ten Info observations are recorded in
`policy-audit.2026-08-23T04-45.md` and `code-review.2026-08-23T04-45.md`. None gates the merge. The two
worth folding into the next commit that touches the file are M1 and M2 — both stale prose in the same
comment block of `BlastRadius.KeyPartition.Tests.ps1`, one edit, verified by re-running the Pester
directory. The remaining three (M3, M4, M5) are evidence-quality and suppression-policy items with no
effect on shipped behaviour.
