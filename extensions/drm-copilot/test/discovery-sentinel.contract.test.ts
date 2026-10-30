/**
 * Replay the shared sentinel consumption fixture against the TypeScript consumer.
 *
 * `tests/fixtures/discovery_host/sentinel-consumption.json` holds the two
 * `host-observation` records the PowerShell gate writes for the capability
 * sentinel agent, placed at the protected-store paths the gate derives. This
 * suite proves `consumeSentinelGrant` finds the tool record from the fixture
 * tool input alone, writes exactly the latch text the fixture pins, leaves the
 * record untouched and refuses a replay, so the PowerShell probe can read
 * consumption from that latch.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { consumeSentinelGrant } from "../src/discovery-sentinel";
import {
  FIXTURE_DIRECTORY,
  LOCATION,
} from "./discovery-authorization-test-support";
import { MemoryStoreIO } from "./discovery-store-test-helpers";

interface SentinelConsumptionFixture {
  readonly consumer_now: string;
  readonly envelopes: {
    readonly tool: { readonly tool_input: Record<string, unknown> };
  };
  readonly records: Record<"tool" | "shell", Record<string, unknown>>;
  readonly relative_paths: Record<"tool" | "shell", string>;
  readonly latch: { readonly relative_path: string; readonly text: string };
  readonly sentinel_result: {
    readonly observed: boolean;
    readonly observationRef: string;
    readonly agentIdPresent: boolean;
    readonly agentType: string;
  };
}

const CONTRACT = JSON.parse(
  fs.readFileSync(
    path.join(FIXTURE_DIRECTORY, "sentinel-consumption.json"),
    "utf8",
  ),
) as SentinelConsumptionFixture;

function storeWithFixtureRecords(): MemoryStoreIO {
  const io = new MemoryStoreIO();
  for (const name of ["tool", "shell"] as const) {
    io.files.set(
      `${LOCATION.directory}/${CONTRACT.relative_paths[name]}`,
      JSON.stringify(CONTRACT.records[name]),
    );
  }
  return io;
}

function consume(io: MemoryStoreIO) {
  return consumeSentinelGrant({
    location: LOCATION,
    io,
    inputs: CONTRACT.envelopes.tool.tool_input,
    now: new Date(CONTRACT.consumer_now),
  });
}

describe("consumeSentinelGrant over the shared consumption fixture", () => {
  it("consumes the gate-built tool record and reports the fixture result", () => {
    const io = storeWithFixtureRecords();

    expect(consume(io)).toEqual(CONTRACT.sentinel_result);
  });

  it("writes exactly the pinned latch text beside the tool record and never rewrites the record", () => {
    const io = storeWithFixtureRecords();
    const recordPath = `${LOCATION.directory}/${CONTRACT.relative_paths.tool}`;
    const before = io.files.get(recordPath);

    consume(io);

    expect(
      io.files.get(`${LOCATION.directory}/${CONTRACT.latch.relative_path}`),
    ).toBe(CONTRACT.latch.text);
    expect(io.files.get(recordPath)).toBe(before);
    expect(io.writtenPaths()).toEqual([
      `${LOCATION.directory}/${CONTRACT.latch.relative_path}`,
    ]);
  });

  it("refuses a second consumption once the latch exists", () => {
    const io = storeWithFixtureRecords();
    consume(io);

    expect(consume(io)).toEqual({
      observed: false,
      observationRef: null,
      agentIdPresent: null,
      agentType: null,
    });
  });
});
