#!/usr/bin/env node
/**
 * nopdev-docs-mcp — servidor MCP local (stdio)
 * Expone los manuales de nopCommerce 4.90.8 (fuente markdown de este repo)
 * como herramientas MCP: toc, search, get_chapter y reload.
 *
 * Uso: node index.js   (transporte stdio; no imprimir nada por stdout salvo el protocolo)
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { z } from "zod";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(HERE, "..");

const MANUALS = {
  desarrollo: {
    file: "Manual de desarrollo V01 de nopCommerce.md",
    label: "Manual de desarrollo",
  },
  usuario: {
    file: "Manual de usuario V01 de nopCommerce.md",
    label: "Manual de usuario",
  },
};

const MAX_RESULTS_DEFAULT = 30;
const MAX_RESULTS_LIMIT = 100;
const MAX_CHAPTER_CHARS = 150_000;

/** Quita acentos manteniendo la longitud (para buscar "capitulo" y encontrar "capítulo"). */
function foldAccents(s) {
  return s.replace(
    /[àáâãäåèéêëìíîïòóôõöùúûüñç]/gi,
    (c) => c.normalize("NFD")[0]
  );
}

/** Parsea un manual: devuelve secciones (parte/capítulo/apéndice/índice) con líneas. */
function parseManual(key) {
  const meta = MANUALS[key];
  const abs = path.join(REPO_ROOT, meta.file);
  if (!fs.existsSync(abs)) {
    throw new Error(`No existe el manual: ${abs}`);
  }
  const text = fs.readFileSync(abs, "utf8");
  const lines = text.split(/\r?\n/);

  const marks = [];
  for (let i = 0; i < lines.length; i++) {
    const h1 = /^# (Parte\s+[IVXLCDM]+)\s*[-–—]\s*(.+?)\s*\{#([\w-]+)\}\s*$/.exec(lines[i]);
    if (h1) {
      marks.push({ level: 1, type: "parte", roman: h1[1], title: h1[2], anchor: h1[3], line: i });
      continue;
    }
    if (/^# /.test(lines[i]) && i > 0) {
      marks.push({ level: 1, type: "titulo", title: lines[i].replace(/^# /, "").trim(), line: i });
      continue;
    }
    const h2 = /^## (.+?)\s*\{#([\w-]+)\}\s*$/.exec(lines[i]);
    if (h2) {
      const m = /^Cap[íi]tulo\s+(\d+)\s*[-–—]\s*(.+)$/.exec(h2[1]);
      const a = /^Ap[ée]ndice\s+([A-ZÁÉÍÓÚ])\s*[-–—]\s*(.+)$/.exec(h2[1]);
      let type = "seccion", number = null, title = h2[1];
      if (m) { type = "capitulo"; number = parseInt(m[1], 10); title = m[2].trim(); }
      else if (a) { type = "apendice"; number = a[1]; title = a[2].trim(); }
      else if (/^Índice general$/i.test(h2[1])) { type = "indice"; }
      marks.push({ level: 2, type, number, title, anchor: h2[2], line: i });
    }
  }

  // Rango de cada sección de nivel 2: hasta la siguiente marca de nivel 1 o 2.
  const sections = [];
  for (let mi = 0; mi < marks.length; mi++) {
    const mk = marks[mi];
    if (mk.level !== 2) continue;
    let end = lines.length;
    for (let mj = mi + 1; mj < marks.length; mj++) {
      if (marks[mj].level <= 2) { end = marks[mj].line; break; }
    }
    // Parte a la que pertenece: la última de nivel 1 anterior.
    let part = null;
    for (let mj = mi - 1; mj >= 0; mj--) {
      if (marks[mj].level === 1 && marks[mj].type === "parte") { part = marks[mj]; break; }
    }
    sections.push({ ...mk, lineEnd: end, part });
  }

  return { key, label: meta.label, file: meta.file, lines, sections };
}

let DB = {};

function loadAll() {
  DB = {};
  for (const key of Object.keys(MANUALS)) DB[key] = parseManual(key);
}

loadAll();

function sectionText(manual, sec) {
  return manual.lines.slice(sec.line, sec.lineEnd).join("\n").trim();
}

function tocText(onlyManual) {
  const out = [];
  for (const key of Object.keys(MANUALS)) {
    if (onlyManual && key !== onlyManual) continue;
    const m = DB[key];
    out.push(`# ${m.label} (${m.file})`);
    let currentPart = null;
    for (const s of m.sections) {
      if (s.part && s.part !== currentPart) {
        currentPart = s.part;
        out.push(`\n## ${currentPart.roman} - ${currentPart.title}`);
      }
      if (s.type === "capitulo") {
        out.push(`- Capítulo ${s.number}: ${s.title}  [anchor: ${s.anchor}]`);
      } else if (s.type === "apendice") {
        out.push(`- Apéndice ${s.number}: ${s.title}  [anchor: ${s.anchor}]`);
      } else if (s.type === "seccion") {
        out.push(`- ${s.title}  [anchor: ${s.anchor}]`);
      }
    }
    out.push("");
  }
  return out.join("\n");
}

function findSection(manualKey, selector) {
  const m = DB[manualKey];
  if (!m) throw new Error(`Manual desconocido: ${manualKey} (usa "desarrollo" o "usuario")`);
  const sel = String(selector).trim();
  // 1) por ancla exacta
  let hit = m.sections.find((s) => s.anchor === sel);
  if (hit) return hit;
  // 2) por número de capítulo
  if (/^\d+$/.test(sel)) {
    hit = m.sections.find((s) => s.type === "capitulo" && s.number === parseInt(sel, 10));
    if (hit) return hit;
  }
  // 3) por número de apéndice
  if (/^[A-ZÁÉÍÓÚ]$/i.test(sel)) {
    hit = m.sections.find((s) => s.type === "apendice" && String(s.number).toUpperCase() === sel.toUpperCase());
    if (hit) return hit;
  }
  // 4) por subcadena del título (insensible a mayúsculas y acentos)
  const folded = foldAccents(sel).toLowerCase();
  const candidates = m.sections.filter(
    (s) => s.type === "capitulo" || s.type === "apendice" || s.type === "seccion"
  );
  hit = candidates.find((s) => foldAccents(s.title).toLowerCase().includes(folded));
  if (hit) return hit;
  const total = candidates.length;
  throw new Error(
    `No se encontró "${sel}" en el manual de ${m.label}. Usa toc para ver ${total} secciones con su anchor.`
  );
}

function sectionAtLine(manual, lineIdx) {
  for (const s of manual.sections) {
    if (lineIdx >= s.line && lineIdx < s.lineEnd) return s;
  }
  return null;
}

const server = new McpServer({ name: "nopdev-docs", version: "1.0.0" });

server.registerTool(
  "toc",
  {
    title: "Índice de los manuales",
    description:
      "Lista las partes, capítulos y apéndices de los manuales de nopCommerce 4.90.8 (desarrollo y usuario), con su anchor para usar en get_chapter.",
    inputSchema: {
      manual: z.enum(["desarrollo", "usuario"]).optional().describe("Filtrar a un solo manual"),
    },
  },
  async ({ manual }) => ({ content: [{ type: "text", text: tocText(manual) }] })
);

server.registerTool(
  "get_chapter",
  {
    title: "Obtener capítulo",
    description:
      "Devuelve el texto completo de un capítulo, apéndice o sección del manual indicado. Selector: número de capítulo (p. ej. 16), anchor (p. ej. capitulo-16) o subcadena del título.",
    inputSchema: {
      manual: z.enum(["desarrollo", "usuario"]).describe("Manual del que extraer la sección"),
      selector: z.string().describe("Número (16), ancla (capitulo-16) o subcadena del título (tareas programadas)"),
    },
  },
  async ({ manual, selector }) => {
    try {
      const m = DB[manual];
      const sec = findSection(manual, selector);
      let text = sectionText(m, sec);
      let note = "";
      if (text.length > MAX_CHAPTER_CHARS) {
        text = text.slice(0, MAX_CHAPTER_CHARS);
        note = `\n\n[... TRUNCADO en ${MAX_CHAPTER_CHARS} caracteres]`;
      }
      const header = `# ${m.label} — ${
        sec.type === "capitulo" ? `Capítulo ${sec.number}` :
        sec.type === "apendice" ? `Apéndice ${sec.number}` :
        sec.type === "parte" ? sec.roman : sec.type
      }: ${sec.title} (ancla: ${sec.anchor})\n\n`;
      return { content: [{ type: "text", text: header + text + note }] };
    } catch (e) {
      return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
    }
  }
);

server.registerTool(
  "search",
  {
    title: "Buscar en los manuales",
    description:
      "Búsqueda de texto en los manuales (insensible a mayúsculas y acentos; usa regex=true si necesitas expresiones regulares). Devuelve coincidencias con su capítulo y contexto.",
    inputSchema: {
      query: z.string().describe("Texto o expresión a buscar"),
      manual: z.enum(["desarrollo", "usuario"]).optional().describe("Filtrar a un solo manual"),
      regex: z.boolean().optional().describe("Interpretar query como expresión regular (por defecto texto literal)"),
      context_lines: z.number().int().min(0).max(5).optional().describe("Líneas de contexto alrededor (por defecto 1)"),
      max_results: z.number().int().min(1).max(MAX_RESULTS_LIMIT).optional().describe(`Máximo de coincidencias (por defecto ${MAX_RESULTS_DEFAULT})`),
    },
  },
  async ({ query, manual, regex, context_lines, max_results }) => {
    const max = max_results ?? MAX_RESULTS_DEFAULT;
    const ctx = context_lines ?? 1;
    const keys = manual ? [manual] : Object.keys(MANUALS);
    let matcher;
    try {
      if (regex) {
        const re = new RegExp(query, "i");
        matcher = (line) => re.test(line);
      } else {
        const folded = foldAccents(query).toLowerCase();
        matcher = (line) => foldAccents(line).toLowerCase().includes(folded);
      }
    } catch (e) {
      return { content: [{ type: "text", text: `Regex inválida: ${e.message}` }], isError: true };
    }

    const out = [];
    let count = 0;
    let truncated = false;
    outer: for (const key of keys) {
      const m = DB[key];
      for (let i = 0; i < m.lines.length; i++) {
        if (matcher(m.lines[i])) {
          if (count >= max) { truncated = true; break outer; }
          const sec = sectionAtLine(m, i);
          const where = sec
            ? `${m.label} — ${sec.type === "capitulo" ? `Capítulo ${sec.number}: ${sec.title}` : sec.title} (línea ${i + 1})`
            : `${m.label} (línea ${i + 1})`;
          const from = Math.max(0, i - ctx);
          const to = Math.min(m.lines.length - 1, i + ctx);
          const snippet = [];
          for (let j = from; j <= to; j++) {
            snippet.push(`${j === i ? ">>" : "  "} ${j + 1}: ${m.lines[j]}`);
          }
          out.push(`— ${where}\n${snippet.join("\n")}`);
          count++;
        }
      }
    }
    const header = `${count} coincidencia(s)${truncated ? ` (se alcanzó el máximo de ${max}; refina la búsqueda)` : ""}:\n\n`;
    return { content: [{ type: "text", text: count ? header + out.join("\n\n") : "Sin coincidencias." }] };
  }
);

server.registerTool(
  "reload",
  {
    title: "Recargar manuales",
    description: "Vuelve a leer los archivos markdown de los manuales desde disco (útil si se han editado).",
    inputSchema: {},
  },
  async () => {
    try {
      loadAll();
      const total = Object.values(DB).reduce((a, m) => a + m.sections.length, 0);
      return { content: [{ type: "text", text: `Recargados 2 manuales; ${total} secciones indexadas.` }] };
    } catch (e) {
      return { content: [{ type: "text", text: `Error al recargar: ${e.message}` }], isError: true };
    }
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
console.error(`nopdev-docs-mcp listo (stdio). Manuales en: ${REPO_ROOT}`);
