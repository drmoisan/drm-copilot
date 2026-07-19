# File-Size Limit Verification (500-line limit)

- Timestamp: 2026-07-18T21-15
- Task: [P5-T2]
- Rule: No production or test file may exceed 500 lines (raw text fixtures exempt).

## Per-file line counts

| File | Lines | Under 500 |
| --- | --- | --- |
| scripts/dev_tools/discovery/analyzer/source_text.py | 476 | yes |
| scripts/dev_tools/discovery/analyzer/dotnet_inventory.py | 457 | yes |
| scripts/dev_tools/discovery/analyzer/vsto_office.py | 451 | yes |
| scripts/dev_tools/discovery/analyzer/vsto_patterns.py | 87 | yes |
| scripts/dev_tools/discovery/analyzer/stack_cli.py | 214 | yes |
| tests/scripts/dev_tools/discovery/analyzer/test_source_text.py | 289 | yes |
| tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py | 407 | yes |
| tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py | 474 | yes |
| tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py | 212 | yes |
| tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py | 129 | yes |

## Notes

- `dotnet_patterns.py` was not required: `dotnet_inventory.py` (457 lines) stayed
  under the limit without splitting its pattern tables.
- `vsto_patterns.py` was created as the data-only pattern-table split for the VSTO
  analyzer, keeping `vsto_office.py` at 451 lines.
- Raw text fixtures under `tests/fixtures/discovery_dotnet_vsto/` are exempt from
  the 500-line limit per policy and are not counted here.

## Verdict

All counted production and test files are under 500 lines. No split is blocked
and no file exceeds the limit.
