# Code Review: blast-radius bundled truth-table correction (Issue #500)

**Review Date:** 2026-08-22
**Reviewer:** feature-review
**Cycle:** remediation cycle 1 re-audit
**Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `a95ae362`
**Base:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
**Scope:** the full branch diff against the merge base, twelve non-documentation files plus 81 Markdown documents.

---

## Executive Summary

The branch is well built. It corrects a two-directional defect in a published configuration document, adds a cross-copy drift gate in two languages plus two TypeScript property assertions, and records the resulting contract in the governing rule with a byte-identical mirror. Every toolchain stage passes at head, every coverage threshold is met, no suppression is added, no test is weakened, and no coverage exclusion is introduced.

The remediation cycle delivered five of its six items in substance rather than in wording. Each was verified by perturbation rather than by reading:

- The new directional invariant fails on an injected witness in both languages, with the Python case reporting `assert not ['Directory.Build.props']` and the Pester case reporting `Expected $null or empty, but got 'Directory.Build.props'`. The two compute the same relation over the same two subsets, so the mirror discriminates for the same reason as its original. The failure mode that R6 exists to correct was not reproduced here.
- The corrected `-InputObject` comparison form does distinguish a single-element list from a bare scalar, measured directly.
- The corrected evidence command reproduces its own figures exactly: 1182 edges and 31 cohorts post-change, 1199 and 33 pre-change, over 56 items and 1540 pairs.
- AC9 and AC10 now name the file that carries the gate and cite a command that collects it, and re-checking them is warranted.

Three findings follow. One is Blocking, one is Major, and one is Minor.

The Blocking finding is that the remediation corrected two of the three acceptance criteria carrying the same wrong file reference and left the third. Spec AC4 still cites `tests/scripts/dev_tools/test_blast_radius_config.py` as the file carrying "the Class 2 and Class 3 assertions of the new gate," and that file contains neither. This is a wording defect in a documentation file, not a defect in the delivered behaviour, and its correction is a single-token edit.

The Major finding is a residual drift direction the three-class gate cannot see: a top-level key added to one copy and not the other. The partition enumerates the six keys that exist today and never asserts that the enumeration covers the actual key sets, so the mechanism that produced the original defect is only partly closed.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | `## Acceptance Criteria`, fourth checkbox, trailing sentence | AC4 ends "Verified by the Class 2 and Class 3 assertions of the new gate in `tests/scripts/dev_tools/test_blast_radius_config.py`." That file is untouched by the branch, carries no Class 2 or Class 3 assertion, and collects 32 cases none of which belongs to the gate. Both classes live in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`. This is the identical defect the cycle-1 inputs recorded as R1 against AC9 and R2 against AC10; the remediation swept those two because they were the two enumerated, and left the third instance. | Replace `test_blast_radius_config.py` with `test_blast_radius_config_parity.py` in AC4's trailing sentence, then re-check the box. Do not alter the criterion's substantive content, which is delivered in full. | `spec.md` is the sole acceptance-criteria source under work mode `full-bug`. A criterion whose stated verification does not exercise it is not independently verifiable, which is the exact condition cycle 1 opened to remove and which its own exit condition 3 restates. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` -> exit 0, `32 passed`; `git diff --stat fb30a9a5..HEAD -- tests/scripts/dev_tools/test_blast_radius_config.py` -> empty; `grep -n "class_two\|class_three\|PORTABLE_SHARED_SURFACES\|PAYLOAD_MODULE" tests/scripts/dev_tools/test_blast_radius_config.py` -> no assertion match |
| Major | `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | the three-class partition as a whole | The gate enumerates `version`, `over_breadth_fraction`, `mandate_reads`, `shared_surfaces`, `shared_surface_globs`, and `modules`, which is the complete key set of both copies today, but never asserts that the enumerated partition covers the actual key sets. A seventh top-level key added to one copy and not the other is undetected. That is the same mechanism as the original defect: a bundled copy falling behind a self-hosted one that grew. | Add one case per language asserting that the two copies declare the same top-level key set, and that the set equals the union of the three classes. This is roughly six lines in Python and ten in PowerShell against 77 and 113 lines of file headroom respectively. | The gate's stated purpose in its own module docstring is to pin "the three-class partition that is correct." A partition assertion that does not check exhaustiveness pins the classes but not the partition, so the gate is one key-addition away from the state it was written to prevent. | Injecting `new_top_level_key` into `config/blast-radius.json` alongside a separator-bearing `shared_surfaces` entry, a `shared_surface_globs` entry, and a `newsub` module, then running both pytest modules: exit 0, `50 passed`. No case fires. |
| Minor | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | `## Risks & Mitigations`, the Class 2 mitigation bullet | The revised sentence ends "and the residual gap is closed structurally by `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` (added in Phase 2)." The closure is restricted to separator-free entries; a self-hosted separator-bearing addition is still unobserved. The restriction is legible from the quoted test name but the sentence's own claim is unqualified. | Qualify the clause, for example "the separator-free portion of the residual gap is closed structurally by". | The bullet is the document's statement of what the gate guarantees. An unqualified claim there is what a later maintainer will rely on when deciding whether an addition needs a bundled counterpart. | Injecting `config/new-portable-surface.json` into the self-hosted `shared_surfaces` alone: exit 0, all cases pass. The directional invariant filters on `"/" not in entry`, so a path-bearing entry is outside its selection by construction. |
| Minor | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | `## Acceptance Criteria`, criteria 1, 2, 3, 5, and 12 | Five criteria cite line numbers that no longer resolve to the constructs they name. AC1 cites lines 123-130 for the reason the `.claude` tree is not a module; the doc comment opens at 123 and the reason sits at 131-140. AC2 cites 137, 153, 240, 252, 338, 474; only 137 and 240 land on an assertion. AC3 cites 44, 122, 292, 387 and `SOURCE_BLAST_RADIUS` at line 84; the constant is at 86 and its comment spans 61-85. AC5 cites 284-293 for a list now at roughly 300-310. AC12 cites 96-98 for a comment now at 92-104. | Either drop the line numbers in favour of the construct names, which are stable, or refresh them once at PR time. Dropping them is preferable: an anchor that drifts silently is worse than no anchor. | Every named construct exists in the named file with the required content, so no criterion is unverifiable on this ground. The cost is reviewer time spent confirming that a mismatched anchor is drift rather than the AC4 defect. | Direct inspection of each cited line at head `a95ae362` via `sed -n "<n>p"`. |
| Minor | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/` | the twenty artifacts stamped `2026-08-21T21-49` | All twenty remediation-cycle artifacts carry one identical local-clock stamp that is roughly three hours earlier than the UTC stamps of the audit (`2026-08-22T00-52`) and plan (`2026-08-22T01-10`) that requested them, so the evidence appears to predate its own trigger, and their relative order is not recoverable from their names. The original cycle's artifacts use UTC and are internally consistent. | Adopt one clock for the feature folder, UTC being the one the earlier artifacts already use, and stamp each artifact when it is produced. | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` fixes the format but not the timezone, so this is a consistency defect rather than a format violation. It nonetheless makes the cycle's evidence chain unreadable in filename order. | `ls docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/*/*2026-08-21T21-49*` returns twenty paths spanning baseline, regression-testing, qa-gates, issue-updates, and remediation-baseline. |
| Minor | `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | the `Cross-copy key partition` Context | The Pester directional case indexes `$script:CommittedConfig['shared_surfaces']` directly, whereas its Python counterpart reads through the `shared_surfaces` accessor, which returns an empty tuple for an absent or non-list key. A renamed key therefore raises on the PowerShell side and passes vacuously on the Python side, where the separate non-vacuity floor case is what catches it. The Pester file carries no non-vacuity floor of its own. | Either mirror the non-vacuity floor into the Pester file or add a guard asserting both `shared_surfaces` values are non-empty lists before the containment loop. | Both languages fail loudly overall, so this is not a hole. It is a divergence in how the two mirrors respond to the same malformed input, which is the property the mirror relation is supposed to preserve. | Read of `BlastRadius.TruthTable.Tests.ps1:270-303` against `test_blast_radius_config_parity.py:253-289` and `blast_radius_parity_test_support.py:139-158`. |
| Informational | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T00-52-remediation/remediation-inputs.2026-08-22T00-52.md` | item R6 | The recorded rationale states that under the pipeline form "an empty list serializes as `$null` exactly as an absent key does." Measured directly, the pipeline form yields no output for an empty list, which compares as `$null`, and yields the string `null` for an absent key, so `-cne` already distinguished them. The single-element-list against bare-scalar half of the rationale was correct and is the half the correction turns on. | No action. Recorded so a later reader does not rely on the inaccurate half. | The remediation was correct to make the change; only one of the two stated reasons held. | `PIPELINE emptyList -> <no output>, absent -> null, equal=False` and `INPUTOBJ singleList -> [["x"]], scalar -> "x", equal=False`, measured in `pwsh -NoProfile`. |
| Informational | `.claude/rules/parallel-orchestration.md` | the added subsection, second paragraph | The claim that `tests/scripts/dev_tools/test_blast_radius_config.py` calls `load_module_globs` on the bundled copy, which is the stated reason for retaining the bundled `modules` key, was checked and holds. | No action. | This is the one factual claim in the added rule prose that a reader cannot confirm from the rule itself. | `test_blast_radius_config.py:490` inside `test_no_committed_copy_declares_a_location_bucket_module`, parametrized over `COMMITTED_CONFIGS`, which includes `BUNDLED_CONFIG_PATH`. |

---

## Drift-Direction Coverage Analysis

The original defect was a bundled copy diverging from the self-hosted one. The table below enumerates every divergence direction and states which is covered and by what.

| # | Direction | Detected | By what |
|---|---|---|---|
| 1 | Bundled `version`, `over_breadth_fraction`, or `mandate_reads` changes alone | Yes | Class 1 equality, both languages |
| 2 | Self-hosted `version`, `over_breadth_fraction`, or `mandate_reads` changes alone | Yes | Class 1 equality, both languages, verified by injection in cycle 1 |
| 3 | Bundled `shared_surfaces` gains or loses an entry | Yes | Class 2 equality against `PORTABLE_SHARED_SURFACES` |
| 4 | Self-hosted `shared_surfaces` gains a separator-free entry not carried to the bundle | Yes, newly | The directional invariant added by this remediation, verified by injection in both languages |
| 5 | Self-hosted `shared_surfaces` gains a separator-bearing entry not carried to the bundle | No, by design | Portability is a deliberate declaration; `PORTABLE_SHARED_SURFACES` must be edited for a bundled addition. Recorded as a Minor overclaim in the mitigation text. |
| 6 | Self-hosted `shared_surfaces` loses an entry the bundle still declares | Yes | `bundled <= self_hosted` in Class 2 |
| 7 | Bundled `shared_surface_globs` becomes non-empty | Yes | Class 2 emptiness assertion |
| 8 | Self-hosted `shared_surface_globs` changes | No, by design | Every self-hosted glob is a `scripts/dev_tools` pattern describing no destination; the bundled list is correct at empty. |
| 9 | Bundled `modules` gains a name outside the payload set | Yes | Class 3 subset, plus the five-name umbrella denylist on both copies |
| 10 | Self-hosted `modules` changes | No, by design | A destination's map is derived by `assembleModules`; the bundled `modules` key is never consumed. |
| 11 | `PAYLOAD_MODULES` gains an umbrella or a forbidden glob | Yes | `blast-radius-derive-core.test.ts:461-479`, both the equality pin and the negative property |
| 12 | Either copy stops parsing or declares a version other than 1 | Yes | `test_every_committed_copy_parses_and_declares_schema_version_one`, parametrized |
| 13 | A gate key is renamed so an accessor returns empty and the gate passes vacuously | Yes, Python only | `test_the_gate_compares_non_empty_collections`; no PowerShell counterpart |
| 14 | **A new top-level key is added to one copy and not the other** | **No** | Nothing. The partition is enumerated, not exhaustive. Major finding above. |
| 15 | The two `parallel-orchestration.md` copies diverge | Yes | `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, 10 passed |
| 16 | The two `orchestration-routing.json` copies diverge | Yes | An existing Jest assertion, independently confirmed here by `cmp` and `Get-FileHash` |

Directions 5, 8, and 10 are deliberate asymmetries with a stated rationale in the rule; they are not gaps. Direction 14 is a genuine residual gap. Direction 13 is covered in one language only.

---

## Positive Observations

- **The falsifiability discipline is real.** The remediation commit did not add an invariant and observe it pass. It reverted the bundled copy to the merge-base state, observed each half of the new invariant fail while naming the three missing entries, restored with the restore proven by `git status`, and reran green. This reviewer repeated the procedure independently and reproduced both failures and both passes.
- **The mirror relation is stated in the code, not only in the spec.** Each language's directional case names its counterpart by test name and file path in a comment, which is what makes a future divergence findable.
- **The failure messages are accumulating, not first-failure.** Both directional cases collect every missing entry before asserting, so one run reports the whole delta.
- **The non-vacuity floor is not decorative.** `test_the_gate_compares_non_empty_collections` pins `len(COMMITTED_CONFIGS) == 2` and separately checks `mandate_reads` is a non-empty list, precisely because a Class 1 equality of two empty lists would hold. That is the failure mode the rest of the gate would otherwise be exposed to.
- **The bundled `modules` key retention is justified rather than assumed.** The rule records that `load_module_globs` raises on an absent key and that a pre-existing test calls it on the bundled copy. The reviewer confirmed the call site.
- **The corrected evidence command is genuinely reproducible.** Following the amended description verbatim produced 1182 and 1199 edges, matching the recorded figures to the unit. The pre-correction description produced different numbers, which is what made the correction necessary.

---

## Typed-Python Review

Both new Python modules are strict-mode clean under Pyright with zero suppressions.

- `blast_radius_parity_test_support.py` declares `BUNDLED_CONFIG` and `SELF_HOSTED_CONFIG` as `Mapping[str, object]` and imports `Mapping` under `if TYPE_CHECKING:`, with `from __future__ import annotations` at the head.
- `shared_surfaces` and `shared_surface_globs` narrow with `isinstance(value, list)`, then `cast("list[object]", value)`, then a per-entry `isinstance(entry, str)` filter. The `cast` is confined to the narrowing step and is not used to bypass a diagnostic.
- `config_key` returns `object` rather than a union, and its docstring states the deliberate absent-key convention: a renamed key surfaces as a `None` mismatch rather than a `KeyError`. That is a design choice with a consequence, and the consequence is what the non-vacuity floor exists to catch.
- `module_names` documents the `TypeError` it propagates from `load_module_globs` rather than catching it, which matches the fail-fast requirement in `.claude/rules/general-code-change.md`.
- Every test function is annotated `-> None`; every parametrized case annotates its parameters. `derive_bundled_radius` and `reason_pairs` carry full Args and Returns blocks.
- The directional case uses `frozenset` difference and `sorted(...)` for a deterministic message ordering, so the failure text is stable across runs.

---

## Recommendation

**No-go for PR authoring until the Blocking finding is corrected.**

The correction is one token in one Markdown file. It changes no source code, no configuration data, and no test logic, so no toolchain rerun is required for it alone. The Major finding is worth taking in the same change because it is small and closes the last instance of the mechanism the branch exists to fix, but it is not required to clear the blocker. The four Minor findings and two Informational notes are recorded for the author's judgment.
