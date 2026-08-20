# Coverage Delta and Threshold Assertion [P7-T11]

Timestamp: 2026-08-20T20-44

Sources:
- Baseline: `evidence/baseline/baseline-ts-jest-coverage.2026-08-20T18-54.md` (P0-T15) and `evidence/baseline/baseline-py-pytest-coverage.2026-08-20T18-54.md` (P0-T19).
- Post-change: `evidence/qa-gates/final-ts-jest-coverage.2026-08-20T20-24.md` (P7-T5) and `evidence/qa-gates/final-py-pytest-coverage.2026-08-20T20-41.md` (P7-T9, iteration 4).
- Per-file and changed-line TypeScript figures: the `SF:`/`LF:`/`LH:`/`BRF:`/`BRH:`/`DA:`/`BRDA:` records in `extensions/drm-copilot/coverage/lcov.info`, produced by the P7-T5 run. `text-summary` reports global totals only and is not a sufficient source for the per-file requirement.
- Per-file Python figures: the `term-missing` per-file rows produced by P7-T9.

Uniform thresholds (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`): **line >= 85%**, **branch >= 75%**, and **no regression on changed lines**.

---

## Global Coverage — TypeScript

| Metric | Baseline | Post-change | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Lines | 96.65% (42960/44447) | **96.66%** (43055/44542) | **+0.01 pp** | >= 85% | **PASS** |
| Branches | 90% (6099/6776) | **90.04%** (6122/6799) | **+0.04 pp** | >= 75% | **PASS** |
| Statements | 96.65% (42960/44447) | 96.66% (43055/44542) | +0.01 pp | — | — |
| Functions | 89.65% (1257/1402) | 89.67% (1259/1404) | +0.02 pp | — | — |
| Test suites | 193 | 195 | +2 | — | — |
| Tests | 2645 | 2654 | +9 | — | — |

## Global Coverage — Python

| Metric | Baseline | Post-change | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Lines | 92.60% (13818/14923) | **92.60%** (13834/14939) | **0.00 pp** | >= 85% | **PASS** |
| Branches | 89.80% (4921/5480) | **89.81%** (4929/5488) | **+0.01 pp** | >= 75% | **PASS** |
| Tests passed | 4059 | 4062 | +3 | — | — |
| Tests failed | 0 | 0 | 0 | — | — |

Both languages hold or improve on both gated metrics. No global regression.

---

## Per-File Coverage — the Four Production Files

### TypeScript (from `lcov.info`)

| File | LF | LH | Line % | BRF | BRH | Branch % | Line >= 85% | Branch >= 75% |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `src/lib/new-active-feature-folder/flow.ts` | 492 | 490 | **99.59%** | 90 | 84 | **93.33%** | PASS | PASS |
| `src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | 164 | 164 | **100.00%** | 14 | 14 | **100.00%** | PASS | PASS |
| `src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 209 | 209 | **100.00%** | 18 | 15 | **83.33%** | PASS | PASS |

### Python (from the `term-missing` per-file row)

| File | Stmts | Miss | Line % | Branch | Partial | Branch % | Line >= 85% | Branch >= 75% |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/new_active_feature_folder_flow.py` (baseline) | 135 | 12 | 91.11% | 52 | 6 | 88.46% | — | — |
| `scripts/dev_tools/new_active_feature_folder_flow.py` (post-change) | 151 | **12** | **92.05%** | 60 | **6** | **90.00%** | PASS | PASS |

The Python per-file figures **improve**: the measured surface grows by 16 statements and 8 branches while the missing count (12) and partial count (6) are unchanged from baseline.

---

## Changed-Line Coverage — the Decisive Check

Changed line ranges were taken from `git diff -U0 ffa03095c9a338695be47974ebe150be245ee3b3 -- <file>` (post-change line numbering) and compared against the uncovered records for each file.

### `flow.ts` — changed ranges 175-180, 289-293, 347-348, 352-358, 362-366, 372-376, 446-469

Uncovered lines in the whole file (`DA:<n>,0`): **388, 389** only.
Uncovered branches in the whole file (`BRDA:<n>,...,0`): **103, 104, 162, 387, 479, 491** only.

**No uncovered line and no uncovered branch falls inside any changed range.** Changed-line coverage for `flow.ts` is **100% line and 100% branch**.

Lines 387-389 are the pre-existing `if (fallbackReason) { emit(...) }` block, which the file's own comment documents as never emitted (the variable is retained for Python parity). It is unchanged by this work.

### `new-active-feature-folder-service-call.ts` — changed ranges 105-122, 126-129, 137, 146-153

`LH == LF` (164/164) and `BRH == BRF` (14/14): the file has **no uncovered line and no uncovered branch at all**, so changed-line coverage is necessarily **100% line and 100% branch**. Both arms of the new post-condition are exercised by the P1-T6 cases.

### `potential-to-issue-service-call.ts` — changed ranges 159-162, 168, 187-199

`LH == LF` (209/209): no uncovered line anywhere, so changed-line **line** coverage is **100%**.

The three uncovered branches are at lines **178, 205, 207**, all outside the changed ranges:
- `178` — the `outcome.messages.length > 0` ternary inside the pre-existing non-zero-exit throw.
- `205` and `207` — the pre-existing `outcome.destination === undefined ? {} : ...` and `issueUrl === null ? {} : ...` spread ternaries in the return record.

The branch records covering the added post-condition (`BRDA:194,12,0,2` and `BRDA:199,13,0,12`) both carry non-zero hit counts, so changed-line **branch** coverage is **100%**.

### `new_active_feature_folder_flow.py` — changed ranges 43-65, 138-143, 235-238, 295-300, 303-306, 312-315

Missing after the final run: `96->99, 117, 294->317, 322, 324->335, 328->335, 399-416`.

Mapping each against the changed ranges:

| Missing record | Inside a changed range? | What it is |
| --- | --- | --- |
| `96->99` | No | Pre-existing partial branch in the auto-resolve block (baseline analogue `73->76`) |
| `117` | No | Pre-existing uncovered statement (baseline analogue `94`) |
| `294->317` | No — line 294 is the pre-existing `if potential_issue_path is not None:` | Pre-existing partial branch (baseline analogue `262->274`) |
| `322` | No | Pre-existing `print(f"Fallback reason: ...")`, never reached (baseline analogue `279`) |
| `324->335`, `328->335` | No | Pre-existing launcher-path partial branches (baseline analogues `281->292`, `285->292`) |
| `399-416` | No | Pre-existing CLI `main()` region (baseline analogue `356-373`) |

**No missing record falls inside any changed range.** Changed-line coverage for `new_active_feature_folder_flow.py` is **100% statement and 100% branch**.

This required a loop iteration to achieve. At Python loop iteration 3 the missing set included `236` and `298` — the minor-audit `filesystem.copy_file(...)` call and its `Copied potential file to ...` emission, both **newly added by P4-T2 and P4-T4** and both inside changed ranges. That is a changed-line coverage regression and a blocking finding under `.claude/rules/python.md`, notwithstanding the run's zero exit code. `test_create_minor_audit_folder_copies_promoted_potential` was added to cover that placement site, the loop restarted, and iteration 4 shows the missing and partial counts back at their baseline values of 12 and 6.

---

## No-Regression-on-Changed-Lines Assertion

**Asserted and satisfied.** Across all four production files, every added or modified line and every added branch is covered by at least one test. The changed-line coverage is 100% line and 100% branch in each file, so no changed line lost coverage relative to baseline and none was introduced uncovered.

---

## Threshold Enforcement Note

**`jest.config.cjs` carries no `coverageThreshold` entry for any of the four production files.** Its `coverageThreshold` block (beginning at `jest.config.cjs:25`) lists per-file entries for unrelated modules — the only `*service-call.ts` entry is `./src/lib/validate/validate-orchestration-service-call.ts`, and there is no entry matching `flow.ts`, `new-active-feature-folder-service-call.ts`, or `potential-to-issue-service-call.ts`.

The runner therefore does **not** enforce the 85/75 gate on these files. The gate is asserted **manually in this artifact**, from the `lcov.info` records, and every file passes with margin. The narrowest figure is the 83.33% branch coverage of `potential-to-issue-service-call.ts`, which clears the 75% branch threshold by 8.33 points and whose three uncovered branches are all pre-existing and outside the diff.

This is recorded explicitly so a later reader does not mistake a green runner for runner-enforced per-file thresholds on these files.

---

## Tier Classification

**`quality-tiers.yml` is absent at the repository root**, confirmed by the recursive search at P0-T10 (`SearchPatterns: quality-tiers.y*ml`, `SearchResult: none`, exit 0) and unchanged by this work. No T1–T4 classification therefore applies to any of the four production files.

The uniform gates still bind and are all satisfied above: format 100% pass, 0 lint errors, 0 type errors, line >= 85%, branch >= 75%, and no regression on changed lines. The tier-dependent gates (property-test density, mutation score, untyped-escape-hatch limits, determinism retry rate, golden tests, E2E scope) have no classification source and cannot be evaluated. Creating `quality-tiers.yml` is out of scope for this bug fix.

---

## Verdict

**PASS.** Every required numeric value is present; none is a placeholder. Global line and branch coverage hold or improve in both languages, all four production files clear both uniform thresholds individually, and changed-line coverage is 100% line and 100% branch in every one of them.
