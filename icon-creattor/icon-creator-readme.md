# icon-creator — Skill README

Skill สำหรับสร้างและจัดการ icon set ใน Figma แบบครบ workflow
ทำงานร่วมกับ **figma-console-mcp Desktop Bridge**

---

## Requirements

| Tool | หน้าที่ |
|------|---------|
| Claude Desktop | รัน skill |
| figma-console-mcp | Desktop Bridge — connect กับ Figma |
| Figma Desktop | เปิดไฟล์ที่ต้องการแก้ไข |

> ต้องเปิด Desktop Bridge plugin ใน Figma ก่อนเริ่ม workflow ทุกครั้ง

---

## Install

1. ดาวน์โหลด `icon-creator.skill`
2. เปิด Claude Desktop → **Customize** → **Skills**
3. ลาก `icon-creator.skill` เข้าไปวาง
4. Skill พร้อมใช้งาน

---

## Trigger Phrases

พิมพ์ประโยคเหล่านี้เพื่อเรียกใช้ skill:

**ภาษาไทย**
- `สร้าง icon set ใหม่`
- `ทำ icon สำหรับ onboarding`
- `icon หนาเกินไป`
- `icon ดูแน่น ปรับให้หน่อย`
- `เช็ก icon vs spec`
- `import icon เข้า Figma`
- `icon ไม่ balance วาง 2 ตัวนี้แล้วดูต่างกัน`
- `ปรับ stroke ของ icon`
- `เส้น icon ติดกัน`

**English**
- `create icon set`
- `make icons for navigation`
- `audit icon against spec`
- `icon stroke too heavy`
- `balance check these icons`
- `import SVG to Figma as component`
- `fix icon path — looks dense`

---

## Workflow Overview

```
1. Define spec       → frame size, stroke, style, naming
        ↓
2. Propose list      → จัดกลุ่ม icon ตาม context
        ↓
3. Preview ใน chat   → SVG inline → iterate → approve
        ↓
4. Balance check     → เทียบ visual weight icon ที่วางใกล้กัน
        ↓
5. Audit vs spec     → เทียบกับ icon guide frame ใน Figma
        ↓
6. Import to Figma   → SVG → Component → Section
```

---

## Spec Default

| Property | ค่า Default |
|----------|-------------|
| Frame size | 24×24px |
| Live area | 20×20px (padding 2px) |
| Stroke weight | 2px @ 24px |
| Stroke cap | Round |
| Stroke join | Round |
| Style | Stroke-based (outline) |
| Naming | `icon/{name}` |

**Stroke scale ตาม size:**

| Size | Stroke |
|------|--------|
| 16px | 1.34px |
| 20px | 1.65px |
| 24px | 2px |
| 32px | 2.5px |

---

## Step-by-step Guide

### 1. สร้าง icon set ใหม่

```
User: "สร้าง icon set สำหรับ navigation มี home, back, scan, transfer"
```

Claude จะ:
1. ถาม style (outline / filled) และ size ถ้ายังไม่ระบุ
2. Preview icon ทั้งหมดใน chat ก่อน
3. รอ approve แล้วค่อย import เข้า Figma

---

### 2. ปรับ icon ที่มีอยู่แล้ว

```
User: "icon/chart-bar ดูเส้นหนาเกิน ปรับให้หน่อย"
```

Claude จะ:
1. อ่าน path data จาก Figma
2. วิเคราะห์ปัญหา (gap, density, stroke cluster)
3. Preview แบบใหม่ใน chat
4. Approve → recreate component ใน Figma

---

### 3. Balance check

```
User: "icon/transfer กับ icon/scan วางใกล้กันแล้วดูไม่เท่ากัน"
```

Claude จะ:
1. Preview คู่เทียบกันพร้อม analysis
2. เสนอ option A / B ให้เลือก
3. Import version ที่เลือก

---

### 4. Audit vs icon guide

```
User: "เช็กว่า icon ที่ทำไว้ตรงกับ spec ใน Figma ไหม"
    + แชร์ link Figma ของ icon guide frame
```

Claude จะ:
1. อ่าน keyline จาก guide frame
2. เทียบ live area, stroke, naming
3. Report สิ่งที่ผ่าน / ไม่ผ่าน พร้อม fix แนะนำ

---

## Tips

- **Preview ก่อนเสมอ** — Claude จะแสดง icon ใน chat ก่อน import จริงทุกครั้ง
- **บอก context** เช่น "สำหรับ KYC", "navigation bar" — Claude จะ propose icon list ที่เหมาะสม
- **แชร์ Figma link** ของ icon guide frame ถ้ามี — audit จะแม่นขึ้นมาก
- **Desktop Bridge ต้องเปิดอยู่** ก่อน import หรือ audit ทุกครั้ง

---

## Common Issues

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| import ไม่ได้ | Desktop Bridge ปิดอยู่ | เปิด plugin ใน Figma Desktop |
| icon ดูหนา | stroke center + path ชิดขอบ | ขยับ path ให้ห่างขอบ ≥ 2px |
| icon ไม่ balance | path density ต่างกัน | ลด/เพิ่ม element ให้ visual weight ใกล้เคียงกัน |
| เส้นติดกัน | gap ระหว่าง parallel path < 2px | เพิ่ม gap หรือลด element |

---

## Figma Section Structure

Icon จะถูก import เข้า Section ชื่อ **"New"** โดย default:

```
Page: Icons
  └── Section: New
        ├── icon/home          (Component)
        ├── icon/arrow-left    (Component)
        ├── icon/scan          (Component)
        └── ...
```

---

*icon-creator skill v1.0 — built from session workflow by indiko-ui*
