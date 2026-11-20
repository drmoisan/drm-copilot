# Template Link Check [P3-T4]

Timestamp: 2026-11-20T15-10
Command: cp .dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md; sha256sum over each FT_BYTE_PAIRS source and bundle copy; grep -n ".github/instructions" over the moved templates; ls of each link target
EXIT_CODE: 0
Output Summary: Four FT_BYTE_PAIRS copies checked: feature plan COPIED, bug plan, refactor plan and epic/epic.md ALREADY_IDENTICAL; every source and bundle digest pair matches. The feature template's two `.github/instructions/` links use `../../../`, which resolves from `.dev/active/<folder>/` to the repository root; both targets exist. The other templates carry no `.github/instructions/` link.

## FT_BYTE_PAIRS

| Bundle copy | Source | Result | SHA-256 (source = bundle) |
| --- | --- | --- | --- |
| `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` | `.dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md` | COPIED | `a4cf9119e5b3f465c22e9d2535990ad9a913f5e6062dd19358a8d62628736a4a` |
| `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md` | `.dev/templates/bug/plan.yyyy-MM-ddTHH-mm.md` | ALREADY_IDENTICAL | `b6882b54687a2e02abcf0c40c0dc0170aff34d8842d35bbb67ae32f6ab4c8ee6` |
| `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md` | `.dev/templates/refactor/plan.yyyy-MM-ddTHH-mm.md` | ALREADY_IDENTICAL | `5a42b51b9a21d2131d00aab23335eabfc3f3b69c4332b87da9587b34175cbcab` |
| `extensions/drm-copilot/resources/feature-templates/epic/epic.md` | `.dev/templates/epic/epic.md` | ALREADY_IDENTICAL | `8dd93bdc3d428a36b63b8dfe3720ef6b8cd90c66707f01682be9bdf8bc22ef78` |

Before the copy the feature bundle copy had digest `87e2bb68be03bfed3d9693ba2d524b16be85e13bb3b572442d7a71b64bc5abc2` and four-level (`../../../../`) links; the diff was the two link lines only, which lie outside every recorded ledger region.

## Link resolution from `.dev/active/<folder>/`

| Link | Resolved path | Exists |
| --- | --- | --- |
| `../../../.github/instructions/general-code-change.instructions.md` | `.github/instructions/general-code-change.instructions.md` | yes |
| `../../../.github/instructions/general-unit-test.instructions.md` | `.github/instructions/general-unit-test.instructions.md` | yes |

## Named acceptance tests (task check of the same time)

- `test_plan_templates_carry_premortem_skeleton`: passed.
- `CES-TEMPLATES-BYTE-IDENTICAL`: passed.
- `PRC-LEDGER-CHAIN-HOLDS`: passed.
