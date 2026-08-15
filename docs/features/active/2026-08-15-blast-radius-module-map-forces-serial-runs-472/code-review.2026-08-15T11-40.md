# Code Review: blast-radius-module-map-forces-serial-runs (Issue #472)

---

**Review Date:** 2026-08-15
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `768e485ddf3b48b16aa7588a72709e17568ee5f5`)
**Head Branch:** `bug/blast-radius-module-map-forces-serial-runs-472` at `a45a993b`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes issue #472 in two composed parts: (Defect A) the `docs` and `tests` location-bucket modules are deleted from both committed `blast-radius.json` copies, removing the universal module-overlap that made every pair of parallel items conflict; (Defect B) the TypeScript push-down surface gains a write-intercepting `BlastRadiusDeriveFileSystem` decorator plus a pure core `deriveDestinationModuleMap` that derives the destination's module map from its actual layout at push-down time. The production diff is small and disciplined (2 JSON copies, 2 new TS modules, 2 modified TS modules — one comment-only); the test diff is substantial and high quality (57 new Jest tests, 6 new pytest cases, 2 new Pester cases, plus the AC14 rewrite of a previously tautological genericity test into a property assertion).

**What changed:**
The pure core owns algorithm steps 2-8 with no I/O; the decorator owns the depth-limited breadth-first scan (step 1) behind an injectable `DirectoryLister` seam and intercepts exactly one destination-relative path. Composition in `pushDownCustomizations` sits adjacent to the existing `RoutingMergeFileSystem` precedent. Failure semantics are explicit named error classes raised before any write.

**Top 3 risks:**
1. The guard-trip ordering at the decorator boundary is pinned indirectly (via the `BlastRadiusDeriveError` path) rather than directly (the `BlastRadiusGuardError` path is unreachable through the composed scanner) — verified acceptable via mutant probes, see Findings.
2. `MANIFEST_FILENAMES`/`MANIFEST_SUFFIXES`/`EXCLUDED_DIR_NAMES` are fixed judgment lists; an unanticipated destination stack (e.g. a `Makefile`-only C project) falls through to the top-level-directory fallback, which is coarse but defined and fail-open at the module level.
3. The PR-context parser lists incidental author-asserted autoclose candidates (#452, #462, `#ISO-8601`); a PR body that copies them would close the wrong issues.

**PR readiness recommendation:** **Go** — all toolchain stages pass at the head, all findings are Info-level, and both adversarial mutant probes were killed by the delivered tests.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | lines 271-295 | The case `still surfaces a guard trip as a raise before any write` calls `deriveDestinationModuleMap` directly and then reads back the seeded destination file. Because no decorator method is invoked in the Act step, the destination-bytes assertion cannot fail through that call path (nothing could have written). | Optionally reword the case comment to state that the untouched-bytes claim is carried by the unparseable-document case, or drop the read-back assertion. No production change needed. | An assertion that cannot fail can mislead a future reader about what is pinned. The ordering contract itself is genuinely pinned elsewhere: the reviewer's write-reorder mutant (inner write moved before derivation) was killed by `fails an unparseable bundled document and names the path`, which shares the same single derive-then-write call site (`claude-blast-radius-derive.ts:291-292`), and the guard-delete mutant was killed by 4 tests including this one. | Reviewer mutant probes: guard-delete -> 4 failed; write-reorder -> 1 failed; both reverted, `git status --porcelain` clean |
| Info | PR context (`artifacts/pr_context.summary.txt`) | Close candidates section | Author-asserted autoclose candidates include #452, #462, and a spurious `#ISO-8601` token, all parsed from feature-doc text rather than intended closures. #452 is explicitly out of scope per spec.md; #462 is already delivered. | When authoring the PR, use closing keywords for #472 only. | Incorrect closing keywords would close an open, unrelated issue (#452). | `artifacts/pr_context.summary.txt` "Close candidates" section; `spec.md` Scope & Non-Goals |
| Info | `artifacts/research/` (untracked, pre-existing) | n/a | `validate_evidence_locations.py` exits 1 on two untracked research files that predate this branch and appear in no diff. | Housekeeping outside this feature: move or delete the two local files. | Standing item recorded in the #331, #397, #469 audits; not attributable to this branch. | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exit 1; `git diff 768e485d..HEAD --name-only` contains no `artifacts/` path |
| Info | repo-wide JSON gates | n/a | `format_json --check` reports 9 pre-existing files that would reformat; `validate_json` reports 2 pre-existing evidence checkpoints without `$schema`. None of the 11 paths is in this branch's diff; both changed blast-radius copies are compliant. | Housekeeping outside this feature. | Pre-existing repo state; the branch neither introduced nor touched these files. | Reviewer runs of both tools with per-file output cross-checked against `git diff --name-only` |

No Blockers, Major, Minor, or Nit findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- Clean purity boundary: `claude-blast-radius-derive-core.ts` imports nothing host-bound (no `fs`, no clock, no randomness) and every function is a deterministic transform; the decorator owns all I/O behind the `DirectoryLister` seam. This exactly mirrors the repository's stated separation-of-concerns policy and the `RoutingMergeFileSystem` precedent.
- Determinism is engineered, not incidental: ordinal comparators everywhere (with a comment explaining why locale collation is rejected), breadth-first scan with sorted queues, insertion-order-controlled serialization, and a byte-identity test plus an input-non-mutation test.
- The `PushDownFileSystem` contract is not widened: the decorator implements exactly the six existing members, and `ClaudePushDownOptions` grows only an optional `listEntries` with a real-filesystem default — non-breaking per policy.
- Error design is contract-oriented: `BlastRadiusDeriveError` carries `path`, `BlastRadiusGuardError` carries `moduleName` and `glob`, and both are raised before the inner write so destination bytes survive failures (mutant-verified).
- The guard checks the assembled map rather than intermediate stages, so it also covers `PAYLOAD_MODULES` and any future contributor to the map — a deliberate, commented choice.

#### Type safety and maintainability

- No `any`, no type assertions beyond two commented, narrowed `as` casts in test helpers; the source document is parsed into an explicit `JsonValue`/`JsonObject` shape with a non-object-root rejection.
- Zero suppression comments across all 8 changed TS files (grep-verified: no `eslint-disable`, `@ts-expect-error`, `@ts-ignore`, `@ts-nocheck`).
- Both new modules carry full header doc blocks (purpose, responsibilities, invariants, side effects) and JSDoc on every export.

#### Error handling and logging

- The two catch-alls (real lister, `listTolerantly`) are the documented tolerance rule mirroring `RealPushDownFileSystem.listFiles`, each returning a defined empty result with a rationale comment — this is the pinned behavior required so existing in-memory push-down tests keep passing, not a silent swallow.

### Python implementation audit

#### What changed well

- Test-only change; the regression gate runs against the committed config (the spec's stated rationale: the defect lived in the committed map, so a test-local map proves nothing).
- Helpers (`derive_item_radius`, `reason_kinds`, `reason_detail`, `derive_matrix_pair`) are fully typed with Google-style docstrings; `reason_detail` deliberately avoids `next()`/`StopIteration` so a miss fails with a named assertion.
- The two-config negative pin parametrizes over labelled paths so a failure names the offending copy, and checks both module names and globs (rename-resistant, as commented).

#### Typing and API notes

- No new public Python API surface was added; `TYPE_CHECKING`-gated imports keep runtime imports minimal.

#### Error handling and logging

- Not applicable beyond assertion messages; no production Python changed (AC15 pin verified by empty diff).

### PowerShell implementation audit

#### What changed well

- The two new Parity cases mirror the Python assertions case-for-case and say so in comments; ordinal `-ccontains` matches the Python reference's case-sensitive semantics — cross-runtime parity is explicit rather than assumed.
- The `BlastRadiusConfig.Tests.ps1` amendment is the minimal count-pin change (14 -> 12) the config deletion arithmetically requires.

#### API and safety notes

- Test files only; no production PowerShell changed, so advanced-function/ShouldProcess requirements do not apply.

#### Error handling and logging

- Offending names/globs are collected into lists before assertion so a failure prints the violating entries.

---

## Test Quality Audit

The delivered test surface pins every level of the fix: the committed-config truth table (Python + PowerShell, red-before/green-after evidence recorded), the derivation algorithm per step (Jest core suite), the decorator's scan/interception/tolerance/idempotency behavior (Jest decorator suite), and the rewritten genericity property (carriage suite). The reviewer went beyond re-running suites: two targeted mutants were applied to production files and both were killed by the delivered tests, upgrading the "tests discriminate" claim from asserted to verified.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` — 43 hermetic core tests; covers all eight algorithm steps including guard error fields and non-object source roots; kills the guard-delete mutant.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` — 14 decorator tests; depth bound, pruning, foreign-root non-interception, tolerance, failure semantics, idempotency; kills the write-reorder mutant via the unparseable-document case. One vacuous read-back assertion noted (Findings, Info).
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` — AC14 rewrite verified: no `toBe(SOURCE_BLAST_RADIUS)` assertion on the published blast-radius document remains; the property form asserts destination-module presence, forbidden-glob absence, and drm-copilot-entry absence; the overwrite case now discriminates against both the seed and the pre-existing destination bytes.
- `tests/scripts/dev_tools/test_blast_radius_config.py` — regression gate + matrix + negative pin; reviewer rerun 45/45.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` and `BlastRadiusConfig.Tests.ps1` — mirrored gate and count pin; reviewer direct Pester rerun 322/322.
- `evidence/regression-testing/fail-before-*.md` and `pass-after-*.md` — red-before/green-after pairs for the pytest and Pester gates (exit 1/2 before the config fix, exit 0 after), proving the gate discriminates on the committed config.
- `evidence/regression-testing/expected-red-ts-phase4.2026-08-15T11-55.md` — records the AC9 deviation rationale and the planned red state (the two pre-rewrite AC8 tests) resolved in Phase 5.

### Quality assessment prompts

- **Determinism:** No clock/randomness/network in any new test; fixed `COMPUTED_AT` constant; `fixedClock`; injected listers; ordinal ordering assertions.
- **Isolation:** One behavior per case throughout; state constructed per-test.
- **Speed:** Reviewer-observed: Jest push-down scope 4.0s, pytest scope 0.10s, Pester folder 3.9s.
- **Diagnostics:** Assertion messages name observed reasons, offending files, or offending globs; guard error fields are asserted individually.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: config keys and module names only; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess use anywhere in the diff; the only new host API is `fs.readdirSync` behind the lister seam. |
| Input validation at boundaries | ✅ PASS | Source document parse is validated (non-JSON and non-object roots rejected with named errors); foreign-root paths are not intercepted (`relativeToPosix` anchors on the destination root with a separator-anchored prefix). |
| Error handling remains explicit | ✅ PASS | Named error classes with contract fields; catch-alls limited to the documented lister-tolerance rule with immediate defined results. |
| Configuration / path handling is safe | ✅ PASS | Path normalization strips trailing separators and normalizes to POSIX; ancestor pruning anchors on `/` to avoid prefix-name collisions (tested via `pack`/`packages`). |

---

## Research Log

No external research was required. All evidence derives from the branch diff, the feature folder's evidence artifacts, repository policy files, and reviewer-executed commands.

---

## Verdict

The change is ready for normal PR flow. The production design follows the established decorator precedent with a strict purity split, the delivered tests discriminate (proven by two killed mutant probes rather than asserted), the previously tautological genericity gate is now a property test, and the committed-config regression gate has recorded red-before/green-after evidence in both mirror languages. All four findings are Info-level: one test-comment clarity note, one PR-authoring caution about incidental autoclose candidates, and two pre-existing repo housekeeping items outside this branch's diff. Recommendation: **Go**.
