# P6-T2 final static

Timestamp: 2026-10-21T16-08

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t2-final-candidate-released.2026-10-21T16-08.json`

EXIT_CODE: 0

Output Summary: PASS; 0.209 seconds; 0 passed nodes; timeout=False.

```text
{
  "files": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli.py",
      "physical_lines": 453,
      "definitions": 42,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli_arguments.py",
      "physical_lines": 405,
      "definitions": 14,
      "loops": [
        154,
        173,
        213,
        253,
        344,
        355,
        361
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/cli_commands.py",
      "physical_lines": 241,
      "definitions": 4,
      "loops": [
        223
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_cli_commands.py",
      "physical_lines": 372,
      "definitions": 7,
      "loops": [
        203,
        210
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_cli_errors.py",
      "physical_lines": 371,
      "definitions": 21,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_cli_dry_run.py",
      "physical_lines": 493,
      "definitions": 29,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/scripts/dev_tools/discovery/test_init_cli.py",
      "physical_lines": 154,
      "definitions": 11,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/cli_test_support.py",
      "physical_lines": 85,
      "definitions": 2,
      "loops": [],
      "reviewed_unchanged_test_body": false
    }
  ],
  "retained_units": [],
  "source_or_test_mutation": false
}

```
