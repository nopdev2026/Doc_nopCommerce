#!/usr/bin/env node
/**
 * nopdev-docs-mcp — entrada local (transporte stdio).
 * No imprimir nada por stdout salvo el protocolo MCP; los mensajes van a stderr.
 */

import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createServer, REPO_ROOT } from "./server.js";

const server = createServer();
const transport = new StdioServerTransport();
await server.connect(transport);
console.error(`nopdev-docs-mcp listo (stdio). Manuales en: ${REPO_ROOT}`);
