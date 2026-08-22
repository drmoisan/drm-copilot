# Remediation Inputs: blast-radius bundled truth-table correction (#500)

**Timestamp:** 2026-08-22T02-58
**Authored by:** feature-review
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Base Branch:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
**Head:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `a95ae362`
**Work Mode:** `full-bug`; acceptance-criteria source is `spec.md` only
**Cycle:** 2

---

## Trigger

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8 by the condition "required acceptance criteria are FAIL or PARTIAL". One of the seventeen acceptance criteria in `spec.md` was evaluated PARTIAL and has been unchecked by this review.

No other trigger condition fired:

- **Toolchain checks did not fail.** All eleven runnable stages across Python, TypeScript, and PowerShell passed in a single uninterrupted reviewer-executed pass at head `a95ae362`, recorded in `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T02-58.md`.
- **Coverage did not regress and no threshold was breached in any language.** Python 92.60% statements and 85.19% branches; TypeScript 96.66% lines and 90.04% branches; PowerShell 96.21% lines with no branch counter emitted by Pester. Every delta against the Phase 0 baseline is 0.00. The one changed production file reads 100.00% lines and 95.83% branches.
- **No coverage artifact is absent** for any language with changed files. `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, and `artifacts/pester/powershell-coverage.xml` were all regenerated at head during this review.
- **The `modified-workflow-needs-green-run` rule did not fire.** Zero changed paths match `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`.
- **No evidence-location violation exists.** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0, and the diff writes nothing under a forbidden `artifacts/` evidence path.

**Blocking findings: 1.** The remediation below is documentation-only. No source code, no configuration data, and no test logic requires change to clear the blocking finding.

---

## Cycle 1 Disposition

Cycle 1 enumerated six items. Five are delivered in substance and one is delivered with a residual overclaim. Each was verified independently in this re-audit rather than accepted from the artifacts.

| Item | Cycle-1 severity | Disposition | Verification performed in this re-audit |
|---|---|---|---|
| R1 | Blocking | **Delivered** | AC9 names `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, states the import relationship, names the sibling constants module, and records PD-1 and the 499-line ceiling. The cited command reported `15 passed` at exit 0 and collects every assertion the criterion enumerates. Re-checking is warranted. |
| R2 | Blocking | **Delivered** | AC10 restates the file name explicitly rather than relying on the anaphor, and cites the same command. All three assertions it names are collected by that command. |
| R3 | Minor | **Delivered with a residual overclaim** | The sentence now separates the Class 1 and Class 2 claims correctly. Its closing clause "the residual gap is closed structurally by ..." is unqualified where the closure is restricted to separator-free entries. Carried forward as R8 below. |
| R4 | Minor | **Delivered and general within its stated scope** | Injecting `Directory.Build.props` into the self-hosted `shared_surfaces` fails the Python case with `assert not ['Directory.Build.props']` and the Pester case with `Expected $null or empty, but got 'Directory.Build.props'`. The two mirrors compute the same relation over the same two subsets and fail on the same witness. The rule and its byte-identical bundled mirror both record the invariant. |
| R5 | Minor | **Delivered** | Following the corrected command description verbatim reproduced 56 items, 1540 pairs, 1182 edges, 31 cohorts post-change and 1199 edges, 33 cohorts pre-change, matching the artifact exactly. |
| R6 | Minor | **Delivered** | The `-InputObject` form distinguishes a single-element list from a bare scalar, measured directly. The empty-list against absent-key half of the recorded rationale did not hold under the pipeline form either, so only one of the two stated reasons was real; the correction is sound regardless. |

Cycle 1's exit conditions 1, 2, and 4 are met. Conditions 3 and 5 are not, because of the single finding below.

---

## Enumerated Fix List

### R7 — Blocking. Correct the AC4 criterion text so it names the file that carries the assertions

**File:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`, `## Acceptance Criteria`, the fourth checkbox item, at line 435, currently ending:

```
      the four added entries; and `modules` is exactly `{ "config": ["config/**"] }`. Verified by
      the Class 2 and Class 3 assertions of the new gate in
      `tests/scripts/dev_tools/test_blast_radius_config.py`.
```

**Observed defect:** the criterion names `tests/scripts/dev_tools/test_blast_radius_config.py` as the file carrying the Class 2 and Class 3 assertions of the new gate. That file is untouched by the branch, stands at 499 lines, contains no Class 2 or Class 3 assertion, and collects 32 cases none of which belongs to the gate. Both classes live in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, delivered under plan deviation PD-1. This is the identical defect cycle 1 recorded as R1 against AC9 and R2 against AC10. The remediation corrected the two criteria the cycle-1 inputs enumerated and left the third instance, because the inputs did not enumerate it. That omission is this reviewer's, not the executor's.

**Expected behavior after the fix:** the criterion's trailing sentence reads "Verified by the Class 2 and Class 3 assertions of the new gate in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`." Everything before that sentence is unchanged: the six named `shared_surfaces` entries, the empty `shared_surface_globs`, the four added `mandate_reads` entries, and the exact `modules` value all stay exactly as written. The checkbox is then set to `[x]`.

**Verification commands:**

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 0 and "15 passed"; this selection contains
# test_class_two_bundled_shared_surfaces_are_the_portable_set,
# test_class_two_bundled_shared_surface_globs_are_empty, and
# test_class_three_bundled_modules_are_payload_modules_only

git grep -c -F "tests/scripts/dev_tools/test_blast_radius_config.py" -- \
  docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
# expect exactly 1 match after the fix, namely the import reference inside AC9,
# and no match inside AC4
```

The second command's expectation is stated as a count rather than as an absence because AC9 legitimately names that file as the source of the imported helpers. The distinction to preserve is that AC9 names it as an import source and AC4 must not name it as a verification source.

---

### R8 — Major, recommended in the same change. Close the key-set exhaustiveness gap

**Files:** `tests/scripts/dev_tools/test_blast_radius_config_parity.py` (423 lines, 77 of headroom) and `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (387 lines, 113 of headroom).

**Observed gap:** the three-class partition enumerates `version`, `over_breadth_fraction`, `mandate_reads`, `shared_surfaces`, `shared_surface_globs`, and `modules`, which is the complete top-level key set of both copies today. Nothing asserts that the enumeration covers the actual key sets, so a seventh top-level key added to one copy and not the other is undetected. That is the same mechanism that produced the original defect: a bundled copy falling behind a self-hosted one that grew.

Demonstrated empirically in this re-audit. Adding four self-hosted-only changes at once — `config/new-portable-surface.json` to `shared_surfaces`, `config/newfam_*.json` to `shared_surface_globs`, a `newsub` module, and a `new_top_level_key` top-level key — then running both pytest modules produced `50 passed` at exit 0. No case fired.

**Expected behavior after the fix:** a new case in each language asserts that the two copies declare the same top-level key set, and that the set equals the union of the three declared classes. A key added to one copy and not the other, or a key added to both but claimed by no class, then fails loudly and names the offending key. The invariant must be verified to hold at the current head and verified to fail against a synthetic key injected into one copy only, so it is falsifiable before it is committed.

The declared class membership already exists as data on the Python side: `BYTE_EQUAL_KEYS` names Class 1, and Class 2 and Class 3 each cover one or two named keys. Expressing the union as a module-level tuple in `blast_radius_parity_test_support.py` keeps the assertion module free of new data, consistent with the existing split.

**Verification commands:**

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 0 with the new case passing

# falsifiability, one copy only
python -c "import json,io;p='config/blast-radius.json';d=json.load(open(p,encoding='utf-8'));d['new_top_level_key']=['x'];open(p,'w',encoding='utf-8').write(json.dumps(d,indent=2)+chr(10))"
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
# expect exit 1 with the new case failing and naming new_top_level_key
git checkout -- config/blast-radius.json
git status --short -- config/blast-radius.json
# expect no output, proving the restore
```

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCFormat  -Root (Get-Location).ProviderPath   # expect exit 0, zero files rewritten
Invoke-PoshQCAnalyze -Root (Get-Location).ProviderPath   # expect exit 0, no findings
Invoke-PoshQCTest    -Root (Get-Location).ProviderPath   # expect exit 0, 3112 or more passed, 0 failed
```

If R8 is taken, `.claude/rules/parallel-orchestration.md` and its bundled mirror should record the exhaustiveness assertion in the subsection this branch added, and the mirror must stay byte-identical in the same commit.

---

### R9 — Minor, recommended in the same change. Qualify the Class 2 mitigation clause

**File:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`, `## Risks & Mitigations`, the Class 2 mitigation bullet, currently ending:

```
    and the residual gap is
    closed structurally by `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle`
    (added in Phase 2).
```

**Observed defect:** the clause is unqualified where the closure is restricted to separator-free entries. Injecting `config/new-portable-surface.json` into the self-hosted `shared_surfaces` alone fires nothing, because the directional invariant filters on `"/" not in entry` by construction. The restriction is legible from the quoted test name, but the sentence's own claim is broader than what is delivered.

**Expected behavior after the fix:** the clause names the restriction, for example "and the separator-free portion of the residual gap is closed structurally by ...". The reason the restriction is correct — only a separator-free entry is accepted by the root-token extractor, so only a separator-free omission is a live gap — is already stated in both the Python docstring and the Pester comment and may be cited rather than restated.

**Verification command:**

```bash
git grep -n -F "separator-free portion of the residual gap" -- \
  docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
# expect one match inside the Class 2 mitigation bullet
```

---

### R10 — Minor, optional in this cycle. Retire the stale line-number anchors in five criteria

**File:** the same `spec.md`, `## Acceptance Criteria`, items 1, 2, 3, 5, and 12.

**Observed defect:** five criteria cite line numbers that no longer resolve to the constructs they name.

| Criterion | Cited | Actual at head `a95ae362` |
|---|---|---|
| AC1 | `claude-blast-radius-derive-core.ts` lines 123-130 | doc comment opens at 123; the stated reason sits in the `@remarks` block at 131-140 |
| AC2 | `blast-radius-derive-core.test.ts` lines 137, 153, 240, 252, 338, 474 | 137 and 240 land on an assertion and an `it(...)` opener; 153 is a closing brace, 252 a comment, 338 a blank line, 474 a comment continuation. The two required assertions are at 461-479 |
| AC3 | `blast-radius-derive.test.ts` lines 44, 122, 292, 387; `config-carriage.test-helpers.ts` line 84 and comment 61-72 | 44 and 292 resolve; 122 is a closing brace and 387 the file's final line. `SOURCE_BLAST_RADIUS` is at 86 with its comment at 61-85 |
| AC5 | `claude-config-carriage.test.ts` lines 284-293 | the rationale comment is at 278-296 and the forbidden-substring list follows at roughly 300-310 |
| AC12 | `BlastRadius.TruthTable.Tests.ps1` lines 96-98 | the corrected comment stands at 92-104 |

**Expected behavior after the fix:** the line numbers are removed in favour of the construct names, which are stable across edits, or refreshed once against head. Removal is preferred: an anchor that drifts silently costs a reviewer the work of distinguishing drift from the R7 defect class. No criterion's substantive content changes.

**Verification:** read each criterion and confirm it names a construct rather than a line range, and that `git grep -n -F "<construct name>" -- <cited file>` returns at least one match for each named construct.

---

### R11 — Minor, optional in this cycle. Use one clock for the feature folder's evidence timestamps

**Files:** the twenty artifacts under `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/` stamped `2026-08-21T21-49`.

**Observed defect:** all twenty remediation-cycle artifacts carry one identical local-clock stamp, roughly three hours earlier than the UTC stamps of the audit (`2026-08-22T00-52`) and plan (`2026-08-22T01-10`) that requested them, so the cycle's evidence appears to predate its own trigger. Their shared minute also makes their relative order unrecoverable from their names. The original cycle's artifacts use UTC and are internally consistent.

**Expected behavior after the fix:** the feature folder uses one clock, UTC being the one the earlier artifacts already use, and each artifact is stamped when it is produced. Renaming committed artifacts is not required and is not recommended, because the cross-references in the plan and the audits would have to move with them. Recording the convention and the discrepancy in a short note under `evidence/other/` is sufficient for audit fidelity, and future cycles use UTC.

**Verification command:**

```bash
ls docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/*/*2026-08-21T21-49*
# expect the twenty known paths; the note explains why their stamp precedes the
# audit that requested them
```

---

### R12 — Minor, optional in this cycle. Mirror the non-vacuity floor into the Pester file

**File:** `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`.

**Observed gap:** the Python directional case reads through the `shared_surfaces` accessor, which returns an empty tuple for an absent or non-list key, so a renamed key would make it pass vacuously; `test_the_gate_compares_non_empty_collections` is what catches that. The Pester case indexes `$script:CommittedConfig['shared_surfaces']` directly, so a renamed key raises rather than passing. Both fail loudly overall, but not through the same mechanism, and the Pester file carries no non-vacuity floor of its own.

**Expected behavior after the fix:** either a guard asserting both `shared_surfaces` values are non-empty collections before the containment loop, or a mirrored non-vacuity `It` block in the `Cross-copy key partition` Context. The choice is the author's; the requirement is that the two mirrors respond the same way to the same malformed input, which is the property the mirror relation exists to preserve.

**Verification commands:**

```powershell
Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -Output Detailed
# expect exit 0 with the new or extended case passing
```

---

## Priority and Minimum Sufficient Scope

| ID | Severity | Required to clear the blocking finding | Files touched |
|---|---|---|---|
| R7 | Blocking | Yes | `spec.md` |
| R8 | Major | No | two test files, optionally the rule and its mirror |
| R9 | Minor | No | `spec.md` |
| R10 | Minor | No | `spec.md` |
| R11 | Minor | No | one new evidence note |
| R12 | Minor | No | one test file |

The minimum sufficient remediation is R7 alone, which changes one identifier in one documentation file and changes no executable behaviour. R9 and R10 are strongly recommended alongside it because they touch the same document, require no toolchain rerun, and remove the remaining imprecision in the acceptance-criteria section. R8 is recommended because it closes the last undetected instance of the mechanism this branch exists to fix and because the two files have ample headroom, but it is not required to clear the blocker.

If R8 or R12 is taken, the full toolchain loop must be rerun for the affected languages and the coverage figures recorded, because those changes touch test code. R7, R9, R10, and R11 alone require no toolchain rerun.

---

## Do Not Do

- **Do not amend the substance of any acceptance criterion.** R7 changes one file identifier in AC4's trailing sentence. The six named `shared_surfaces` entries, the empty `shared_surface_globs`, the four `mandate_reads` entries, and the exact `modules` value all stay exactly as written. R10 removes or refreshes line anchors and changes no substantive requirement.
- **Do not add, remove, or renumber acceptance criteria.** The count stays at seventeen.
- **Do not add a new acceptance criterion for R8.** R8 closes a gap no criterion states. Adding a criterion for it would change the seventeen-item set and is out of scope for this cycle; record it in the code review and the rule instead.
- **Do not move the gate into `tests/scripts/dev_tools/test_blast_radius_config.py` to make AC4's original text true.** That file stands at 499 of a permitted 500 lines and one added line would breach `.claude/rules/general-code-change.md`. The sibling-module design is correct and PD-1 records it.
- **Do not remove AC9's reference to `test_blast_radius_config.py`.** AC9 names it as the source of the imported helpers, which is accurate. Only AC4 names it as a verification source, and only that is wrong.
- **Do not change `PAYLOAD_MODULES`, either truth table, or the rule text** as part of R7, R9, R10, or R11. Those are settled and verified at head.
- **Do not delete the bundled `modules` key.** `load_module_globs` raises `TypeError` on its absence and `test_blast_radius_config.py:490` calls that helper on the bundled copy. The retention is deliberate and is recorded in the rule.
- **Do not widen the bundled `shared_surfaces` set beyond the six declared portable entries** as part of R8. R8 adds an assertion; it does not change data. If the assertion fails after being added, that is a finding to report, not a licence to edit either copy.
- **Do not relax the Class 2 equality to a subset relation** in order to accommodate R8. Equality against the declared constant is what catches a silently added drm-copilot-specific entry.
- **Do not weaken the directional invariant to accommodate R8.** The two invariants are independent: one asserts reverse containment for separator-free entries, the other asserts key-set exhaustiveness.
- **Do not weaken any assertion, delete any test, or add any suppression.** Zero `noqa`, `# type: ignore`, `# pyright: ignore`, `eslint-disable`, `@ts-expect-error`, or PSScriptAnalyzer suppression exists on an added line anywhere in the branch today and none may be added.
- **Do not add a coverage `exclude` or `omit` entry.** None exists in the branch today.
- **Do not author, import, or read a JSON Schema** for either truth table. `.claude/rules/parallel-orchestration.md` prohibits it; enforcement remains prose plus validator and test logic.
- **Do not extend `SCOPED_ROOTS` in `test_push_down_claude_resource_contracts.py` to the `config` tree.** Research `## 4.4` rejected that as Option A because it would force drm-copilot-specific paths into every destination.
- **Do not rename the twenty artifacts stamped `2026-08-21T21-49` as part of R11.** The plan and the two prior audits cross-reference them by name.
- **Do not open a new remediation cycle for the findings already listed here.** Any new finding discovered during execution begins cycle 3 with its own inputs artifact.
- **Do not write evidence anywhere but `<FEATURE>/evidence/<kind>/`.** Any instruction naming `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` must be rejected and the rejection recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED`.
- **Do not modify any file under `.claude/rules/` or `.github/instructions/`** except the single `.claude/rules/parallel-orchestration.md` amendment and its byte-identical bundled mirror, and only if R8 is taken.

---

## Handoff

Plan authorship is routed to `atomic-planner` per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`. That skill assigns authorship of the remediation plan to `atomic-planner` and prohibits the orchestrator from acting on the delta itself; `feature-review` likewise does not author the plan, so no plan stub was created by this review. The plan must conform to `.claude/skills/atomic-plan-contract/SKILL.md`, must pass `validate_orchestration_artifacts` with `artifact_type: "plan"`, and must clear `atomic-executor` preflight before execution.

A specific caution for the plan's own acceptance gates, carried forward from cycle 1's preflight finding RP-1 and from `.claude/rules/plan-acceptance-gates.md`: do not state an acceptance condition as a search for a phrase that wraps across a line in the target file, and do not state a conjunction whose conjuncts already hold against the unedited file. The R7 verification above uses `git grep -c` with an expected count rather than an absence assertion for exactly this reason, because the string legitimately appears elsewhere in the same document.

Note on artifact layout: `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` describes a folder-per-cycle layout of `remediation/<entry-ts>/` and `audit/<exit-ts>/`. The `feature-review` agent contract in force for this run specifies flat, timestamp-suffixed filenames at the feature root, and the delegating prompt asked for the artifacts in the active feature folder. This artifact and the three audit artifacts therefore use the flat form, matching cycle 1.

---

## Exit Condition for Cycle 2

Cycle 2 exits when a reaudit confirms all of the following:

1. `spec.md` AC4 names `tests/scripts/dev_tools/test_blast_radius_config_parity.py` as the file carrying the Class 2 and Class 3 assertions, and its checkbox is `[x]`.
2. All seventeen acceptance criteria are checked and each is independently verifiable from its own stated source and command, with no criterion naming a file that carries none of the assertions it cites.
3. The full toolchain still passes in a single pass for every language with changed files, and coverage is unchanged or improved in all three coverage languages.
4. If R8 was taken, a synthetic top-level key injected into one copy alone fails the new case in both languages, and the restore is proven by `git status --short` producing no output.
5. `blocking_count == 0`.
