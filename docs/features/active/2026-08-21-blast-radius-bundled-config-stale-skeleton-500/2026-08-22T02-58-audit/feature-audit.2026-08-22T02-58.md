# Feature Audit: blast-radius bundled truth-table correction (Issue #500)

**Audit Date:** 2026-08-22
**Auditor:** feature-review
**Cycle:** remediation cycle 1 re-audit

---

## Scope and Baseline

**Base branch:** `main`, resolved from the supplied value and confirmed against `artifacts/pr_context.summary.txt`, which records `Base ref (resolved): origin/main @ fb30a9a58b8422e610a09b07361421e97367807a`.
**Merge base:** `fb30a9a58b8422e610a09b07361421e97367807a`, identical to the base tip, so the branch requires no rebase to be current.
**Head:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `a95ae362`.
**Range audited:** `fb30a9a58b8422e610a09b07361421e97367807a..a95ae36284eef1bafc0aa2e86e7ef488f2d0e868`, twelve commits.
**PR context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, both recording head `a95ae362`, which matches the current head. Neither is stale and neither was regenerated.

**Work mode:** `full-bug`, read from the persisted marker `- Work Mode: full-bug` in `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/issue.md`. Under `.claude/skills/acceptance-criteria-tracking/SKILL.md` the acceptance-criteria source for `full-bug` is `spec.md` and that file only. `user-story.md` does not exist in this folder, which is consistent with the mode.

**Acceptance-criteria source:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`, `## Acceptance Criteria`, seventeen checkbox items.

**Scope statement.** This audit covers the full branch diff against the merge base, not the remediation delta alone. All twelve non-documentation files and all 81 Markdown documents are in scope, and every language with changed files (Python, TypeScript, PowerShell, JSON, Markdown) received its full toolchain and coverage check at head. No caller instruction attempted to narrow that scope.

**Changed files, non-documentation:**

```
.claude/rules/parallel-orchestration.md
config/blast-radius.json
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts
extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
tests/scripts/dev_tools/blast_radius_parity_test_support.py
tests/scripts/dev_tools/test_blast_radius_config_parity.py
```

---

## Acceptance Criteria Inventory

| # | Criterion, abbreviated | Source line |
|---|---|---|
| AC1 | `PAYLOAD_MODULES` is `{ config: ["config/**"] }` with no `claude-runtime`, and its doc comment states why the `.claude` tree is not a module | `spec.md` `## Acceptance Criteria`, item 1 |
| AC2 | `blast-radius-derive-core.test.ts` no longer positively pins `claude-runtime`; asserts the key set excludes it and the glob set contains no `FORBIDDEN_GLOBS` member | item 2 |
| AC3 | `blast-radius-derive.test.ts` seeded expectations updated; `config-carriage.test-helpers.ts` `SOURCE_BLAST_RADIUS` and its comment mirror the corrected bundled file | item 3 |
| AC4 | The bundled `blast-radius.json` declares the 6-entry portable `shared_surfaces`, empty `shared_surface_globs`, the four added `mandate_reads` entries, and `modules` exactly `{ "config": ["config/**"] }` | item 4 |
| AC5 | `claude-config-carriage.test.ts` AC8 forbidden-substring list no longer forbids `poetry.lock` or `package-lock.json`, with a DD-1 rationale comment | item 5 |
| AC6 | `config/blast-radius.json` `mandate_reads` carries the four added entries and its other keys are unchanged | item 6 |
| AC7 | `.claude/rules/parallel-orchestration.md` records (a) the derived module map and unconsumed bundled `modules`, (b) `PAYLOAD_MODULES` carrying `config` only, (c) the destination-portable surface sets with the asymmetry as the reason | item 7 |
| AC8 | The bundled `parallel-orchestration.md` is byte-identical after the amendment, in the same commit | item 8 |
| AC9 | `test_blast_radius_config_parity.py` carries the three-class key-partition gate with its constants in `blast_radius_parity_test_support.py` under PD-1 | item 9 |
| AC10 | `test_blast_radius_config_parity.py` asserts the five-name umbrella denylist, the separator-free wildcard-free constraint, and a non-vacuity floor | item 10 |
| AC11 | `BlastRadius.TruthTable.Tests.ps1` mirrors Class 1, Class 3, the denylist on both copies, and the separator-free assertion, and stays under 500 lines | item 11 |
| AC12 | The comment at `BlastRadius.TruthTable.Tests.ps1` no longer claims the bundled module map describes a destination's subsystems, and names `PAYLOAD_MODULES` as the live source | item 12 |
| AC13 | A fail-closed regression test fails before and passes after: two unrelated `.claude` citations report `conflict=False` against the published document | item 13 |
| AC14 | A fail-open regression test fails before and passes after: two items citing the same separator-free root surface report `conflict=True` with `Get-ConfigRootSurface` non-empty | item 14 |
| AC15 | Coverage obligations met and recorded for Python, TypeScript, and PowerShell, with no regression on changed lines and no `exclude` entry added | item 15 |
| AC16 | Full toolchain pass in a single run for all three languages | item 16 |
| AC17 | `git log --follow` output captured for both copies of `config/blast-radius.json`, plus a `Get-FileHash` byte compare of the `orchestration-routing.json` pair | item 17 |

Total: 17.

---

## Acceptance Criteria Evaluation

| # | Verdict | Evidence and reasoning |
|---|---|---|
| AC1 | PASS | `claude-blast-radius-derive-core.ts:148` declares `export const PAYLOAD_MODULES: Readonly<Record<string, ReadonlyArray<string>>>` with `config` as its only key and no `claude-runtime`. The doc comment opens at line 123 and its `@remarks` block at lines 131-140 states the reason: every agent is instructed to read the policy rules first, so a `.claude/**` umbrella matches nearly every radius and carries no contention information. The cited anchor 123-130 covers the comment's opening rather than the reason, which is finding G3 in the policy audit; the required content is present in the named construct. `npm run test:unit` reported 195 suites and 2656 tests passing at exit 0. |
| AC2 | PASS | `blast-radius-derive-core.test.ts:461-479` carries both required assertions: `expect(names).not.toContain("claude-runtime")` and a loop over `FORBIDDEN_GLOBS` asserting no member appears in the glob set. Line 137 reads `expect(Object.keys(modules)).toEqual(["config"])` and line 240 opens `it("emits the payload modules when the observation list is empty")`; the other four cited lines have drifted. Verified by `npm run test:coverage`, exit 0. |
| AC3 | PASS | `blast-radius-derive.test.ts:44` reads `config: ["config/**"]` and line 292 asserts `not.toContain('"**"')`. `config-carriage.test-helpers.ts` declares `SOURCE_BLAST_RADIUS` at line 86 with a comment at lines 61-85 that states the six-entry portable set, its three separator-free members, the ten-entry `mandate_reads`, and the single `config` payload module, all matching the committed bundled copy key for key. The cited anchors 84 and 61-72 have drifted. Verified by `npm run test:coverage`, exit 0. |
| AC4 | PARTIAL, unchecked by this review | The data requirement is delivered exactly: the bundled copy declares the six named `shared_surfaces` entries, `shared_surface_globs` is `[]`, `mandate_reads` carries the four added entries, and `modules` is exactly `{"config": ["config/**"]}`. The criterion's stated verification does not verify it. It names `tests/scripts/dev_tools/test_blast_radius_config.py`, which is untouched by the branch, contains no Class 2 or Class 3 assertion, and collects 32 cases none of which belongs to the gate. Both classes live in `test_blast_radius_config_parity.py`. This is the same defect cycle 1 recorded as R1 and R2 against AC9 and AC10 and is the blocking finding of this re-audit. |
| AC5 | PASS | `claude-config-carriage.test.ts` at lines 278-296 carries the DD-1 rationale comment stating that an ecosystem-standard root filename is a different case from a path naming this repository's directory layout, and that `poetry.lock` and `package-lock.json` were removed from the list for that reason. The forbidden-substring list follows immediately and contains neither name. The cited anchor 284-293 has drifted by roughly sixteen lines. Verified by `npm run test:coverage`, exit 0. |
| AC6 | PASS | `git diff fb30a9a5..HEAD -- config/blast-radius.json` shows exactly four added lines, all inside `mandate_reads`, naming `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/agent-memory/**`, and `.agents/skills/**`. No other hunk exists, so `shared_surfaces`, `shared_surface_globs`, and `modules` are provably unchanged. `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` passes. |
| AC7 | PASS | The rule gains a subsection titled "The published truth table is not a copy of this one (issue #500)" carrying all three required statements: (a) `assembleModules` computes a destination's map from the destination's own layout and never reads the source document's `modules` key, with the retention reason stated; (b) `PAYLOAD_MODULES` carries `config` only, with `claude-runtime` disqualified by the same granularity criterion; (c) the bundled surface sets are the destination-portable subset, with the surfaces-versus-modules asymmetry given as the reason. A fourth paragraph records the directional invariant added by the remediation. The one checkable factual claim in the prose, that `test_blast_radius_config.py` calls `load_module_globs` on the bundled copy, was verified at line 490 of that file. |
| AC8 | PASS | `cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` produced no output at exit 0, and SHA256 is `59e7693cdc3dbe7a45e972f8a1f231a09974d5d854fd2013a6221475354b21c9` on both. Both edits appear in commit `a95ae362`, satisfying the same-commit requirement. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` reported 10 passed at exit 0. |
| AC9 | PASS | `test_blast_radius_config_parity.py` carries Class 1 as a case parametrized over `BYTE_EQUAL_KEYS`, Class 2 as `test_class_two_bundled_shared_surfaces_are_the_portable_set` plus `test_class_two_bundled_shared_surface_globs_are_empty`, and Class 3 as `test_class_three_bundled_modules_are_payload_modules_only`. It imports `BUNDLED_CONFIG_LABEL`, `COMMITTED_CONFIGS`, and `load_config_file` from `test_blast_radius_config.py`, and its constants and accessors live in `blast_radius_parity_test_support.py`. PD-1 is recorded in `artifacts/orchestration/orchestrator-state.json` with `verified_by_orchestrator: true`, and `test_blast_radius_config.py` measures 499 lines. The cited command `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` reported `15 passed` at exit 0 and collects every case the criterion enumerates. The correction is substantive, not cosmetic: the previously cited command collected 32 cases, none belonging to the gate. |
| AC10 | PASS | The same file carries `test_no_committed_copy_declares_an_umbrella_module`, parametrized over both copies and checking all five disqualified names; `test_every_separator_free_bundled_shared_surface_is_wildcard_free`, which first asserts the selection is non-empty; and `test_the_gate_compares_non_empty_collections`, which pins `len(COMMITTED_CONFIGS) == 2` and asserts six named collections plus `mandate_reads` are non-empty. The cited command collects all three. |
| AC11 | PASS | The Pester file carries `declares equal values for the runtime-describing keys in both copies` (Class 1), `declares only payload modules in the bundled copy` (Class 3), `declares no removed umbrella module in either committed copy` (the five-name denylist on both copies), and `gives every separator-free bundled shared surface no wildcard`. It measures 387 lines against the 500-line limit. `Invoke-PoshQCTest` reported 3111 passed and 0 failed at exit 0; the file alone reported 18 passed and 0 failed. |
| AC12 | PASS | The comment now stands at lines 92-104 and states that the bundled base document's module map is never read, that a destination's map is derived by `assembleModules`, and that `PAYLOAD_MODULES` is the live source. It additionally records that the former comment's exemption was untrue and let a `claude-runtime` umbrella survive in the published document. The cited anchor 96-98 has drifted by four lines. |
| AC13 | PASS | Fail-before: reverting the bundled copy to the merge-base version and rerunning the parity module failed `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`, reproduced by this reviewer, and is recorded in `evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md` and `evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md`. Pass-after: the case passes at head, and this reviewer independently derived the pair in PowerShell against the published table and observed `conflict = False`. |
| AC14 | PASS | Fail-before: with the bundled copy reverted, `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` failed, reproduced by this reviewer, and is recorded in `evidence/regression-testing/powershell-fail-open-repro.2026-08-21T23-12.md`. Pass-after: this reviewer derived two radii citing `package-lock.json` against the published table and observed `Get-ConfigRootSurface` returning the three-entry set `package-lock.json, poetry.lock, quality-tiers.yml`, the radius carrying `package-lock.json` as a real path, and `conflict = True` with both `path_overlap` and `shared_surface_overlap` reasons. The pass-after artifact's run 1 showing `conflict : False` is correctly explained in the artifact itself: research 5.3 cites `Directory.Build.targets` and `coverage.config`, neither of which is a member of the portable set, and root-surface membership is an exact ordinal match by design. Run 2 supplies the configured-token case the criterion names. |
| AC15 | PASS | Measured by this reviewer at head. Python 92.60% statements and 85.19% branches, thresholds 85% and 75%. TypeScript 96.66% lines and 90.04% branches. PowerShell 96.21% lines, exempt from the branch threshold because Pester emits no branch counter. All deltas against the Phase 0 baselines are 0.00. The one changed production file reads `LF:468 LH:468 BRF:48 BRH:46`, that is 100.00% lines and 95.83% branches. No `exclude`, `omit`, or ignore-pattern entry is added anywhere in the diff, and no coverage configuration file is touched. |
| AC16 | PASS | Discharged by this reviewer's eleven-stage pass at head `a95ae362`, recorded in `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T02-58.md`: Black, Ruff, Pyright, Pytest; Prettier, ESLint, tsc, Jest; PoshQC format, analyze, test. All exit 0, in one uninterrupted sequence against a clean tree, with no stage rewriting a file and no restart required. The executor's own `evidence/qa-gates/remediation-toolchain-single-pass.2026-08-21T21-49.md` records seven stages covering Python and PowerShell only, with TypeScript deliberately deferred; that gap is recorded as finding G6 in the policy audit and does not leave the criterion undelivered. |
| AC17 | PASS | `evidence/other/divergence-commit-walk.2026-08-21T21-47.md` records both `git log --follow --oneline` invocations with a per-commit key-shape table. Rerunning the bundled-copy walk at head returns the same three commits plus `59425465`, the branch's own. `evidence/other/routing-pair-byte-compare.2026-08-22T00-14.md` records SHA256 `D9C6657CBDBE15413E0FB9BC1BE700CE1A8F892D0DB413C3BBC253EA24EA7BDA` for both `orchestration-routing.json` copies; this reviewer recomputed the digest and obtained the same value on both files. |

---

## Summary

| Verdict | Count | Criteria |
|---|---|---|
| PASS | 16 | AC1, AC2, AC3, AC5, AC6, AC7, AC8, AC9, AC10, AC11, AC12, AC13, AC14, AC15, AC16, AC17 |
| PARTIAL | 1 | AC4 |
| FAIL | 0 | none |
| UNVERIFIED | 0 | none |

**Blocking findings: 1.**

The single blocker is documentation-only. Every behavioural requirement the seventeen criteria state is delivered, verified at head, and reproducible. AC4's data requirement is delivered in full; only its stated verification pointer names a file that carries neither of the assertions it cites. The correction is a single-token edit to `spec.md` followed by re-checking the box.

Two of the cycle's own exit conditions are now met and one is not:

1. AC9 names `test_blast_radius_config_parity.py` and cites a pytest invocation that collects the gate's cases; checkbox `[x]`. **Met.**
2. AC10 resolves to the same file and command; checkbox `[x]`. **Met.**
3. All seventeen criteria checked and each independently verifiable from its own stated command. **Not met**, because AC4 is not verifiable from its own stated command. AC4 has been unchecked accordingly.
4. Full toolchain passes in a single pass for every language with changed files, and coverage is unchanged or improved in all three coverage languages. **Met**, verified by the reviewer at head.
5. `blocking_count == 0`. **Not met**, `blocking_count == 1`.

Verification of the remediation's own claims, each performed independently rather than accepted:

| Item | Claim | Verdict |
|---|---|---|
| R1, R2 | AC9 and AC10 now name the parity file and cite a command that collects it, and re-checking is warranted | Confirmed. The cited command collects and passes all fifteen cases including every assertion the two criteria enumerate. |
| R3 | Corrected Class 2 mitigation sentence | Delivered in substance, with a residual unqualified clause recorded as a Minor finding. |
| R4 | Directional invariant closes the gap in both languages | Confirmed and shown general within its stated scope, not witness-specific. Both mirrors fail on an injected witness with equivalent messages, and both compute the same relation. Separator-bearing entries remain outside the invariant's selection by construction. |
| R5 | Corrected `spec_text` argument makes the recorded command reproduce its figures | Confirmed. Following the amended description verbatim produced 1182 edges and 31 cohorts post-change and 1199 edges and 33 cohorts pre-change over 56 items and 1540 pairs, matching the artifact exactly. |
| R6 | `-InputObject` form distinguishes a single-element list from a bare scalar and an empty list from an absent key | Confirmed for the first case. The second case was already distinguished under the pipeline form, so half the recorded rationale did not hold; the correction is sound regardless. |

One residual gap is recorded that no criterion covers and no remediation item raised: a new top-level key added to one copy and not the other is undetected by the three-class gate. It is a Major, non-blocking finding in the code review.

**Recommendation: no-go for PR authoring until AC4 is corrected and re-checked.**

---

## Acceptance Criteria Check-off

**Source file:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`

State on entry to this review: 17 of 17 checked.

Actions taken by this review:

| Criterion | Action | Reason |
|---|---|---|
| AC4 | `- [x]` changed to `- [ ]` at `spec.md:435` | Evaluated PARTIAL. The criterion is not independently verifiable from its own stated source, which names a file carrying neither the Class 2 nor the Class 3 assertion. |

No criterion was newly checked by this review, because none entered unchecked. No criterion text was modified. No criterion was added, removed, or renumbered; the count stays at seventeen.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
- Total AC items: 17
- Checked off (delivered): 16
- Remaining (unchecked): 1
- Items remaining: AC4, `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` declares exactly the 6-entry portable `shared_surfaces` set, empty `shared_surface_globs`, the four added `mandate_reads` entries, and `modules` exactly `{ "config": ["config/**"] }`. The data requirement is delivered; the criterion's stated verification names `tests/scripts/dev_tools/test_blast_radius_config.py`, which carries neither the Class 2 nor the Class 3 assertion.
