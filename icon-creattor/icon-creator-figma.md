---
name: icon-creator
description: >
  Icon set creation & management ใน Figma — ครบ workflow: define spec, preview & iterate
  shape ใน chat, audit vs spec (live area/stroke), balance check, import SVG เป็น component.
  Triggers (EN): create icon set, make icons, icon spec, preview icon, audit icon,
  balance check icons, import icon figma, icon too thick, stroke heavy, icon dense,
  fix icon path, icon live area, icon naming, icon consistency, adjust icon,
  icon color variable, bind icon stroke, swap icon keep color, icon multi-size, icon size variant.
  Triggers (TH): สร้าง icon, ทำ icon set, icon หนาเกิน, icon ดูแน่น, เช็ก icon,
  ปรับ icon, icon ไม่ balance, วาง icon ใกล้กัน, import icon, stroke หนาเกิน,
  เส้น icon ติดกัน, icon ดูไม่ consistent, แก้ icon,
  เปลี่ยนสี icon, bind สี icon, swap icon สีคงอยู่, icon หลายขนาด, icon size variant.
  ALWAYS use when user wants to create, adjust, audit, or import any icon.
  REQUIRES: figma-use skill loaded before every use_figma call.
compatibility: Designed for Figma Agent (use_figma tool) and figma-console-mcp Desktop Bridge. Requires active Figma file open in desktop app.
allowed-tools: use_figma
license: © Indiko-UI. All rights reserved.
metadata:
  author: Indiko-UI
  copyright: © Indiko-UI
  version: "4.0"
---

# Icon Creator Skill

> © **Indiko-UI** · version 4.0 — Figma Agent skill for icon set creation, multi-size, color tokens & documentation links.
> Created and maintained by Indiko-UI ([indiko-ui.com](https://indiko-ui.com)). Do not redistribute without attribution.

Full workflow สำหรับ icon set creation และ management ใน Figma
ทำงานร่วมกับ **figma-use** (Figma Agent / use_figma) และ **figma-console-mcp Desktop Bridge**

---

## ⚠️ Figma Agent Prerequisite (MANDATORY)

**ก่อนเรียก `use_figma` ทุกครั้ง ต้อง load skill นี้ก่อน:**

```
view /mnt/skills/user/figma-use/SKILL.md
```

- ถ้า task เกี่ยวกับ variable binding / token → load เพิ่ม:
  ```
  view /mnt/skills/user/figma-design-system/SKILL.md
  ```
- ห้ามเรียก `use_figma` โดยไม่ผ่าน figma-use skill — silent failure guaranteed

**Figma Agent vs Desktop Bridge:**

| Context | Tool | Pattern |
|---|---|---|
| Figma Agent (Claude.ai) | `use_figma` | `skillNames: "figma-use"` + top-level `await`/`return` |
| Desktop Bridge (figma-console-mcp) | `figma_execute` / `figma_get_*` | async IIFE ถ้าต้องการ, return เป็น JSON |

---

## 🧭 Workflow Decision (อ่านก่อนเริ่มทุกครั้ง)

เมื่อ user ขอสร้าง/import icon — **ต้องถาม size ก่อนเสมอ**:

| User ต้องการ | ใช้ section ไหน | ผลลัพธ์ |
|---|---|---|
| Single 24px | Section 6 Step 2b | 1 component 24px |
| **Multi-size 16/20/24/32** | **Section 6.5 (ALL-IN-ONE)** | component set + Size variant |
| เปลี่ยนสีได้ (token) | + Section 8 หลัง import | bound variable + color picker |

> ⚠️ **อย่า default เป็น 24px เงียบๆ** — ถ้า user พูดถึง icon set / DS / production ให้ถาม multi-size ก่อน
> Multi-size = **Section 6.5** (สร้าง 4 size + combine ครบใน 1 script) ไม่ใช่ Step 2b

---

## 0. Pre-flight

```
figma_get_status probe:true   (Desktop Bridge)
```
หรือ inspect page ผ่าน use_figma:
```js
// use_figma — check current page
const pages = figma.root.children.map(p => ({ name: p.name, id: p.id }));
return { currentPage: figma.currentPage.name, pages };
```

**Error recovery:**
- ❌ `not connected` → เปิด Figma → Plugins → figma-console → Run
- ❌ port conflict (9223–9232) → restart MCP process แล้ว pre-flight ใหม่
- ❌ wrong page → `await figma.setCurrentPageAsync(page)` ที่ต้น script ทุก call

---

## 1. Define Spec

### 1.0 Read Guide Frame First (ก่อน hardcode spec)

ถ้าไฟล์มี icon guide/keyline frame อยู่แล้ว → **อ่าน spec จาก guide จริง** อย่าใช้ default เพราะ guide แต่ละทีมต่างกัน (square-only vs multi-keyline square+circle+diagonal)

**ถาม user หา guide ก่อน:**
- "มี icon guide frame ในไฟล์ไหม? ส่ง node-id หรือชื่อ frame มา"
- ถ้า user ส่ง Figma URL → extract node-id จาก `node-id=10260-1683` → API ใช้ `10260:1683` (เปลี่ยน `-` เป็น `:`)

**Read guide spec (use_figma):**
```js
// use_figma — อ่าน guide frame เพื่อ derive spec จริง
// NODE_ID จาก URL: node-id=10260-1683 → "10260:1683"
const guide = await figma.getNodeByIdAsync("NODE_ID");
if (!guide) return { error: "ไม่เจอ guide node — เช็ค node-id + page" };

// แยก guide element ตาม type เพื่อหา keyline structure
const elements = (guide.children || []).map(c => ({
  type: c.type,
  name: c.name,
  x: Math.round(c.x * 100) / 100,
  y: Math.round(c.y * 100) / 100,
  w: Math.round(c.width * 100) / 100,
  h: Math.round(c.height * 100) / 100,
  strokeWeight: c.strokeWeight,
  opacity: c.opacity
}));

// derive: square keyline = RECTANGLE ที่เล็กกว่า frame, circle = ELLIPSE
const frame = { w: guide.width, h: guide.height };
const squares = elements.filter(e => e.type === "RECTANGLE");
const circles = elements.filter(e => e.type === "ELLIPSE");

return {
  guideName: guide.name,
  frameSize: frame,
  // live area = square keyline ที่เล็กที่สุด (inner padding)
  squareKeylines: squares.map(s => ({ size: `${s.w}×${s.h}`, padding: (frame.w - s.w) / 2 })),
  circleKeylines: circles.map(c => ({ diameter: c.w })),
  allElements: elements
};
```

**Derive spec จาก output:**
- `frameSize` → ใช้เป็น Frame size (อาจไม่ใช่ 24)
- `squareKeylines[].padding` → ใช้เป็น live area padding จริง
- ถ้ามี `circleKeylines` → guide เป็น **multi-keyline** → icon ต้องวาด peak ชนคนละ keyline ตาม shape (ดู Section 5 audit)
- **เก็บค่าที่ได้ไว้ใช้ตลอด session** — pass เข้า import + audit แทน default

**Desktop Bridge version:**
```javascript
figma_execute({
  code: `(async () => {
    const guide = await figma.getNodeByIdAsync("NODE_ID");
    if (!guide) return { error: "ไม่เจอ guide node" };
    const elements = (guide.children || []).map(c => ({
      type: c.type, name: c.name,
      x: c.x, y: c.y, w: c.width, h: c.height,
      strokeWeight: c.strokeWeight, opacity: c.opacity
    }));
    const frame = { w: guide.width, h: guide.height };
    return {
      guideName: guide.name, frameSize: frame,
      squares: elements.filter(e => e.type === "RECTANGLE"),
      circles: elements.filter(e => e.type === "ELLIPSE"),
      allElements: elements
    };
  })()`
})
```

### 1.1 Spec table

เก็บ spec ให้ครบก่อน generate — **default ใช้เมื่อไม่มี guide เท่านั้น**:

| Property | Default | Note |
|---|---|---|
| Frame size | 24×24px | **override จาก guide ถ้ามี** |
| Live area | 20×20px | padding 2px — **override จาก squareKeyline** |
| Stroke weight | 2px @ 24px | scale: 16→1.34px, 20→1.65px, 32→2.5px |
| Stroke cap | Round | |
| Stroke join | Round | |
| Style | Stroke-based (outline) | หรือ filled — ถามก่อน |
| Naming | `icon/{category}/{name}` | เช่น `icon/nav/home` |
| Color | `#000000` hardcode → bind variable ทีหลัง | |
| Keyline type | square-only | **multi-keyline ถ้า guide มี circle/diagonal** |

**ถาม user ถ้าขาด (และไม่มี guide):**
- Style: outline / filled / mixed?
- Size: single (24px) หรือ multi-size?
- Reference: มี icon guide frame ใน Figma ไหม? (ถ้ามี → ทำ 1.0 ก่อน)

---

## 2. Propose Icon List

ถ้า user บอก context (เช่น "onboarding", "navigation") → propose list ก่อน
จัดกลุ่มตาม use case แล้วให้ user confirm / ตัด / เพิ่ม

```
กลุ่ม KYC: user-check, id-card, camera, face-scan
กลุ่ม Account: phone, lock, shield-check, bell
กลุ่ม Feature: wallet, chart-bar, gift, check-circle
```

---

## 3. Preview & Iterate ใน Chat

Generate SVG inline ด้วย visualizer ก่อน import จริง — ประหยัด iteration

### ⚠️ 3.0 CRITICAL: Single-Vector SVG Rule (swap-safe)

**ปัญหา:** `createNodeFromSvg` สร้าง **1 node ต่อ 1 SVG element** → SVG ที่มีหลาย `<path>` = ได้หลาย VECTOR แยก → structure ไม่ตรงข้าม icon → **swap แล้วสี reset, binding หาย**

**กฎเหล็กในการ author SVG ทุก icon:**

1. **ใช้ `<path>` เดียวเท่านั้น** — รวมทุก subpath ด้วย `M` command คั่น
   ```
   ❌ หลาย element (4 vectors):
   <path d="M3 7V5..."/><path d="M17 3..."/><circle cx=12../>

   ✅ 1 path, หลาย subpath (1 vector):
   <path d="M3 7V5C3 3.9 3.9 3 5 3H7  M17 3H19C20.1 3 21 3.9 21 5V7  M21 17..." />
   ```

2. **ห้ามใช้ `<circle>` / `<ellipse>` / `<rect>`** — Figma แปลงเป็น ELLIPSE/RECTANGLE node แยก ไม่ใช่ VECTOR
   - แปลง circle เป็น path arc แทน:
   ```
   ❌ <circle cx="12" cy="12" r="3"/>
   ✅ <path d="M12 9 A3 3 0 1 0 12 15 A3 3 0 1 0 12 9" />
      (วงกลม r=3 ที่ศูนย์ 12,12 = 2 arc ครึ่งวง)
   ```
   - สูตร circle → path: center `(cx,cy)` radius `r`:
   ```
   M{cx} {cy-r} A{r} {r} 0 1 0 {cx} {cy+r} A{r} {r} 0 1 0 {cx} {cy-r}
   ```

3. **ผลลัพธ์:** ทุก icon import มาเป็น **VECTOR เดียว** → rename เป็น `shape` → bind variable ครั้งเดียว → swap-safe 100%

**SVG template ที่ถูกต้อง (stroke-based, single vector):**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none"
  xmlns="http://www.w3.org/2000/svg">
  <path d="SUBPATH1 M SUBPATH2 M SUBPATH3"
    stroke="#000000" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

> Subpath ทั้งหมดใน `<path>` เดียวจะ share stroke property เดียวกัน (weight/cap/join)
> และยังคงเป็น **live stroke** แก้ strokeWeight ได้ปกติ — ไม่เสีย editability

### Preview pattern

**SVG spec สำหรับ stroke-based:**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none"
  xmlns="http://www.w3.org/2000/svg">
  <path d="..." stroke="#000000" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**Pattern การ preview:**
- แสดง icon frame 24px พร้อม label
- แสดง 32px เพื่อดู detail
- ถ้าหลาย icon → แสดงพร้อมกันเพื่อ balance check

**Iteration loop:**
1. Preview → user feedback → แก้ path → preview ใหม่
2. ทำซ้ำจนได้ direction ที่ต้องการ
3. Approve แล้วค่อย import

---

## 4. Balance Check

เมื่อ user วาง icon ใกล้กัน ให้วิเคราะห์ **visual weight** ก่อน approve:

**ตรวจ 3 อย่าง:**
- **Path density** — จำนวน path elements ต่อ icon (มากกว่า = หนักกว่า)
- **Live area coverage** — path ใช้พื้นที่ใน 20×20px มากแค่ไหน
- **Stroke cluster** — มีเส้นขนานใกล้กันไหม (gap < 2px หลัง stroke = ดูติดกัน)

**วิธีแก้ไม่ balance:**
- Icon หนักกว่า → ลด path / ย่อ live area usage / เพิ่ม gap ระหว่าง elements
- Icon เบากว่า → เพิ่ม element / ขยาย path ให้ใช้ live area เต็มขึ้น
- ปรับ gap ≥ 2px เสมอหลัง stroke center

**Context groups ที่มักอยู่ใกล้กัน:**
- Navigation bar → วาง 4-5 ตัวแนวนอน
- Step indicator → วางเรียงซ้าย→ขวา
- Feature card → วาง 3 ตัวในแนวนอน
- Permission list → วางแนวตั้ง icon + label

---

## 5. Audit vs Spec

### ผ่าน Figma Agent (use_figma)

```js
// load figma-use ก่อน — mandatory
// Switch ไป Icons page ก่อน
const iconsPage = figma.root.children.find(p => p.name === "Icons");
await figma.setCurrentPageAsync(iconsPage);

// หา section หรือ guide frame
const guideFrame = iconsPage.findOne(n => n.name === "Icon Guide" || n.name === "Keyline");
return {
  guideId: guideFrame?.id,
  guideSize: guideFrame ? { w: guideFrame.width, h: guideFrame.height } : null,
  allComponents: iconsPage.findAll(n => n.type === "COMPONENT").map(c => ({
    id: c.id, name: c.name, w: c.width, h: c.height
  }))
};
```

### ผ่าน Desktop Bridge

```javascript
// figma_get_file_for_plugin — ต้องมี nodeId จาก figma_get_selection หรือ URL extract ก่อน
// ห้าม hardcode nodeId ข้าม session — IDs reassign ทุก session
figma_get_file_for_plugin({ nodeIds: [guideNodeId], depth: 4 })
```

**Audit checklist (เทียบ guide จริงจาก Section 1.0):**
- [ ] Frame size = guide `frameSize` (ไม่ใช่ default 24 ถ้า guide ต่าง)
- [ ] Path peak อยู่ใน keyline ที่ถูกต้องตาม shape type
- [ ] Stroke weight ตาม spec (scale ตาม size)
- [ ] strokeCap = ROUND, strokeJoin = ROUND
- [ ] Naming `icon/{name}` format
- [ ] VECTOR เดียวชื่อ `shape` (swap-safe)

**Multi-keyline rule (ถ้า guide มี circle/diagonal):**
- **Square-ish icon** (card, stop, grid) → peak ชน **square keyline**
- **Circular icon** (circle, scan dot, avatar) → peak ชน **circle keyline** (ใหญ่กว่า square ~2px เพื่อ optical balance)
- **Portrait/landscape** (image, document) → ชน diagonal/rect ตาม orientation
- เหตุผล: shape ต่างกันต้อง overshoot ต่างกันให้ดู optical เท่ากัน — square ที่ fit เป๊ะจะดูใหญ่กว่า circle ที่ fit เป๊ะ

**Measure path peak เทียบ keyline (use_figma):**
```js
// use_figma — วัด bounding box ของ shape เทียบ frame + keyline
// pass ค่า guide จาก Section 1.0: FRAME_SIZE, SQUARE_PAD, CIRCLE_DIA
const FRAME_SIZE = 24;     // จาก guide.frameSize
const SQUARE_PAD = 2;      // จาก squareKeylines[].padding
const CIRCLE_DIA = 22;     // จาก circleKeylines[].diameter (ถ้ามี)

const comp = await figma.getNodeByIdAsync("COMPONENT_ID");
const shape = comp.findOne(n => n.type === "VECTOR");
if (!shape) return { error: "ไม่มี VECTOR ใน component" };

// absoluteBoundingBox = ขอบจริงรวม stroke
const bb = shape.absoluteBoundingBox;
const compBox = comp.absoluteBoundingBox;

// แปลงเป็น local coordinate (เทียบมุมบนซ้าย component)
const local = {
  left: bb.x - compBox.x,
  top: bb.y - compBox.y,
  right: (bb.x + bb.width) - compBox.x,
  bottom: (bb.y + bb.height) - compBox.y
};

const squareLimit = { min: SQUARE_PAD, max: FRAME_SIZE - SQUARE_PAD };
const circleInset = (FRAME_SIZE - CIRCLE_DIA) / 2;

return {
  name: comp.name,
  frameSize: { w: comp.width, h: comp.height },
  pathBounds: local,
  // เช็คชน square keyline ไหม (เผื่อ tolerance 0.5px)
  squareFit: {
    leftOK: local.left >= squareLimit.min - 0.5,
    topOK: local.top >= squareLimit.min - 0.5,
    rightOK: local.right <= squareLimit.max + 0.5,
    bottomOK: local.bottom <= squareLimit.max + 0.5
  },
  // overshoot เกิน frame = overflow
  overflow: local.left < 0 || local.top < 0 ||
            local.right > FRAME_SIZE || local.bottom > FRAME_SIZE,
  circleKeylineInset: circleInset
};
```

**Batch audit ทั้ง set เทียบ guide:**
```js
// use_figma — audit ทุก icon เทียบ frame size + overflow
const FRAME_SIZE = 24;  // จาก guide
const page = figma.currentPage;
const comps = page.findAll(n => n.type === "COMPONENT" && n.name.includes("icon/"));

const report = comps.map(c => {
  const shape = c.findOne(n => n.type === "VECTOR");
  if (!shape) return { name: c.name, error: "no vector" };

  const bb = shape.absoluteBoundingBox;
  const cb = c.absoluteBoundingBox;
  const local = {
    l: bb.x - cb.x, t: bb.y - cb.y,
    r: (bb.x + bb.width) - cb.x, b: (bb.y + bb.height) - cb.y
  };
  return {
    name: c.name,
    frameOK: Math.abs(c.width - FRAME_SIZE) < 0.5 && Math.abs(c.height - FRAME_SIZE) < 0.5,
    overflow: local.l < -0.5 || local.t < -0.5 || local.r > FRAME_SIZE + 0.5 || local.b > FRAME_SIZE + 0.5,
    bounds: { l: Math.round(local.l*10)/10, t: Math.round(local.t*10)/10, r: Math.round(local.r*10)/10, b: Math.round(local.b*10)/10 }
  };
});

return {
  failed: report.filter(r => r.error || !r.frameOK || r.overflow),
  all: report
};
```

**Common violations (อ้าง guide จริง):**
- `frameOK: false` → frame ไม่เท่า guide (มักเกิดหลัง extract vector — vector bbox ≠ frame size)
- `overflow: true` → path peak เลยขอบ frame → ชน/ทะลุ keyline
- Square icon ที่ fit เป๊ะ square keyline แต่ guide เป็น circle-based → ดูใหญ่เกิน ต้องย่อให้ชน circle keyline แทน
- Stroke CENTER + path ชิดขอบ → absoluteBoundingBox รวม stroke ครึ่งนึงเลยขอบ
- Gap ระหว่าง parallel subpath < 2px = ดูติดกัน

> ✅ **Approach 2 (frame as component):** import สร้าง component จาก FRAME → size คงที่ 24×24 fit guide เสมอ
> structure = `component(FRAME) > VECTOR(shape)` — bind variable + swap ที่ VECTOR child ชื่อ `shape`

---

## 6. Import เข้า Figma

### ✅ Figma Agent Pattern (use_figma) — CORRECT

> ⚠️ ต้อง load `figma-use` SKILL.md ก่อนทุกครั้ง
> Code ต้องใช้ top-level `await` + `return` — ห้าม wrap ใน async IIFE

**Pre-flight inspect — หา page + section:**
```js
// Step 1: inspect ก่อน import
const pages = figma.root.children.map(p => ({ name: p.name, id: p.id }));
return { pages };
```

**Step 2a — ถาม user ก่อน import (MANDATORY):**

ก่อน generate script ต้องถาม user 3 อย่างนี้ถ้ายังไม่รู้:
1. **Page name** ที่จะ import เข้า (default: "Icons")
2. **Size** — single หรือ multi-size?
   - **Single 24px** → ใช้ Step 2b ด้านล่าง
   - **Multi-size 16/20/24/32** → ข้ามไป **Section 8.5a** (generate per-size) เลย ไม่ใช้ Step 2b
3. **Doc link mode** — เลือก:
   - **Figma self-link** (default) — link ชี้กลับมาที่ component เองในไฟล์ (auto จาก node.id)
   - **Custom doc URL** — ชี้ไป doc site ภายนอก (`https://your-docs.com/icons/...`)

> ⚠️ **ถ้า user ต้องการ multi-size — อย่าใช้ Step 2b (มันสร้างแค่ 24px)**
> ไปที่ **Section 8.5a** ซึ่ง generate ครบ 4 size พร้อม stroke weight ต่างกัน → แล้ว 8.5b รวมเป็น set
> Full multi-size flow: **8.5a (สร้าง 4 size)** → 8.4 (bind color ถ้าต้องการ) → 8.5b (combine เป็น variant set)

### 📌 Copyright Stamp (ใส่ทุก component ที่สร้าง)

ทุก icon ที่ skill นี้สร้าง/แก้ → แปะ credit ลง **`setPluginData`** (ไม่รก UI, อ่านได้ภายหลัง)
ไม่ใส่ใน `description` เพราะ description ควรเป็น use case ของ icon ไม่ใช่ metadata

```js
// helper — เรียกหลังสร้าง/แก้ component ทุกตัว (constant ใช้ร่วมทุก flow)
const SKILL_CREDIT = "© Indiko-UI";
const SKILL_VERSION = "4.0";

function stampCredit(node) {
  node.setPluginData("creator", SKILL_CREDIT);
  node.setPluginData("skillVersion", SKILL_VERSION);
  node.setPluginData("createdAt", new Date().toISOString());
}
// ใช้: stampCredit(comp);  หรือ stampCredit(set);
```

**อ่าน credit กลับ:**
```js
node.getPluginData("creator");      // "© Indiko-UI"
node.getPluginData("skillVersion"); // "4.0"
```

> ทุก script ใน Section 6 / 6.5 / 8.5 / 9 — เพิ่ม `stampCredit(comp)` (หรือ `set`) ก่อน return
> Copyright อยู่ใน plugin data → ไม่กระทบ Component configuration panel ที่ user เห็น

**Step 2b — Import SINGLE 24px (ถ้าไม่ใช่ multi-size):**
```js
// ⚠️ Step นี้สร้างแค่ 24px — ถ้าต้องการ multi-size ใช้ Section 8.5a แทน
const SKILL_CREDIT = "© Indiko-UI";
const SKILL_VERSION = "4.0";

// LINK_MODE: "figma" (self-link) หรือ "custom" (doc site)
const LINK_MODE = "figma";
const DOC_BASE_URL = "https://your-docs.com/icons";  // ใช้เฉพาะ LINK_MODE === "custom"
const PAGE_NAME = "Icons";

// fileKey สำหรับ self-link — auto ก่อน, fallback ถ้าอ่านไม่ได้
const FILE_KEY_FALLBACK = "u7w4oJi9y9dqIHpjp6RrRQ";
const fileKey = (typeof figma.fileKey === "string" && figma.fileKey) || FILE_KEY_FALLBACK;
const fileName = encodeURIComponent(figma.root.name.replace(/\s+/g, "-"));

const iconsPage = figma.root.children.find(p => p.name === PAGE_NAME);
await figma.setCurrentPageAsync(iconsPage);

let section = iconsPage.children.find(n => n.type === "SECTION" && n.name === "New Icons");
if (!section) {
  section = figma.createSection();
  section.name = "New Icons";
  iconsPage.appendChild(section);
}

const icons = [
  {
    name: "icon/home",
    description: "Home — navigate to main dashboard",
    svg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 12L12 3L21 12V21H15V15H9V21H3V12Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`
  },
  // ... icons ต่อไป (max 6 ต่อ call)
];

const createdNodeIds = [];
let x = 0;

for (const icon of icons) {
  const svgNode = figma.createNodeFromSvg(icon.svg);
  svgNode.resize(24, 24);  // frame = 24×24 เป๊ะ (fit guide)
  svgNode.fills = [];      // ⚠️ ลบ default white fill ของ frame (ไม่ใช่แค่ซ่อน)

  // ⚠️ rename VECTOR child เป็น "shape" — ไม่ extract ออกจาก frame
  const vector = svgNode.findOne(n => n.type === "VECTOR");
  if (vector) vector.name = "shape";

  // สร้าง component จาก FRAME → component = 24×24
  const comp = figma.createComponentFromNode(svgNode);

  comp.name = icon.name;
  comp.description = icon.description;
  section.appendChild(comp);

  // ⚠️ self-link ต้อง set หลังได้ comp.id (chicken-and-egg: id ยังไม่มีตอน define array)
  let docUrl;
  if (LINK_MODE === "figma") {
    const urlNodeId = comp.id.replace(/:/g, "-");  // id ":" → URL "-"
    docUrl = `https://www.figma.com/design/${fileKey}/${fileName}?node-id=${urlNodeId}`;
  } else {
    const slug = icon.name.replace(/^icon\//, "");
    docUrl = `${DOC_BASE_URL}/${slug}`;
  }
  comp.documentationLinks = [{ uri: docUrl }];

  // 📌 copyright stamp ลง plugin data
  comp.setPluginData("creator", SKILL_CREDIT);
  comp.setPluginData("skillVersion", SKILL_VERSION);

  comp.x = x;
  comp.y = 0;
  x += 40;
  createdNodeIds.push(comp.id);
}

// verify — อ่านกลับมา confirm ว่า set จริง + structure ถูก
const verified = createdNodeIds.map(id => {
  const n = figma.getNodeById(id);
  const vectors = n.findAll(c => c.type === "VECTOR");
  return {
    name: n.name,
    frameSize: { w: n.width, h: n.height },   // ต้อง = 24×24 (fit guide)
    docLinks: n.documentationLinks,
    vectorCount: vectors.length,              // ต้อง = 1 (swap-safe)
    shapeNamed: vectors[0]?.name === "shape"
  };
});

return { linkMode: LINK_MODE, fileKey, createdNodeIds, verified };
```

**Screenshot verify:**
```js
// Step 3: verify หลัง import (ใช้ component node id จาก step 2)
// Desktop Bridge: figma_capture_screenshot — target component node id เท่านั้น ห้าม section id
```

### Desktop Bridge Pattern (figma_execute)

```javascript
// ถ้าใช้ figma-console-mcp — ใช้ async IIFE
await figma_execute({
  code: `(async () => {
    const DOC_BASE_URL = "https://your-docs.com/icons";
    const page = figma.currentPage;

    let section = page.children.find(n => n.type === "SECTION" && n.name === "New Icons");
    if (!section) {
      section = figma.createSection();
      section.name = "New Icons";
      page.appendChild(section);
    }

    const svgString = \`<svg width="24" height="24" viewBox="0 0 24 24" fill="none"
      xmlns="http://www.w3.org/2000/svg">
      <path d="M3 12L12 3L21 12V21H15V15H9V21H3V12Z"
        stroke="#000000" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round"/>
    </svg>\`;

    const svgNode = figma.createNodeFromSvg(svgString);
    svgNode.resize(24, 24);  // frame = 24×24 (fit guide)
    svgNode.fills = [];      // ⚠️ ลบ default white fill ของ frame

    // rename VECTOR child เป็น "shape" — ไม่ extract (เก็บ frame เป็น boundary)
    const vector = svgNode.findOne(n => n.type === "VECTOR");
    if (vector) vector.name = "shape";
    const comp = figma.createComponentFromNode(svgNode);  // จาก FRAME → 24×24

    comp.name = "icon/home";
    comp.description = "Home — navigate to main dashboard";

    // appendChild ก่อน แล้วค่อย set documentationLinks
    section.appendChild(comp);
    comp.documentationLinks = [{ uri: \`\${DOC_BASE_URL}/home\` }];

    comp.x = 0;
    comp.y = 0;

    // verify
    const saved = figma.getNodeById(comp.id);
    const vectors = saved.findAll(n => n.type === "VECTOR");
    return {
      createdNodeIds: [comp.id],
      frameSize: { w: saved.width, h: saved.height },  // ต้อง 24×24
      docLinks: saved.documentationLinks,
      vectorCount: vectors.length
    };
  })()`
});
```

**⚠️ pitfalls (ทั้ง 2 modes):**
- `createNodeFromSvg` wrap vector ใน FRAME → rename VECTOR child เป็น `shape` แต่ **สร้าง component จาก FRAME** (ไม่ extract vector ออก) → frame คงที่ 24×24 fit guide
- **`svgNode.fills = []` หลัง resize เสมอ** — frame มี default white fill ติดมา (แม้ปิดตา) ต้องลบจริง ไม่ใช่ซ่อน
- SVG ต้องเป็น single `<path>` (ดู Section 3.0) — หลาย element = หลาย vector = swap พัง + frame เพี้ยน
- ต้อง `appendChild` ก่อน set `x`/`y` และก่อน set `documentationLinks`
- Batch ทีละ 6 icon max — ป้องกัน timeout
- ต้อง return `frameSize` (= 24×24) + `vectorCount` (= 1) ทุกครั้ง
- Screenshots → target component node ID, ห้าม section ID
- **โครงสร้าง:** `component(FRAME 24×24, fills=[]) > VECTOR(shape)` — bind/swap ที่ VECTOR child

---

## 6.5 Multi-Size: Full Path (16/20/24/32) — ALL-IN-ONE

> ⚠️ **ถ้า user ขอ multi-size — ใช้ section นี้ ไม่ใช่ Step 2b** (Step 2b สร้างแค่ 24px)
> Script นี้รวมครบ: สร้าง 4 size → combine เป็น variant set → self-link — รันได้ใน 1 call ต่อ icon

**Stroke weight ต่อ size (critical — ต้องต่างกัน):**

| Size | Frame | Stroke | Detail |
|------|-------|--------|--------|
| 16 | 16×16 | 1.34px | simplify detail เล็กออก |
| 20 | 20×20 | 1.65px | scale ตรงได้ |
| 24 | 24×24 | 2px | master |
| 32 | 32×32 | 2.5px | เพิ่ม detail ได้ |

```js
// use_figma — สร้าง icon multi-size ครบ flow (1 icon ต่อ 1 call)
const PAGE_NAME = "Icons";
const ICON_BASE = "home";   // ชื่อ icon ไม่รวม prefix
const ICON_DESC = "Home — navigate to main dashboard";
const SKILL_CREDIT = "© Indiko-UI";
const SKILL_VERSION = "4.0";

// self-link config
const fileKey = (typeof figma.fileKey === "string" && figma.fileKey) || "u7w4oJi9y9dqIHpjp6RrRQ";
const fileName = encodeURIComponent(figma.root.name.replace(/\s+/g, "-"));

const page = figma.root.children.find(p => p.name === PAGE_NAME);
await figma.setCurrentPageAsync(page);

let section = page.children.find(n => n.type === "SECTION" && n.name === "New Icons");
if (!section) {
  section = figma.createSection();
  section.name = "New Icons";
  page.appendChild(section);
}

// ⚠️ แต่ละ size: SVG ของตัวเอง — stroke-width + viewBox + path ต่างกัน
// 16px simplify, 32px เพิ่ม detail ได้ (ถ้า scale: path × size/24)
const sizeSpecs = [
  { size: 16, svg: `<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 8L8 2L14 8V14H10V10H6V14H2V8Z" stroke="#000000" stroke-width="1.34" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
  { size: 20, svg: `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2.5 10L10 2.5L17.5 10V17.5H12.5V12.5H7.5V17.5H2.5V10Z" stroke="#000000" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
  { size: 24, svg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 12L12 3L21 12V21H15V15H9V21H3V12Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
  { size: 32, svg: `<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 16L16 4L28 16V28H20V20H12V28H4V16Z" stroke="#000000" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
];

// STEP 1: สร้าง 4 size components
const sizeComps = [];
for (const spec of sizeSpecs) {
  const svgNode = figma.createNodeFromSvg(spec.svg);
  svgNode.resize(spec.size, spec.size);  // frame = size เป๊ะ
  svgNode.fills = [];                     // ⚠️ ลบ default white fill ของ frame

  const vector = svgNode.findOne(n => n.type === "VECTOR");
  if (vector) vector.name = "shape";

  const comp = figma.createComponentFromNode(svgNode);  // จาก FRAME → size ถูก
  comp.name = `${ICON_BASE}/Size=${spec.size}`;          // variant naming
  section.appendChild(comp);
  sizeComps.push(comp);
}

// STEP 2: combine เป็น component set (variant property "Size")
const set = figma.combineAsVariants(sizeComps, page);
set.name = `icon/${ICON_BASE}`;
set.description = ICON_DESC;

// จัด grid (combineAsVariants stack ที่ 0,0)
let gx = 16, gy = 16, maxH = 0;
for (const child of set.children) {
  child.x = gx; child.y = gy;
  maxH = Math.max(maxH, child.height);
  gx += child.width + 24;
}
set.resize(gx + 16, maxH + 32);

// STEP 3: self-link ที่ระดับ SET (หลังได้ set.id)
const urlNodeId = set.id.replace(/:/g, "-");
set.documentationLinks = [{
  uri: `https://www.figma.com/design/${fileKey}/${fileName}?node-id=${urlNodeId}`
}];

// 📌 copyright stamp — set + ทุก variant
set.setPluginData("creator", SKILL_CREDIT);
set.setPluginData("skillVersion", SKILL_VERSION);
for (const v of set.children) {
  v.setPluginData("creator", SKILL_CREDIT);
  v.setPluginData("skillVersion", SKILL_VERSION);
}

// verify ครบ
const savedSet = figma.getNodeById(set.id);
return {
  setName: set.name,
  setType: savedSet.type,                                        // COMPONENT_SET
  credit: savedSet.getPluginData("creator"),                     // © Indiko-UI
  variantProps: Object.keys(set.componentPropertyDefinitions),   // ต้องมี "Size"
  variants: set.children.map(c => ({
    name: c.name,
    size: { w: c.width, h: c.height },                           // 16/20/24/32
    strokeWeight: c.findOne(n => n.type === "VECTOR")?.strokeWeight  // 1.34/1.65/2/2.5
  })),
  docLink: savedSet.documentationLinks?.[0]?.uri
};
```

**ผลลัพธ์:** instance ของ `icon/home` มี **Size dropdown** (16/20/24/32) + self-link ที่ config panel

**ถ้าต้องการ color binding ด้วย** → หลัง section นี้ รัน **8.4 multi-size bind loop** (bind stroke ทุก size variant ด้วย variable เดียว)

**Loop หลาย icon:** เปลี่ยน `ICON_BASE` + `ICON_DESC` + `sizeSpecs` แล้วรันซ้ำต่อ icon (1 call ต่อ icon เพื่อกัน timeout)

---

## 7. Component Metadata

### Description + Documentation Link

ตั้งค่าตอน import (ดู Section 6) หรือ patch ทีหลังบน component ที่มีอยู่แล้ว

**API ที่ใช้:**
```js
comp.description = "Home — navigate to main dashboard";
comp.documentationLinks = [{ uri: "https://your-docs.com/icons/home" }];
```

**ผลใน Figma:**
- `description` → แสดงใน **Inspect panel** ใต้ชื่อ component และใน **Component properties** tooltip
- `documentationLinks` → แสดงเป็นปุ่ม **"View documentation"** ใน Inspect / Dev Mode (เปิด URL ใน browser)

**Description format ที่แนะนำ:**
```
{label} — {use case หรือ context}

ตัวอย่าง:
"Home — navigate to main dashboard"
"Arrow left — go back, previous step"
"ID Card — identity verification, KYC step 1"
"Face scan — biometric authentication"
```

**Patch บน existing components (batch):**

มี 2 mode สำหรับ doc link:
- **Mode B — Figma node self-link** (default, แนะนำ) — ชี้กลับมาที่ node เองในไฟล์ (`figma.com/design/{key}?node-id={id}`)
- **Mode A — Custom doc URL** — ชี้ไป doc site ภายนอก (`https://your-docs.com/icons/...`)

> `figma.fileKey` อ่านได้ใน Figma Agent context → self-link auto ทำงาน ไม่ต้อง hardcode

#### Mode A — Custom doc URL
```js
// use_figma — patch description + custom docUrl (handle ทั้ง SET และ standalone COMPONENT)
// ถาม user หา DOC_BASE_URL ก่อน run เสมอ
const DOC_BASE_URL = "https://your-docs.com/icons";

const page = figma.root.children.find(p => p.name === "Icons");
await figma.setCurrentPageAsync(page);

const patches = [
  { name: "icon/home",       desc: "Home — navigate to main dashboard"    },
  { name: "icon/arrow-left", desc: "Arrow left — go back, previous step"  },
  { name: "icon/id-card",    desc: "ID Card — identity verification, KYC" },
];

const results = [];
for (const p of patches) {
  // ⚠️ multi-size: ตัว set เป็น COMPONENT_SET ไม่ใช่ COMPONENT
  // หาทั้ง 2 type — set ก่อน (เพราะ description/link ควรอยู่ที่ set ระดับบนสุด)
  const node = page.findOne(n =>
    (n.type === "COMPONENT_SET" || n.type === "COMPONENT") && n.name === p.name
  );
  if (!node) { results.push({ name: p.name, status: "not found" }); continue; }

  // derive slug: "icon/home" → "home", "icon/kyc/id-card" → "kyc/id-card"
  const slug = p.name.replace(/^icon\//, "");

  // set ที่ระดับ set/component — Figma แสดง link/desc ของ SET ใน config panel
  node.description = p.desc;
  node.documentationLinks = [{ uri: `${DOC_BASE_URL}/${slug}` }];

  // verify ทันที
  const saved = figma.getNodeById(node.id);
  results.push({
    name: p.name,
    nodeType: node.type,          // COMPONENT_SET = multi-size, COMPONENT = single
    status: "patched",
    id: node.id,
    desc: saved.description,
    docLinks: saved.documentationLinks
  });
}

return { results };
```

#### Mode B — Figma node self-link

ใช้ Figma URL ของ node เองเป็น documentation link → คลิกแล้ว navigate ไปที่ component นั้นในไฟล์

**Constraint:**
- Plugin API **ไม่มี method คืน node URL** — ต้องประกอบเอง: `https://www.figma.com/design/{fileKey}/{fileName}?node-id={id}`
- node-id ใน URL ใช้ `-` แต่ API ใช้ `:` → **แปลง `:` เป็น `-`**
- `figma.fileKey` อาจอ่านไม่ได้ในบาง context → **fallback hardcode fileKey** จาก URL ที่รู้

```js
// use_figma — patch documentationLinks เป็น Figma node self-link
// fileKey: ลองอ่านจาก API ก่อน ถ้าไม่ได้ใช้ hardcode
const FILE_KEY_FALLBACK = "u7w4oJi9y9dqIHpjp6RrRQ";  // ← จาก URL ไฟล์ถ้า figma.fileKey อ่านไม่ได้
const fileKey = (typeof figma.fileKey === "string" && figma.fileKey) || FILE_KEY_FALLBACK;
const fileName = encodeURIComponent(figma.root.name.replace(/\s+/g, "-"));

const page = figma.root.children.find(p => p.name === "Icons");
await figma.setCurrentPageAsync(page);

const patches = [
  { name: "icon/home",       desc: "Home — navigate to main dashboard"    },
  { name: "icon/arrow-left", desc: "Arrow left — go back, previous step"  },
  { name: "icon/id-card",    desc: "ID Card — identity verification, KYC" },
];

const results = [];
for (const p of patches) {
  const node = page.findOne(n =>
    (n.type === "COMPONENT_SET" || n.type === "COMPONENT") && n.name === p.name
  );
  if (!node) { results.push({ name: p.name, status: "not found" }); continue; }

  // ⚠️ node.id ใช้ ":" → URL ต้องใช้ "-"
  const urlNodeId = node.id.replace(/:/g, "-");
  const nodeUrl = `https://www.figma.com/design/${fileKey}/${fileName}?node-id=${urlNodeId}`;

  node.description = p.desc;
  // self-link → Figma แปลงเป็น NODE type อัตโนมัติ (in-file navigation)
  node.documentationLinks = [{ uri: nodeUrl }];

  const saved = figma.getNodeById(node.id);
  results.push({
    name: p.name,
    nodeType: node.type,
    nodeUrl,
    docLinks: saved.documentationLinks,
    worked: saved.documentationLinks?.[0]?.uri === nodeUrl
  });
}

return { fileKey, fileName, results };
```

**หมายเหตุ:** ถ้า `figma.fileKey` อ่านได้ (Agent context รองรับ) → URL ถูกอัตโนมัติ
ถ้าไม่ได้ → ต้องใส่ `FILE_KEY_FALLBACK` ให้ตรงไฟล์ (ดูจาก URL: `figma.com/design/{KEY}/...`)

**Root cause ที่พบบ่อยสุดเมื่อ link ไม่ขึ้นใน config panel:**

หลัง `combineAsVariants` โครงสร้างเป็น:
```
icon/id-card           ← COMPONENT_SET (parent, กรอบ purple dashed)
  ├─ id-card/Size=16   ← COMPONENT (variant child)
  ├─ id-card/Size=20   ← COMPONENT (variant child)
  ├─ id-card/Size=24   ← COMPONENT (variant child)
  └─ id-card/Size=32   ← COMPONENT (variant child)
```

- **Config panel "Link to documentation" อ่านจาก COMPONENT_SET** (ตัว parent) เมื่อเลือกทั้งก้อน
- ถ้า set link ที่ **variant (child)** แต่เปิด config ของ **set** → ไม่เห็น (คนละ node)
- ถ้า description ขึ้นแต่ลงท้าย `/Size=32` → แปลว่า patch ไปโดน **variant** ไม่ใช่ set (เพราะ findOne เจอ COMPONENT child ที่ชื่อมี Size)

**กฎ:** set `documentationLinks` + `description` ที่ **COMPONENT_SET** (ระดับ icon) ไม่ใช่ที่ variant

### 7.2 Debug command — ตรวจว่าทำไม link ไม่ขึ้น

สั่ง agent: *"debug ว่าทำไม documentation link ไม่ขึ้น"* → รัน:

```js
// use_figma — DEBUG documentationLinks (default: Figma self-link)
// เลือก node ที่มีปัญหาบน canvas ก่อน (variant หรือ set ก็ได้)
const sel = figma.currentPage.selection;
if (sel.length === 0) return { error: "เลือก node บน canvas ก่อนรัน debug" };

const LINK_MODE = "figma";  // "figma" (self-link) หรือ "custom"
const DOC_BASE_URL = "https://your-docs.com/icons";
const fileKey = (typeof figma.fileKey === "string" && figma.fileKey) || "u7w4oJi9y9dqIHpjp6RrRQ";
const fileName = encodeURIComponent(figma.root.name.replace(/\s+/g, "-"));
const out = [];

for (const node of sel) {
  // หา node ที่ควร set link จริง — ถ้าเลือก variant ให้ชี้ขึ้นไปที่ set
  let target = node;
  if (node.type === "COMPONENT" && node.parent?.type === "COMPONENT_SET") {
    target = node.parent;  // multi-size → set link ที่ SET
  }

  // สร้าง URL ตาม mode
  let docUrl;
  if (LINK_MODE === "figma") {
    const urlNodeId = target.id.replace(/:/g, "-");
    docUrl = `https://www.figma.com/design/${fileKey}/${fileName}?node-id=${urlNodeId}`;
  } else {
    const slug = target.name.replace(/^icon\//, "").replace(/\/Size=\d+$/, "");
    docUrl = `${DOC_BASE_URL}/${slug}`;
  }

  const before = target.documentationLinks;
  let err = null;
  try {
    target.documentationLinks = [{ uri: docUrl }];
  } catch (e) { err = e.message; }
  const after = target.documentationLinks;

  out.push({
    selected: { name: node.name, type: node.type },
    targetForLink: { name: target.name, type: target.type },  // ควรเป็น COMPONENT_SET ถ้า multi-size
    isVariantRedirect: target !== node,
    linkMode: LINK_MODE,
    fileKeyResolved: fileKey,        // ถ้า = fallback แปลว่า figma.fileKey อ่านไม่ได้
    docUrl,
    validUrl: docUrl.startsWith("https://"),
    before,
    after,
    error: err,
    worked: !err && after?.length > 0 && after[0].uri === docUrl
  });
}

return out;
```

**อ่านผล debug:**
| ผลลัพธ์ | สาเหตุ | แก้ |
|---|---|---|
| `worked: true` + `isVariantRedirect: true` | เดิม set ผิดที่ variant → ตอนนี้ set ที่ set แล้ว | เปิด config ของ **set** (กรอบ purple) ดู link |
| `worked: true` แต่ panel ยังว่าง | ดู config ผิด node | เลือก **COMPONENT_SET** ไม่ใช่ variant |
| `fileKeyResolved` = fallback value | `figma.fileKey` อ่านไม่ได้ใน context นี้ | ใส่ fileKey จริงใน fallback |
| `validUrl: false` | URL ผิด (space, ไม่มี https) | เช็ค fileName/slug |
**⚠️ pitfalls:**
- `documentationLinks` รับ **array** เสมอ แม้จะมีแค่ 1 link — ห้าม assign string ตรงๆ
- API set ได้แค่ **1 link** ต่อ component (Figma limitation) — clear ด้วย `[]`
- URL ต้องขึ้นต้นด้วย `https://` — Figma validate format ก่อน save
- **Multi-size:** set ที่ `COMPONENT_SET` ไม่ใช่ variant — ดู Section 7.1
- Link แสดงเฉพาะใน **Component configuration panel** (เลือก set/main → ดู Description + Link) ไม่ใช่ design canvas
- ถ้า component ถูก publish แล้ว → ต้อง republish library หลัง patch ถึงจะ sync ไปยัง consumer files

---

## 8. Color Binding + Multi-Size (Mechanism C)

ทำให้ icon **เปลี่ยนสีได้** (bound variable + exposed) และ **multi-size** (16/20/24/32) ใน component set เดียว — สีคงอยู่เมื่อ swap instance

### 8.0 ก่อนเริ่ม — ตัดสินใจ scale strategy

Icon set นี้เป็น **live stroke** (vector มี `strokeWeight`, ยังไม่ outline) → ใช้ **separate component ต่อ size** เพราะ:
- Resize node แบบ Auto Layout → `strokeWeight` คงที่ (2px) → 16px เส้นหนาเกิน, 32px เส้นบางเกิน
- ต้องกำหนด stroke weight + optical hinting เองต่อ size

| Size | Stroke weight | Live area | Detail |
|------|--------------|-----------|--------|
| 16px | 1.34px | 12×12px | simplify detail ออก |
| 20px | 1.65px | 16×16px | |
| 24px | 2px | 20×20px | master size |
| 32px | 2.5px | 28×28px | เพิ่ม detail ได้ |

→ สีผูกที่ `strokes[0].color` (ไม่ใช่ `fills` เพราะเป็น stroke-based)

### 8.1 ⚠️ ข้อเท็จจริงสำคัญ: Figma ไม่มี native COLOR property

Figma component property type มีแค่: `VARIANT`, `BOOLEAN`, `TEXT`, `INSTANCE_SWAP` — **ไม่มี `COLOR`**

วิธีทำให้ "เลือกสีได้ใน instance panel" จริงๆ คือ:
1. สร้าง **color variables** (semantic tier: `icon/default`, `icon/active`, `icon/disabled`, ...)
2. **Bind** stroke ของ vector → variable
3. variable ที่ bind จะโผล่ใน instance panel เป็น dropdown ให้เลือก variable ตัวอื่นใน collection เดียวกันได้อัตโนมัติ (ถ้า scope ตรง)

นี่คือ "color property" ในความหมายที่ใช้งานได้จริง — designer เลือก token จาก dropdown, developer ได้ semantic token

### 8.2 Step 1 — สร้าง semantic color variables

```js
// use_figma — สร้าง icon color collection + variables
// หา collection เดิมก่อน (name-based, ID เปลี่ยนทุก session)
let collection = (await figma.variables.getLocalVariableCollectionsAsync())
  .find(c => c.name === "Icon Colors");
if (!collection) {
  collection = figma.variables.createVariableCollection("Icon Colors");
}
const modeId = collection.modes[0].modeId;

const tokens = [
  { name: "icon/default",  color: { r: 0.1,  g: 0.1,  b: 0.1,  a: 1 } },
  { name: "icon/active",   color: { r: 0.13, g: 0.4,  b: 1,    a: 1 } },
  { name: "icon/disabled", color: { r: 0.7,  g: 0.7,  b: 0.7,  a: 1 } },
  { name: "icon/danger",   color: { r: 0.9,  g: 0.2,  b: 0.2,  a: 1 } },
];

const created = {};
const existing = await Promise.all(
  collection.variableIds.map(id => figma.variables.getVariableByIdAsync(id))
);

for (const t of tokens) {
  let v = existing.find(e => e && e.name === t.name);
  if (!v) {
    v = figma.variables.createVariable(t.name, collection, "COLOR");
    // ⚠️ scope = STROKE_COLOR เพราะ icon เป็น stroke-based
    v.scopes = ["STROKE_COLOR"];
  }
  v.setValueForMode(modeId, t.color);
  created[t.name] = v.id;
}

return { collectionId: collection.id, variableIds: created };
```

**⚠️ ถ้า icon เป็น fill-based (outline)** → เปลี่ยน scope เป็น `["SHAPE_FILL"]` และ bind `fills` แทน `strokes`

### 8.3 Step 2 — Standard structure (swap-safe REQUIREMENT)

**สีคงอยู่เมื่อ swap ได้ก็ต่อเมื่อทุก component ใน set มี structure ตรงกัน 100%:**

- VECTOR layer ต้องชื่อ **`shape`** เหมือนกันทุก icon
- ทุก icon ต้องมี **VECTOR เดียว** (single) ผูก variable ด้วย layer name เดียวกัน

**ป้องกันที่ source (แนะนำ):** author SVG เป็น single `<path>` ตั้งแต่แรก → ดู **Section 3.0** → import มาเป็น 1 vector อัตโนมัติ ไม่ต้อง repair

#### Repair icon ที่ structure พังแล้ว (หลาย vector / มี ELLIPSE)

ถ้า icon ในไฟล์มีหลาย VECTOR หรือมี ELLIPSE ปนอยู่ (เช่น `icon/setting/language` ที่มี 4 layers) → ต้อง rebuild จาก SVG ใหม่ เพื่อ**คง stroke editability**

> ⚠️ **ห้ามใช้ `figma.flatten()`** — flatten convert stroke → fill outline → เสีย strokeWeight ถาวร (ผิด requirement Q2)
> วิธีถูก: ดึง path data ทุก vector → รวมเป็น single `<path>` → recreate ผ่าน `createNodeFromSvg`

**Step A — อ่าน geometry จาก icon ที่พัง:**
```js
// use_figma — dump path data + stroke props จากทุก vector ใน component
const comp = await figma.getNodeByIdAsync("COMPONENT_ID");
const shapes = comp.findAll(n => n.type === "VECTOR" || n.type === "ELLIPSE");

const dump = shapes.map(n => ({
  type: n.type,
  name: n.name,
  strokeWeight: n.strokeWeight,
  vectorPaths: n.type === "VECTOR" ? n.vectorPaths.map(p => p.data) : null,
  // ELLIPSE — เก็บ bbox ไว้ convert เป็น arc path
  ellipse: n.type === "ELLIPSE" ? { x: n.x, y: n.y, w: n.width, h: n.height } : null
}));

return { compName: comp.name, count: shapes.length, dump };
```

**Step B — รวม path → recreate single-vector SVG:**
```js
// use_figma — recreate component จาก path data ที่รวมแล้ว
// MERGED_PATH = path data ทุกตัวต่อกันด้วยช่องว่าง (subpath M จะคั่นเอง)
// ELLIPSE ต้อง convert เป็น arc ก่อน (สูตรใน Section 3.0)
const MERGED_PATH = "M3 7V5C3 3.9... M17 3H19... M12 9 A3 3 0 1 0 12 15 A3 3 0 1 0 12 9";

const old = await figma.getNodeByIdAsync("OLD_COMPONENT_ID");
const savedName = old.name;
const savedDesc = old.description;
const savedDocs = old.documentationLinks;
const savedX = old.x, savedY = old.y;
const parent = old.parent;
old.remove();

const svg = `<svg width="24" height="24" viewBox="0 0 24 24" fill="none"
  xmlns="http://www.w3.org/2000/svg">
  <path d="${MERGED_PATH}" stroke="#000000" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round"/>
</svg>`;

const svgNode = figma.createNodeFromSvg(svg);
svgNode.resize(24, 24);  // frame = 24×24 (fit guide)
svgNode.fills = [];      // ⚠️ ลบ default white fill ของ frame

// rename VECTOR child เป็น "shape" — เก็บ FRAME เป็น component boundary
const vector = svgNode.findOne(n => n.type === "VECTOR");
if (vector) vector.name = "shape";
const comp = figma.createComponentFromNode(svgNode);  // จาก FRAME → 24×24

comp.name = savedName;
comp.description = savedDesc;
parent.appendChild(comp);
comp.documentationLinks = savedDocs;
comp.x = savedX;
comp.y = savedY;

// verify — VECTOR เดียวชื่อ shape + frame 24×24 + strokeWeight ยังอยู่
const check = comp.findAll(n => n.type === "VECTOR");
return {
  createdNodeIds: [comp.id],
  frameSize: { w: comp.width, h: comp.height },  // ต้อง 24×24
  vectorCount: check.length,                      // ต้อง = 1
  vectorName: check[0]?.name,                     // ต้อง = "shape"
  strokeWeight: check[0]?.strokeWeight            // ต้อง = 2 (live stroke คงอยู่)
};
```

**Step C — audit ทั้ง set หา icon ที่ยังพัง:**
```js
// use_figma — scan ทุก icon component หา structure ที่ไม่ตรง
const page = figma.currentPage;
const comps = page.findAll(n => n.type === "COMPONENT" && n.name.includes("icon/"));

const report = comps.map(c => {
  const vectors = c.findAll(n => n.type === "VECTOR");
  const others = c.findAll(n => n.type === "ELLIPSE" || n.type === "RECTANGLE");
  return {
    name: c.name,
    vectorCount: vectors.length,        // ควร = 1
    hasNonVector: others.length > 0,    // ควร = false
    shapeNamed: vectors.length === 1 && vectors[0].name === "shape",
    needsRepair: vectors.length !== 1 || others.length > 0
  };
});

return { broken: report.filter(r => r.needsRepair), all: report };
```

### 8.4 Step 3 — Bind stroke → variable

**Single component:**
```js
// use_figma — bind stroke ของ "shape" → variable icon/default
const variable = await figma.variables.getVariableByIdAsync("VARIABLE_ID_DEFAULT");
const comp = await figma.getNodeByIdAsync("COMPONENT_ID");
const shape = comp.findOne(n => n.name === "shape" && n.type === "VECTOR");

// ต้องมี stroke paint อยู่ก่อน ถ้าไม่มีให้ set ก่อน
if (!shape.strokes || shape.strokes.length === 0) {
  shape.strokes = [{ type: "SOLID", color: { r: 0.1, g: 0.1, b: 0.1 } }];
}

// ⚠️ setBoundVariableForPaint คืน paint ใหม่ — ต้อง capture + reassign
const boundPaint = shape.setBoundVariableForPaint(shape.strokes[0], "color", variable);
shape.strokes = [boundPaint];

// verify
return {
  bound: shape.strokes[0].boundVariables?.color?.id === variable.id,
  variableId: variable.id
};
```

**Multi-size — bind ทุก size variant ด้วย variable เดียวกัน (loop):**
```js
// use_figma — bind stroke ทุก size component ของ icon เดียวกัน
// รันก่อน combineAsVariants (8.5b) หรือหลังก็ได้ (set.children ก็ได้)
const variable = await figma.variables.getVariableByIdAsync("VARIABLE_ID_DEFAULT");
const ICON_BASE = "home";
const page = figma.currentPage;

const sizeComps = ["16", "20", "24", "32"].map(sz =>
  page.findOne(n => n.type === "COMPONENT" && n.name === `${ICON_BASE}/Size=${sz}`)
).filter(Boolean);

const results = [];
for (const comp of sizeComps) {
  const shape = comp.findOne(n => n.name === "shape" && n.type === "VECTOR");
  if (!shape) { results.push({ name: comp.name, error: "no shape" }); continue; }

  if (!shape.strokes || shape.strokes.length === 0) {
    shape.strokes = [{ type: "SOLID", color: { r: 0.1, g: 0.1, b: 0.1 } }];
  }
  const boundPaint = shape.setBoundVariableForPaint(shape.strokes[0], "color", variable);
  shape.strokes = [boundPaint];

  results.push({
    name: comp.name,
    bound: shape.strokes[0].boundVariables?.color?.id === variable.id
  });
}

return { results };  // ทุกตัวต้อง bound: true
```

### 8.5 Step 4 — สร้าง multi-size component set

มี 2 sub-step: **8.5a สร้าง 4 size components** → **8.5b รวมเป็น set**

#### 8.5a — Generate per-size components (16/20/24/32)

แต่ละ size ต้องมี frame + stroke weight + (อาจ) path ต่างกัน — **ไม่ใช่แค่ resize**

| Size | Frame | Stroke | viewBox | Path strategy |
|------|-------|--------|---------|---------------|
| 16 | 16×16 | 1.34px | `0 0 16 16` | simplify — ตัด detail เล็กออก |
| 20 | 20×20 | 1.65px | `0 0 20 20` | scale path ตรงๆ ได้ |
| 24 | 24×24 | 2px | `0 0 24 24` | master |
| 32 | 32×32 | 2.5px | `0 0 32 32` | scale + เพิ่ม detail ได้ |

**2 ทางเลือกการได้ path แต่ละ size:**

- **Manual per-size SVG** (แนะนำสำหรับ icon สำคัญ) — author path เองต่อ size ให้ optical-correct โดยเฉพาะ 16px
- **Scale จาก master 24** (เร็วกว่า สำหรับ set ใหญ่) — scale path coordinate × (size/24) แล้ว set stroke weight ตามตาราง

```js
// use_figma — สร้าง 4 size components จาก master (Approach 2: frame as component)
// แต่ละ size มี SVG ของตัวเอง (manual หรือ scaled)

const PAGE_NAME = "Icons";
const ICON_BASE = "home";  // ชื่อ icon (ไม่รวม prefix)

const page = figma.root.children.find(p => p.name === PAGE_NAME);
await figma.setCurrentPageAsync(page);

let section = page.children.find(n => n.type === "SECTION" && n.name === "New Icons");
if (!section) {
  section = figma.createSection();
  section.name = "New Icons";
  page.appendChild(section);
}

// กำหนด SVG ต่อ size — ใส่ path จริงของแต่ละ size
// (ถ้า scale จาก master: path coordinate × size/24, viewBox = size)
const sizeSpecs = [
  { size: 16, stroke: 1.34, svg: `<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 8L8 2L14 8V14H10V10H6V14H2V8Z" stroke="#000000" stroke-width="1.34" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
  { size: 20, stroke: 1.65, svg: `<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2.5 10L10 2.5L17.5 10V17.5H12.5V12.5H7.5V17.5H2.5V10Z" stroke="#000000" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
  { size: 24, stroke: 2,    svg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 12L12 3L21 12V21H15V15H9V21H3V12Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
  { size: 32, stroke: 2.5,  svg: `<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 16L16 4L28 16V28H20V20H12V28H4V16Z" stroke="#000000" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>` },
];

const created = [];
let x = 0;

for (const spec of sizeSpecs) {
  const svgNode = figma.createNodeFromSvg(spec.svg);
  svgNode.resize(spec.size, spec.size);  // frame = size เป๊ะ
  svgNode.fills = [];                     // ⚠️ ลบ default white fill ของ frame

  // rename VECTOR child เป็น "shape" — เก็บ FRAME เป็น boundary
  const vector = svgNode.findOne(n => n.type === "VECTOR");
  if (vector) vector.name = "shape";

  const comp = figma.createComponentFromNode(svgNode);  // จาก FRAME → size ถูก
  // ⚠️ variant naming: "{base}/Size={n}" — กำหนด variant property "Size"
  comp.name = `${ICON_BASE}/Size=${spec.size}`;

  section.appendChild(comp);
  comp.x = x;
  comp.y = 0;
  x += spec.size + 16;

  created.push({
    name: comp.name,
    frameSize: { w: comp.width, h: comp.height },  // ต้อง = spec.size
    strokeWeight: vector?.strokeWeight              // ต้อง = spec.stroke
  });
}

return { created };
```

**⚠️ stroke weight ต้อง set ใน SVG** (`stroke-width`) — `createNodeFromSvg` อ่านค่าจาก SVG attribute ถ้าใส่ผิดทุก size จะได้ 2px เท่ากันหมด → optical พัง

#### 8.5b — รวม 4 size เป็น component set

ตั้งชื่อ component ตาม variant pattern **ก่อน** `combineAsVariants` — naming กำหนด variant property:

```js
// use_figma — รวม 4 size เป็น component set เดียว
// ต้องสร้าง 4 size จาก 8.5a ก่อน + bind variable (8.4) แต่ละตัว
const ICON_BASE = "home";
const page = figma.currentPage;

const sizeComps = ["16", "20", "24", "32"].map(sz =>
  page.findOne(n => n.type === "COMPONENT" && n.name === `${ICON_BASE}/Size=${sz}`)
).filter(Boolean);

if (sizeComps.length !== 4) {
  return { error: "ไม่ครบ 4 size", found: sizeComps.map(c => c.name) };
}

const set = figma.combineAsVariants(sizeComps, page);
set.name = `icon/${ICON_BASE}`;
set.description = "Home — navigate to main dashboard";

// combineAsVariants stack ทุกตัวที่ (0,0) — จัด grid ใหม่
let x = 16, y = 16, maxH = 0;
for (const child of set.children) {
  child.x = x;
  child.y = y;
  maxH = Math.max(maxH, child.height);
  x += child.width + 24;
}
set.resize(x + 16, maxH + 32);

// ✅ set description + documentationLinks ที่ระดับ COMPONENT_SET (ไม่ใช่ variant)
// นี่คือ node ที่ Component configuration panel อ่าน — ดู Section 7.1
set.description = "Home — navigate to main dashboard";

// self-link (default) — set หลังได้ set.id แล้ว
const fileKey = (typeof figma.fileKey === "string" && figma.fileKey) || "u7w4oJi9y9dqIHpjp6RrRQ";
const fileName = encodeURIComponent(figma.root.name.replace(/\s+/g, "-"));
const urlNodeId = set.id.replace(/:/g, "-");
set.documentationLinks = [{
  uri: `https://www.figma.com/design/${fileKey}/${fileName}?node-id=${urlNodeId}`
}];

// verify — confirm link ติดที่ set
const savedSet = figma.getNodeById(set.id);
return {
  setId: set.id,
  setType: savedSet.type,                                       // = COMPONENT_SET
  variantProps: Object.keys(set.componentPropertyDefinitions),  // ต้องมี "Size"
  variantCount: set.children.length,                            // = 4
  docLinks: savedSet.documentationLinks                         // ต้องมี uri (self-link)
};
```

**Bind variable กับ multi-size:** ต้อง bind stroke ของ `shape` ใน **ทุก size variant** (รัน 8.4 × 4 หรือ loop) — ใช้ variable ตัวเดียวกัน → swap + เปลี่ยน size แล้วสีคงอยู่

### 8.6 Result ใน instance panel

เมื่อวาง instance ของ `icon/home` แล้ว designer จะเห็น:
- **Size** dropdown → 16 / 20 / 24 / 32 (variant property)
- **Stroke color** → variable picker (เลือก `icon/default` → `icon/active` ฯลฯ) เพราะ bind variable + scope `STROKE_COLOR` ตรง

### 8.7 Swap-safe — ทำไมสีคงอยู่

Figma map binding ข้าม instance **ตาม layer name + property path**:
- swap `icon/home` → `icon/settings` → ถ้าทั้งคู่มี VECTOR ชื่อ `shape` ที่ bind `strokes[0].color` → variable override **คงอยู่**
- ถ้า structure ต่าง (layer ชื่อไม่ตรง / vector count ต่าง / ไม่ได้ bind) → override **reset เป็น default**

**Checklist swap-safe (ต้องครบทุกข้อ):**
- [ ] ทุก icon component มี VECTOR ชื่อ `shape` เป๊ะ (case-sensitive)
- [ ] ทุก icon bind `strokes[0].color` → variable จาก collection เดียวกัน
- [ ] ทุก icon มี Size variant ครบชุดเดียวกัน (16/20/24/32)
- [ ] scope ของ variable = `STROKE_COLOR` (หรือ `SHAPE_FILL` ถ้า fill-based) — ตรงกันทั้ง set
- [ ] ไม่มี hardcoded stroke เหลือใน vector ใดๆ

### 8.8 Audit binding (ตรวจก่อน publish)

```js
// use_figma — ตรวจว่าทุก icon ใน set bind variable ครบ ไม่มี hardcode เหลือ
const page = figma.currentPage;
const sets = page.findAll(n => n.type === "COMPONENT_SET" && n.name.startsWith("icon/"));

const report = [];
for (const set of sets) {
  const variants = set.findAll(n => n.type === "COMPONENT");
  for (const v of variants) {
    const shape = v.findOne(n => n.name === "shape" && n.type === "VECTOR");
    report.push({
      set: set.name,
      variant: v.name,
      hasShape: !!shape,
      strokeBound: shape?.strokes?.[0]?.boundVariables?.color?.id || null
    });
  }
}

// flag ตัวที่ไม่ผ่าน
const failed = report.filter(r => !r.hasShape || !r.strokeBound);
return { total: report.length, failed };
```

---

## 9. Fix Path Issues

**เส้นหนา/แน่น → อ่านก่อนแก้:**

```js
// use_figma — อ่าน vector data จาก component
const comp = await figma.getNodeByIdAsync("COMPONENT_ID_HERE");
const vectors = comp.findAll(n => n.type === "VECTOR");
return vectors.map(v => ({
  id: v.id, name: v.name,
  x: v.x, y: v.y, w: v.width, h: v.height,
  strokeWeight: v.strokeWeight,
  strokeCap: v.strokeCap,
  strokeJoin: v.strokeJoin,
  pathCount: v.vectorPaths?.length,
  pathPreview: v.vectorPaths?.map(p => p.data?.substring(0, 150))
}));
```

**แก้ path → recreate component (อย่าแก้ vectorPaths โดยตรง):**

```js
// use_figma — ลบเดิม → recreate SVG ใหม่ → extract vector → component
const old = await figma.getNodeByIdAsync("OLD_COMPONENT_ID");
const savedName = old.name;
const savedDesc = old.description;
const savedDocs = old.documentationLinks;
const savedX = old.x;
const savedY = old.y;
const parent = old.parent;
old.remove();

// NEW PATH ต้องเป็น single <path> (ดู Section 3.0)
const newSvg = `<svg width="24" height="24" viewBox="0 0 24 24" fill="none"
  xmlns="http://www.w3.org/2000/svg">
  <path d="...NEW SINGLE PATH..." stroke="#000000" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round"/>
</svg>`;
const svgNode = figma.createNodeFromSvg(newSvg);
svgNode.resize(24, 24);  // frame = 24×24 (fit guide)
svgNode.fills = [];      // ⚠️ ลบ default white fill ของ frame

// rename VECTOR child เป็น "shape" — เก็บ FRAME เป็น component boundary
const vector = svgNode.findOne(n => n.type === "VECTOR");
if (vector) vector.name = "shape";
const comp = figma.createComponentFromNode(svgNode);  // จาก FRAME → 24×24

comp.name = savedName;
comp.description = savedDesc;
parent.appendChild(comp);
comp.documentationLinks = savedDocs;
comp.x = savedX;
comp.y = savedY;

return {
  createdNodeIds: [comp.id],
  frameSize: { w: comp.width, h: comp.height },  // ต้อง 24×24
  vectorCount: comp.findAll(n => n.type === "VECTOR").length,
  strokeWeight: vector?.strokeWeight
};
```

### 9.1 Cleanup default frame fill (icon ที่สร้างไปแล้ว)

icon ที่ import ก่อน v3.8 อาจมี **default white fill ค้าง** ที่ frame (แม้ปิดตา) → ลบออก batch (fix ตั้งแต่ v3.8)

> ลบเฉพาะ fill ที่ระดับ component/frame — ไม่แตะ VECTOR (stroke-based vector ควร fill = none อยู่แล้ว)

```js
// use_figma — ลบ default fill ออกจากทุก icon frame ในไฟล์
const page = figma.currentPage;

// หา component + variant ทั้งหมด (frame ที่ครอบ shape)
const comps = page.findAll(n =>
  n.type === "COMPONENT" && (n.name.includes("icon/") || n.name.includes("/Size="))
);

const cleaned = [];
for (const comp of comps) {
  const hadFill = Array.isArray(comp.fills) && comp.fills.length > 0;
  if (hadFill) {
    comp.fills = [];  // ลบ fill ทั้งหมดที่ frame (รวม invisible)
  }
  cleaned.push({
    name: comp.name,
    removed: hadFill,
    fillsNow: comp.fills.length  // ต้อง = 0
  });
}

return {
  total: cleaned.length,
  removed: cleaned.filter(c => c.removed).length,
  cleaned
};
```

**Multi-size note:** loop นี้ครอบ variant child (`/Size=`) ด้วย — frame ของแต่ละ size variant ก็โดน cleanup
ถ้า fill ค้างที่ COMPONENT_SET เอง (ไม่ใช่ variant) → set `set.fills = []` แยกอีกที (set ปกติไม่มี fill แต่เช็คไว้)

---

## 10. Naming Convention

```
icon/{name}              — single category (nav set)
icon/{category}/{name}   — multi-category (ถ้า set ใหญ่)

ตัวอย่าง:
icon/home
icon/arrow-left
icon/nav/home           — ถ้ามีหลาย category
icon/kyc/id-card
```

**Multi-size variant naming (Mechanism C):**
```
ก่อน combineAsVariants — ตั้งชื่อ component แต่ละ size:
home/Size=16
home/Size=20
home/Size=24
home/Size=32

หลัง combineAsVariants → set.name = "icon/home"
→ ได้ variant property "Size" อัตโนมัติ
```

---

## 11. SVG Reference Library

### Stroke spec ตาม size
| Size | Stroke | Live area |
|------|--------|-----------|
| 16px | 1.34px | 12×12px (2px pad) |
| 20px | 1.65px | 16×16px (2px pad) |
| 24px | 2px    | 20×20px (2px pad) |
| 32px | 2.5px  | 28×28px (2px pad) |

### Common path patterns

**Arrow (horizontal):**
```
M4 12H20 M20 12L16 8 M20 12L16 16   ← right
M20 12H4 M4 12L8 8   M4 12L8 16    ← left
```

**Scan (bracket + dot):**
```
M3 7V5C3 3.9 3.9 3 5 3H7
M17 3H19C20.1 3 21 3.9 21 5V7
M21 17V19C21 20.1 20.1 21 19 21H17
M7 21H5C3.9 21 3 20.1 3 19V17
circle cx=12 cy=12 r=2.5
```

**Transfer (+2px gap):**
```
M4 8H20 M20 8L16 4  M20 8L16 12
M20 16H4 M4 16L8 12 M4 16L8 20
```

**Check (inside circle):**
```
circle cx=12 cy=12 r=9
M8 12L11 15L16 9
```

---

## Quick Reference

| Task | Tool / Action |
|------|---------------|
| Preview icon | visualizer show_widget (SVG) |
| Audit vs guide | use_figma inspect — `figma.currentPage.findAll` |
| Fix path | read vectorPaths → recreate SVG → createNodeFromSvg |
| Import to Figma (Agent) | use_figma: createNodeFromSvg → createComponentFromNode → appendChild |
| Import to Figma (Bridge) | figma_execute async IIFE: same pattern |
| Set description | `comp.description = "Label — use case"` |
| Set doc link (custom) | `comp.documentationLinks = [{ uri }]` (after appendChild) |
| Set doc link (figma self) | URL `design/{key}/{name}?node-id={id.replace(/:/g,'-')}` |
| Patch existing batch | findOne (SET or COMPONENT) by name → assign at set level |
| Debug link not showing | select node → check targetForLink type = COMPONENT_SET |
| Create color tokens | createVariable type COLOR, scope `STROKE_COLOR` |
| Bind stroke→variable | `setBoundVariableForPaint` → capture + reassign |
| Author SVG (single vector) | 1 `<path>` + M subpaths, no `<circle>`/`<rect>` |
| Repair broken icon | dump paths → merge → recreate as single `shape` vector |
| Remove frame fill | `svgNode.fills = []` on create / batch `comp.fills = []` cleanup |
| Copyright stamp | `setPluginData("creator", "© Indiko-UI")` ทุก component ที่สร้าง |
| **Multi-size (full)** | **Section 6.5 ALL-IN-ONE: 4 size + combine + self-link in 1 call** |
| Generate per-size | 4 SVG (16/20/24/32) ต่าง stroke-width → component ต่อ size |
| Multi-size set | name `{base}/Size=N` → `combineAsVariants` → variant "Size" |
| Bind multi-size | loop bind stroke ทุก size variant ด้วย variable เดียว |
| Audit binding/structure | findAll → check vectorCount=1 + `boundVariables.color` |
| Balance check | compare path density + live area coverage |
| Screenshot verify | figma_capture_screenshot — component node ID เท่านั้น |

---

## Skill Cross-Reference

| Skill | When to load |
|---|---|
| `figma-use` | **MANDATORY** ก่อนทุก `use_figma` call |
| `figma-design-system` | เมื่อ bind variable / token หลัง import |
| `icon-creator` (this) | Icon spec, preview, balance, import, fix |

---

© **Indiko-UI** · icon-creator v4.0 · [indiko-ui.com](https://indiko-ui.com)
All rights reserved. ทุก component ที่สร้างจาก skill นี้ถูก stamp ด้วย `creator: © Indiko-UI` ใน plugin data
