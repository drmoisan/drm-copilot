# Feature Audit: Portable Prepared Orchestration Handoff (#614)

**Audit Date:** 2026-09-03  
**Reviewer:** feature-review delegation `s9-final-feature-review-614-001`  
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/`  
**Work Mode:** `full-feature`  
**Base:** `origin/main` at `9f3514bf5da84110f23617382cbbeabf54f27427`  
**Reviewed Head:** `541e8d89250bdc9a49f78c4ac4fcb6217799a4dd`

## Scope and Baseline

This audit covers the complete merge-base-to-head feature scope, not only the final fixture commit. Fresh canonical PR context generated at 2026-09-03 03:57:45 UTC reports 193 changed files, 20,677 insertions, and 513 deletions. The scope includes the portable v2 handoff schema, Python and TypeScript contracts and adapters, published extension authority and transition tools, canonical path containment, checkpoint projection/materialization, semantic MCP aliasing, provider and scheduler ownership boundaries, hook and resource publication, TaskMaster #469 fixtures, tests, QA evidence, and review history.

Authoritative acceptance sources for `full-feature` mode are:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` — 15 criteria.
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md` — 13 criteria.

`issue.md` was inspected for objective and work-mode context, but its nine early-draft unchecked items are not the authoritative checklist for this review.

Baseline and QA evidence records complete green Python, TypeScript, and PowerShell toolchains, contract/schema compatibility, architecture, integration/publication parity, path containment, and raw fixture identity. Direct final-head checks reconfirmed both 101,998-byte TaskMaster plan fixtures and their pinned digest, the 2/2 focused Python hash cases, 61/61 focused TypeScript authority/materializer/contract tests, all file-size limits, and the exact branch/base/head identity.

The implementation review also produced a direct negative reproduction. With the workspace and envelope digest valid, changing `repository_id`, `branch`, `source_head_sha`, `issue_number`, `feature_folder`, and `work_mode` still returned `status: validated` from the production authority. This is FR-614-005 and changes seven acceptance outcomes below.

## Acceptance Criteria Inventory

### From spec.md

1. AC1: A Draft 2020-12, semantically versioned portable handoff envelope validates schema identity, objective, repository, workspace, branch lineage, issue, feature folder, work mode, ordered completed phases, exact next transition, logical complexity, capabilities, and exact plan path/hash before a destination runtime may continue.
2. AC2: Source checkpoint identity uses the raw-byte SHA-256, the original bytes are archived by content digest before canonical replacement, prior provider receipts remain opaque and unchanged, and handoff history is monotonic and digest-linked.
3. AC3: Plan validation accepts only the pinned normalized repository-relative path and raw-byte hash; it rejects absolute paths, `..`, symlink escape, directory rediscovery, and stale content.
4. AC4: Claude-to-Codex and Codex-to-Claude adapters carry portable complexity, lifecycle, route, plan, and ownership semantics while retaining provider-specific model, reasoning, profile, topology, launch, and receipt evidence only in the expression that produced it.
5. AC5: A destination projection resumes the exact recorded transition and rejects replay of every listed completed phase; destination receipts begin only with the first new destination delegation and never represent historical source work.
6. AC6: Parallel and epic child handoffs validate run/item, kickoff or manifest, parent checkpoint, cohort/wave, owner, and result bindings; an ordinary child can return its bounded result but cannot assume scheduler, barrier, fan-in, integration, cleanup, or parent-completion authority.
7. AC7: Hook and validator allowlists share one semantic MCP alias registry, accept both supported spellings of `validate_orchestration_artifacts` as the same registered operation, and reject malformed identifiers, unrelated servers, and approximate or unregistered operations.
8. AC8: Consumer repositories can perform workspace-explicit handoff validation, destination topology resolution, and provider routing through the published extension authority without importing unshipped drm-copilot Python modules; unavailable authority returns the specified single blocked result before delegation.
9. AC9: `transition_prepared_orchestration` is the only preparation-gate operation permitted to materialize a destination checkpoint; ordinary shell and patch route changes remain denied, and dry-run mode performs no canonical-checkpoint or user-file mutation.
10. AC10: Materialization repeats validation, performs a read-only clean-worktree preflight, writes and validates a same-directory candidate, archives source bytes, and atomically replaces the canonical checkpoint; any failure leaves the source checkpoint intact and records no completed transition.
11. AC11: Python, TypeScript, MCP, and hook tests select the same primary failure using the ordered `HANDOFF_*` precedence. The TaskMaster fixture's unrelated `.csproj` changes produce only `HANDOFF_DIRTY_WORKTREE` after all earlier contract and authority checks pass, with the dirty paths reported and unmodified.
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
6. Hook and validator allowlists resolve both supported `drm-copilot` MCP transport spellings to the same registered semantic operation and reject malformed identifiers, unrelated tools, and unregistered operations.
7. A consumer repository can perform workspace-explicit validation, topology resolution, and destination routing through published runtime authority without importing unshipped drm-copilot source modules; missing authority produces one deterministic blocked result before delegation.
8. Dry-run transition changes no canonical checkpoint or user file. Materialization validates a same-directory destination candidate and atomically replaces the canonical checkpoint only after every contract, binding, capability, and clean-worktree check passes.
9. An unrelated dirty worktree is reported separately as `HANDOFF_DIRTY_WORKTREE` after earlier validation succeeds; the result lists affected paths and does not stage, stash, reset, delete, or modify them.
10. Unsupported schema versions, tampered source or history, wrong repository/workspace/branch/issue/feature, invalid or stale plan identity, scheduler mismatch, invalid transition, and missing capabilities or authorities each fail closed with the contract's deterministic primary code.
11. TaskMaster issue #469 fixtures prove the original Claude-prepared checkpoint reaches Codex execution readiness with its pinned source and plan hashes, no completed-phase replay, and no historical-receipt fabrication; symmetric fixtures prove Codex-to-Claude continuation.
12. Root, bundled, packed, and installed-consumer tests demonstrate that the schema, registry, adapters, hooks, skills, validators, and transition authority remain synchronized and usable from a consumer checkout.
13. Regression coverage confirms issue #467 remains the owner of full Codex-native parallel scheduling and issue #543 remains the owner of the provider-specific epic-planner ready-gate defect; this feature changes neither behavior.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| S1 | Versioned envelope validates all required identity and transition bindings before continuation | FAIL | FR-614-005 | Direct production-authority reproduction plus source anchors at authority 227-246 | Repository, branch, source HEAD, issue, feature, and work mode are not independent of the envelope. |
| S2 | Raw source identity, archive, opaque receipts, and linked history | PASS | Source/archive/provenance suites and QA evidence | Full Python/Jest and integration suites | Verified. |
| S3 | Exact plan path/hash rejects absolute, traversal, symlink, discovery, and stale content | PASS | Canonical path boundary and focused containment evidence | Recorded containment suites and direct source inspection | FR-614-001 remains resolved. |
| S4 | Bidirectional adapters preserve portable/provider-specific boundaries | PASS | Adapter, projection, and provider tests | Recorded contract and integration suites | Verified. |
| S5 | Exact transition resumes without replay or historical receipt fabrication | PASS | Transition/replay tests | Recorded Python/Jest suites | Verified. |
| S6 | Scheduled child bindings preserve parent scheduler authority | PASS | Scheduler fixtures and boundary tests | Recorded integration/parity suite | Verified. |
| S7 | Semantic aliases share a registry and malformed operations fail | PASS | Registry, hook, and MCP tests | Recorded Jest/Pester suites | Verified. |
| S8 | Published consumer authority validates, resolves, routes, and fails closed when absent | FAIL | FR-614-005 | Direct production-authority reproduction; public request/interface inspection | Authority is published and source-independent but its validation context is incomplete. |
| S9 | Only semantic transition materializes; dry run is non-mutating | PASS | Hook and dry-run tests | Recorded TypeScript/Pester suites | Verified. |
| S10 | Materialization repeats every binding check before archive/candidate/replacement | FAIL | FR-614-005 | Materializer 19-28 and 259-278; authority 227-246 | Write order is safe, but required independent bindings are not checked. |
| S11 | Ordered failure precedence and dirty-worktree separation | PASS | Cross-language precedence and dirty-worktree cases | Contract/schema and integration suites | Verified for implemented checks. |
| S12 | Legacy migration requires independently proven facts | PASS | Migration and ambiguity fixtures | Recorded compatibility suites | Verified. |
| S13 | TaskMaster #469 exact raw hashes and both directions | PASS | Final fixture evidence and direct final-head reproduction | Focused pytest 2 passed; working/index/Windows/Linux hash check | FR-614-004 is resolved with no hydration mechanism. |
| S14 | Root/resource/pack/install parity and source-independent consumer flow | PASS | Publication and installed-consumer tests | Integration/parity 167/167 | Verified for shipped bytes. |
| S15 | #467 and #543 ownership boundaries remain unchanged | PASS | Scope-boundary regressions | Recorded parallel/epic regression suites | Verified. |
| U1 | Provider-neutral handoff validates identity before continuation | FAIL | FR-614-005 | Same direct reproduction as S1 | Six contextual bindings can be altered without rejection. |
| U2 | Archive/hash/history and no historical destination receipts | PASS | Same as S2 | Provenance/transition suites | Verified. |
| U3 | Adapters preserve portable semantics and new provider evidence | PASS | Same as S4 | Adapter and projection suites | Verified. |
| U4 | Exact transition continues without replay | PASS | Same as S5 | Replay/transition suites | Verified. |
| U5 | Ordinary child completion preserves parent scheduler authority | PASS | Same as S6 | Ownership suites | Verified. |
| U6 | Both MCP spellings map to one semantic operation | PASS | Same as S7 | Registry/hook suites | Verified. |
| U7 | Consumer uses published authority and fails closed when absent | FAIL | FR-614-005 | Same as S8 | Availability behavior passes, but published validation is incomplete. |
| U8 | Dry run is non-mutating and materialization follows every binding check | FAIL | FR-614-005 | Same as S9/S10 | Dry-run/write-order behavior passes; the universal binding prerequisite does not. |
| U9 | Dirty worktree is separately reported and unmodified | PASS | Dirty-worktree fixtures | Recorded TaskMaster/integration scenarios | Verified. |
| U10 | Invalid/tampered/context mismatch cases fail closed deterministically | FAIL | FR-614-005 | Direct changed-binding reproduction returned validated | Wrong repository, branch, source HEAD, issue, feature, and work mode do not fail at the production authority. |
| U11 | #469 exact pinned continuity in both directions | PASS | Same as S13 | Focused pytest and byte-identity verification | Verified. |
| U12 | Root/bundle/pack/install consumer surfaces remain synchronized | PASS | Same as S14 | Publication/parity suite | Verified. |
| U13 | #467 and #543 boundaries remain unchanged | PASS | Same as S15 | Scope regressions | Verified. |

## Summary

**Overall Feature Readiness:** BLOCKED

REVIEW_STATUS: REMEDIATION_REQUIRED

**Criteria summary:**

- **PASS:** 21 criteria.
- **PARTIAL:** 0 criteria.
- **UNVERIFIED:** 0 criteria.
- **FAIL:** 7 criteria.

**Top gap preventing PASS:**

1. FR-614-005: the supported production authority/transition boundary does not obtain independent repository, branch/source-HEAD lineage, issue, feature, or work-mode context and therefore accepts envelopes with those contextual bindings changed.

**Required follow-up verification:**

1. Establish an independently trusted request or checkout/source-checkpoint observation for every affected binding and propagate it through topology, routing, and transition.
2. Add production authority and materialization tests that hold expected/observed context fixed while changing each envelope field, assert the defined primary code, and prove no governed write occurs.
3. Update and verify all public schemas, handlers, services, resource copies, packs, and installed-consumer parity affected by the request contract.
4. Run the complete formatting, linting, typing, testing, coverage, architecture, and publication-parity loop.
5. Reconcile the seven unchecked authoritative criteria only from direct passing evidence, then repeat the full feature review.

## Acceptance Criteria Check-off

This review changed only seven checkbox markers from checked to unchecked. Criterion text and every other marker remain unchanged:

- `spec.md`: AC1, AC8, and AC10 are unchecked for FR-614-005.
- `user-story.md`: criteria 1, 7, 8, and 10 are unchecked for FR-614-005.

All three prior valid findings remain resolved. Spec AC13 and user-story criterion 11 remain checked because direct final-head raw-byte evidence passes. `issue.md` remains unchanged because its early-draft checklist is not authoritative in `full-feature` mode.

### AC Status Summary

- Source: `spec.md` and `user-story.md`.
- Total AC items: 28.
- Checked off (delivered): 21.
- Remaining (unchecked): 7.
- Items remaining: spec AC1, AC8, AC10; user-story criteria 1, 7, 8, 10.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 15 | 12 | 3 | AC1, AC8, and AC10 fail under FR-614-005. |
| `user-story.md` | 13 | 9 | 4 | Criteria 1, 7, 8, and 10 fail under FR-614-005. |
| `issue.md` | 9 early-draft items | 0 | 9 | Inspected but non-authoritative for `full-feature` mode. |
