#!/usr/bin/env node
/**
 * nopdev-docs-mcp — entrada remota (Streamable HTTP).
 *
 * Expone las mismas herramientas que index.js (stdio) sobre HTTP, con autenticación
 * por token: cabecera `Authorization: Bearer <MCP_TOKEN>` o query `?token=<MCP_TOKEN>`.
 *
 * Variables de entorno:
 *   MCP_TOKEN  (obligatoria) token de acceso
 *   PORT       (opcional, por defecto 8787)
 *
 * Diseño stateless: cada petición crea su propia instancia de servidor y transporte,
 * así que no hay estado de sesión que conservar entre peticiones.
 */

import { createServer as createNodeServer } from "node:http";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { createServer, REPO_ROOT } from "./server.js";

const PORT = Number.parseInt(process.env.PORT || "8787", 10);
const TOKEN = process.env.MCP_TOKEN;

if (!TOKEN) {
  console.error("Falta la variable MCP_TOKEN: el servidor remoto no arranca sin token de acceso.");
  process.exit(1);
}

function sendJson(res, status, obj, extraHeaders = {}) {
  if (res.headersSent) return;
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    ...extraHeaders,
  });
  res.end(JSON.stringify(obj));
}

function isAuthorized(req, url) {
  const auth = req.headers.authorization || "";
  if (auth === `Bearer ${TOKEN}`) return true;
  const q = url.searchParams.get("token");
  if (q && q === TOKEN) return true;
  return false;
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on("data", (c) => {
      size += c.length;
      if (size > 5_000_000) {
        reject(new Error("Cuerpo demasiado grande"));
        req.destroy();
        return;
      }
      chunks.push(c);
    });
    req.on("end", () => {
      if (chunks.length === 0) return resolve(undefined);
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString("utf8")));
      } catch {
        reject(new Error("JSON inválido en el cuerpo de la petición"));
      }
    });
    req.on("error", reject);
  });
}

const serverInfo = {
  name: "nopdev-docs",
  transport: "streamable-http",
  repo: REPO_ROOT,
};

const httpServer = createNodeServer(async (req, res) => {
  // CORS (para clientes basados en navegador en fases futuras)
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type, Accept, MCP-Protocol-Version, Mcp-Session-Id");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");

  const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  if (url.pathname === "/health") {
    sendJson(res, 200, { ok: true, ...serverInfo });
    return;
  }

  if (url.pathname !== "/mcp") {
    sendJson(res, 404, { error: "No encontrado. El endpoint MCP es /mcp y la salud es /health." });
    return;
  }

  if (!isAuthorized(req, url)) {
    sendJson(
      res,
      401,
      { jsonrpc: "2.0", error: { code: -32001, message: "No autorizado: falta o es incorrecto el token." }, id: null },
      { "WWW-Authenticate": 'Bearer realm="nopdev-docs"' }
    );
    return;
  }

  // stateless: servidor + transporte nuevos por petición
  const server = createServer();
  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined,
    enableJsonResponse: true,
  });
  res.on("close", () => {
    transport.close().catch(() => {});
    server.close().catch(() => {});
  });

  try {
    const body = req.method === "POST" ? await readJsonBody(req) : undefined;
    await server.connect(transport);
    await transport.handleRequest(req, res, body);
  } catch (e) {
    console.error(`Error en /mcp: ${e.message}`);
    sendJson(res, 500, {
      jsonrpc: "2.0",
      error: { code: -32603, message: e.message || "Error interno" },
      id: null,
    });
  }
});

httpServer.listen(PORT, "0.0.0.0", () => {
  console.error(
    `nopdev-docs-mcp listo (http). Puerto ${PORT} · endpoint /mcp · auth Bearer token · manuales en: ${REPO_ROOT}`
  );
});
