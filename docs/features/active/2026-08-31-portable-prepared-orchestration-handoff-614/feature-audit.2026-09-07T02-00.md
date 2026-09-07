# Feature Audit: Portable Prepared Orchestration Handoff (Issue #614)

**Audit Timestamp:** 2026-09-07T02-00
**Reviewer:** feature-review
**Companion artifacts:** `policy-audit.2026-09-07T02-00.md`, `code-review.2026-09-07T02-00.md`

---

## Scope and Baseline

**Feature folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614` (single-version feature; no `v1/`, `v2/` sub-scope exists, so the feature root is the review scope)

**Work mode:** `full-feature`, read from the persisted `- Work Mode: full-feature` marker in `issue.md`. Acceptance-criteria sources are therefore `spec.md` and `user-story.md`, tracked independently.

**Base branch:** `main`, resolved to `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Merge base:** `1ed0964045febbb4d92f1cb92661d4b945153a40`, merge-base commit timestamp 2026-09-02T19:09:17-05:00
**Head:** `feature/portable-prepared-orchestration-handoff-614 @ 0decbdbbf6dcdea1231cf6eb3715835b369883ad`
**Audit range:** `1ed0964045febbb4d92f1cb92661d4b945153a40..0decbdbbf6dcdea1231cf6eb3715835b369883ad`

**Evidence sources:**

- `artifacts/pr_context.summary.txt` (primary), generated 2026-09-07 05:48:23 UTC at head `0decbdbb`
- `artifacts/pr_context.appendix.txt` (baseline diff appendix), same generation
- `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`
- The feature's canonical evidence tree under `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/{baseline,remediation-baseline,regression-testing,qa-gates,other}/`
- Direct source and fixture inspection at head, plus a full check-only toolchain sweep run by this reviewer

**Change surface:** 275 files changed, 29,039 insertions, 518 deletions across 9 commits. Production surface is 21 TypeScript `src/**` modules, 5 Python `scripts/dev_tools/**` modules, 2 PowerShell hook files, 4 JSON contract and registry files, and 8 committed fixtures.

**Scope invariant:** the audit is feature-vs-base over the full branch diff. No caller narrowing was applied; see the `## Rejected Scope Narrowing` section of `policy-audit.2026-09-07T02-00.md` for the two phrases evaluated and why neither constitutes narrowing.

---

## Acceptance Criteria Inventory

| Source | Section | Items | Currently checked at head |
|---|---|---|---|
| `spec.md` | `## Acceptance Criteria` (lines 329-380) | 15 (AC1-AC15) | 15 |
| `user-story.md` | `## Acceptance Criteria` (lines 86-127) | 13 (US1-US13) | 13 |
| **Total** | | **28** | **28** |

The `## Definition of Done` and `## Seeded Test Conditions (from potential)` sections of `spec.md` also contain checkbox items. Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, the named-section counter begins after the `Acceptance Criteria` heading and ends at the next equal-or-shallower heading, so those 12 items are not acceptance criteria and are not counted or checked off here. They are addressed narratively in the Summary.

`user-story.md` acceptance criteria are unlabelled bullets. They are assigned the stable identifiers US1-US13 in document order for this audit only; no identifier was written into the source file.

---

## Acceptance Criteria Evaluation

### `spec.md`

| ID | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| AC1 | Draft 2020-12, semantically versioned envelope validates identity, bindings, phases, transition, complexity, capabilities, and plan path/hash before continuation | PASS | `config/orchestration-handoff.schema.json` declares `$schema: https://json-schema.org/draft/2020-12/schema` and `$id: .../orchestration-handoff/2.0.0/schema.json`. `orchestration_handoff_contract.py` dataclasses validate every named field in `__post_init__`; `orchestration-handoff-contract.ts` performs the parallel parse at 98.79% line and 90.79% branch coverage. `tests/scripts/dev_tools/test_orchestration_handoff_schema.py` (8 cases) and `extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts` exercise the envelope surface. |
| AC2 | Raw-byte SHA-256 source identity, content-digest archive before replacement, opaque prior receipts, monotonic digest-linked history | PASS | `SOURCE_ARCHIVE_PREFIX = "artifacts/orchestration/handoffs/sources/sha256/"` with the archive path derived from `checkpoint_sha256` (`orchestration_handoff_contract.py` lines 57 and 236). `validate_history_chain` (line 466) enforces monotonic `sequence` and `previous_entry_sha256` linkage and recomputes `history_entry_digest`. `validate_source_bytes` (line 486) rejects a source whose raw digest differs and rejects an incomplete receipt set. Receipt references are compared by digest only and never rewritten. The materializer archives before replacing (`stageMaterialization`), and both the archive-exists-matching and archive-exists-differing branches are now tested. |
| AC3 | Plan validation accepts only the pinned normalized repository-relative path and raw-byte hash; rejects absolute paths, `..`, symlink escape, directory rediscovery, stale content | PASS | `normalize_repository_relative_path` rejects backslashes, POSIX and Windows absolute paths, empty segments, `.`, `..`, and any value differing from its own normalization. `orchestration-handoff-path-boundary.test.ts` covers root-prefix collision after canonical resolution, non-normal separators, in-root link acceptance only after canonical target resolution, and rejection of existing and creatable reparse targets outside the root. Python covers directory rediscovery (`test_plan_directory_rediscovery_blocks_before_write`), shared traversal (`test_shared_traversal_fixture_blocks_before_write`), and stale hash (`test_stale_plan_hash_blocks_before_write`). Note: the Python helper `resolve_pinned_plan_path` is not on the enforcement path and its success branch is untested; see finding F2 in the code review. The criterion is satisfied by the enforcing runtimes. |
| AC4 | Bidirectional adapters carry portable semantics while provider-specific evidence stays in the expression that produced it | PASS | `orchestration_handoff_adapters.py` at 100.00% line and 100.00% branch after the R1 remediation; `orchestration-handoff-provider-adapters.ts` at 99.27% line and 95.65% branch. `_validate_projection_facts` rejects plan, lifecycle, scheduler-context, digest-shape, and history-linkage divergence, each asserted by a dedicated test at `test_orchestration_handoff_adapters.py` line 101. `test_orchestration_handoff_taskmaster_469.py` line 237 asserts `projection.destination_evidence == ProviderExecutionEvidence()`, proving no source-side provider evidence crosses into the destination expression. |
| AC5 | Destination projection resumes the exact recorded transition and rejects replay of every completed phase; destination receipts begin only with the first new delegation | PASS | `test_orchestration_handoff_versions.py::test_completed_phase_replay_has_deterministic_code` and `test_invalid_transition_has_deterministic_code`. `test_orchestration_handoff_taskmaster_469.py` line 102 asserts `projection.checkpoint["next_step"] == envelope.lifecycle.next_transition`, and line 237 asserts the destination evidence container starts empty. |
| AC6 | Parallel and epic child handoffs validate their bindings; an ordinary child returns a bounded result without assuming scheduler authority | PASS | `validate_return_to_scheduler` (`orchestration_handoff_contract.py` line 369) requires `run_id`, `item_id`, `parent_checkpoint_path`, `parent_checkpoint_sha256`, `plan_sha256`, `child_checkpoint_sha256`, and `result_sha256`. `SchedulerContext.__post_init__` requires `kickoff_or_manifest_sha256` and `parent_checkpoint_sha256` for child contexts (line 281). The registry declares `scheduler-context:ordinary`, `scheduler-context:parallel-child`, `scheduler-context:epic-child`, and `scheduler-return:portable_child_result-v1` as distinct capabilities. Exercised at `test_orchestration_handoff_taskmaster_469.py` lines 200-213. |
| AC7 | Hook and validator allowlists share one semantic MCP alias registry, accept both transport spellings, reject malformed and unregistered identifiers | PASS | `src/lib/validate/semantic-mcp-identity.ts` at 100.00% line and 100.00% branch, driven by the `tests/fixtures/orchestration-handoff/contract/semantic-mcp-alias-cases.json` fixture. `.codex/hooks/enforce-epic-planning-only.ps1` replaced its hardcoded allowlist with `Get-EpicPlanningRegisteredMcpTool`, which reads `config/orchestration-handoff-registry.json` and validates each transport alias against `^mcp__(?:drm-copilot|drm_copilot)__<operation>$`, rejecting an unregistered id, a mismatched `operation` field, and a malformed alias. |
| AC8 | Consumer repositories perform workspace-explicit validation, topology resolution, and routing through published authority without importing unshipped source modules; unavailable authority returns one blocked result before delegation | PASS | `orchestration-handoff-authority-service.ts` at 98.41% line and 88.41% branch, with blocked-result assertions at `orchestration-handoff-authority-service.test.ts` lines 373, 394, and 457. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_consumer_uses_published_typescript_handoff_authority` and `::test_handoff_runtime_has_bundle_pack_and_effective_install_parity` prove the consumer path resolves through the published extension rather than repository Python. |
| AC9 | `transition_prepared_orchestration` is the only preparation-gate operation permitted to materialize; shell and patch route changes stay denied; dry run mutates nothing | PASS | `$script:PreparationSemanticMcpIds` (`.codex/hooks/enforce-epic-planning-only.ps1` lines 21-26) lists four operations, of which three are read-only resolvers or validators and only `drm-copilot.transition_prepared_orchestration` materializes. The hook's deny path for non-registered MCP tools, shell commands, and patch payloads is exercised by `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` (24 blocks) and `legacy-codex-hook-contracts.Tests.ps1` (34 blocks). `orchestration-handoff-materializer.test.ts` line 17, "returns a deterministic dry-run projection without mutation", asserts no write seam is invoked in dry-run mode. |
| AC10 | Materialization repeats validation, performs a read-only clean-worktree preflight, writes and validates a same-directory candidate, archives source bytes, atomically replaces; any failure leaves the source intact and records no completed transition | PASS | The criterion was PARTIAL at the 2026-09-06T23-30 cycle because five staging-recovery branches were untested. Remediation item R3 landed at commit `0decbdbb`: seven new cases now cover the pre-existing archive that cannot be re-read, the pre-existing candidate with a differing digest, the pre-existing candidate already holding the projection bytes, re-validation rejection, candidate re-read failure, candidate removal failure, and atomic-replace failure. Each asserts the returned `primaryFailureCode`, the reported `affectedPaths`, and that `status` is never `materialized`. The adjacent recovery-contract correction landed as well: the `replaceFile` failure path now calls `discardCandidate` and reports `preparation.candidatePath`, matching the re-validation failure path. Module coverage rose from 94.14% to 98.42% line and 94.87% branch. |
| AC11 | Python, TypeScript, MCP, and hook tests select the same primary failure using the ordered `HANDOFF_*` precedence; unrelated `.csproj` changes produce only `HANDOFF_DIRTY_WORKTREE` after all earlier checks pass, with paths reported and unmodified | PASS | `config/orchestration-handoff-registry.json` carries the 16-entry ordered `failure_precedence`. TypeScript asserted parity at `orchestration-handoff-contract.test.ts` line 267 before this cycle; Python is now bound to the same array by `test_orchestration_handoff_contract.py` line 105 (remediation item R2, landed at `0decbdbb`). `test_orchestration_handoff_taskmaster_469.py` lines 370-405 construct 16 unrelated `.csproj` paths and assert `HANDOFF_DIRTY_WORKTREE` is selected. `orchestration-handoff-materializer.test.ts` lines 157-164 drive a porcelain payload with modified, untracked, and renamed `.csproj` entries and assert the reported `affectedPaths` list contains all four names with no write seam invoked. |
| AC12 | Legacy-v1 migration requires an explicit source provider and independently proven plan, lifecycle, and scheduled-parent facts; ambiguous migration stops before archive or checkpoint change | PASS | `read_legacy_v1` (`orchestration_handoff_contract_support.py` lines 65-83) rejects a payload that already carries `schema_version`, requires `source_provider` to be exactly `claude` or `codex`, and requires all three of plan, lifecycle, and scheduler facts. `test_orchestration_handoff_versions.py::test_legacy_v1_accepts_only_explicit_migration_facts` covers the acceptance and rejection surface. The already-migrated guard at line 77 remains uncovered (carried-forward item R7c); the guard's behavior is unchanged and the criterion's substance is proven by the other branches. |
| AC13 | TaskMaster #469 fixtures pin source and plan raw-byte hashes, prove Claude-to-Codex continuation without replay or receipt fabrication, and prove the symmetric Codex-to-Claude transition | PASS | This reviewer recomputed all four pinned digests from the on-disk bytes at head. `claude-to-codex`: `source_checkpoint.sha256 = 558de827d94b8f51fc135227a7f70a0933807e2c558f7c0f40a8bff1181e0fdd` and `plan.sha256 = 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`. `codex-to-claude`: `source_checkpoint.sha256 = ed0724168078356d789d503e629e5de0a2e2ac099ac2aba8bd5ca60299404669` and the same plan digest. Every declared value matches its file. The `.gitattributes` entries disabling EOL normalization for the two fixture plan files are present, so the digests are stable across checkouts. `test_orchestration_handoff_taskmaster_469.py` (10 cases) exercises both directions. |
| AC14 | Root, extension-resource, core/variant-pack, and installed-consumer parity tests prove all runtime files ship together and the consumer flow works without source modules | PASS | SHA-256 parity confirmed by this reviewer: `config/orchestration-handoff.schema.json` and `config/orchestration-handoff-registry.json` are byte-identical to their `extensions/drm-copilot/resources/config/` copies. Both are listed in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lines 98-99. `test_push_down_claude_resource_contracts.py` (14 cases) and `test_push_down_codex_and_agents_customizations.py` (9 cases) cover bundle, pack, and effective-install parity; both suites pass. |
| AC15 | Regression tests demonstrate that #467 remains the owner of Codex-native parallel scheduling and #543 remains the owner of the epic-planner ready-gate defect; #614 changes neither | PASS | The branch diff contains no `parallel-*` skill or agent file and no change to `scripts/dev_tools/validate_epic_planner_state.py`. The only change to `.codex/hooks/enforce-epic-planning-only.ps1` replaces the hardcoded MCP allowlist with a registry-derived semantic allowlist (57 insertions, 12 deletions); the removed lines are the four hardcoded tool names and the two `mcp__*` branch blocks they fed. The ready-gate logic is untouched. The four Codex-hook Pester suites (92 `It` blocks total) pass with 0 failures. |

### `user-story.md`

| ID | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| US1 | A versioned provider-neutral handoff validates every binding and the exact plan path/hash before a destination may continue | PASS | Same evidence as spec AC1 and AC3. |
| US2 | Archives original source bytes by raw SHA-256, preserves source receipts as opaque, appends digest-linked history, never synthesizes destination receipts for source work | PASS | Same evidence as spec AC2 and AC5. |
| US3 | Adapters preserve complexity, route, lifecycle, plan, and ownership while each destination independently resolves its own model, profile, topology, and launch evidence for new work only | PASS | Same evidence as spec AC4. |
| US4 | A completed preparation state advances to its recorded execution transition without replaying promotion, research, document authoring, planning, or preflight; replay is rejected before mutation | PASS | Same evidence as spec AC5. The Python path tests are named `*_blocks_before_write` and run under a `deny_write_boundaries` fixture that fails the test if any write seam is invoked. |
| US5 | A parallel or epic child can be completed piecemeal by an ordinary destination orchestrator while the parent retains cohort, wave, barrier, fan-in, integration, cleanup, and completion authority | PASS | Same evidence as spec AC6. |
| US6 | Hook and validator allowlists resolve both supported transport spellings to the same semantic operation and reject malformed identifiers, unrelated tools, and unregistered operations | PASS | Same evidence as spec AC7. |
| US7 | A consumer repository performs workspace-explicit validation, topology resolution, and routing through published authority without importing unshipped source; missing authority produces one deterministic blocked result before delegation | PASS | Same evidence as spec AC8 and AC14. |
| US8 | Dry run changes no canonical checkpoint or user file; materialization validates a same-directory candidate and atomically replaces only after every check passes | PASS | Same evidence as spec AC9 and AC10. |
| US9 | An unrelated dirty worktree is reported separately as `HANDOFF_DIRTY_WORKTREE` after earlier validation succeeds; the result lists affected paths and does not stage, stash, reset, delete, or modify them | PASS | Same evidence as spec AC11. The materializer's dirty-worktree branch reads Git porcelain through the injected read-only `HandoffGitBoundary` and has no write capability, so the non-mutation property holds structurally as well as by assertion. |
| US10 | Unsupported versions, tampered source or history, wrong bindings, invalid or stale plan identity, scheduler mismatch, invalid transition, and absent capabilities each fail closed with the contract's deterministic primary code | PASS | Same evidence as spec AC11 and AC12, plus `test_orchestration_handoff_versions.py` cases for unknown major version, unknown vocabulary, unknown capability, and invalid transition, and `test_orchestration_handoff_paths.py::test_wrong_binding_blocks_before_write`. Note the one untested accept path recorded as finding F1; every reject path in this criterion is covered. |
| US11 | TaskMaster #469 fixtures prove Claude-prepared reaches Codex execution readiness with pinned hashes, no phase replay, and no receipt fabrication; symmetric fixtures prove the reverse | PASS | Same evidence as spec AC13. |
| US12 | Root, bundled, packed, and installed-consumer tests demonstrate schema, registry, adapters, hooks, skills, validators, and transition authority remain synchronized and usable from a consumer checkout | PASS | Same evidence as spec AC14. |
| US13 | Regression coverage confirms #467 and #543 retain their ownership and this feature changes neither behavior | PASS | Same evidence as spec AC15. |

---

## Summary

All 28 acceptance criteria across both sources evaluate to PASS. No criterion is PARTIAL, FAIL, or UNVERIFIED.

The single PARTIAL from the previous cycle, `spec.md` AC10, is resolved. Remediation item R3 landed at commit `0decbdbb` with seven new staging-recovery cases and the adjacent recovery-contract correction, raising `orchestration-handoff-materializer.ts` from 94.14% to 98.42% line coverage and covering every branch the criterion describes. The evidence record for the re-check is `evidence/other/ac10-recheck.2026-09-06T23-30.md`. The criterion is `[x]` at head and no source-file edit is required by this audit.

**Definition of Done and Seeded Test Conditions.** The 12 checkbox items under `spec.md` `## Definition of Done` (7 items) and `## Seeded Test Conditions (from potential)` (5 items) are all unchecked in the source file. They are not acceptance criteria under the work-mode contract and this audit does not check them off. On the evidence gathered, their substance is met: acceptance criteria in both sources are individually mapped above; bidirectional ordinary, parallel-child, and epic-child behavior is covered; schema, adapter, migration, validator, hook-process, extension MCP, and publishing-parity tests all exist and pass; the negative surface for unsupported versions, tampering, invalid paths, wrong bindings, and unavailable authority is covered; provider documentation is updated in both the `.claude` and `.agents` trees with byte-identical bundled copies; structured transition results and deterministic failure logging are implemented; and the required formatting, linting, type-checking, architecture, unit, contract, and integration gates all pass. The unchecked state of those boxes is a documentation-hygiene gap in `spec.md`, not a delivery gap. Because they are outside the AC contract for `full-feature` mode, this reviewer does not modify them; the orchestrator may wish to have them checked before the pull request is opened.

**Quality posture.** Zero blocking findings. All seven toolchain stages pass in a single check-only sweep with a clean working tree. All three coverage languages clear the uniform 85% line and, where the tooling measures it, 75% branch thresholds repo-wide, on changed lines, and per changed production file: TypeScript 96.88% and 90.43% repo-wide with 98.77% on changed lines; Python 92.89% and 85.51% repo-wide with 97.72% on changed lines; PowerShell 94.77% repo-wide with 87.10% on changed lines. The evidence-location validator exits 0 and the branch writes no file under a forbidden `artifacts/` evidence path. All four pinned fixture digests were recomputed at head and match.

**Open items.** Two new non-blocking findings (F1, F2) and six carried-forward items (R4, R5, R6, R7a, R7b, R7c) are enumerated in `remediation-inputs.2026-09-07T02-00.md`. None gates the pull request. F1 and F2 are Python-side gaps in a two-runtime parity contract and should be scheduled promptly.

**Recommendation: go.** The feature is ready for pull-request authoring after a rebase onto `origin/main @ 0542c92a` and a force-push with lease.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md` and `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md`
- Total AC items: 28 (15 in `spec.md`, 13 in `user-story.md`)
- Checked off (delivered): 28 (15 in `spec.md`, 13 in `user-story.md`)
- Remaining (unchecked): 0
- Items remaining: none

---

## Acceptance Criteria Check-off

No source-file edit was required by this audit. All 28 criteria were already `[x]` at head `0decbdbb`, and this audit's independent evaluation returned PASS for all 28, so every existing check mark is confirmed rather than newly applied.

| Source | ID | State before this audit | Verdict | State after this audit | Action taken |
|---|---|---|---|---|---|
| `spec.md` | AC1 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC2 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC3 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC4 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC5 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC6 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC7 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC8 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC9 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC10 | `[x]` | PASS | `[x]` | confirmed; the previous cycle's PARTIAL is resolved by remediation item R3 at `0decbdbb` |
| `spec.md` | AC11 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC12 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC13 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC14 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `spec.md` | AC15 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US1 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US2 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US3 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US4 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US5 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US6 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US7 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US8 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US9 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US10 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US11 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US12 | `[x]` | PASS | `[x]` | confirmed, no edit |
| `user-story.md` | US13 | `[x]` | PASS | `[x]` | confirmed, no edit |

Working-tree confirmation: `git status --porcelain` returned empty before and after this audit, so no acceptance-criteria source file was modified.
