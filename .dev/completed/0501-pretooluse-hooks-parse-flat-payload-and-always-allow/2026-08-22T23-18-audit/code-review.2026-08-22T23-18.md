# Code Review: PreToolUse hooks parse flat payload and always allow (#501) — Cycle-2 Re-Audit

**Review Date:** 2026-08-22
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
**Base Branch:** `main` (`origin/main @ fb30a9a58b8422e610a09b07361421e97367807a`)
**Head Branch:** PR #503 head `bd6e42846a497433b6d4ac288c2054b62b864b23`
**Review Type:** Re-audit (cycle-2 close, last gate before DONE)

**Template source note:** the MCP template-resolution tool was not exercised in this session (not present in this session's toolset); the same section layout as the prior two cycles' code reviews is reused for continuity.

---

## Executive Summary

This cycle closes remediation cycle 2, whose sole trigger was a CI failure on PR #503 (four required checks red at head `0a383439`): three new files bundled under `.claude/` by this feature — `enforce-parallel-cohort-barrier-helpers.ps1`, `enforce-pr-author-skill-helpers.ps1`, and `HookPayload.psm1` — were unregistered in every pack manifest, so both the Python and TypeScript manifest-completeness contract tests failed even though the byte-parity mirror test the cycle-1 QA loop ran did pass (a different, sibling contract in the same test directory). The fix is a 3-line, purely additive JSON edit to `core.json`, plus an unconditional widening of the plan's final-QA phase to run the full Python suite and both full TypeScript suites, not only targeted selectors — the actual root-cause correction, since the byte-parity selector was never going to catch a registration-contract failure.

Scope for this cycle: one production-tree file (`core.json`, +3/-0 lines) plus eleven new evidence artifacts. Zero hook decision logic, zero test files, and zero coverage configuration changed. CI is green: 19 of 19 required checks pass against the exact branch head (`gh pr checks 503`, run `32603135721`, reviewer-confirmed this session).

**What changed this cycle:**
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: three lines added, each following the manifest's pre-existing sibling-helper-file convention (`enforce-parallel-drift-gate.ps1` / `-helpers.ps1` is the precedent cited by the plan and reviewer-confirmed present in the same file).
- Plan Phase 3 made `poetry run pytest` (full), `npm test` (full root TS), and `npm run test:unit` (full extension TS) unconditional final-QA tasks, alongside the pre-existing PowerShell format/analyze/test triad.
- Eleven evidence artifacts: four Phase-0 baseline captures (two `[expect-fail]` named-test failures, plus a JSON-validity baseline), and seven Phase-2/Phase-3 post-fix verification artifacts.

**Top risks (assessed):**
1. **Resolved.** Manifest registration verified in both runtimes, reviewer-reproduced independently for the Python side and the mirror-parity guard.
2. **None new this cycle.** No production code, decision logic, or test behavior changed; the risk surface introduced by this cycle is limited to a data file whose only consumer is the packaging/push-down tooling, not the runtime hook-enforcement path this feature exists to fix.
3. **Carried forward, unaffected.** Cycle-1's already-resolved findings (batch-budget coverage regression, coverage-evidence overstatement, stale docstring) remain resolved; none of their governing files changed this cycle.

**PR readiness recommendation:** **Ready to merge** — zero Blocking findings remain, and CI is green against the exact head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (resolved) | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | lines ~38, ~43, ~110 (three insertions) | Cycle-2's Blocking CI-failure trigger is fixed: three previously-unregistered bundled `.claude` files are now listed in `core.json`, adjacent to their parent/group entries, following the manifest's own sibling-helper-file convention. Zero pre-existing documented exceptions were swept in. | None — verified resolved. | Independently reproduced in this session: `git diff 0a383439..bd6e4284 -- .../core.json` shows exactly three added, zero removed lines; grep for the three documented exceptions across the manifest directory returns zero matches. | Reviewer `git diff` and `grep` this session; `evidence/qa-gates/2026-08-22T18-52-core-manifest-json-postfix.md` (`python -m json.tool` exit 0). |
| Info (resolved) | `remediation-plan.2026-08-22T18-30.md` Phase 3 | `[P3-T4]`–`[P3-T6]` | The root-cause finding — local final QA ran a targeted selector that structurally could not catch a sibling contract's failure, and never ran the TypeScript suite at all — is corrected by making the full Python suite and both full TypeScript suites unconditional Phase-3 tasks, each with a machine-checkable `EXIT_CODE == 0` acceptance clause and a corresponding evidence artifact. | None — verified this is a binding task list, not aspirational prose. | Every task carries `[x]` (executed) plus a distinct evidence file reviewer-inspected this session, and the phase preamble states "no `SKIPPED` outcome is authorized." | `evidence/qa-gates/2026-08-22T19-08-pytest-full-final.md`, `2026-08-22T19-11-root-typescript-full-final.md`, `2026-08-22T19-13-extension-typescript-full-final.md`. |
| Info (resolved) | `evidence/remediation-baseline/phase0-instructions-read.2026-08-22T18-40.md` | whole artifact | The plan's `[P0-T1]` task named an evidence path (`phase0-instructions-read.md`) that collided with an already-committed cycle-1 artifact of the identical name; the executor detected the overwrite, restored the original via `git checkout`, and wrote this cycle's log under a timestamp-disambiguated filename instead. | None — the self-correction is genuine, not merely reported. | Reviewer independently diffed the cycle-1 artifact's committed content between `db3de831` and the current head: **empty diff**, byte-identical, and the content at head matches cycle-1's own timestamp and scope statement, not cycle-2's. | `git diff db3de831..bd6e4284 -- .../evidence/remediation-baseline/phase0-instructions-read.md` (empty, this session). |
| Info | Full branch diff | n/a | Zero test files changed in cycle 2 (`git diff 0a383439..bd6e4284 --stat -- 'tests/**' 'extensions/drm-copilot/test/**'` is empty), confirming no test was weakened, skipped, or deleted to make CI pass — the one shortcut the remediation-inputs document explicitly warned against. | None — confirmed absent. | Direct verification requested by the task; a manifest-registration fix has no legitimate reason to touch test files, and none were touched. | Reviewer `git diff --stat` this session. |

---

## Implementation Audit

### Manifest edit (`core.json`)

#### What changed well

- **The fix follows the file's own established convention rather than inventing a new one.** The plan explicitly cites the `enforce-parallel-drift-gate.ps1` / `enforce-parallel-drift-gate-helpers.ps1` pair, already present in `core.json` two lines below the first insertion, as the precedent for listing a dot-sourced helper sibling immediately after its parent hook. Reviewer confirmed this precedent exists in the file and that the new insertions follow the same adjacency pattern.
- **`HookPayload.psm1` is correctly placed in the `.claude/lib/` group rather than a narrower manifest**, reflecting that it is consumed by both `core.json`-registered hooks and the two `powershell.json`-registered batch-budget hooks — a cross-manifest dependency the plan reasoned through explicitly rather than placing arbitrarily.
- **The three pre-existing, documented-exception files were correctly left unregistered.** Both governing tests assert their continued absence as a scope guard; the plan's Phase 2 explicitly runs the assertion in the same pass as the fix's own positive assertion (`[P2-T1]`), so a scope-creep regression on this point would have been caught locally before this review, not only by CI.

#### Root-cause reasoning quality

- The plan's "Decision" section is a genuine root-cause analysis, not a restatement of the symptom: it identifies that the byte-parity selector and the manifest-completeness assertion are **sibling test functions in the same directory**, so no amount of "pick a more specific selector" generalizes — only running the full suite (or, in principle, every sibling file in the directory) closes the gap. This reasoning correctly generalizes beyond this one incident and is reflected in binding, unconditional tasks rather than left as prose.
- The plan also correctly identifies a second, independent gap: the TypeScript suite was never part of the local final-QA loop at all, so no local stage could have caught the TypeScript-side failure regardless of Python-selector specificity. `[P3-T5]`/`[P3-T6]` close this gap directly.

#### Scope discipline

- The plan's do-not-do list is explicit and was honored: no hook decision logic, deny-reason string, or fail-closed posture changed; no new pack manifest file introduced; `.codex/hooks/` and the eight SubagentStop validators untouched; no test weakened, skipped, or excluded. Reviewer-verified each of these against the diff directly rather than accepting the plan's self-report.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`: re-run independently this session, 2 passed (`test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_documented_exceptions_remain_absent_from_every_manifest`).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`: re-run independently this session, 1 passed — confirms the mirror-parity contract this cycle did not need to touch remains green.
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`: re-run independently this session (47/47 pass) as a spot-check that the most recently-touched hook file (docstring fix, `0a383439`, landed immediately before cycle 2 opened) remains fully correct; `Invoke-ScriptAnalyzer` 0 findings, `Invoke-Formatter` reports no change.
- Full-suite evidence (`evidence/qa-gates/2026-08-22T19-08/11/13-*-final.md`): reviewed for content and internal consistency; the Python count (4062 passed) is exactly one more than CI's pre-fix 4061, and the root TypeScript count (2671) is exactly one more than CI's pre-fix 2670 — both deltas are explained by the now-passing manifest-completeness test, which is the expected and only expected delta.

### Quality assessment prompts

- **Independence/isolation:** cycle 2 introduced zero new test code; nothing to assess for independence beyond what cycle 1 already established and this session reconfirmed still holds (0 failures across all four full-suite runs).
- **Determinism:** the manifest-completeness tests are pure list-membership assertions over a static JSON file and a static file tree; no timing or randomness is involved.
- **No shortcut taken:** the task explicitly asked this reviewer to verify no test was weakened, skipped, excluded, or deleted to make CI pass. Confirmed: the diff contains no test-file change of any kind (`git diff 0a383439..bd6e4284 --stat -- 'tests/**' 'extensions/drm-copilot/test/**'` is empty), and both originally-failing tests pass unmodified because their assertion became true, not because their assertion was loosened.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection this session; the only production change is a list of relative file paths in a JSON manifest. |
| No unsafe subprocess or command construction | PASS | No new subprocess invocation; no hook logic changed. |
| Input validation at boundaries | N/A | No new input-handling code this cycle. |
| Error handling remains explicit | N/A | No new error-handling code this cycle. |
| Fail-open eliminated (the feature's original subject, #501) | PASS | Unchanged this cycle; not re-litigated in depth since no file in the shared-reader or hook-decision surface was touched. Reviewer re-confirmed no `.ps1`/`.psm1` file changed in cycle 2 by direct `git diff --stat`. |
| Regression risk from the manifest edit itself | PASS | A pack-manifest addition can only ever cause a file to be *included* in a bundled push-down pack that previously excluded it; it cannot alter runtime hook behavior, since the manifest is consumed by packaging tooling, not by the hooks themselves at invocation time. |

---

## Research Log

- Independently re-ran the two governing manifest-completeness tests (Python) and the mirror-parity guard this session, rather than accepting the executor's and cycle-1's reported results alone.
- Diffed `core.json` between `0a383439` (pre-cycle-2 head) and `bd6e4284` (current head) directly to confirm the exact three-line, zero-removal shape claimed by the plan and the remediation-inputs document.
- Grepped the full `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` directory for the three documented-exception filenames to confirm none were swept in as a side effect.
- Diffed cycle-2's full range (`0a383439..bd6e4284`) against `tests/**` and `extensions/drm-copilot/test/**` to confirm zero test files changed.
- Diffed the cycle-1 Phase-0 evidence artifact between `db3de831` and the current head to independently confirm the executor's self-reported restoration, rather than accepting the report at face value.
- Confirmed via `gh pr checks 503` that all 19 required checks are green against the exact branch head, cross-checked against the stated run ID `32603135721`.
- Confirmed the codex-surface sibling manifest (`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`) carries zero `.claude/` path entries, so it correctly has no completeness obligation toward these three files and was correctly left untouched.

---

## Verdict

**Ready to merge.** Zero Blocking findings. CI is green (19/19 required checks) against the exact branch head. All four cycle-2 verification items in the task's "What to verify" list — exact scope, no test weakened, genuine verification-gap correction, and a genuinely-intact executor self-correction — are independently confirmed, not accepted on report.

Severity: Info
