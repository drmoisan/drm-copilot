# P2-T7 consolidated independent review

Timestamp: 2026-10-18 09:42:14 UTC
Started: 2026-10-18 09:41:34 UTC
Command: `poetry run python SCRATCH/issue-980-probe-p2t7.py`
EXIT_CODE: 1

Output summary: 34 schema-checked probes completed; 29 passed and five assertions exposed three bounded production defects. Source hashes were unchanged during execution. Every semantic probe had zero upstream reference, evidence, decision, observation-claim and revision findings after operational fixture correction. Snapshot inputs remained immutable. This is a request for correction within P2-T7, not task acceptance.

1. Ready acceptance ignores criterion platform/mode applicability. A source criterion explicitly limited to browser/online accepts a portable platform or offline mode as ready, with every upstream schema/reference/evidence/decision/claim/revision check passing. Apply exact criterion/client/platform/mode support before exposing ready records; inherited requirements remain obligations and must not silently broaden an observed criterion.
2. Client-only required uncertainty can hide beneath a verified feature summary. With timing required by the client, unknown timing plus an open linked question produces no finding in structural mode or completion when block_on_unresolved_required_behavior=false. The prior claim rule sees global/feature dimensions only. Enforce the non-disableable verified-summary consistency rule over the complete requirement union in this task, including inferred/contradictory states, without changing the accepted prior module.
3. Approved decision criteria are required outside their decision scope. A browser-only approved criterion plus all source criterion tuples and its valid browser scenario still demands that decision criterion for the portable client. Keep current scoped decision criteria confined to the applicable feature/client/platform/mode scope; do not weaken inherited source/profile obligations.

The first run is retained separately. Its unrelated missing decision-criterion evidence reference was corrected to an empty evidence array with the existing approved decision reference; the independent canonical digest oracle now preserves the accepted per-object terminal LF. The valid not-applicable fixture uses a decision scope permitting its connected target criterion. No production or repository test file was edited by this verifier.

The exact reusable cases are in `SCRATCH/issue-980-probe-p2t7.py` and `SCRATCH/issue-980-p2t7-probe-support.py`. No test temporary files or external processes were introduced into repository tests. Earlier inspection attempts at a guessed fixture path and a shell-unexpanded spec glob returned lookup errors; the actual example and exact spec paths were then read. Those attempts were not validation runs or successful evidence.

```text
{
  "probes": 34,
  "passed": 29,
  "failed": 5,
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
    "upstream_codes": [],
    "expected": {
      "dimensions_ok": true,
      "acceptance_ok": true,
      "ready_count": 4,
      "upstream_ok": true
    },
    "snapshot_unchanged": true
  }
]
Traceback (most recent call last):
  File "SCRATCH\issue-980-probe-p2t7.py", line 146, in <module>
    assert result['failed'] == 0 and source_hashes == final_hashes, 'Independent boundary assertions or source binding failed.'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: Independent boundary assertions or source binding failed.
```
