# Feature Audit: Codex-Native Parallel Orchestration (#467)

**Audit Date:** 2026-08-14
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Base Branch:** `main`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `7f63b7323fc88fee0aadb83fa2e603b4480a8039`
**Work Mode:** `full-feature`
**Audit Type:** Second-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/codex-native-parallel-orchestration-467` / `7f63b7323fc88fee0aadb83fa2e603b4480a8039`
- **Merge base:** `768e485ddf3b48b16aa7588a72709e17568ee5f5`, timestamp `2026-08-13T18:56:27-04:00`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, SHA-256 `A64D70B67523188A733D1EDDC3B9876E418F6F90B44F6FECA8C304B88B2EDB6B`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`, SHA-256 `03D4F924827F0C2460FB92DD73BA5D8488DA02C0C11EA854285736EBADB47464`
  - Feature evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/**`
  - Review evidence: exact current diff, current machine-readable Python/PowerShell/TypeScript/Bash coverage, prior review/remediation artifacts, and minimal check-only reconciliation
- **Feature folder used:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` explicitly declares `- Work Mode: full-feature`; `spec.md` and `user-story.md` are therefore authoritative.
- **Scope note:** This audit covers all 1,574 paths in the complete feature-vs-`main` diff. Existing exact-content executor evidence was reused. No hosted exact-head check evidence is available in canonical PR context.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md` — 22 checkbox criteria.
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md` — 21 checkbox criteria.

### From `spec.md`

| ID | Criterion |
|---|---|
| S-D01 | Every acceptance criterion in `spec.md` and `user-story.md` is mapped to named automated tests or a deterministic process demonstration, with evidence retained under this feature's canonical `evidence/` subtree. |
| S-D02 | Root provenance, forced planner/orchestrator routing, planning-only behavior, committed-kickoff readiness, monotonic topology/model routing, and no-fallback receipt validation pass. |
| S-D03 | Differential Python, TypeScript/MCP, and portable Bash fixtures prove identical normalization, conflict edges, cohorts, bounded batches, mutation decisions, open/closed behavior, and drift decisions. |
| S-D04 | External launcher and resume tests prove immutable hashes, isolated `CODEX_HOME`, exact profile/model/reasoning/authority/worktree binding, bounded concurrency, ascending launch order, interrupted resume, and rejection of corrupt or mismatched status. |
| S-D05 | Integration tests prove one `origin/main` worktree, branch, and PR to `main` per item; exact-head green checks, merge, and matching worktree removal gate completion; no integration branch or fan-in PR is accepted. |
| S-D06 | Mutation, pinning, close, detach/abandon, drift quiescence, deterministic recomputation, later-started conflict handling, requeue, and authoritative resume edge cases pass in both Python and TypeScript/MCP. |
| S-D07 | Every new hook passes the actual `.codex/config.toml` registered-process matrix for allow, deny, malformed and missing stdin, poisoned Claude variables, exact stdout, exact stderr, and exact exit code. |
| S-D08 | The translation enforceability ledger accounts for every Claude mechanical gate and reports 16 PRESERVED, 2 DEGRADED with tested compensating controls, and 0 LOST. |
| S-D09 | The user-authorized `translate-claude-to-codex` `mode=apply` operation uses the corrected Codex research basis, classifies feature/evidence/other outputs, writes `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`, `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and `<FEATURE>/evidence/other/translation-snapshots/`, and records `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...` when the non-canonical destination is supplied. |
| S-D10 | Root/bundle byte parity, registration existence, full and selected pack membership, collision behavior, additive route merge, issue-462 asset allowlisting, and Python/TypeScript publisher output parity pass for every new or selected file. |
| S-D11 | A published payload-only destination validates manifests and computes cohorts and bounded batches without Python or Poetry and does not contain unrelated `.claude/` files. |
| S-D12 | Existing Codex epic and delivered Claude parallel suites pass, and a before/after byte audit reports no `.claude/` source changes. |
| S-D13 | All changed Python, TypeScript, PowerShell, and Bash surfaces pass repository formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats, and zero-regression checks in the required order. |
| S-D14 | Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-line coverage does not regress, and coverage evidence is stored under the canonical feature evidence path; QA-gate evidence uses `<FEATURE>/evidence/qa-gates/`. |
| S-D15 | All required GitHub checks pass for the current PR head SHA; stale-head results do not satisfy completion. |
| S-T01 | Differential Python/TypeScript/Bash fixtures cover normalization, conflict edges, Welsh-Powell cohort coloring, ascending bounded batching, mutation completeness and sequence, open/closed modes, pinning, abandon, and semantic drift. |
| S-T02 | Pester process tests invoke every new hook through its actual `.codex/config.toml` registration and assert native transport, allow and deny paths, missing and malformed stdin, poisoned environment handling, exact output streams, and exact exit codes. |
| S-T03 | Launcher contract tests cover immutable hashes, wrong agent/model/reasoning/authority, branch/repository/worktree mismatch, corrupt status, interrupted resume, bounded concurrency, ascending item launch order, and rejection of epic integration/fan-in state. |
| S-T04 | Publisher tests cover Python/TypeScript output equality, additive route merge, portable asset allowlisting, collision handling, complete full and selected packs, no unrelated `.claude/` publication, root/bundle byte parity, and payload-only destination execution. |
| S-T05 | Translation tests cover the corrected research basis, feature/evidence/other classification, canonical evidence paths, rejected override recording, and a ledger with no omitted or LOST mechanical gate. |
| S-T06 | Regression suites cover existing epic launch/security behavior and every delivered Claude parallel contract while a byte-level guard verifies that `.claude/` is unchanged. |
| S-T07 | Current-head CI tests reject stale check suites and retain language coverage thresholds and zero-regression requirements. |

### From `user-story.md`

| ID | Criterion |
|---|---|
| U01 | Root `parallel-plan`, `parallel-run`, and manual `parallel-orchestrate` entry resolves only its forced authorized parallel persona; ordinary and epic orchestrators are mechanically rejected as parallel roots, and no silent topology or model fallback occurs. |
| U02 | Planning cannot launch implementation, and execution requires a committed kickoff that passes deterministic ready-for-execution validation with complete item preflight and required authority, topology, and model-routing receipts. |
| U03 | Identical normalized inputs produce identical conflict edges, Welsh-Powell cohorts, and ascending item-key batches bounded by `max_concurrency` across Python, TypeScript/MCP, and the published portable Bash runtime. |
| U04 | Each item launches in a distinct verified worktree created from `origin/main` with sealed exact-profile, model, reasoning, authority, repository, branch, worktree, launch-hash, and child-status receipts before the child can mutate files. |
| U05 | Each item owns exactly one branch and one PR targeting `main`; current-head green checks, merge, and matching worktree removal gate terminal completion, while integration branches and fan-in PRs are rejected. |
| U06 | Both cohort enforcement layers reject premature admission, including any conflicting later-cohort start before all required predecessors have both merged and removed their worktrees; green CI alone is insufficient. |
| U07 | Drift detection compares observed pre-review files with the declaration, persists a blocking event, quiesces new scheduling, recomputes the unstarted graph deterministically, halts only later-started conflicts, and requeues affected work; Python and MCP accept and reject the same drift fixtures. |
| U08 | Add, remove, close, detach, and abandon operations enforce complete ordered mutation records, unique sequence numbers, pinned in-flight items, rejection of merged removal, exact destructive confirmation, and open/closed completion semantics; Python and MCP accept and reject the same mutation fixtures. |
| U09 | Resume rejects corrupt, stale, incomplete, or mismatched Git, GitHub, PR-head, worktree, launch, child-status, mutation, drift, topology, model-routing, authority, or completion state before any new scheduling. |
| U10 | Every new Codex hook is registered in `.codex/config.toml` and passes actual-registration process tests for allow, deny, malformed and missing stdin, poisoned `CLAUDE_TOOL_INPUT`, poisoned `CLAUDE_SESSION_ID`, exact stdout, exact stderr, and exact exit code. |
| U11 | Native hook behavior is consistent: allow exits 0 with empty streams, deny exits 0 with one native JSON deny envelope and empty stderr, and malformed or missing stdin exits 2 with empty stdout and a deterministic stderr diagnostic. |
| U12 | Every Claude mechanical gate is recorded in the translation enforceability ledger as PRESERVED or DEGRADED with a tested mechanical compensating control; the final ledger contains 16 PRESERVED, 2 tested DEGRADED, 0 LOST, and no omitted gate. |
| U13 | Translation uses `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md` as the corrected Codex basis and does not treat the absent artifacts research path as authoritative. |
| U14 | The user-authorized `translate-claude-to-codex` `mode=apply` operation classifies every output as feature, evidence, or other and writes its evidence exactly to `<FEATURE>/evidence/other/translation-plan.<yyyy-MM-ddTHH-mm>.md`, `<FEATURE>/evidence/other/translation-diff.<yyyy-MM-ddTHH-mm>.md`, and `<FEATURE>/evidence/other/translation-snapshots/`; a request for `artifacts/translation/**` is redirected and recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`. |
| U15 | Existing epic and Claude parallel suites remain green, the surface-neutral launcher retains epic public behavior through thin adapters, and a byte-level check reports no `.claude/` source changes. |
| U16 | Every new Codex root file has a byte-identical bundle counterpart, every registered path exists, and full and selected packs include the complete dependency closure or a justified exclusion. |
| U17 | Python and TypeScript publishers emit equal payloads, merge destination routing additively, preserve destination-owned routes, apply identical collision rules, deliver `config/blast-radius.json`, and select only the fixed issue-462 portable assets rather than unrelated `.claude/` content. |
| U18 | A published payload-only destination validates manifests and computes deterministic cohorts and bounded batches without Python or Poetry, using the issue-462 portability assets and additive destination configuration. |
| U19 | Formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats, differential parity, root/bundle parity, pack, registration, destination, and zero-regression gates pass in one clean toolchain loop. |
| U20 | Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-line coverage does not regress, and baseline, QA-gate, regression, and coverage evidence is stored under the active feature's canonical `evidence/` subtree; QA-gate evidence uses `<FEATURE>/evidence/qa-gates/`. |
| U21 | All required GitHub checks pass for the exact current PR head SHA; results from an earlier head do not satisfy merge or completion. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| S-D01 | PASS | Acceptance mapping and canonical evidence index | Inspect requirement sources and feature evidence | All 43 criteria remain mapped. |
| S-D02 | PASS | Dedicated persona and readiness receipts | Inspect routing profiles, skills, and validators | Forced root authority and no-fallback behavior pass. |
| S-D03 | PASS | Differential Python/TypeScript/Bash receipts | Inspect parity fixtures | Normalization, graph, cohort, and batch parity pass. |
| S-D04 | PASS | Launcher and resume suites | Inspect immutable launch/resume receipts | Isolation and sealed identity checks pass. |
| S-D05 | PASS | Completion and worktree-removal tests | Inspect completion gate receipts | One PR to `main`, merge, and removal constraints pass. |
| S-D06 | PASS | Mutation/drift/resume tests | Inspect Python and MCP differential fixtures | State edge cases pass. |
| S-D07 | PASS | Registered-process Pester matrix | Inspect hook registration receipts | Native transport matrix passes. |
| S-D08 | PASS | Translation enforceability ledger | Inspect ledger counts | 16 PRESERVED, 2 tested DEGRADED, 0 LOST. |
| S-D09 | PASS | Translation plan/diff/snapshots | Inspect canonical paths and override receipt | Authorized apply-mode evidence is canonical. |
| S-D10 | PASS | Publisher, pack, parity, and collision receipts | Inspect Python/TypeScript publisher evidence | Distribution contracts pass. |
| S-D11 | PASS | Payload-only Bats validation | Inspect payload-only receipt | Runtime works without Python/Poetry. |
| S-D12 | PASS | Epic/Claude regression and byte-invariance receipts | `git diff --name-only 768e485d...HEAD -- .claude` | No `.claude/**` feature delta. |
| S-D13 | FAIL | Policy audit findings 2 and 3 | `git diff --check 768e485d...HEAD`; inspect Python line 495 | Full required clean loop is not satisfied. |
| S-D14 | FAIL | Policy audit finding 1 | Parse PowerShell XML counters | PowerShell branch denominator is absent. |
| S-D15 | UNVERIFIED | Canonical PR context reports CI status unavailable | Inspect `artifacts/pr_context.summary.txt` | Must remain unchecked. |
| S-T01 | PASS | Differential fixture receipts | Inspect named suites | Covered. |
| S-T02 | PASS | Registered hook process receipts | Inspect Pester matrix | Covered. |
| S-T03 | PASS | Launcher contract receipts | Inspect Pester/Python suites | Covered. |
| S-T04 | PASS | Publisher and payload receipts | Inspect pack/parity suites | Covered. |
| S-T05 | PASS | Translation tests and ledger | Inspect translation evidence | Covered. |
| S-T06 | PASS | Epic and Claude regression receipts | Inspect regression suites and byte guard | Covered. |
| S-T07 | PASS | Stale-current-head rejection tests | Inspect CI gate tests | The implementation test exists even though hosted execution remains unverified. |
| U01 | PASS | Dedicated persona and routing evidence | Inspect profiles, prompts, and validators | No-fallback authority passes. |
| U02 | PASS | Kickoff readiness and preflight tests | Inspect kickoff validator evidence | Planning/run boundary passes. |
| U03 | PASS | Cross-runtime differential fixtures | Inspect Python/MCP/Bash receipts | Deterministic parity passes. |
| U04 | PASS | Worktree launcher receipts | Inspect sealed launch tests | Binding passes. |
| U05 | PASS | Per-item completion tests | Inspect main-targeting and removal tests | Completion constraints pass. |
| U06 | PASS | Cohort barrier tests | Inspect dual-layer admission receipts | Premature admission is rejected. |
| U07 | PASS | Drift fixtures | Inspect Python/MCP parity | Drift behavior passes. |
| U08 | PASS | Mutation fixtures | Inspect add/remove/close/abandon receipts | Mutation behavior passes. |
| U09 | PASS | Resume reconciliation fixtures | Inspect stale/corrupt state tests | Resume fails closed. |
| U10 | PASS | Registered hook matrix | Inspect `.codex/config.toml` process tests | Covered. |
| U11 | PASS | Native stream/exit assertions | Inspect hook-process evidence | Transport contract passes. |
| U12 | PASS | Enforceability ledger | Inspect 16/2/0 count | No LOST gate. |
| U13 | PASS | Corrected research-basis tests | Inspect translation receipts | Correct source is enforced. |
| U14 | PASS | Apply-mode translation evidence | Inspect canonical paths and override marker | Covered. |
| U15 | PASS | Epic/Claude regression and byte checks | Inspect final invariance receipts | Preserved. |
| U16 | PASS | Root/bundle and registration receipts | Inspect 237/237 parity | Preserved. |
| U17 | PASS | Publisher parity/additive merge tests | Inspect customization validators | Covered. |
| U18 | PASS | Payload-only validation | Inspect 12/12 Bats receipt | Covered. |
| U19 | FAIL | Policy audit findings 2 and 3 | Current diff-check and comment inspection | Clean zero-regression loop is not proven. |
| U20 | FAIL | Policy audit finding 1 | Current coverage reconciliation | PowerShell branch coverage is non-PASS. |
| U21 | UNVERIFIED | No hosted exact-head result in canonical context | Inspect PR-context CI section | Must remain unchecked. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**

- **PASS:** 37 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria
- **FAIL:** 4 criteria

**Top gaps preventing PASS:**

1. PowerShell branch coverage remains unsupported/non-PASS with zero source-attributable branch counters.
2. The exact current feature diff has three whitespace diagnostics.
3. The latest Python coverage test omits the mandatory intent comment above its loop.

**Recommended follow-up verification steps:**

1. Execute the delegated atomic remediation plan while preserving all closed owner-coverage, parity, root-report, and invariance findings.
2. Refresh PR context after the remediation commit and perform another complete feature-vs-`main` review.
3. Verify hosted CI only for the exact published head and keep hosted criteria unchecked until that evidence exists.

## Acceptance Criteria Check-off

No authoritative source checkbox was changed during this review. All 37 criteria evaluated PASS were already checked. S-D13, S-D14, U19, and U20 remain unchecked because current evidence fails them. S-D15 and U21 remain unchecked because exact-current-head hosted CI is unverified.

### AC Status Summary

- Source: `spec.md` and `user-story.md`
- Total AC items: 43
- Checked off (delivered): 37
- Remaining (unchecked): 6
- Items remaining:
  - All changed language surfaces pass the full ordered and zero-regression gate (S-D13).
  - Repository line/branch, new-owner, changed-line, and canonical-evidence coverage requirements pass (S-D14).
  - Required GitHub checks pass for the current head (S-D15).
  - All formatting, linting, typing, tests, parity, registration, destination, and zero-regression gates pass in one clean loop (U19).
  - Repository line/branch, new-owner, changed-line, and canonical-evidence coverage requirements pass (U20).
  - Required GitHub checks pass for the exact current head (U21).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 22 | 19 | 3 | S-D13 and S-D14 fail; S-D15 is unverified. |
| `user-story.md` | 21 | 18 | 3 | U19 and U20 fail; U21 is unverified. |

## Verdict

**REMEDIATION REQUIRED.** Four authoritative criteria fail, two exact-head hosted-CI criteria remain unverified, and three review findings require correction. The feature must retain all verified second-remediation closures, complete delegated remediation planning, and undergo another full review before PR readiness can be recommended.
