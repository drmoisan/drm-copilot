# P3-T5 independent probe: retained initial fixture failure

Timestamp: 2026-10-18T16:59:31Z
Command: `poetry run python SCRATCH/issue-980-p3t5-review-probes.py`
EXIT_CODE: 1
Output Summary: 12 checks passed; one SCRATCH fixture construction failed before the collection-link call. Source and accepted fixture hashes remained unchanged.

The probe supplied a previously absent collection file without removing its path from the captured missing-path set. The accepted manifest correctly rejected that contradictory fixture with PATH_COLLISION. Correct only the SCRATCH fixture to replace absence with the supplied file, then repeat the same bounded probe. No production defect or task acceptance is inferred.

Raw check detail: [initial result](p3t5-executor-probe-initial.2026-10-18T16-59.json).

```text
{"name": "deterministic-exact-projection", "passed": true, "detail": null}
{"name": "explicit-create-and-original-digest-preconditions", "passed": true, "detail": null}
{"name": "runtime-link-preserves-entire-original-observation", "passed": true, "detail": null}
{"name": "source-projection-preserves-states", "passed": true, "detail": null}
{"name": "test-projection-preserves-states", "passed": true, "detail": null}
{"name": "observation-projection-preserves-states", "passed": true, "detail": null}
{"name": "documentation-projection-preserves-states", "passed": true, "detail": null}
{"name": "decision-projection-preserves-states", "passed": true, "detail": null}
{"name": "inventory-projection-preserves-states", "passed": true, "detail": null}
{"name": "nested-array-only-update", "passed": true, "detail": null}
{"name": "existing-exact-link-is-not-duplicated-and-other-link-remains", "passed": true, "detail": null}
{"name":"probe-harness-completed","passed":false,"detail":{"error":"PATH_COLLISION: 'docs/migration/discovery/product-decisions.yaml': Remove duplicate or aliased paths.","traceback":"Traceback (most recent call last):\n  File \"SCRATCH\\issue-980-p3t5-review-probes.py\", line 191, in <module>\n    main()\n    ~~~~^^\n  File \"SCRATCH\\issue-980-p3t5-review-probes.py\", line 117, in main\n    selected = put_record(baseline, collection, path)\n  File \"SCRATCH\\issue-980-p3t5-review-probes.py\", line 66, in put_record\n    manifest=replace(baseline.snapshot.manifest,\n             ~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n                     files=tuple(item for item in baseline.snapshot.manifest.files if item.path != path)\n                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n                     + (SnapshotFile(path=path, content=canonical_json(value), category=\"artifact\"),))))\n                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File \"PYTHON_RUNTIME\\Lib\\dataclasses.py\", line 1596, in replace\n    return _replace(obj, **changes)\n  File \"PYTHON_RUNTIME\\Lib\\dataclasses.py\", line 1630, in _replace\n    return self.__class__(**changes)\n           ~~~~~~~~~~~~~~^^^^^^^^^^^\n  File \"<string>\", line 7, in __init__\n  File \"WORKTREE\\packages\\discovery-runtime\\src\\drm_copilot_discovery\\snapshot.py\", line 162, in __post_init__\n    check_path_collisions(paths + missing)\n    ~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^\n  File \"WORKTREE\\packages\\discovery-runtime\\src\\drm_copilot_discovery\\path_models.py\", line 100, in check_path_collisions\n    raise PathPolicyError(\n        \"PATH_COLLISION\", path, \"Remove duplicate or aliased paths.\"\n    )\ndrm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/product-decisions.yaml': Remove duplicate or aliased paths.\n"}}
{"name": "source-and-accepted-fixtures-stable", "passed": true, "detail": null}
{"task": "P3-T5", "passed": 12, "failed": 1, "elapsed_seconds": 5.402}
```
