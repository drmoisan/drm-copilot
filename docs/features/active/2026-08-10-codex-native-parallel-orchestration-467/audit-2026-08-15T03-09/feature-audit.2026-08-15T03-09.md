# Feature Audit: Codex-Native Parallel Orchestration (#467)

**Audit Date:** 2026-08-15<br>
**Review Timestamp:** 2026-08-15T03-09<br>
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`<br>
**Base Branch:** `main`<br>
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `2d44e14f48706bb317ee8b81d23b2b2f7cee1c5d`<br>
**Work Mode:** `full-feature`<br>
**Audit Type:** Final authorized remediation-cycle-2 acceptance re-review

## Scope and Baseline

- **Base branch:** `main` at `768e485ddf3b48b16aa7588a72709e17568ee5f5`.
- **Head branch/commit:** `feature/codex-native-parallel-orchestration-467` at `2d44e14f48706bb317ee8b81d23b2b2f7cee1c5d`.
- **Merge base:** `768e485ddf3b48b16aa7588a72709e17568ee5f5`, timestamp 2026-08-13T18:56:27-04:00.
- **Primary evidence:** `artifacts/pr_context.summary.txt`, SHA-256 `C9728A9A536ED0C87D13610440EC04B73450AAB09BBDA391B77B2EF59449EB86`.
- **Secondary baseline diff:** `artifacts/pr_context.appendix.txt`, SHA-256 `7AFFF5088C330E43E3E032980A06A4AE251B92CA22CB596E793F79EE5B7C150A`.
- **Feature evidence:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/**`.
- **Requirements source:** `spec.md` and `user-story.md`.
- **Requirements hashes:** `spec.md` `2F6F96B9DFAD126D0052EF6DBE98B67322A74F6B2BECE034D2E855D68F50B849`; `user-story.md` `4FC607A52466B1B894CDE0D3BEDD2819039FD4475F63E826E418E69C89B30E32`.
- **Original plan:** `plan.2026-08-10T20-25.md`, SHA-256 `1307CDB6B5641C6B29642E43162F17B8567382573C19386EC4F2F85075BCD28D`; 114/114 atomic tasks are checked. Checklist completion does not override a fail-closed policy result.
- **Work mode resolution:** `issue.md` line 10 declares `Work Mode: full-feature`; `spec.md` and `user-story.md` are authoritative.
- **Scope note:** The audit covers all 1,782 committed paths. Commit `2d44e14f` adds only 58 review/remediation/evidence paths after prior reviewed executable boundary `e693a2a3`; no executable, test, policy, dependency, configuration, or threshold input changed.
- **Hosted CI note:** Canonical PR context reports CI status unavailable. Exact-head hosted-check criteria remain UNVERIFIED.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- `spec.md` — 22 checkbox criteria.
- `user-story.md` — 21 checkbox criteria.

### From spec.md

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
| S-D09 | The authorized `translate-claude-to-codex mode=apply` operation uses the corrected research basis, classifies feature/evidence/other outputs, writes canonical translation evidence, and records the rejected non-canonical override. |
| S-D10 | Root/bundle byte parity, registration existence, full and selected pack membership, collision behavior, additive route merge, issue-462 asset allowlisting, and Python/TypeScript publisher output parity pass for every new or selected file. |
| S-D11 | A published payload-only destination validates manifests and computes cohorts and bounded batches without Python or Poetry and does not contain unrelated `.claude` files. |
| S-D12 | Existing Codex epic and delivered Claude parallel suites pass, and a before/after byte audit reports no `.claude` source changes. |
| S-D13 | All changed Python, TypeScript, PowerShell, and Bash surfaces pass repository formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats, and zero-regression checks in the required order. |
| S-D14 | Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-line coverage does not regress, and coverage evidence is stored under the canonical feature evidence path. |
| S-D15 | All required GitHub checks pass for the current PR head SHA; stale-head results do not satisfy completion. |
| S-T01 | Differential Python/TypeScript/Bash fixtures cover normalization, conflict edges, Welsh-Powell cohort coloring, ascending bounded batching, mutation completeness and sequence, open/closed modes, pinning, abandon, and semantic drift. |
| S-T02 | Pester process tests invoke every new hook through its actual `.codex/config.toml` registration and assert native transport, allow and deny paths, missing and malformed stdin, poisoned environment handling, exact output streams, and exact exit codes. |
| S-T03 | Launcher contract tests cover immutable hashes, wrong agent/model/reasoning/authority, branch/repository/worktree mismatch, corrupt status, interrupted resume, bounded concurrency, ascending item launch order, and rejection of epic integration/fan-in state. |
| S-T04 | Publisher tests cover Python/TypeScript output equality, additive route merge, portable asset allowlisting, collision handling, complete full and selected packs, no unrelated `.claude` publication, root/bundle byte parity, and payload-only destination execution. |
| S-T05 | Translation tests cover the corrected research basis, feature/evidence/other classification, canonical evidence paths, rejected override recording, and a ledger with no omitted or LOST mechanical gate. |
| S-T06 | Regression suites cover existing epic launch/security behavior and every delivered Claude parallel contract while a byte-level guard verifies that `.claude` is unchanged. |
| S-T07 | Current-head CI tests reject stale check suites and retain language coverage thresholds and zero-regression requirements. |

### From user-story.md

| ID | Criterion |
|---|---|
| U01 | Root `parallel-plan`, `parallel-run`, and manual `parallel-orchestrate` entry resolves only its forced authorized parallel persona; ordinary and epic orchestrators are mechanically rejected as parallel roots, and no silent topology or model fallback occurs. |
| U02 | Planning cannot launch implementation, and execution requires a committed kickoff that passes deterministic ready-for-execution validation with complete item preflight and required authority, topology, and model-routing receipts. |
| U03 | Identical normalized inputs produce identical conflict edges, Welsh-Powell cohorts, and ascending item-key batches bounded by `max_concurrency` across Python, TypeScript/MCP, and the published portable Bash runtime. |
| U04 | Each item launches in a distinct verified worktree created from `origin/main` with sealed exact-profile, model, reasoning, authority, repository, branch, worktree, launch-hash, and child-status receipts before mutation. |
| U05 | Each item owns exactly one branch and one PR targeting `main`; current-head green checks, merge, and matching worktree removal gate terminal completion, while integration branches and fan-in PRs are rejected. |
| U06 | Both cohort enforcement layers reject premature admission, including any conflicting later-cohort start before all required predecessors have both merged and removed their worktrees; green CI alone is insufficient. |
| U07 | Drift detection compares observed pre-review files with the declaration, persists a blocking event, quiesces scheduling, recomputes the unstarted graph deterministically, halts only later-started conflicts, and requeues affected work; Python and MCP accept and reject the same fixtures. |
| U08 | Add, remove, close, detach, and abandon operations enforce complete ordered mutation records, unique sequence numbers, pinned in-flight items, rejection of merged removal, exact destructive confirmation, and open/closed completion semantics; Python and MCP accept and reject the same fixtures. |
| U09 | Resume rejects corrupt, stale, incomplete, or mismatched Git, GitHub, PR-head, worktree, launch, child-status, mutation, drift, topology, model-routing, authority, or completion state before scheduling. |
| U10 | Every new Codex hook is registered in `.codex/config.toml` and passes actual-registration process tests for allow, deny, malformed and missing stdin, poisoned `CLAUDE_TOOL_INPUT`, poisoned `CLAUDE_SESSION_ID`, exact stdout, exact stderr, and exact exit code. |
| U11 | Native hook behavior is consistent: allow exits 0 with empty streams, deny exits 0 with one native JSON deny envelope and empty stderr, and malformed or missing stdin exits 2 with empty stdout and deterministic stderr. |
| U12 | Every Claude mechanical gate is recorded as PRESERVED or DEGRADED with a tested compensating control; the final ledger contains 16 PRESERVED, 2 tested DEGRADED, 0 LOST, and no omitted gate. |
| U13 | Translation uses `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md` and does not treat the absent artifacts research path as authoritative. |
| U14 | The authorized translation classifies every output as feature, evidence, or other, writes canonical translation evidence under the feature `evidence/other` path, and records redirection of the non-canonical request. |
| U15 | Existing epic and Claude parallel suites remain green, the surface-neutral launcher retains epic behavior through thin adapters, and a byte-level check reports no `.claude/` source changes. |
| U16 | Every new Codex root file has a byte-identical bundle counterpart, every registered path exists, and full and selected packs include complete dependency closure or a justified exclusion. |
| U17 | Python and TypeScript publishers emit equal payloads, merge routing additively, preserve destination-owned routes, apply identical collision rules, deliver `config/blast-radius.json`, and select only fixed issue-462 portable assets. |
| U18 | A published payload-only destination validates manifests and computes deterministic cohorts and bounded batches without Python or Poetry, using issue-462 assets and additive configuration. |
| U19 | Formatting, linting, type checking where applicable, unit and integration tests, Pester, Bats, differential parity, root/bundle parity, pack, registration, destination, and zero-regression gates pass in one clean toolchain loop. |
| U20 | Repository-wide line coverage remains at least 85 percent, repository-wide branch coverage remains at least 75 percent, each new module/class/method targets at least 90 percent, changed-line coverage does not regress, and evidence is stored under the active feature's canonical subtree. |
| U21 | All required GitHub checks pass for the exact current PR head SHA; earlier-head results do not satisfy completion. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| S-D01 | PASS | AC mirrors, original plan, and grouped evidence | Enumerate all 43 authoritative checkboxes and 114 plan tasks | Complete mapping retained. |
| S-D02 | PASS | Routing/readiness receipts | Inspect forced profiles, skills, and validators | No fallback accepted. |
| S-D03 | PASS | Cross-runtime parity receipts | Inspect Python, TypeScript, and Bats differential suites | Deterministic parity passes. |
| S-D04 | PASS | Launcher/resume receipts | Inspect immutable launch and resume suites | Isolation and binding pass. |
| S-D05 | PASS | Completion/removal suites | Inspect per-item completion receipts | Main-only terminal constraints pass. |
| S-D06 | PASS | Mutation/drift/resume suites | Inspect Python/MCP fixtures | State edge cases pass. |
| S-D07 | PASS | Registered-process Pester matrix | Inspect actual-registration receipts | Native transport matrix passes. |
| S-D08 | PASS | Enforceability ledger | Inspect ledger counts | 16/2/0, no omitted gate. |
| S-D09 | PASS | Translation plan/diff/snapshots | Inspect canonical paths and override marker | Authorized apply evidence is canonical. |
| S-D10 | PASS | Publisher, pack, parity receipts | Inspect root/bundle and publisher groups | Distribution contracts pass. |
| S-D11 | PASS | Payload-only Bats evidence | Inspect payload destination receipt | Runs without Python/Poetry. |
| S-D12 | PASS | Regression and invariance evidence | `git diff --name-only 768e485d..2d44e14f -- .claude/**` | Empty feature delta. |
| S-D13 | PASS | Ordered language gates | Inspect cycle-2 comparison and reuse/fresh receipts | All applicable toolchain gates pass. |
| S-D14 | FAIL | PowerShell coverage reconciliation | Parse report-level coverage XML counters | Lines pass; genuine branch counter count and denominator are 0. |
| S-D15 | UNVERIFIED | Canonical PR-context CI section | Inspect `artifacts/pr_context.summary.txt` | Exact-head hosted result unavailable. |
| S-T01 | PASS | Differential fixture receipts | Inspect named Python/MCP/Bats suites | Covered. |
| S-T02 | PASS | Registered hook receipts | Inspect Pester process matrix | Covered. |
| S-T03 | PASS | Launcher contract receipts | Inspect launch/resume suites | Covered. |
| S-T04 | PASS | Publisher/payload receipts | Inspect parity/collision/destination suites | Covered. |
| S-T05 | PASS | Translation tests/ledger | Inspect canonical translation evidence | Covered. |
| S-T06 | PASS | Regression/invariance receipts | Inspect cycle-2 preservation evidence | Covered. |
| S-T07 | PASS | Stale-head rejection tests | Inspect CI gate unit tests | Implementation exists; hosted execution is separate. |
| U01 | PASS | Dedicated persona/routing evidence | Inspect profiles, prompts, validators | Authority passes. |
| U02 | PASS | Kickoff readiness/preflight tests | Inspect kickoff evidence | Boundary passes. |
| U03 | PASS | Cross-runtime fixtures | Inspect Python/MCP/Bash receipts | Deterministic parity passes. |
| U04 | PASS | Worktree launcher receipts | Inspect sealed launch tests | Binding passes. |
| U05 | PASS | Per-item completion tests | Inspect main-target/removal tests | Constraints pass. |
| U06 | PASS | Cohort barrier tests | Inspect dual-layer receipts | Premature admission rejected. |
| U07 | PASS | Drift fixtures | Inspect Python/MCP parity | Drift behavior passes. |
| U08 | PASS | Mutation fixtures | Inspect mutation receipts | Mutation behavior passes. |
| U09 | PASS | Resume fixtures | Inspect stale/corrupt-state tests | Resume fails closed. |
| U10 | PASS | Registered hook matrix | Inspect config-resolved process tests | Covered. |
| U11 | PASS | Native stream/exit assertions | Inspect hook-process evidence | Transport contract passes. |
| U12 | PASS | Enforceability ledger | Inspect 16/2/0 counts | No LOST gate. |
| U13 | PASS | Corrected-basis tests | Inspect translation receipts | Correct source enforced. |
| U14 | PASS | Apply-mode evidence | Inspect paths/override marker | Covered. |
| U15 | PASS | Regression/byte checks | Inspect Claude invariance | Preserved. |
| U16 | PASS | Root/bundle/registration receipts | Inspect 237/237 parity | Preserved. |
| U17 | PASS | Publisher parity/merge tests | Inspect publisher validators | Covered. |
| U18 | PASS | Payload-only validation | Inspect Bats evidence | Covered. |
| U19 | PASS | Ordered QA/preservation receipts | Inspect final comparison | Applicable gates pass. |
| U20 | FAIL | PowerShell coverage/policy evidence | Parse coverage counters and owner matrix | Genuine branch counter count and denominator are 0. |
| U21 | UNVERIFIED | Canonical PR-context CI section | Inspect `artifacts/pr_context.summary.txt` | Exact-head hosted result unavailable. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**

- **PASS:** 39 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria
- **FAIL:** 2 criteria

**Top gaps preventing PASS:**

1. S-D14 and U20 fail because PowerShell supplies no genuine source-attributable branch denominator. `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`.
2. S-D15 and U21 remain unverified because hosted checks have not run for exact head `2d44e14f48706bb317ee8b81d23b2b2f7cee1c5d`.

**Recommended follow-up verification steps:**

1. Retain `POWERSHELL_BRANCH_POLICY_UNRESOLVED` and the FAIL verdict unless separately authorized future work produces genuine branch evidence without policy weakening, threshold changes, waivers, new dependencies, or proxy relabeling.
2. Verify hosted checks only after publication and only for the exact resulting head.

## Acceptance Criteria Check-off

No authoritative requirement source was edited during this review. All 39 PASS criteria were already checked. S-D14 and U20 remain unchecked and FAIL. S-D15 and U21 remain unchecked and UNVERIFIED.

### AC Status Summary

- Source: `spec.md` and `user-story.md`.
- Total AC items: 43.
- Checked off (delivered): 39.
- Remaining (unchecked): 4.
- Items remaining: S-D14, S-D15, U20, and U21.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 22 | 20 | 2 | S-D14 FAIL; S-D15 UNVERIFIED. |
| `user-story.md` | 21 | 19 | 2 | U20 FAIL; U21 UNVERIFIED. |

## Verdict

**REMEDIATION REQUIRED.** Thirty-nine criteria pass, two fail, and two remain unverified. The feature is not ready for PR completion while PowerShell branch coverage has zero genuine counters and denominator zero. Hosted checks must remain unverified until the exact head is published and checked.

REVIEW_STATUS: REMEDIATION_REQUIRED
