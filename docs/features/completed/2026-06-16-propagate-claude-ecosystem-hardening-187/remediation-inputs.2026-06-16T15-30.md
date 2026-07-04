# Remediation Inputs: propagate-claude-ecosystem-hardening (#187)

- **Entry timestamp:** 2026-06-16T15-30
- **Feature folder:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187`
- **Base branch:** `main` (merge-base `c903b1f9531a164a4470524171b17ef63759ee93`)
- **Head:** `feature/propagate-claude-ecosystem-hardening-187` @ `24353b0bf4527092832cdfaea81c37b0367614c5`
- **Trigger:** Policy audit contains one Major FAIL (500-line hard-limit violation). All 18 acceptance criteria PASS; this remediation addresses code-quality policy compliance, not unmet ACs.

## Source Audit Artifacts (findings origin)

- `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T15-30.md` (Section 2.3, Section 8, Section 10)
- `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/code-review.2026-06-16T15-30.md` (Findings Table: 1 Major, 2 Minor)
- `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/feature-audit.2026-06-16T15-30.md` (Summary: readiness NEEDS REVISION)

## Blocking Findings (must fix)

### F1 — Major: production file exceeds 500-line hard limit

- **File:** `scripts/dev_tools/validate_orchestrator_state.py` (currently 505 lines; base was 416, +89 added by this feature).
- **Policy violated:** `.claude/rules/general-code-change.md` line 49 — "No production code, test code, or reusable script file may exceed 500 lines."
- **Expected behavior after fix:** the file is < 500 lines and `validate_orchestrator_state_text(text, *, require_complete=False) -> list[str]` retains its exact public signature and behavior (no functional change). Extract one cohesive validator group into a sibling module — preferred: move `_validate_human_interaction` plus its four module constants (`HUMAN_INTERACTION_KEY`, `HUMAN_INTERACTION_REQUIREMENTS_KEY`, `HUMAN_INTERACTION_RESPONSE_ENUM`, `HUMAN_INTERACTION_EXCEPTION_RESPONSE`) into a new module (for example `scripts/dev_tools/_orchestrator_state_human_interaction.py`) and import the helper into `validate_orchestrator_state.py`. Alternatively extract the remediation-cycle helpers. Keep all error strings byte-identical.
- **Verification commands:**
  - `wc -l scripts/dev_tools/validate_orchestrator_state.py` (and any new sibling module) — each must be < 500.
  - `poetry run black --check scripts/dev_tools/ tests/scripts/dev_tools/`
  - `poetry run ruff check scripts/dev_tools/ tests/scripts/dev_tools/`
  - `poetry run pyright scripts/dev_tools/validate_orchestrator_state.py`
  - `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing` — 25 pass, module line >= 85%, branch >= 75%.

## Non-Blocking Findings (fix in the same pass, recommended)

### F2 — Minor: dangling schema reference in documentation/help

- **Files:** `.claude/skills/orchestrate/SKILL.md` (line 53) and `.claude/hooks/validate-orchestrator-output.ps1` (function comment-based help, lines 60-83) reference `.claude/schemas/orchestrator-state.schema.json`, which does not exist in the repository.
- **Expected behavior after fix:** prose states that the `human_interaction` invariants are enforced by `scripts/dev_tools/validate_orchestrator_state.py` and `Test-HumanInteractionShape`, not by an imported schema file — OR a repo-local schema is added that complies with the foreign-schema policy in `.claude/rules/orchestrator-state.md` (no `drmoisan.github.io/mix-calculator/` `$id`, repo-local required-field set). Do not copy the foreign schema verbatim.
- **Verification commands:**
  - `grep -rn "orchestrator-state.schema.json" .claude/` — references must resolve to an existing file or be reworded.
  - If any `.claude/` file is edited, re-verify mirror parity: `cmp <canonical> <extensions/.../canonical>` and `cmp <canonical> <packages/mcp-server/.../canonical>`.

## Do Not Do (constraints)

- Do not change the public signature or runtime behavior of `validate_orchestrator_state_text`; this is a structural split only.
- Do not weaken, remove, or reword any validator error string to make the split easier.
- Do not weaken any policy document under `.claude/rules/` or `.github/instructions/` to dodge the 500-line limit.
- Do not copy `schemas/orchestrator-state.schema.json` verbatim from the source tree (foreign-schema policy).
- Do not propagate `settings.local.json` or `agent-memory/**`.
- Do not introduce new dependencies, CLI commands, services, telemetry, or feature flags (Non-Goals in `user-story.md`).
- Do not skip mirror parity: any edited canonical `.claude/` file must remain byte-identical in both bundled mirrors.
- Do not narrow scope; the remediation must leave all 18 acceptance criteria PASS.

## Expected Cycle Artifacts

Per `remediation-handoff-atomic-planner`, this cycle must produce five artifacts:

1. `remediation-inputs.2026-06-16T15-30.md` (this file).
2. `remediation-plan.2026-06-16T15-30.md` (atomic-planner authors; entry timestamp).
3. `code-review.<exit-ts>.md` (feature-review at cycle exit).
4. `feature-audit.<exit-ts>.md` (feature-review at cycle exit).
5. `policy-audit.<exit-ts>.md` (feature-review at cycle exit).

Exit gate: `blocking_count == 0` (zero FAIL findings) closes the loop.
