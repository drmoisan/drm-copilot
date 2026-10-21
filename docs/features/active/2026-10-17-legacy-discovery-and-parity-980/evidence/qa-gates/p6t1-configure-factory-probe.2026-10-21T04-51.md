# P6-T1 configure factory observation

Timestamp: 2026-10-21T04-51

Command: `WORKSPACE/.venv/Scripts/python.exe -I -S -B SCRATCH/issue-980-p6t1-gateway-configure-factory-probe.py SCRATCH/issue-980-p6t1-gateway-configure-factory-2026-10-21T04-51.json`

EXIT_CODE: 0

Output Summary: One read-only installed_local_io construction; no service/native operation replay.

The exact request and five source/installed inputs are bound in the JSON companion. The subprocess reused the retained controller with a 30-second limit and 65,536-byte limit per stream. The raw archive preserves executed helper/configuration/request/output bytes.

```json
{
  "all_runtime_imports_installed": true,
  "blocked_events": [],
  "calls": {
    "forbidden_port": 0,
    "git_runner": 0,
    "installed_local_io": 1
  },
  "constructed": false,
  "dont_write_bytecode": true,
  "failure": {
    "frames": [
      {
        "function": "<module>",
        "line": 80,
        "module": "__main__"
      },
      {
        "function": "installed_local_io",
        "line": 413,
        "module": "drm_copilot_discovery.gateway_local"
      },
      {
        "function": "_canonical_state_location",
        "line": 374,
        "module": "drm_copilot_discovery.gateway_local"
      }
    ],
    "type": "ValueError"
  },
  "isolated": 1,
  "no_site": 1,
  "service_imported": false,
  "stage": "factory-construction"
}
```

Constructor-only diagnostic. Current host settings are inherited by the retained controller; no claim that unrecorded historical host settings are identical.
