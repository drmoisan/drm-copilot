# Feature Audit: Preimplementation Gate Blocks Planner Surfaces (#535)

**Audit Date:** 2026-08-23
**Feature Folder:** `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535`
**Base Branch:** `main`
**Head Branch:** `bug/preimplementation-gate-blocks-planner-surfaces-535`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge-base commit `e96e32e01662035faacec460a12441b253b6f3b2`)
- **Head branch/commit:** `bug/preimplementation-gate-blocks-planner-surfaces-535` (commit `d6aece5b8ee10f3f791491311b3d8fa5b9c82840`)
- **Merge base:** `e96e32e01662035faacec460a12441b253b6f3b2` (resolved by merge-base ancestry; supplied by the caller and confirmed against `git merge-base`-consistent PR context)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`, cross-checked with `git diff e96e32e0..HEAD`
  - Feature evidence: `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/**` (21 artifacts across baseline, regression-testing, qa-gates, other)
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` (re-parsed), reviewer-run `sha256sum` over the four hook copies, reviewer grep of the two SKILL.md kickoff lines
- **Feature folder used:** `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the sole authoritative AC source per `acceptance-criteria-tracking`.
- **Scope note:** Scope is the full branch diff against the resolved base branch (31 files: 6 PowerShell code files, 25 Markdown documents). No caller-supplied scope narrowing was attempted or accepted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/spec.md` — only source (`## Acceptance Criteria`, 14 checkbox items, all currently `[x]`)

### Acceptance criteria

1. `Test-ImplementationPath` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` exempts exactly the seven repo-relative literals `artifacts/orchestration/orchestrator-state.json`, `parallel-planner-state.json`, `parallel-orchestrator-state.json`, `epic-planner-state.json`, `epic-orchestrator-state.json`, `powershell-orchestrator-state.json`, and `csharp-orchestrator-state.json`, expressed as literals behind a single membership check over the normalized path (no directory-prefix or glob exemption, no absolute-path entries, no per-path normalization logic).
2. A `Write`/`Edit` payload for each of the seven exempt checkpoint literals is allowed with no ready checkpoint present, in both forward-slash and backslash spellings (verified through the pure decision seam).
3. A `Write` payload for a non-checkpoint `.json` under `artifacts/orchestration/` (e.g., `artifacts/orchestration/some-other-file.json`) is still denied, proving the exemption is a literal set rather than a directory prefix.
4. A `Write` payload for a checkpoint-named file outside `artifacts/orchestration/` (e.g., `scripts/parallel-planner-state.json`) is still denied, proving full-path equality.
5. The delegation classifier exempts a delegation if and only if `tool_input.subagent_type` equals exactly `orchestrator` AND the `prompt` field (field-scoped, not the serialized payload) contains both literals `Preparation mode: true.` and `route_id: preparation.`; the verbatim parallel-plan and epic-plan kickoff lines are both allowed with no checkpoint present.
6. Spoofed-marker delegations remain denied: (a) both markers present but `subagent_type` is not `orchestrator`; (b) marker text present only in a non-`prompt` field while `prompt` matches the implementation regex; (c) only one marker, or a marker missing its trailing period, with an otherwise regex-matching payload.
7. All other delegation classification is unchanged: an `Agent(orchestrator)` payload without both markers that matches the implementation regex is denied, and engineer/atomic-executor delegations are denied pre-readiness exactly as before.
8. Fail-closed semantics are preserved and demonstrated by re-running the existing suite unmodified in intent: empty payload, unparseable JSON, and flat root shape deny with payload-anomaly reasons; malformed checkpoint content for a genuine implementation operation denies; implementation writes, toolchain commands, and `git add|commit` remain denied without a ready checkpoint; ready-checkpoint allows unchanged; `Test-OrchestrationReady`, `Test-ImplementationCommand`, and the decision-JSON schema are unmodified.
9. The identical behavioral fix is present in all four hook copies: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
10. The `.codex` canonical and Codex-bundle copies are byte-identical in the same commit, and the hash-binding contract test in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes; any `.codex` decision assertions affected by the two exemptions are updated in that file per its established mechanism.
11. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` is extended in place with passing tests covering all thirteen case groups listed under Test Strategy, driven through `Invoke-OrchestrationPreimplementationGateDecision` with no disk I/O, child processes, or temporary files; the allow-case prompts are the verbatim SKILL.md kickoff lines.
12. Fail-before evidence exists: the new allow cases run against the unfixed hook produce a failing baseline recorded under `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/regression-testing/`.
13. PoshQC toolchain passes clean in a single pass (format → analyze → Pester via the MCP commands), with line coverage >= 85% on every changed production hook file.
14. No out-of-scope changes: issue #516 absolute-path normalization is not implemented, the `git add|commit` housekeeping gap and `enforce-promotion-mcp-only.ps1` are untouched, `Test-OrchestrationReady` is unchanged, and each hook copy and the extended Claude test file remain under 500 lines.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Seven-literal membership check, no prefix/glob/absolute/normalization | PASS | Diff hunk adds `$script:CheckpointPaths` with exactly the seven literals and one `-contains` check replacing the single-literal equality; readiness scalar retained; no `GetFullPath`/`Resolve-Path`/`IsPathRooted` in the diff | `git diff e96e32e0..HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Reviewer read the full hunk; set membership is exact (7 entries, all repo-relative). |
| 2 | Seven literals allowed with no ready checkpoint, both spellings | PASS | Two table-driven allow `It` blocks (forward slash and backslash) over all seven literals, each with explicit not-ready `-CheckpointRaw`; 1532/1532 pass | `mcp__drm-copilot__run_poshqc_test` (executor); reviewer diff inspection | Fail-before run shows these exact cases failing pre-fix, proving discrimination. |
| 3 | Non-checkpoint `.json` under `artifacts/orchestration/` denied | PASS | Deny `It` for `artifacts/orchestration/some-other-file.json` asserts deny + `PREIMPLEMENTATION_GATE_BLOCKED` reason | Same as above | Proves literal set, not directory prefix. |
| 4 | Checkpoint-named file outside the directory denied | PASS | Deny `It` for `scripts/parallel-planner-state.json` asserts deny + reason prefix | Same as above | Proves full-path equality. |
| 5 | Three-conjunct field-scoped exemption; verbatim kickoff lines allowed | PASS | `Test-PreparationModeDelegation` implements exactly the three conjuncts; both allow tests use the verbatim kickoff lines, which the reviewer matched character-for-character against `.claude/skills/parallel-plan/SKILL.md:105` and `.claude/skills/epic-plan/SKILL.md:99` | `grep -n "Preparation mode: true" .claude/skills/parallel-plan/SKILL.md .claude/skills/epic-plan/SKILL.md`; diff inspection | Prompt read is field-scoped via `Get-ClaudeHookToolInputString` / `Get-StringProperty`, never the serialized payload. |
| 6 | Spoofed-marker delegations denied (wrong agent; non-prompt field; one marker; missing period) | PASS | Four deny `It` blocks cover (a) `atomic-executor` with both markers, (b) markers in `description` while `prompt` matches the regex, (c) one-marker-only, (d) missing trailing period | Executor Pester runs; reviewer diff inspection | All deny cases supply explicit not-ready checkpoints (deterministic). |
| 7 | All other delegation classification unchanged | PASS | Regex path is textually unchanged in the diff; deny test for an orchestrator execution prompt without markers; pre-existing delegation denial tests re-run green | Diff inspection; `evidence/regression-testing/pass-after-claude.2026-08-23T21-52.md` | Exemption returns only "not implementation"; fall-through preserved via try/catch. |
| 8 | Fail-closed semantics preserved; named functions and schema unmodified | PASS | Pre-existing anomaly/malformed-checkpoint/implementation-denial/ready-allow contexts pass unmodified; `Test-OrchestrationReady` and `Test-ImplementationCommand` appear nowhere in the diff; `PreToolUseSchema.Contract.Tests.ps1` included in the final two-folder run (1532 pass) | `evidence/qa-gates/scope-and-size.2026-08-23T22-16.md`; `evidence/qa-gates/final-pester.2026-08-23T22-12.md`; reviewer diff grep | Deny-reason prefix and phrases retained. |
| 9 | Identical behavioral fix in all four copies | PASS | Claude pair byte-identical (SHA256 `f57fae11...`), Codex pair byte-identical (SHA256 `e8a2dfc7...`), both re-computed by the reviewer; the two canonical diffs implement the same two exemptions in their respective idioms | `sha256sum` over the four paths; `git diff` on both canonical copies | Bundle mirrors inherit behavior by byte-identity. |
| 10 | `.codex` pair byte-identical in same commit; hash-binding test passes; decision assertions updated | PASS | Both `.codex` copies land in commit `192cb484`; byte-identity `It` passes in the 43-test codex run; the added table-driven `It` is the established mechanism's update for the two exemptions | `git log --oneline e96e32e0..HEAD`; `evidence/regression-testing/pass-after-codex.2026-08-23T22-02.md` | Byte-identity `It` itself was not edited, per plan. |
| 11 | Thirteen case groups, pure seam, no disk I/O / child processes / temp files, verbatim prompts | PASS | Groups 1-10 are the 11 new Claude-suite cases; groups 11-12 are the re-run pre-existing contexts; group 13 is the codex parity leg; all driven through `Invoke-OrchestrationPreimplementationGateDecision` on constructed JSON | Reviewer diff inspection of both test files; executor Pester evidence | File extended in place (+156/-0), 461 lines. |
| 12 | Fail-before evidence exists | PASS | `evidence/regression-testing/fail-before-pester.2026-08-23T21-40.md`: exit 4 (expected 4), exactly the four new allow cases failing against the unfixed hook | Artifact inspection | Artifact also documents the determinism correction that made the cases discriminating. |
| 13 | Clean single-pass PoshQC toolchain; line coverage >= 85% on every changed production hook file | PASS | Final iteration: format clean, analyze 0 findings, 1532/1532 tests; per-file line coverage 90.00% (`.claude`) and 99.18% (`.codex`), re-parsed by the reviewer from `artifacts/pester/powershell-coverage.xml`; bundle mirrors inherit via verified byte-identity; no changed-line regression | `python` re-parse of the JaCoCo LINE counters; `evidence/qa-gates/final-poshqc-format.2026-08-23T22-06.md`, `final-poshqc-analyze.2026-08-23T22-07.md`, `final-pester.2026-08-23T22-12.md`, `coverage-delta.2026-08-23T22-14.md` | Loop iteration 1 surfaced a `.codex` changed-line gap; iteration 2 passed all stages clean in a single pass. |
| 14 | No out-of-scope changes; all six files under 500 lines | PASS | Diff surface is exactly the six code files plus feature docs; no #516 normalization; `Test-ImplementationCommand`, `Test-OrchestrationReady`, `enforce-promotion-mcp-only.ps1` untouched; reviewer-recounted line counts 339/339/336/336/461/494 | `git diff --name-status e96e32e0..HEAD`; `wc -l` over the six files | Matches `evidence/qa-gates/scope-and-size.2026-08-23T22-16.md`. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Post-merge integration retest (already recorded in spec.md Rollout & Follow-up): confirm `/parallel-plan` reaches its preparation fan-out and writes `artifacts/orchestration/parallel-planner-state.json` without a fabricated single-feature checkpoint.
2. When authoring the PR, assert autoclose for #535 only; the author-asserted candidate list currently also carries #516 (explicitly out of scope) and a malformed `#ISO-8601` token.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 14 criteria evaluate as **PASS**.
- All 14 checkboxes in `spec.md` were already checked `[x]` by the executor during plan execution (tasks P1-T3, P2-T6 through P2-T8, P3-T6, P3-T8, P3-T9, P4-T7, P4-T8), each after its verifying evidence passed. This audit independently confirms every check-off is supported by evidence; no reviewer check-off action was needed and no source-file change was made by this audit.
- No criterion remains unchecked; no phantom criteria were added.

### AC Status Summary

- Source: `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/spec.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/spec.md` | 14 | 14 | 0 | Checkbox-backed; executor-checked with per-task evidence; reviewer-confirmed |
