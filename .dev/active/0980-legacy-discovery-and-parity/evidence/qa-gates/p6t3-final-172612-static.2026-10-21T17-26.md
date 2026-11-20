# P6-T3 final static

Timestamp: 2026-10-21T17-26

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t3_final_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t3-final-candidate-qualified-released.2026-10-21T17-23.json`

EXIT_CODE: 0

Output Summary: PASS; 0.410 seconds; 0 passed nodes; timeout=False.

```text
{
  "files": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "physical_lines": 467,
      "definitions": 43,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/profile_cli.py",
      "physical_lines": 128,
      "definitions": 8,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/init_cli.py",
      "physical_lines": 65,
      "definitions": 2,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/analyzer/__init__.py",
      "physical_lines": 31,
      "definitions": 1,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/analyzer/__main__.py",
      "physical_lines": 12,
      "definitions": 0,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/analyzer/cli.py",
      "physical_lines": 88,
      "definitions": 3,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/analyzer/stack_cli.py",
      "physical_lines": 50,
      "definitions": 2,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/generate_acceptance_scenarios.py",
      "physical_lines": 346,
      "definitions": 19,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/validate_discovery_artifacts.py",
      "physical_lines": 295,
      "definitions": 14,
      "loops": [
        83,
        110,
        176,
        207,
        247
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/coverage_report.py",
      "physical_lines": 146,
      "definitions": 3,
      "loops": [
        123
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/parity_report.py",
      "physical_lines": 146,
      "definitions": 3,
      "loops": [
        123
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "scripts/dev_tools/discovery/completion_report.py",
      "physical_lines": 176,
      "definitions": 4,
      "loops": [
        150
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_legacy_adapters.py",
      "physical_lines": 384,
      "definitions": 12,
      "loops": [
        59
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_profile_cli.py",
      "physical_lines": 251,
      "definitions": 14,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_init_cli.py",
      "physical_lines": 265,
      "definitions": 15,
      "loops": [
        45,
        54
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/analyzer/test_cli.py",
      "physical_lines": 202,
      "definitions": 16,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py",
      "physical_lines": 184,
      "definitions": 9,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/test_generate_acceptance_scenarios.py",
      "physical_lines": 338,
      "definitions": 18,
      "loops": [
        229
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py",
      "physical_lines": 457,
      "definitions": 30,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_coverage_report.py",
      "physical_lines": 489,
      "definitions": 37,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_parity_report.py",
      "physical_lines": 401,
      "definitions": 33,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_completion_report.py",
      "physical_lines": 444,
      "definitions": 33,
      "loops": [],
      "reviewed_unchanged_test_body": false
    }
  ],
  "retained_units": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "CliPorts",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "CliPorts",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_clock",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_clock",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_create_io",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_create_io",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_emit",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_emit",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_execute",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_execute",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_failure",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_failure",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_repository",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_repository",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_resolve_workspace",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_resolve_workspace",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "_write",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "_write",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_completion_report",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_completion_report",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_configure",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_configure",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_coverage_report",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_coverage_report",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_doctor",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_doctor",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_dotnet",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_dotnet",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_generate_acceptance",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_generate_acceptance",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_generate_acceptance_scenarios",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_generate_acceptance_scenarios",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_import_inventory",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_import_inventory",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_init",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_init",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_inventory",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_inventory",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_link_evidence",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_link_evidence",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_migrate",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_migrate",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_new_contract",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_new_contract",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_new_scenario",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_new_scenario",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_parity_report",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_parity_report",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_profile",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_profile",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_snapshot_export",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_snapshot_export",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_snapshot_import",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_snapshot_import",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_update_artifact",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_update_artifact",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_all",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_all",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_coverage_ledger",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_coverage_ledger",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_decisions",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_decisions",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_evidence_reference",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_evidence_reference",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_feature_contract",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_feature_contract",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_parity_matrix",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_parity_matrix",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_product_decision",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_product_decision",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_profile",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_profile",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_runtime_scenario",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_runtime_scenario",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_validate_unspecified_behavior",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_validate_unspecified_behavior",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "main_vsto",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "main_vsto",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "name": "run_cli",
      "source_ref": "e926b481d9958b174a4012fb3bb268a390fa8fc2",
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "source_name": "run_cli",
      "source_archive": {
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-originals.2026-10-21T16-44.json",
        "selector": [
          "preimage_reader_view"
        ],
        "sha256": "83a37ef8ccfdaa1129dbfed4ebdf6c8cdfd63a6fd368fc3aaae3d65acd5e332f"
      }
    }
  ],
  "source_or_test_mutation": false
}

```
