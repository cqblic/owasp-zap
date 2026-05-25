import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import { ListToolsRequestSchema, CallToolRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import express from "express";
import ZapClient from 'zaproxy';

// ZAP configuration
const zapOptions = {
  apiKey: process.env.ZAP_API_KEY || 'secret-key-123',
  proxy: {
    host: '127.0.0.1',
    port: '8080'
  }
};

const zap = new ZapClient(zapOptions);

const server = new Server(
  {
    name: "owasp-zap-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

/**
 * List available tools.
 */
server.setRequestHandler(ListToolsRequestSchema, async (request) => {
  return {
    tools: [
      {
        name: "spider_scan",
        description: "Run a ZAP spider scan against a target URL",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string", description: "The target URL to spider" },
          },
          required: ["url"],
        },
      },
      {
        name: "active_scan",
        description: "Run a ZAP active scan against a target URL",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string", description: "The target URL to scan" },
          },
          required: ["url"],
        },
      },
      {
        name: "get_alerts",
        description: "Get vulnerability alerts for a target URL",
        inputSchema: {
          type: "object",
          properties: {
            baseurl: { type: "string", description: "The base URL to filter alerts for" },
          },
        },
      },
    ],
  };
});

/**
 * Handle tool calls.
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "spider_scan": {
        const result = await zap.spider.scan({ url: args.url });
        return {
          content: [{ type: "text", text: `Spider scan started. Scan ID: ${JSON.stringify(result)}` }],
        };
      }
      case "active_scan": {
        const result = await zap.ascan.scan({ url: args.url });
        return {
          content: [{ type: "text", text: `Active scan started. Scan ID: ${JSON.stringify(result)}` }],
        };
      }
      case "get_alerts": {
        const result = await zap.core.alerts({ baseurl: args.baseurl });
        return {
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
        };
      }
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [{ type: "text", text: `Error: ${error.message}` }],
      isError: true,
    };
  }
});

const app = express();
let transport;

app.get("/sse", async (req, res) => {
  console.log("New SSE connection");
  transport = new SSEServerTransport("/messages", res);
  await server.connect(transport);
});

app.post("/messages", async (req, res) => {
  console.log("New message received");
  await transport.handlePostMessage(req, res);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`ZAP MCP Server listening on port ${PORT}`);
});
