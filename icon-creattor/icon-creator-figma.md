---
name: icon-creator
description: >
  Icon set creation & management ใน Figma — ครบ workflow: define spec, preview & iterate
  shape ใน chat, audit vs spec (live area/stroke), balance check, import SVG เป็น component.
  Triggers (EN): create icon set, make icons, icon spec, preview icon, audit icon,
  balance check icons, import icon figma, icon too thick, stroke heavy, icon dense,
  fix icon path, icon live area, icon naming, icon consistency, adjust icon.
  Triggers (TH): สร้าง icon, ทำ icon set, icon หนาเกิน, icon ดูแน่น, เช็ก icon,
  ปรับ icon, icon ไม่ balance, วาง icon ใกล้กัน, import icon, stroke หนาเกิน,
  เส้น icon ติดกัน, icon ดูไม่ consistent, แก้ icon.
  ALWAYS use when user wants to create, adjust, audit, or import any icon.
  REQUIRES: figma-use skill loaded before every use_figma call.
---
compatibility: Designed for Figma Agent (use_figma tool) and figma-console-mcp Desktop Bridge. Requires active Figma file open in desktop app.
allowed-tools: use_figma
metadata:
  author: indiko-ui
  version: "2.0"

# Icon Creator Skill

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

เก็บ spec ให้ครบก่อน generate:

| Property | Default | Note |
|---|---|---|
| Frame size | 24×24px | multi-size: 16/20/24/32 |
| Live area | 20×20px | padding 2px ทุกด้าน |
| Stroke weight | 2px @ 24px | scale: 16→1.34px, 20→1.65px, 32→2.5px |
| Stroke cap | Round | |
| Stroke join | Round | |
| Style | Stroke-based (outline) | หรือ filled — ถามก่อน |
| Naming | `icon/{category}/{name}` | เช่น `icon/nav/home` |
| Color | `#000000` hardcode → bind variable ทีหลัง | |

**ถาม user ถ้าขาด:**
- Style: outline / filled / mixed?
- Size: single (24px) หรือ multi-size?
- Reference: มี icon guide frame ใน Figma ไหม?

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

**Audit checklist:**
- [ ] Frame 24×24px ✓
- [ ] Path อยู่ใน live area (2px padding ทุกด้าน)
- [ ] Stroke weight ตาม spec
- [ ] strokeLineCap = ROUND
- [ ] strokeLineJoin = ROUND
- [ ] Naming `icon/{name}` format

**Common violations:**
- Path peak เกิน y=2 หรือ y=22 (ชนขอบ)
- Stroke CENTER + path ชิดขอบ = visual overflow
- Gap ระหว่าง parallel paths < 2px = ดูติดกัน

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

**Import icons — batch ทีละ 6:**
```js
// Step 2: switch page + import (เรียกซ้ำสำหรับ batch ถัดไป)
const iconsPage = figma.root.children.find(p => p.name === "Icons");
await figma.setCurrentPageAsync(iconsPage);

// หา section หรือสร้างใหม่
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
    docUrl: "https://your-docs.com/icons/home",   // ละไว้ได้ถ้าไม่มี doc
    svg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 12L12 3L21 12V21H15V15H9V21H3V12Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`
  },
  // ... icons ต่อไป (max 6 ต่อ call)
];

const createdNodeIds = [];
let x = 0;

for (const icon of icons) {
  const svgNode = figma.createNodeFromSvg(icon.svg);
  svgNode.resize(24, 24);
  const comp = figma.createComponentFromNode(svgNode);
  comp.name = icon.name;

  // ✅ Component description — แสดงใน Figma inspect panel
  if (icon.description) {
    comp.description = icon.description;
  }

  // ✅ Documentation link — แสดงเป็น "Open in browser" ใน Dev Mode / inspect
  if (icon.docUrl) {
    comp.documentationLinks = [{ uri: icon.docUrl }];
  }

  section.appendChild(comp);
  comp.x = x;
  comp.y = 0;
  x += 40;
  createdNodeIds.push(comp.id);
}

return { createdNodeIds, count: createdNodeIds.length };
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
    svgNode.resize(24, 24);
    const comp = figma.createComponentFromNode(svgNode);
    comp.name = "icon/home";
    comp.description = "Home — navigate to main dashboard";
    comp.documentationLinks = [{ uri: "https://your-docs.com/icons/home" }];
    section.appendChild(comp);
    comp.x = 0;
    comp.y = 0;
    
    return { createdNodeIds: [comp.id] };
  })()`
});
```

**⚠️ pitfalls (ทั้ง 2 modes):**
- อย่าสร้าง frame แยกแล้ว append — ใช้ `createNodeFromSvg` โดยตรง
- ต้อง `appendChild` ก่อน set `x`/`y`
- Batch ทีละ 6 icon max — ป้องกัน timeout
- ต้อง return `createdNodeIds` ทุกครั้ง
- Screenshots → target component node ID, ห้าม section ID

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
```js
// use_figma — patch description + docUrl บน component ที่มีอยู่
const page = figma.root.children.find(p => p.name === "Icons");
await figma.setCurrentPageAsync(page);

const patches = [
  { name: "icon/home",      desc: "Home — navigate to main dashboard",       docUrl: "https://your-docs.com/icons/home" },
  { name: "icon/arrow-left",desc: "Arrow left — go back, previous step",     docUrl: "https://your-docs.com/icons/arrow-left" },
  { name: "icon/id-card",   desc: "ID Card — identity verification, KYC",    docUrl: "https://your-docs.com/icons/id-card" },
];

const results = [];
for (const p of patches) {
  const comp = page.findOne(n => n.type === "COMPONENT" && n.name === p.name);
  if (!comp) { results.push({ name: p.name, status: "not found" }); continue; }
  comp.description = p.desc;
  comp.documentationLinks = [{ uri: p.docUrl }];
  results.push({ name: p.name, status: "patched", id: comp.id });
}

return { results };
```

**⚠️ pitfalls:**
- `documentationLinks` รับ **array** เสมอ แม้จะมีแค่ 1 link — ห้าม assign string ตรงๆ
- URL ต้องขึ้นต้นด้วย `https://` — Figma validate format ก่อน save
- ถ้า component ถูก publish แล้ว → ต้อง republish library หลัง patch ถึงจะ sync ไปยัง consumer files

---

## 8. Fix Path Issues

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
// use_figma — ลบเดิม → recreate SVG ใหม่ → createComponentFromNode
const old = await figma.getNodeByIdAsync("OLD_COMPONENT_ID");
const savedName = old.name;
const savedX = old.x;
const savedY = old.y;
const parent = old.parent;
old.remove();

const newSvg = `<svg ...NEW PATH...>`;
const svgNode = figma.createNodeFromSvg(newSvg);
svgNode.resize(24, 24);
const comp = figma.createComponentFromNode(svgNode);
comp.name = savedName;
parent.appendChild(comp);
comp.x = savedX;
comp.y = savedY;

return { createdNodeIds: [comp.id] };
```

---

## 9. Naming Convention

```
icon/{name}              — single category (nav set)
icon/{category}/{name}   — multi-category (ถ้า set ใหญ่)

ตัวอย่าง:
icon/home
icon/arrow-left
icon/nav/home           — ถ้ามีหลาย category
icon/kyc/id-card
```

---

## 10. SVG Reference Library

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
| Set doc link | `comp.documentationLinks = [{ uri: "https://..." }]` |
| Patch existing batch | use_figma: findOne by name → assign desc + docUrl |
| Balance check | compare path density + live area coverage |
| Screenshot verify | figma_capture_screenshot — component node ID เท่านั้น |

---

## Skill Cross-Reference

| Skill | When to load |
|---|---|
| `figma-use` | **MANDATORY** ก่อนทุก `use_figma` call |
| `figma-design-system` | เมื่อ bind variable / token หลัง import |
| `icon-creator` (this) | Icon spec, preview, balance, import, fix |
