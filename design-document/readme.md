# Figma Design-System Documentation Skills

ชุด skill สำหรับดูแล component และ documentation ใน Figma ตั้งแต่ตรวจความพร้อม สร้างเอกสารใหม่ ไปจนถึง sync เอกสารหลัง source เปลี่ยน

## เลือกใช้ให้ถูกงาน

| งานที่ต้องการ | ใช้ skill | ผลลัพธ์หลัก |
| --- | --- | --- |
| ตรวจ component ก่อน handoff หรือก่อนเขียนเอกสาร | `$audit-component` | Evidence-based findings, readiness และ next actions |
| สร้าง documentation ใหม่สำหรับ component/pattern | `$design-documentation` | หน้า documentation ที่อ้างอิง source จริงและอ่านง่าย |
| อัปเดต documentation ที่มีอยู่หลัง source component เปลี่ยน | `$update-doc` | Minimal sync พร้อม change manifest และ review flags |

## ลำดับการทำงาน

### 1. เริ่มจาก component ที่ยังไม่มี documentation

```text
$audit-component → แก้หรือยืนยัน Critical / Needs definition → $design-documentation
```

ใช้ audit เพื่อยืนยันว่า properties, variants, layout, tokens และ state มีหลักฐานพอ ก่อนสร้างเอกสารใหม่

### 2. Component เปลี่ยน แต่มี documentation อยู่แล้ว

```text
$audit-component (เมื่ออยากประเมินความเสี่ยง) → $update-doc
```

`$update-doc` จะ sync เฉพาะข้อเท็จจริงที่ stale และรักษา product/engineering guidance ที่มนุษย์เขียนไว้

### 3. ต้องการสร้างหรือ rebuild documentation ใหม่จริง ๆ

```text
$audit-component → $design-documentation
```

ใช้ `$design-documentation` เมื่อเป็นหน้าใหม่ หรือเมื่อผู้ใช้สั่ง rebuild ชัดเจน ไม่ใช้แทน `$update-doc` สำหรับการเปลี่ยนเล็กน้อย

## Guardrails ร่วมกัน

- ใช้เฉพาะ source และ design-system evidence ที่ตรวจได้
- ไม่เดา tokens, states, breakpoints, accessibility behavior หรือ product rule
- ใช้ `Needs definition` เมื่อยังไม่มีหลักฐานพอ
- ไม่แก้ source component โดยอัตโนมัติ
- ไม่เขียนทับ human-authored usage, product rationale, accessibility หรือ engineering note โดยไม่มีเหตุผลชัดเจน

## ตัวอย่าง prompt

### Audit ก่อน handoff

```text
$audit-component
Audit Button component set นี้ก่อน handoff
รายงานเฉพาะ findings ที่มี evidence พร้อม node/property/variant ที่เกี่ยวข้อง
ห้ามแก้ source component
```

### สร้าง documentation ใหม่

```text
$design-documentation
สร้าง documentation สำหรับ Tooltip ที่ node 1066:12111
ใช้เฉพาะข้อมูลจาก component และ token ที่ bind อยู่
```

### Sync เอกสารเดิม

```text
$update-doc
Sync documentation ของ Button กับ component set ปัจจุบัน
รักษา usage guidance และ engineering notes เดิมไว้
สรุปเฉพาะความเปลี่ยนแปลงที่มีความหมาย
```

## รายละเอียดราย skill

- [Audit Component](audit-component/README.md)
- [Design Documentation](design-documentation/README.md)
- [Update Documentation](update-doc/README.md)

## ไฟล์ skill

- [audit-component/SKILL.md](audit-component/SKILL.md)
- [design-documentation/SKILL.md](design-documentation/SKILL.md)
- [update-doc/SKILL.md](update-doc/SKILL.md)

