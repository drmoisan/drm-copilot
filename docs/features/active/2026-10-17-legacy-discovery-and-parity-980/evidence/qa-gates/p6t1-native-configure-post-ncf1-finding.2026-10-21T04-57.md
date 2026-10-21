# P6-T1 post-NCF1 factory finding

Timestamp: 2026-10-21T04-57 UTC

Command: exact retained constructor-only probe; installed package inputs updated.

EXIT_CODE: 0 (diagnostic completed; factory construction failed)

Output Summary: One factory call raised ValueError at gateway_local.py:374 before ActivationStore.local. The probe recorded zero Git, protected-port or effect calls, no service import, and no timeout or overflow. All five source/installed bindings remained unchanged.

The rejected predicate was `state.resolve() != base.resolve() / state.relative_to(base)`. The separately authorized operand comparison called the installed RegistryLocation contract once. Resolving the complete contract path inserts `Packages/OpenAI.Codex_2p2nqsd0c76g0/LocalCache/Local` beneath the trusted state base; resolving the base alone leaves it unchanged. Both operands retain the exact `drm-copilot/discovery/workspaces/<workspace-digest>` suffix. The actual path remains within the resolved trusted base and outside the workspace. Exact operands are retained losslessly in the comparison receipt's raw stdout; readable evidence uses relative components.

The production helper assumes that resolving the base and then appending the suffix is equivalent to resolving the complete state path. The observed host resolution violates that assumption. The 26 passing NCF1 controls remain valid for their injected models, which did not include this parent-versus-subtree difference. The earlier activation-store rejection, successful initialization, and current helper rejection remain separate evidence.

The proposed correction is limited to gateway_local.py and test_gateway_factory.py: canonicalize the already validated complete state path, require that it remain beneath the resolved trusted base with the exact RegistryLocation-derived suffix, and retain strict store recanonicalization and external-location checks. Do not hardcode the observed package prefix. This is a proposal pending repair release.

Scope remained read-only apart from diagnostic evidence. Exactly one constructor observation and one separately authorized operand comparison ran, each with a 30-second bound. No service/native operation, test, package rebuild or Git/checkpoint change was performed. The existing source and tests remain frozen.
