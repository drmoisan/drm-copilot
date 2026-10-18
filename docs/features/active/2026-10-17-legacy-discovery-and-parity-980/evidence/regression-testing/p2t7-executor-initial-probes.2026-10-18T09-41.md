# P2-T7 initial independent boundary probes

Timestamp: 2026-10-18 09:41:05 UTC
Started: 2026-10-18 09:40:20 UTC
Command: `poetry run python SCRATCH/issue-980-probe-p2t7.py`
EXIT_CODE: 1

Output summary: 34 completed probes; 25 passed and 9 expectations failed. This is retained initial review evidence, not task acceptance. Decision fixtures still contain an unrelated missing evidence reference, and the independent digest oracle omitted the accepted canonical JSON terminal LF; those operational fixture/oracle issues will be corrected before consolidating production findings. No production or unit-test files were modified by this verifier.

```text
{
  "probes": 34,
  "passed": 25,
  "failed": 9,
  "source_hashes": {
    "packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py": "a1d5a34597deb4d0e6cfa925c6d8678ec0ec36db514430ed42bc918a07ff5f05",
    "packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py": "35daf9c963b73975774d08ace7f2d7becde12f8ff8819039c6c92a0b1f87a384"
  },
  "source_hashes_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py": "a1d5a34597deb4d0e6cfa925c6d8678ec0ec36db514430ed42bc918a07ff5f05",
    "packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py": "35daf9c963b73975774d08ace7f2d7becde12f8ff8819039c6c92a0b1f87a384"
  }
}
[
  {
    "name": "scenario cannot claim a different criterion platform",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [],
    "ready": [
      "scenario-alpha"
    ],
    "upstream_codes": [],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": false,
      "ready_count": 0,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "scenario cannot claim a different criterion mode",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [],
    "ready": [
      "scenario-alpha"
    ],
    "upstream_codes": [],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": false,
      "ready_count": 0,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "client-required unknown cannot hide beneath a verified summary False",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [],
    "ready": [
      "scenario-alpha"
    ],
    "upstream_codes": [],
    "expected": {
      "dimensions_ok": false,
      "acceptance_ok": true,
      "ready_count": 1,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "client-required unknown cannot hide beneath a verified summary True",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [],
    "ready": [
      "scenario-alpha"
    ],
    "upstream_codes": [],
    "expected": {
      "dimensions_ok": false,
      "acceptance_ok": true,
      "ready_count": 1,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "configured not-applicable dimension has an explicit approval",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [
      {
        "code": "ACCEPTANCE_REQUIRED",
        "pointer": "/acceptance_criteria",
        "message": "Missing ready criterion/client/platform/mode: criterion-decision-alpha/browser-example/browser/online."
      }
    ],
    "ready": [
      "scenario-alpha",
      "scenario-decision"
    ],
    "upstream_codes": [
      "REFERENCE_MISSING"
    ],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": true,
      "ready_count": 2,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "scoped target decision does not create obligations for a different client",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [
      {
        "code": "ACCEPTANCE_REQUIRED",
        "pointer": "/acceptance_criteria",
        "message": "Missing ready criterion/client/platform/mode: criterion-decision-alpha/portable-example/browser/online."
      },
      {
        "code": "ACCEPTANCE_REQUIRED",
        "pointer": "/acceptance_criteria",
        "message": "Missing ready criterion/client/platform/mode: criterion-decision-alpha/portable-example/portable/online."
      }
    ],
    "ready": [
      "scenario-alpha",
      "scenario-decision",
      "scenario-portable-browser",
      "scenario-portable"
    ],
    "upstream_codes": [
      "REFERENCE_MISSING"
    ],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": true,
      "ready_count": 4,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "decision cannot supply a ready result outside its client scope",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [
      {
        "code": "ACCEPTANCE_CLAIM",
        "pointer": "/criterion_id",
        "message": "Ready expectation requires one eligible source or approved criterion."
      }
    ],
    "ready": [],
    "upstream_codes": [
      "REFERENCE_MISSING"
    ],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": false,
      "ready_count": 0,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "approved target criterion preserves an open optional legacy observation",
    "passed": false,
    "dimension_findings": [],
    "acceptance_findings": [],
    "ready": [
      "scenario-alpha",
      "scenario-decision"
    ],
    "upstream_codes": [
      "REFERENCE_MISSING"
    ],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": true,
      "ready_count": 2,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  },
  {
    "name": "source digest matches independent canonical JSON encoding",
    "passed": false
  }
]
Traceback (most recent call last):
  File "SCRATCH\issue-980-probe-p2t7.py", line 146, in <module>
    assert result['failed'] == 0 and source_hashes == final_hashes, 'Independent boundary assertions or source binding failed.'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: Independent boundary assertions or source binding failed.
```
