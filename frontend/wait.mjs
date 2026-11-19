// Waits (up to WAIT_TIMEOUT seconds, default 300) until every dependency answers.
import net from "node:net";

const deadline = Date.now() + Number(process.env.WAIT_TIMEOUT || 300) * 1000;

const targets = [];
const addUrl = (name, value, fallbackPort) => {
  if (!value) return;
  try {
    const u = new URL(value);
    targets.push({ name, host: u.hostname.replace(/^\[|\]$/g, ""), port: Number(u.port || fallbackPort) });
  } catch {
    console.warn(`[wait] ${name}: cannot parse URL, not waiting for it`);
  }
};
addUrl("Postgres", process.env.DATABASE_URL, 5432);
addUrl("ClickHouse", process.env.CLICKHOUSE_URL, 8123);
addUrl("Quickwit", process.env.QUICKWIT_SEARCH_URL, 7280);

const probe = ({ host, port }) =>
  new Promise((resolve) => {
    const s = net.connect({ host, port });
    const done = (ok) => { s.destroy(); resolve(ok); };
    s.setTimeout(3000, () => done(false));
    s.once("connect", () => done(true));
    s.once("error", () => done(false));
  });

for (const t of targets) {
  let logged = false;
  while (!(await probe(t))) {
    if (Date.now() > deadline) {
      console.warn(`[wait] ${t.name} (${t.host}:${t.port}) still not reachable, starting anyway`);
      break;
    }
    if (!logged) { console.log(`[wait] waiting for ${t.name} (${t.host}:${t.port})`); logged = true; }
    await new Promise((r) => setTimeout(r, 2000));
  }
}
// Quickwit answers TCP before its REST API is ready; index creation needs the API.
if (process.env.QUICKWIT_SEARCH_URL) {
  const url = process.env.QUICKWIT_SEARCH_URL.replace(/\/$/, "") + "/health/readyz";
  while (Date.now() < deadline) {
    try { if ((await fetch(url)).ok) break; } catch {}
    await new Promise((r) => setTimeout(r, 2000));
  }
}
console.log("[wait] dependencies are up");
