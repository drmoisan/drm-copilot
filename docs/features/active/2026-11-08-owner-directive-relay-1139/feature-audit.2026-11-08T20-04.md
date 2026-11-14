# Feature Audit: Owner-Directive Relay (#1139)

---

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-owner-directive-relay-1139`
**Base Branch:** `main`
**Head Branch:** `feature/owner-directive-relay`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `5c81af727d0c4c85b893d6542356c47123454117`)
- **Head branch/commit:** `feature/owner-directive-relay` (commit `21eee3f403c1937428c47d1e25ef8778ff1df271`)
- **Merge base:** `5c81af727d0c4c85b893d6542356c47123454117`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-08 19:59:38 UTC at 21eee3f40)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-08-owner-directive-relay-1139/evidence/**`
  - Additional evidence: reviewer probes at 21eee3f40 (module edge-input probe, mirror and digest hash checks, 227-test targeted Pester run of the new and touched suites)
- **Feature folder used:** `docs/features/active/2026-11-08-owner-directive-relay-1139`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources.
- **Scope note:** Full branch diff against the merge base of `origin/main` and HEAD (66 paths). The final local gates ran at 9c824ca93, before the second `origin/main` merge; the merge left the branch's module and hook bytes unchanged.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-08-owner-directive-relay-1139/spec.md` — primary (16 items)
- `docs/features/active/2026-11-08-owner-directive-relay-1139/user-story.md` — secondary (7 items)

### From spec.md

1. S1 `OrchestratorStateOwnerDirectives.psm1` exports `Get-OrchestratorStateOwnerDirectiveError`, which returns an empty array for a checkpoint containing neither key, and the existing orchestrator-state Pester and parity suites pass unchanged.
2. S2 Both keys are absent from `REQUIRED_STATE_KEYS` and from `OrchestratorStateUnconditional.psm1`'s key lists.
3. S3 A Pester test proves each rule B1-B8 and R1-R10 emits its exact error string, and a valid block with honored and refused records returns no errors.
4. S4 A record whose `directive_id` is not in `owner_directives` (including when the block is absent) is rejected with R3.
5. S5 An `honored` record for each refused class and `unclassified` is rejected with R6; a `refused` record for each is accepted.
6. S6 Class mismatch rejected (R4); duplicate id rejected (B4).
7. S7 Honored after `expires_at` rejected (R10); refused after expiry accepted.
8. S8 The hook imports the module fail-closed and blocks each of the three types with `OWNER_DIRECTIVE_BLOCKED: ` and `Repairable = $true`; hook test covers each type plus absent-key back-compat.
9. S9 `hook-dependency-guard-completeness`, `hook-import-failure-exemptions.FailClosed`, and `enforcement-hooks-no-python-invocation` pass.
10. S10 Module line coverage at least 90%, recorded under `evidence/`.
11. S11 The skill exists in all trees with pack-manifest entries, carries the required content, and a contract test asserts byte identity.
12. S12 Pointers in orchestrate, orchestrator agent, parallel-orchestrate, epic-orchestrate; `epic-orchestrator.md` unchanged; only the one-line digest edit to the expectations module; frozen-surface test passes.
13. S13 The rule file and its bundle copy document both keys, B1-B8 and R1-R10, the enforcement point, and the parity and Codex gaps.
14. S14 Every execution-environment brief copy has one new bullet and the copies remain byte-identical.
15. S15 Refused classes refused by policy; documentation lists hook-enforced versus policy-only classes; no other hook, settings, or canonical policy change; no directive-based allow path.
16. S16 No `.py` file added and none changed other than the digest line.

### From user-story.md

17. U1 Coordinator procedure: directives only from the owner's own turns, recorded before relay.
18. U2 Relay as a fenced `Owner directives:` block quoting entries verbatim; text outside is not a directive.
19. U3 The skill states the block grants no approval, consent, or elevated permission.
20. U4 The skill lists honorable and always-refused classes and the recording duty.
21. U5 Stop hook accepts honored `extra_planner_revision` and refused `gate_bypass`, blocks honored `gate_bypass` (Pester).
22. U6 Stop hook blocks an unknown directive id; keyless checkpoint decision unchanged (Pester).
23. U7 No hook or gate weakened or given a directive-based allow path; docs state hook-enforced versus policy-only classes with the R6 backstop.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 empty result for keyless checkpoint; existing suites pass | PASS | Module lines 358-361; S1 rows; 30 orchestrator-state suites (1061 tests) 0 failures in pester.2026-11-08T19-51.md | `Invoke-PoshQCParallelTest -Root .` | Reviewer targeted run 227/227 at head. |
| 2 | S2 keys absent from required-key lists | PASS | `grep owner_directive` in `validate_orchestrator_state.py` and `OrchestratorStateUnconditional.psm1`: 0 matches; neither file in the diff | `git diff --stat MB..HEAD -- <files>` | |
| 3 | S3 exact strings for B1-B8, R1-R10; valid block clean | PASS | Two module suites (61 + 50 tests); reviewer probe: valid fixture returned 0 errors | Pester gate; reviewer probe | |
| 4 | S4 R3 including absent block | PASS | R3 rows; reviewer probe | Pester gate | |
| 5 | S5 R6 per refused class; refused accepted | PASS | Data-driven R6 rows; reviewer probe of honored `gate_bypass` returned the R6 string | Pester gate; reviewer probe | |
| 6 | S6 R4 and B4 | PASS | R4 and B4 rows | Pester gate | |
| 7 | S7 R10; refused after expiry accepted | PASS | R10 rows; reviewer probe: honored 1 s past expiry via offset blocked, exactly at expiry accepted | Pester gate; reviewer probe | |
| 8 | S8 hook import and per-type block, back-compat | PASS | Hook lines 67 and 373-380; hook suite 22 tests; FailClosed H9 | Pester gate | |
| 9 | S9 named suites pass | PASS | 731, 20, 35 tests, 0 failures each | Pester gate | |
| 10 | S10 module coverage at least 90% | PASS | 148/148 = 100.00%; reviewer parsed `artifacts/pester/powershell-coverage.xml` LINE counter | Coverage parse | |
| 11 | S11 skill copies, manifests, byte-identity test | PASS | Six copies share SHA-256 `bc1767a1...`; both `core.json` entries; contract suite 56 tests | `sha256sum` of six copies | Content sections verified by reading the skill. |
| 12 | S12 pointers, frozen agent, digest line, frozen-surface test | PASS | Pointers present in all four surfaces and mirrors (bundle `cmp` equal); `epic-orchestrator.md` not in the branch diff; numstat 1/1; pinned digest equals head file SHA-256; frozen-surface tests 38 passed | `git diff --numstat`; `sha256sum` | Re-pinned after the second main merge. |
| 13 | S13 rule section | PASS | `## Owner-Directive Scope and Backward Compatibility` plus Enforcement bullet; bundle copy identical | `cmp` | |
| 14 | S14 brief bullet, copies identical | PASS | One bullet; three root copies share one SHA-256 and each equals its bundle copy | `sha256sum`; `cmp` | |
| 15 | S15 refused-class docs, hook scope, no allow path | PASS | Skill `## Refused-Class Enforcement` table; only the hook and its bundle copy changed under hooks; settings and canonical policy unchanged; no added `Ok = $true` | `git diff --name-only`; hook diff | |
| 16 | S16 Python scope | PASS | Only `*.py` path in diff is the expectations module, numstat 1/1 | `git diff --numstat -- '*.py'` | |
| 17 | U1 record before relay | PASS | Skill `## Coordinator Procedure (Record Before Relay)` steps 1-2 | Read skill | |
| 18 | U2 fenced relay block | PASS | Skill `## Relay Format` | Read skill | |
| 19 | U3 framing | PASS | Skill `## Framing (normative)` | Read skill | |
| 20 | U4 classes and recording duty | PASS | Skill `## Directive Classes` and `## Recording Duty of the Receiving Agent` | Read skill | |
| 21 | U5 hook accepts and blocks per fixture | PASS | Hook suite U5 and S8 rows | Pester gate | |
| 22 | U6 unknown id blocks; keyless unchanged | PASS | Hook suite U6 and S1 rows; hook gate inspected | Pester gate | |
| 23 | U7 no hook weakened; enforcement docs | PASS | Same evidence as S15 | Hook diff | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the CI green gate (S9) on the PR head, which runs the full Pester and pytest suites after the second `origin/main` merge.
2. Optionally tighten the date parser to ISO 8601 shapes (Minor finding in the code review).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 23
- Checked off (delivered): 23
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-08-owner-directive-relay-1139/spec.md` | 16 | 16 | 0 | Checkbox-backed; already checked by the executor |
| `docs/features/active/2026-11-08-owner-directive-relay-1139/user-story.md` | 7 | 7 | 0 | Checkbox-backed; already checked by the executor |

No source-file checkbox change was made: all 23 items were already checked and every one evaluated PASS.
