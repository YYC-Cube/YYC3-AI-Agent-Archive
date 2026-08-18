/**
 * file server.test.ts
 * description @yyc3/i18n-core server.ts 单元测试
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.3.0
 * created 2026-04-24
 * updated 2026-04-24
 * status active
 * tags [test],[mcp],[unit]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief @yyc3/i18n-core server.ts 单元测试
 */
import { beforeEach, describe, expect, it } from "vitest";
import { MCPServer } from "../../lib/mcp/server.js";
import type { MCPMessage, MCPTransport } from "../../lib/mcp/types.js";

interface MockTransport extends MCPTransport {
  getSentMessages(): MCPMessage[];
  getMessageHandler(): ((message: MCPMessage) => void) | null;
}

function createMockTransport(): MockTransport {
  let messageHandler: ((message: MCPMessage) => void) | null = null;
  const sentMessages: MCPMessage[] = [];

  return {
    connected: false,
    async connect() {
      this.connected = true;
    },
    async send(message: MCPMessage) {
      sentMessages.push(message);
    },
    onMessage(handler: (message: MCPMessage) => void) {
      messageHandler = handler;
    },
    async close() {
      this.connected = false;
    },
    getSentMessages() {
      return sentMessages;
    },
    getMessageHandler() {
      return messageHandler;
    },
  } as MockTransport;
}

async function expectNoResponseForId(
  transport: MockTransport,
  existingCount: number,
): Promise<void> {
  // Give the handler microtask time to settle before checking
  await new Promise((r) => setTimeout(r, 5));
  expect(transport.getSentMessages().length).toBe(existingCount);
}

describe("MCPServer", () => {
  let server: MCPServer;
  let transport: MockTransport;

  beforeEach(() => {
    transport = createMockTransport();
    server = new MCPServer({
      name: "test-i18n-server",
      version: "1.0.0",
      transport: transport as MCPTransport,
    });
  });

  async function sendMessage(message: MCPMessage): Promise<MCPMessage> {
    const handler = transport.getMessageHandler();
    if (!handler) throw new Error("No handler registered");
    await handler(message);
    return transport.getSentMessages()[transport.getSentMessages().length - 1]!;
  }

  describe("start", () => {
    it("should connect transport and register handler", async () => {
      await server.start();
      expect(transport.connected).toBe(true);
    });

    it("should register message handler on transport", async () => {
      await server.start();
      expect(transport.getMessageHandler()).toBeDefined();
    });
  });

  describe("initialize response", () => {
    it("should respond to initialize request", async () => {
      await server.start();

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      expect(response.id).toBe(1);
      expect(response.result).toBeDefined();
    });

    it("should respond with server capabilities", async () => {
      await server.start();

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const result = response.result as Record<string, unknown>;
      expect(result.capabilities).toBeDefined();
      expect(result.serverInfo).toBeDefined();
    });
  });

  describe("tools/list", () => {
    it("should respond with empty tools list by default", async () => {
      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/list",
        params: {},
      });

      expect(response.id).toBe(2);
      expect(response.result).toBeDefined();
    });
  });

  describe("registerTool", () => {
    it("should register a tool and include it in tools/list", async () => {
      server.registerTool(
        { name: "test-tool", description: "A test tool", inputSchema: { type: "object", properties: {} } },
        async () => ({ content: [{ type: "text", text: "test" }] }),
      );

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/list",
        params: {},
      });

      const tools = (response.result as Record<string, unknown>).tools as Array<Record<string, unknown>>;
      expect(tools.length).toBe(1);
      expect(tools[0]!.name).toBe("test-tool");
    });
  });

  describe("tools/call", () => {
    it("should execute tool handler", async () => {
      server.registerTool(
        { name: "echo", description: "Echo tool", inputSchema: { type: "object", properties: {} } },
        async (args: Record<string, unknown>) => ({
          content: [{ type: "text" as const, text: JSON.stringify(args) }],
        }),
      );

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/call",
        params: {
          name: "echo",
          arguments: { message: "hello" },
        },
      });

      expect(response.id).toBe(2);
      expect(response.result).toBeDefined();
    });

    it("should handle params without arguments field", async () => {
      server.registerTool(
        { name: "no-args", description: "Tool with no args", inputSchema: { type: "object", properties: {} } },
        async () => ({ content: [{ type: "text" as const, text: "no-args-called" }] }),
      );

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      // Send tools/call WITHOUT arguments field to test ?? {} fallback
      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/call",
        params: {
          name: "no-args",
        } as Record<string, unknown>,
      });

      expect(response.id).toBe(2);
      expect(response.result).toBeDefined();
    });

    it("should return error for unknown tool", async () => {
      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/call",
        params: {
          name: "nonexistent",
          arguments: {},
        },
      });

      expect(response.error).toBeDefined();
    });

    it("should handle handler throwing an error", async () => {
      server.registerTool(
        { name: "thrower", description: "Tool that throws", inputSchema: { type: "object", properties: {} } },
        async () => {
          throw new Error("Handler crashed");
        },
      );

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/call",
        params: {
          name: "thrower",
          arguments: {},
        },
      });

      expect(response.result).toBeDefined();
      expect((response.result as Record<string, unknown>).isError).toBe(true);
      const content = (response.result as Record<string, unknown>).content as Array<Record<string, unknown>>;
      expect(content[0]!.text).toContain("Handler crashed");
    });

    it("should handle handler throwing a non-Error value", async () => {
      server.registerTool(
        { name: "string-thrower", description: "Throws string", inputSchema: { type: "object", properties: {} } },
        async () => {
          // eslint-disable-next-line no-throw-literal
          throw "Something went wrong";
        },
      );

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/call",
        params: {
          name: "string-thrower",
          arguments: {},
        },
      });

      expect(response.result).toBeDefined();
      const content = (response.result as Record<string, unknown>).content as Array<Record<string, unknown>>;
      expect(content[0]!.text).toContain("Something went wrong");
    });
  });

  describe("notifications/initialized", () => {
    it("should not send any response for initialization notification", async () => {
      await server.start();
      const sentCount = transport.getSentMessages().length;

      const handler = transport.getMessageHandler();
      expect(handler).toBeDefined();
      await handler!({
        jsonrpc: "2.0",
        method: "notifications/initialized",
      });

      // No additional response should be sent
      expect(transport.getSentMessages().length).toBe(sentCount);
    });
  });

  describe("resources/list", () => {
    it("should respond with empty resources list by default", async () => {
      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "resources/list",
        params: {},
      });

      expect(response.id).toBe(2);
      const result = response.result as Record<string, unknown>;
      expect(result.resources).toEqual([]);
    });

    it("should list registered resources", async () => {
      const resource: MCPResource = {
        uri: "i18n://locales",
        name: "Supported Locales",
        description: "List of supported locales",
        mimeType: "application/json",
      };
      server.registerResource(resource);

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "resources/list",
        params: {},
      });

      expect(response.id).toBe(2);
      const result = response.result as Record<string, unknown>;
      expect(result.resources).toHaveLength(1);
      expect((result.resources as Array<Record<string, unknown>>)[0]!.uri).toBe("i18n://locales");
    });
  });

  describe("resources/read", () => {
    it("should return error for non-existent resource", async () => {
      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "resources/read",
        params: {
          uri: "i18n://nonexistent",
        },
      });

      expect(response.error).toBeDefined();
      expect(response.error).toMatchObject({ code: -32602 });
    });

    it("should respond with resource content for existing resource", async () => {
      server.registerResource({
        uri: "i18n://locales",
        name: "Supported Locales",
        mimeType: "application/json",
      });

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "resources/read",
        params: {
          uri: "i18n://locales",
        },
      });

      expect(response.id).toBe(2);
      const result = response.result as Record<string, unknown>;
      expect(result.contents).toHaveLength(1);
      expect((result.contents as Array<Record<string, unknown>>)[0]!.uri).toBe("i18n://locales");
    });

    it("should use default mimeType when not provided on resource", async () => {
      server.registerResource({
        uri: "i18n://data",
        name: "Data",
      });

      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "resources/read",
        params: {
          uri: "i18n://data",
        },
      });

      const result = response.result as Record<string, unknown>;
      expect((result.contents as Array<Record<string, unknown>>)[0]!.mimeType).toBe("text/plain");
    });
  });

  describe("ping", () => {
    it("should respond with empty result to ping", async () => {
      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "ping",
      });

      expect(response.id).toBe(2);
      expect(response.result).toEqual({});
    });
  });

  describe("unknown method", () => {
    it("should return method not found error", async () => {
      await server.start();

      await sendMessage({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "test-client", version: "1.0.0" },
        },
      });

      const response = await sendMessage({
        jsonrpc: "2.0",
        id: 2,
        method: "unknown_method",
      });

      expect(response.error).toBeDefined();
      expect(response.error).toMatchObject({ code: -32601 });
    });
  });

  describe("getResources", () => {
    it("should return registered resources", () => {
      server.registerResource({ uri: "i18n://test", name: "Test" });
      const resources = server.getResources();
      expect(resources).toHaveLength(1);
      expect(resources[0]!.uri).toBe("i18n://test");
    });

    it("should return empty array when no resources registered", () => {
      const resources = server.getResources();
      expect(resources).toEqual([]);
    });

    it("should return a copy of resources array", () => {
      server.registerResource({ uri: "i18n://test", name: "Test" });
      const resources = server.getResources();
      resources.push({ uri: "i18n://extra", name: "Extra" });
      expect(server.getResources()).toHaveLength(1);
    });
  });

  describe("close", () => {
    it("should close transport", async () => {
      await server.start();
      await server.stop();
      expect(transport.connected).toBe(false);
    });
  });
});
