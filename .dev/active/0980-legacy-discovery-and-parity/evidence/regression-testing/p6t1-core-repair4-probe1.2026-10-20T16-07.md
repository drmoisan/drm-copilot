# P6-T1 core service probe1

Timestamp: 2026-10-20T16-07

Command: `poetry run python <SCRATCH>\issue-980-p6t1-core-probe.py`

EXIT_CODE: 0

Output Summary: PASS; 1.612 seconds.

```text
{
  "timestamp": "2026-10-20T16:07:49.324139+00:00",
  "scope": "Finite direct composition probes; inert injected ports; no writes or suites",
  "bindings_before": {
    "packages/discovery-runtime/src/drm_copilot_discovery/service.py": "fa624d625177512b5752a891ebd73c5cc5bf000b1ce0a5e236d25728e68b4c3e",
    "packages/discovery-runtime/src/drm_copilot_discovery/operations.py": "dfa1c9f174f75551037817399315b578e17a4d6e57bc0c7da7f9d5fc45bb2de3",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py": "e66eebfdca69edc01d7df3775fa6bd845fb44a84ebc7b51b23c4f9fcfba3a162",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py": "650172e2041ae469274d51bd35ea826788132496310c245747ad95b2bc5b46f8",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py": "69baad58dedfc54e1054612fe2447dfe74481ad8c2b6a6c22e53b2679f04f6e0",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py": "618cd0e0c10929dfdbd67bf4da1a6bb32270f2baca293de68414944dfa7a7372",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py": "e81579104dbf8d3c7b146942393e1f82786fdb3891841ece8427bb26b2a3bb85",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py": "0bcdcb5cf374912da69ea837dd6d75d51a7a93a18de5bb0db54896615001a6ab",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py": "e62fa8e8703e2936283067be3b1463ed1a0b2e9fdf28d655721fd195fc7c6015"
  },
  "failure_envelopes": {
    "operation_provider": {
      "pointers": [
        "/inputs"
      ],
      "returned": true,
      "exit_code": 3,
      "result_type": "DiscoveryResult"
    },
    "core_io": {
      "pointers": [
        "/"
      ],
      "returned": true,
      "exit_code": 3,
      "result_type": "DiscoveryResult"
    },
    "shared_runtime_positive_control": {
      "pointers": [
        "/runtime"
      ],
      "returned": true,
      "exit_code": 3,
      "result_type": "DiscoveryResult"
    }
  },
  "catalog_before_request": {
    "returned": true,
    "exit_code": 2,
    "result_type": "DiscoveryResult"
  },
  "projection_work": {
    "configured_total_work": 2048,
    "available_work_before": 1,
    "content_bytes": 4096,
    "outcome": {
      "returned": false,
      "error_type": "ReportLimitError",
      "error": "REPORT_LIMIT: report exceeds configured resource limits"
    },
    "hash_calls": [],
    "work_after": 0
  },
  "finding_order_work": {
    "findings": 96,
    "configured_total_work": 2048,
    "declared_order_reservation": 768,
    "outcome": {
      "returned": false,
      "error_type": "ReportLimitError",
      "error": "REPORT_LIMIT: report exceeds configured resource limits"
    },
    "actual_equality_calls": 0
  },
  "bindings_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/service.py": "fa624d625177512b5752a891ebd73c5cc5bf000b1ce0a5e236d25728e68b4c3e",
    "packages/discovery-runtime/src/drm_copilot_discovery/operations.py": "dfa1c9f174f75551037817399315b578e17a4d6e57bc0c7da7f9d5fc45bb2de3",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py": "e66eebfdca69edc01d7df3775fa6bd845fb44a84ebc7b51b23c4f9fcfba3a162",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py": "650172e2041ae469274d51bd35ea826788132496310c245747ad95b2bc5b46f8",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py": "69baad58dedfc54e1054612fe2447dfe74481ad8c2b6a6c22e53b2679f04f6e0",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py": "618cd0e0c10929dfdbd67bf4da1a6bb32270f2baca293de68414944dfa7a7372",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py": "e81579104dbf8d3c7b146942393e1f82786fdb3891841ece8427bb26b2a3bb85",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py": "0bcdcb5cf374912da69ea837dd6d75d51a7a93a18de5bb0db54896615001a6ab",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py": "e62fa8e8703e2936283067be3b1463ed1a0b2e9fdf28d655721fd195fc7c6015"
  },
  "source_and_dependency_stable": true
}

```
