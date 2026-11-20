# claude-memory-scope-and-hardening - Refactor Spec

- **Issue:** #181
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/181
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-13
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Intent & Outcomes

The extension ships a bundled copy of `.claude` to consumer repositories via the
push-down mechanism. The current contract requires every `.claude` file to mirror into
the bundled copy. That contract is incorrect for `.claude/agent-memory`: some agent
memories are specific to this repository (the drm-copilot extension itself) and have no
value — and may mislead — when pushed to consumer repositories. Only memories that apply
to any repository should be distributed.

Separately, a hardened snapshot of the Claude architecture from another repository
(`artifacts/.claude`) contains additive hardening that this repository lacks: explicit
orchestrator-state invariants and a type-only-module coverage exemption. The snapshot also
contains six domain-neutral orchestration memories worth promoting. Coverage-threshold
changes in the snapshot were reviewed and rejected; the root tier-based coverage policy
(85% line / 75% branch) is retained.

This feature delivers two outcomes:

1. A deterministic, fail-safe memory differentiation mechanism that distributes only
   general-scoped agent memories to consumer repositories.
2. Additive orchestrator-state invariants and a type-only-module coverage exemption,
   mirrored into both the root `.claude` and the bundled `.claude` copy.

This feature is expected to change Python and Markdown files only. No TypeScript change is
expected.

## Approved Decisions (final — encoded here, not re-opened)

- **Decision M (memory differentiation):** A YAML frontmatter field `metadata.scope:
  general | repo` on each agent memory. The push-down filter copies a memory only when
  `scope: general`. An absent or unrecognized value defaults to `repo` (fail-safe — nothing
  leaks). `MEMORY.md` index files are `scope: repo`. Per Option B, repo-specific memories are
  physically removed from the bundled `.claude/agent-memory` copy and relocated to the root
  `.claude/agent-memory` folder (gitignored / local-only); the bundle retains only
  `scope: general` memories plus each orchestrator `MEMORY.md` index (which remains
  `scope: repo` and is never pushed). The frontmatter scope value is parsed
  with a small `re`-based parser. PyYAML is not added. The template source-root bug in
  `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` is fixed in
  the same change (it resolves the source-root from cwd instead of the bundled
  customizations directory; it is aligned with the codex template behavior).
- **Decision C = C1 (coverage policy unchanged):** Root coverage policy stays at 85% line /
  75% branch with the tier system retained. The snapshot's 80% / 90% thresholds,
  `rules/coverage.md`, the `diff-cover` new-code gate, the 6-step toolchain, and the
  "property tests encouraged" downgrade are all rejected and must not be introduced.
- **Decision L (cross-language scope):** Three cross-language items are out of scope and are
  filed as separate GitHub issues (see Out of Scope / Follow-up Issues). The type-only /
  interface-only module coverage exemption is in scope and implemented here.

## Invariants (must not change)

The following behaviors, contracts, and surfaces must remain identical after this change:

- **Byte-identical script copies.** `scripts/dev_tools/push_down_claude_customizations.py`
  and `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`
  must remain byte-for-byte identical (enforced by existing tests).
- **Non-memory mirror parity.** Every non-memory `.claude` file must remain byte-identical
  between the root `.claude` and the bundled
  `extensions/drm-copilot/resources/claude-customizations/.claude` copy
  (enforced by the resource-contract parity test).
- **`settings.local.json` exclusion.** The existing exclusion of
  `.claude/settings.local.json` from push-down is unchanged.
- **Non-memory copy behavior.** Files outside `.claude/agent-memory/` continue to be copied
  verbatim, unaffected by the new scope filter.
- **Root coverage policy.** 85% line / 75% branch thresholds and the T1–T4 tier system are
  unchanged. No `rules/coverage.md`, `diff-cover` gate, or threshold change is introduced.
- **Existing `validate_orchestrator_state.py` contract.** The current required top-level
  keys, step-status validation, and delegation-receipt validation behavior remain. The new
  invariants are additive and apply only when a `remediation_loop` structure is present.
- **Compatibility guarantees.** No CLI flag changes; no public function removals. New helper
  functions are additive.

## Scope (structural changes)

### S1 — Memory scope filter in the push-down engine

Add a content-based scope filter for files under `.claude/agent-memory/` to the two main
push-down script copies. The two copies must stay byte-identical:

- `scripts/dev_tools/push_down_claude_customizations.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`

Implementation outline (each copy receives identical logic):

- Add an `re`-based frontmatter scope parser (for example
  `_read_memory_scope(content: str) -> str`) that extracts the leading YAML frontmatter block
  (between the first pair of `---` markers) and returns the value of `metadata.scope`. It
  returns `repo` when the field is absent, the frontmatter is missing, the value is
  unrecognized, or the value is not exactly `general`. The parser only reads the `scope` leaf;
  it does not implement general YAML parsing and does not add PyYAML.
- Add a predicate (for example `_is_general_memory_file(relative_path, content)`) that returns
  `True` only when the path is under `.claude/agent-memory/` and the parsed scope is exactly
  `general`. For paths outside `.claude/agent-memory/`, the predicate returns `True`
  unconditionally (those files are always copied).
- Extend `_ExcludingFileSystem.list_files()` so that, in addition to the existing
  `EXCLUDED_RELATIVE_PATHS` check, it reads the content of each candidate file under
  `.claude/agent-memory/` (via the inner adapter's `read_text`) and excludes any file that is
  not general-scoped.
- Update the module docstring and `__all__` to reflect the new filtering behavior and any
  new public helper.

### S2 — Extension template scope filter and source-root fix

Update `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`:

- Apply the same scope-filter logic as S1.
- Fix the source-root bug. The template currently calls
  `push_down_customizations(..., source_root=resolved_repo_root, ...)` where
  `resolved_repo_root = resolve_cli_path(repo_root or Path.cwd())`. With cwd equal to the
  destination workspace, the template uses the destination as its own source. Align the
  template with the codex template (`push_down_codex_and_agents_customizations.py`), which sets
  the source root to the bundled customizations directory:
  `Path(__file__).resolve().parent.parent / "claude-customizations"`. The template must copy
  from the bundled `claude-customizations/` directory to the destination, not from the
  destination back to itself.

This template is architecturally distinct from the two dev-tools scripts; it is not subject
to the byte-identical-script invariant, but it must carry equivalent filtering behavior.

### S3 — Reconcile the existing bundled memories to general-only (Option B)

Per Option B, the bundled `.claude/agent-memory` copy must contain only `scope: general`
memories plus each orchestrator `MEMORY.md` index. Repo-specific memories are physically
removed from the bundle and relocated to the root `.claude/agent-memory` folder (gitignored /
local-only). Reconcile the memory files under
`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/` as follows:

- **Retained in the bundle as `scope: general`:**
  - `orchestrator/feedback_policy_compliance_not_optional.md` — `scope: general`.
- **Retained in the bundle as `scope: repo` (index only, never pushed):**
  - `orchestrator/MEMORY.md` — `scope: repo`.
- **Physically removed from the bundle and relocated to the root `.claude/agent-memory`
  folder (gitignored / local-only):**
  - `orchestrator/feedback_bundle_sync_after_runtime_edit.md`.
  - `orchestrator/feedback_repo_root_is_source_of_truth.md`.
  - `orchestrator/feedback_vsce_verify_package_location.md`.
  - `orchestrator/project_extension_location.md`.
  - `orchestrator/project_published_mcp_server.md`.
  - `prd-feature/project_push_down_pattern.md`.
  - `task-researcher/project_push_down_claude_dir.md`.

The `prd-feature/` and `task-researcher/` agent-memory subdirectories are removed from the
bundle entirely (they held only repo-specific content, including their `MEMORY.md` index
files). The orchestrator `MEMORY.md` index is updated so it no longer references the relocated
repo-specific memories.

Result: the bundled `.claude/agent-memory` copy contains only `scope: general` memories plus
the orchestrator `MEMORY.md` index (which remains `scope: repo`). The `scope` field is recorded
inside the existing `metadata:` block of each retained file's frontmatter. The relocated
repo-specific memories continue to exist only at the root `.claude/agent-memory` folder, which
is gitignored / local-only and never pushed.

### S4 — Promote six domain-neutral orchestration memories as `scope: general`

Add six generalized orchestration memories to the bundled orchestrator memory directory, each
carrying `scope: general` and following the generalized rewrites in Research B section 7:

1. Test files count against the 500-line file cap (not only production files).
2. Every change — including small tooling changes — goes through the full orchestration
   lifecycle (issue promotion, active feature folder, feature-review before commit).
3. Remediation-plan phase headings must use the canonical `### Phase N — <Title>` em-dash form
   with no parenthetical qualifiers (validator-enforced).
4. Branch-base check for unmerged-PR dependencies before choosing a branch base.
5. `potential_to_issue` already creates the GitHub issue; do not also run `gh issue create`.
6. A small bug fix (~1–3 production files) uses the small path with Work Mode `minor-audit`,
   not `full-bug`.

The bundled orchestrator `MEMORY.md` index is updated to point at the new general memories.
The index file itself remains `scope: repo`.

The generalized rewrites must not reference drm-copilot-specific paths, issue numbers, or
source-repo file names; they must read as repository-neutral guidance.

### S5 — Orchestrator-state invariants (prose rule + validator)

Document the orchestrator-state invariants as a prose rule and enforce them in the validator.

**Prose rule.** Add a new rule file `orchestrator-state.md` to both the root `.claude/rules/`
and the bundled `.claude/rules/` copy (byte-identical mirror). The rule documents three
invariants for remediation cycles in the orchestrator-state artifact at
`artifacts/orchestration/orchestrator-state.json`:

1. Per remediation cycle, `plan_path` must be a non-empty string. An empty string is a
   malformed cycle.
2. A cycle `execution_status` may not be in `{in_progress, complete, failed}` unless that
   cycle's `preflight.final_status == 'clear'`.
3. `exit_condition_met == true` requires `blocking_count == 0`.

The rule must state that the orchestrator-state schema from the hardened snapshot references a
foreign `$id` (`drmoisan.github.io/mix-calculator/`) and must not be copied verbatim; the
invariants are re-expressed as prose plus validator logic.

**Validator.** Enforce the three invariants in
`scripts/dev_tools/validate_orchestrator_state.py`.

Current state, verified by reading the validator: the module validates a step-based checkpoint
shape (`REQUIRED_STATE_KEYS` with `step5_status`–`step10_status`, `delegation_receipts`,
`blocked_reason`). It does not model a `remediation_loop`, cycles, `preflight`, `plan_path`,
`execution_status`, `blocking_count`, or `exit_condition_met`. The new invariants therefore
require introducing remediation-cycle modeling into the validator.

The validator changes must be additive and backward compatible:

- When the checkpoint has no `remediation_loop` (or no cycles), the existing validation
  behavior is unchanged and the new invariants do not produce errors.
- When a `remediation_loop` with a `cycles` array is present, for each cycle the validator
  appends an error when:
  - `plan_path` is missing, not a string, or an empty/whitespace-only string;
  - `execution_status` is in `{in_progress, complete, failed}` and the cycle's
    `preflight.final_status` is not exactly `'clear'`;
  - `exit_condition_met == true` and `blocking_count` is not `0`.
- Error messages follow the existing validator's message style (literal, prefixed with the
  checkpoint context) and the validator continues to return a list of error strings without
  mutating input.

The 500-line file-size limit must be respected; if adding cycle validation pushes
`validate_orchestrator_state.py` near the limit, extract the cycle-validation logic into a
small private helper within the same module or a sibling module, consistent with the existing
`_validate_*_delegation_receipts` helper pattern.

### S6 — Type-only / interface-only module coverage exemption

Add a clarifying note that type-only / interface-only modules with no executable behavior may
be excluded from coverage measurement. Examples: Python `Protocol`-only modules consumed only
under `TYPE_CHECKING`; TypeScript interface/type-only files; C# interface-only files. The note
is a clarification that does not lower any coverage threshold; such modules legitimately report
0% executable coverage and may be omitted from measurement.

Add the note to:

- The general unit-test rule `general-unit-test.md` (root and bundle), under Coverage
  Requirements.
- `rules/python.md` (root and bundle), under the Pytest coverage rules.
- `rules/typescript.md` (root and bundle), under the coverage rules.
- `rules/csharp.md` (root and bundle), under the Coverage section.

PowerShell has no type-only construct and is not modified for this exemption.

### S7 — Tests

Update the two affected test modules:

- `tests/scripts/dev_tools/test_push_down_claude_customizations.py`:
  - Scope parser tests: `general`, `repo`, absent field, missing frontmatter, malformed
    frontmatter, unrecognized value — each mapping to the expected include/exclude decision.
  - Filter tests: a `scope: general` memory is copied; a `scope: repo` memory is excluded; an
    unmarked memory is excluded (fail-safe default); files outside `.claude/agent-memory/` are
    unaffected by the scope filter.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`:
  - Exempt `.claude/agent-memory/**` from the byte-identical "every repo file must be in the
    bundle" assertion in
    `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (the general memories
    live in the bundle but not at the gitignored root `.claude/agent-memory/`).
  - Add an assertion that every NON-index bundled file under `.claude/agent-memory/` carries
    `metadata.scope: general`, and that every `MEMORY.md` index file carries `scope: repo`.
    Per Option B, no `scope: repo` non-index memory remains in the bundle; this assertion
    prevents repo-specific memories from being distributed and prevents an index from being
    mismarked.

Add validator tests for S5, in the existing orchestrator-state validator test module
(positive and negative cases for each of the three invariants, plus a case with no
`remediation_loop` to confirm backward compatibility).

### S8 — Mirroring

Every non-memory `.claude` change in this feature (the new `orchestrator-state.md` rule and
the four coverage-exemption note edits) must be applied to both the root `.claude` and the
bundled `extensions/drm-copilot/resources/claude-customizations/.claude` copy as byte-identical
mirrors. The resource-contract parity test enforces byte-identical mirroring for non-memory
files.

## Non-Goals

- No change to root coverage thresholds, the tier system, the toolchain stage count, or the
  property-test obligation. The snapshot's 80% / 90% thresholds, `rules/coverage.md`, the
  `diff-cover` new-code gate, and the 6-step toolchain are explicitly not introduced.
- No import of the 85 domain-specific memories from `artifacts/.claude/agent-memory/` beyond
  the six generalized memories in S4.
- No JSON Schema file is added; the snapshot schema's foreign `$id` must not be copied. The
  invariants are expressed as prose plus validator logic.
- No new runtime dependency (no PyYAML); the scope parser is `re`-based.
- No changes to `agentic_sync.py`; agent-memory does not participate in agentic sync.
- The three cross-language generalization items in Decision L are not implemented here.

## Dependencies / Touchpoints

- Shared push-down engine `scripts/dev_tools/push_down_copilot_customizations.py` and the
  filesystem adapter `push_down_copilot_customizations_filesystem.py` (consumed, not modified).
- Codex template `push_down_codex_and_agents_customizations.py` (referenced as the source-root
  fix model; not modified).
- The resource-contract parity test and the byte-identical-script test (both must continue to
  pass with the agent-memory exemption applied).
- The orchestrator-state validator is consumed by the MCP tool
  `validate_orchestration_artifacts`; backward compatibility for existing step-based
  checkpoints must be preserved.
- `.gitignore` excludes `.claude/agent-memory` at the repo root; committed general memories
  exist only in the bundle directory. This is unchanged.

## Risks & Mitigations

- **Risk:** The two main push-down script copies drift. **Mitigation:** Apply identical edits
  to both; the byte-identical-script test fails on drift.
- **Risk:** A non-memory rule edit is applied to only one of root / bundle. **Mitigation:**
  Apply both; the resource-contract parity test fails on divergence.
- **Risk:** A repo-specific memory is accidentally marked `scope: general` and distributed.
  **Mitigation:** Per Option B, repo-specific memories are physically removed from the bundle;
  the fail-safe default is `repo`; the new bundle assertion in S7 fails if any non-index bundled
  memory is not `scope: general`, and `MEMORY.md` indexes are asserted `scope: repo`.
- **Risk:** The validator change breaks existing step-based checkpoints. **Mitigation:** New
  invariants apply only when a `remediation_loop` is present; a no-`remediation_loop`
  regression test guards backward compatibility.
- **Risk:** Reading file content during enumeration changes push-down performance.
  **Mitigation:** Content is read only for files under `.claude/agent-memory/`; the subtree is
  small (after Option B reconciliation the bundle holds only general-scoped memories plus the
  orchestrator `MEMORY.md` index).

## Technical Specifications

- **Files/modules expected to change:**
  - `scripts/dev_tools/push_down_claude_customizations.py`
  - `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`
  - `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`
  - `scripts/dev_tools/validate_orchestrator_state.py`
  - `.claude/rules/orchestrator-state.md` (new) and bundled mirror
    `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
  - `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`,
    `.claude/rules/typescript.md`, `.claude/rules/csharp.md` and their bundled mirrors
  - The reconciled bundled memory files (S3: the retained `scope: general` memory, the removed
    repo-specific memories, and the removed `prd-feature/` and `task-researcher/` subdirectories)
    and six new bundled memory files (S4) plus the bundled orchestrator `MEMORY.md`
  - `tests/scripts/dev_tools/test_push_down_claude_customizations.py`
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - The orchestrator-state validator test module (validator invariant tests)
- **Public interfaces/contracts affected:**
  - Push-down scripts gain additive helper(s) for scope parsing/filtering; existing entry
    points and CLI are unchanged.
  - `validate_orchestrator_state.py` gains additive remediation-cycle invariant checks; the
    existing return contract (list of error strings) is unchanged.
- **Data flow or validation adjustments:** Memory file content is read during source
  enumeration for files under `.claude/agent-memory/` to decide inclusion. Orchestrator-state
  validation gains cycle-level invariant checks when a `remediation_loop` is present.
- **Logging/telemetry updates:** None.
- **Migration or backfill needs:** None. Existing checkpoints without a `remediation_loop`
  continue to validate unchanged.

## Test Strategy

- **Primary toolchain (Python).** This feature changes Python and Markdown. Run the Python
  toolchain in order: Black, Ruff, Pyright, Pytest with the repository's existing coverage
  policy (85% line / 75% branch; no threshold change). Command:
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- **Extension toolchain (conditional).** The extension's Jest / Prettier / ESLint / tsc
  toolchain runs only if TypeScript files change. This feature is expected to be Python +
  Markdown only; verify that no `.ts`/`.tsx` files are modified before deciding the extension
  toolchain is not required.
- **Regression tests to add or update:**
  - Scope parser unit tests (general / repo / absent / missing-frontmatter / malformed /
    unrecognized).
  - Push-down filter tests (include general, exclude repo, exclude unmarked, non-memory files
    unaffected).
  - Resource-contract parity: agent-memory exemption plus the every-non-index-bundled-memory-is-general
    assertion and the MEMORY.md-index-is-repo assertion (no `scope: repo` non-index memory
    remains in the bundle per Option B).
  - Orchestrator-state validator: positive and negative cases for each of the three invariants,
    plus a no-`remediation_loop` backward-compatibility case.
- **Invariant validation tests:** The existing byte-identical-script test and the
  `settings.local.json` exclusion test must remain green.
- **Edge cases and negative scenarios:** Empty/whitespace `plan_path`; `execution_status` in
  the blocked set with non-clear preflight; `exit_condition_met == true` with non-zero
  `blocking_count`; memory file with no frontmatter; memory file with frontmatter but no
  `scope` leaf.
- **Error handling and logging verification:** Validator returns explicit error strings for
  each violated invariant; the scope parser fails safe to `repo` on malformed input rather than
  raising.
- **Coverage impact and targets for changed lines/modules:** Changed lines must meet the
  existing 85% line / 75% branch policy with no regression on changed lines. The new validator
  helper and the scope parser must have positive and negative test coverage.
- **Toolchain commands to run (format -> lint -> type-check -> test):**
  `poetry run black .` -> `poetry run ruff check .` -> `poetry run pyright` ->
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- **Manual validation steps (if required):** None required beyond the automated toolchain.

## Acceptance Criteria

- [x] Push-down copies only `scope: general` memories under `.claude/agent-memory/`; `scope: repo` and unmarked memories are excluded.
- [x] Fail-safe default verified: a memory with no `scope` frontmatter (or malformed/unrecognized frontmatter) is treated as `repo` and excluded.
- [x] Files outside `.claude/agent-memory/` are copied verbatim and are unaffected by the scope filter.
- [x] An `re`-based frontmatter scope parser is added (no PyYAML dependency introduced).
- [x] The two main push-down script copies (`scripts/dev_tools/...` and `extensions/drm-copilot/resources/scripts/dev_tools/...`) remain byte-identical and both carry the scope filter.
- [x] The extension template (`resources/templates/push_down_claude_customizations.py`) carries the scope filter and its source-root resolves to the bundled `claude-customizations/` directory, aligned with the codex template.
- [x] The bundled `.claude/agent-memory` copy contains only `scope: general` memories plus the orchestrator `MEMORY.md` index (which remains `scope: repo` and is never pushed); `orchestrator/feedback_policy_compliance_not_optional.md` is retained as `scope: general`.
- [x] Repo-specific memories are physically removed from the bundle and relocated to the root `.claude/agent-memory` folder (gitignored / local-only); the `prd-feature/` and `task-researcher/` agent-memory subdirectories are removed from the bundle entirely.
- [x] Six domain-neutral orchestration memories are present in the bundle as `scope: general`, with repository-neutral wording per Research B section 7, and the bundled orchestrator `MEMORY.md` index references them.
- [x] The resource-contract parity test exempts `.claude/agent-memory/**` from byte-identical mirroring and asserts every NON-index bundled memory carries `scope: general` and every bundled `MEMORY.md` index carries `scope: repo`.
- [x] `validate_orchestrator_state.py` enforces, for each remediation cycle: `plan_path` is a non-empty string; `execution_status` in `{in_progress, complete, failed}` requires `preflight.final_status == 'clear'`; `exit_condition_met == true` requires `blocking_count == 0`.
- [x] The validator changes are backward compatible: a checkpoint with no `remediation_loop` validates exactly as before (regression test passes).
- [x] A prose rule `orchestrator-state.md` documents the three invariants and is mirrored byte-identically into root and bundle; it states the snapshot schema's foreign `$id` must not be copied verbatim.
- [x] The type-only / interface-only module coverage exemption is documented in `general-unit-test.md`, `rules/python.md`, `rules/typescript.md`, and `rules/csharp.md`, mirrored byte-identically into root and bundle.
- [x] Root coverage policy is unchanged (85% line / 75% branch, tier system retained); no `coverage.md`, `diff-cover` gate, 6-step toolchain, or property-test downgrade is introduced.
- [x] Every non-memory `.claude` change is applied to both root and bundle as byte-identical mirrors (parity test passes).
- [x] The full Python toolchain (Black, Ruff, Pyright, Pytest at 85% line / 75% branch) passes with no coverage regression on changed lines; the extension Jest/Prettier/ESLint/tsc toolchain runs only if TypeScript files change.

## Definition of Done

Distinct from the per-criterion acceptance checklist, this feature is done when:

- [ ] All acceptance criteria above are checked off with verifying evidence.
- [ ] Structure matches this spec; no rejected snapshot artifacts (`coverage.md`, `diff-cover` gate, JSON Schema with foreign `$id`, 6-step toolchain) are present.
- [ ] The byte-identical-script invariant and the non-memory mirror-parity invariant are validated by passing tests.
- [ ] The push-down filter, scope parser, and validator invariants have positive and negative test coverage; changed lines meet the 85% / 75% policy with no regression.
- [ ] The full toolchain pass (format -> lint -> type-check -> test) completes cleanly in a single pass.
- [ ] Evidence artifacts are written only under `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/<kind>/`.
- [ ] Three follow-up GitHub issues are opened for the cross-language items in Decision L (see below).
- [ ] Spec and user-story acceptance criteria are reconciled and any non-AC documentation (feature folder index) is updated.

## Out of Scope / Follow-up Issues

The following cross-language items are out of scope for this feature and must be filed as
separate GitHub issues (Decision L). They are not implemented here:

1. New-code delta coverage gate for TypeScript, C#, and PowerShell (the Python `diff-cover`
   new-code concept generalized to other languages).
2. Test-purity hooks for TypeScript and C# (analogous to the existing Python and PowerShell
   test-purity hooks).
3. Batch-budget hooks for TypeScript and C# (analogous to the existing Python and PowerShell
   batch-budget hooks).

The type-only / interface-only module coverage exemption is the only cross-language item in
scope for this feature and is implemented in S6.

## Seeded Test Conditions (from potential)

- [ ] Unit: scope frontmatter parser (general, repo, absent, malformed, unrecognized).
- [ ] Unit: push-down filter excludes repo/unmarked memories, includes general memories.
- [ ] Unit: resource-contract parity exemption for agent-memory plus all-bundled-memories-are-general and MEMORY.md-index-is-repo assertions.
- [ ] Unit: `validate_orchestrator_state.py` new invariants (positive and negative cases) plus no-`remediation_loop` backward-compatibility case.
- [ ] Regression: existing push-down behavior (settings.local.json exclusion, byte-identical copy of non-memory files) unchanged.
