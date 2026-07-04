# Atomic Implementation Plan — claude-memory-scope-and-hardening (Issue #181)

- Issue: #181
- Feature folder: `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/`
- Work Mode: full-feature
- Languages in scope: Python + Markdown (TypeScript expected N/A — extension Jest/Prettier/ESLint/tsc toolchain runs only if a `.ts`/`.tsx` file changes; none is expected in this plan)
- Evidence root (canonical, non-overridable): `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/<kind>/`

## Sources of truth

- `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/spec.md` (S1–S8, Invariants, Acceptance Criteria)
- `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/user-story.md` (Scenarios 1–8, Acceptance Criteria)
- `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/issue.md`
- `artifacts/research/20260613-memory-bundling-differentiation.md` (Research A — memory classification, 11-file list)
- `artifacts/research/2026-06-13T11-51-hardening-classification-research.md` (Research B — section 7 generalized memory rewrites, H2–H5 invariants, LG4 exemption)

## Fixed-scope guardrails (do not violate)

- Decision C1: root coverage policy UNCHANGED. Do NOT introduce `rules/coverage.md`, `diff-cover`, 80%/90% thresholds, the 6-step toolchain, or PyYAML. These are non-goals.
- The three cross-language items (new-code delta gate, TS/C# test-purity hooks, TS/C# batch-budget hooks) are OUT OF SCOPE; the orchestrator files them as separate GitHub issues, not implemented here.
- Scope parser is `re`-based only; no new runtime dependency.
- Per-batch budget: at most 3 production files + 3 test files per execution batch. Phases below are sized to respect this.
- Byte-identical invariants:
  - The two main push-down scripts (`scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`) must remain byte-for-byte identical.
  - Every non-memory `.claude` file edit at root must be mirrored byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/`.

---

### Phase 0 — Baseline capture and policy reads

- [x] [P0-T1] Read the policy files in required order and record an evidence artifact at `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and an explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/tonality.md`. Acceptance: artifact exists with all three fields populated and the eight files listed.
- [x] [P0-T2] Run `poetry run black --check .` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/baseline-black.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records the exit code and a one-line pass/fail summary.
- [x] [P0-T3] Run `poetry run ruff check .` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/baseline-ruff.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records the exit code and key counts.
- [x] [P0-T4] Run `poetry run pyright` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/baseline-pyright.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records the exit code and error/warning counts.
- [x] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/baseline-pytest.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. `Output Summary:` MUST include the numeric baseline line-coverage and branch-coverage headline values and the passed/failed test counts. Acceptance: artifact records numeric coverage values (not placeholders) and the test result counts.
- [x] [P0-T6] Verify the two main push-down script copies are byte-identical by running `git diff --no-index scripts/dev_tools/push_down_claude_customizations.py extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/baseline-script-parity.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records EXIT_CODE 0 (no diff) as the starting byte-identical state.
- [x] [P0-T7] Confirm no `.ts`/`.tsx` file is in the planned change set and record the rationale in `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/baseline/baseline-typescript-na.md` with `Timestamp:` and `Output Summary:` stating the extension Jest/Prettier/ESLint/tsc toolchain is Not Applicable because no TypeScript files are modified by this plan. Acceptance: artifact exists and states the N/A rationale.

---

### Phase 1 — Scope parser and filter in the two main push-down scripts

This phase touches 2 production files (the byte-identical pair counts as one logical edit applied twice) and 0 test files; within batch budget.

- [x] [P1-T1] In `scripts/dev_tools/push_down_claude_customizations.py`, add an `re`-based frontmatter scope parser `_read_memory_scope(content: str) -> str` that extracts the leading YAML frontmatter block between the first pair of `---` markers and returns the value of `metadata.scope`. It returns `"repo"` when frontmatter is missing, the `scope` leaf is absent, the value is unrecognized, or the value is not exactly `general`; it returns `"general"` only for an exact `general` value. No PyYAML import. Acceptance: function present with a full docstring per `self-explanatory-code-commenting.md`; returns `general`/`repo` per the rules above.
- [x] [P1-T2] In `scripts/dev_tools/push_down_claude_customizations.py`, add predicate `_is_general_memory_file(relative_path: Path, content: str) -> bool` returning `True` only when the path is under `.claude/agent-memory/` and `_read_memory_scope(content) == "general"`, and returning `True` unconditionally for paths outside `.claude/agent-memory/`. Acceptance: function present with docstring; non-memory paths always return `True`.
- [x] [P1-T3] In `scripts/dev_tools/push_down_claude_customizations.py`, extend `_ExcludingFileSystem.list_files()` so that, in addition to the existing `EXCLUDED_RELATIVE_PATHS` check, each candidate file under `.claude/agent-memory/` is read via the inner adapter's `read_text` and excluded when `_is_general_memory_file(...)` returns `False`. Update the module docstring and `__all__` to reflect the new filtering behavior and any new public helper. Acceptance: agent-memory files that are not `scope: general` are removed from the returned list; non-memory files are unaffected.
- [x] [P1-T4] If `scripts/dev_tools/push_down_claude_customizations.py` would exceed 500 lines after P1-T1–P1-T3, extract the parser/predicate into a new helper module `scripts/dev_tools/push_down_claude_memory_scope.py` (with full docstrings) and import it; otherwise keep the helpers inline and record that the file remains <= 500 lines. Acceptance: the script file is <= 500 lines; if a helper module was created, it is <= 500 lines and imported by the script.
- [x] [P1-T5] Apply the exact changes from P1-T1–P1-T4 (and, if created, the new helper module) to `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` so the two copies remain byte-for-byte identical; if a helper module was created in P1-T4, mirror it byte-identically to `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_memory_scope.py`. Acceptance: `git diff --no-index` between the two script copies (and between the two helper-module copies if present) reports no differences.

---

### Phase 2 — Extension template scope filter and source-root fix

This phase touches 1 production file; within batch budget.

- [x] [P2-T1] In `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`, apply the same scope-filter logic as Phase 1 (the `_read_memory_scope` parser, the `_is_general_memory_file` predicate, and the `_ExcludingFileSystem.list_files()` content-based exclusion). If Phase 1 created a shared helper module, import it via the same bundled-scripts import path the template already bootstraps; otherwise add the helpers inline. Acceptance: the template carries equivalent scope-filter behavior to the two main scripts.
- [x] [P2-T2] In `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`, fix the source-root bug in `main()`: change the `push_down_customizations(...)` call so `source_root` (and the `repo_root` used as the copy source) resolves to the bundled customizations directory `Path(__file__).resolve().parent.parent / "claude-customizations"`, mirroring `extensions/drm-copilot/resources/templates/push_down_codex_and_agents_customizations.py` (lines ~77–88), instead of `resolve_cli_path(repo_root or Path.cwd())`. The destination remains the parsed `--destination`. Acceptance: the template copies from the bundled `claude-customizations/` directory to the destination, not from the destination back to itself.
- [x] [P2-T3] Confirm `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` remains <= 500 lines after P2-T1–P2-T2. Acceptance: file is <= 500 lines.

---

### Phase 3 — Annotate the 11 existing bundled memories

Markdown-only edits under `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/`. Adds the `scope` leaf inside each file's existing `metadata:` frontmatter block. Confirmed against Research A section 2.

- [x] [P3-T1] Add `scope: general` to the `metadata:` block of `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_policy_compliance_not_optional.md`. Acceptance: frontmatter `metadata.scope` is exactly `general`.
- [x] [P3-T2] Add `scope: repo` to the `metadata:` block of each of the following five orchestrator memories: `orchestrator/feedback_bundle_sync_after_runtime_edit.md`, `orchestrator/feedback_repo_root_is_source_of_truth.md`, `orchestrator/feedback_vsce_verify_package_location.md`, `orchestrator/project_extension_location.md`, `orchestrator/project_published_mcp_server.md` (all under `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/`). Acceptance: each file's `metadata.scope` is exactly `repo`.
- [x] [P3-T3] Add `scope: repo` to the `metadata:` block of the remaining four repo-specific memories: `prd-feature/project_push_down_pattern.md`, `task-researcher/project_push_down_claude_dir.md`, and the two non-index files' subtrees are covered; then add `scope: repo` to the three `MEMORY.md` index files: `orchestrator/MEMORY.md`, `prd-feature/MEMORY.md`, `task-researcher/MEMORY.md` (all under `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/`). Acceptance: `prd-feature/project_push_down_pattern.md`, `task-researcher/project_push_down_claude_dir.md`, and all three `MEMORY.md` indexes carry `metadata.scope: repo`. Net result across Phase 3: exactly 1 file `scope: general`, 10 files `scope: repo`.

---

### Phase 4 — Six generalized general-scoped memories plus index update

Markdown-only. New files created in the bundle at `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/`. Use the generalized rewrites in Research B section 7 (M1–M6); each file MUST be repository-neutral (no drm-copilot paths, issue numbers, or source-repo file names) and carry standard memory frontmatter (`name`, `description`, `metadata.type`, `metadata.scope: general`).

- [x] [P4-T1] Create `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_test_files_count_against_500_cap.md` from Research B M1 (test files count against the 500-line cap; QA must scan changed/created production AND test files). Frontmatter: `metadata.type: feedback`, `metadata.scope: general`. Acceptance: file exists, is repository-neutral, and carries `scope: general`.
- [x] [P4-T2] Create `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_every_change_through_lifecycle.md` from Research B M2 (every change, including small tooling changes, goes through issue promotion, active feature folder, feature-review before commit; evidence only under the active feature folder). Frontmatter: `metadata.type: feedback`, `metadata.scope: general`. Acceptance: file exists, repository-neutral, `scope: general`.
- [x] [P4-T3] Create `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_remediation_plan_em_dash_required.md` from Research B M3 (the plan validator rejects any token between `Phase N` and the em-dash; only `### Phase N — <Title>` passes). Frontmatter: `metadata.type: feedback`, `metadata.scope: general`. Acceptance: file exists, repository-neutral, `scope: general`.
- [x] [P4-T4] Create `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_branch_base_check_unmerged_pr_deps.md` from Research B M4 (verify required symbols/files exist on the chosen branch base; if only in an open PR, stack or merge first). Frontmatter: `metadata.type: feedback`, `metadata.scope: general`. Acceptance: file exists, repository-neutral, `scope: general`.
- [x] [P4-T5] Create `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_potential_to_issue_creates_github_issue.md` from Research B M5 (`potential_to_issue` creates the GitHub issue as a side effect; do not also run `gh issue create`). Frontmatter: `metadata.type: feedback`, `metadata.scope: general`. Acceptance: file exists, repository-neutral, `scope: general`.
- [x] [P4-T6] Create `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/feedback_small_bug_uses_minor_audit.md` from Research B M6 (a ~1–3 production-file bug fix uses the small path with Work Mode `minor-audit`, not `full-bug`). Frontmatter: `metadata.type: feedback`, `metadata.scope: general`. Acceptance: file exists, repository-neutral, `scope: general`.
- [x] [P4-T7] Update `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/MEMORY.md` to add one index pointer line per the six new memories (P4-T1–P4-T6), keeping the index file's own `metadata.scope: repo`. Acceptance: the index references all six new files by their `name:` slugs, and the index file remains `scope: repo`.

---

### Phase 5 — Orchestrator-state invariants prose rule with bundle mirror

Non-memory `.claude` edits; both copies MUST be byte-identical (parity test). Markdown only.

- [x] [P5-T1] Create `.claude/rules/orchestrator-state.md` documenting the three remediation-cycle invariants for `artifacts/orchestration/orchestrator-state.json`: (1) per cycle, `plan_path` must be a non-empty string; (2) `execution_status` in `{in_progress, complete, failed}` requires that cycle's `preflight.final_status == 'clear'`; (3) `exit_condition_met == true` requires `blocking_count == 0`. The rule MUST state that the hardened snapshot's orchestrator-state schema references a foreign `$id` (`drmoisan.github.io/mix-calculator/`) and must not be copied verbatim; the invariants are re-expressed as prose plus validator logic. Use the same path-scoped/header conventions as existing `.claude/rules/*.md` files. Acceptance: file documents all three invariants and the foreign-`$id` warning.
- [x] [P5-T2] Create `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` as a byte-identical mirror of the root file from P5-T1. Acceptance: `git diff --no-index .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` reports no differences.

---

### Phase 6 — Orchestrator-state invariants additive backward-compatible validator

Touches 1 production file; within batch budget.

- [x] [P6-T1] In `scripts/dev_tools/validate_orchestrator_state.py`, add a private helper (following the existing `_validate_*_delegation_receipts` pattern) that validates a `remediation_loop` only when a top-level `remediation_loop` key is present with a `cycles` array. For each cycle, append an error when: `plan_path` is missing, not a string, or empty/whitespace-only; `execution_status` is in `{in_progress, complete, failed}` and the cycle's `preflight.final_status` is not exactly `'clear'`; or `exit_condition_met == true` and `blocking_count` is not `0`. Do NOT copy the snapshot JSON schema or its foreign `$id`. Acceptance: helper present with full docstring; produces the three error categories on malformed cycles.
- [x] [P6-T2] In `scripts/dev_tools/validate_orchestrator_state.py`, call the new helper from `validate_orchestrator_state_text(...)` only when `remediation_loop` is present, append its errors to the returned list, preserve the existing message style (literal, checkpoint-context prefixed), and keep the function pure (no input mutation, returns `list[str]`). When `remediation_loop` is absent or has no cycles, existing behavior is unchanged and no new errors are produced. Acceptance: a checkpoint with no `remediation_loop` returns exactly the pre-change error set; a checkpoint with a `remediation_loop` returns the new invariant errors.
- [x] [P6-T3] Confirm `scripts/dev_tools/validate_orchestrator_state.py` is <= 500 lines after P6-T1–P6-T2; if it would exceed the cap, extract the cycle-validation logic into a sibling module `scripts/dev_tools/validate_orchestrator_state_remediation.py` (with full docstrings) consistent with the existing helper pattern and import it. Acceptance: the validator file (and any new sibling) is <= 500 lines.

---

### Phase 7 — Type-only and interface-only coverage exemption with bundle mirrors

Non-memory `.claude` Markdown edits; each root edit MUST be mirrored byte-identically. PowerShell excluded (no type-only construct). The note is a clarification only; it does NOT lower any coverage threshold.

- [x] [P7-T1] Add a clarifying note to `.claude/rules/general-unit-test.md` under Coverage Requirements stating that type-only / interface-only modules with no executable behavior (for example Python `Protocol`-only modules consumed only under `TYPE_CHECKING`, TypeScript interface/type-only files, C# interface-only files) may be omitted from coverage measurement and legitimately report 0% executable coverage, without lowering any threshold. Acceptance: note present; no threshold value changed.
- [x] [P7-T2] Mirror the P7-T1 edit byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`. Acceptance: `git diff --no-index` of the two `general-unit-test.md` files reports no differences.
- [x] [P7-T3] Add the equivalent clarifying note to `.claude/rules/python.md` under the Pytest coverage rules (Python `Protocol`-only / `TYPE_CHECKING`-only modules). Acceptance: note present; no threshold value changed.
- [x] [P7-T4] Mirror the P7-T3 edit byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md`. Acceptance: `git diff --no-index` of the two `python.md` files reports no differences.
- [x] [P7-T5] Add the equivalent clarifying note to `.claude/rules/typescript.md` under the coverage rules (interface/type-only files). Acceptance: note present; no threshold value changed.
- [x] [P7-T6] Mirror the P7-T5 edit byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`. Acceptance: `git diff --no-index` of the two `typescript.md` files reports no differences.
- [x] [P7-T7] Add the equivalent clarifying note to `.claude/rules/csharp.md` under the Coverage section (interface-only files). Acceptance: note present; no threshold value changed.
- [x] [P7-T8] Mirror the P7-T7 edit byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`. Acceptance: `git diff --no-index` of the two `csharp.md` files reports no differences.

---

### Phase 8 — Push-down scope-filter and parser tests

Test-file changes. Within batch budget (1 test file in this phase).

- [x] [P8-T1] In `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, add scope-parser unit tests for `_read_memory_scope` covering: exact `general` → `general`; exact `repo` → `repo`; absent `scope` field → `repo`; missing frontmatter entirely → `repo`; malformed frontmatter (no closing `---`) → `repo`; unrecognized value → `repo`. Use in-memory content strings (no temp files). Acceptance: each case asserts the expected return value.
- [x] [P8-T2] In `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, add filter tests: a `scope: general` memory under `.claude/agent-memory/` is copied to the destination; a `scope: repo` memory is excluded; an unmarked memory is excluded (fail-safe default); a malformed-frontmatter memory is excluded; a file outside `.claude/agent-memory/` is copied verbatim and is unaffected by the scope filter. Use the in-memory/fake filesystem patterns already present in this module (no runtime temp files). Acceptance: each scenario asserts the include/exclude outcome.
- [x] [P8-T3] Confirm `tests/scripts/dev_tools/test_push_down_claude_customizations.py` is <= 500 lines after additions; if it would exceed the cap, split the new scope tests into a sibling module `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` (<= 500 lines). Acceptance: each touched/created test file is <= 500 lines.

---

### Phase 9 — Resource-contract parity tests for agent-memory

Test-file changes. Within batch budget (1 test file in this phase).

- [x] [P9-T1] In `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, exempt `.claude/agent-memory/**` from the byte-identical "every repo file must be in the bundle" assertion in `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (general memories live in the bundle but not at the gitignored root `.claude/agent-memory/`). Acceptance: the parity assertion no longer iterates `.claude/agent-memory/**` paths.
- [x] [P9-T2] In `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, add an assertion (new test) that every bundled file under `.claude/agent-memory/` that is not a `MEMORY.md` index carries `metadata.scope: general`, and that every bundled `MEMORY.md` index carries `metadata.scope: repo`. Acceptance: the test enumerates the bundled agent-memory tree and asserts both conditions.
- [x] [P9-T3] Confirm `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is <= 500 lines after additions; split into a sibling test module if it would exceed the cap. Acceptance: each touched/created test file is <= 500 lines.

---

### Phase 10 — Orchestrator-state validator tests

Test-file changes. Within batch budget (1 test file in this phase).

- [x] [P10-T1] In `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, add a backward-compatibility regression test: a checkpoint with no `remediation_loop` validates exactly as before (no new invariant errors). Acceptance: test asserts the error list is unchanged from the pre-change behavior for a non-`remediation_loop` checkpoint.
- [x] [P10-T2] In `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, add positive and negative cases for each of the three invariants: (a) empty/whitespace `plan_path` → error; valid non-empty `plan_path` → no error; (b) `execution_status` in `{in_progress, complete, failed}` with non-`clear` preflight → error; same status with `preflight.final_status == 'clear'` → no error; (c) `exit_condition_met == true` with non-zero `blocking_count` → error; `exit_condition_met == true` with `blocking_count == 0` → no error. Acceptance: each invariant has at least one passing and one failing case.
- [x] [P10-T3] Confirm `tests/scripts/dev_tools/test_validate_orchestrator_state.py` is <= 500 lines after additions; split into a sibling test module if it would exceed the cap. Acceptance: each touched/created test file is <= 500 lines.

---

### Phase 11 — Final QA loop and acceptance verification

Run the full Python toolchain in order. If any step fails or changes files, restart from the formatting step until a single clean pass completes. Persist one evidence artifact per command step.

- [x] [P11-T1] Run `poetry run black .` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-black.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If files were reformatted, restart the loop. Acceptance: clean formatting pass recorded.
- [x] [P11-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-ruff.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 recorded (no lint errors).
- [x] [P11-T3] Run `poetry run pyright` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-pyright.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 recorded (0 errors).
- [x] [P11-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-pytest.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. `Output Summary:` MUST record numeric post-change line- and branch-coverage values and the passed/failed test counts. Acceptance: EXIT_CODE 0, coverage meets 85% line / 75% branch, and no regression on changed lines versus the P0-T5 baseline.
- [x] [P11-T5] Verify the two main push-down script copies remain byte-identical: run `git diff --no-index scripts/dev_tools/push_down_claude_customizations.py extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` (and, if a shared helper module was created in P1-T4, the corresponding pair) and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-script-parity.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0 (no diff) for every script/helper pair.
- [x] [P11-T6] Verify every non-memory `.claude` mirror pair edited in this plan is byte-identical: run `git diff --no-index` for each of `orchestrator-state.md`, `general-unit-test.md`, `python.md`, `typescript.md`, `csharp.md` between `.claude/rules/` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`, and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-mirror-parity.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (per pair), `Output Summary:`. Acceptance: every pair reports no differences.
- [x] [P11-T7] Scan all changed/created production AND test files in this feature for the 500-line cap (the two push-down scripts and any helper module, the extension template, `validate_orchestrator_state.py` and any sibling, and every touched/created `tests/scripts/dev_tools/*.py`) and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-file-size-scan.md` with `Timestamp:`, `Command:`, `Output Summary:` listing each file and its line count. Acceptance: every listed file is <= 500 lines; Markdown documentation files are exempt per policy.
- [x] [P11-T8] Verify each Acceptance Criterion in `spec.md` (lines 375–390) and `user-story.md` (lines 104–115) against on-disk evidence and write `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-acceptance-verification.md` mapping each criterion to its verifying evidence artifact or file. Confirm explicitly that no rejected snapshot artifact (`rules/coverage.md`, `diff-cover` gate, JSON schema with foreign `$id`, 6-step toolchain, PyYAML) was introduced and that root coverage policy is unchanged (85% line / 75% branch, tier system retained). Acceptance: every spec and user-story acceptance criterion is mapped to evidence; the no-rejected-artifact and unchanged-coverage-policy checks pass.
- [x] [P11-T9] Confirm the extension Jest/Prettier/ESLint/tsc toolchain remains Not Applicable by verifying no `.ts`/`.tsx` file was modified in the final change set (`git diff --name-only` filtered to `*.ts`/`*.tsx` returns empty) and record the result in `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/qa-gates/final-typescript-na.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: no TypeScript files changed; extension toolchain confirmed N/A (not waived).
