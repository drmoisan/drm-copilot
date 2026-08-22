# Feature Audit: blast-radius bundled truth-table correction (#500)

**Audit Date:** 2026-08-22
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Base Branch:** `main`
**Head Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `fc9a3a26`
**Work Mode:** `full-bug`
**Audit Type:** Post-remediation acceptance verification, remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `main` (commit `fb30a9a58b8422e610a09b07361421e97367807a`)
- **Head branch/commit:** `bug/blast-radius-bundled-config-stale-skeleton-500` (commit `fc9a3a26e64a5c11175382c2c7ea67bccf00a56f`)
- **Merge base:** `fb30a9a58b8422e610a09b07361421e97367807a`, identical to the base tip
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, refreshed at head; its `Head ref (resolved)` line reads `fc9a3a26e64a5c11175382c2c7ea67bccf00a56f` and its `Range` line reads `fb30a9a5..fc9a3a26`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/**`, 81 artifacts across six kinds
  - Additional evidence: this reviewer's own `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md` and `evidence/qa-gates/reviewer-perturbation-battery.2026-08-22T04-46.md`
- **Feature folder used:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`, selected because its `-500` suffix matches the issue number in the branch name and because it is the only active feature folder the branch modifies
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`. Under `.claude/skills/acceptance-criteria-tracking/SKILL.md` that resolves the acceptance-criteria source to `spec.md` alone. `user-story.md` does not exist in this folder, which is consistent with the bug work mode. No fail-closed fallback was needed.
- **Scope note:** the audit is a full feature-versus-base review of the entire branch diff, not of the cycle-2 delta. Every one of the seventeen criteria was re-verified from its own stated source and command at head `fc9a3a26`, including the twelve that cycle 2 did not touch. Two in-repository artifacts assert a TypeScript scope narrowing for the remediation cycle; both were rejected and are recorded verbatim in the policy audit under `## Rejected Scope Narrowing`, and the full TypeScript toolchain and coverage were rerun at head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` — only source, `## Acceptance Criteria` section spanning lines 419 to 520

The section contains seventeen markdown checkbox items. All seventeen were checked before this review; none was unchecked by it. The criteria are transcribed below in abbreviated form; the authoritative wording is in `spec.md` and was not modified by this review.

### Acceptance criteria

1. `claude-blast-radius-derive-core.ts` declares `PAYLOAD_MODULES` as `{ config: ["config/**"] }` with no `claude-runtime` key, and its doc comment's `@remarks` block states why the `.claude` tree is not a module.
2. `blast-radius-derive-core.test.ts` no longer positively pins `claude-runtime`; every seeded module-map expectation is updated, and the case `declares no umbrella or forbidden glob in the payload module set` asserts the key-set exclusion and the forbidden-glob property.
3. `blast-radius-derive.test.ts` seeded module-map expectations are updated, and `config-carriage.test-helpers.ts` `SOURCE_BLAST_RADIUS` with its preceding doc comment mirrors the corrected bundled file.
4. The bundled `blast-radius.json` declares exactly the 6-entry portable `shared_surfaces` set, an empty `shared_surface_globs`, the four added `mandate_reads` entries, and `modules` exactly `{ "config": ["config/**"] }`. Verified by the Class 2 and Class 3 assertions of the new gate in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
5. `claude-config-carriage.test.ts` AC8 forbidden-substring list in the `publishes a document derived from the destination's own layout` case no longer forbids `poetry.lock` or `package-lock.json`, with a rationale comment citing DD-1.
6. `config/blast-radius.json` `mandate_reads` carries the four added entries and its `shared_surfaces`, `shared_surface_globs`, and `modules` are otherwise unchanged.
7. `.claude/rules/parallel-orchestration.md` records, under the Blast-Radius Contention Doctrine, that the destination module map is derived and the bundled `modules` key is not consumed; that `PAYLOAD_MODULES` carries `config` only and `claude-runtime` is disqualified in a destination; and that the bundled surface sets are the destination-portable subset, with the surfaces/modules asymmetry as the stated reason.
8. The bundled `parallel-orchestration.md` is byte-identical to the repo copy after that amendment, in the same commit.
9. `test_blast_radius_config_parity.py` carries the three-class key-partition gate, importing shared helpers from `test_blast_radius_config.py` and holding its declared constants and accessors in `blast_radius_parity_test_support.py` per PD-1.
10. `test_blast_radius_config_parity.py` asserts the five-name umbrella denylist, the separator-free wildcard-free property, and a non-vacuity floor under which `COMMITTED_CONFIGS` has exactly two members and each collection intended to be non-empty is non-empty.
11. `BlastRadius.TruthTable.Tests.ps1` mirrors the Class 1 equality, the Class 3 subset, the five-name umbrella denylist applied to both copies, and the separator-free-wildcard-free assertion, and stays under the 500-line limit.
12. The comment inside the `declares no removed umbrella module in either committed copy` case no longer states that the bundled module map describes the destination repository's subsystems, and instead records that the bundled `modules` key is never read and that `PAYLOAD_MODULES` is the live source.
13. A regression test fails before the fix and passes after it for the fail-closed direction, with evidence in `evidence/regression-testing/` and `evidence/qa-gates/`.
14. A regression test fails before the fix and passes after it for the fail-open direction, with evidence in the same two locations.
15. Coverage obligations met and recorded: line >= 85% and branch >= 75% for Python and TypeScript; line >= 85% for PowerShell; no regression on changed lines; no `exclude` entry added.
16. Full toolchain pass in a single run for all three languages.
17. `git log --follow` output for both copies of `config/blast-radius.json` captured as evidence, and a `Get-FileHash` byte compare of the two `orchestration-routing.json` copies.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `PAYLOAD_MODULES` is `config` only with an `@remarks` rationale | PASS | `claude-blast-radius-derive-core.ts:148-151` declares `{ config: ["config/**"] }`. The `@remarks` block at lines 130-147 states that the `.claude` tree is deliberately not a module, gives the granularity-criterion reason, and records why `config` is retained. | `grep -n "PAYLOAD_MODULES" src/lib/push-down/claude-blast-radius-derive-core.ts` and read of lines 118-160 | The R10 anchor replacement resolves: the reason is in the `@remarks` block, as the corrected criterion now says. |
| 2 | `blast-radius-derive-core.test.ts` no longer pins `claude-runtime`; the named case asserts both properties | PASS | The file contains exactly two `claude-runtime` occurrences, at lines 472 and 477, and both are inside the named case: one a comment, one `expect(names).not.toContain("claude-runtime")`. The same case iterates `FORBIDDEN_GLOBS` asserting `not.toContain`. | `grep -n "claude-runtime" test/lib/push-down/blast-radius-derive-core.test.ts`; `npm run test:coverage` | The generalized wording "every seeded module-map expectation" is verified by the zero positive-pin count rather than by the retired line list. |
| 3 | `blast-radius-derive.test.ts` updated; `SOURCE_BLAST_RADIUS` mirrors the corrected bundled file | PASS | `blast-radius-derive.test.ts` contains zero `claude-runtime` occurrences. `SOURCE_BLAST_RADIUS` at `config-carriage.test-helpers.ts:86` reproduces the corrected bundled document key for key: `version 1`, the same six `shared_surfaces`, empty `shared_surface_globs`, the same ten `mandate_reads`, and `modules` of `config` only. Its doc comment at lines 61-85 states the mirror relation and the two removal rationales. | `grep -c "claude-runtime" test/lib/push-down/blast-radius-derive.test.ts` returns 0; read of `config-carriage.test-helpers.ts:58-110` against the committed bundled JSON | The mirror is correct today but unenforced; recorded as code-review finding CR-4. That is a durability observation, not a failure of this criterion, which requires the constant to mirror the file and it does. |
| 4 | Bundled JSON declares the portable set, empty globs, four added mandate reads, and `config` only | PASS | The committed bundled file declares exactly `.claude/settings.json`, `config/blast-radius.json`, `config/orchestration-routing.json`, `package-lock.json`, `poetry.lock`, `quality-tiers.yml`; `shared_surface_globs` is `[]`; `mandate_reads` carries all ten entries including the four added; `modules` is `{ "config": ["config/**"] }`. The cited file now carries the assertions: `test_class_two_bundled_shared_surfaces_are_the_portable_set`, `test_class_two_bundled_shared_surface_globs_are_empty`, and `test_class_three_bundled_modules_are_payload_modules_only` are all collected by the cited command. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -q` -> `16 passed` | The R7 correction is complete. The criterion's substantive data requirement was already satisfied before cycle 2; only the verification pointer was wrong, and it now names the file that carries the assertions. |
| 5 | AC8 forbidden-substring list corrected with a DD-1 rationale | PASS | `claude-config-carriage.test.ts:268` opens the named case; the forbidden list at lines 299-305 is `'"**"'`, `'"docs/**"'`, `'"tests/**"'`, `"scripts/dev_tools"`, `"packages/mcp-server"`, with neither lockfile present. The rationale comment at lines 277-296 cites issue #500 and DD-1 and gives the surfaces-versus-modules asymmetry. | `grep -n "publishes a document derived from the destination's own layout" test/lib/push-down/claude-config-carriage.test.ts`; `npm run test:coverage` | The R10 anchor replacement resolves to a case name that exists. |
| 6 | Self-hosted `mandate_reads` gains four entries; nothing else changes | PASS | `git diff fb30a9a5...HEAD -- config/blast-radius.json` shows a single hunk adding exactly `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/agent-memory/**`, and `.agents/skills/**` to `mandate_reads`. No other line changes. The Class 1 byte-equality assertion covers it and fired under perturbation P8. | `git diff fb30a9a58b8422e610a09b07361421e97367807a...HEAD -- config/blast-radius.json` | The "otherwise unchanged" clause is verified by the diff itself, which is stronger than any test could be. |
| 7 | The rule records the three stated points | PASS | The new subsection "The published truth table is not a copy of this one (issue #500)" carries all three: "A destination's module map is DERIVED, so the bundled `modules` key is not consumed"; "`PAYLOAD_MODULES` carries `config` only" with the granularity-criterion transfer; and "The bundled `shared_surfaces` and `shared_surface_globs` sets are the destination-portable subset" followed by the surfaces-versus-modules asymmetry as the stated reason. | `git diff fb30a9a58b8422e610a09b07361421e97367807a...HEAD -- .claude/rules/parallel-orchestration.md` | Cycle 2 appended a fourth paragraph recording the exhaustiveness assertion. That is additive and does not disturb the three required points. |
| 8 | The bundled rule copy is byte-identical, in the same commit | PASS | `cmp` over the pair exits 0. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is collected and passing. Both copies were amended in commit `59425465` and again in `fc9a3a26`, each time in the same commit. | `cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` -> `10 passed` | The criterion's cited anchor "lines 101-126" still resolves exactly: the `def` is at line 101 and the function body ends at 126. |
| 9 | The three-class gate exists, imports the shared helpers, and holds constants in the sibling module | PASS | `test_blast_radius_config_parity.py` imports `BUNDLED_CONFIG_LABEL`, `COMMITTED_CONFIGS`, and `load_config_file` from `test_blast_radius_config.py` and thirteen names from `blast_radius_parity_test_support.py`. Class 1 is `test_class_one_keys_are_equal_across_both_committed_copies` parametrized over `BYTE_EQUAL_KEYS`; Class 2 is the two `test_class_two_*` cases; Class 3 is `test_class_three_bundled_modules_are_payload_modules_only`. The support module carries the constants and four accessors and no assertion. PD-1 and the 499-line ceiling are recorded in the criterion and in the module docstring. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -q` -> `16 passed`; `wc -l` reports 461, 180, and 499 lines | The AC9 reference to `test_blast_radius_config.py` is an import-source citation and is accurate; it is the one reference to that file inside the criteria section and it must not be removed. |
| 10 | The denylist, the separator-free wildcard property, and the non-vacuity floor | PASS | `test_no_committed_copy_declares_an_umbrella_module` checks all five names over both copies via `COMMITTED_CONFIGS`. `test_every_separator_free_bundled_shared_surface_is_wildcard_free` asserts a non-empty selection before looping. `test_the_gate_compares_non_empty_collections` asserts `len(COMMITTED_CONFIGS) == 2`, six named non-empty collections, and a non-empty `mandate_reads` list in both copies. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -q` | The floor was driven to failure by perturbation P5, confirming it is not decorative. |
| 11 | The Pester mirror carries the four named assertions and stays under 500 lines | PASS | `declares equal values for the runtime-describing keys in both copies` at line 244 mirrors Class 1; `declares only payload modules in the bundled copy` at line 123 mirrors Class 3; `declares no removed umbrella module in either committed copy` at line 91 applies the five-name denylist to both copies; `gives every separator-free bundled shared surface no wildcard` at line 218 mirrors the separator-free assertion. The file is 446 lines. | `Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -PassThru` -> `TOTAL=20 PASSED=20 FAILED=0`; `wc -l` reports 446 | All four named assertions were driven to failure by perturbation P8, so the mirror is verified rather than assumed. The separate non-vacuity defect recorded as CR-1 and CR-2 lies outside this criterion's four named assertions. |
| 12 | The umbrella-case comment is corrected | PASS | The comment at lines 96-104 states that the scope is both committed copies, that "The bundled base document's module map is never read", that `assembleModules` derives from the destination's own layout, that `PAYLOAD_MODULES` "is the live source of a destination's payload modules", and that the former comment's exemption "was not true" and let the umbrella survive. | Read of `BlastRadius.TruthTable.Tests.ps1:91-121`; `Invoke-PoshQCTest -Root .` -> exit 0 | The R10 anchor replacement resolves to a case name that exists. |
| 13 | Fail-closed regression, fail before and pass after, evidence in both locations | PASS | Reproduced independently. With the bundled copy reverted to its merge-base state, `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` fails; at head it passes. The Pester counterparts also fail under the same revert. Evidence exists at `evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md` and `evidence/qa-gates/powershell-fail-closed-pass-after.2026-08-22T00-10.md`. | Perturbation P8, recorded in `evidence/qa-gates/reviewer-perturbation-battery.2026-08-22T04-46.md`; `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -q` | The reviewer's revert used `git show fb30a9a5:<path>`, which is the authoritative pre-fix state rather than a hand-constructed approximation of it. |
| 14 | Fail-open regression, fail before and pass after, evidence in both locations | PASS | Reproduced independently by the same revert: `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` fails against the merge-base bundled copy and passes at head, and it asserts the specific `("shared_surface_overlap", "package-lock.json")` reason pair rather than only the boolean. Evidence exists at `evidence/regression-testing/powershell-fail-open-repro.2026-08-21T23-12.md` and `evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md`. | Perturbation P8 | `Get-ConfigRootSurface` returning a non-empty set is implied by the shared-surface reason firing, and is separately pinned by the non-empty precondition in the wildcard-free case. |
| 15 | Coverage obligations met and recorded | PASS | Measured at head by the reviewer. Python 92.60% statements and 85.19% branches; TypeScript 96.66% lines and 90.04% branches; PowerShell 96.21% lines. Every delta against the Phase 0 baseline is 0.00. The one changed production file reads 100.00% lines and 95.83% branches. No `exclude`, `omit`, or `coveragePathIgnorePatterns` entry is added anywhere in the diff. | `poetry run pytest --cov=scripts.dev_tools --cov-branch ...`; `npm run test:coverage`; `Invoke-PoshQCTest -Root .` | Recorded in `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md` and in section 1.2.1 of the policy audit. The criterion's Python coverage target `--cov=scripts.dev_tools` is a dotted module name, so it collects real data. |
| 16 | Full toolchain pass in a single run, all three languages | PASS | Eleven stages executed by the reviewer in one uninterrupted sequence at head: Black, Ruff, Pyright, Pytest; Prettier, ESLint, tsc, Jest; PoshQC format, analyze, test. All exit 0, no stage rewrote a file, so no restart from formatting was required, and `git status --porcelain` was empty before and after. | The eleven commands listed in Appendix B of the policy audit | The cycle-2 executor's own single-pass artifact covers Python and PowerShell only, on the ground that cycle 2 touched no TypeScript file. The reviewer's pass covers all three, which is what discharges this criterion at head. |
| 17 | `git log --follow` divergence walk plus a `Get-FileHash` byte compare | PASS | `evidence/other/divergence-commit-walk.2026-08-21T21-47.md` records both `git log --follow --oneline` invocations and a per-commit key-shape table showing the divergence mechanism. `evidence/other/routing-pair-byte-compare.2026-08-22T00-14.md` records two identical SHA256 digests, `D9C6657C...7BDA`, for the two `orchestration-routing.json` copies. | `cmp config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json` -> exit 0 | The byte compare was confirmed independently by the reviewer with `cmp`, which does not depend on the Jest assertion that also covers the pair. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 17 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Repair the Pester non-vacuity floor so it distinguishes an absent `shared_surfaces` key from an empty list, and extend it to the bundled `modules` map. Verify by re-running perturbations P4 and P5 from `evidence/qa-gates/reviewer-perturbation-battery.2026-08-22T04-46.md` and observing the case fail before accepting the change. Code-review findings CR-1 and CR-2.
2. Bind `SOURCE_BLAST_RADIUS` to the committed bundled resource with one Jest equality assertion, then re-run perturbation P9 and confirm the suite now fails. Code-review finding CR-4.
3. Correct the two surviving pre-PD-1 pointers in `spec.md` `## Test Strategy` at lines 388 and 412. Code-review finding CR-5.

None of the three is required for this branch to merge. All seventeen acceptance criteria are satisfied without them.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All seventeen criteria in `spec.md` were already checked at head `fc9a3a26`, and all seventeen evaluate PASS in this audit. **No checkbox state was changed by this review.** No criterion was unchecked, because none evaluated below PASS. AC4, which the cycle-1 re-audit unchecked, was re-checked by the cycle-2 remediation commit after its verification pointer was corrected; this audit confirms that re-check is warranted.

The check-off protocol's "evidence before check-off" rule was applied to every criterion individually. Fourteen of the seventeen were verified by executing a command or a perturbation in this session rather than by reading an evidence artifact; the remaining three, criteria 7, 12, and 17, were verified by direct file inspection plus, for 17, an independent `cmp`.

### AC Status Summary

- Source: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | 17 | 17 | 0 | Checkbox-backed; authoritative under work mode `full-bug`. No state changed by this review. |
| `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/issue.md` | 0 | 0 | 0 | Not authoritative under `full-bug`. Its `## Proposed Fix / Validation Ideas` and `## Next Step` checkboxes are scoping notes, not acceptance criteria, and were not evaluated or modified. |
| `user-story.md` | 0 | 0 | 0 | Does not exist in this folder, which is correct for the `full-bug` work mode. |
