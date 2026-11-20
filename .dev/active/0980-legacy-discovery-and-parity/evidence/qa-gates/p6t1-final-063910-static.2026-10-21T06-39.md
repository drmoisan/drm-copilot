# P6-T1 final static

Timestamp: 2026-10-21T06-39

Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\p6t1_final_nio1_static.py WORKSPACE\docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p6t1-final-candidate-source-range.2026-10-21T06-39.json`

EXIT_CODE: 0

Output Summary: PASS; 0.410 seconds; 0 passed nodes; timeout=False.

```text
{
  "files": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service.py",
      "physical_lines": 334,
      "definitions": 6,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/operations.py",
      "physical_lines": 500,
      "definitions": 20,
      "loops": [
        119,
        246,
        362,
        369
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py",
      "physical_lines": 278,
      "definitions": 5,
      "loops": [
        200
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py",
      "physical_lines": 217,
      "definitions": 4,
      "loops": [
        34,
        96,
        160,
        172
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py",
      "physical_lines": 246,
      "definitions": 4,
      "loops": [
        106,
        117
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py",
      "physical_lines": 337,
      "definitions": 7,
      "loops": [
        82,
        253
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway.py",
      "physical_lines": 354,
      "definitions": 8,
      "loops": [
        200,
        305
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "physical_lines": 431,
      "definitions": 16,
      "loops": [
        243,
        153
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/doctor.py",
      "physical_lines": 288,
      "definitions": 10,
      "loops": [
        103,
        192
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_service.py",
      "physical_lines": 495,
      "definitions": 24,
      "loops": [
        193,
        196
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_service_publication.py",
      "physical_lines": 455,
      "definitions": 18,
      "loops": [
        58,
        425
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_service_boundaries.py",
      "physical_lines": 499,
      "definitions": 27,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_gateway.py",
      "physical_lines": 453,
      "definitions": 26,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_gateway_local.py",
      "physical_lines": 494,
      "definitions": 21,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_doctor.py",
      "physical_lines": 414,
      "definitions": 17,
      "loops": [
        327
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_gateway_boundaries.py",
      "physical_lines": 425,
      "definitions": 19,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/gateway_test_support.py",
      "physical_lines": 319,
      "definitions": 22,
      "loops": [],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "physical_lines": 497,
      "definitions": 13,
      "loops": [
        111,
        225,
        318,
        387,
        390,
        397,
        406,
        241
      ],
      "reviewed_unchanged_test_body": false
    },
    {
      "path": "tests/discovery_runtime/test_gateway_factory.py",
      "physical_lines": 410,
      "definitions": 18,
      "loops": [
        75
      ],
      "reviewed_unchanged_test_body": false
    }
  ],
  "retained_units": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy.__init__",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy.__init__",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy._inspect",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy._inspect",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy._validate_layout",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy._validate_layout",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy._walk",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy._walk",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy.resolve_read",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy.resolve_read",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy.resolve_write",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy.resolve_write",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy.revalidate_write",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy.revalidate_write",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "PathPolicy.validate_configuration",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "PathPolicy.validate_configuration",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "_absolute",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "_absolute",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "_overlaps",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "_overlaps",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "name": "_reserved_output",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "source_name": "_reserved_output",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.__init__",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.__init__",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO._recapture",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO._recapture",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.activation",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.activation",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.initialization",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.initialization",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.runtime_identity",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.runtime_identity",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "_authorize_local_root",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "_authorize_local_root",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "_invalidate_empty_authority",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "_invalidate_empty_authority",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "_repository_selection",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "_repository_selection",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "run_local_git",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "run_local_git",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "run_local_git.expire",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "run_local_git.expire",
      "source_archive": {
        "bytes": 26554,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-nio1-inputs.2026-10-20T17-59.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "be93a812aad06fe57ba345d498b19b9ae28a401328e23d0aa3cbd2aa97d3c515"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO._matches_workspace",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO._matches_workspace",
      "source_archive": {
        "bytes": 18045,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf1-inputs.2026-10-21T04-30.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "9873fb731c0e4f3ac8e69fef36bd048d831db6fc59cf81a88d7547a44d771fe0"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO._matches_workspace",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO._matches_workspace",
      "source_archive": {
        "bytes": 18045,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf1-inputs.2026-10-21T04-30.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "9873fb731c0e4f3ac8e69fef36bd048d831db6fc59cf81a88d7547a44d771fe0"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.authorize",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.authorize",
      "source_archive": {
        "bytes": 18045,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf1-inputs.2026-10-21T04-30.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "9873fb731c0e4f3ac8e69fef36bd048d831db6fc59cf81a88d7547a44d771fe0"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.authorize",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.authorize",
      "source_archive": {
        "bytes": 18045,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf1-inputs.2026-10-21T04-30.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "9873fb731c0e4f3ac8e69fef36bd048d831db6fc59cf81a88d7547a44d771fe0"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.writer",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.writer",
      "source_archive": {
        "bytes": 18045,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf1-inputs.2026-10-21T04-30.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "9873fb731c0e4f3ac8e69fef36bd048d831db6fc59cf81a88d7547a44d771fe0"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "LocalServiceIO.writer",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "LocalServiceIO.writer",
      "source_archive": {
        "bytes": 18045,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf1-inputs.2026-10-21T04-30.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "9873fb731c0e4f3ac8e69fef36bd048d831db6fc59cf81a88d7547a44d771fe0"
      }
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "name": "installed_local_io",
      "source_ref": null,
      "source_path": "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py",
      "source_name": "installed_local_io",
      "source_archive": {
        "bytes": 18103,
        "path": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-gateway-ncf2-inputs.2026-10-21T05-08.json",
        "selector": [
          "entries",
          "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py"
        ],
        "sha256": "4252a3140aa1c2231d4a004433c5f29fbfc22f5fadc6b6d1a79cd32a58389bc2"
      }
    }
  ],
  "source_or_test_mutation": false
}

```
