# P2-T7 final-source independent boundary probes

Timestamp: 2026-10-18 09:52:56 UTC
Started: 2026-10-18 09:52:17 UTC
Command: `poetry run python SCRATCH/issue-980-probe-p2t7.py`
EXIT_CODE: 0

Output summary: 47/47 independent probes pass against the current typed source. The earlier 09-49 probe preceded two set[str]() type-narrowing corrections in acceptance_rules.py; this bounded rerun binds the unchanged semantic cases to the final current hash. Both source hashes remain unchanged during execution; all semantic graphs are schema-valid, upstream assessments have zero findings, and snapshots remain immutable. Exact probe cases and hashes are retained in the companion JSON. Specialist ordered gates and final staged audit remain required before acceptance.

```text
{
  "probes": 47,
  "passed": 47,
  "failed": 0,
  "source_hashes": {
    "packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py": "6e47a2bff2eb5619b7360af05a069769cbefba5e2bcd8822986252065eedacda",
    "packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py": "01334ac9f98de2bb3676f92b5037c7986580830e7949d7e95799471ffaf1bd08"
  },
  "source_hashes_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py": "6e47a2bff2eb5619b7360af05a069769cbefba5e2bcd8822986252065eedacda",
    "packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py": "01334ac9f98de2bb3676f92b5037c7986580830e7949d7e95799471ffaf1bd08"
  }
}
[]
```
