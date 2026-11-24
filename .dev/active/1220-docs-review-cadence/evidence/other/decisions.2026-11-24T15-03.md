# Decisions (plan revision 3, before P2-T3)

Timestamp: 2026-11-24T15-03
Command: read plan.2026-11-23T00-39.md `## Open Questions / Notes` (revision 3 decisions); env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan .dev/active/1220-docs-review-cadence/plan.2026-11-23T00-39.md
EXIT_CODE: 0
Output Summary: single-pass preflight of P2-T3 to P4-T6 returned PREFLIGHT: ALL CLEAR with no in-place fix; plan validation passed; the three revision-3 decisions below are repeated with a clock-read stamp (autonomous mode, recommended option).

## Decisions

1. The upstream tests of #1221 and #1222 that assert behavior P2-T3 and P3-T2 change are edited in those tasks, each with its stated reason: `DocsValidateCommands.Families.Tests.ps1` (P2-T3), `docs-authoring-roles.FamilyTemplates.Tests.ps1` and `DocsAuthorPageTemplates.Acceptance.Tests.ps1` (P3-T2).
2. The `docs-authoring-roles.Templates.Tests.ps1` body-rule test stays on the 8 `Templates` members, because `alerts-catalog` is a reference template without a generated marker (pinned by `gives alerts-catalog no generated marker`).
3. The phase gates P2-T4 and P3-T3 run the targeted union of their task test selections under the owner instruction dated 2026-11-23 ("The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests."). This is a one-off waiver recorded in each gate artifact; it is not a process-reduction ledger entry and no policy file is edited.

## Preflight sweep (test tree)

Searched `tests/` for `docs-complete`, `'validate'`, `Invoke-DocsValidateCommand`, `CallLog`, `ReadBytesFailure`, `required_families`, `last_reviewed`, `review_due`, `FieldOrder`, and `docs-author-page`, and `extensions/drm-copilot/test` for `docs-author-page`. Every matching file is named with a disposition in P2-T3, P3-T1, or P3-T2, or reads only text unaffected by the change (`DocumentationEstateOnboarding.Tests.ps1`, `docs-estate-workflow.EndToEnd.Tests.ps1`, `DocsLedgerCommands.Properties.Tests.ps1`, the `enforce-docs-complete-gate*` hook suites). No further test outside the task file sets asserts the changed behavior.
