/**
 * Derive the trusted outer identity of a host-principal runtime invocation.
 *
 * Every request that carries a protected invocation reference runs under the
 * `host` principal with the agent id, session id, host name and agent role the
 * injected {@link DiscoveryAuthorityProvider} verified. Request data never
 * supplies these values, and a process without a trusted agent identity is
 * refused rather than downgraded to the `local-user` principal.
 */

import type { DiscoveryAuthorityProvider } from "./discovery-authority-provider";
import { consumeToolAuthorizationByBinding } from "./discovery-authorization";
import type { DiscoveryRuntimeInvocation } from "./discovery-runtime";
import type { ConsumeDiscoveryToolAuthorizationInput } from "./repo-automation-service-discovery-types";

/** The complete trusted identity set of a host-principal invocation. */
export type HostInvocationOptions = Readonly<
  Required<
    Pick<
      DiscoveryRuntimeInvocation,
      "principal" | "authorId" | "sessionId" | "hostName" | "agentRole"
    >
  >
>;

/**
 * Return the host-principal options for the agent this process serves.
 *
 * @throws Error `DISCOVERY_AGENT_IDENTITY_REQUIRED` when the provider reports
 *   no trusted agent identity; the caller must not fall back to `local-user`.
 */
export function hostInvocationOptions(
  authority: DiscoveryAuthorityProvider,
): HostInvocationOptions {
  if (authority.agent === null) {
    throw new Error(
      "DISCOVERY_AGENT_IDENTITY_REQUIRED: a request bound to a protected invocation requires the trusted discovery agent identity of this process; it is never run as local-user.",
    );
  }
  return {
    principal: "host",
    authorId: authority.agent.agentId,
    sessionId: authority.context.sessionId,
    hostName: authority.context.host,
    agentRole: authority.agent.role,
  };
}

/**
 * Select the outer identity for one request: host options when the request is
 * bound to a protected invocation, none for a root request.
 *
 * The provider is resolved lazily so a root request never constructs the
 * production provider or reads the process environment.
 */
export function invocationOptions(
  authority: () => DiscoveryAuthorityProvider,
  invocationRef: string | undefined,
): HostInvocationOptions | Record<never, never> {
  return invocationRef === undefined ? {} : hostInvocationOptions(authority());
}

/**
 * Consume the one-use native authorization of one controlled tool call.
 *
 * The trusted binding is the provider's host, session and agent identity with
 * the request's invocation reference, and the protected activation envelope
 * of the workspace; nothing in the tool input selects it. Returns the consumed
 * record's reference, which the gate forwards to the runtime request.
 */
export function consumeHostToolAuthorization(
  authority: DiscoveryAuthorityProvider,
  input: ConsumeDiscoveryToolAuthorizationInput,
): string {
  const identity = hostInvocationOptions(authority);
  const location = authority.location(input.workspaceRoot);
  const envelope = authority.activation(location).envelope();
  return consumeToolAuthorizationByBinding({
    location,
    io: authority.io,
    request: {
      tool: input.tool,
      operation: input.operation,
      inputs: input.inputs,
      invocationRef: input.invocationRef,
    },
    trusted: {
      workspace: envelope.workspace,
      identity: {
        host: identity.hostName,
        session_id: identity.sessionId,
        agent_id: identity.authorId,
        role: identity.agentRole,
        invocation_id: input.invocationRef,
      },
    },
    now: authority.now(),
  }).authorizationRef;
}
