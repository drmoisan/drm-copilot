# Feature Audit: Codex-Native Parallel Orchestration (#467)

**Audit Date:** 2026-08-13
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Base Branch:** `main`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `8c7f389a7620834a41fe779116a1d2bab7bf0dd7`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/codex-native-parallel-orchestration-467` / `8c7f389a7620834a41fe779116a1d2bab7bf0dd7`
- **Merge base:** `fe0413d4aca1e76b2d02d05701fba79a887d5405`, timestamp `2026-08-10T19:24:17-04:00`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, SHA-256 `0CBC0FC3000E6793220B98D0CF1EED051530ADF10517EE231354024CE5A357EA`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`, SHA-256 `74943C7BE1C5522AF85E7E7ADB9362FD5A8BFDD45D35550A562228DB130B073B`
  - Feature evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/**`
  - Additional evidence: current machine-readable Python, TypeScript, PowerShell, and Bash coverage artifacts; direct full-diff inspection.
- **Feature folder used:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` explicitly declares `Work Mode: full-feature`; therefore `spec.md` and `user-story.md` are authoritative.
- **Scope note:** This audit covers all 1,408 paths in the complete feature-vs-`main` diff. Existing green executor evidence was reused where policy permits. Hosted exact-current-head criteria remain deferred until hosted evidence exists.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md` — primary full-feature specification; 22 checkbox criteria.
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md` — primary user-facing requirements; 21 checkbox criteria.

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
| S-D01 | PASS | E01-E19 mapping and canonical feature evidence | Inspect `evidence/issue-updates/issue-467.2026-08-10T20-25.md` and evidence index | All authoritative criteria are mapped. |
| S-D02 | PASS | `persona-green.txt`; `validators.txt` | Inspect planner/orchestrator profiles, prompts, skills, and 237/237 parity | Prior authority mismatch is closed. |
| S-D03-S-D12 | PASS | E03-E14 and E17-E19 receipts | Inspect differential, launcher, hook, translation, publisher, pack, destination, epic, and Claude regression evidence | Ten criteria have deterministic passing evidence. |
| S-D13 | FAIL | Policy audit findings 3-5 | Parse canonical/current coverage; run full `git diff --check`; inspect `testResults.xml` diff | Python zero-regression and full-diff hygiene do not pass. |
| S-D14 | FAIL | Policy audit findings 1-3 | Parse Python JSON, PowerShell XML/receipt, TypeScript LCOV, Bash Cobertura | PowerShell branch and six modified-owner floors fail; Python canonical no-regression fails. |
| S-D15 | UNVERIFIED | No exact-current-head hosted result exists | Defer hosted check query until the reviewed head is published | Must remain unchecked. |
| S-T01-S-T07 | PASS | Canonical named regression suites | Inspect differential, hook-process, launcher, publisher, translation, regression, and stale-CI suites | Tests cover the stated contracts. |
| U01 | PASS | `persona-green.txt`; `validators.txt` | Inspect exact authority strings and parity | Planner/orchestrator permission and source/bundle parity are coherent. |
| U02-U18 | PASS | E02-E14 and E17-E19 | Inspect canonical named feature evidence | Seventeen criteria have passing deterministic evidence. |
| U19 | FAIL | Policy audit findings 3-5 | Same coverage/diff reconciliation as S-D13 | The required clean zero-regression loop is not proven. |
| U20 | FAIL | Policy audit findings 1-3 | Same numeric reconciliation as S-D14 | Coverage contract is not fully met. |
| U21 | UNVERIFIED | No exact-current-head hosted result exists | Defer hosted check query until the reviewed head is published | Must remain unchecked. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**

- **PASS:** 37 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria
- **FAIL:** 4 criteria

**Top gaps preventing PASS:**

1. PowerShell branch coverage is unsupported/not-PASS, and six modified PowerShell owners are below 80%.
2. Python `parallel_kickoff_contract.py` regresses against the canonical feature-start baseline.
3. Full-diff whitespace validation and root `testResults.xml` do not represent a clean final state.

**Recommended follow-up verification steps:**

1. Execute the delegated atomic remediation plan while preserving the verified TypeScript, persona/parity, PowerShell attribution/new-owner, and R5 documentation closures.
2. Regenerate affected numeric evidence and run the complete ordered gates plus `git diff --check`.
3. Perform another full feature re-review, then verify hosted CI only for the exact final published head.

## Acceptance Criteria Check-off

Only checkbox tokens were changed in authoritative requirement files. S-D13, S-D14, U19, and U20 were reset from checked to unchecked because current evidence disproves them. S-D15 and U21 were already unchecked and remain deferred. All 37 locally proven criteria remain checked.

### AC Status Summary

- Source: `spec.md` and `user-story.md`
- Total AC items: 43
- Checked off (delivered): 37
- Remaining (unchecked): 6
- Items remaining: S-D13, S-D14, S-D15, U19, U20, U21

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 22 | 19 | 3 | S-D13 and S-D14 fail; S-D15 is hosted-CI deferred. |
| `user-story.md` | 21 | 18 | 3 | U19 and U20 fail; U21 is hosted-CI deferred. |

## Verdict

**REMEDIATION REQUIRED.** Four authoritative criteria fail, two hosted exact-current-head criteria remain unverified, and five Blocking review findings require correction. The branch requires delegated atomic remediation planning and a subsequent full feature review before PR completion. Hosted CI must remain unchecked until it exists for the exact final published head.
