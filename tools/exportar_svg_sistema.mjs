// Exporta del sistema de diseño SISCAN v2 (components/bundle.local.js) los SVG que la app Flutter usa tal cual:
//  · los 70 íconos (Icon, trazo 1,75 en caja de 24) → assets/sistema/iconos/<nombre>.svg
//  · el paisaje del secador (Landscape) en día, atardecer y noche, con y sin aire y calor, y en los encuadres que usan
//    los componentes (lote activo, ingreso, estado vacío, foto) → assets/sistema/paisaje/<variante>.svg
// Se ejecuta con Playwright: node tools/exportar_svg_sistema.mjs <carpeta del sistema> <carpeta assets>
import { chromium } from "playwright";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const DS = process.argv[2] || "C:/dev/siscan-ds-nuevo/siscan-design-system";
const OUT = process.argv[3] || "C:/dev/siscan/siscan_app/assets/sistema";
const lib = f => readFileSync(`${DS}/components/${f}`, "utf8");
mkdirSync(`${OUT}/iconos`, { recursive: true });
mkdirSync(`${OUT}/paisaje`, { recursive: true });

const b = await chromium.launch();
const p = await b.newPage();
await p.setContent(`<div id="r"></div><script>${lib("lib/react.production.min.js")}</script><script>${lib("lib/react-dom.production.min.js")}</script><script>${lib("bundle.local.js")}</script>`);
const svg = (el) => p.evaluate(async (el) => {
  const S = window.Siscan, h = React.createElement, r = document.getElementById("r");
  const raiz = ReactDOM.createRoot(r);
  const comp = el.tipo === "icono" ? h(S.Icon, { name: el.nombre, size: 24 }) : h(S.Landscape, el.props);
  ReactDOM.flushSync(() => raiz.render(comp));
  const s = r.querySelector("svg").cloneNode(true);
  raiz.unmount();
  s.removeAttribute("class"); s.removeAttribute("aria-hidden");
  s.setAttribute("xmlns", "http://www.w3.org/2000/svg");
  return s.outerHTML;
}, el);

const nombres = await p.evaluate(() => window.Siscan.ICON_NAMES);
for (const n of nombres) writeFileSync(`${OUT}/iconos/${n}.svg`, await svg({ tipo: "icono", nombre: n }));
// Encuadres de cada componente (viewBox del propio sistema).
const VISTAS = { completo: undefined, movil: "560 150 560 460", ingreso: "250 0 1200 600", vacio: "480 260 720 340", foto: "540 300 640 300", tarjeta: "560 330 600 230" };
let n = 0;
for (const variante of ["day", "dusk", "night"]) for (const aire of [true, false]) for (const calor of [true, false]) for (const [vista, vb] of Object.entries(VISTAS)) {
  if (vista !== "completo" && (!aire || calor)) continue;   // los encuadres secundarios van sin calor y con aire (como en el sistema)
  const nombre = `${variante}${aire ? "-aire" : ""}${calor ? "-calor" : ""}-${vista}`;
  writeFileSync(`${OUT}/paisaje/${nombre}.svg`, await svg({ tipo: "paisaje", props: { variant: variante, airflow: aire, heater: calor, view: vb, birds: vista !== "ingreso" } }));
  n++;
}
await b.close();
console.log(`${nombres.length} íconos y ${n} paisajes en ${OUT}`);
