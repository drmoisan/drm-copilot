# P5-T2 final static

Timestamp: 2026-10-20T08-03
Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\final_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p5t2-final-candidate.2026-10-20T08-03.json`
EXIT_CODE: 0
Output Summary: Stage 4; 2.027 seconds; 0 completed nodes; timeout=False; changed bindings=0.

```text
{
  "files": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_entry_rules.py",
      "physical_lines": 473,
      "definitions": 9,
      "loops": [
        101,
        193,
        462,
        157,
        403,
        447,
        212
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py",
      "physical_lines": 413,
      "definitions": 6,
      "loops": [
        109,
        124,
        194,
        202,
        297,
        307,
        337,
        361,
        365,
        119,
        327,
        150,
        331
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_models.py",
      "physical_lines": 86,
      "definitions": 3,
      "loops": []
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py",
      "physical_lines": 173,
      "definitions": 8,
      "loops": []
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "physical_lines": 345,
      "definitions": 4,
      "loops": [
        302,
        331,
        112,
        119,
        145,
        239,
        334
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "physical_lines": 346,
      "definitions": 20,
      "loops": [
        92,
        140,
        155
      ]
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "physical_lines": 498,
      "definitions": 10,
      "loops": [
        70,
        373
      ]
    },
    {
      "path": "scripts/dev_tools/discovery/parity_report.py",
      "physical_lines": 127,
      "definitions": 3,
      "loops": [
        104
      ]
    },
    {
      "path": "tests/discovery_runtime/test_parity_axes.py",
      "physical_lines": 245,
      "definitions": 9,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_parity_metrics.py",
      "physical_lines": 497,
      "definitions": 16,
      "loops": [
        109
      ]
    },
    {
      "path": "tests/discovery_runtime/test_parity_models.py",
      "physical_lines": 330,
      "definitions": 14,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_parity_report.py",
      "physical_lines": 399,
      "definitions": 21,
      "loops": []
    },
    {
      "path": "tests/discovery_runtime/test_parity_report_projection.py",
      "physical_lines": 314,
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
      "path": "tests/discovery_runtime/test_validation_modes.py",
      "physical_lines": 476,
      "definitions": 14,
      "loops": [
        303,
        312
      ]
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_parity_report.py",
      "physical_lines": 344,
      "definitions": 28,
      "loops": []
    }
  ],
  "retained_units": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py",
      "name": "_legacy_version",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py",
      "name": "parse_parity_matrix",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py",
      "name": "build_parity_rows",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py",
      "name": "render_parity_report",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportLimitError",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportLimitError.__init__",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.__init__",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.work",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.spend",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.text",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ReportBudget.check",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "_freeze",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "bounded_object",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "ratio",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.__post_init__",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.to_dict",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "DiscoveryReport.to_json",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "_legacy_version",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "parse_coverage_ledger",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "build_coverage_rows",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py",
      "name": "render_coverage_report",
      "source_ref": "2b069afb0d88ae1a3c17ef10f7a52c3936800462"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "SnapshotValidation",
      "source_ref": "7012d20245cd27d29bf66ede6ac9756dec354ed4"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "_findings",
      "source_ref": "7012d20245cd27d29bf66ede6ac9756dec354ed4"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "SnapshotValidation.ok",
      "source_ref": "7012d20245cd27d29bf66ede6ac9756dec354ed4"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "_Validation.evaluate",
      "source_ref": "7012d20245cd27d29bf66ede6ac9756dec354ed4"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "validate_snapshot",
      "source_ref": "7012d20245cd27d29bf66ede6ac9756dec354ed4"
    }
  ],
  "source_or_test_mutation": false
}

```
