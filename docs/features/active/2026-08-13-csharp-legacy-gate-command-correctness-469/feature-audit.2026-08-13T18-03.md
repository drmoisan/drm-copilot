# Feature Audit: csharp-legacy-gate-command-correctness (Issue #469)

- **Audit Date:** 2026-08-13
- **Auditor:** feature-review agent (Claude Code)
- **Work Mode:** full-bug (persisted marker `- Work Mode: full-bug` at `issue.md` line 12)
- **AC Source:** `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/spec.md` (sole AC source for full-bug mode; `user-story.md` correctly does not exist)

## Scope and Baseline

- **Base branch:** `main` (supplied by caller and confirmed: `git merge-base main HEAD` = `fe0413d4aca1e76b2d02d05701fba79a887d5405`, matching the PR-context resolved base `origin/main @ fe0413d4`).
- **Branch under review:** `bug/csharp-legacy-gate-command-correctness-469` at HEAD `d342c6c77e85b052a489bb7dbc881f6dca9dbe92` (reviewer-verified with `git rev-parse HEAD`; matches the PR-context head).
- **Diff range:** `fe0413d4..d342c6c7`, 40 files, +1826/-122.
- **PR-context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, both collected against the current head; not stale, no refresh required.
- **Working-tree note:** one uncommitted modification exists (`evidence/issue-updates/issue-469.2026-08-13T17-28.md`, the orchestrator's posted-comment URL update). It is outside HEAD and therefore outside the audited diff; recorded as an Advisory pre-PR commit action.
- **Scope decisions honored (owner-authored, in the AC source):** (1) stale-form absence assertions scoped to the four `csharp-legacy` variant files only — the Codex default-slot defect is pre-existing and recorded at `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`; (2) the MSBuild binlog / `CoreCompile`-count proof requirement was struck by owner decision 2026-08-13. The reviewer confirmed no binlog or `CoreCompile` assertion exists in the diff.

## Acceptance Criteria Inventory

Source: `spec.md` `## Acceptance Criteria` (AC1-AC15), each tracing one-to-one to the identically numbered criterion in `issue.md`. All fifteen were already checked `[x]` by the executor (plan P5-T2/P5-T3); this audit independently re-verifies each.

1. AC1 — Formatting gate uses `dotnet tool run csharpier format .` (apply) and `dotnet tool run csharpier check .` (verify) in every affected legacy surface.
2. AC2 — Formatting gate requires `dotnet tool restore` when not restored and `dotnet tool run` for the manifest-pinned version.
3. AC3 — Global-CSharpier fallback (`csharpier .`) removed from every affected surface.
4. AC4 — Analyzer gate documented as `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true` with the warm-worktree/CI explanation.
5. AC5 — Compiler/nullable gate documented as `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:TreatWarningsAsErrors=true` with the `/t:Rebuild` rationale.
6. AC6 — `/p:Nullable=enable` absent from every documented command (command-scoped, span predicate); `/p:TreatWarningsAsErrors=true` retained; `#nullable enable` per-file opt-in documented.
7. AC7 — Stale forms (`dotnet tool run csharpier .`, global `csharpier .`, warm-local `/t:Build` instructions) absent from every affected surface.
8. AC8 — Gate ordering, restart rule, zero-regression comparisons, evidence/reporting contract preserved unchanged.
9. AC9 — Deterministic tests prove `csharp-legacy` pack selection emits the corrected canonical destination files on both surfaces.
10. AC10 — Deterministic tests prove the required command substrings and the command-scoped nullable absence.
11. AC11 — Deterministic tests prove the stale forms of AC7 are absent from the affected surfaces.
12. AC12 — Deterministic tests prove modern-profile invariance, legacy/modern mutual exclusion, and repeated-generation determinism.
13. AC13 — Change scope limited to canonical `csharp-legacy` sources, the README legacy section, and directly related tests.
14. AC14 — Full upstream toolchain passes in one final clean sequence.
15. AC15 — README "Legacy VSTO C# (.NET Framework)" section matches the corrected sources with no stale form.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | Reviewer byte-verification: both required CSharpier subcommand strings present in all four variant files; diff hunks show them in step 1 of each file and in the README format line. Enforced by the two `*_contain_corrected_gate_commands` tests. |
| AC2 | PASS | `dotnet tool restore` and the `dotnet tool run` manifest-pinning sentence present in all four files (required-substring set includes `dotnet tool restore`; the rules/skill step-1 text carries the restore-first and pin rationale verbatim). |
| AC3 | PASS | File-scoped forbidden literal `csharpier .` absent from all four files (reviewer scan + exclude tests). The literal matches both stale forms and nothing in the corrected text; `csharpier check .` verified not to contain it as a contiguous substring. |
| AC4 | PASS | Exact analyzer command present in all four files and README (`/t:Rebuild /m`, whole-argument platform token, both analyzer properties), each followed by the `/t:Rebuild`-intentional / CI-may-retain-`/t:Build` explanation (step-2 text and the inserted explanation paragraph in the two qa-gate files). |
| AC5 | PASS | Exact compiler/nullable command present in all four files and README with the local `/t:Rebuild` rationale sentence. |
| AC6 | PASS | Reviewer ran the span predicate independently: zero inline code spans in any variant file contain both `msbuild` and `/p:Nullable=enable`; zero fenced code blocks exist, so spans are the complete command surface. `/p:TreatWarningsAsErrors=true` present in all four; `#nullable enable` per-file opt-in prose present in all four. Prohibition prose naming the property is permitted per the spec's Nullable-Literal Scoping section. Mutant probe: injecting the property into a Codex msbuild span made the exclude test fail. |
| AC7 | PASS | All three stale forms absent per the spec's forbidden-literal precision (`csharpier .`, `sln /t:Build`; the retained "CI may retain `/t:Build`" prose does not trip the command-context literal). Mutant probe: reintroducing `sln /t:Build` in the Claude rules file made the exclude test fail. |
| AC8 | PASS | Diff hunks show the four-step numbering, ordering sentence (format → lint → type-check → test), restart rule, vstest test step, "If the environment prevents..." paragraph, and Delta Requirements sections unchanged in every file; README test line unchanged. |
| AC9 | PASS | The push-down engines copy source bytes verbatim (established by existing end-to-end routing tests, including `test_selected_legacy_csharp_writes_variant_content_to_canonical_paths`); the five real-bytes contract tests therefore pin the emitted content, and the pack-selection tests pin the destination routing. Suite evidence: `evidence/regression-testing/pass-after-contract-tests.2026-08-13T17-28.md` and `push-down-suite.2026-08-13T17-28.md`; reviewer re-ran all four files, 32 passed. |
| AC10 | PASS | `LEGACY_REQUIRED_SUBSTRINGS` contains exactly the seven spec-mandated strings, asserted per file on both surfaces; the span-scoped predicate enforces the command-scoped nullable absence. Fail-before evidence records 4 failed / 0 passed pre-fix. |
| AC11 | PASS | `LEGACY_FORBIDDEN_SUBSTRINGS` contains exactly the three spec-mandated file-scoped literals, asserted per file on both surfaces, scoped to the four variant files only (no bundle- or repo-wide walk). Reviewer mutant probes confirmed both exclude tests discriminate. |
| AC12 | PASS | Modern baseline: `test_claude_modern_csharp_profile_retains_modern_gate_commands` pins the root modern files (present: `dotnet csharpier check .`, `dotnet build`; absent: `msbuild`, `/t:Rebuild`) and passed before the fix (`evidence/regression-testing/modern-invariant-baseline.2026-08-13T17-28.md`), proving it is a pin, not a fix artifact; bundle byte parity is enforced by the pre-existing payload-contract test. Mutual exclusion: pre-existing `assert_single_csharp_toolchain` tests on both surfaces (both branches already covered; none added, per spec). Determinism: the two new repeated-generation tests compare full `{relative_path: content}` maps across two destination roots with artifacts excluded and a non-empty guard. Codex-side AC12 reduces to the diff not touching default-slot files, verified under AC13. |
| AC13 | PASS | Reviewer verified the full 40-file diff list: exactly the four variant files, `README.md`, the four named test files, the feature folder, and the two potential-feature documents (lifecycle artifacts of this fix). Zero paths under `packages/mcp-server/resources/**`, `.github/**`, `.claude/**`, modern-profile subtrees (`.claude-variants` modern counterparts, `.agents/` default slots), or parallel-orchestration resources. Executor evidence: `evidence/other/scope-verification.2026-08-13T17-28.md`. |
| AC14 | PASS | Reviewer re-executed the Python sequence in one clean pass (Black check, Ruff, Pyright, Pytest all exit 0; 3781 passed; 92.30% line / 84.66% branch, zero regression). Executor Phase 4 evidence records the same plus the TypeScript verification stages (`npm run format`/`lint`/`typecheck`/`test:coverage`, all exit 0) at `evidence/qa-gates/final-*.2026-08-13T17-28.md` and `coverage-comparison.2026-08-13T17-28.md`. |
| AC15 | PASS | Reviewer read the README section (lines 352-361): format/analyze/nullable lines match the corrected Claude-surface commands with the `<solution>.sln` placeholder; no stale form (`csharpier .`, `sln /t:Build`, `/p:Platform="Any CPU"`, `/p:Nullable=enable`) appears in the section; the test line is unchanged. |

## Summary

All fifteen acceptance criteria PASS on independently re-verified evidence: reviewer-executed toolchain runs, byte-level content verification of all five production documents, an independent span-predicate execution, diff-scope verification of all 40 files, and two adversarial mutant probes proving the new exclude tests discriminate. The executor's evidence set (24 artifacts under `evidence/`) is complete, internally consistent, and numerically identical to the reviewer's re-runs.

No Blocking or Major findings. Remediation is not required. Two housekeeping items are recorded in the policy audit (`policy-audit.2026-08-13T18-03.md` Section 8): commit the uncommitted issue-update evidence edit before PR authoring, and (unrelated to this branch) relocate or delete two pre-existing untracked files under `artifacts/research/`.

**Go/no-go recommendation:** GO for PR authoring against `main`, after committing the working-tree evidence update. Use `#469` as the sole closing reference (the PR-context author-asserted list contains a malformed `#ISO-8601` token that must not be propagated).

## Acceptance Criteria Check-off

All fifteen criteria were already checked `[x]` in both `spec.md` (lines 303-317) and `issue.md` (lines 74-88) by the executor per plan tasks P5-T2 and P5-T3. This audit independently evaluated every criterion as PASS, so the existing check-off state is confirmed correct; no checkbox changes were required, and none were made by the reviewer.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
- Items remaining: none
