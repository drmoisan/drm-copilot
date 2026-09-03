# Feature Audit: Portable Prepared Orchestration Handoff (#614)

**Audit Date:** 2026-09-02
**Feature Folder:** docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/
**Base Branch:** main at 9f3514bf5da84110f23617382cbbeabf54f27427
**Head Branch:** feature/portable-prepared-orchestration-handoff-614 at 6230d7912e1ea6ab600609c11420caad74ffed6e
**Work Mode:** full-feature
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Base branch:** main at 9f3514bf5da84110f23617382cbbeabf54f27427.
- **Head branch/commit:** feature/portable-prepared-orchestration-handoff-614 at 6230d7912e1ea6ab600609c11420caad74ffed6e.
- **Merge base:** 9f3514bf5da84110f23617382cbbeabf54f27427.
- **Evidence sources:**
  - Primary: artifacts/pr_context.summary.txt, generated 2026-09-03 02:11:04 UTC.
  - Secondary baseline diff: artifacts/pr_context.appendix.txt.
  - Feature evidence: docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/.
  - Additional evidence: direct committed-head focused Python and TypeScript checks, Git attribute inspection, clean tracked-file SHA-256 checks, and LCOV inspection.
- **Feature folder used:** docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/.
- **Requirements source:** spec.md and user-story.md.
- **Work mode resolution note:** issue.md records Work Mode: full-feature, making spec.md and user-story.md authoritative. The early-draft checkboxes in issue.md were inspected but are not authoritative acceptance sources for this run.
- **Scope note:** The audit covers the full feature-versus-main diff. No caller scope narrowing was supplied or applied. PR context is fresh for the reviewed head.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md — 15 criteria.
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md — 13 criteria.

### From spec.md

1. AC1: A Draft 2020-12, semantically versioned portable handoff envelope validates schema identity, objective, repository, workspace, branch lineage, issue, feature folder, work mode, ordered completed phases, exact next transition, logical complexity, capabilities, and exact plan path/hash before a destination runtime may continue.
2. AC2: Source checkpoint identity uses the raw-byte SHA-256, the original bytes are archived by content digest before canonical replacement, prior provider receipts remain opaque and unchanged, and handoff history is monotonic and digest-linked.
3. AC3: Plan validation accepts only the pinned normalized repository-relative path and raw-byte hash; it rejects absolute paths, .., symlink escape, directory rediscovery, and stale content.
4. AC4: Claude-to-Codex and Codex-to-Claude adapters carry portable complexity, lifecycle, route, plan, and ownership semantics while retaining provider-specific model, reasoning, profile, topology, launch, and receipt evidence only in the expression that produced it.
5. AC5: A destination projection resumes the exact recorded transition and rejects replay of every listed completed phase; destination receipts begin only with the first new destination delegation and never represent historical source work.
6. AC6: Parallel and epic child handoffs validate run/item, kickoff or manifest, parent checkpoint, cohort/wave, owner, and result bindings; an ordinary child can return its bounded result but cannot assume scheduler, barrier, fan-in, integration, cleanup, or parent-completion authority.
7. AC7: Hook and validator allowlists share one semantic MCP alias registry, accept both supported validate_orchestration_artifacts transport spellings as the same registered operation, and reject malformed identifiers, unrelated servers, and approximate or unregistered operations.
8. AC8: Consumer repositories can perform workspace-explicit handoff validation, destination topology resolution, and provider routing through the published extension authority without importing unshipped drm-copilot Python modules; unavailable authority returns the specified single blocked result before delegation.
9. AC9: transition_prepared_orchestration is the only preparation-gate operation permitted to materialize a destination checkpoint; ordinary shell and patch route changes remain denied, and dry-run mode performs no canonical-checkpoint or user-file mutation.
10. AC10: Materialization repeats validation, performs a read-only clean-worktree preflight, writes and validates a same-directory candidate, archives source bytes, and atomically replaces the canonical checkpoint; any failure leaves the source checkpoint intact and records no completed transition.
11. AC11: Python, TypeScript, MCP, and hook tests select the same primary failure using the ordered HANDOFF_* precedence. The TaskMaster fixture's unrelated .csproj changes produce only HANDOFF_DIRTY_WORKTREE after all earlier contract and authority checks pass, with the dirty paths reported and unmodified.
12. AC12: Legacy-v1 migration requires an explicit source provider and independently proven plan, lifecycle, and scheduled-parent facts. The four-field TaskMaster checkpoint cannot fabricate missing history; ambiguous migration stops before source archive or active-checkpoint change.
13. AC13: End-to-end TaskMaster issue #469 fixtures pin source and plan raw-byte hashes, prove Claude-prepared to Codex-execution-ready continuation without completed-phase replay or historical receipt fabrication, and prove the symmetric Codex-to-Claude transition.
14. AC14: Root, extension-resource, core/variant-pack, and installed-consumer parity tests prove all required runtime files ship together and the consumer flow works without drm-copilot source modules.
15. AC15: Regression tests demonstrate that issue #467 remains the sole owner of full Codex-native parallel scheduling and issue #543 remains the sole owner of the provider-specific epic-planner ready-gate defect; #614 changes neither behavior.

### From user-story.md

1. A versioned provider-neutral handoff validates objective, repository, workspace, branch lineage, issue, feature, work mode, completed phases, exact next transition, logical complexity, capability requirements, and exact plan path/hash before a destination may continue.
2. A valid handoff archives the original source checkpoint bytes by raw SHA-256, preserves source receipts as immutable or opaque evidence, appends digest-linked history, and never synthesizes destination receipts for completed source-runtime work.
3. Claude-to-Codex and Codex-to-Claude adapters preserve logical complexity, route, lifecycle, plan, and ownership semantics while each destination independently resolves model, reasoning, profile, topology, and launch evidence for new work only.
4. A completed preparation state advances to its recorded execution transition without replaying promotion, research, feature-document authoring, atomic planning, or preflight, and any attempted replay is rejected before mutation.
5. A parallel or epic child can be completed piecemeal by an ordinary destination orchestrator, but the parent scheduler retains cohort/wave ordering, barriers, fan-in, integration, cleanup, and overall completion authority.
6. Hook and validator allowlists resolve both supported drm-copilot MCP transport spellings to the same registered semantic operation and reject malformed identifiers, unrelated tools, and unregistered operations.
7. A consumer repository can perform workspace-explicit validation, topology resolution, and destination routing through published runtime authority without importing unshipped drm-copilot source modules; missing authority produces one deterministic blocked result before delegation.
8. Dry-run transition changes no canonical checkpoint or user file. Materialization validates a same-directory destination candidate and atomically replaces the canonical checkpoint only after every contract, binding, capability, and clean-worktree check passes.
9. An unrelated dirty worktree is reported separately as HANDOFF_DIRTY_WORKTREE after earlier validation succeeds; the result lists affected paths and does not stage, stash, reset, delete, or modify them.
10. Unsupported schema versions, tampered source or history, wrong repository/workspace/branch/issue/feature, invalid or stale plan identity, scheduler mismatch, invalid transition, and missing capabilities or authorities each fail closed with the contract's deterministic primary code.
11. TaskMaster issue #469 fixtures prove the original Claude-prepared checkpoint reaches Codex execution readiness with its pinned source and plan hashes, no completed-phase replay, and no historical-receipt fabrication; symmetric fixtures prove Codex-to-Claude continuation.
12. Root, bundled, packed, and installed-consumer tests demonstrate that the schema, registry, adapters, hooks, skills, validators, and transition authority remain synchronized and usable from a consumer checkout.
13. Regression coverage confirms issue #467 remains the owner of full Codex-native parallel scheduling and issue #543 remains the owner of the provider-specific epic-planner ready-gate defect; this feature changes neither behavior.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| S1 | Versioned envelope validates required identity and transition fields | PASS | Schema, contract, adapter, and precedence tests | Recorded full Python/Jest evidence and 32/32 compatibility tests | Contract behavior remains verified. |
| S2 | Raw-byte source identity, archive, opaque receipts, linked history | PASS | Provenance, materialization, and history evidence | Recorded contract and transition suites | FR-614-004 concerns plan fixture packaging, not source archive behavior. |
| S3 | Pinned path/hash rejects absolute, traversal, symlink, discovery, and stale content | PASS | Canonical path-boundary implementation and containment evidence | Focused TypeScript re-review, 38/38 | FR-614-001 resolved. |
| S4 | Bidirectional adapters preserve portable/provider-specific boundaries | PASS | Adapter and projection tests | Recorded provider/parity suites | Verified. |
| S5 | Exact transition resumes without replay or fabricated receipts | PASS | Transition/replay tests | Recorded contract and adapter suites | Generic behavior verified independently of the broken fixture packaging. |
| S6 | Scheduled child bindings and parent authority remain bounded | PASS | Parallel/epic ownership evidence | Recorded parity suite | Verified. |
| S7 | Semantic MCP aliases share registry and reject malformed operations | PASS | Registry and hook-process evidence | Recorded Jest and Pester suites | Verified. |
| S8 | Published consumer authority validates/routes and fails closed when absent | PASS | Consumer, pack, and unavailable-authority evidence | Recorded publication/parity suites | Verified. |
| S9 | Only semantic transition materializes; dry run is non-mutating | PASS | Hook and dry-run tests | Recorded TypeScript/Pester suites | Verified. |
| S10 | Materialization validates, checks cleanliness, archives, and atomically replaces | PASS | Materializer containment and full Jest evidence | 54/54 recorded focused tests; 38/38 re-review subset | FR-614-001 resolved. |
| S11 | Ordered HANDOFF_* precedence and dirty-worktree separation | PASS | Precedence matrix and dirty-worktree tests | Recorded Python/Jest/Pester evidence | Verified. |
| S12 | Legacy migration requires independently proven facts | PASS | Legacy migration fixtures | Recorded compatibility/version suites | Verified. |
| S13 | TaskMaster #469 fixtures pin raw hashes and prove both directions | FAIL | FR-614-004 | Focused committed-head pytest failed 2/2 | Both plan bytes hash to 089467... while metadata pins 54c971.... |
| S14 | Root/resource/pack/install parity and source-independent consumer flow | PASS | Publication parity evidence | Recorded parity tests | No packaging-surface drift found outside the raw fixture defect. |
| S15 | #467 and #543 ownership boundaries remain unchanged | PASS | Scope-boundary regression evidence | Recorded 36 parallel and 21 epic tests | Verified. |
| U1 | Provider-neutral handoff validates identity before continuation | PASS | Same as S1 | Contract/validator suites | Verified. |
| U2 | Archive/hash/history and no historical destination receipts | PASS | Same as S2 | Provenance/transition suites | Verified. |
| U3 | Adapters preserve portable semantics and resolve new provider evidence | PASS | Same as S4 | Adapter suites | Verified. |
| U4 | Exact transition continues without replay | PASS | Same as S5 | Replay/transition suites | Verified. |
| U5 | Ordinary child completion preserves parent scheduler authority | PASS | Same as S6 | Ownership suites | Verified. |
| U6 | Both MCP spellings map to one semantic operation | PASS | Same as S7 | Registry/hook suites | Verified. |
| U7 | Consumer uses published authority and fails closed when absent | PASS | Same as S8 | Consumer/pack suites | Verified. |
| U8 | Dry run non-mutating; candidate and replacement are safe | PASS | Same as S9/S10 | Materializer containment suites | Verified after remediation. |
| U9 | Dirty worktree is separately reported and unmodified | PASS | Same as S11 | TaskMaster dirty-worktree scenarios | Verified. |
| U10 | Invalid and tampered cases fail closed with deterministic code | PASS | Path/contract/precedence evidence | 38/38 focused re-review plus recorded compatibility suites | Verified after remediation. |
| U11 | #469 fixtures prove exact pinned continuity in both directions | FAIL | FR-614-004 | Focused committed-head pytest failed 2/2 | Pinned plan digest does not match committed bytes. |
| U12 | Root/bundle/pack/install consumer surfaces remain synchronized | PASS | Same as S14 | Publication/parity evidence | Verified. |
| U13 | #467 and #543 boundaries remain unchanged | PASS | Same as S15 | Scope regressions | Verified. |

## Summary

**Overall Feature Readiness:** BLOCKED

REVIEW_STATUS: REMEDIATION_REQUIRED

**Criteria summary:**

- **PASS:** 26 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 2 criteria

**Top gaps preventing PASS:**

1. FR-614-004: both committed TaskMaster #469 plan fixture digests conflict with their metadata and fail the exact-head test.

**Recommended follow-up verification steps:**

1. Make the fixture byte representation, Git attributes, and pinned metadata self-consistent without runtime or pre-test hydration.
2. Run the focused pinned-hash test, full Python coverage, and integration/parity commands from unmodified committed bytes.
3. Re-evaluate S13 and U11, then recheck their source markers only after both pass.

## Acceptance Criteria Check-off

Spec AC13 and user-story criterion 11 were changed from checked to unchecked after the committed-head failure was independently reproduced. No criterion text was modified. All other authoritative markers remain checked because their mapped evidence still passes. issue.md was inspected for work-mode resolution and its early-draft criteria, but its checkboxes are not authoritative under full-feature mode and were not changed.

### AC Status Summary

- Source: spec.md and user-story.md.
- Total AC items: 28.
- Checked off (delivered): 26.
- Remaining (unchecked): 2.
- Items remaining: spec AC13 and user-story criterion 11.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| spec.md | 15 | 14 | 1 | AC13 is unchecked and FAIL. |
| user-story.md | 13 | 12 | 1 | Criterion 11 is unchecked and FAIL. |
| issue.md | 9 early-draft AC items | 0 | 9 | Inspected but non-authoritative for full-feature mode. |
