# Branch Change-Set File List (AC12 Verification)

Timestamp: 2026-08-20T14-48
Task: [P11-T7]
Issue: #486
Branch: `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`

The combined list below is the union of the uncommitted change set and the committed branch diff. The uncommitted status output is required because this plan carries no commit task, so the new modules are untracked when the assertion runs and `git diff --name-only main...HEAD` alone would list neither.

## Command 1

Command: `git status --porcelain --untracked-files=all`

EXIT_CODE: 0

```
 M .claude/skills/atomic-plan-contract/SKILL.md
 M docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md
 M extensions/drm-copilot/jest.config.cjs
 M extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts
 M extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts
 M extensions/drm-copilot/src/mcp-tools.ts
 M extensions/drm-copilot/src/repo-automation-service-contract.ts
 M scripts/dev_tools/validate_orchestration_artifacts.py
?? .claude/rules/plan-acceptance-gates.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/existing-plan-error-strings.2026-08-20T11-40.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/phase0-instructions-read.2026-08-20T11-26.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-format.2026-08-20T11-27.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-lint.2026-08-20T11-27.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-test.2026-08-20T11-29.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-typecheck.2026-08-20T11-28.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-format.2026-08-20T11-32.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-lint.2026-08-20T11-33.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-test.2026-08-20T11-35.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-typecheck.2026-08-20T11-34.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/parity-fixture-run.2026-08-20T14-32.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/post-change-gate-detection.2026-08-20T12-14.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/pre-change-no-gate-detection.2026-08-20T11-38.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/python-existing-plan-validator.2026-08-20T12-13.md
?? docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/typescript-existing-validator.2026-08-20T14-05.md
?? extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts
?? extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts
?? extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts
?? extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts
?? extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts
?? extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts
?? extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts
?? extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts
?? extensions/drm-copilot/test/lib/validate/plan-gate-repository.test.ts
?? extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts
?? extensions/drm-copilot/test/mcp-plan-gate-warning-projection.test.ts
?? scripts/dev_tools/plan_gate_commands.py
?? scripts/dev_tools/plan_gate_discrimination.py
?? tests/scripts/dev_tools/test_plan_gate_commands.py
?? tests/scripts/dev_tools/test_plan_gate_discrimination_context.py
?? tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py
?? tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py
?? tests/scripts/dev_tools/test_plan_gate_parity.py
?? tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py
```

Note: this listing was taken before the Phase 12 final-QC evidence artifacts were written, so it does not include them. The AC12 assertion is unaffected: no Phase 12 task modifies `.claude/hooks/validate-planner-output.ps1`.

## Command 2

Command: `git diff --name-only main...HEAD`

EXIT_CODE: 0

```
docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/issue.md
docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md
docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/research/2026-08-17T16-00-unfalsifiable-acceptance-gates-486-research.md
docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md
docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/user-story.md
docs/features/potential/promoted/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans.md
```

## Required Assertions

| Assertion | Result |
| --- | --- |
| Combined list contains `scripts/dev_tools/plan_gate_discrimination.py` | PRESENT (untracked, listed by command 1) |
| Combined list contains `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | PRESENT (untracked, listed by command 1) |
| Combined list contains `.claude/hooks/validate-planner-output.ps1` | ABSENT |

Absence verification commands and results:

- `git status --porcelain --untracked-files=all | grep -c -F "validate-planner-output.ps1"` printed `0` and exited 1 (grep's no-match exit).
- `git diff --name-only main...HEAD | grep -c -F "validate-planner-output.ps1"` printed `0` and exited 1 (grep's no-match exit).

Output Summary: Both required modules are present in the combined change set and `.claude/hooks/validate-planner-output.ps1` is absent from both the uncommitted status output and the committed branch diff. Spec AC12 is satisfied. The only `.claude/` files this branch touches are `.claude/rules/plan-acceptance-gates.md` (new, authorized by [P11-T1] through [P11-T4]) and `.claude/skills/atomic-plan-contract/SKILL.md` (modified, authorized by [P11-T5] and [P11-T6]); no file under `.github/instructions/` and no other file under `.claude/rules/` was modified.
