# Acceptance-Criteria to Test Traceability

- Timestamp: 2026-07-18T21-15
- Task: [P5-T4]
- Feature: legacy-discovery-dotnet-vsto-analyzers (#369)

Test module abbreviations:
- TSTX = tests/scripts/dev_tools/discovery/analyzer/test_source_text.py
- TDN = tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py
- TVO = tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py
- TCLI = tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py
- TNEU = tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py

## Spec acceptance criteria (S-AC1..S-AC14)

| Criterion | Implementing tasks | Verifying tests / document |
| --- | --- | --- |
| S-AC1 (dotnet protocol + namespace/type enumeration) | P2-T3,T4,T6 | TDN::TestNamespaceDetection, TestTypeDetection, TestDeclarationFixture, TestEndToEndEmission |
| S-AC2 (event/delegate/subscription, heuristic tag) | P2-T5 | TDN::TestEventDelegateSubscription (positive, heuristic, trap rejection) |
| S-AC3 (VSTO Ribbon-XML detection) | P3-T5,T6 | TVO::TestRibbonDetection (customUI URIs, root, extensibility signals) |
| S-AC4 (VSTO COM-interop detection) | P3-T7 | TVO::TestComInteropDetection (attributes, guid, marshal, progid, using, project) |
| S-AC5 (root read, include/exclude, AnalyzerError fail-fast) | P2-T3,T9; P3-T5,T11 | TDN::TestErrorPathsAndRouting; TVO::TestRoutingAndErrors |
| S-AC6 (parsing-strategy decision recorded in spec) | Satisfied by spec.md | spec.md "Specification Decision: Parsing Strategy" section present (limitations + claim-scoping rule + research citation) |
| S-AC7 (shared line-preserving stripper; XML unstripped) | P1-T1 | TSTX::TestStripper; TVO::test_cs_comment_ribbon_trap_ignored_but_xml_unstripped |
| S-AC8 (TextParseResult isinstance narrowing; no #363 change) | P1-T3; P2-T4,T9; P3-T5,T11 | TSTX::TestTextParseResult; TDN::test_classify_rejects_plain_parse_result; TVO::test_classify_rejects_plain_parse_result |
| S-AC9 (Evidence Reference v1 emission contract) | P1-T2; P2-T6,T10; P3-T8,T11 | TSTX::TestBuildEvidenceId; TDN/TVO::TestEndToEndEmission (schema-valid, key set, id/$schema/schema_version) |
| S-AC10 (twelve-value detection_kind vocabulary) | P2-T6; P3-T8 | TDN/TVO::test_emits_schema_valid_instances (metadata.detection_kind membership) |
| S-AC11 (two console scripts, argparse, exit 0/1/2) | P4-T1,T2,T3,T4 | TCLI::TestSuccessPaths, TestErrorPaths; pyproject.toml [tool.poetry.scripts] |
| S-AC12 (consumer-neutrality feature-scoped list) | P5-T1 | TNEU (all tests) |
| S-AC13 (test-quality policy) | P1-T4,T5; P2-T7..T10; P3-T9..T11; P4-T3,T4; P5-T3; P6-T4,T5 | full analyzer test suite; no temp files; injected clock; parametrized matrices |
| S-AC14 (500-line, no new dependency, no coverage exclusion) | P4-T2; P5-T2,T3 | file-size-verification.md; dependency-and-coverage-config-verification.md |

## User-story acceptance criteria (U-AC1..U-AC8)

| Criterion | Implementing tasks | Verifying tests |
| --- | --- | --- |
| U-AC1 (dev.discovery.dotnet emits anchored C# detections) | P2-T3..T10; P4-T1,T3 | TDN::TestEndToEndEmission; TCLI::TestSuccessPaths[main_dotnet] |
| U-AC2 (dev.discovery.vsto emits ribbon/COM detections) | P3-T5..T11; P4-T1,T3 | TVO::TestEndToEndEmission; TCLI::TestSuccessPaths[main_vsto] |
| U-AC3 (globs honored; exit 0/1/2; --json) | P2-T9; P3-T5; P4-T1,T3,T4 | TDN/TVO include/exclude routing; TCLI (json, exit codes) |
| U-AC4 (schema-valid; specifics only in metadata) | P1-T2; P2-T6,T10; P3-T8,T11 | TDN/TVO::test_emits_schema_valid_instances (top-level key set bounded) |
| U-AC5 (heuristic marking, detection language) | P2-T5,T8 | TDN::TestEventDelegateSubscription (confidence == heuristic) |
| U-AC6 (byte-identical reruns with pinned clock) | P1-T2; P2-T10; P3-T11 | TDN/TVO::test_byte_identical_on_rerun |
| U-AC7 (consumer-neutrality / capture-as-data) | P3-T7; P5-T1 | TVO::test_interop_using_captures_target_as_data; TNEU |
| U-AC8 (quality policy + false-positive-trap fixtures) | P1-T1,T4; P2-T1,T2; P3-T1..T4; P6-T4,T5 | trap tests in TDN/TVO; fixtures under tests/fixtures/discovery_dotnet_vsto/ |

## S-AC6 document verification

The parsing-strategy Specification Decision is present in
`docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/spec.md`
under the heading "Specification Decision: Parsing Strategy", including the stated
regex limitations ("Limitations of regex scanning of C#") and the heuristic
"Claim-scoping rule", citing `research/2026-07-17-dotnet-vsto-analyzers-research.md`.

## Verdict

Every acceptance criterion maps to at least one verifying test or document; no row
is empty.
