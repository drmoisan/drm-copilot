# Feature Audit: claude-memory-scope-and-hardening (Issue #181)

**Audit Date:** 2026-06-13
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)

## Scope and Baseline

- **Base branch:** `main`
- **Merge-base SHA:** `2745d23d01ea179d8d02fc240dbadb1017ee7aeb`
- **Branch head SHA:** `75b0ea6191b0498b9e2240f9a262457f348a57e3`
- **Diff range:** `2745d23d..75b0ea6` — 7 Python files, 49 Markdown files (scoping docs, evidence, rule mirrors, bundle memories). Zero TypeScript files.
- **PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (refreshed; consistent with the on-disk diff).
- **Toolchain (re-run during this audit):** Black PASS, Ruff PASS, project-scoped Pyright PASS (0 errors), Pytest PASS (1116 passed, 19 skipped). Changed-module line coverage 88% / 92%; repo-wide TOTAL 82% (unchanged from baseline).

The audit is a full feature-vs-base review. No caller-supplied scope narrowing was accepted (see policy audit `## Rejected Scope Narrowing`). The TypeScript toolchain is N/A because the branch diff contains zero `.ts`/`.tsx` files.

## Acceptance Criteria Inventory

Sources:
- `spec.md` `## Acceptance Criteria`: 17 items.
- `user-story.md` `## Acceptance Criteria`: 14 items.

## Acceptance Criteria Evaluation

### spec.md

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|--------------------------|---------|----------|
| 1 | Push-down copies only `scope: general` memories; repo/unmarked excluded | PASS | `_is_general_memory_file` + `list_files` filter; tests in `test_push_down_claude_memory_scope.py`. |
| 2 | Fail-safe default: absent/malformed/unrecognized => repo, excluded | PASS | `_read_memory_scope` returns `repo` on all such inputs; covered by parser tests. |
| 3 | Files outside `.claude/agent-memory/` copied verbatim | PASS | Predicate returns `True` unconditionally outside the subtree; `_is_scope_included` skips the content read; tests confirm. |
| 4 | `re`-based parser, no PyYAML | PASS | `_SCOPE_LEAF_PATTERN` regex; grep confirms no `yaml` import in any changed script. |
| 5 | Two main script copies byte-identical and both carry the filter | PASS | `git diff --no-index` root vs bundle script = identical; both contain the filter. |
| 6 | Extension template carries the filter; source-root = bundled `claude-customizations/` | PASS | Template resolves `Path(__file__).resolve().parent.parent / "claude-customizations"`; aligned with codex template. |
| 7 | Bundle agent-memory contains only general memories + orchestrator `MEMORY.md` (repo, never pushed); `feedback_policy_compliance_not_optional.md` retained as general | PASS | Bundle tree: 7 `scope: general` memories + 1 `scope: repo` `MEMORY.md`; `feedback_policy_compliance_not_optional.md` present as general. |
| 8 | Repo-specific memories physically removed and relocated; `prd-feature/` and `task-researcher/` subdirs removed from bundle | PASS | Diff shows `D` for the 5 orchestrator repo memories, `prd-feature/*`, `task-researcher/*`; subdirs absent from bundle tree. Relocation to gitignored root is asserted by spec (Option B); not visible in diff except as bundle deletions, consistent with design. |
| 9 | Six domain-neutral general memories present; index references them | PASS | Six new `scope: general` memories added; bundle `MEMORY.md` updated to reference them. |
| 10 | Resource-contract parity test exempts agent-memory and asserts general/repo scopes | PASS | `test_push_down_claude_resource_contracts.py` exempts `.claude/agent-memory/**` and asserts non-index = general, index = repo. |
| 11 | Validator enforces the three remediation-cycle invariants | PASS | `_validate_remediation_cycle` enforces non-empty `plan_path`, cleared-preflight gate, exit-vs-blocking; positive + negative tests pass. |
| 12 | Validator backward compatible (no `remediation_loop` validates unchanged) | PASS | `test_no_remediation_loop_is_backward_compatible` passes; invariants gated on key presence. |
| 13 | `orchestrator-state.md` prose rule mirrored byte-identically; notes foreign `$id` not copied | PASS | Root and bundle `orchestrator-state.md` byte-identical; rule documents the foreign `$id` constraint. |
| 14 | Type-only coverage exemption documented in 4 rule files, mirrored | PASS | Note present in `general-unit-test.md`, `python.md`, `typescript.md`, `csharp.md`; all four byte-identical root vs bundle. |
| 15 | Root coverage policy unchanged; no `coverage.md`/`diff-cover`/6-step/property downgrade | PASS | No `coverage.md` in root or bundle; no `diff-cover` in `.claude/`; tier system + 85%/75% retained. |
| 16 | Every non-memory `.claude` change mirrored byte-identically | PASS | All five changed rule files identical root vs bundle. |
| 17 | Full Python toolchain passes, no changed-line regression; TS toolchain only if TS changes | PASS | Black/Ruff/Pyright/Pytest pass; repo-wide 82% unchanged; no TS files changed. |

### user-story.md

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|--------------------------|---------|----------|
| 1 | General memory distributed | PASS | Scope filter + tests. |
| 2 | Repo memory not distributed | PASS | Scope filter + tests; Option B removal. |
| 3 | Unmarked/malformed/unrecognized => repo, not distributed | PASS | Parser fail-safe + tests. |
| 4 | Non-memory files copied verbatim | PASS | Predicate passthrough + tests. |
| 5 | Template source-root = bundled dir; carries filter | PASS | Source-root fix verified. |
| 6 | Bundle = general + orchestrator `MEMORY.md` (repo); `feedback_policy_compliance_not_optional.md` general | PASS | Bundle tree verified. |
| 7 | Repo memories removed/relocated; `prd-feature/`+`task-researcher/` removed | PASS | Diff deletions + bundle tree verified. |
| 8 | Parity test asserts non-index general, index repo | PASS | Test verified. |
| 9 | Six general memories present, referenced by index | PASS | Verified. |
| 10 | Validator rejects malformed cycle; no-`remediation_loop` unchanged | PASS | Tests pass. |
| 11 | Orchestrator-state invariants documented as mirrored prose rule | PASS | Byte-identical mirror verified. |
| 12 | Type-only exemption documented in general + 3 language rules, mirrored | PASS | Verified. |
| 13 | Root coverage policy unchanged; no rejected snapshot artifact | PASS | Verified absent. |
| 14 | Three follow-up GitHub issues opened (Decision L) | UNVERIFIED | Out-of-band orchestrator action; not in branch diff. No evidence of issue creation available to this review. Left unchecked. |

## Summary

- spec.md: 17/17 PASS.
- user-story.md: 13/14 PASS, 1 UNVERIFIED (follow-up GitHub issues — orchestrator responsibility, outside the branch diff).
- No FAIL verdicts. No code or toolchain remediation is required.
- One out-of-band acceptance item (three follow-up issues) is UNVERIFIED and is recorded in `remediation-inputs.2026-06-13T19-53.md` as a tracking item, not a code defect.

Go/No-go: the implementation is complete and compliant for all in-branch acceptance criteria. PR readiness is gated only by the orchestrator confirming the three Decision L follow-up issues are filed.

## Acceptance Criteria Check-off

The previously-unchecked spec.md criteria #7, #8, #10 and user-story.md criteria #6, #7, #8 are evaluated PASS in this audit and are checked off in their source files per `acceptance-criteria-tracking`. The user-story.md follow-up-issues criterion (#14) is UNVERIFIED and remains unchecked. The spec.md "Definition of Done" and "Seeded Test Conditions" sections are not acceptance criteria and are not modified by this review.
