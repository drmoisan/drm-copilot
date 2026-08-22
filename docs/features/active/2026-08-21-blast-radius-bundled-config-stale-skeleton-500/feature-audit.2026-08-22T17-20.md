# Feature Audit: blast-radius bundled truth-table correction (Issue #500)

**Audit Date:** 2026-08-22
**Auditor:** feature-review
**Cycle:** remediation cycle 3 re-audit

## Scope and Baseline

- **Base branch:** `main`, resolved from the delegating prompt and confirmed against `artifacts/pr_context.summary.txt`, which records `Base ref (resolved): origin/main @ fb30a9a58b8422e610a09b07361421e97367807a`.
- **Merge base:** `fb30a9a58b8422e610a09b07361421e97367807a`, identical to the base tip, so the branch requires no rebase to be current.
- **Head:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `0610037bdfa90a8d77ee75a0f5d7dbb2b985cdb7`.
- **PR context freshness:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` both record head `0610037b` and were regenerated at `2026-08-22T11:17` local, after the head commit at `2026-08-22T11:16` local. They are current; no refresh was required.
- **Diff scope:** 153 files, 11,262 insertions, 53 deletions. 142 Markdown, 5 TypeScript, 2 Python, 2 PowerShell, 2 JSON.
- **Work mode:** `full-bug`, read from the `- Work Mode: full-bug` marker at line 12 of `issue.md`. The acceptance-criteria source is `spec.md` only. `user-story.md` does not exist in this folder and is correctly not consulted.
- **Audit scope:** the full branch diff against the merge base. The delegating prompt's "Specific scrutiny" list was explicitly framed as orientation rather than a scope limit, and no attempt to narrow scope, to exclude a language, or to skip a coverage check was present. There is therefore no rejected scope narrowing to record.

## Acceptance Criteria Inventory

The `## Acceptance Criteria` section of `spec.md` (lines 421 to 522) contains 17 checkbox items, all currently marked `[x]`. Numbered here in document order.

| # | Criterion, abbreviated | spec.md line |
|---|---|---|
| AC1 | `claude-blast-radius-derive-core.ts` declares `PAYLOAD_MODULES` as `{ config: ["config/**"] }` with no `claude-runtime`, and an `@remarks` block states why | 423 |
| AC2 | `blast-radius-derive-core.test.ts` no longer positively pins `claude-runtime`; a new case asserts the negative property against `FORBIDDEN_GLOBS` | 427 |
| AC3 | `blast-radius-derive.test.ts` expectations updated; `SOURCE_BLAST_RADIUS` and its doc comment mirror the corrected bundled file | 434 |
| AC4 | Bundled `blast-radius.json` declares the 6-entry portable `shared_surfaces`, empty `shared_surface_globs`, the four added `mandate_reads`, and `modules` exactly `{ "config": ["config/**"] }` | 440 |
| AC5 | `claude-config-carriage.test.ts` AC8 forbidden list no longer forbids `poetry.lock` or `package-lock.json`, with a rationale comment | 447 |
| AC6 | `config/blast-radius.json` `mandate_reads` carries the four added entries; its other keys are unchanged | 453 |
| AC7 | `.claude/rules/parallel-orchestration.md` records (a) derived module map, (b) `PAYLOAD_MODULES` carries `config` only, (c) the destination-portable surface subset with the asymmetry as the reason | 458 |
| AC8 | The bundled `parallel-orchestration.md` is byte-identical to the repo copy, in the same commit | 464 |
| AC9 | `test_blast_radius_config_parity.py` carries the three-class key-partition gate with constants and accessors in the sibling support module | 470 |
| AC10 | The same module asserts the five-name umbrella denylist over both copies, separator-free wildcard freedom, and a non-vacuity floor with `COMMITTED_CONFIGS` at exactly two members | 481 |
| AC11 | `BlastRadius.TruthTable.Tests.ps1` mirrors the Class 1 equality, the Class 3 subset, the five-name denylist over both copies, and the separator-free-wildcard-free assertion, and stays under 500 lines | 488 |
| AC12 | The comment in `declares no removed umbrella module in either committed copy` no longer claims the bundled map describes the destination's subsystems, and records that the key is never read | 492 |
| AC13 | Fail-before and pass-after regression evidence for the fail-closed direction | 499 |
| AC14 | Fail-before and pass-after regression evidence for the fail-open direction | 504 |
| AC15 | Coverage obligations met and recorded, with no `exclude` entry added | 508 |
| AC16 | Full toolchain pass in a single run for all three languages | 515 |
| AC17 | `git log --follow` evidence for both copies plus a `Get-FileHash` byte compare of the routing pair | 517 |

## Acceptance Criteria Evaluation

| # | Verdict | Evidence |
|---|---------|----------|
| AC1 | PASS | `git diff` on `claude-blast-radius-derive-core.ts` shows `"claude-runtime": [".claude/**"],` removed from `PAYLOAD_MODULES`, leaving `config: ["config/**"]`, with a 17-line `@remarks` block giving the granularity criterion, the path-level and shared-surface fallback, and the non-vacuity reason for retaining `config`. |
| AC2 | PASS | The positive pin now reads `expect(PAYLOAD_MODULES).toEqual({ config: ["config/**"] })`. The new case `declares no umbrella or forbidden glob in the payload module set` asserts `expect(names).not.toContain("claude-runtime")` and loops over `FORBIDDEN_GLOBS`, which is newly imported. All four seeded module-map expectations elsewhere in the file were updated. Jest: 2657 passed. |
| AC3 | PASS | Three seeded expectations in `blast-radius-derive.test.ts` updated; `SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts` rewritten to the six-entry surface set, the ten-entry `mandate_reads`, and the single `config` module, with a rewritten doc comment. Cycle 3 additionally bound the fixture to the on-disk resource, verified by five-class perturbation. |
| AC4 | PASS | Read directly from the file: `shared_surfaces` is exactly the six declared entries, `shared_surface_globs` is `[]`, `mandate_reads` carries the four added entries, `modules` is exactly `{"config": ["config/**"]}`. Pinned by Class 2 and Class 3 assertions in both languages; perturbing any of them fails at least one gate. |
| AC5 | PASS | `poetry.lock` and `package-lock.json` were removed from the forbidden-substring loop, and a 12-line rationale comment states the retained criterion and the surfaces-versus-modules asymmetry that justifies the removal. |
| AC6 | PASS | The `config/blast-radius.json` diff against merge base is exactly the four added `mandate_reads` entries. No other key changed. |
| AC7 | PASS | The 63-line rule addition carries three bolded paragraphs matching (a), (b), and (c), plus the asymmetry paragraph and the separator-free-surface weight. |
| AC8 | PASS | `cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` exits 0. Both were introduced in commit `59425465`. |
| AC9 | PASS | 16 collected tests in the parity module; constants and the four accessors live in `blast_radius_parity_test_support.py` (189 lines) and the assertion module is 469 lines, both under the limit. Class 1, Class 2, and Class 3 assertions are each present and each was driven to failure by perturbation. |
| AC10 | PASS | `test_no_committed_copy_declares_an_umbrella_module` is parametrized over `COMMITTED_CONFIGS`; `test_every_separator_free_bundled_shared_surface_is_wildcard_free` guards its own selection against vacuity; `test_the_gate_compares_non_empty_collections` asserts `len(COMMITTED_CONFIGS) == 2` and six named non-empty collections plus `mandate_reads` in both copies. |
| AC11 | **PARTIAL** | The named file carries the Class 3 subset (`declares only payload modules in the bundled copy`), the five-name denylist (`declares no removed umbrella module in either committed copy`), and the separator-free-wildcard-free assertion, and is 325 lines. It does **not** carry the Class 1 equality: cycle 3 moved `declares equal values for the runtime-describing keys in both copies` to `BlastRadius.KeyPartition.Tests.ps1:50`. The criterion's substance is delivered across the two files; its text is false for the file it names. |
| AC12 | PASS | The comment in that case now reads that the bundled module map "is never read", that `assembleModules` derives a destination's map from the destination's own layout, that `PAYLOAD_MODULES` is the live source, and that the former exemption "was not true". The case itself was widened to walk both copies. |
| AC13 | PASS | Fail-before at `evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md`, tagged `[expect-fail]`; pass-after at `evidence/qa-gates/powershell-fail-closed-pass-after.2026-08-22T00-10.md` with `EXIT_CODE: 0`. The reviewer independently re-derived the underlying relation: with `claude-runtime` removed from the bundled map, two items citing unrelated `.claude/**` files no longer contend. |
| AC14 | PASS | Fail-before at `evidence/regression-testing/powershell-fail-open-repro.2026-08-21T23-12.md`; pass-after at `evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md` with `EXIT_CODE: 0`. The reviewer confirmed the standing relation independently: the bundled `shared_surfaces` now carries three separator-free entries, and Group E cell E2 shows that removing the self-hosted-to-bundled path for a separator-free surface fails the directional invariant. |
| AC15 | PASS | Re-measured at head by this reviewer, not accepted from the executor's artifacts: Python 92.60% line and 85.19% branch; TypeScript 96.66% line and 90.04% branch; PowerShell 96.21% line. The one changed production module reads 100.00% lines and 95.83% branches. `git diff` over `pyproject.toml`, `jest.config.cjs`, and `pester.runsettings.psd1` is empty for the branch, so no `exclude` entry was added. |
| AC16 | PASS | All eleven checks pass in a single pass with no restart: Black, Ruff, Pyright, Pytest; Prettier, ESLint, tsc, Jest; PoshQC format, analyze, test. `git status --porcelain` is empty after the formatter, so no stage rewrote a file. |
| AC17 | PASS | `evidence/other/divergence-commit-walk.2026-08-21T21-47.md` records the `git log --follow` walk for both copies; `evidence/other/routing-pair-byte-compare.2026-08-22T00-14.md` records the SHA256 `Get-FileHash` comparison of the routing pair. The reviewer independently reproduced the routing comparison with `cmp`, exit 0. |

### Verification that cycle 3 did not touch the acceptance criteria

`git diff a9b0484d..HEAD -- spec.md` shows 3 insertions and 1 deletion, all inside the `## Test Strategy` section at lines 386 to 411: a parenthetical noting that the fail-open test was delivered under PD-1 in the sibling parity module, and the addition of `test_blast_radius_config_parity.py` to the recorded pytest invocation. Neither edit touches the `## Acceptance Criteria` section at lines 421 to 522. No checkbox was changed by cycle 3. `issue.md` is unchanged by cycle 3. The constraint held.

## Summary

Sixteen of the seventeen acceptance criteria PASS, all verified at head by direct inspection, by the reviewer's own toolchain run, or by perturbation rather than by accepting the executor's artifacts.

One criterion, AC11, is PARTIAL. Cycle 3 split `BlastRadius.TruthTable.Tests.ps1` at 496 lines and moved the `Cross-copy key partition` Context, including the Class 1 equality case, into `BlastRadius.KeyPartition.Tests.ps1`. The split itself is sound — 20 cases before, 16 plus 4 after, no case lost or duplicated, both files passing standalone — but it left AC11's text describing a file that no longer carries one of the four mirrors it names.

The three substantive cycle-3 repairs (CR-1, CR-2, CR-4) are verified. One cycle-3 claim, CR-3, is not supported: the silent-pass direction it names remains open in all three languages. Cycle 3 also introduced four stale file pointers in the two `parallel-orchestration.md` copies. Neither is a defect in the shipped fix; both are recorded in `code-review.2026-08-22T17-20.md` and routed to `remediation-inputs.2026-08-22T17-20.md`.

**Blocking findings: 0.** The feature is functionally complete and independently verified. Remediation is triggered by the PARTIAL criterion and by the unsupported CR-3 claim.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
- Total AC items: 17
- Checked off (delivered): 16
- Remaining (unchecked): 1
- Items remaining: AC11 — `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` mirrors the Class 1 equality, the Class 3 subset, the five-name umbrella denylist applied to both copies, and the separator-free-wildcard-free assertion, and stays under the 500-line limit.

## Acceptance Criteria Check-off

No checkbox was modified by this review.

- The 16 criteria evaluated PASS were already `[x]` in `spec.md` before this review. No check-off action was required.
- AC11 evaluated PARTIAL. Its checkbox is currently `[x]`, which does not match this evaluation. Per `acceptance-criteria-tracking`, a PARTIAL item is left unchecked; the skill provides no instruction for reverting an existing check, and reverting one would edit a scoping document during review. This reviewer therefore records the discrepancy here and in `remediation-inputs.2026-08-22T17-20.md` rather than editing `spec.md`. The correct resolution is for the remediation cycle to either amend AC11's text to name both Pester files or move the Class 1 case back into the file AC11 names, and then to re-assert the checkbox on evidence.
- The counts above therefore report the audited state (16 delivered, 1 outstanding), not the raw checkbox count in the file (17 checked).
