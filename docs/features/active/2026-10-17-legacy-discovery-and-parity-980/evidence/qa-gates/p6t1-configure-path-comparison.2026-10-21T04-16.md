# P6-T1 configure path comparison

Timestamp: 2026-10-21T04-16

Command: `WORKSPACE/.venv/Scripts/python.exe -I -S -B SCRATCH/issue-980-p6t1-gateway-configure-path-comparison.py SCRATCH/issue-980-p6t1-gateway-configure-factory-2026-10-21T04-13.json`

EXIT_CODE: 0

Output Summary: Two path comparisons and at most 16 registry/ancestor metadata entries; no runtime calls.

```json
{
  "blocked_events": [],
  "factory_calls": 0,
  "metadata": [
    {
      "component": "registry",
      "error_type": "FileNotFoundError"
    },
    {
      "component": "ancestor-1",
      "file_attributes": 16,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-2",
      "file_attributes": 16,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-3",
      "file_attributes": 16,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-4",
      "file_attributes": 16,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-5",
      "file_attributes": 16,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-6",
      "file_attributes": 16,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-7",
      "file_attributes": 17,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    },
    {
      "component": "ancestor-8",
      "file_attributes": 22,
      "kind": "directory",
      "reparse": false,
      "reparse_tag": 0
    }
  ],
  "runtime_imported": false,
  "state_absolute": true,
  "state_inside_workspace_lexical": false,
  "state_resolve_equals_lexical": false,
  "workspace_absolute": true,
  "workspace_resolve_equals_lexical": true
}
```

Windows lexical argument construction inspected before execution; both arguments are derived from absolute inputs. No factory invocation, runtime import, service, Git, test or writer call.
