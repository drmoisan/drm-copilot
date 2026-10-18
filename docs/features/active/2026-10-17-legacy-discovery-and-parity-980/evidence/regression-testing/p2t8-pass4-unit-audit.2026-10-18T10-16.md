# p2t8-pass4-unit-audit

Timestamp: 2026-10-18T10-16
Command: python SCRATCH/issue-980-p2t8-preaudit.py
EXIT_CODE: 0
Output Summary:       "percent": 88.88888888888889;     };   ]; }

Working directory: .
Started: 2026-10-18T10:16:44.208755+00:00
Duration seconds: 0.057
Phase: P2-T8 source-to-target parity rules; focused task verification.

## Captured output

```text
{
  "units": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "ParityValidation",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "_declares",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "_ParityRules",
      "covered": 110,
      "total": 111,
      "percent": 99.09909909909909
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "validate_parity",
      "covered": 15,
      "total": 15,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "__init__",
      "covered": 4,
      "total": 4,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "source",
      "covered": 8,
      "total": 8,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "target",
      "covered": 9,
      "total": 9,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "approval",
      "covered": 18,
      "total": 18,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "classifications",
      "covered": 30,
      "total": 31,
      "percent": 96.7741935483871
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "entry",
      "covered": 36,
      "total": 36,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py",
      "name": "required_entries",
      "covered": 4,
      "total": 4,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "_payload_paths",
      "covered": 4,
      "total": 4,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "TargetProof",
      "covered": 81,
      "total": 87,
      "percent": 93.10344827586206
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "__init__",
      "covered": 5,
      "total": 5,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "blocked",
      "covered": 3,
      "total": 3,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "identity",
      "covered": 8,
      "total": 9,
      "percent": 88.88888888888889
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "source_payload",
      "covered": 7,
      "total": 8,
      "percent": 87.5
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "evidence",
      "covered": 15,
      "total": 16,
      "percent": 93.75
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "implementation",
      "covered": 24,
      "total": 27,
      "percent": 88.88888888888889
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "links",
      "covered": 11,
      "total": 11,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "coordinate",
      "covered": 7,
      "total": 7,
      "percent": 100.0
    }
  ],
  "failures": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "identity",
      "covered": 8,
      "total": 9,
      "percent": 88.88888888888889
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "source_payload",
      "covered": 7,
      "total": 8,
      "percent": 87.5
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py",
      "name": "implementation",
      "covered": 24,
      "total": 27,
      "percent": 88.88888888888889
    }
  ]
}
```
