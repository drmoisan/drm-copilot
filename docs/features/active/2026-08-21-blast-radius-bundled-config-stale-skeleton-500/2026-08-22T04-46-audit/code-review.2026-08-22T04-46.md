# Code Review: blast-radius bundled truth-table correction (#500)

**Review Date:** 2026-08-22
**Reviewer:** feature-review
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Feature Folder Selection Rule:** the folder whose `-500` suffix matches the issue number in the branch name `bug/blast-radius-bundled-config-stale-skeleton-500`; it is also the only active folder the branch modifies.
**Base Branch:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
**Head Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `fc9a3a26`
**Review Type:** Post-remediation re-review, remediation cycle 2

---

## Executive Summary

The branch corrects a stale published artifact and the constant that feeds it, then builds a drift gate so the staleness cannot recur silently. Two committed copies of `config/blast-radius.json` exist: the self-hosted one governing this repository, and the one the Claude push-down publishes into a destination workspace. The published copy had fallen three changes behind: it retained the `claude-runtime -> .claude/**` umbrella that issue #489 removed here, it declared 3 shared surfaces instead of a portable 6 with no separator-free entry at all, and its `mandate_reads` list was 4 entries short. The first defect fails closed, forcing unrelated agent work items to contend. The second fails open, letting two items rewriting the same root lockfile schedule concurrently. Cycle 0 fixed both and added a three-class key-partition gate in Python mirrored in PowerShell. Cycle 1 added a directional separator-free invariant. Cycle 2, the subject of this review, added key-set exhaustiveness in both languages, corrected the last stale acceptance-criterion pointer, qualified an overclaiming mitigation sentence, retired five stale line anchors, added a Pester non-vacuity case, and recorded the folder's timestamp convention.

Every cycle-2 claim was verified by perturbation rather than by reading. Nine injections were applied to the two committed truth tables and restored, with the measured output of each recorded in `evidence/qa-gates/reviewer-perturbation-battery.2026-08-22T04-46.md`. The exhaustiveness gate is genuinely falsifiable in both of its relations and in both languages. The AC4 correction is complete and the sweep behind it holds. The overall engineering quality is high: the assertions accumulate before failing so one run reports the whole delta, each language's case names its counterpart by test name, and the executor proved falsifiability by injection rather than observing a green run.

**What changed:**

Twelve non-documentation files. `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` is reduced to one payload module and widened to the 6-entry portable surface set; `config/blast-radius.json` gains four `mandate_reads` entries and nothing else; `claude-blast-radius-derive-core.ts` reduces `PAYLOAD_MODULES` to `config` with an `@remarks` block giving the reason; `.claude/rules/parallel-orchestration.md` gains a 63-line subsection, byte-identical in its bundled mirror; `test_blast_radius_config_parity.py` and `blast_radius_parity_test_support.py` add 641 lines carrying 16 cases; `BlastRadius.TruthTable.Tests.ps1` adds 197 lines carrying the mirrored cases; four TypeScript test files drop their positive `claude-runtime` pins and add two negative properties.

**Top 3 risks:**

1. The Pester non-vacuity floor added by R12 cannot fail for the condition its own comment names, so the mirror relation R12 was opened to restore is not restored. Finding CR-1.
2. The Pester mirror has no non-vacuity floor at all for the bundled module map, so divergence direction 13 stays covered in Python only. Finding CR-2.
3. `SOURCE_BLAST_RADIUS` states that it mirrors the committed bundled resource key for key, and nothing enforces that. A future correction to the resource can leave the TypeScript fixture behind without any test noticing. Finding CR-4.

**PR readiness recommendation:** **Go** — all seventeen acceptance criteria pass, all eleven toolchain stages pass in one uninterrupted run, coverage is unchanged in all three coverage languages, and the two Major findings are redundancy defects in a mirror rather than detection holes in the pipeline.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | lines 345-362, `requires the shared-surface lists compared by the directional invariant to be non-empty` | The case comment states it guards against a renamed `shared_surfaces` key making the directional invariant pass vacuously. It cannot. It reads `@($script:CommittedConfig['shared_surfaces']).Count` and asserts `Should -BeGreaterThan 0`; a hashtable index on an absent key yields `$null` and `@($null).Count` is `1`, so the assertion holds for exactly the input it claims to reject. It can fail only for an explicitly empty list. | Assert `ContainsKey('shared_surfaces')` on both copies and that each value is an enumerable with at least one element, then re-run perturbation P4 and observe the case fail before accepting the fix. | R12's stated requirement was that "the two mirrors respond the same way to the same malformed input". They do not: the Python floor fails on this input and the Pester floor passes. An assertion that cannot fail for its documented reason misleads the next maintainer about what is protected. | Perturbation P4: with `shared_surfaces` renamed in the bundled copy, Pester reported `PASSED=17 FAILED=3` and this case was among the seventeen passing. Direct measurement under `pwsh -NoProfile`: `@($null).Count` returns `1`, `@(@()).Count` returns `0`. |
| Major | `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | `Context 'Cross-copy key partition'` and `Context 'Module map'` | The mirror carries no non-vacuity floor for the bundled `modules` map. An empty bundled module map satisfies `declares only payload modules in the bundled copy` because the empty set is a subset, and satisfies `maps every module to a non-empty glob list` because it iterates zero entries. | Extend the same floor case to assert both copies declare at least one module, matching the `module_names` entries the Python floor already pins. | Divergence direction 13 from the cycle-1 enumeration, a key renamed so an accessor returns empty and the gate passes vacuously, remains covered in Python only. Closing that asymmetry was R12's purpose. | Perturbation P5: with the bundled `modules` replaced by an empty object, pytest reported `1 failed, 15 passed` firing `test_the_gate_compares_non_empty_collections` with `assert ()`, while Pester reported `PASSED=20 FAILED=0`. |
| Minor | `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | lines 106-112, `DECLARED_TOP_LEVEL_KEYS` | The constant is derived from `BYTE_EQUAL_KEYS` for Class 1 only. The Class 2 and Class 3 names are string literals restated in the constant and bound to no assertion, so adding a name there silences the exhaustiveness gate with no compensating check. The Pester mirror at line 311 restates all six names, so the "cannot go stale" property does not hold on the PowerShell side at all. | Derive the Class 2 and Class 3 names from module-level tuples that the Class 2 and Class 3 assertions themselves consume, so a name cannot enter the declared set without an assertion reading it. | Graded Minor rather than Major because every accidental drift direction fails safe: removing a name from `BYTE_EQUAL_KEYS` makes its key unclassified and fails loudly, adding one adds a real parametrized equality assertion, and a schema rename becomes unclassified in both languages. The residual requires a deliberate edit of the literal set. | Read of `blast_radius_parity_test_support.py:106-112` and `BlastRadius.TruthTable.Tests.ps1:311-312`; perturbations P1 and P2 confirmed the fail-safe directions. |
| Minor | `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | lines 61-110, `SOURCE_BLAST_RADIUS` and its doc comment | The doc comment states the constant "mirrors the corrected bundled copy at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` key for key". No test reads that resource, so the claim is unenforced and the fixture can silently diverge from the document it represents. | Add one Jest case asserting `JSON.parse(SOURCE_BLAST_RADIUS)` deep-equals the parsed committed resource, or read the resource at test time instead of duplicating it. | The shipped document is pinned by the Python and Pester gates, so this is a fixture-fidelity gap rather than a production drift gap. It is nonetheless a seventeenth divergence direction, outside the sixteen the cycle-1 enumeration covered. | Perturbation P9: appending `config/drifted-entry.json` to the bundled `shared_surfaces` left `node run-jest.cjs test/lib/push-down` at `15 suites, 222 tests passed` and the full `node run-jest.cjs` at `195 suites, 2656 tests passed`, both exit 0. |
| Minor | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | lines 388 and 412, `## Test Strategy` | Two pointers predating plan deviation PD-1 survive. Line 388 states the natural home for the fail-open regression is `test_blast_radius_config.py`; line 412's toolchain command selects `test_blast_radius_config.py` and `test_push_down_claude_resource_contracts.py` but not the parity module that actually carries the gate. | Point line 412's command at `tests/scripts/dev_tools/test_blast_radius_config_parity.py` alongside the other two modules, and mark line 388 as the pre-PD-1 intent. | Same pointer-staleness class as R7, and it would mislead a reader who follows the Test Strategy rather than the criteria. Not Blocking because both sit outside the acceptance-criteria section spanning lines 419-520, so no criterion is falsified. | `grep -n -F "tests/scripts/dev_tools/test_blast_radius_config.py" spec.md` returns lines 249, 285, 388, 391, 412, 470. Of these only 470 falls inside 419-520, and `spec.md:391`'s citation of `test_blast_radius_config.py:474-499` was checked and is accurate. |
| Minor | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/` | the eighteen artifacts stamped `2026-08-21T21-49` | R11's disposition, a convention note without renames, is adequate for its stated purpose, but two residuals persist. The eighteen filenames sort before the Phase 0 baselines stamped `22-47` through `22-52` that they postdate, so filename ordering reconstructs the cycle backwards; and the `Timestamp:` field inside each of the eighteen carries the same local value, so the discrepancy is invisible from any single artifact. | Add a one-line pointer to `evidence/other/timestamp-clock-convention.2026-08-22T03-37.md` in each of the eighteen, which preserves every existing cross-reference by name. | Renaming was correctly rejected because the plan and both prior audits cite these files by name. A pointer inside each file resolves the provenance question without moving anything. | `ls evidence/*/*2026-08-21T21-49*` returns exactly 18 paths, confirming the convention note's correction from twenty. `head -4` of two samples shows the local value repeated in the `Timestamp:` field. |
| Info | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/code-review.2026-08-22T02-58.md` | the Drift-Direction Coverage Analysis table, row 10 | This reviewer's cycle-1 entry recorded direction 10, a change to the self-hosted `modules` map, as "No, by design". That is inaccurate. | No branch change required; the correction is recorded here and in the policy audit. | Left uncorrected, the table would understate the gate's coverage and could justify weakening a pin that is actually load-bearing. | Perturbation P7: injecting a `newsub` module into the self-hosted map produced Pester `PASSED=19 FAILED=1`, `FAILED: retains exactly the seven ratified subsystem modules`. |

No Blockers.

---

## Drift-Direction Coverage Analysis, re-enumerated at head `fc9a3a26`

The cycle-1 re-audit enumerated sixteen divergence directions. Each is re-evaluated below against the current state, and a seventeenth is added. Every "Yes" that changed this cycle, and every "No" that persists, was confirmed by perturbation rather than by reading.

| # | Direction | Detected | By what, and what changed this cycle |
|---|---|---|---|
| 1 | Bundled `version`, `over_breadth_fraction`, or `mandate_reads` changes alone | Yes | Class 1 equality, both languages. Unchanged. |
| 2 | Self-hosted `version`, `over_breadth_fraction`, or `mandate_reads` changes alone | Yes | Class 1 equality, both languages. Confirmed again by P8, which fired the `mandate_reads` parameter. |
| 3 | Bundled `shared_surfaces` gains or loses an entry | Yes | Class 2 equality against `PORTABLE_SHARED_SURFACES`. Confirmed by P8. |
| 4 | Self-hosted `shared_surfaces` gains a separator-free entry not carried to the bundle | Yes | The cycle-1 directional invariant. Confirmed still firing by P3, P4, and P8. |
| 5 | Self-hosted `shared_surfaces` gains a separator-bearing entry not carried to the bundle | No, by design | Confirmed still uncovered by P6: injecting `config/new-portable-surface.json` left pytest at `49 passed` and Pester at `20 passed`. The decision remains defensible. `PORTABLE_SHARED_SURFACES` is a deliberate declaration rather than a derived set, and an unmatched surface entry is inert in a destination, so erring narrow costs nothing. R9 has now qualified the spec's mitigation clause, so the documentation no longer overclaims what direction 4 closes. |
| 6 | Self-hosted `shared_surfaces` loses an entry the bundle still declares | Yes | `bundled <= self_hosted` in Class 2. Unchanged. |
| 7 | Bundled `shared_surface_globs` becomes non-empty | Yes | Class 2 emptiness assertion. Unchanged. |
| 8 | Self-hosted `shared_surface_globs` changes | No, by design | Confirmed still uncovered by P7 in both languages. Still defensible: every self-hosted glob is a `scripts/dev_tools` pattern naming this repository's own Python module families, so it describes no destination and an empty bundled list stays correct however the self-hosted list moves. A glob is also never a source of root-token acceptance, so nothing about the fail-open direction depends on it. |
| 9 | Bundled `modules` gains a name outside the payload set | Yes | Class 3 subset plus the five-name umbrella denylist over both copies. Confirmed by P8, which fired both. |
| 10 | Self-hosted `modules` changes | **Yes, correcting the cycle-1 entry** | The pre-existing Pester case `retains exactly the seven ratified subsystem modules` fires. P7 produced `Expected @('benchmarks', ... 'schemas'), but got @(... 'newsub' ...)`. The cycle-1 table recorded this as uncovered by design; that was wrong. |
| 11 | `PAYLOAD_MODULES` gains an umbrella or a forbidden glob | Yes | `blast-radius-derive-core.test.ts:466`, the case `declares no umbrella or forbidden glob in the payload module set`, which asserts the negative property in addition to the positive pin. Unchanged. |
| 12 | Either copy stops parsing or declares a version other than 1 | Yes | `test_every_committed_copy_parses_and_declares_schema_version_one`, parametrized over both copies. Unchanged. |
| 13 | A gate key is renamed or emptied so an accessor returns empty and the gate passes vacuously | **Partially, Python only** | R12 was intended to close this. It does not. P4 showed the new Pester floor passing on a renamed bundled `shared_surfaces` key, and P5 showed the whole Pester file passing on an emptied bundled `modules` map that the Python floor catches. Findings CR-1 and CR-2. The renamed-key case is nonetheless not silent overall: P3 and P4 each produced three to five other Pester failures, and the Python side raises `TypeError` at collection. |
| 14 | A new top-level key is added to one copy and not the other | **Yes, newly** | `test_every_top_level_key_is_classified_and_shared_by_both_copies` and its Pester mirror. P1 fired both, each naming `new_top_level_key`. This was the cycle-1 Major finding and it is now closed. |
| 15 | A new top-level key is added to both copies but claimed by no declared class | **Yes, newly** | The second assertion of the same case in both languages. P2 fired both. The cycle-1 table folded this into row 14; it is a distinct relation and is listed separately here because the two are falsifiable independently. |
| 16 | The two `parallel-orchestration.md` copies diverge | Yes | `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `10 passed`. Independently confirmed here by `cmp`, exit 0. |
| 17 | The two `orchestration-routing.json` copies diverge | Yes | An existing Jest assertion, independently confirmed here by `cmp`, exit 0, and by the executor's `Get-FileHash` evidence showing identical SHA256 digests. |
| 18 | `SOURCE_BLAST_RADIUS` diverges from the bundled resource it claims to mirror | **No** | Nothing. Newly identified in this re-audit; P9 showed the whole 2656-test Jest suite passing against a drifted resource. Finding CR-4. |

Plain answer to the question the delegating prompt asked: **one direction is genuinely uncovered and it is newly identified, number 18. Direction 13 is now half-covered rather than fully covered.** Directions 5 and 8 remain deliberately uncovered and both decisions are still defensible now that the gate has grown, for the reasons given in their rows. Direction 10 was never uncovered; the cycle-1 classification was wrong.

---

## Assertion Interaction Analysis

The delegating prompt asked whether the two new assertions can overlap or interact badly with the existing five, whether one can pass because another already failed, and whether a single edit can satisfy one while silently violating another. Three questions, answered separately.

**Can one assertion pass because another failed?** No. Pytest executes each test function independently, and a failure in one produces no state a later function reads: every case reads the two module-level parsed mappings, which are immutable and constructed once at import. Pester executes each `It` independently against `$script:CommittedConfig` and `$script:BundledConfig` from the Describe-level `BeforeAll`, and neither new case mutates them. Perturbations P1 through P5 each produced a failing set whose complement passed for reasons independent of the failure, which is the observable form of this property.

Within the single exhaustiveness case, the two assertions short-circuit: assertion 1 aborts the case before assertion 2 runs, in both languages. That is masking of a *message*, not of an *outcome* — the case still fails. P1 and P2 exercised the two orderings and each produced the message belonging to the relation that was actually violated.

**Can a single edit satisfy one assertion while silently violating another?** Two edits were examined and both fail loudly:

- Adding a key to both copies and to `BYTE_EQUAL_KEYS`. Exhaustiveness then passes because the key is classified, and the Class 1 parametrization gains a real equality assertion for it. No silent state.
- Renaming a schema key in both copies and updating the accessor. Exhaustiveness fails, naming the new key as unclassified. P2 is the general form of this.

One edit does produce a silent state, and it is the residual behind CR-3: adding a name to the Class 2 and Class 3 literal set inside `DECLARED_TOP_LEVEL_KEYS`. That silences exhaustiveness for the named key while no Class 2 or Class 3 assertion reads it. It requires a deliberate edit of a constant whose comment states its purpose, so it is a Minor rather than a Major.

**Do the assertions overlap redundantly?** Partly, and beneficially. The exhaustiveness case subsumes the renamed-key detection that previously relied on `TypeError` propagation from `load_module_globs` and `require_string_list` — P3 and P4 showed the exhaustiveness case failing alongside the accessor-driven failures. The overlap is defence in depth rather than duplication, because the two mechanisms produce different messages: one names the key, the other names the malformed type.

---

## Is `DECLARED_TOP_LEVEL_KEYS` genuinely derived?

Tested rather than read. The constant is:

```python
DECLARED_TOP_LEVEL_KEYS = frozenset(BYTE_EQUAL_KEYS) | frozenset(
    {"shared_surfaces", "shared_surface_globs", "modules"}
)
```

One of its three classes is derived; two are restated. The behaviour that follows was checked against each way class membership can change:

| Change to class membership | Effect on `DECLARED_TOP_LEVEL_KEYS` | Outcome |
|---|---|---|
| A key is added to `BYTE_EQUAL_KEYS` and to both copies | The set grows automatically | Passes, and the Class 1 parametrization gains a real equality assertion for the key. Correct. |
| A key is removed from `BYTE_EQUAL_KEYS` and stays in both copies | The set shrinks automatically | The key becomes unclassified and the case fails naming it. Correct and loud, which is the fail-safe direction. |
| A key moves from Class 1 to Class 2 or Class 3 | The set is unchanged only if the literal set is edited in the same commit | If the literal set is not edited, the key becomes unclassified and fails loudly. Correct. |
| A key is added to Class 2 or Class 3 and to the literal set, with no assertion | The set grows by hand | **Passes silently.** This is the residual recorded as CR-3. |
| A schema key is renamed in both copies and the accessor updated | The set is unchanged | The new name is unclassified and fails loudly. Confirmed by P2's general form. |

The claim "it cannot go stale because it is computed from `BYTE_EQUAL_KEYS`" is therefore true for the Class 1 third and false for the other two thirds, and false outright for the Pester mirror, whose `$declaredTopLevelKey` restates all six names as literals. The practical consequence is bounded: every accidental drift direction fails loudly, and the one silent direction requires editing the constant on purpose. The rule text does not repeat the derivation claim, so no policy document is inaccurate; only the commit message is broader than the code.

---

## The Pester mirrors

There are now seven cross-copy cases in `BlastRadius.TruthTable.Tests.ps1`. Each was compared against its Python counterpart and, where a perturbation could distinguish them, driven with the same injected witness in both languages.

| Pester case | Python counterpart | Asserts the same relation | Same response to the same malformed input |
|---|---|---|---|
| `declares equal values for the runtime-describing keys in both copies` | `test_class_one_keys_are_equal_across_both_committed_copies` | Yes. Both compare `version`, `over_breadth_fraction`, and `mandate_reads`. The Pester form serializes with `ConvertTo-Json -InputObject ... -Depth 10 -Compress` and compares with `-cne`, which is value equality over the same three keys. | Yes, P8 fired both. |
| `declares only payload modules in the bundled copy` | `test_class_three_bundled_modules_are_payload_modules_only` | Yes, subset against `@('config')` versus `PAYLOAD_MODULE_NAMES`. | Yes, P8 fired both. |
| `declares no removed umbrella module in either committed copy` | `test_no_committed_copy_declares_an_umbrella_module` | Yes, the same five names over both copies, ordinal comparison on both sides. | Yes, P8 fired both. |
| `gives every separator-free bundled shared surface no wildcard` | `test_every_separator_free_bundled_shared_surface_is_wildcard_free` | Yes, including the non-empty precondition on the selection. | Yes, P4 and P8 fired both. |
| `requires every separator-free self-hosted shared surface to reach the bundled copy` | `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` | Yes, reverse containment restricted to separator-free entries. | Yes, P3, P4, and P8 fired both. |
| `requires every top-level key in both copies to be classified and shared` | `test_every_top_level_key_is_classified_and_shared_by_both_copies` | Yes, both relations: symmetric-difference emptiness and union-minus-declared emptiness. The declared set is a literal on the Pester side, which is CR-3. | Yes, P1, P2, P3, and P4 fired both. |
| `requires the shared-surface lists compared by the directional invariant to be non-empty` | `test_the_gate_compares_non_empty_collections` | **No.** The Python case pins six named collections plus `len(COMMITTED_CONFIGS) == 2` plus a non-empty-list check on `mandate_reads` in both copies. The Pester case pins two `shared_surfaces` counts and nothing else. | **No.** P4 and P5 both fired the Python floor and left the Pester file green. Findings CR-1 and CR-2. |

Direct answer to the question asked: six of the seven mirrors assert what their Python counterpart asserts and respond identically to the same malformed input. The seventh does not, and the non-vacuity floor R12 added does not prevent the vacuous-pass mode it names, because `@($null).Count` is `1` in PowerShell.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The split forced by PD-1 is a clean one. `blast_radius_parity_test_support.py` holds only inert data and four read-only accessors, and its module docstring states that no assertion lives there. `test_blast_radius_config_parity.py` holds every assertion. The split was forced by the 499-line ceiling on `test_blast_radius_config.py`, but the resulting shape is better than a single file would have been.
- Shared helpers are imported rather than duplicated. `BUNDLED_CONFIG_PATH`, `CONFIG_PATH`, `load_config_file`, `load_module_globs`, `BUNDLED_CONFIG_LABEL`, and `COMMITTED_CONFIGS` all come from the pre-existing module, so a rename there surfaces as an `ImportError` rather than as two definitions drifting.
- Failure messages accumulate. Every absence assertion collects its offenders into a sorted list and asserts on the list, so a single run reports the whole delta. This was observed directly: P1's message named the symmetric difference rather than the first differing key.
- The presence assertion in `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` is scoped correctly. Its comment explains that a tuple-equality assertion over all reasons would fail against the fixed state, because a corrected table also reports `path_overlap` for the same token. Asserting membership of the specific `(kind, detail)` pair is the right choice and the reason is recorded.

#### Typing and API notes

Pyright reports 0 errors, 0 warnings, 0 informations at strict settings. Every constant and every function signature in both new modules is annotated. `DECLARED_TOP_LEVEL_KEYS` is inferred `frozenset[str]` from two `frozenset` operands. The two `cast("list[object]", value)` calls in the accessors follow an `isinstance(value, list)` narrowing and are the standard idiom for that narrowing in this repository. No new public API is added; both modules are test-tree only.

#### Error handling and logging

No new failure path is introduced. The accessors return empty collections for an absent or malformed key by design, and the docstring on `shared_surfaces` states the design reason: "Returning empty rather than raising leaves the non-vacuity floor responsible for detecting a renamed key, which keeps the failure message specific." That is a coherent division of responsibility, and P5 confirmed the floor holds up its end on the Python side. `module_names` deliberately does not soften `load_module_globs`, so a malformed module map raises rather than passing empty. The asymmetry between the two is intentional and is documented in the `Raises` sections.

### TypeScript implementation audit

#### What changed well

- The negative property in `declares no umbrella or forbidden glob in the payload module set` is the right complement to the positive pin, and its comment says why: "the pin would still pass if a maintainer edited both the constant and the pin together, whereas this case states the property that must hold for any future payload module set."
- The `@remarks` block on `PAYLOAD_MODULES` records why `config` is retained rather than emptied, including the non-vacuity argument for `assertNoForbiddenGlob`. That is the kind of reason a later maintainer would otherwise have to reconstruct.
- The AC5 correction to the forbidden-substring list is argued rather than asserted. The comment distinguishes an entry naming this repository's directory layout, which must never reach a destination, from an ecosystem-standard root filename, which any Python or Node destination may legitimately carry, and grounds the distinction in the surfaces-versus-modules asymmetry.

#### Type safety and maintainability

`tsc -p ./ --noEmit` and ESLint both exit 0. No `any` is introduced and no suppression is added. `PAYLOAD_MODULES` keeps its `Readonly<Record<string, ReadonlyArray<string>>>` annotation, so the value change is invisible to every call site.

The one maintainability concern is CR-4: `SOURCE_BLAST_RADIUS` duplicates the bundled resource by hand while claiming to mirror it key for key.

#### Error handling and logging

No boundary behaviour changed. `assembleModules` iterates `Object.entries(PAYLOAD_MODULES)` exactly as before; only the constant's contents differ.

### PowerShell implementation audit

#### What changed well

- Both added cases sit in the correct `Context`, accumulate offenders into a `System.Collections.Generic.List[string]` before asserting, and use ordinal comparison operators (`-cnotcontains`) matching the case-sensitive semantics of the Python frozensets they mirror.
- Each added case names its Python counterpart by test name and file path in a comment. That is what makes a future divergence findable, and it is the reason this review could check mirror fidelity case by case.

#### API and safety notes

No advanced function, parameter block, or `ShouldProcess` surface is added; the change is test code only. `Invoke-PoshQCAnalyze` reports no findings across the repository.

#### Error handling and logging

The two added cases index `$script:CommittedConfig` and `$script:BundledConfig` directly rather than through an accessor. For the exhaustiveness case that is correct: `.Keys` on a hashtable is total. For the non-vacuity case it is the source of CR-1, because `@($null).Count` silently yields `1` where the author expected `0`.

### C# implementation audit

Not applicable. The branch changes zero C# files.

---

## Test Quality Audit

The branch adds 16 Python cases, 7 PowerShell cross-copy cases, and 2 TypeScript cases, and it removes every positive `claude-runtime` pin from the TypeScript fixtures. Regression evidence exists for both failure directions in both `evidence/regression-testing/` and `evidence/qa-gates/`, and this review reproduced both independently by reverting the bundled copy to its merge-base state.

The falsifiability discipline is real and was re-verified, not accepted. Cycle 2's executor did not add the exhaustiveness invariant and observe it pass; it injected a synthetic key into one copy, observed each half fail while naming the key, restored with the restore proven by `git status`, and reran green. This reviewer repeated that procedure independently and reproduced both failures and both passes, then extended it with seven further injections the executor did not run. Two of those seven are what produced CR-1 and CR-2.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_config_parity.py` — 16 cases, `16 passed` in 0.08s alone and `48 passed` with the base module. Fourteen of the sixteen were driven to failure by at least one perturbation in this review; the two that were not are the empty-glob case and the bundled parse-and-version case, both of which require a malformed input outside the battery's scope.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` — 20 cases, all passing, 446 lines. Six of the seven cross-copy cases were driven to failure; the seventh is CR-1.
- `extensions/drm-copilot/test/lib/push-down/*.test.ts` — 222 cases across 15 push-down suites, all passing, inside a full run of 2656.
- `evidence/regression-testing/python-key-exhaustiveness-fail-before.2026-08-22T03-37.md` and `.../powershell-key-exhaustiveness-fail-before.2026-08-22T03-37.md` — both record `EXIT_CODE: 1` with `ExpectedExitCode: 1` and quote the rendered failure message. Both messages were reproduced verbatim in this review.
- `evidence/qa-gates/python-key-exhaustiveness-pass-after.2026-08-22T03-37.md` and its PowerShell sibling — both record the restore proven by `git status --short` producing no output.
- `evidence/qa-gates/remediation-toolchain-single-pass.2026-08-22T03-37.md` — seven stages, all exit 0. Covers Python and PowerShell only; the reviewer's own eleven-stage pass covers TypeScript as well.
- `evidence/qa-gates/coverage-delta-verification.2026-08-22T03-37.md` — deltas of 0.00, reproduced exactly.
- `evidence/other/timestamp-clock-convention.2026-08-22T03-37.md` — the R11 note; its corrected count of eighteen was confirmed by enumeration.

### Quality assessment prompts

- **Determinism:** `COMPUTED_AT` is a fixed constant rather than a clock read, no randomness is introduced, and no sleep or timer API appears in the diff. Every case reads committed files only.
- **Isolation:** each case targets one relation. Perturbations P1, P2, and P5 each fired exactly one Python case out of 48, which is the observable form of isolation.
- **Speed:** 0.08s for the parity module, about 1.2s for the Pester file, 6.96s for the full Jest run, 19.44s for the full pytest run.
- **Diagnostics:** measured rather than inferred. Every failure message observed in the battery named the offending key, entry, or module and the repo-relative label of the offending copy.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | The branch adds no credential, token, connection string, or `.env` file. The two configuration files contain only path globs, filenames, and a numeric fraction. |
| No unsafe subprocess or command construction | PASS | No added line in any language invokes a subprocess, shell, or process-start API. Both new Python modules' docstrings state that no external process is started. |
| Input validation at boundaries | PASS | `load_config_file` raises `TypeError` on a non-object root and `load_module_globs` raises on an absent or malformed `modules` key. Perturbation P3 exercised the raise path and produced `TypeError: config["shared_surfaces"] must be a list, got NoneType.` at collection time. |
| Error handling remains explicit | PASS | No broad exception handler is added anywhere in the diff, and no failure is swallowed. |
| Configuration and path handling is safe | PASS | Every path in both truth tables is repo-relative; the Pester case `lists every shared surface as a repo-relative path` pins that property and fired under P3. No absolute path, drive letter, or parent-directory traversal is introduced. |
| No JSON Schema authored, imported, or read | PASS | `.claude/rules/parallel-orchestration.md` prohibits it for these artifacts. The branch adds no schema file and no schema read; enforcement remains prose plus validator and test logic. |

---

## Research Log

No external research was required. Every question this review answered was decidable against the repository at head: the policy files named in `CLAUDE.md`, the two committed truth tables, the three test suites, the coverage artifacts, and the feature folder's own evidence. One behaviour of the PowerShell language was checked empirically rather than from documentation, namely that `@($null).Count` evaluates to `1` while `@(@()).Count` evaluates to `0`; both were measured under `pwsh -NoProfile` in this session and are recorded in the perturbation evidence.

---

## Verdict

The branch is ready for normal PR flow. It fixes a real and measured defect in a published artifact, corrects both of its failure directions, and builds a gate whose every assertion but one was driven to failure in this review by an injected witness. All seventeen acceptance criteria pass on their own stated terms, the full eleven-stage toolchain passes in one uninterrupted run across the three languages with changed files, coverage is unchanged in all three coverage languages, and the two rule-document copies are byte-identical.

Two Major findings remain, both in the PowerShell mirror and both concerning non-vacuity rather than the relations the gate exists to assert. Neither creates a detection hole: the Python floor catches both conditions and both suites run in the same pipeline. They are recorded because R12's stated requirement was that the two mirrors respond the same way to the same malformed input, and they do not; because an assertion that cannot fail for its documented reason misleads the next maintainer; and because the fix for each is a few lines in one file. The decision whether to open a third remediation cycle for them, or to carry them as a follow-up issue, belongs to the orchestrator. This review did not open one, because none of the remediation-triggering conditions in the workflow contract fired.
