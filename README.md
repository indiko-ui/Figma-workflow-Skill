# Figma × Claude — Team Skill Package

10 skills สำหรับ Figma + Claude workflow — ติดตั้งได้เลย พร้อมใช้งานทันที

---

## วิธี Install

1. เปิด Claude Settings → Skills
2. Drag `.skill` file เข้า หรือกด Import
3. Install ทับ skill เดิมได้เลย — ไม่ต้องลบก่อน

---

## Skills ทั้งหมด

| Skill | ใช้เมื่อ |
|-------|---------|
| `figma-design-system` | จุดเริ่มต้นทุก Figma task — token, variable, audit, export |
| `figma-use` | เขียน Plugin API code ผ่าน `use_figma` |
| `figma-generate-library` | สร้าง Design System ใน Figma จาก codebase |
| `figma-generate-design` | สร้าง/อัพเดท screen จาก DS components |
| `figma-implement-design` | แปลง Figma design เป็น production code |
| `figma-code-connect-components` | เชื่อม Figma components กับ code (Code Connect) |
| `figma-create-design-system-rules` | สร้าง AI coding rules สำหรับ project |
| `figma-ui-agent` | วางแผน UI layout spec ก่อน execute |
| `figma-create-new-file` | สร้าง Figma file ใหม่ |
| `ts-owner-sync` | Sync Token Studio ownership จาก Figma Variables |

---

## สิ่งที่ต้องปรับก่อนใช้งาน

### 1. Font Name
Skills ใช้ `"YOUR_FONT"` เป็น placeholder — Claude จะถามเมื่อต้องใช้ หรือบอก Claude ตอนเริ่มงานว่า:
> "เราใช้ font [ชื่อ font] ใน Figma"

### 2. Token Naming
Skills ใช้ `brand/`, `neutral/` เป็นตัวอย่าง — ปรับให้ตรงกับ naming convention ของโปรเจค เช่น `blue/`, `gray/`, `primary/`

### 3. MCP Connection
Skills รองรับทั้ง:
- **Figma Cloud MCP** — tools ชื่อ `figma_*`
- **figma-console-mcp Desktop Bridge** — tools ชื่อ `figma_execute`

ใช้ whichever ที่ connect อยู่ได้เลย

---

## แนะนำ Install Order

ถ้าจะใช้ครบทุก skill ให้ install ตามลำดับนี้:

1. `figma-use` — prerequisite สำหรับทุก Plugin API task
2. `figma-design-system` — reference หลักสำหรับ MCP workflows
3. Skills อื่นๆ ตามต้องการ

---

## Compatibility

- Claude Sonnet 4+ 
- Figma MCP Server (Cloud) หรือ figma-console-mcp (Desktop Bridge)
- Token Studio v2.x (สำหรับ `ts-owner-sync`)
