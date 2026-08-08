# Python repr quote-selection divergence (Potential)

- Date captured: 2026-08-07
- Author: atomic-executor (remediation cycle 1, feature 2026-08-07-parallel-schema-validators-444, issue #444)
- Status: Draft

## Problem / Why

Every TypeScript port of Python's `repr`-style error-string formatting always single-quotes
string values. Python's `repr` switches to double quotes when the value contains a single
quote (and no double quote). This is a repo-wide implementation defect, not limited to the
parallel-orchestration schema validators.

Example: for `"mode": "it's open"`, Python emits `found: "it's open".` and the TypeScript port
emits `found: 'it\'s open'.` The two runtimes diverge on the exact error string whenever an
input value contains a single quote.

Verified occurrences, by file and line (function definition line of the local `pythonRepr`
implementation):

1. `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts:112-132`
2. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:63`
3. `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts:52`
4. `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts:87`
5. `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts:133`

## Proposed Behavior

Each local `pythonRepr` implementation should select the enclosing quote character the way
Python's `repr` does: prefer a single quote, but switch to a double quote when the string
contains a single quote and does not contain a double quote (and fall back to Python's own
tie-breaking rule when the string contains both).

## Acceptance Criteria (early draft)

- [ ] All five listed `pythonRepr` implementations reproduce Python's quote-selection rule.
- [ ] A shared, single implementation is considered instead of five independent copies, to
      avoid re-introducing the divergence at a sixth call site.
- [ ] Regression fixtures cover a value containing a single quote, a value containing a double
      quote, and a value containing both.

## Constraints & Risks

- **This entry is documentation-only.** No code change accompanies this entry.
- Fixing this defect requires modifying validator source under `src/lib/validate/`, four of
  the five occurrences (`epic-planner-state-core.ts`, `epic-orchestrator-state-resolution.ts`,
  `codex-topology-resolver.ts`, `orchestrator-state-codex-model-routing.ts`) are epic validators
  (`_epic_*` / `src/lib/validate/epic-*` family or codex-topology/model-routing validators
  consumed by the epic surface), and the remediation cycle that captured this defect
  (`docs/features/active/2026-08-07-parallel-schema-validators-444`, issue #444) is forbidden
  from modifying epic validators. Remediation belongs to a separately scheduled feature.
- Changing error-string formatting is a behavior change for every consumer of these validators'
  error strings (CLI output, MCP tool responses, any test asserting exact error text), so the
  fix must be scoped and reviewed independently rather than folded into an unrelated change.

## Test Conditions to Consider

- [ ] Unit coverage: single-quote-only string, double-quote-only string, string containing both,
      string containing neither.
- [ ] Regression fixtures per affected file confirming the corrected quote character matches
      Python's `repr` output for the same input.
- [ ] Cross-runtime parity check (Python vs. TypeScript) for each of the five call sites.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
