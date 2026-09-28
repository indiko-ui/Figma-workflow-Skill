# Design Documentation

สร้างหน้า documentation ใน Figma สำหรับ component, component set, pattern หรือ UI section ที่มีอยู่แล้ว ให้ทีมออกแบบและพัฒนาเข้าใจวิธีใช้ กติกา และจุดที่ยังต้องตัดสินใจจากหลักฐานจริง

ใช้คู่กับ [SKILL.md](SKILL.md)

## ใช้เมื่อไร

- ต้องสร้างหน้าเอกสารใหม่สำหรับ component หรือ pattern ที่มีหลักฐานพร้อม
- ต้องทำ component showcase, anatomy, properties, variants, layout rules หรือ usage guidance
- ต้องทำเอกสารให้พร้อม review หรือ handoff โดยไม่เดา behavior ที่ยังไม่ถูกนิยาม

ไม่ใช้สำหรับ audit หาข้อบกพร่องก่อนเริ่ม หรือ sync เอกสารที่มีอยู่หลัง component เปลี่ยน

## สิ่งที่ต้องมี

- Figma node หรือ selected scope ที่ชัดเจน
- สิทธิ์อ่าน source component และสร้าง/แก้ documentation scope
- เอกสารหรือ component ใกล้เคียง หากต้องการให้รูปแบบเข้ากับระบบเดิม

## วิธีทำงาน

1. ตรวจ source, component properties, variants, tokens, layout และเอกสารใกล้เคียง
2. เลือกเฉพาะ module ที่มีหลักฐานจริง ไม่บังคับสร้างทุก section
3. สร้างหน้าโดยให้ component specimen เป็นจุดเด่น และใช้รูปแบบ visual ตามชนิดข้อมูล
4. ตรวจภาพทั้ง scope แล้วแก้เฉพาะ clipping, hierarchy, spacing หรือ example ที่สื่อสารไม่ชัด

## ผลลัพธ์ที่คาดหวัง

- หน้าเอกสารที่อ่านง่ายและใช้ component จริงเป็นศูนย์กลาง
- ตาราง/diagram/example เฉพาะที่ช่วยตัดสินใจได้
- `Needs definition` สำหรับกติกาที่ source ยังไม่ยืนยัน
- ไม่มี placeholder, empty table หรือ card ขนาดใหญ่ที่ไม่มีข้อมูล

## ตัวอย่าง prompt

```text
$design-documentation
สร้าง documentation สำหรับ component Tooltip ที่ node 1066:12111
ใช้เฉพาะข้อมูลใน component และ token ที่ bind อยู่
```

```text
$design-documentation
ทำหน้า documentation สำหรับ Button component set นี้ โดยเน้น variants,
content resilience และ Do/Don't ที่มีหลักฐานจากตัว component
```

## ลำดับร่วมกับ skill อื่น

เริ่มจาก `$audit-component` หากยังไม่มั่นใจว่าข้อมูลพร้อมหรือมีช่องว่างสำคัญหรือไม่ แล้วจึงใช้ skill นี้สร้างเอกสารใหม่

