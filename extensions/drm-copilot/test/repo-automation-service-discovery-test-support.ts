/**
 * Shared fixtures for the service-level discovery suites: a buffered output,
 * a service factory over an in-memory launcher, and an authority provider
 * built from the P8-T4 invocation fixtures.
 */

import { jest } from "@jest/globals";

import type { DiscoveryAuthorityProvider } from "../src/discovery-authority-provider";
import type { RepoAutomationService } from "../src/repo-automation-service";
import { createRepoAutomationService } from "../src/repo-automation-service";
import { WRITER } from "./discovery-finalization-test-support";
import {
  ACTIVATION,
  CONTEXT,
  LOCATION,
  NOW,
  WORKSPACE,
} from "./discovery-invocation-test-support";
import {
  MemoryInputReader,
  type MemoryStoreIO,
} from "./discovery-store-test-helpers";
import { FAKE_INTERPRETER, type FakeLauncher } from "./discovery-test-helpers";

export const output = { appendLine: jest.fn<(line: string) => void>() };

export function service(
  launcher: FakeLauncher,
  authority?: DiscoveryAuthorityProvider,
): RepoAutomationService {
  return createRepoAutomationService({
    extensionRoot: "C:/extension",
    output,
    discovery: {
      runtime: { launcher, detectInterpreter: () => FAKE_INTERPRETER },
      ...(authority === undefined ? {} : { authority }),
    },
  });
}

export function provider(
  io: MemoryStoreIO,
  overrides: Partial<DiscoveryAuthorityProvider> = {},
): DiscoveryAuthorityProvider {
  return {
    context: CONTEXT,
    agent: null,
    io,
    reader: new MemoryInputReader(),
    writer: WRITER,
    location: () => LOCATION,
    activation: () => ACTIVATION,
    now: () => NOW,
    nonce: () => "0123456789abcdef0001",
    ...overrides,
  };
}

export const WS_ROOT = WORKSPACE.workspace_root;
