# P8-T8 Python type gate

Timestamp: 2026-10-22T13-31
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/doctor.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py tests/discovery_runtime/test_doctor.py tests/discovery_runtime/test_doctor_capability.py
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations. The CapabilityObservation return annotation on LocalServiceIO.capability_observation resolves through a TYPE_CHECKING import; the runtime_checkable CapabilityObserving protocol is narrowed with isinstance in service_inspection before capability_observation is called. The only cast in the new test module narrows a parametrized str to the CapabilityStatus literal for the contradiction cases; no type: ignore was added.
