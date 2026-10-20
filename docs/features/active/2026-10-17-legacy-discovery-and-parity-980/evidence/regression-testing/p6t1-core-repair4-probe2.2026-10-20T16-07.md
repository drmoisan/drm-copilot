# P6-T1 core service probe2

Timestamp: 2026-10-20T16-07

Command: `poetry run python <SCRATCH>\issue-980-p6t1-core-boundary-probe.py`

EXIT_CODE: 0

Output Summary: PASS; 2.212 seconds.

```text
{
  "timestamp": "2026-10-20T16:07:50.985681+00:00",
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
  "coordinator_ordering_only": {
    "configured_total_work": 2048,
    "reserved_work": 768,
    "outcome": {
      "returned": false,
      "error_type": "ReportLimitError",
      "error": "REPORT_LIMIT: report exceeds configured resource limits"
    },
    "observations": []
  },
  "bootstrap_failure_packaging": {
    "captured_bytes_sha256": "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
    "current_bytes_sha256": "4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945",
    "first_freshness_failure": {
      "returned": false,
      "error_type": "OSError",
      "error": "Snapshot bytes changed at 'input.json'; reload"
    },
    "failure_envelope": {
      "returned": true,
      "exit_code": 3
    }
  },
  "public_execute_provider_mismatch": {
    "returned": true,
    "exit_code": 3
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
