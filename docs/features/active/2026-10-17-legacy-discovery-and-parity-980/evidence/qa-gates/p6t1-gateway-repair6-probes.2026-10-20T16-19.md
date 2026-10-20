Timestamp: 2026-10-20T16-19
Command: `.venv/Scripts/python.exe SCRATCH\issue-980-p6t1-gateway-repair-probe.py`
EXIT_CODE: 0
Output Summary: repair6-probes; exit 0; elapsed 0.692 seconds.

```text
{
  "timestamp": "2026-10-20T16:19:07.213947+00:00",
  "bindings_before": {
    "packages/discovery-runtime/src/drm_copilot_discovery/gateway.py": "70317b21203fb11dd640fa2036b8b13521516f8ce8c8f7412b4d177e2b9207db",
    "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py": "15d1ffba846eb418b8046cad1d2455c725167da2985f4c7e80f6fb44185564e1",
    "packages/discovery-runtime/src/drm_copilot_discovery/doctor.py": "344fc1fecdcdefca5ed193d6fbecfc0b9a867143753dfe4d32a5a9ef24a8795d",
    "tests/discovery_runtime/test_gateway.py": "7cb784279aac1e0d0aa6f7b6f38e7a0e50df1a3eb010e064851fe5ea361135fd",
    "tests/discovery_runtime/test_gateway_local.py": "e2c2b77c97c886221690355c835834e13ba04cecb130d52d87baac8d4728e6bb",
    "tests/discovery_runtime/test_doctor.py": "bc079b2c3f7c4105df1b82ed070e98e43c3f7aa295cd2abf17e7c8b8ba1c9dbf",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py": "e81579104dbf8d3c7b146942393e1f82786fdb3891841ece8427bb26b2a3bb85",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py": "0bcdcb5cf374912da69ea837dd6d75d51a7a93a18de5bb0db54896615001a6ab",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py": "e62fa8e8703e2936283067be3b1463ed1a0b2e9fdf28d655721fd195fc7c6015",
    "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py": "3ca56a07f1056802ff414b44bddf52393c573dd0ddbd3142e6c7a2b6192d5bd0"
  },
  "post_executor_serialization": {
    "calls": [
      "executor_returned",
      "serialization"
    ],
    "outcome": {
      "returned": true,
      "exit_code": 3
    },
    "stdout": "",
    "stderr": "Discovery result failed unexpectedly; no replacement emitted.\n"
  },
  "git_read_deadline_order": {
    "events": [
      {
        "event": "deadline.create",
        "timeout": 30
      },
      {
        "event": "deadline.start"
      },
      {
        "event": "stdout.read",
        "size": 5,
        "prior_wait_timeouts": []
      },
      {
        "event": "deadline.cancel"
      },
      {
        "event": "deadline.join"
      },
      {
        "event": "poll"
      },
      {
        "event": "kill"
      },
      {
        "event": "wait",
        "timeout": null
      },
      {
        "event": "context_exit"
      }
    ],
    "qualification": "The sentinel stops at read entry. This demonstrates deadline ordering only; no hung child or elapsed-time result is claimed."
  },
  "doctor_path_work": {
    "candidate_characters": 4095,
    "configured_work": 2048,
    "text_measurements": [],
    "work_remaining": [],
    "outcome": {
      "returned": true,
      "exit_code": 3,
      "missing_paths": 0
    },
    "workspace_byte_reads": 0,
    "registry_write_observed": false,
    "revocations": 0
  },
  "bindings_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/gateway.py": "70317b21203fb11dd640fa2036b8b13521516f8ce8c8f7412b4d177e2b9207db",
    "packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py": "15d1ffba846eb418b8046cad1d2455c725167da2985f4c7e80f6fb44185564e1",
    "packages/discovery-runtime/src/drm_copilot_discovery/doctor.py": "344fc1fecdcdefca5ed193d6fbecfc0b9a867143753dfe4d32a5a9ef24a8795d",
    "tests/discovery_runtime/test_gateway.py": "7cb784279aac1e0d0aa6f7b6f38e7a0e50df1a3eb010e064851fe5ea361135fd",
    "tests/discovery_runtime/test_gateway_local.py": "e2c2b77c97c886221690355c835834e13ba04cecb130d52d87baac8d4728e6bb",
    "tests/discovery_runtime/test_doctor.py": "bc079b2c3f7c4105df1b82ed070e98e43c3f7aa295cd2abf17e7c8b8ba1c9dbf",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py": "e81579104dbf8d3c7b146942393e1f82786fdb3891841ece8427bb26b2a3bb85",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py": "0bcdcb5cf374912da69ea837dd6d75d51a7a93a18de5bb0db54896615001a6ab",
    "packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py": "e62fa8e8703e2936283067be3b1463ed1a0b2e9fdf28d655721fd195fc7c6015",
    "packages/discovery-runtime/src/drm_copilot_discovery/report_models.py": "3ca56a07f1056802ff414b44bddf52393c573dd0ddbd3142e6c7a2b6192d5bd0"
  },
  "source_and_dependency_stable": true,
  "probe_rebinding": {
    "original_sha256": "bafdcdec34d3eea0c5fe633d2460b3a728356732784adbadfd36771e371a268e",
    "changes": [
      "Historical scope paths retained; current hashes replace the stale candidate equality guard.",
      "Manual deadline observer records create/start/cancel/join without a timer thread.",
      "Original serializer, pipe-entry and counted-path observations are unchanged.",
      "Added pass assertions for exactly the three demonstrated corrections."
    ]
  }
}

```
