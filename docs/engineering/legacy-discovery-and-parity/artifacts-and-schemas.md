# Artifacts and Schemas

Every artifact is governed by a version 2 JSON Schema (draft 2020-12) under
`schemas/discovery/v2/`, identified by a URN of the form
`urn:drm-copilot:discovery:2.0.0:<artifact-kind>`, and carries `$schema`, `schema_version`
(`2.0.0`), `artifact_kind`, `id` and an `extensions` object. The staged copies inside the
wheel are byte-identical to the repository files and are verified by hash before use.

## Version 2 artifact kinds

| Kind | Purpose |
|---|---|
| `domain-profile`, `scope` | Configuration and confirmed scope ([`domain-profile.md`](domain-profile.md)). `scope.status` is `draft` or `confirmed`; `disposition` is `in-scope` or `no-scope` with a rationale. |
| `inventory-snapshot` | Analyzer output: files, components, findings, relationships, diagnostics, exclusions and the capture that produced them. |
| `feature-contract` | One legacy feature: trigger, preconditions, inputs, state transitions, outputs, side effects and the dimension facets (ordering, timing, cancellation, failure, online, offline, mobile, alternate clients, environment, security), each with a disposition. |
| `coverage-ledger` | Every in-scope component with an inspection status and coverage disposition. |
| `runtime-characterization-scenario` | A planned observation with explicit expectation basis, pre- and post-state capture, runs and result status. |
| `evidence-reference` | A locally verifiable pointer (path, digest, captured time) to proof. |
| `unspecified-behavior`, `unspecified-behavior-collection` | Open questions with competing interpretations and their resolution basis. |
| `product-decision`, `product-decision-collection` | Scoped decisions with owner approval and resulting acceptance criteria. |
| `parity-matrix` | Source contracts bound to target implementation records per client, platform, mode and dimension. |
| `implementation-record` | Target-side implementation paths, test references and verification state. |
| `acceptance-specification` | Generated Given/When/Then criteria with readiness and expectation basis. |
| `source-snapshot-manifest`, `extension-result-manifest`, `migration-report` | Transport, imported inventory and migration outcomes ([`migration.md`](migration.md)). |
| `activation`, `discovery-invocation`, `required-output-manifest`, `tool-authorization`, `validation-receipt`, `capability-attestation` | Protected authority records written outside the workspace ([`enforcement.md`](enforcement.md)). |
| `service-request`, `service-result`, `common` | The gateway wire contract and shared definitions. |

## Status and version semantics

The shared vocabularies in `common.schema.json` are:

- `lifecycle`: `draft`, `reviewed`, `superseded`.
- `observation-state`: `verified`, `inferred`, `unknown`, `contradictory`,
  `intentionally-unspecified`. Only `verified` facts carry source evidence; `unknown` and
  `contradictory` require an open unspecified-behavior record; `intentionally-unspecified`
  requires an approved decision.
- `confidence`: `high`, `medium`, `low`, `unknown`.
- `product-decision-state`: `not-required`, `proposed`, `approved`, `rejected`, `superseded`.
- `target-relevance`: `required`, `optional`, `retired` (requires an approved decision),
  `undecided`.
- `inspection-status` (`uninspected`, `inspected`, `blocked`) and `coverage-disposition`
  (`unassigned`, `feature-linked`, `supporting`, `excluded`, `blocked`); a feature-linked or
  supporting component must be inspected.
- `runtime-result`: `not-run`, `observed`, `passed`, `failed`, `blocked`, `not-applicable`;
  a `passed` or `failed` scenario must contain a run with that result.
- Unspecified behavior `status`: `open`, `under-review`, `resolved` (by `approved-decision`
  or `verified-observation`), `intentionally-unspecified` (by approved decision only).
- Acceptance `readiness`: `ready` (basis `verified-source` or `approved-decision`),
  `pending` (basis `unresolved`), `superseded`.
- Implementation `verification_state`: `passed`, `failed`, `blocked`, `not-applicable`.

Version identity is explicit everywhere: `schema_version` is the constant `2.0.0`,
`profile_version` is `2`, receipts carry `receipt_version` `2.0.0`, and the activation
records `required_runtime_major` `2`. A document whose version differs from the installed
runtime fails `structural` validation; nothing is coerced.

## Criteria versus test pass

Framework output stops at criteria. An `acceptance-specification` is `ready` when its
expectation rests on a verified source fact or an approved decision; it never claims that a
target test passed. Test outcomes belong to the consumer's `implementation-record`
(`verification_state`, `test_references`) and to the parity matrix dimension
`verification` (`not-run`, `passed`, `failed`, `not-applicable`), both populated by the
consumer from its own test runs. The parity and completion reports project both sides
without merging them, so a criterion can be ready while its implementation is unverified.

## Frozen version 1 schemas

The seven version 1 schemas under `schemas/discovery/v1/` (feature contract, coverage
ledger, runtime characterization scenario, parity matrix, unspecified behavior record,
product decision record, evidence reference) are frozen and staged into the wheel for
`migrate` to read historical artifacts. No version 1 document is accepted by a version 2
validation mode; the migration path is described in [`migration.md`](migration.md).

## Validation

Validation runs only inside the engine, in one of five modes:

| Mode | Scope |
|---|---|
| `structural` | Every selected document against its schema, the trusted schema catalog and the path policy. |
| `agent-output` | A discovery agent's required outputs for one invocation, used by the stop validation. |
| `discovery-complete` | Structural plus the completion gates for source discovery. |
| `parity-complete` | Discovery-complete plus parity, implementation and acceptance gates. |
| `planning` | The mode named by `planning_prerequisite`, used by the planning gate. |

Each mode re-reads and re-hashes every input it depends on (`input_manifest`) and the
gateway client records the outcome as a protected `validation-receipt`. A receipt is valid
only while its inputs are unchanged; any edit invalidates it. The legacy PowerShell
validator (`DiscoveryValidation.psm1`) retains its export names but returns a
`DISCOVERY_VALIDATION_REQUIRED:` result that directs to the engine and can never pass.

## Evidence and pins

Evidence references record a workspace-relative path, its SHA-256 and the capture time;
every artifact that cites evidence records the digest it saw, and `link-evidence` requires
the current digest of the target artifact (`--expected-sha256`) so a stale reference cannot
be attached. Repository revisions are pinned in every snapshot and ledger; `pinned`
profiles reject a working tree that differs from the pin.

## Safe extensions

Every artifact carries an `extensions` object that the engine preserves verbatim and never
interprets. Separately produced inventories are imported through
`extension-result-manifest` documents (`import-inventory`), validated against the captured
inputs they claim and merged without execution. These are the only sanctioned extension
points; an unknown top-level property fails structural validation.
