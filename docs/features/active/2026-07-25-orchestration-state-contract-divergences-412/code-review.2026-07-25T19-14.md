# Code Review: orchestration-state-contract-divergences (#412)

---

**Review Date:** 2026-07-25
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412`
**Feature Folder Selection Rule:** Sole active feature folder whose suffix matches the issue number (412) in the branch name; also the folder holding all changed scoping docs.
**Base Branch:** `main` (merge base `009808510363081d0db7684f7b555f2ded4b0b7c`, tip of `origin/main`)
**Head Branch:** `bug/orchestration-state-contract-divergences-412` (head `81f3df3fb122db6d2dd8c51520e9ab8a2b1f7da5`, six commits)
**Review Type:** Initial review

---

## Executive Summary

This branch fixes two documented-contract-versus-implementation divergences in the orchestration state machine, with documentation ruled the authoritative side for both. Divergence 1 introduces a per-step-key additive step-status vocabulary (`step9_status` gains `passed`, `failed_remediation_required`, `blocked_ci_loop_limit`; `step6_status` gains `blocked_remediation_loop_limit`) layered on a verifiably unchanged shared `VALID_STEP_STATUS` set, with completion-gate closure (three failure values block `--require-complete`; `passed` does not) and Python PR-creation-readiness closure. The mechanism is mirrored in the Python validator, the PowerShell portable module (plus byte-identical resources mirror), and the TypeScript MCP validator with byte-identical error strings. Divergence 2 replaces the any-non-empty complexity-floor formula with an intersection against a hard-coded floor-signal set in both reference implementations, pinned to `config/orchestration-routing.json` by static parity tests in both languages.

The implementation quality is high: the change is minimal and additive, purity contracts are preserved and documented, the rejection matrices are exhaustive (owning-key × non-owning-key), the compatibility consequence is pinned by a dedicated test, and the epic-merge-gate regression witness is verified unmodified with its 30-test suite green. All toolchain gates were independently re-run by this review and pass cleanly; coverage improves marginally in every language. One Major finding remains: the PowerShell portable PR-creation-readiness function was not extended with the new step6 blocking value, so the pushed-down consumer path diverges from the Python gate it documents parity with.

**What changed:**
Production: `scripts/dev_tools/validate_orchestrator_state.py` (500→495 lines, delegates step-status checks), `scripts/dev_tools/_orchestrator_state_step_status.py` (new, 184 lines), `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` (blocklist +1 value), `scripts/dev_tools/compute_complexity_floor.py` (intersection + docstring rewrite), `.claude/lib/orchestrator-state/OrchestratorState.psm1` (485→498, per-key extra map in base-presence check) and `.claude/lib/model-routing/ModelRouting.psm1` (floor-set intersection) each with byte-identical resources mirrors, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (map + completion blocklist + helper). Tests: +39 pytest, +37 Pester, +4 Jest cases across seven test files (one new). Docs/evidence: 71 files under the feature folder.

**Top 3 risks:**
1. The pushed-down PowerShell readiness gate now fails open for `step6_status: "blocked_remediation_loop_limit"` in consumer repositories (finding CR-1); mitigated by the `blocked_reason` readiness check that usually accompanies a halted loop, and by the Python gate being authoritative in this repository.
2. Cross-language error-string drift over time; mitigated now by literal-string Jest assertions and the documented header contract, but no automated cross-language string extraction exists (pre-existing state).
3. `OrchestratorState.psm1` at 498/500 lines leaves near-zero headroom for the next change to that module (CR-2).

**PR readiness recommendation:** **Go** — all acceptance-criteria-bearing behavior is delivered and verified; the single Major finding is outside the spec's acceptance criteria and file-surface contract for gate closure and is suitable for a follow-up issue rather than blocking this fix.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/orchestrator-state/OrchestratorState.psm1` (+ resources byte mirror) | `Get-OrchestratorStatePrCreationReadinessError`, line 319 | CR-1: The portable PR-creation-readiness check still blocks only `pending`/`blocked` on steps 5–8, while the Python gate it documents parity with (`_orchestrator_state_pr_creation_readiness.py`, `PR_CREATION_BLOCKING_STEP_STATUS`) now also blocks `blocked_remediation_loop_limit`. Because that value is now plain-valid on `step6_status`, a checkpoint recording a halted remediation loop passes the portable readiness path (`Test-OrchestratorStatePrCreationReadiness`) in pushed-down consumer repos where the Python validator is not importable. Pre-change the same checkpoint failed the base-presence check (value was unwritable), so this is a net fail-open in that fallback path. | File a follow-up issue to add `blocked_remediation_loop_limit` to the step blocklist in `Get-OrchestratorStatePrCreationReadinessError` (and its byte mirror), with a Pester case mirroring `test_pr_creation_readiness_rejects_step6_blocked_remediation_loop_limit`. Alternatively fold into the recorded `enforce-completion-consistency` follow-up. | The function's own docstring claims parity with the Python readiness reference; the divergence is the same defect class this issue exists to fix. Not Blocking: no spec acceptance criterion covers the PowerShell readiness gate (spec AC 12 covers plain-mode acceptance/rejection only), the spec file-surface lists only the Python readiness module for gate closure, and in this repository the authoritative Python gate is closed. The portable path retains partial defense: a halted loop that also records a non-`none` `blocked_reason` is still rejected by the readiness `blocked_reason` check (line 327). | Diff inspection `git diff 0098085..HEAD -- .claude/lib/orchestrator-state/OrchestratorState.psm1` (readiness function untouched); module lines 315–322 vs. `_orchestrator_state_pr_creation_readiness.py` lines 59–68 |
| Minor | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | whole file | CR-2: File is at 498 of the 500-line limit after this change (485 before). The next edit of any size will force a split under time pressure. | When the CR-1 follow-up lands, extract the readiness/preflight helpers into a sibling module in the same change (mirroring how the Python side split `_orchestrator_state_step_status.py` out at the 500-line boundary). | Proactive structure work is cheaper than a forced split inside an unrelated fix. | `wc -l` = 498 |
| Info | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | lines 263–274 | CR-3: PowerShell `-contains`/`-notcontains` comparisons are case-insensitive by default, so the portable module accepts e.g. `PASSED` where Python and TypeScript reject it. The new `$extra -notcontains` check inherits this pre-existing module-wide convention; this branch does not widen the difference. | No action for this branch. If exact-case parity is ever required in the portable path, switch to `-cnotcontains` module-wide in one change. | Cross-language strictness difference exists in the fallback path only; the Python validator is authoritative where it ships. | Inspection of `Get-OrchestratorStateBasePresenceError`; pre-existing pattern for `$script:VALID_STEP_STATUS` |
| Info | `extensions/drm-copilot/test/**` | n/a | CR-4: `.claude/rules/typescript.md` names Vitest as the unit-test framework, but the extension's entire pre-existing suite (168 files) is Jest, and the changed tests correctly follow the established Jest convention. | Pre-existing repo-level rule/practice inconsistency; resolve at the rules level, not in this branch. | Flagging so the inconsistency is on record; changing frameworks inside this bugfix would be scope creep. | `extensions/drm-copilot/package.json` scripts (`run-jest.cjs`); rule file `.claude/rules/typescript.md` |
| Info | `extensions/drm-copilot/jest.config.cjs` | `testMatch` | CR-5: Environmental only — in this dot-directory worktree the configured `testMatch` glob matches nothing (`No tests found`, exit 1); the `--testMatch "**/test/**/*.test.ts"` override discovers all 168 suites, which pass. Config deliberately unmodified; CI checkouts are unaffected. | No action. Evidence artifacts correctly record both invocations with real exit codes. | Prevents mis-reporting an environmental failure as a branch defect. | Reviewer re-run: override run 168 suites / 2035 tests, exit 0 |

No Blocker findings. One Major, one Minor, three Info.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The per-key additive map (`STEP_SPECIFIC_EXTRA_STATUS`) is the smallest mechanism that satisfies the documented contract without weakening the shared vocabulary: the shared `VALID_STEP_STATUS` literal is verifiably untouched (diff shows only its consumers changed), and the same values on non-owning keys remain rejected with the pre-existing message form.
- Extracting `_orchestrator_state_step_status.py` simultaneously solved the 500-line pressure on `validate_orchestrator_state.py` (exactly 500 pre-change, 495 after) and gave the vocabulary a single home; `STEP_STATUS_KEYS` is re-exported so existing importers and tests resolve it unchanged.
- `COMPLETION_BLOCKING_STEP_STATUS` deliberately omits `passed` with a comment explaining why — the exact subtlety the spec calls out ("`passed` must not block completion") is encoded and tested rather than implied.
- `compute_complexity_floor` keeps the max-over-candidates + ceiling-clamp shape of the original formula and adds only the intersection, which keeps the diff reviewable and the C4-never-floor-forced invariant obviously intact.

#### Typing and API notes

- Full annotations throughout; `frozenset[str] | set[str]` for the injected shared set keeps the single-source-of-truth in the primary validator without a circular import. `TYPE_CHECKING`-guarded `Mapping`/`Sequence` imports. `__all__` documents the deliberate re-export surface. No `Any`, no new suppressions anywhere in the branch diff (verified by grep).
- `is_valid_step_status(key, value, *, shared=...)` takes `value: object` and relies on set membership, matching the validator's raw-value semantics; membership of non-str objects in a `frozenset[str]` is well-defined and false.

#### Error handling and logging

- The non-raising error-string-collector contract is preserved; message forms are byte-identical to the pre-change strings (asserted by the unmodified 735-line legacy suite remaining green, which pins that no previously valid checkpoint is newly rejected in plain mode).

### TypeScript implementation audit

#### What changed well

- The port is structurally faithful: `ReadonlyMap`/`ReadonlySet` constants, an `isValidStepStatus` helper mirroring the Python function, and the completion loop switching from a two-literal comparison to `COMPLETION_BLOCKING_STEP_STATUS.has(value)`.
- `COMPLETION_BLOCKING_STEP_STATUS: ReadonlySet<unknown>` is a deliberate, documented choice so membership is tested on the raw checkpoint value, matching the Python `in` check on unparsed values — the TSDoc explains this rather than leaving it as an apparent type sloppiness.

#### Type safety and maintainability

- Error strings verified byte-identical to Python for string inputs: `` `Checkpoint has invalid ${key}: ${String(value)}` `` and `` `Checkpoint completion validation failed: ${key} is ${String(value)}.` ``. Jest cases assert the literal strings, giving a regression tripwire for future drift.
- No type assertions, no suppressions; ESLint strict-type-checked and `tsc --noEmit` pass (reviewer re-run).

#### Error handling and logging

- Validator remains a pure error-array collector; no behavioral change outside the two check sites.

### PowerShell implementation audit

#### What changed well

- `$script:STEP_SPECIFIC_EXTRA_STATUS` is applied inside the existing base-presence loop with a two-line extension, keeping the fail-closed structure of `Get-OrchestratorStateBasePresenceError` intact; the header comment pins it to the Python source module by name.
- `Get-ComplexityFloor` filters with `Where-Object { $script:FLOOR_SIGNAL_NAMES -contains $_ }` and re-uses the existing empty-guard via `$triggered.Count -eq 0`, so the empty-input and no-floor-signal cases collapse into one path — simpler than the Python original's two-step structure while provably equivalent (Pester truth table matches the Python table).
- The no-runtime-file-read rationale (module is pushed down to consumer repos without the config file) is documented at the constant definition, and both changed modules' resources mirrors are byte-identical (verified with `cmp` by this review; also enforced by `test_push_down_claude_resource_contracts.py`, unmodified and green).

#### API and safety notes

- No new functions; no parameter-surface changes; `$script:`-scoped immutable literals consistent with module conventions; PSScriptAnalyzer 0 findings on both modules (reviewer re-run).
- See CR-1 (readiness gate divergence) and CR-3 (case-insensitive `-contains`, pre-existing) in the findings table.

#### Error handling and logging

- Error strings use the same `Checkpoint has invalid <key>: <value>` form via the existing backtick-escaped interpolation; fail-closed load/parse paths untouched.

---

## Test Quality Audit

Coverage, regression, and cross-language parity evidence is complete and was independently re-verified. The rejection matrices are the strongest part of the suite: every extra value is tested on its owning key (acceptance) and on all five non-owning keys (rejection) in both Python (20 parametrized triples) and Jest (equivalent loops), which makes vocabulary leakage across keys structurally impossible without a test failure. The compatibility consequence of divergence 2 has a dedicated pin (`test_non_floor_only_assessment_with_floor_c3_rejected` asserts the literal floor-mismatch error naming recomputed `C1`). The parity tests read the live config in both languages and assert bidirectional set equality plus non-vacuity (`assert config_floor_names` and count assertions), so a silently emptied catalog cannot make the parity assertion vacuous.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_orchestrator_state_step_status_extras.py` — new 279-line suite; owning/non-owning matrices, completion blocklist, `passed` non-blocking, absent-key default. Builds a fully completion-clean checkpoint so a single mutation is the only error source — good isolation discipline.
- `tests/scripts/dev_tools/test_compute_complexity_floor.py` — truth-table extension driven by the live catalog (non-floor names read from config, not hard-coded in tests) plus the static parity assertion; module attribute accessed via `floor_module.FLOOR_SIGNAL_NAMES` so a missing constant fails one test instead of aborting collection.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` — validator-level acceptance of `floor: C1` for non-floor-only signals and rejection of the stale `floor: C3`.
- `tests/scripts/claude-lib/**` — Pester mirrors of the above (106/106 pass, reviewer re-run); `ModelRouting.Parity.Tests.ps1` pins the embedded set with equality and exclusion cases plus explicit count assertions (4 floor, 3 non-floor).
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-core*.test.ts` — byte-identity assertions on the ported strings; completion failure/success cases.
- `evidence/regression-testing/*` — fail-before evidence for each phase (pre-fix exit codes recorded, including exit-1 runs proving the new tests fail against pre-fix code); `final-epic-merge-gate-regression.md` — 30/30 hook suite green with the hook verified untouched (re-confirmed by this review: zero diff against merge base).
- `evidence/qa-gates/final-coverage-comparison.md` — every number independently reproduced by this review from the raw artifacts; exact match.

### Quality assessment prompts

- **Determinism:** In-memory fixtures; only file dependency is the committed routing config, read by tests (never by code under test). No timers, RNG, or wall-clock reads added.
- **Isolation:** Each test mutates exactly one field of a known-clean state; failure attribution is unambiguous.
- **Speed:** pytest full suite 11.30s; Jest 6.65s; Pester changed suites ~5s.
- **Diagnostics:** Literal expected-string assertions mean a failure prints the exact divergent contract string, which is precisely the failure mode this change guards against.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: constants, validation logic, tests, and docs only. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess/`Invoke-Expression`/`eval` additions; existing python-probe seam untouched. |
| Input validation at boundaries | ✅ PASS | Validators strengthened (per-key vocabulary, wider completion/readiness blocklists on the Python side); plain-mode widening is exactly the documented contract. See CR-1 for the one fallback-path gap. |
| Error handling remains explicit | ✅ PASS | Non-raising collector contract preserved in all three languages; no silent catches added. |
| Configuration / path handling is safe | ✅ PASS | No runtime file reads added; embedded constants pinned to config by static parity tests in both languages; mirrors byte-identical. |

---

## Research Log

No external research was required for this review. All evidence derives from the branch diff, the feature folder (spec, plan, research artifact, evidence tree), the regenerated PR-context artifacts, and reviewer-executed toolchain runs. The feature's own research artifact (`research/2026-07-25T20-45-orchestration-state-contract-divergences-research.md`) was used as context for the authoritative-side rulings and was consistent with the code-level facts verified here (`enforce-epic-merge-gate.ps1` line 148 requiring `step9_status -eq 'passed'`; config `floor` flags; dead-configuration behavior of the pre-fix formula).

---

## Verdict

The change is ready for the normal PR flow. Both divergences are fixed exactly as specified: the shared step-status set is untouched in all three languages (verified at the literal level), the per-key map is additive with exhaustive owning/non-owning coverage, completion and Python readiness gates are closed with `passed` correctly non-blocking, the floor formula now honors the config's `floor` flags with unknown names contributing nothing, both floor implementations remain pure, and the parity tests genuinely pin the embedded sets to `config/orchestration-routing.json` in both directions. Every toolchain gate passes on reviewer re-execution, coverage improves marginally everywhere with no changed-line regression, and the deliberately-unchanged file set is verified untouched.

One Major follow-up remains (CR-1): extend the PowerShell portable PR-creation-readiness blocklist with `blocked_remediation_loop_limit` to restore parity with the Python gate in pushed-down consumer repositories. This does not violate any acceptance criterion or written policy rule and does not block the PR; it should be filed as a follow-up issue alongside the two follow-ups already recorded in `spec.md` §Rollout & Follow-up. Recommendation: **Go**.
