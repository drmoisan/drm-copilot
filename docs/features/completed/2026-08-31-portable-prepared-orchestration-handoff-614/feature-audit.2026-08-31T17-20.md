# Feature Audit: Portable Prepared Orchestration Handoff (#614)

**Audit Date:** 2026-08-31
**Reviewer:** `feature-reviewer-c4` delegation `s9-feature-review-614-001`
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/`
**Base Branch:** `main`
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614` at `b06a3516d52d1693a38106eeb33817c261983620`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main`; PR context resolved `origin/main` at collection time.
- **Head branch/commit:** `feature/portable-prepared-orchestration-handoff-614` / `b06a3516d52d1693a38106eeb33817c261983620`.
- **Merge base:** `9f3514bf5da84110f23617382cbbeabf54f27427`.
- **Primary evidence:** `artifacts/pr_context.summary.txt` generated 2026-09-03 00:45:31 UTC and matching reviewed HEAD.
- **Secondary baseline diff:** `artifacts/pr_context.appendix.txt`, same generation time and head SHA.
- **Feature evidence:** all files under `evidence/baseline/`, `evidence/qa-gates/`, and `evidence/other/`.
- **Additional evidence:** original 108-task plan, issue, spec, user story, implementation research, machine-readable coverage artifacts, code inspection, line-cap check, commit ancestry, and `git diff --check`.
- **Feature folder used:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/`.
- **Requirements source:** `spec.md` and `user-story.md` as directed by `issue.md` work mode `full-feature`.
- **Work mode resolution note:** `issue.md` explicitly records `full-feature`.
- **Scope note:** review is against the recorded merge base, which is the refreshed `origin/main` tip. PR context reports 119 changed files, 15,272 insertions, and 513 deletions. CI status is unverified because GitHub CLI status was unavailable; local baseline and QA evidence is present.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` — primary technical acceptance source, 15 items.
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md` — primary user acceptance source, 13 items.

### From `spec.md`

1. AC1: A Draft 2020-12, semantically versioned portable handoff envelope validates schema identity, objective, repository, workspace, branch lineage, issue, feature folder, work mode, ordered completed phases, exact next transition, logical complexity, capabilities, and exact plan path/hash before a destination runtime may continue.
2. AC2: Source checkpoint identity uses the raw-byte SHA-256, the original bytes are archived by content digest before canonical replacement, prior provider receipts remain opaque and unchanged, and handoff history is monotonic and digest-linked.
3. AC3: Plan validation accepts only the pinned normalized repository-relative path and raw-byte hash; it rejects absolute paths, `..`, symlink escape, directory rediscovery, and stale content.
4. AC4: Claude-to-Codex and Codex-to-Claude adapters carry portable complexity, lifecycle, route, plan, and ownership semantics while retaining provider-specific model, reasoning, profile, topology, launch, and receipt evidence only in the expression that produced it.
5. AC5: A destination projection resumes the exact recorded transition and rejects replay of every listed completed phase; destination receipts begin only with the first new destination delegation and never represent historical source work.
6. AC6: Parallel and epic child handoffs validate run/item, kickoff or manifest, parent checkpoint, cohort/wave, owner, and result bindings; an ordinary child can return its bounded result but cannot assume scheduler, barrier, fan-in, integration, cleanup, or parent-completion authority.
7. AC7: Hook and validator allowlists share one semantic MCP alias registry, accept both `mcp__drm-copilot__validate_orchestration_artifacts` and `mcp__drm_copilot__validate_orchestration_artifacts` as the same registered operation, and reject malformed identifiers, unrelated servers, and approximate or unregistered operations.
8. AC8: Consumer repositories can perform workspace-explicit handoff validation, destination topology resolution, and provider routing through the published extension authority without importing unshipped drm-copilot Python modules; unavailable authority returns the specified single blocked result before delegation.
9. AC9: `transition_prepared_orchestration` is the only preparation-gate operation permitted to materialize a destination checkpoint; ordinary shell and patch route changes remain denied, and dry-run mode performs no canonical-checkpoint or user-file mutation.
10. AC10: Materialization repeats validation, performs a read-only clean-worktree preflight, writes and validates a same-directory candidate, archives source bytes, and atomically replaces the canonical checkpoint; any failure leaves the source checkpoint intact and records no completed transition.
11. AC11: Python, TypeScript, MCP, and hook tests select the same primary failure using the ordered `HANDOFF_*` precedence. The TaskMaster fixture's unrelated `.csproj` changes produce only `HANDOFF_DIRTY_WORKTREE` after all earlier contract and authority checks pass, with the dirty paths reported and unmodified.
12. AC12: Legacy-v1 migration requires an explicit source provider and independently proven plan, lifecycle, and scheduled-parent facts. The four-field TaskMaster checkpoint cannot fabricate missing history; ambiguous migration stops before source archive or active-checkpoint change.
13. AC13: End-to-end TaskMaster issue #469 fixtures pin source and plan raw-byte hashes, prove Claude-prepared to Codex-execution-ready continuation without completed-phase replay or historical receipt fabrication, and prove the symmetric Codex-to-Claude transition.
14. AC14: Root, extension-resource, core/variant-pack, and installed-consumer parity tests prove all required runtime files ship together and the consumer flow works without drm-copilot source modules.
15. AC15: Regression tests demonstrate that issue #467 remains the sole owner of full Codex-native parallel scheduling and issue #543 remains the sole owner of the provider-specific epic-planner ready-gate defect; #614 changes neither behavior.

### From `user-story.md`

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
| S1 | Versioned envelope validates required identity and transition fields | PASS | Schema, contract, adapter, and precedence QA artifacts | Full Python and Jest suites; native artifact validators | Draft 2020-12 and semantic version cases are covered. |
| S2 | Raw-byte source identity, archive, opaque receipts, linked history | PASS | Migration, transition, #469, and acceptance evidence | Full contract and end-to-end suites | No historical receipt synthesis found. |
| S3 | Pinned plan path/hash rejects absolute, traversal, symlink, discovery, stale content | FAIL | TypeScript authority lines 44-50 and materializer-support lines 12-29 | `rg -n "realpath\|lstat\|readlink\|path.resolve"` in both modules | Lexical checks reject absolute/traversal but do not reject a real symlink escape. |
| S4 | Bidirectional adapters preserve portable and provider-specific boundaries | PASS | Provider adapter and projection QA evidence | Full Python/Jest adapter suites | Destination evidence begins with new work. |
| S5 | Exact transition resumes without completed-phase replay or fabricated receipts | PASS | Transition, history, replay, and #469 evidence | Full contract/end-to-end suites | Positive and negative transitions are covered. |
| S6 | Scheduled child bindings and parent authority remain bounded | PASS | Parallel/epic ownership and scheduler regression evidence | Targeted ownership suites plus full suites | Ordinary children do not assume parent scheduling/fan-in authority. |
| S7 | Semantic MCP aliases share registry and reject malformed operations | PASS | Registry and hook-process QA evidence | TypeScript and Pester hook/registry suites | Both supported spellings are covered. |
| S8 | Published consumer authority supports validation/topology/routing and fail-closed absence | PASS | Consumer, pack/install, and unavailable-authority evidence | Installed-consumer and extension MCP suites | Does not require source Python modules. |
| S9 | Only semantic transition materializes; shell/patch denied; dry run non-mutating | PASS | Hook gate and dry-run QA evidence | Pester/TypeScript transition suites | Preparation-gate authority remains narrow. |
| S10 | Materialization repeats validation and safely performs same-directory atomic replacement | PARTIAL | Materialization and atomicity evidence plus FR-614-001 inspection | Full materialization suites; TypeScript containment inspection | Ordinary failure/atomic cases pass, but symlinked paths can escape the real workspace/directory. |
| S11 | Ordered cross-surface `HANDOFF_*` precedence and dirty-worktree separation | PASS | Precedence matrix and TaskMaster dirty-worktree evidence | Python/Jest/MCP/hook suites | Dirty paths remain reported and unmodified. |
| S12 | Legacy migration requires explicit independently proven facts | PASS | Migration fixtures and ambiguity evidence | Python/Jest migration suites | Four-field checkpoint cannot fabricate history. |
| S13 | TaskMaster #469 bidirectional fixtures prove exact continuity | PASS | #469 end-to-end QA evidence | Targeted #469 suites plus full suites | Source/plan hashes, replay, and receipt constraints are covered. |
| S14 | Root/resource/pack/install parity and source-independent consumer operation | PASS | Publishing and installed-consumer evidence | Root/bundle/pack/install parity suites | All required runtime files are recorded synchronized. |
| S15 | #467 and #543 ownership/scope remain unchanged | PASS | Scope-boundary regression evidence | Targeted regression suites | No reviewed diff broadens either issue's ownership. |
| U1 | Provider-neutral handoff validates required identity before continuation | PASS | Same evidence as S1 | Full contract and validator suites | Verified. |
| U2 | Archive/hash/history and no historical destination receipts | PASS | Same evidence as S2 | Transition and #469 suites | Verified. |
| U3 | Adapters preserve portable semantics and independently resolve new provider evidence | PASS | Same evidence as S4 | Adapter/projection suites | Verified. |
| U4 | Exact transition continues without replay | PASS | Same evidence as S5 | Replay/transition suites | Verified. |
| U5 | Ordinary child completion preserves parent scheduler authority | PASS | Same evidence as S6 | Ownership suites | Verified. |
| U6 | Both MCP spellings map to one semantic operation | PASS | Same evidence as S7 | Registry/hook suites | Verified. |
| U7 | Consumer checkout uses published authority and fails closed when absent | PASS | Same evidence as S8 | Consumer/pack/install suites | Verified. |
| U8 | Dry run is non-mutating and materialization uses a safe same-directory candidate | PARTIAL | Dry-run/atomic evidence plus FR-614-001 | Materialization suites and code inspection | Dry-run and ordinary atomic cases pass; real symlink containment is not enforced. |
| U9 | Dirty worktree is separately reported and unmodified | PASS | Same evidence as S11 | TaskMaster dirty-worktree suites | Verified. |
| U10 | All invalid/tampered/binding/authority cases fail closed with primary code | FAIL | FR-614-001 and precedence evidence | TypeScript containment inspection and full precedence suites | Most cases pass; an invalid symlinked plan/checkpoint path can be accepted. |
| U11 | #469 reaches execution readiness without replay or receipt fabrication in both directions | PASS | Same evidence as S13 | #469 end-to-end suites | Verified. |
| U12 | Root/bundle/pack/install consumer surfaces remain synchronized | PASS | Same evidence as S14 | Publication parity suites | Verified. |
| U13 | #467 and #543 boundaries remain unchanged | PASS | Same evidence as S15 | Scope regression suites | Verified. |

## Summary

**Overall Feature Readiness:** BLOCKED

`REVIEW_STATUS: REMEDIATION_REQUIRED`

**Criteria summary:**

- **PASS:** 24 criteria
- **PARTIAL:** 2 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 2 criteria

**Top gaps preventing PASS:**

1. FR-614-001: TypeScript consumer validation and materialization do not reject symlink escape.
2. FR-614-003: the new TypeScript authority service is 87.02% covered, below 90%.

**PowerShell verdict:** **PASS.** The authoritative full MCP PoshQC run omitted `scan_folders`, passed 3,932/3,932 tests, and reported 94.763% repository line coverage (7,437/7,848). The earlier 19.00% reading came from a narrow 637-test hook-only run combined with the full 88-file denominator and is invalid as repository-wide coverage evidence.

**Recommended follow-up verification steps:**

1. Implement symlink-safe real-path containment and deterministic negative tests across validation and materialization.
2. Raise the new TypeScript authority service to at least 90% line coverage without exclusions or policy changes.
3. Re-run ordered cross-language QA, coverage, provider/ownership/#469/parity/pack/install/#467/#543 suites and validate fresh artifacts. PowerShell coverage must use only full MCP `mcp__drm_copilot__run_poshqc_test` with `scan_folders` omitted and the repository runsettings/configured `CodeCoverage.Path`; direct Pester is not acceptable coverage evidence.
4. Re-evaluate all 28 criteria and reconcile source checkboxes strictly to verified PASS.

## Acceptance Criteria Check-off

The authoritative source files currently contain 28 checked criteria. Review verification supports only 24 as PASS. Four checked items contradict the review evidence: `spec.md` AC3 and AC10, and `user-story.md` criteria 8 and 10. Per acceptance-criteria tracking rules, these must be reopened during remediation and checked again only after verified PASS.

No requirement-source checkbox was changed during this review because the assigned review ownership is limited to timestamped review/remediation artifacts. The discrepancy is explicitly carried into `remediation-inputs.2026-08-31T17-20.md` and the delegated remediation plan.

### AC Status Summary

- Source files: `spec.md` and `user-story.md`
- Total AC items: 28
- Source checkboxes currently checked: 28
- Verified PASS: 24
- Remaining for verified delivery: 4
- Items remaining: `spec.md` AC3; `spec.md` AC10; `user-story.md` criterion 8; `user-story.md` criterion 10

| Source File | Total AC | Source Checked | Verified PASS | Non-PASS requiring reopen | Notes |
|---|---:|---:|---:|---:|---|
| `spec.md` | 15 | 15 | 13 | 2 | AC3 FAIL; AC10 PARTIAL. |
| `user-story.md` | 13 | 13 | 11 | 2 | Criterion 8 PARTIAL; criterion 10 FAIL. |

The feature remains blocked until all four non-PASS criteria are remediated and the FR-614-003 coverage finding passes. FR-614-001 and FR-614-003 are the complete bounded issue #614 remediation scope. The user has authorized automated continuation through remediation, PR, and exact-head CI; merge is not authorized.
