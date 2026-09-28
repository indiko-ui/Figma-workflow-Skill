# Update Documentation

sync documentation ที่มีอยู่ใน Figma ให้ตรงกับ source component ปัจจุบัน โดยแก้เฉพาะข้อมูลที่ stale และรักษา human-authored guidance ไว้

ใช้คู่กับ [SKILL.md](SKILL.md)

## ใช้เมื่อไร

- component, variant, property, token, layout หรือ visual example เปลี่ยนหลังมี documentation แล้ว
- ต้องการอัปเดตเอกสารแบบ minimal diff โดยไม่ rebuild ทั้งหน้า
- ต้องการเห็นว่า source change กระทบ usage, accessibility, engineering หรือ migration note หรือไม่

ไม่ใช้เพื่อสร้าง documentation ใหม่, redesign หน้าเอกสาร หรือเขียนทับ product rationale เพียงเพราะหาใน component ไม่เจอ

## หลักการสำคัญ

- Source component เป็น authority ของ fact ที่สังเกตได้ เช่น properties, variants, tokens และ layout
- Documentation อาจเป็น authority ของ product rationale, usage guidance, content rules, accessibility/engineering notes และ decision history
- ถ้า source ↔ document relationship ไม่ชัด ต้องหยุดและรายงาน `Blocked — source relationship needs confirmation`

## วิธีทำงาน

1. ยืนยัน source node และ documentation scope ที่จับคู่กัน
2. แยก documentation เป็น Source fact, Authored guidance, Mixed หรือ Unknown provenance
3. สร้าง change manifest ก่อนแก้ทุกครั้ง
4. อัปเดตเฉพาะ Added / Removed / Modified / Renamed ที่พิสูจน์ได้
5. รักษา authored guidance; ถ้าอาจขัดกับ source ให้ติด `Review required`
6. ตรวจ claim, cross-reference และ screenshot หลัง sync

## Completion status

| สถานะ | ความหมาย |
| --- | --- |
| Synced | source facts ที่ map ไว้ถูกต้อง และไม่มี conflict สำคัญ |
| Synced — review required | source facts sync แล้ว แต่ยังมี authored/ambiguous content รอ owner ตัดสินใจ |
| Blocked | ยังระบุ relationship หรือ evidence ที่จำเป็นไม่ได้อย่างปลอดภัย |

## ตัวอย่าง prompt

```text
$update-doc
Sync documentation ของ Button นี้กับ component set ปัจจุบัน
รักษา usage guidance และ engineering notes เดิมไว้
รายงาน change manifest ก่อนแก้ และสรุปเฉพาะความเปลี่ยนแปลงที่มีความหมาย
```

```text
$update-doc
อัปเดต property table และ visual example ของ Tooltip documentation
หาก state ในเอกสารไม่พบใน source ให้ทำ Review required แทนการลบ
```

## ลำดับร่วมกับ skill อื่น

สำหรับเอกสารที่มีอยู่แล้ว ใช้ `$audit-component` เพื่อตรวจความพร้อมหรือความเสี่ยงก่อน แล้วใช้ skill นี้เพื่อ sync. ใช้ `$design-documentation` เฉพาะกรณีสร้างเอกสารใหม่หรือได้รับคำสั่ง rebuild จริง ๆ

