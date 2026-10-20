# P6-T1 renderer reprobe

Timestamp: 2026-10-20T15-24

Command: `poetry run python <SCRATCH>\p6t1-shared-reprobe.py`

EXIT_CODE: 0

Output Summary: PASS; 1.611 seconds.

```text
{
  "task": "P6-T1",
  "scope": "Two bounded deterministic concerns; no pytest population or I/O fixture.",
  "candidate": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py",
      "sha256": "e81579104dbf8d3c7b146942393e1f82786fdb3891841ece8427bb26b2a3bb85"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py",
      "sha256": "0bcdcb5cf374912da69ea837dd6d75d51a7a93a18de5bb0db54896615001a6ab"
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py",
      "sha256": "e62fa8e8703e2936283067be3b1463ed1a0b2e9fdf28d655721fd195fc7c6015"
    }
  ],
  "direct_carriers": [
    {
      "field": "ServiceAuthority.principal",
      "equality_calls": 0,
      "accepted": false,
      "retains_nonstring": false,
      "error_type": "ValueError"
    },
    {
      "field": "ServiceRuntimeError.code",
      "equality_calls": 0,
      "accepted": false,
      "retains_nonstring": false,
      "error_type": "ValueError"
    },
    {
      "field": "ServiceRequestError.operation",
      "equality_calls": 0,
      "accepted": true,
      "retains_nonstring": false,
      "error_type": null
    },
    {
      "field": "ServiceRequestError.mode",
      "equality_calls": 0,
      "accepted": true,
      "retains_nonstring": false,
      "error_type": null
    },
    {
      "field": "DiscoveryResult.operation",
      "equality_calls": 0,
      "accepted": false,
      "retains_nonstring": false,
      "error_type": "ValueError"
    },
    {
      "field": "DiscoveryResult.mode",
      "equality_calls": 0,
      "accepted": false,
      "retains_nonstring": false,
      "error_type": "ValueError"
    }
  ],
  "manifest_work": [
    {
      "path_characters": 20,
      "content_bytes": 1,
      "work_capacity": 2048,
      "calls": [],
      "budget_observations": [],
      "returned": false,
      "error_type": "ReportLimitError"
    },
    {
      "path_characters": 4096,
      "content_bytes": 1,
      "work_capacity": 2048,
      "calls": [],
      "budget_observations": [],
      "returned": false,
      "error_type": "ReportLimitError"
    }
  ]
}

```
