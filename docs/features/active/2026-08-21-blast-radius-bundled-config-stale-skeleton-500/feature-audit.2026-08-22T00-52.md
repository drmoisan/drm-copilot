# Feature Audit: blast-radius bundled truth-table correction (#500)

**Audit Date:** 2026-08-22
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Base Branch:** `main`
**Head Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `fb30a9a58b8422e610a09b07361421e97367807a`)
- **Head branch/commit:** `bug/blast-radius-bundled-config-stale-skeleton-500` (commit `59425465740957cd35fdae599146f81ed707f1a5`)
- **Merge base:** `fb30a9a58b8422e610a09b07361421e97367807a`, confirmed by `git merge-base main HEAD`. The merge base equals the base tip, so the branch is up to date with `main` and the diff is a pure fast-forward set.
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, regenerated against `main` at the current head and confirming `Base ref (resolved): origin/main @ fb30a9a5...` and `Head ref (resolved): ... @ 59425465...`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/**`, 52 artifacts across `baseline`, `qa-gates`, `regression-testing`, `other`, and `issue-updates`
  - Additional evidence: `artifacts/orchestration/orchestrator-state.json` for `design_decisions`, `plan_deviations`, `artifact_errors`, `preflight_status`, and `execution_result`; direct execution of the toolchain and four mutation probes by the reviewer
- **Feature folder used:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`, selected because its numeric suffix matches the issue number in the branch name and because it is the only active folder with scoping-document changes in this diff.
- **Requirements source:** `spec.md` only.
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`. Under `.claude/skills/acceptance-criteria-tracking/SKILL.md` that resolves the acceptance-criteria source to `spec.md` alone. `user-story.md` does not exist in this folder, which is consistent with the bug work mode. The reviewer did not treat the `## Proposed Fix / Validation Ideas` checkboxes in `issue.md` as acceptance criteria, because `full-bug` excludes `issue.md` as an AC source.
- **Scope note:** the audit covers the full branch diff against the resolved base, not a plan, task, or phase subset. Sixty-seven files changed: three production or data files, six test and test-helper files, two rule Markdown files, and fifty-six documentation and evidence Markdown files. Every language with changed files was carried through its full toolchain and coverage check; the results are recorded in `policy-audit.2026-08-22T00-52.md` and `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T00-52.md`. The GitHub CLI is unavailable in this environment, so no pull-request metadata was consulted and the pull request is not yet open.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` — only source, resolved from the `full-bug` work mode

All seventeen criteria are checkbox items under the `## Acceptance Criteria` heading. They are transcribed below in source order, abbreviated where the original spans many lines; the source wording is unchanged in the file.

### From spec.md

1. `claude-blast-radius-derive-core.ts` declares `PAYLOAD_MODULES` as `{ config: ["config/**"] }` with no `claude-runtime` key, and its doc comment states why the `.claude` tree is not a module.
2. `blast-radius-derive-core.test.ts` no longer positively pins `claude-runtime`; the six named expectations are updated, and the file asserts that the `PAYLOAD_MODULES` key set excludes `claude-runtime` and that its glob set contains no member of `FORBIDDEN_GLOBS`.
3. `blast-radius-derive.test.ts` seeded expectations at four named lines are updated, and `config-carriage.test-helpers.ts` `SOURCE_BLAST_RADIUS` and its comment mirror the corrected bundled file.
4. The bundled `config/blast-radius.json` declares exactly the six-entry portable `shared_surfaces` set; `shared_surface_globs` is `[]`; `mandate_reads` carries the four added entries; and `modules` is exactly `{ "config": ["config/**"] }`.
5. `claude-config-carriage.test.ts` AC8 forbidden-substring list no longer forbids `poetry.lock` or `package-lock.json`, and its rationale comment states that the exclusion targets entries naming this repository's directory layout rather than ecosystem-standard root lockfile names (DD-1).
6. `config/blast-radius.json` `mandate_reads` carries the same four added entries, and its `shared_surfaces`, `shared_surface_globs`, and `modules` are otherwise unchanged.
7. `.claude/rules/parallel-orchestration.md` records, under the Blast-Radius Contention Doctrine, that the destination module map is derived and the bundled `modules` key is not consumed; that `PAYLOAD_MODULES` carries `config` only; and that the bundled surface sets are the destination-portable subset, with the asymmetry as the stated reason.
8. The bundled `.claude/rules/parallel-orchestration.md` is byte-identical to the repository copy after that amendment, in the same commit.
9. `tests/scripts/dev_tools/test_blast_radius_config.py` carries the three-class key-partition gate, extending the two-copy `COMMITTED_CONFIGS` pattern at lines 474-499, verified by `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py`.
10. The same file asserts the five-name umbrella denylist across both copies, the separator-free wildcard-free property, and a non-vacuity floor, verified by the same pytest invocation.
11. `BlastRadius.TruthTable.Tests.ps1` mirrors the Class 1 equality, the Class 3 subset, the five-name denylist applied to both copies, and the separator-free-wildcard-free assertion, and stays under the 500-line limit.
12. The comment at `BlastRadius.TruthTable.Tests.ps1:96-98` no longer states that the bundled module map describes the destination repository's subsystems, and instead records that the bundled `modules` key is never read and that `PAYLOAD_MODULES` is the live source.
13. A regression test fails before the fix and passes after it for the fail-closed direction, with the failing-before run captured under `evidence/regression-testing/` and the passing-after run under `evidence/qa-gates/`.
14. A regression test fails before the fix and passes after it for the fail-open direction, with `Get-ConfigRootSurface` returning a non-empty set, and evidence captured in the same two locations.
15. Coverage obligations met and recorded: line at or above 85 percent and branch at or above 75 percent for Python and TypeScript, line at or above 85 percent for PowerShell, with no regression on changed lines and no `exclude` entry added.
16. Full toolchain pass in a single run for all three languages.
17. `git log --follow` output for both copies of `config/blast-radius.json` is captured as evidence, and a `Get-FileHash` byte compare of the `config/orchestration-routing.json` pair confirms it independently of its TypeScript test.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `PAYLOAD_MODULES` is `{ config: ["config/**"] }` with a doc comment explaining the exclusion | PASS | `claude-blast-radius-derive-core.ts:148-152` declares exactly `{ config: ["config/**"] }`. Lines 123-147 carry a rewritten comment with a `@remarks` block stating the granularity criterion, that removing the umbrella does not weaken `path_overlap` or `shared_surface_overlap`, and that retaining `config` keeps `assertNoForbiddenGlob` non-vacuous. | `git diff fb30a9a5...HEAD -- extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | The AC cites the comment at "lines 123-130"; the comment now spans 123-147 because it grew. The reviewer evaluated substance, not the stale line span. |
| 2 | `blast-radius-derive-core.test.ts` drops the positive pin and adds the negative property | PASS | The six expectations at the named positions are updated to exclude `claude-runtime`. A new case `declares no umbrella or forbidden glob in the payload module set` asserts `expect(names).not.toContain("claude-runtime")` and loops `FORBIDDEN_GLOBS` asserting `expect(globs).not.toContain(forbidden)`. `FORBIDDEN_GLOBS` is added to the existing import list rather than duplicated. | `npm run test:coverage` in `extensions/drm-copilot`, exit 0, 195 suites and 2656 tests | The case comment correctly distinguishes the invariant from the equality pin it complements. |
| 3 | `blast-radius-derive.test.ts` seeds updated and `SOURCE_BLAST_RADIUS` mirrors the corrected bundle | PASS | All four seeded `modules` literals in `blast-radius-derive.test.ts` drop `claude-runtime`. `SOURCE_BLAST_RADIUS` now declares the same six `shared_surfaces` in the same order, an empty `shared_surface_globs`, the same ten `mandate_reads` in the same order, `modules` of `{ config: ["config/**"] }`, and `over_breadth_fraction` `0.25`, matching the bundled file key for key and in key order. The comment at lines 61-88 is rewritten. | `git diff fb30a9a5...HEAD -- extensions/drm-copilot/test/lib/push-down/`; reviewer key-by-key comparison against the committed bundled file | `mandate_reads` was absent from the constant before this change and is now present, which is what makes the AC8 assertion in criterion 5 meaningful. |
| 4 | Bundled JSON declares the six-entry portable set, empty globs, four added mandate reads, and `modules` of `config` only | PASS | Reviewer read the committed file: `shared_surfaces` is exactly `.claude/settings.json`, `config/blast-radius.json`, `config/orchestration-routing.json`, `package-lock.json`, `poetry.lock`, `quality-tiers.yml`; `shared_surface_globs` is `[]`; `mandate_reads` has ten entries including the four added; `modules` is `{"config": ["config/**"]}`. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`, exit 0, `14 passed`; reviewer key dump script | Three of the six surfaces are separator-free, which is what re-opens the root-token branch of `Get-PathTokenKind` in a destination. |
| 5 | AC8 forbidden list narrowed with a rationale comment stating the DD-1 criterion | PASS | The list at `claude-config-carriage.test.ts:299-307` now holds `'"**"'`, `'"docs/**"'`, `'"tests/**"'`, `scripts/dev_tools`, `packages/mcp-server`, with `poetry.lock` and `package-lock.json` removed. The comment above states the retained criterion is an entry naming this repository's directory layout, and that an ecosystem-standard root filename is a different case, citing issue #500 and DD-1. | `npm run test:coverage`, exit 0 | The reviewer confirmed the narrowing was not merely permitted but required: `CARRIED_KEYS` copies `shared_surfaces` verbatim into the published document, so once `SOURCE_BLAST_RADIUS` gained the two lockfile names under criterion 3, the unnarrowed assertion would have failed. DD-1's claim that the change "does not mechanically break the test" is true only of the pre-criterion-3 constant. |
| 6 | Self-hosted `mandate_reads` gains the four entries and nothing else changes | PASS | The diff for `config/blast-radius.json` is a single hunk appending exactly the four entries to `mandate_reads`. `shared_surfaces`, `shared_surface_globs`, and `modules` are untouched; the self-hosted map still holds the seven ratified subsystem modules. | `git diff fb30a9a5...HEAD -- config/blast-radius.json`; `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` | The entries are appended in the same order in both copies, which is what makes the Class 1 list-equality assertion hold. |
| 7 | The rule records the three required points | PASS | The new section `### The published truth table is not a copy of this one (issue #500)` covers (a) that the destination map is derived and the bundled `modules` key is not consumed, naming `assembleModules` and its file; (b) that `PAYLOAD_MODULES` carries `config` only, with the criterion transfer argument and the no-signal-floor argument; and (c) that the bundled surface sets are the destination-portable subset, with the surfaces-versus-modules asymmetry stated as the mechanism. | `git diff fb30a9a5...HEAD -- .claude/rules/parallel-orchestration.md` | The section also records the separator-free surface as the sole gate on root-token acceptance, which is beyond what the criterion requires. |
| 8 | The bundled rules mirror is byte-identical in the same commit | PASS | `diff .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` produced no output, exit 0. Both files appear in commit `59425465`. | `diff` as above; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` runs inside the full suite, exit 0 | The executor's recorded sha256 `222de3c8...6578` for the pair is consistent with the reviewer's `diff` result. |
| 9 | `test_blast_radius_config.py` carries the three-class gate, verified by pytest on that file | PARTIAL | The three-class gate is fully delivered and enforced, but in `tests/scripts/dev_tools/test_blast_radius_config_parity.py` with constants in `blast_radius_parity_test_support.py`. `test_blast_radius_config.py` is untouched at 499 lines. The AC's own verification command collects 32 cases and none of the gate's 14. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` exit 0, `32 passed`; `--collect-only -q` matched zero of `class_one`, `class_two`, `class_three`, `umbrella`. Contrast `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` exit 0, `14 passed`. | Substance delivered under recorded deviation PD-1, forced by the hard 500-line ceiling. The criterion text and its verification command are not satisfied as written, so the item is left unchecked. Remediation is a documentation-only amendment of the criterion text. |
| 10 | The same file asserts the umbrella denylist, the separator-free property, and the non-vacuity floor | PARTIAL | All three assertions exist and pass, in the sibling module: `test_no_committed_copy_declares_an_umbrella_module` parametrized over both copies with all five names; `test_every_separator_free_bundled_shared_surface_is_wildcard_free` with a non-empty precondition; `test_the_gate_compares_non_empty_collections` pinning `len(COMMITTED_CONFIGS) == 2` and six named non-empty collections plus a separate `mandate_reads` check. | Same commands as criterion 9 | Same disposition and same remediation as criterion 9. |
| 11 | The Pester file mirrors Class 1, Class 3, the denylist over both copies, and the separator-free property, under 500 lines | PASS | Four cases present: `declares equal values for the runtime-describing keys in both copies` (Class 1 over all three keys), `declares only payload modules in the bundled copy` (Class 3 subset), `declares no removed umbrella module in either committed copy` (widened to both copies with all five names), and `gives every separator-free bundled shared surface no wildcard` (with a non-empty precondition). The file is 353 lines. | `Invoke-PoshQCTest -Root <worktree>` exit 0, 3110 passed; targeted `Invoke-Pester` on the file, 17 passed 0 failed; `wc -l` = 353 | The reviewer additionally confirmed the mirror is discriminating by reverting the bundled JSON: 13 passed and 4 failed, naming all four. |
| 12 | The incorrect comment is corrected and records the real mechanism | PASS | The former text asserting the bundled map "describes the DESTINATION repository's subsystems" is gone. The replacement states the map is never read, that a destination's map is derived by `assembleModules`, that `PAYLOAD_MODULES` is the live source with its full file path, and that the former exemption let a `claude-runtime` umbrella survive. | `git diff fb30a9a5...HEAD -- tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`; `Invoke-PoshQCTest` exit 0 | The correction is the reason the denylist could be widened to both copies. |
| 13 | Fail-before and pass-after for the fail-closed direction, evidence in both canonical folders | PASS | `evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md` records `EXIT_CODE: 1` with `ExpectedExitCode: 1` and quotes the assertion message naming `('module_overlap', 'claude-runtime')`. `evidence/qa-gates/python-regression-pass-after.2026-08-22T00-14.md` records `EXIT_CODE: 0` with byte-identical node IDs. | Reviewer reproduction: reverting only the bundled JSON to `fb30a9a5` and rerunning the two node IDs gave exit 1 with the exact recorded messages; restored, tree clean | The reviewer reproduced the fail-before state rather than accepting the artifact, so this is verified rather than asserted. |
| 14 | Fail-before and pass-after for the fail-open direction, with a non-empty root-surface set | PASS | The same artifact pair records the fail-open case with `observed reasons ()` before and passing after. `evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md` records `Get-ConfigRootSurface -Config $bundled` returning the three separator-free entries where it previously returned the empty set, plus a second run with a configured token demonstrating the restored branch. | Reviewer reproduction as for criterion 13; `Invoke-PoshQCTest` exit 0 | The pass-after artifact reports `conflict : False` for the research 5.3 pair and explains that this is correct because those tokens are not portable-set members, rather than substituting a passing case. |
| 15 | Coverage obligations met and recorded, no regression on changed lines, no `exclude` added | PASS | Reviewer-measured: Python 92.60% statements and 85.19% branches; TypeScript 96.66% lines and 90.04% branches; PowerShell 96.21% lines with no branch counter emitted. Deltas 0.00 in every figure. The one changed production module carries `LF:468 LH:468` and `BRF:48 BRH:46`. `pyproject.toml`, `jest.config.cjs`, and the Pester runsettings are unchanged on the branch. | `poetry run pytest --cov=scripts.dev_tools --cov-branch ...` exit 0; `npm run test:coverage` exit 0; `Invoke-PoshQCTest` exit 0; `artifacts/pester/powershell-coverage.xml` root `LINE missed="228" covered="5792"` | AC15 names `npm run test:coverage`, which is the correction the orchestrator recorded in `artifact_errors` after preflight found that `test:unit:coverage` does not exist in the extension `package.json`. The corrected command exists and was run. |
| 16 | Full toolchain pass in a single run for all three languages | PASS | The reviewer executed all eleven runnable stages in one uninterrupted sequence, all exit 0, none rewriting a file. Black 440 unchanged; Ruff all checks passed; Pyright 0 errors; pytest 4076 passed; Prettier all matched files conform; ESLint no diagnostics; tsc clean; Jest 2656 passed; PoshQC format 382 already formatted and 0 rewritten; PoshQC analyze no findings; PoshQC test 3110 passed. | See `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T00-52.md` and Appendix B of `policy-audit.2026-08-22T00-52.md` | The architecture-boundary stage named by `.claude/rules/general-code-change.md` step 4 is not runnable because no `dependency-cruiser` configuration exists anywhere in the repository. That is a pre-existing condition at the merge base and is recorded in the policy audit; AC16 names only the eleven stages that were run. |
| 17 | Divergence walk captured, and the routing pair byte-compared independently | PASS | `evidence/other/divergence-commit-walk.2026-08-21T21-47.md` records both `git log --follow --oneline` outputs with a per-commit key-shape table showing the bundled copy at 3 shared surfaces from creation and the self-hosted copy at 10. `evidence/other/routing-pair-byte-compare.2026-08-22T00-14.md` records equal SHA256 `D9C6657C...7BDA` for the pair. | Reviewer confirmation: `diff` of both `orchestration-routing.json` pairs produced no output; `git show a45a993b:config/blast-radius.json` confirms the historical self-hosted shape the walk reports | The walk is the evidence that justifies rejecting byte-equality for the surface keys: the bundle was authored narrow rather than falling behind. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

The revision required is documentary and small. The engineering, the evidence, and the toolchain are all sound, and the reviewer independently reproduced every load-bearing claim including the fail-before state in two languages and the headline conflict-graph measurement to the exact edge count.

**Criteria summary:**
- **PASS:** 15 criteria
- **PARTIAL:** 2 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC9 and AC10 name `tests/scripts/dev_tools/test_blast_radius_config.py` as the file carrying the three-class gate and cite `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` as the verification. The gate is in `tests/scripts/dev_tools/test_blast_radius_config_parity.py` with constants in `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, and the cited command collects 32 cases and none of the gate's 14. The deviation PD-1 that forced the relocation is legitimate and disclosed in the orchestration checkpoint, but the criterion text was never amended to match, so the acceptance record asserts a verification that did not occur.
2. No second gap prevents PASS. The Major finding CR-1 recorded in `code-review.2026-08-22T00-52.md`, that Class 2 does not detect self-hosted-side growth of the portable shared-surface set, is a design observation with a concrete strengthening recommendation and does not correspond to an unmet acceptance criterion; AC9 requires exactly the relation that was implemented.

**Recommended follow-up verification steps:**

1. Amend the AC9 and AC10 criterion text in `spec.md` to name `tests/scripts/dev_tools/test_blast_radius_config_parity.py` together with `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, and to cite `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`. Then rerun that command, confirm `14 passed`, and re-check both boxes.
2. Consider adding the directional invariant recommended in CR-1: assert that every separator-free self-hosted `shared_surfaces` entry appears in the bundled set, mirrored in the Pester file. The invariant holds today and would have fired against the pre-fix bundle, so it is verifiable before it is committed. Correct the `## Risks & Mitigations` sentence in `spec.md` regardless.
3. When the pull request is opened, confirm the body states the destination-visible behaviour change, which `spec.md` `## Data / API / Config Impact` requires and which cannot be verified before the pull request exists.

---

## Acceptance Criteria Check-off

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`:

- Criteria evaluated as PASS may be checked off in the authoritative source file when they are checkbox items and are not already checked.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED must remain unchecked.
- Criterion text is preserved; only the checkbox marker is changed.

**Actions taken by this reviewer in `spec.md`:**

- Criteria 1 through 8 and 11 through 17 were evaluated PASS and were already checked. No change was made to those fifteen lines.
- Criterion 9 was evaluated PARTIAL and was **unchecked**, changing `- [x]` to `- [ ]` on the line beginning `` `tests/scripts/dev_tools/test_blast_radius_config.py` carries the three-class key-partition ``. The criterion text was not modified.
- Criterion 10 was evaluated PARTIAL and was **unchecked**, changing `- [x]` to `- [ ]` on the line beginning `The same file asserts that neither copy declares any of the five disqualified umbrella module`. The criterion text was not modified.

No criterion was added, removed, or reworded. The reviewer did not amend the AC9 or AC10 wording to match the delivered file, because the tracking rules reserve criterion authorship to planning and scoping agents; that amendment is routed through `remediation-inputs.2026-08-22T00-52.md`.

The executor's own summary at `evidence/issue-updates/ac-status-summary.2026-08-22T00-40.md` reports all seventeen criteria as checked. This audit supersedes that count for criteria 9 and 10.

### AC Status Summary

- Source: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
- Total AC items: 17
- Checked off (delivered): 15
- Remaining (unchecked): 2
- Items remaining:
  1. `` `tests/scripts/dev_tools/test_blast_radius_config.py` carries the three-class key-partition gate, extending the existing two-copy `COMMITTED_CONFIGS` pattern at lines 474-499 ... Verified by `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py`. ``
  2. `The same file asserts that neither copy declares any of the five disqualified umbrella module names ... Verified by the same pytest invocation.`

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | 17 | 15 | 2 | Checkbox-backed and authoritative for `full-bug`. Two items unchecked by this review. |
| `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/issue.md` | n/a | n/a | n/a | Not authoritative under `full-bug`. Its `## Proposed Fix / Validation Ideas` checkboxes were read for context only and were not treated as acceptance criteria. |
| `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/user-story.md` | n/a | n/a | n/a | Does not exist, which is correct for the `full-bug` work mode. |

Note on artifact structure: the bundled feature-audit template heads this section `## Acceptance Criteria Check-Off` with a capital O, while `scripts/dev_tools/validate_orchestration_review_artifacts.py` requires `## Acceptance Criteria Check-off`. This artifact uses the validator's spelling. The divergence is pre-existing and is recorded here so a later maintainer does not mistake the deviation from the template for an error in this artifact.
