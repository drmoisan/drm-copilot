/**
 * Supply the trusted host context and protected-store adapters the discovery
 * agent lifecycle operations (prepare, finalize) consume.
 *
 * The provider is the only place production wiring reads the process
 * environment, platform and clock for discovery authority. Everything it
 * returns is injectable so the service can be tested with in-memory stores and
 * fixed identities; nothing in a request can substitute for these values.
 */

import { randomBytes } from "node:crypto";
import * as os from "node:os";

import { ActivationStore, type ProtectedEnvelope } from "./discovery-authority";
import {
  type AuthorizationStoreIO,
  createNodeAuthorizationStoreIO,
} from "./discovery-authorization";
import {
  type AuthorityLocation,
  type AuthorityPlatform,
  resolveAuthorityLocation,
  type TrustedHostEnvironment,
} from "./discovery-authority-paths";
import type { CapabilityPins } from "./discovery-capabilities";
import type { ReceiptWriter } from "./discovery-finalization";
import {
  createNodeInputReader,
  type InputBytesReader,
} from "./discovery-input-manifest";
import type { PrepareContext } from "./discovery-invocation";

/** Host-verified identity of the agent the current process serves, if any. */
export interface DiscoveryAgentContext {
  readonly agentId: string;
  readonly role: string;
}

export interface DiscoveryAuthorityProvider {
  /** Trusted root launch context (host, session, parent agent, parent role). */
  readonly context: PrepareContext;
  /** Agent identity when this service runs for a discovery specialist. */
  readonly agent: DiscoveryAgentContext | null;
  /** Protected store seam with directory listing for one-use authorizations. */
  readonly io: AuthorizationStoreIO;
  readonly reader: InputBytesReader;
  readonly writer: Omit<ReceiptWriter, "kind" | "host">;
  /** Host-pinned configuration and hook hashes an attestation must reproduce. */
  readonly capabilityPins?: CapabilityPins;
  location(workspaceRoot: string): AuthorityLocation;
  activation(location: AuthorityLocation): { envelope(): ProtectedEnvelope };
  now(): Date;
  nonce(): string;
}

/** Environment keys the native host adapters populate for the gateway. */
export const DISCOVERY_ENVIRONMENT_KEYS = {
  host: "DRM_DISCOVERY_HOST",
  sessionId: "DRM_DISCOVERY_SESSION_ID",
  parentAgentId: "DRM_DISCOVERY_PARENT_AGENT_ID",
  parentRole: "DRM_DISCOVERY_PARENT_ROLE",
  agentId: "DRM_DISCOVERY_AGENT_ID",
  agentRole: "DRM_DISCOVERY_AGENT_ROLE",
  localAppData: "LOCALAPPDATA",
  xdgStateHome: "XDG_STATE_HOME",
} as const;

export interface NodeAuthorityProviderOptions {
  readonly env?: Readonly<Record<string, string | undefined>>;
  readonly platform?: NodeJS.Platform;
  readonly homedir?: string;
  readonly io?: AuthorizationStoreIO;
  readonly reader?: InputBytesReader;
  readonly now?: () => Date;
  readonly nonce?: () => string;
  readonly writer?: Omit<ReceiptWriter, "kind" | "host">;
  readonly component?: "extension" | "standalone-mcp";
  readonly buildSha256?: string;
}

/** Map the Node platform onto the authority platform policy. */
export function authorityPlatform(
  platform: NodeJS.Platform,
): AuthorityPlatform {
  // Windows and macOS have fixed state roots; every other POSIX host uses XDG.
  if (platform === "win32") {
    return "windows";
  }
  if (platform === "darwin") {
    return "macos";
  }
  return "linux";
}

/** Build the trusted host environment from process values. */
export function trustedHostEnvironment(
  platform: NodeJS.Platform,
  homedir: string,
  env: Readonly<Record<string, string | undefined>>,
): TrustedHostEnvironment {
  return {
    platform: authorityPlatform(platform),
    userHome: homedir,
    localAppData: env[DISCOVERY_ENVIRONMENT_KEYS.localAppData] ?? null,
    xdgStateHome: env[DISCOVERY_ENVIRONMENT_KEYS.xdgStateHome] ?? null,
  };
}

/** Build the production provider; every seam is overridable for tests. */
export function createNodeDiscoveryAuthorityProvider(
  options: NodeAuthorityProviderOptions = {},
): DiscoveryAuthorityProvider {
  const env = options.env ?? process.env;
  const platform = options.platform ?? process.platform;
  const homedir = options.homedir ?? os.homedir();
  const io = options.io ?? createNodeAuthorizationStoreIO();
  const nonce = options.nonce ?? (() => randomBytes(16).toString("hex"));
  const agentId = env[DISCOVERY_ENVIRONMENT_KEYS.agentId];
  const agentRole = env[DISCOVERY_ENVIRONMENT_KEYS.agentRole];
  return {
    context: {
      host: env[DISCOVERY_ENVIRONMENT_KEYS.host] ?? "",
      sessionId: env[DISCOVERY_ENVIRONMENT_KEYS.sessionId] ?? "",
      parentAgentId: env[DISCOVERY_ENVIRONMENT_KEYS.parentAgentId] ?? "",
      parentRole: env[DISCOVERY_ENVIRONMENT_KEYS.parentRole] ?? null,
    },
    agent:
      agentId !== undefined && agentRole !== undefined
        ? { agentId, role: agentRole }
        : null,
    io,
    reader: options.reader ?? createNodeInputReader(),
    writer: options.writer ?? {
      component: options.component ?? "extension",
      id: `gateway-${nonce()}`,
      build_sha256: options.buildSha256 ?? "0".repeat(64),
    },
    location(workspaceRoot) {
      return resolveAuthorityLocation(
        workspaceRoot,
        trustedHostEnvironment(platform, homedir, env),
      );
    },
    activation(location) {
      return new ActivationStore({ location, io, nonce });
    },
    now: options.now ?? (() => new Date()),
    nonce,
  };
}
