# icon-creator — Usage Guide

Figma Agent skill สำหรับสร้าง จัดการ และ audit icon set ใน Figma แบบครบ workflow
ตั้งแต่ define spec → preview → import → multi-size → color token → documentation link

**Version:** 4.0 · **Author:** © Indiko-UI · **Runtime:** Figma Agent (`use_figma`) + figma-console-mcp Desktop Bridge

---

## ติดตั้งใน Figma — Step by Step

Figma Make / Figma Agent รับเฉพาะไฟล์ **`.md`** (ไม่ใช่ `.skill` ZIP)

**Step 1 — เปิดเมนู Skills**
ใน prompt box (ปุ่ม **+** ซ้ายล่าง) → เลือก **Skills** → **Manage skills**

**Step 2 — เปิดหน้า Skills manager**
แท็บ **Created by you** → กดปุ่ม **+ Add skills** (หรือ **+** มุมซ้ายบน)

**Step 3 — เลือกวิธี import**
หน้า "Start making skills" → กด **Upload a file** (ไม่ใช่ Start from scratch)
→ เลือกไฟล์ `icon-creator.md`

**Step 4 — Review & Add**
- **Skill name:** `icon-creator` (auto จาก frontmatter)
- **Description:** auto-fill จาก `description` field
- **Instructions:** ตรวจว่าเริ่มด้วย `# Icon Creator Skill` (ไม่ใช่ `compatibility:`)
- กด **Add**

**Step 5 — ยืนยันว่า active**
กลับมาแท็บ **Created by you** → เห็น `icon-creator` ใน **Private** พร้อม toggle เปิด (สีฟ้า)
→ พร้อมใช้งานด้วย `/icon-creator` หรือพิมพ์ trigger

> ⚠️ ถ้า Instructions ขึ้นต้นด้วย `compatibility:` แทน `# Icon Creator Skill` = frontmatter format ผิด — ใช้ไฟล์ v4.0 ที่ field ทุกตัวอยู่ใน `---` ครบ

**Prerequisite:** skill นี้เรียก `use_figma` → ต้องมี `figma-use` skill โหลดอยู่ก่อน (skill จะ enforce เอง)

**Update version:** ลบตัวเดิมใน Manage skills → upload `.md` ใหม่ทับ (Figma ไม่ auto-update)

---

## เริ่มใช้งาน — พิมพ์อะไร

Skill trigger อัตโนมัติเมื่อพูดถึง icon ทั้ง EN/TH ไม่ต้องเรียกชื่อ skill ก็ได้

| อยากทำ | พิมพ์ (ตัวอย่าง) |
|---|---|
| สร้าง icon ใหม่ | "สร้าง icon home แบบ multi-size" / "create a wallet icon" |
| สร้างทั้ง set | "ทำ icon set สำหรับ onboarding 12 ตัว" |
| Preview ก่อน import | "preview icon scan ให้ดูก่อน" |
| Import เข้า Figma | "import icon พวกนี้เข้า Figma" |
| เปลี่ยนสีได้ (token) | "ทำให้ icon เปลี่ยนสีได้เมื่อ swap" |
| Audit | "เช็ก icon ในไฟล์ว่า consistent ไหม" |
| แก้ icon | "icon นี้เส้นหนาเกิน" / "icon ไม่ balance" |
| ใส่ documentation link | "ใส่ link documentation ให้ icon" |

---

## Workflow หลัก — Decision Tree

Skill จะถาม **size ก่อนเสมอ** เพราะกำหนดทุกอย่างที่ตามมา:

```
สร้าง icon
  ├─ Single 24px ────────→ import 1 component
  ├─ Multi-size 16/20/24/32 → component set + Size variant (ALL-IN-ONE)
  └─ + เปลี่ยนสีได้ ────────→ bind color variable เพิ่ม
```

**ถ้าเป็น production / DS** → เลือก multi-size เสมอ อย่ารับแค่ 24px

---

## 3 Mode การสร้าง

### 1. Single 24px (เร็วสุด)
พิมพ์: "สร้าง icon home" → ได้ 1 component 24×24px พร้อม documentation link

### 2. Multi-size 16/20/24/32 (production)
พิมพ์: "สร้าง icon home แบบ multi-size"
- สร้าง 4 size — stroke weight ต่างกัน (1.34 / 1.65 / 2 / 2.5px) เพื่อ optical-correct
- รวมเป็น component set 1 ตัว มี **Size dropdown** ใน instance
- 16px จะ simplify detail, 32px เพิ่ม detail ได้

### 3. Multi-size + Color Token (full DS)
พิมพ์: "สร้าง icon home multi-size แล้วทำให้เปลี่ยนสีได้"
- ทุกอย่างจาก mode 2 + bind stroke → semantic color variable
- Instance panel มีทั้ง **Size** + **Stroke color** picker
- Swap icon → สีคงอยู่ (ไม่ reset)

---

## Spec มาตรฐาน

| Property | Default | Multi-size scale |
|---|---|---|
| Frame | 24×24px | 16 / 20 / 24 / 32 |
| Stroke | 2px | 1.34 / 1.65 / 2 / 2.5px |
| Live area | 20×20px (pad 2px) | scale ตาม frame |
| Cap / Join | Round / Round | — |
| Style | Stroke-based (outline) | — |
| Naming | `icon/{name}` | variant `{base}/Size=N` |

> ถ้ามี icon guide frame ในไฟล์ → skill อ่าน spec จริงจาก guide ก่อน (ส่ง node-id หรือ URL ให้)

---

## Documentation Link — 2 แบบ

**Figma self-link (default)** — link ชี้กลับมาที่ component เองในไฟล์
- คลิกแล้ว navigate ไปที่ icon นั้นใน Figma
- Auto จาก `node.id` — ไม่ต้องตั้งค่า

**Custom doc URL** — ชี้ไป doc site ภายนอก
- พิมพ์: "ใช้ custom doc url [your-site]"

> Link แสดงใน **Component configuration panel** (เลือก component → ดู Description + Link)
> Multi-size: link อยู่ที่ **component set** ไม่ใช่ variant ย่อย

---

## Troubleshooting

| ปัญหา | สาเหตุ | สั่งให้ทำ |
|---|---|---|
| Instructions ขึ้น `compatibility:` | frontmatter field อยู่นอก `---` | ใช้ไฟล์ v4.0 (field อยู่ใน `---` ครบ) re-import |
| สร้างแค่ 24px | ไม่ได้ระบุ multi-size | "ทำใหม่แบบ multi-size 16/20/24/32" |
| Link ไม่ขึ้นใน panel | set ผิด node (variant แทน set) | "debug ว่าทำไม documentation link ไม่ขึ้น" |
| Frame มี fill ขาว (ปิดตา) | default frame fill ค้าง | "ลบ default fill ออกจาก icon ทุกตัว" |
| Swap แล้วสีหาย | structure ไม่ตรง (vector ไม่ชื่อ `shape`) | "audit icon binding แล้ว repair" |
| icon เกินกรอบ / frame เพี้ยน | vector overflow / extract ผิด | "audit icon เทียบ guide แล้วแก้" |
| icon เส้นหนา/แน่น | path density สูง | "icon นี้เส้นหนาเกิน ปรับให้ balance" |
| icon มีหลาย vector layer | SVG หลาย path/มี circle | "repair icon ให้เป็น single vector" |

**Debug command:** เลือก node บน canvas → พิมพ์ "debug documentation link" → skill จะ set + verify + บอกว่าผิดตรงไหน

---

## ข้อควรรู้ (Edge Cases)

- **SVG ต้องเป็น single `<path>`** — หลาย `<path>` / `<circle>` / `<rect>` = หลาย vector = swap พัง + frame เพี้ยน (skill จัดการให้ตอน generate)
- **Multi-size structure** = `COMPONENT_SET > COMPONENT(variant) > VECTOR(shape)` — bind/swap ที่ vector ชื่อ `shape`
- **Stroke editability** — icon เก็บเป็น live stroke (แก้ strokeWeight ได้) ไม่ flatten เป็น fill
- **Published library** — หลังแก้ description/link ต้อง republish ถึง sync ไป consumer file
- **fileKey** — self-link อ่านจาก `figma.fileKey` อัตโนมัติ ถ้าอ่านไม่ได้มี fallback ในตัว

---

## Skill ที่เกี่ยวข้อง

| Skill | เมื่อไหร่ |
|---|---|
| `figma-use` | **บังคับ** ก่อนทุก `use_figma` call |
| `figma-design-system` | เมื่อ bind variable / token หลัง import |
| `icon-creator` (this) | spec, preview, balance, import, multi-size, color, fix |

---

## Quick Examples

```
"สร้าง icon set navigation: home, search, profile, settings แบบ multi-size"
→ 4 icon × 4 size = component set พร้อม Size variant + self-link

"icon scan เส้นติดกัน ปรับให้ห่างขึ้น"
→ audit live area → เพิ่ม gap → recreate

"เช็ก icon ทั้งหมดในไฟล์ว่า frame ตรง guide ไหม"
→ batch audit → report icon ที่ overflow/frame เพี้ยน

"ใส่ documentation link Figma self-link ให้ icon ทุกตัว"
→ batch patch self-link ที่ระดับ component/set
```

---

## Copyright

ทุก component ที่สร้างจาก skill นี้ถูก stamp ด้วย:
- `creator: © Indiko-UI` ใน plugin data
- `skillVersion: 4.0`

อ่าน credit กลับ: `node.getPluginData("creator")` → `© Indiko-UI`
Copyright อยู่ใน plugin data → ไม่กระทบ Component configuration panel ที่ user เห็น

---

© **Indiko-UI** · icon-creator v4.0 · [indiko-ui.com](https://indiko-ui.com)
All rights reserved. Do not redistribute without attribution.
