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
import type { DiscoveryRuntimeInvocation } from "./discovery-runtime";

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
