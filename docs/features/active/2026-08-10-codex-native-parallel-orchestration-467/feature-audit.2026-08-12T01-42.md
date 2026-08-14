# Feature Audit: Codex-Native Parallel Orchestration (#467)

**Audit Date:** 2026-08-12
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Base Branch:** `main`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `35323f412f752467f3d787326399218d9564c8b2`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/codex-native-parallel-orchestration-467` / `35323f412f752467f3d787326399218d9564c8b2`
- **Merge base:** `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, SHA-256 `BD5507E711CE13F29783A3C4F4D82B540E0276ED06E7B0C3AEEACB6BE7EE2B0A`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`, SHA-256 `B891FFE8528ABFFC909E2926DA69370DDB683F157E015F9A9234C5FD4A4C13E0`
  - Feature evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/**`
  - Additional evidence: machine-readable Python, TypeScript, PowerShell, and Bash coverage artifacts identified in the policy audit.
- **Feature folder used:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` explicitly declares `Work Mode: full-feature`; therefore `spec.md` and `user-story.md` are authoritative.
- **Scope note:** The audit covers the complete 1,038-path `main...HEAD` diff. The existing 58-row issue/spec/user-story mapping was reconciled, but this audit's authoritative count is the 43 criteria in `spec.md` and `user-story.md`.

---

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

---

## Acceptance Criteria Evaluation

| ID | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| S-D01 | PASS | E01-E19 mapping in `evidence/issue-updates/issue-467.2026-08-10T20-25.md` | Inspect mapping and canonical receipts | All 43 authoritative criteria have named evidence. |
| S-D02 | FAIL | Persona TOML/profile/skill comparison | `rg -n "orchestrator-workspace\|parallel-(planner\|orchestrator)-workspace" .codex/agents .agents/skills` | Prompt bodies contradict dedicated authority configuration. |
| S-D03-S-D12 | PASS | E03-E14, E17-E19 | Canonical regression/parity/transport/publisher receipts | Each of these ten criteria has passing deterministic evidence. |
| S-D13 | FAIL | Policy audit sections 1.2.1 and 2.5 | Parse current Python JSON, TypeScript LCOV, and PowerShell XML | Required zero-regression loop is not green. |
| S-D14 | FAIL | Machine-readable coverage evidence | Same coverage reconciliation | New-file, modified-file, and source-denominator rules fail. |
| S-D15 | UNVERIFIED | No hosted PR-head result exists | Hosted check query deferred until PR exists | Required exact-current-head criterion remains unchecked by instruction. |
| S-T01-S-T07 | PASS | E03-E18 | Canonical named regression suites | Tests cover the stated contract, including stale-head rejection behavior. |
| U01 | FAIL | Persona TOML/profile/skill comparison | Same authority grep as S-D02 | Forced persona authority is internally contradictory. |
| U02-U18 | PASS | E02-E14, E17-E19 | Canonical named feature evidence | Seventeen criteria have passing deterministic evidence. |
| U19 | FAIL | Policy audit sections 1.2.1 and 2.5 | Parse current coverage artifacts | Coverage/zero-regression gates do not pass in one clean loop. |
| U20 | FAIL | Machine-readable coverage evidence | Same coverage reconciliation | Numeric per-file and attribution requirements fail. |
| U21 | UNVERIFIED | No hosted PR-head result exists | Hosted check query deferred until PR exists | Required exact-current-head criterion remains unchecked by instruction. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**

- **PASS:** 35 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria
- **FAIL:** 6 criteria

**Top gaps preventing PASS:**

1. Python, TypeScript, and PowerShell do not satisfy mandatory per-file/source coverage rules.
2. The forced parallel persona prompt bodies specify the wrong sandbox authority.
3. Added Python source violates mandatory documentation/comment rules; this policy failure also requires remediation even though it is not a separately worded acceptance criterion.

**Recommended follow-up verification steps:**

1. Execute the delegated atomic remediation plan and regenerate fresh machine-readable coverage artifacts for the exact remediated head.
2. Re-run the four-language ordered QA loops, parity/transport/publisher tests, root/bundle checks, and a full post-remediation feature review.
3. After the reviewed branch is pushed and a PR exists, verify the exact-current-head hosted CI criteria in `issue.md`, `spec.md`, and `user-story.md`.

---

## Acceptance Criteria Check-off

The reviewer changed only checkbox tokens in the authoritative sources. The three disproven criteria in each source were reset to unchecked. All previously passing criteria remain checked. The two hosted-current-head criteria were already unchecked and remain deferred. The analogous issue-level hosted criterion also remains unchecked, producing the required total of three deferred hosted criteria across the reconciled requirement set.

### AC Status Summary

- Source: `spec.md` and `user-story.md`
- Total authoritative AC items: 43
- Checked off (delivered): 35
- Remaining (unchecked): 8
- Items remaining: S-D02, S-D13, S-D14, S-D15, U01, U19, U20, U21

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 22 | 18 | 4 | S-D02, S-D13, and S-D14 fail; S-D15 is hosted-CI deferred. |
| `user-story.md` | 21 | 17 | 4 | U01, U19, and U20 fail; U21 is hosted-CI deferred. |

---

## Verdict

**REMEDIATION REQUIRED.** Six authoritative criteria fail and five material review findings require correction. The two hosted-current-head authoritative criteria, plus the matching issue-level criterion, remain unchecked and deferred until hosted CI exists; their deferred state is not treated as a local remediation finding. The branch requires atomic remediation planning and a full post-remediation review before it is ready for PR completion.
