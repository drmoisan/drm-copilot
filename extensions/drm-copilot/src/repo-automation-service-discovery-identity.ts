/**
 * Derive the outer identity of a host-principal runtime invocation from the
 * one-use authorization the MCP gate consumed for it.
 *
 * Every request that carries a protected invocation reference runs under the
 * `host` principal with the agent id, session id, host name and role the
 * consumed `tool-authorization` record binds, which the native hook took from
 * its own payload. The server process holds no identity: request data never
 * supplies these values, and a bound request without a consumed record is
 * refused rather than downgraded to the `local-user` principal.
 */

import type { DiscoveryAuthorityProvider } from "./discovery-authority-provider";
import type { ConsumedAuthorization } from "./discovery-authorization";
import { consumeToolAuthorizationByBinding } from "./discovery-authorization-binding";
import { refuse } from "./discovery-authorization-record";
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

/** Return the host-principal options the consumed record's identity names. */
export function hostInvocationOptions(
  consumed: ConsumedAuthorization,
): HostInvocationOptions {
  return {
    principal: "host",
    authorId: consumed.identity.agent_id,
    sessionId: consumed.identity.session_id,
    hostName: consumed.identity.host,
    agentRole: consumed.identity.role,
  };
}

/**
 * Select the outer identity for one request: host options from the consumed
 * record when the request is bound to a protected invocation, none for a root
 * request.
 *
 * @throws DiscoveryAuthorizationError `DISCOVERY_HOST_BINDING_REQUIRED` when a
 *   bound request has no consumed record, or `AUTHORIZATION_IDENTITY` when the
 *   consumed record names another invocation; the caller never falls back to
 *   `local-user`.
 */
export function invocationOptions(
  consumed: ConsumedAuthorization | undefined,
  invocationRef: string | undefined,
): HostInvocationOptions | Record<never, never> {
  if (invocationRef === undefined) {
    return {};
  }
  if (consumed === undefined) {
    throw refuse(
      "DISCOVERY_HOST_BINDING_REQUIRED",
      `DISCOVERY_HOST_BINDING_REQUIRED: a request bound to invocation ${invocationRef} requires the one-use authorization the host gate issued for it; it is never run as local-user.`,
    );
  }
  if (consumed.identity.invocation_id !== invocationRef) {
    throw refuse(
      "AUTHORIZATION_IDENTITY",
      `AUTHORIZATION_IDENTITY: the consumed authorization binds invocation ${consumed.identity.invocation_id}, not ${invocationRef}.`,
    );
  }
  return hostInvocationOptions(consumed);
}

/**
 * Consume the one-use native authorization of one controlled tool call.
 *
 * The request's `invocation_ref` selects the invocation partition and the
 * protected activation envelope supplies the workspace binding; nothing in the
 * tool input supplies an identity. Returns the consumed record, whose identity
 * the service carries into the runtime request.
 */
export function consumeHostToolAuthorization(
  authority: DiscoveryAuthorityProvider,
  input: ConsumeDiscoveryToolAuthorizationInput,
): ConsumedAuthorization {
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
    workspace: envelope.workspace,
    now: authority.now(),
  });
}
