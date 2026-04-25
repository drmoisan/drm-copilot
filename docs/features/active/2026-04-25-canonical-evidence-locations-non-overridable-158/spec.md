# 2026-04-25-canonical-evidence-locations-non-overridable — Spec

- **Issue:** #158
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-25T14-37
- **Status:** Draft
- **Version:** 0.1

## Overview

This feature removes all paths by which any orchestrator, planner, executor, or upstream prompt can direct agent-generated evidence files to non-canonical `artifacts/` sub-paths. Enforcement is applied at four layers simultaneously: skill definitions (Part A), agent contract sections (Part B), a PreToolUse tool-layer hook (Part C), and a standalone Python validator script (Part D). The canonical path scheme `<FEATURE>/evidence/<kind>/` is not changed; this feature makes it non-overridable.


## Behavior

**Part A — Skill reconciliation (9 files)**

`evidence-and-timestamp-conventions/SKILL.md` is updated with a `## Non-Overridable Authority` section that lists all 6 canonical evidence sub-paths (`baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, `other/`, `remediation-baseline/`) and states explicitly that no delegation prompt, plan, or upstream agent may override the `<FEATURE>/evidence/<kind>/` location.

The three QA-gate skills (`python-qa-gate`, `csharp-qa-gate`, `powershell-qa-gate`) and three invoke-engineer skills (`invoke-python-engineer`, `invoke-csharp-engineer`, `invoke-powershell-engineer`) currently reference the non-canonical paths `artifacts/evidence/baseline/<timestamp>/` and `artifacts/evidence/post-change/<timestamp>/`. These are corrected to `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/` respectively. Each corrected section ends with a canonical-authority pointer line: `This location is canonical per evidence-and-timestamp-conventions and is not overridable.`

`orchestrate/SKILL.md` is updated with a `## Evidence Location Authority` section inserted after `## Delegation Model`. This section contains the explicit allow-list of `artifacts/`-rooted sub-paths that agents may write to (`artifacts/orchestration/`, `artifacts/research/`, `artifacts/pr_context`, `artifacts/reviews/`, `artifacts/status/`, coverage artifact roots) and states that all other `artifacts/` sub-paths are forbidden for evidence output.

`atomic-plan-contract/SKILL.md` is updated with a non-overridable clause stating that no plan task may specify a non-canonical evidence path, and that if a delegation prompt supplies such a path the planner must reject it and substitute the canonical path before the plan is approved.

**Part B — Agent invariants (12 files)**

All 12 agent definition files under `.claude/agents/` receive a `## Evidence Location Invariant` section with the following behavior contract: if a delegation prompt, plan, or caller instruction specifies a non-canonical path (for example `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`), the agent ignores that instruction, writes to the canonical path, and records the override attempt in session output as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.

`feature-review.md` additionally receives an instruction to scan the branch diff for any files written under the forbidden sub-paths during the policy-audit phase. If any are found, the agent records a FAIL finding in the policy-audit artifact under the heading `## Evidence Location Compliance` with the exact file paths and their canonical replacement paths.

**Part C — PreToolUse hook**

A new file `.claude/hooks/enforce-evidence-locations.ps1` is created, following the `check-python-test-purity.ps1` structural pattern (`[CmdletBinding()]`, pure helper functions testable via dot-source, main entrypoint reading `$env:CLAUDE_TOOL_INPUT`). The hook reads the `file_path` field from the tool input JSON. If the path begins with `artifacts/` and does not match an allowed `artifacts/` sub-prefix, the hook writes a block decision JSON to stdout and exits 0. If the path is not under `artifacts/` or matches an allowed prefix, the hook writes an allow decision and exits 0. Hard failures exit 1 (matching the `validate-bash.ps1` pattern).

Forbidden `artifacts/` prefixes blocked by the hook: `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, `artifacts/regression-testing/`, `artifacts/post-change/`.

Allowed `artifacts/` prefixes that pass through: `artifacts/orchestration/`, `artifacts/research/`, `artifacts/pr_context`, `artifacts/reviews/`, `artifacts/status/`, `artifacts/python/`, `artifacts/pester/`, `artifacts/csharp/`.

Block message format (the `reason` field): `EVIDENCE_LOCATION_BLOCKED: <path> is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead.`

`.claude/settings.json` is updated to register the hook under the existing `PreToolUse` entry for Write and Edit tool events.

A Pester v5 self-test `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` covers the five required cases.

**Part D — Standalone Python validator**

A new file `scripts/dev_tools/validate_evidence_locations.py` is created following the `validate_orchestration_artifacts.py` pattern. It accepts an optional `--root` argument defaulting to the repository root. A pure `find_forbidden_paths(root: Path) -> Iterator[tuple[Path, str]]` generator walks the tree and yields `(path, canonical_suggestion)` for every file found under a forbidden prefix. `main()` collects the results, prints each violation with its canonical replacement, and exits with code 1 if any violations are found, or code 0 if the tree is clean. The script uses the Python standard library only (no new packages).

`feature-review.md` is updated to reference `validate_evidence_locations.py` as a required policy-audit step: the feature-review agent must invoke the validator against the branch checkout and record its output (pass or fail) in the policy-audit artifact.

A pytest test file `tests/scripts/dev_tools/test_validate_evidence_locations.py` covers the two required cases (clean tree exits 0; seeded violation exits 1 with canonical replacement printed). No temporary files are created by the tests.


## Inputs / Outputs

- **Python validator CLI inputs**:
  - `--root <path>` (optional): root directory to walk; defaults to the repository root resolved from the script's location.
- **Python validator outputs**:
  - stdout: one line per violation in the format `VIOLATION: <path> — use <canonical_suggestion> instead`.
  - exit code 0 if no violations found; exit code 1 if one or more violations found.

- **Hook inputs** (via `$env:CLAUDE_TOOL_INPUT` JSON):
  - `file_path: string` — the path of the file being written or edited.
  - `content: string` (Write tool) or `new_string: string` (Edit tool) — not inspected; only `file_path` is evaluated.
- **Hook outputs** (stdout JSON):
  - `{ "decision": "block", "reason": "EVIDENCE_LOCATION_BLOCKED: <path> is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead." }` on a forbidden path.
  - `{ "decision": "allow" }` on an allowed path.
  - Exit code 0 for both block and allow decisions. Exit code 1 on hard failure (malformed input).

- **Skill and agent file changes**: text-only edits to `.claude/skills/*.md` and `.claude/agents/*.md`; no runtime artifacts produced.

- **Settings update**: `.claude/settings.json` gains one additional hook entry under the existing `PreToolUse[Write|Edit]` array.

- **Config keys and defaults**: none introduced; all hook configuration is in `settings.json`.

- **Versioning / backward-compatibility**: skill and agent text changes are backward-compatible; existing evidence written to canonical paths is unaffected. No API surface change.

## API / CLI Surface

**Validator script (`validate_evidence_locations.py`)**

```
poetry run python scripts/dev_tools/validate_evidence_locations.py [--root <path>]
```

- `--root <path>`: optional; directory to scan. Defaults to the repository root.
- Exit code 0: no forbidden paths found.
- Exit code 1: one or more forbidden paths found; each printed to stdout with canonical replacement.

Example — clean tree:
```
$ poetry run python scripts/dev_tools/validate_evidence_locations.py
# exits 0, no output
```

Example — violation present:
```
$ poetry run python scripts/dev_tools/validate_evidence_locations.py
VIOLATION: artifacts/baselines/2026-04-25T14-37/baseline.md — use <FEATURE>/evidence/baseline/ instead.
# exits 1
```

**PreToolUse hook (`enforce-evidence-locations.ps1`)**

Invoked by Claude Code via `.claude/settings.json` for Write and Edit tool events:
```json
{
  "type": "command",
  "command": "pwsh -NoProfile -File .claude/hooks/enforce-evidence-locations.ps1"
}
```

Input: `CLAUDE_TOOL_INPUT` environment variable containing JSON with a `file_path` field.

Output (stdout JSON, exit 0):
```json
{ "decision": "block", "reason": "EVIDENCE_LOCATION_BLOCKED: artifacts/baselines/foo.md is not a canonical evidence location. Use <FEATURE>/evidence/baseline/ instead." }
```
or:
```json
{ "decision": "allow" }
```

**No new public API surface** is introduced for skills or agent files; those are plain Markdown text changes.

## Data & State

- **Data flow**: The PreToolUse hook receives the proposed file path from Claude Code via `$env:CLAUDE_TOOL_INPUT` before any write occurs. The hook evaluates the path against the forbidden and allowed prefix lists and returns a block or allow decision to Claude Code. No data is persisted by the hook itself.

- **Validator data flow**: The validator script reads the filesystem tree under `--root` at invocation time. It yields `(path, canonical_suggestion)` pairs for files whose paths match a forbidden prefix. No state is written; all output is to stdout.

- **State changes introduced**: `.claude/settings.json` is modified to register the new hook. Skill and agent Markdown files are modified with new sections. No database, cache, or session state is affected.

- **Data transformations**: None. The hook and validator perform path prefix matching only; they do not transform file contents.

- **Caching**: None. The hook and validator are stateless on each invocation.

- **Migration / backfill**: This feature does not migrate pre-existing non-canonical evidence files. Files already written to non-canonical paths in historical commits are not affected and are not required to be moved.

## Constraints & Risks

- Must not change the canonical path scheme itself (`<FEATURE>/evidence/<kind>/` is the answer).
- Must not migrate historical non-canonical evidence from other branches or repos.
- Must not change `artifacts/orchestration/`, `artifacts/research/`, or feature-audit report paths.
- Hook script must require no external dependencies beyond the language runtime on PATH.


## Implementation Strategy

**Scope (what changes):**

- Part A: 9 Markdown skill files under `.claude/skills/` — text edits only.
- Part B: 12 Markdown agent files under `.claude/agents/` — text edits only.
- Part C: 1 new PowerShell hook `.claude/hooks/enforce-evidence-locations.ps1`; 1 new Pester v5 test `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`; 1 JSON edit to `.claude/settings.json`.
- Part D: 1 new Python script `scripts/dev_tools/validate_evidence_locations.py`; 1 new pytest file `tests/scripts/dev_tools/test_validate_evidence_locations.py`; 1 Markdown text edit to `feature-review.md` (or `feature-review-workflow` SKILL.md).

**Implementation ordering**: Part A before Part B (skills must be correct before agents reference them); Part B before Part C (agent-level contracts before tool-layer enforcement adds defense in depth); Part C before Part D (hook operational before validator wired into review step).

**New files / functions:**
- `.claude/hooks/enforce-evidence-locations.ps1`: `function Get-EvidenceLocationBlockDecision`, `function Test-EvidenceLocationForbidden`, `function Invoke-EvidenceLocationDecision`, entrypoint block reading `$env:CLAUDE_TOOL_INPUT`.
- `scripts/dev_tools/validate_evidence_locations.py`: `find_forbidden_paths(root: Path) -> Iterator[tuple[Path, str]]`, `main()`.
- Test files as specified above.

**Dependency changes:** None. All changes use existing runtimes (PowerShell 7 via `pwsh`, Python 3 via `poetry run python`).

**Logging / telemetry:** The hook emits structured JSON to stdout on every invocation (allow or block). The validator prints one line per violation to stdout. No telemetry beyond these outputs is added.

**Rollout plan:** No feature flags or staged deploys. Changes take effect immediately on commit. The hook is active for all Write and Edit tool events after `.claude/settings.json` is updated. The validator can be run manually at any time and is referenced from the feature-review step.

## Definition of Done

- [x] `evidence-and-timestamp-conventions/SKILL.md` contains the `## Non-Overridable Authority` section (verified by grep for section heading).
- [x] All 6 QA-gate and invoke-engineer skills reference `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/` paths and include the canonical-authority pointer line (verified by grep; `artifacts/evidence/` must not appear in these files).
- [x] `orchestrate/SKILL.md` contains `## Evidence Location Authority` section with the allow-list (verified by grep).
- [x] `atomic-plan-contract/SKILL.md` contains the non-overridable clause for plan tasks (verified by grep).
- [x] All 12 agent files contain `## Evidence Location Invariant` section (verified by grep across `.claude/agents/`).
- [x] `feature-review.md` contains the diff-scan FAIL-finding instruction (verified by grep).
- [x] `enforce-evidence-locations.ps1` exists and the Pester self-test passes all 5 cases (verified by PoshQC test run).
- [x] `.claude/settings.json` registers `enforce-evidence-locations.ps1` under PreToolUse for Write and Edit (verified by JSON inspection).
- [x] `validate_evidence_locations.py` exists and pytest passes both test cases (clean tree exits 0; seeded violation exits 1 with replacement printed) — verified by pytest run.
- [x] `feature-review.md` references the validator as a required policy-audit step (verified by grep).
- [ ] All Python toolchain steps pass in a single clean pass: Black → Ruff → Pyright → Pytest.
- [x] PoshQC toolchain steps pass in a single clean pass: format → analyze → Pester.

## Seeded Test Conditions (from potential)
- [x] Hook self-test: blocked path exits 1 with correct stderr message.
- [x] Hook self-test: allowed orchestration path exits 0.
- [x] Hook self-test: allowed research path exits 0.
- [x] Hook self-test: canonical evidence path exits 0.
- [x] Hook self-test: regular source-code path exits 0.
- [x] Validator: clean tree exits 0; seeded violation exits 1 with canonical replacement printed.
