# Audit Component

ตรวจ selected Figma component, component set, pattern หรือ UI section ก่อนทำ documentation หรือ handoff โดยรายงานเฉพาะประเด็นที่มีหลักฐานและนำไปตัดสินใจต่อได้

ใช้คู่กับ [SKILL.md](SKILL.md)

## ใช้เมื่อไร

- ก่อน publish, handoff หรือสร้าง documentation ให้ component สำคัญ
- เมื่อสงสัยเรื่อง component API, variants, layout resilience, token bindings หรือ accessibility readiness
- เมื่อต้องการหา Critical, Important และ Needs definition โดยไม่ redesign component

ไม่ใช้เพื่อเปลี่ยนชื่อ, refactor variants, แก้ token หรือปรับหน้าตาโดยอัตโนมัติ

## สิ่งที่ตรวจ

- component hierarchy, exposed properties และ variant matrix
- Auto Layout, Hug/Fill/Fixed, wrapping และ optional content
- variables, styles และ visual drift ที่เทียบกับระบบจริงได้
- states, interaction evidence และ content-stress scenarios ที่เกี่ยวข้อง
- accessibility signals ที่เห็นจาก design พร้อมแยกสิ่งที่ต้อง verify ใน implementation

## วิธีทำงาน

1. ระบุ scope และ property owner ของ node ที่เลือก
2. สร้าง evidence map จาก source และ component ที่เกี่ยวข้อง
3. ประเมินเฉพาะ dimension ที่เกี่ยวข้องจริง
4. เขียน finding แบบ Issue → Evidence → Impact → Recommendation
5. สรุป Documentation readiness และ next actions ที่เล็กที่สุด

## ระดับ finding

| ระดับ | ความหมาย |
| --- | --- |
| Critical | เสี่ยง broken behavior, ใช้ผิด, accessibility risk หรือ handoff ผิด |
| Important | มีผลต่อ consistency, resilience หรือ maintenance อย่างมีนัยสำคัญ |
| Improvement | ปรับได้ภายหลังแต่มี benefit ชัด |
| Needs definition | ยังไม่มีหลักฐานพอจะกำหนด rule หรือ owner decision |

## ตัวอย่าง prompt

```text
$audit-component
Audit Button component set นี้ก่อน handoff
รายงานเฉพาะปัญหาที่มี evidence พร้อม node/property/variant ที่เกี่ยวข้อง
ห้ามแก้ source component
```

```text
$audit-component
ตรวจ layout resilience และ token usage ของ Tooltip นี้
แยกสิ่งที่สังเกตจาก Figma ออกจากสิ่งที่ต้อง implementation verification
```

## ลำดับร่วมกับ skill อื่น

ใช้ skill นี้ก่อน `$design-documentation` เมื่อต้องการยืนยัน readiness. หากเอกสารมีอยู่แล้วและ component เปลี่ยน ให้ audit ก่อน แล้วใช้ `$update-doc` สำหรับการ sync ที่จำเป็น

