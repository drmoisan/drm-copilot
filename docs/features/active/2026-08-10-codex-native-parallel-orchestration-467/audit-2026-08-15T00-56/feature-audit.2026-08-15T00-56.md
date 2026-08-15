# Feature Audit: Codex-Native Parallel Orchestration (#467)

**Audit Date:** 2026-08-15<br>
**Review Timestamp:** 2026-08-15T00-56<br>
**Feature Folder:** docs/features/active/2026-08-10-codex-native-parallel-orchestration-467<br>
**Base Branch:** main<br>
**Head Branch:** feature/codex-native-parallel-orchestration-467 at e693a2a32d1c5a936f8a95494900c840139a9b55<br>
**Work Mode:** full-feature<br>
**Audit Type:** Additional remediation cycle 1 acceptance verification

---

## Scope and Baseline

- **Base branch:** main at 768e485ddf3b48b16aa7588a72709e17568ee5f5.
- **Head branch/commit:** feature/codex-native-parallel-orchestration-467 at e693a2a32d1c5a936f8a95494900c840139a9b55.
- **Merge base:** 768e485ddf3b48b16aa7588a72709e17568ee5f5, timestamp 2026-08-13T18:56:27-04:00.
- **Primary evidence:** artifacts/pr_context.summary.txt, SHA-256 8BD213C3796A8F8136AEEF386EF96459DA0C4F14BD40A74CC9E2D6DAF1586EF7.
- **Secondary baseline diff:** artifacts/pr_context.appendix.txt, SHA-256 54E58599CBD9A7B52F16AE1BD50B2B2CB98C84432974B2430AD061901F3B84C8.
- **Feature evidence:** docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/**.
- **Feature folder used:** docs/features/active/2026-08-10-codex-native-parallel-orchestration-467.
- **Requirements source:** spec.md and user-story.md.
- **Requirements hashes:** spec.md 2F6F96B9DFAD126D0052EF6DBE98B67322A74F6B2BECE034D2E855D68F50B849; user-story.md 4FC607A52466B1B894CDE0D3BEDD2819039FD4475F63E826E418E69C89B30E32.
- **Work mode resolution note:** issue.md line 10 explicitly declares Work Mode: full-feature; spec.md and user-story.md are authoritative.
- **Scope note:** The audit covers all 1,725 committed paths in the feature-vs-main comparison. Existing post-commit orchestration-only working-tree files are excluded from the committed implementation verdict and were preserved unchanged.
- **Hosted CI note:** Canonical PR context reports CI status unavailable. The exact head is unpublished, so hosted-check criteria remain UNVERIFIED.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- spec.md — 22 checkbox criteria.
- user-story.md — 21 checkbox criteria.

### From spec.md

| ID | Criterion |
|---|---|
| S-D01 | Every acceptance criterion in spec.md and user-story.md is mapped to named automated tests or a deterministic process demonstration, with evidence retained under this feature's canonical evidence/ subtree. |
| S-D02 | Root provenance, forced planner/orchestrator routing, planning-only behavior, committed-kickoff readiness, monotonic topology/model routing, and no-fallback receipt validation pass. |
| S-D03 | Differential Python, TypeScript/MCP, and portable Bash fixtures prove identical normalization, conflict edges, cohorts, bounded batches, mutation decisions, open/closed behavior, and drift decisions. |
| S-D04 | External launcher and resume tests prove immutable hashes, isolated CODEX_HOME, exact profile/model/reasoning/authority/worktree binding, bounded concurrency, ascending launch order, interrupted resume, and rejection of corrupt or mismatched status. |
| S-D05 | Integration tests prove one origin/main worktree, branch, and PR to main per item; exact-head green checks, merge, and matching worktree removal gate completion; no integration branch or fan-in PR is accepted. |
| S-D06 | Mutation, pinning, close, detach/abandon, drift quiescence, deterministic recomputation, later-started conflict handling, requeue, and authoritative resume edge cases pass in both Python and TypeScript/MCP. |
| S-D07 | Every new hook passes the actual .codex/config.toml registered-process matrix for allow, deny, malformed and missing stdin, poisoned Claude variables, exact stdout, exact stderr, and exact exit code. |
| S-D08 | The translation enforceability ledger accounts for every Claude mechanical gate and reports 16 PRESERVED, 2 DEGRADED with tested compensating controls, and 0 LOST. |
| S-D09 | The user-authorized translate-claude-to-codex mode=apply operation uses the corrected Codex research basis, classifies feature/evidence/other outputs, writes the canonical translation plan, diff, and snapshots under the feature evidence subtree, and records the rejected non-canonical override. |
| S-D10 | Root/bundle byte parity, registration existence, full and selected pack membership, collision behavior, additive route merge, issue-462 asset allowlisting, and Python/TypeScript publisher output parity pass for every new or selected file. |
| S-D11 | A published payload-only destination validates manifests and computes cohorts and bounded batches without Python or Poetry and does not contain unrelated .claude files. |
| S-D12 | Existing Codex epic and delivered Claude parallel suites pass, and a before/after byte audit reports no .claude source changes. |
| S-D13 | All changed Python, TypeScript, PowerShell, and Bash surfaces pass repository formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats, and zero-regression checks in the required order. |
| S-D14 | Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-line coverage does not regress, and coverage evidence is stored under the canonical feature evidence path; QA-gate evidence uses the feature evidence/qa-gates/ path. |
| S-D15 | All required GitHub checks pass for the current PR head SHA; stale-head results do not satisfy completion. |
| S-T01 | Differential Python/TypeScript/Bash fixtures cover normalization, conflict edges, Welsh-Powell cohort coloring, ascending bounded batching, mutation completeness and sequence, open/closed modes, pinning, abandon, and semantic drift. |
| S-T02 | Pester process tests invoke every new hook through its actual .codex/config.toml registration and assert native transport, allow and deny paths, missing and malformed stdin, poisoned environment handling, exact output streams, and exact exit codes. |
| S-T03 | Launcher contract tests cover immutable hashes, wrong agent/model/reasoning/authority, branch/repository/worktree mismatch, corrupt status, interrupted resume, bounded concurrency, ascending item launch order, and rejection of epic integration/fan-in state. |
| S-T04 | Publisher tests cover Python/TypeScript output equality, additive route merge, portable asset allowlisting, collision handling, complete full and selected packs, no unrelated .claude publication, root/bundle byte parity, and payload-only destination execution. |
| S-T05 | Translation tests cover the corrected research basis, feature/evidence/other classification, canonical evidence paths, rejected override recording, and a ledger with no omitted or LOST mechanical gate. |
| S-T06 | Regression suites cover existing epic launch/security behavior and every delivered Claude parallel contract while a byte-level guard verifies that .claude is unchanged. |
| S-T07 | Current-head CI tests reject stale check suites and retain language coverage thresholds and zero-regression requirements. |

### From user-story.md

| ID | Criterion |
|---|---|
| U01 | Root parallel-plan, parallel-run, and manual parallel-orchestrate entry resolves only its forced authorized parallel persona; ordinary and epic orchestrators are mechanically rejected as parallel roots, and no silent topology or model fallback occurs. |
| U02 | Planning cannot launch implementation, and execution requires a committed kickoff that passes deterministic ready-for-execution validation with complete item preflight and required authority, topology, and model-routing receipts. |
| U03 | Identical normalized inputs produce identical conflict edges, Welsh-Powell cohorts, and ascending item-key batches bounded by max_concurrency across Python, TypeScript/MCP, and the published portable Bash runtime. |
| U04 | Each item launches in a distinct verified worktree created from origin/main with sealed exact-profile, model, reasoning, authority, repository, branch, worktree, launch-hash, and child-status receipts before the child can mutate files. |
| U05 | Each item owns exactly one branch and one PR targeting main; current-head green checks, merge, and matching worktree removal gate terminal completion, while integration branches and fan-in PRs are rejected. |
| U06 | Both cohort enforcement layers reject premature admission, including any conflicting later-cohort start before all required predecessors have both merged and removed their worktrees; green CI alone is insufficient. |
| U07 | Drift detection compares observed pre-review files with the declaration, persists a blocking event, quiesces new scheduling, recomputes the unstarted graph deterministically, halts only later-started conflicts, and requeues affected work; Python and MCP accept and reject the same drift fixtures. |
| U08 | Add, remove, close, detach, and abandon operations enforce complete ordered mutation records, unique sequence numbers, pinned in-flight items, rejection of merged removal, exact destructive confirmation, and open/closed completion semantics; Python and MCP accept and reject the same mutation fixtures. |
| U09 | Resume rejects corrupt, stale, incomplete, or mismatched Git, GitHub, PR-head, worktree, launch, child-status, mutation, drift, topology, model-routing, authority, or completion state before any new scheduling. |
| U10 | Every new Codex hook is registered in .codex/config.toml and passes actual-registration process tests for allow, deny, malformed and missing stdin, poisoned CLAUDE_TOOL_INPUT, poisoned CLAUDE_SESSION_ID, exact stdout, exact stderr, and exact exit code. |
| U11 | Native hook behavior is consistent: allow exits 0 with empty streams, deny exits 0 with one native JSON deny envelope and empty stderr, and malformed or missing stdin exits 2 with empty stdout and a deterministic stderr diagnostic. |
| U12 | Every Claude mechanical gate is recorded in the translation enforceability ledger as PRESERVED or DEGRADED with a tested mechanical compensating control; the final ledger contains 16 PRESERVED, 2 tested DEGRADED, 0 LOST, and no omitted gate. |
| U13 | Translation uses docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md as the corrected Codex basis and does not treat the absent artifacts research path as authoritative. |
| U14 | The user-authorized translate-claude-to-codex mode=apply operation classifies every output as feature, evidence, or other, writes canonical translation evidence under the feature evidence/other path, and records redirection of the non-canonical artifacts/translation request. |
| U15 | Existing epic and Claude parallel suites remain green, the surface-neutral launcher retains epic public behavior through thin adapters, and a byte-level check reports no .claude source changes. |
| U16 | Every new Codex root file has a byte-identical bundle counterpart, every registered path exists, and full and selected packs include the complete dependency closure or a justified exclusion. |
| U17 | Python and TypeScript publishers emit equal payloads, merge destination routing additively, preserve destination-owned routes, apply identical collision rules, deliver config/blast-radius.json, and select only the fixed issue-462 portable assets rather than unrelated .claude content. |
| U18 | A published payload-only destination validates manifests and computes deterministic cohorts and bounded batches without Python or Poetry, using the issue-462 portability assets and additive destination configuration. |
| U19 | Formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats, differential parity, root/bundle parity, pack, registration, destination, and zero-regression gates pass in one clean toolchain loop. |
| U20 | Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-line coverage does not regress, and baseline, QA-gate, regression, and coverage evidence is stored under the active feature's canonical evidence subtree. |
| U21 | All required GitHub checks pass for the exact current PR head SHA; results from an earlier head do not satisfy merge or completion. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| S-D01 | PASS | evidence/issue-updates/cycle1-acceptance-criteria.2026-08-14T09-36.md | Enumerate all checkboxes in spec.md and user-story.md | All 43 criteria are mapped and retained. |
| S-D02 | PASS | Routing, readiness, and preservation receipts | Inspect profiles, skills, kickoff validators, and cycle1-orchestration-preservation | Forced authority and no-fallback behavior pass. |
| S-D03 | PASS | Cross-runtime parity receipts | Run/inspect Python, TypeScript, and Bats differential suites | Normalization, graph, cohort, batch, mutation, and drift parity pass. |
| S-D04 | PASS | Launcher and resume receipts | Inspect immutable launch/resume suites | Isolation and sealed identity checks pass. |
| S-D05 | PASS | Completion and worktree-removal tests | Inspect completion-state and removal-gate receipts | One PR to main and terminal constraints pass. |
| S-D06 | PASS | Mutation, drift, and resume tests | Inspect Python/MCP parity fixtures | State edge cases pass. |
| S-D07 | PASS | Registered-process Pester matrix | Inspect actual .codex/config.toml hook process receipts | Native transport matrix passes. |
| S-D08 | PASS | Translation enforceability ledger | Inspect ledger counts | 16 PRESERVED, 2 tested DEGRADED, 0 LOST. |
| S-D09 | PASS | Translation plan/diff/snapshots | Inspect canonical paths and override marker | Authorized apply evidence remains canonical. |
| S-D10 | PASS | Publisher, pack, parity, and collision receipts | Inspect Python/TypeScript publisher groups and root/bundle parity | Distribution contracts pass. |
| S-D11 | PASS | Payload-only Bats evidence | Inspect payload-only destination receipt | Runtime works without Python or Poetry. |
| S-D12 | PASS | Epic/Claude regression and byte-invariance evidence | git diff --name-only 768e485d..e693a2a3 -- .claude | No .claude feature delta; preservation groups pass. |
| S-D13 | PASS | Ordered cycle-1 language gates and exact diff check | Inspect cycle1 Python, PowerShell, TypeScript, Bash, preservation, and final-diff receipts | Prior whitespace and comment defects are closed; source is checked. |
| S-D14 | FAIL | PowerShell coverage reconciliation and branch-capability decision | Parse PowerShell XML counters and inspect owner receipt | Lines and owners pass; genuine branch counters=0 and denominator=0. |
| S-D15 | UNVERIFIED | Canonical PR context CI section | Inspect artifacts/pr_context.summary.txt | Head is unpublished; no hosted exact-head result exists. |
| S-T01 | PASS | Differential fixture receipts | Inspect named Python/MCP/Bats suites | Covered. |
| S-T02 | PASS | Registered hook process receipts | Inspect Pester actual-registration matrix | Covered. |
| S-T03 | PASS | Launcher contract receipts | Inspect Pester/Python launch and resume suites | Covered. |
| S-T04 | PASS | Publisher and payload receipts | Inspect pack, parity, collision, and destination suites | Covered. |
| S-T05 | PASS | Translation tests and ledger | Inspect canonical translation evidence | Covered. |
| S-T06 | PASS | Epic and Claude regression receipts | Inspect cycle1-orchestration-preservation and byte guard | Covered. |
| S-T07 | PASS | Stale-head rejection tests | Inspect CI gate unit tests | Implementation test exists; hosted current-head execution is separately UNVERIFIED. |
| U01 | PASS | Dedicated persona and routing evidence | Inspect profiles, prompts, and validators | No-fallback authority passes. |
| U02 | PASS | Kickoff readiness and preflight tests | Inspect kickoff validator evidence | Planning/execution boundary passes. |
| U03 | PASS | Cross-runtime differential fixtures | Inspect Python/MCP/Bash receipts | Deterministic parity passes. |
| U04 | PASS | Worktree launcher receipts | Inspect sealed launch tests | Binding passes. |
| U05 | PASS | Per-item completion tests | Inspect main-target and removal tests | Completion constraints pass. |
| U06 | PASS | Cohort barrier tests | Inspect dual-layer admission receipts | Premature admission is rejected. |
| U07 | PASS | Drift fixtures | Inspect Python/MCP parity | Drift behavior passes. |
| U08 | PASS | Mutation fixtures | Inspect add/remove/close/detach/abandon receipts | Mutation behavior passes. |
| U09 | PASS | Resume reconciliation fixtures | Inspect stale/corrupt-state tests | Resume fails closed. |
| U10 | PASS | Registered hook matrix | Inspect .codex/config.toml process tests | Covered. |
| U11 | PASS | Native stream and exit assertions | Inspect hook-process evidence | Transport contract passes. |
| U12 | PASS | Enforceability ledger | Inspect 16/2/0 ledger count | No LOST gate. |
| U13 | PASS | Corrected research-basis tests | Inspect translation receipts | Correct source is enforced. |
| U14 | PASS | Apply-mode translation evidence | Inspect canonical paths and override marker | Covered. |
| U15 | PASS | Epic/Claude regression and byte checks | Inspect cycle1 preservation and .claude invariance | Preserved. |
| U16 | PASS | Root/bundle and registration receipts | Inspect 237/237 parity | Preserved. |
| U17 | PASS | Publisher parity and additive merge tests | Inspect customization publisher validators | Covered. |
| U18 | PASS | Payload-only validation | Inspect Bats destination evidence | Covered. |
| U19 | PASS | Ordered cycle-1 QA and preservation receipts | Inspect full four-language gates, parity, registration, destination, and final hygiene | Prior clean-loop defects are closed. |
| U20 | FAIL | PowerShell coverage and policy reconciliation | Parse coverage counters and inspect owner matrix | Genuine branch counters=0; denominator=0. |
| U21 | UNVERIFIED | No hosted exact-head result in canonical context | Inspect PR-context CI section | Must remain unchecked. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**

- **PASS:** 39 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria
- **FAIL:** 2 criteria

**Top gaps preventing PASS:**

1. S-D14 and U20 fail because PowerShell supplies no genuine source-attributable branch denominator. GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO.
2. S-D15 and U21 are unverified because hosted checks have not run for unpublished exact head e693a2a32d1c5a936f8a95494900c840139a9b55.

**Recommended follow-up verification steps:**

1. Keep the PowerShell branch-policy result FAIL and retain POWERSHELL_BRANCH_POLICY_UNRESOLVED unless separately authorized future work produces genuine branch evidence.
2. After any authorized follow-up commit and publication, refresh canonical PR context and verify hosted checks only for that exact head.

## Acceptance Criteria Check-off

No authoritative requirement source was edited during this review. All 39 PASS criteria were already checked before R5. S-D14 and U20 remain unchecked and FAIL. S-D15 and U21 remain unchecked and UNVERIFIED.

### AC Status Summary

- Source: spec.md and user-story.md.
- Total AC items: 43.
- Checked off (delivered): 39.
- Remaining (unchecked): 4.
- Items remaining:
  - S-D14 — repository and owner coverage requirements, including PowerShell branch coverage.
  - S-D15 — exact-current-head required GitHub checks.
  - U20 — repository and owner coverage requirements, including PowerShell branch coverage.
  - U21 — exact-current-head required GitHub checks.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| spec.md | 22 | 20 | 2 | S-D14 FAIL; S-D15 UNVERIFIED. |
| user-story.md | 21 | 19 | 2 | U20 FAIL; U21 UNVERIFIED. |

## Verdict

**REMEDIATION REQUIRED.** Thirty-nine criteria pass, two fail, and two remain unverified. The feature is not ready for PR completion while PowerShell branch coverage has zero genuine counters and denominator 0. Hosted exact-head checks must remain unverified until the head is published and checked.

REVIEW_STATUS: REMEDIATION_REQUIRED
