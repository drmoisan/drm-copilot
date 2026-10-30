# P5-T3 final static

Timestamp: 2026-10-20T09-47
Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\final_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p5t3-final-candidate-native-repair.2026-10-20T09-46.json`
EXIT_CODE: 0
Output Summary: Stage 4; 2.017 seconds; 0 completed nodes; timeout=False; changed bindings=0.

```text
{
  "files": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_report.py",
      "physical_lines": 261,
      "definitions": 7,
      "loops": [
        104
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "physical_lines": 339,
      "definitions": 20,
      "loops": [
        92,
        140,
        155
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_rendering.py",
      "physical_lines": 36,
      "definitions": 1,
      "loops": []
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "physical_lines": 263,
      "definitions": 4,
      "loops": [
        113
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation_operation.py",
      "physical_lines": 310,
      "definitions": 6,
      "loops": [
        42
      ]
    },
    {
      "path": "scripts/dev_tools/discovery/completion_report.py",
      "physical_lines": 155,
      "definitions": 4,
      "loops": [
        129
      ]
    },
    {
      "path": "tests/discovery_runtime/test_agent_output.py",
      "physical_lines": 494,
      "definitions": 12,
      "loops": [
        161
      ]
    },
    {
      "path": "tests/discovery_runtime/test_completion_planning.py",
      "physical_lines": 360,
      "definitions": 16,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_completion_projection.py",
      "physical_lines": 418,
      "definitions": 12,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_completion_report.py",
      "physical_lines": 389,
      "definitions": 19,
      "loops": [
        209,
        211
      ]
    },
    {
      "path": "tests/discovery_runtime/test_parity_report_projection.py",
      "physical_lines": 316,
      "definitions": 8,
      "loops": [
        247
      ]
    },
    {
      "path": "tests/discovery_runtime/test_report_models.py",
      "physical_lines": 375,
      "definitions": 25,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_report_rendering.py",
      "physical_lines": 117,
      "definitions": 5,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_validation_modes.py",
      "physical_lines": 468,
      "definitions": 14,
      "loops": [
        303
      ]
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_completion_report.py",
      "physical_lines": 382,
      "definitions": 29,
      "loops": []
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_io.py",
      "physical_lines": 87,
      "definitions": 8,
      "loops": []
    }
  ],
  "retained_units": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportLimitError",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportLimitError"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportLimitError.__init__",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportLimitError.__init__"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportBudget"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.__init__",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportBudget.__init__"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.work",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportBudget.work"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.spend",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportBudget.spend"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.text",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportBudget.text"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.check",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ReportBudget.check"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "_freeze",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "_freeze"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "bounded_object",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "bounded_object"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ratio",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "ratio"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "DiscoveryReport"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.__post_init__",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "DiscoveryReport.__post_init__"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.to_dict",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "DiscoveryReport.to_dict"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.to_json",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "DiscoveryReport.to_json"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.to_markdown",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "DiscoveryReport.to_markdown"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "_legacy_version",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "_legacy_version"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "parse_coverage_ledger",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "parse_coverage_ledger"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "build_coverage_rows",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "build_coverage_rows"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "render_coverage_report",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "source_name": "render_coverage_report"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_rendering.py",
      "name": "render_report_markdown",
      "source_ref": "d8cdc87f8b70ef7311eb907966b13bbdbc48d89d",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/report_rendering.py",
      "source_name": "render_report_markdown"
    }
  ],
  "source_or_test_mutation": false
}

```
