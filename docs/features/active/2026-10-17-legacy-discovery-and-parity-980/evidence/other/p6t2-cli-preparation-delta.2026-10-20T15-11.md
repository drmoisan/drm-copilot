# P6-T2 CLI preparation delta

Status: PREPARATION_READY; read-only preparation only. Source implementation requires accepted P6-T1 and coordinator release. Current service/core/shared sources are provisional observed interfaces, not accepted dependencies. No tests, collection, baselines or behavioral probes were run.

Authority: source_inspection_p6t2_cli_preparation_20261020 / S5_P6T2_cli_preparation_delta. Persisted route matches the unchanged python-typed-engineer-c3-elevated native profile SHA256 6a4be9ed26fba66f7a437895b20c0b4f2d1534d1a6098c39c9fc796aa64bf363. Earlier selector repair remains frozen and outside this preparation.

## Retained sources and precise delta

Reuse execution_progress.phase6_specialist; plan P6-T2; specification Command inventory; p6t1-release-preparation.2026-10-20T13-26.json; p6t1-contract-decisions.2026-10-20T12-25.json; p6t1-core-composition-preparation.2026-10-20T14-30.json (30-operation matrix); p6t1-shared-declarations.2026-10-20T14-25.json; p6t1-gateway-split.2026-10-20T14-46.json. Do not repeat predecessor research or accepted semantic suites.

The specification has 31 console names: 27 public canonical operations plus four aliases. The service schema has 30 canonical operations because read-source, prepare-agent and finalize-agent are additional service routes, not commands in this task's specification inventory. Do not invent console registrations for those three.

## Exact proposed command and registration map

In BOTH root and runtime pyproject, each name below receives prefix dev.discovery. and target drm_copilot_discovery.cli:main_<name with hyphens changed to underscores>. Use explicit fixed wrappers; aliases normalize before service dispatch. No argv[0] plugin loading or dynamic import. The following operation options are proposed exact spellings where the specification leaves spelling open; requiredness and conditional validation remain the existing service matrix's authority. Common options are described below.

| Console suffix | Canonical operation | Operation-specific mapping |
| --- | --- | --- |
| init | init | --system-id -> system_id; --system-name -> system_name; --role -> system_role; --repository-id -> repository_id; repeatable --production-root/--test-root -> production_roots/test_roots; --draft -> draft |
| configure | configure | mutually exclusive required --activate/--deactivate -> configuration_action; --input -> input_path; activate requires input or profile; deactivate rejects input |
| profile | profile | optional --input -> input_path; simultaneous --profile must agree |
| inventory | inventory | repeatable --analyzer -> analyzer_ids; omission leaves configured-all, never serialize an empty explicit list |
| dotnet | inventory | fixed analyzer_ids=['dotnet']; do not permit an overriding analyzer selector |
| vsto | inventory | fixed analyzer_ids=['office-vsto']; same whole-selection consent validation as inventory |
| new-contract | new-contract | --feature-id -> feature_id; --name -> name; optional --capability-group -> capability_group; --input -> input_path |
| new-scenario | new-scenario | --scenario-id -> scenario_id; repeatable --feature-id -> feature_ids; --input -> input_path |
| update-artifact | update-artifact | --kind -> artifact_kind; --path -> artifact_path; --input -> input_path; --expected-sha256 -> expected_sha256; fixed update_action='replace'; no implicit approval |
| link-evidence | link-evidence | --artifact-kind -> artifact_kind; --artifact-id -> artifact_id; --evidence -> evidence_path; --expected-sha256 -> expected_sha256 |
| validate-profile | validate-profile | optional --input -> input_path; --profile retained; exact v1 compatibility only where service permits |
| validate-feature-contract | validate-feature-contract | required --artifact -> artifact_path |
| validate-coverage-ledger | validate-coverage-ledger | required --artifact -> artifact_path |
| validate-runtime-scenario | validate-runtime-scenario | required --artifact -> artifact_path |
| validate-parity-matrix | validate-parity-matrix | required --artifact -> artifact_path |
| validate-unspecified-behavior | validate-unspecified-behavior | required --artifact -> artifact_path |
| validate-product-decision | validate-product-decision | required --artifact -> artifact_path |
| validate-evidence-reference | validate-evidence-reference | required --artifact -> artifact_path |
| validate-decisions | validate-decisions | no operation inputs; entire configured decision/unresolved collection assessment |
| validate-all | validate-all | --mode structural/discovery-complete/parity-complete/planning; optional --output-prefix -> output_prefix |
| validate | validate-all | exactly the same options/defaults; reject positional legacy file/type probing |
| coverage-report | coverage-report | selected root --mode; no operation inputs |
| parity-report | parity-report | selected root --mode; no operation inputs |
| completion-report | completion-report | selected root --mode; no operation inputs; default structural stays explicitly structural |
| generate-acceptance | generate-acceptance | --kind -> acceptance_kind; repeatable --feature-id/--client-id/--mode-id/--platform-id -> corresponding plural selectors; optional --repository-id -> repository_id; --output-format markdown/gherkin/both -> output_format |
| generate-acceptance-scenarios | generate-acceptance | identical accepted generator options/defaults; no unconditional characterization file |
| snapshot-export | snapshot-export | repeatable required --selected-id -> selected_ids; optional repeatable --path -> paths; no destination outside configured roots |
| snapshot-import | snapshot-import | required --manifest -> manifest_path |
| import-inventory | import-inventory | required --manifest -> manifest_path; data only, no plugin/module selector |
| migrate | migrate | --from-version 1/--to-version 2 -> integers; --destination -> destination; exactly one --input -> input_path OR repeatable --path -> paths; same explicit system/repository/root/draft context as init |
| doctor | doctor | no operation inputs; no capability assertion flag |

The CLI need not expose optional approve-decision update fields or protected agent operations merely because the broader service schema supports them. Approval remains an explicitly routed service operation, never a replacement side effect.

## Shared argument, request and result behavior

- Every command: --workspace-root (omitted means current directory only) and optional --profile -> profile_path. Canonicalize the outer root once through injected boundary context; require an existing canonical directory. Never search ancestors or sibling repositories. All input/artifact/profile/manifest/output paths remain workspace-relative data for existing validation.
- Trusted outer --repository-id binds LocalGitReader(workspace_root=..., repository_id=..., run=run_local_git) independently from request inputs. Serialize it into inputs only for init/migrate/generate-acceptance, where allowed. Core owner confirmed this reuse explicitly: bind the exact reader object into installed_local_io and execute; do not add CLI-specific profile/capture logic or infer the provider from a request document. Inventory without the required reader can fail truthfully; no fabricated repository identity.
- Fixed composition: gateway_local.installed_local_io(root, repository, 'local-user', author_id), InstalledInventoryRegistry, aware UTC clock, then service.execute(request, io=..., repository_reader=same_reader, clock=..., analyzer_registry=...). The existing installed provider supplies protected local-user authority and verified installed identity. Do not expose a flag that promotes a request to host authority. No environment-selected modules or interpreters.
- Build the exact closed 2.0.0 ServiceRequest document with required schema/header, id/request_id, recognized canonical operation/mode, explicit root, nullable profile and opaque refs, booleans, format and inputs. Opaque refs remain null for this local CLI. Keep IDs deterministic for identical normalized invocations; a bounded canonical-request digest is a suitable correlation source and grants no authority.
- Use root --mode only on validate-all and coverage/parity/completion reports; default structural. Do not expose agent-output through this unauthenticated local CLI. Reject an incompatible explicit mode, never silently change it.
- --format json/markdown/both only on those four report operations. Default json is sufficient; validate-all still publishes BOTH canonical views. Other operations use envelope format=json. Acceptance --output-format is a distinct operation input and never changes the service envelope.
- Expose --write on optional publication inventory/dotnet/vsto/import-inventory/generate-acceptance aliases/coverage/parity/completion. Mutation commands init/configure/new-contract/new-scenario/update-artifact/link-evidence/snapshot-export/snapshot-import/migrate perform their intrinsic operation without requiring --write. validate-all/validate publish their canonical JSON+Markdown pair by default. An explicit output-prefix does not bypass root authorization.
- Expose --dry-run on intrinsic mutators, optional publishers and validate-all aliases. dry_run+write is meaningful: plan without effects. Do not make these flags mutually exclusive. Pure inspection, doctor and individual validators reject unsupported dry-run/write options.
- Standard output is one deterministic validated DiscoveryResult JSON plus one newline; --format selects included report representation, not a second unframed stdout stream. Exact result.exit_code becomes process exit: 0 pass, 1 blocking findings, 2 invocation/config/path/version, 3 runtime/dependency/I/O/authority failure. Diagnostic report publication never changes a failed gate into exit 0; partial writes never succeed.
- Help exits 0 with fixed usage and no service/provider calls. Invalid argv produces a fixed actionable invocation failure/exit 2 without caller-controlled snippets or provider side effects; use public Finding/DiscoveryResult constructors, not private gateway imports. Unexpected boundary failures use fixed exit-3 diagnostics, not blanket conversion of downstream ValueError to exit 2. Rendering/serialization failure must not emit a partial successful result.
- Disable argparse abbreviation and response-file expansion; reject unknown/duplicate scalar options and conflicting aliases. Reserve argument count and aggregate Unicode text/encoded-byte work before copying, concatenating, sorting, parsing or constructing repeatable lists. Preserve duplicates for rejection instead of silently deduplicating invalid selections. Use current ParseLimits and bounded JSON machinery, not a parallel path/schema engine.

## Ownership and dependency closure

All six proposed new CLI/test paths are currently absent. Suggested disjoint responsibilities after ONE baseline/interface freeze:

- cli_arguments.py: finite command/options table and pure bounded argv -> exact request mapping. cli_commands.py: fixed command/alias metadata and normalized operation defaults. No semantic graph logic.
- cli.py: explicit named console wrappers, injected streams/cwd/ports and fixed installed composition, service invocation and exit/result emission. Explicit wrappers plus compact tables fit the existing three-module plan; do not create further files without a concrete size justification.
- test_cli_commands.py: table-driven invocation of all 31 names, mapping and one-call collaborator identity; exact both-pyproject entrypoint set and runtime import neutrality.
- test_cli_errors.py: parser/path/version/mode/format/flag errors, bounded argument/repeat work, safe diagnostics, local-user versus host refusal, service result/exit consistency, output failure. No subprocess or temporary-file tests.
- test_cli_dry_run.py: every mutation/publication family through shared in-memory service ports; selected real planner compositions for default validate-all pair, dry-run pair and no side effects, report failure propagation and partial-write failure. Reuse accepted P6-T1 operation fixtures instead of re-executing all semantic predecessor cases.
- pyproject.toml and packages/discovery-runtime/pyproject.toml: the same 31 exact registrations to installed module wrappers. Place runtime [tool.poetry.scripts] BEFORE [tool.poetry.dependencies]. tests/discovery_runtime/test_package_contract.py currently treats dependency section through EOF as dependency inventory; preserve its accepted assertion instead of expanding this task.
- The only necessary existing caller edit is tests/scripts/dev_tools/discovery/test_init_cli.py::test_console_script_registered_in_pyproject: expect '"dev.discovery.init" = "drm_copilot_discovery.cli:main_init"'. Preserve every legacy behavior assertion. P6-T3 owns all legacy adapter changes and other CLI/import consumers.

Freeze argument/dispatch signature and fixed wrapper names before a parsing owner and composition owner work concurrently. They can own disjoint source/tests, but the pyproject/registration assertion must have one named owner. If sequential ownership is simpler, the existing three-source-file task remains cohesive. No additional production or schema prerequisite is identified.

Current public dependencies: service.execute; service_contracts DiscoveryResult/Finding-compatible carriers and parse_service_request; service_serialization bounded wire/result validation; models ParseLimits/JsonObject; gateway_local installed_local_io/run_local_git; repository_reader LocalGitReader; analyzer.registry InstalledInventoryRegistry; installed build/resource identity; ActivationStore/InitializationIO/PathPolicy reached through ServiceIO. Reuse the current service_request_rules matrix through the public parser, not its private constants. P6-T1 acceptance and stable source/resource/build-manifest hashes are execution prerequisites, not missing APIs.

The final focused population is 31 command mapping rows plus concrete error/dry-run/registration cases selected by the implementer; no invented executed test count. Measure new modules and every new callable, retain accepted semantic proof by exact dependency bindings, and run Black -> Ruff -> Pyright -> focused Pytest. Packaging closure must refresh installed build identity after new modules/console metadata under the established build-owner sequence; do not invoke a stale checkout build manifest as proof of a usable installed CLI.

## Qualification

One preparation artifact only. No implementation, test execution, extra baseline, source/config/spec/plan/checkpoint/Git changes, or acceptance claim. Minor shell searches using literal wildcard paths returned path errors; subsequent directory-filtered reads located the exact files. They did not execute code or alter the workspace. No unresolved product decision remains; proposed spellings/defaults above must be frozen by the P6-T2 owner against accepted P6-T1 interfaces before implementation.

Observed source bindings (not a behavioral freeze):

- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md: 622fd11cd9ac5cf83ecfa93c32ec418f7e1ab6edaf765cee94953ab5fba8fe8f
- schemas/discovery/v2/service-request.schema.json: e75eab99e20323e3c9b83a46b3595e406c422a6d3051ba4aac428b5ebbde73e9
- packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py: 16518e8b0391469b75265a9f9e6f78a233fe6c9fc821a27cdf71fd43be035cde
- packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py: e62fa8e8703e2936283067be3b1463ed1a0b2e9fdf28d655721fd195fc7c6015
- packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py: 445db9efb87ed725590abfa7d252d3f659590c19293b2412d7e26b192eb457c2
- packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py: 0768ede62df6d11c68b47b249feab821f00271f763570f815374caac77882779
- packages/discovery-runtime/pyproject.toml: c9bb4b58c41a63c7af01ff2e1515d22736a053970589b3f8362ee3054ae3940b
- pyproject.toml: ac61ea8813f500d25a4917e1922b260f8c9225f71ad5419615f6ca5559dd0284
- tests/scripts/dev_tools/discovery/test_init_cli.py: 5ac3972ac82b2da5dc0281167c72efd3e67c66033229ec92bad9188683ab7ea0
- tests/discovery_runtime/test_package_contract.py: 7d15e14b199a0e24d21d3d8ac8a1e61497500c5f7d6e7e9ef69409d1e5ca0e1d

Timestamp (UTC): 2026-10-20T15-11
