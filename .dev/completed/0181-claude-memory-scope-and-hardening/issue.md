# claude-memory-scope-and-hardening (Issue #181)

- Date captured: 2026-06-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/claude-memory-scope-and-hardening/ (Issue #181)

- Issue: #181
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/181
- Last Updated: 2026-06-13
- Work Mode: full-feature

## Problem / Why

The extension ships a bundled copy of `.claude` to consumer repositories via the
push-down mechanism. Today the contract is that every `.claude` file mirrors into the
bundled copy. This is wrong for `.claude/agent-memory`: some agent memories are specific
to this repository (the drm-copilot extension itself) and have no value — and can be
misleading — when pushed to consumer repositories. Only general memories that apply to
any repository should be distributed.

Separately, a hardened snapshot of the Claude architecture from another repository
(`artifacts/.claude`) contains additive hardening that this repository lacks: explicit
orchestrator-state invariants and a type-only-module coverage exemption. It also contains
six domain-neutral orchestration memories worth promoting. Coverage-threshold changes in
the snapshot were reviewed and intentionally rejected (root tier-based 85%/75% policy is
retained).

## Proposed Behavior

1. Deterministic memory differentiation: a `metadata.scope: general | repo` frontmatter
   field on each agent memory. The push-down filter copies a memory only when
   `scope: general`; an absent or unrecognized value defaults to `repo` (fail-safe so
   repo-specific memories never leak). `MEMORY.md` index files are `scope: repo`.
2. The push-down scripts (root `scripts/dev_tools/`, bundled `resources/scripts/dev_tools/`,
   and the `resources/templates/` wrapper) apply the scope filter. The template
   source-root resolution bug (uses cwd instead of the bundled customizations dir) is
   fixed in the same change.
3. Per Option B, the bundled `.claude/agent-memory` copy retains only `scope: general`
   memories plus the orchestrator `MEMORY.md` index (which stays `scope: repo` and is never
   pushed). Repo-specific memories are physically removed from the bundle and relocated to the
   root `.claude/agent-memory` folder (gitignored / local-only); the `prd-feature/` and
   `task-researcher/` agent-memory subdirectories are removed from the bundle entirely.
4. Additive hardening applied to both root `.claude` and the bundled copy:
   - Orchestrator-state invariants (prose rule + `validate_orchestrator_state.py`):
     `plan_path` non-empty per remediation cycle; execution status may not leave
     `not_started` unless preflight `final_status == clear`; `exit_condition_met == true`
     requires `blocking_count == 0`.
   - Type-only / interface-only module coverage exemption clarified in the general and
     per-language test rules.
5. Six domain-neutral orchestration memories promoted as `scope: general`.
6. Tests updated: push-down unit tests assert scope filtering and the fail-safe default;
   the resource-contract parity test exempts `agent-memory` from byte-identical mirroring
   and instead asserts that every NON-index bundled memory carries `scope: general` and every
   `MEMORY.md` index carries `scope: repo`.

Out of scope (routed to separate GitHub issues): generalizing the new-code delta coverage
gate, test-purity hooks, and batch-budget hooks to TypeScript and C#.

## Acceptance Criteria (early draft)

- [ ] Push-down copies only `scope: general` memories; `scope: repo` and unmarked memories are excluded.
- [ ] Fail-safe default verified: a memory with no `scope` frontmatter is treated as `repo` and excluded.
- [ ] The bundled `.claude/agent-memory` copy contains only `scope: general` memories plus the orchestrator `MEMORY.md` index (which remains `scope: repo` and is never pushed).
- [ ] Repo-specific memories are physically removed from the bundle and relocated to the root `.claude/agent-memory` folder (gitignored / local-only); the `prd-feature/` and `task-researcher/` agent-memory subdirectories are removed from the bundle entirely.
- [ ] Resource-contract parity test exempts `agent-memory` and asserts every NON-index bundled memory carries `scope: general` and every `MEMORY.md` index carries `scope: repo`.
- [ ] Orchestrator-state invariants enforced by `validate_orchestrator_state.py` and documented as a rule in both root and bundle.
- [ ] Type-only module coverage exemption documented in general and per-language test rules (root and bundle).
- [ ] Six generalized memories present as `scope: general` in the bundle.
- [ ] Root coverage policy unchanged (85% line / 75% branch, tier system retained); no `coverage.md` or `diff-cover` gate introduced.
- [ ] Full toolchain (Black, Ruff, Pyright, Pytest; Prettier, ESLint, tsc, Jest for the extension) passes; no coverage regression on changed lines.
- [ ] Three follow-up GitHub issues opened for the cross-language generalization items.

## Constraints & Risks

- The two main push-down script copies must remain byte-identical (enforced by tests).
- Every non-memory `.claude` change must be mirrored into the bundled copy (parity test).
- `.claude/agent-memory` is gitignored at root; committed general memories live in the bundle.
- The orchestrator-state schema from the snapshot references a foreign `$id` and cannot be copied verbatim; invariants are re-expressed as prose + validator logic.

## Test Conditions to Consider

- [ ] Unit: scope frontmatter parser (general, repo, absent, malformed).
- [ ] Unit: push-down filter excludes repo/unmarked memories, includes general memories.
- [ ] Unit: resource-contract parity exemption for agent-memory + every-non-index-bundled-memory-is-general and MEMORY.md-index-is-repo assertions.
- [ ] Unit: `validate_orchestrator_state.py` new invariants (positive and negative cases).
- [ ] Regression: existing push-down behavior (settings.local.json exclusion, byte-identical copy of non-memory files) unchanged.

## Next Step

- [ ] Promote to GitHub issue (refactor template)
- [ ] Create active feature folder from the template