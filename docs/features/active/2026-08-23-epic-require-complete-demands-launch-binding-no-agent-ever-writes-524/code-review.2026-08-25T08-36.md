# Code Quality Review — Issue #524 (Epic `require_complete` Launch-Binding Fix)

- Timestamp: 2026-08-25T08-36
- Branch: `bug/epic-require-complete-demands-launch-binding-no-agent-ever-writes-524-r3`
- HEAD: `83b45f36`
- Reviewed diff: `git diff origin/main...HEAD` (seven non-feature-folder paths; see `policy-audit.2026-08-25T08-36.md`)

## Design Assessment

The fix is the minimal behavioral narrowing the spec describes: a per-feature presence gate on the launch-binding validation, active only when neither Codex enforcement flag is set. It follows the repository's established key-gated additive pattern (documented for `remediation_loop`, `human_interaction`, `complexity_assessments`, and `model_routing_receipts` in `.claude/rules/orchestrator-state.md`). The checkpoint schema is unchanged; no error string is added, removed, or reworded; the change is confined to which features the existing checks apply to under one flag combination.

Design strengths, verified by reading both modules in full:

1. **The presence predicate uses OR, not AND.** Python `_carries_launch_path` (lines 202-205): `"launch_receipt_path" in feature or "launch_status_path" in feature`. TypeScript `featureCarriesLaunchPath` (lines 234-237): the same disjunction with `in`. A partial binding therefore re-arms the full five-check set, which preserves discriminating power for a half-written Codex binding. Both runtimes carry a dedicated test pinning this (`test_require_complete_rejects_partial_launch_binding`; `rejects a partial launch binding under requireComplete`), and both assert the byte-identical error string.
2. **Key membership, not value truthiness.** The predicate tests key presence, so a key present with an empty or null value still arms the gate and fails its shape check. This matches item 3 of the new rule section exactly.
3. **Codex path unchanged.** Under either Codex flag, `require_launch_paths` is `False` and the loop body is reached for every non-skipped feature, exactly as before. The 17 parametrised Codex-gate cases pass unmodified (evidence: `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md`, corroborated by this session's 27-test run of the file at HEAD).
4. **Planner call site is explicit.** `validate_epic_planner_child_launch_bindings` passes `require_launch_paths=False` explicitly (Python line 270, TS line 296) even though the Python default would suffice. Making the planner's unconditional behavior visible at the call site is the right call, given that the planner surface carries the deferred sibling defect (#543).
5. **Activation short-circuit preserved.** The entry-point guard (`if not (require_codex_model_routing or require_codex_topology or require_complete): return []`, Python lines 283-284; TS lines 305-311) is untouched, so the no-flag path remains a byte-identical no-op.

## Cross-Runtime Parity

- Control flow is equivalent: identical guard ordering (non-object, `skip_not_started`, presence gate) in `_validate_launch_bindings` and `validateLaunchBindings`.
- Flag derivation is equivalent by De Morgan: `not (a or b)` versus `a !== true && b !== true` over the boolean option surface.
- The new tests assert one identical error string across runtimes; no new string was introduced, so no new parity surface exists beyond the control flow itself.
- Both new-test suites pass at HEAD (24 Jest tests in the launch-binding suite; 27 pytest tests in the Python file; this session).

## Findings

### CR-1 (Non-blocking) — `require_launch_paths` / `requireLaunchPaths` name reads inverted relative to its effect

- Location: `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` line 215 (parameter), line 228 (use), lines 295-297 (derivation); `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` line 244, line 261, lines 321-323.
- Issue: the flag's effect is "validate only features that carry a launch path key" — a *skip* condition. The name reads as "launch paths are required." The inversion is sharpest at the Codex call sites: when the Codex flags are set, `require_launch_paths` is `False`, yet that is precisely the mode in which launch paths *are* demanded of every feature. A future maintainer reading only the parameter name is likely to draw the opposite conclusion about each mode.
- Mitigating context: the helper docstring ("Return whether the feature records either launch path key"), the guard's shape (`if require_launch_paths and not _carries_launch_path(feature): continue`), and the prose in `.claude/rules/orchestrator-state.md` item 2 together make the semantics recoverable within a few lines. `_validate_launch_bindings` is module-private; the public signatures are unchanged.
- Recommendation: rename in a follow-up to something direction-neutral, for example `only_features_carrying_launch_paths` (Python) / `onlyFeaturesCarryingLaunchPaths` (TypeScript), or add one clarifying comment at each derivation site. Not remediation-required: behavior is correct, tested, and documented in prose.

### CR-2 (Non-blocking) — Minor parameter-surface asymmetry between the twins

- Location: Python `_validate_launch_bindings` declares `require_launch_paths: bool = False` (a defaulted keyword); the TypeScript `LaunchBindingContext.requireLaunchPaths` is a required field with no default.
- Issue: the hand-maintained twins differ in whether the flag is optional. Both call sites in each runtime pass it explicitly, so there is no behavioral divergence, but a future Python call site could omit it while a TypeScript one cannot.
- Recommendation: optionally drop the Python default so both runtimes force the decision at every call site. Cosmetic; no action required.

### Deleted tests — no material coverage gap (assessed, not merely accepted)

The removed Python test `test_require_complete_requires_binding_for_every_feature` exercised: a `not_started` feature, with launch paths present but `model_routing_receipt` removed, failing under `require_complete` alone. Its removal was mandatory — it pinned the defect (universal launch-evidence demand under `require_complete`) as intended behavior. The scenario space it covered decomposes as:

1. *The gate arms under `require_complete` alone when launch keys are present* — now covered by the partial-binding tests in both runtimes (a feature carrying one launch key is fully validated and fails).
2. *`skip_not_started` is disabled under `require_complete`* — still covered: the replacement tests use `merged` features, and the `not_started` interaction under the Codex gates is covered by `test_unlaunched_feature_does_not_require_binding_under_routing_gate` / `does not require evidence before the feature launches`, both preserved.
3. *The receipt shape checks themselves* — covered unchanged by the 17 preserved parametrised Codex-flag cases, which exercise the identical shared loop body.

One narrow scenario is no longer directly asserted: a feature carrying both launch path keys but missing `model_routing_receipt`, under `require_complete` alone. Because the presence gate and the loop body are the only decision points, and the partial-binding test proves the same loop body executes under `require_complete` alone while the Codex-flag tests prove the receipt checks inside that body, the composition is exercised; changed-line coverage is 100% in both runtimes. Assessed as no material gap. A future test could pin the composition directly, but it is not required.

## Test Quality

- All four new tests are deterministic, in-memory, order-independent, and structured Arrange/Act/Assert with intent comments naming what each fixture models (the Claude shape; the half-written binding).
- The partial-binding assertions use the filtered-list equality form (`_launch_errors(errors) == [...]` / `launchErrors(errors)).toEqual([...])`), asserting *exactly one* launch error rather than mere membership — the stronger assertion, and it is what proves no second spurious error appears.
- The skip test removes all four launch-evidence keys, modelling the destination shape faithfully (matches the fixture used for the regression evidence).
- Preserved-test integrity was verified mechanically by the executor via AST source-segment comparison (`evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md`: 15 of 15 preserved functions byte-identical, inventory changed by exactly the three planned names). This session corroborated: the diff hunks touch only the replaced tests, all preserved names are present, and both suites pass at HEAD.

## Rule Prose Review

The new `## Epic Launch-Binding Activation Scope` section (both copies, line 85) is accurate against the implemented code: its three numbered items correspond one-to-one to the Codex-flag unconditional path, the per-feature key gate, and the either-key/key-membership semantics. It correctly restates that enforcement is validator logic plus prose, never an imported schema, consistent with the file's existing doctrine. Twin verified byte-identical (`cmp`) and the push-down resource-contract test passes.

## Verdict

No Blocking findings. Two Non-blocking findings (CR-1 naming, CR-2 twin asymmetry), neither of which requires remediation before merge. The implementation matches the spec's design, including the deliberately either-key presence test, and both runtimes are verified equivalent.
