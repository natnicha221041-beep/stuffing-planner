# Stuffing & Loading Planner

Web Application สำหรับวางแผนบรรจุสินค้า (Stuffing Plan) และโหลดสินค้าขึ้นตู้คอนเทนเนอร์ (Loading Plan)
พร้อมระบบตรวจสอบขีดความสามารถรายวัน (Daily Capacity), ระบบจัดสรรแผนอัตโนมัติ และระบบกระทบยอดประจำวัน (Reconciliation)

> **ใหม่: งานตู้ Export แบบ Shipment (KK-งานตู้คอนเทนเนอร์)** — วางแผนตาม Shipment/Booking ได้ทั้งที่ยังไม่ทราบเบอร์ตู้/เบอร์ซีล
> นำเข้าไฟล์ Export Plan (.xlsx) ได้โดยตรง — ดูหัวข้อ [งานตู้ Export แบบ Shipment](#งานตู้-export-แบบ-shipment-kk)

## ใช้งานผ่าน GitHub Pages (ฟรี ไม่ต้องมี Server)
`npm run build:pages` → `dist/github-pages/` อัปโหลดขึ้น Repository แบบ Public แล้วเปิด Pages — ดู **คู่มือ-GitHub-Pages.md**
โค้ด Backend ชุดเดียวกันถูกโหลดมารันใน Browser (shims ใน `pages/shims/`: fs → IndexedDB, zlib → pure-JS inflate)
ข้อมูลเก็บแยกต่อ Browser — ใช้ปุ่มสำรอง/กู้คืนข้อมูล (.json) เพื่อส่งต่อหรือย้ายเครื่อง

## เริ่มใช้งาน

ต้องมี **Node.js 18 ขึ้นไป** — ไม่ต้อง `npm install` (Backend ใช้เฉพาะ built-in modules ของ Node.js)

```bash
npm start            # เปิด http://localhost:3000
npm test             # รันชุดทดสอบ Business Logic + API (27 รายการ)
npm run build:pages  # สร้างเวอร์ชัน GitHub Pages → dist/github-pages/
npm run seed         # รีเซ็ตข้อมูลตัวอย่าง
```

ตัวแปรสภาพแวดล้อม: `PORT` (ค่าเริ่มต้น 3000), `DATA_FILE` (ไฟล์ข้อมูล, ค่าเริ่มต้น `backend/data/db.json`),
`APP_TZ` (ค่าเริ่มต้น `Asia/Bangkok`), `CORS_ORIGIN` (เมื่อรัน Frontend แยกโดเมน)

ครั้งแรกที่รัน ระบบสร้างข้อมูลตัวอย่างโดยอ้างอิงวันที่ปัจจุบัน (ลูกค้า 5 ราย, สินค้า 4 ประเภท, ตู้ตัวอย่างที่มีการวางของหนักทับของเบา และตู้เมื่อวานที่โหลดขาด 20 กล่อง)

## โครงสร้างโปรเจกต์

```
stuffing-planner/
├── backend/                       ← ส่วนคำนวณและประมวลผล Logic (REST API)
│   ├── src/
│   │   ├── server.js              จุดเริ่มต้น: mount API + เสิร์ฟ Frontend
│   │   ├── lib/http.js            HTTP router ขนาดเล็ก (API แบบ Express, zero-dependency)
│   │   ├── db/
│   │   │   ├── store.js           Repository: JSON file + transaction/rollback/simulate
│   │   │   └── seed.js            ข้อมูลตัวอย่าง + ความจุมาตรฐานของตู้แต่ละประเภท
│   │   ├── lib/xlsx.js            อ่านไฟล์ .xlsx (zero-dependency)
│   │   ├── services/kk/           ★ งานตู้แบบ Shipment: core, rules, planner, loading, importer, views
│   │   ├── services/              ★ Business Logic โมดูลทั่วไป
│   │   │   ├── metrics.js         คำนวณ CBM/น้ำหนักในตู้, การใช้โควตารายวัน
│   │   │   ├── validation.js      กฎข้อ 2: ความจุตู้, Daily Capacity, Weight Distribution
│   │   │   ├── planner.js         Planning Engine (ข้อ 3)
│   │   │   ├── reconciliation.js  กระทบยอด + Roll Over (ข้อ 4)
│   │   │   └── dashboard.js       ข้อมูล Timeline/KPI
│   │   ├── routes/                REST endpoints (orders, containers, master, planning)
│   │   └── utils/                 date, errors, input schema validation
│   └── test/                      logic.test.js, kk.test.js, fixtures/export-plan-sample.xlsx
├── frontend/                      ← ส่วนรับค่าและแสดงผล (Vanilla JS SPA, ไม่ต้อง build)
│   ├── index.html
│   ├── css/styles.css
│   └── js/
│       ├── api.js                 API client
│       ├── ui.js                  ตาราง Inline Editing, Progress bar, Modal, ตรวจสอบก่อนบันทึก
│       ├── app.js                 Router
│       ├── kkshared.js            ฟอร์ม Shipment, สถานะช่องตู้
│       └── views/                 kkplan, kkloading, kksettings + dashboard, orders, containers, capacity, reconciliation
└── database/schema.sql            Schema PostgreSQL สำหรับย้ายไปใช้ฐานข้อมูลจริง
```

## ฟังก์ชันตามข้อกำหนด

| ข้อ | ฟังก์ชัน | หน้าจอ | Backend |
|---|---|---|---|
| 1.1 | คำสั่งซื้อ/แผนบรรจุของลูกค้า (Customer, PO/Invoice, SKU, จำนวน+หน่วย, วันกำหนดส่ง) | คำสั่งซื้อ / แผนบรรจุ | `routes/orders.js` |
| 1.2 | ตู้ (เลขตู้/ซีล, ประเภทตู้ → ดึง CBM/น้ำหนักสูงสุดอัตโนมัติ) + ตาราง Mapping สินค้าเข้าตู้ | แผนโหลดตู้คอนเทนเนอร์ | `routes/containers.js` |
| 1.3 | ขีดความสามารถสูงสุดต่อวันแยกตามประเภทสินค้า (Dynamic Constraints) | กำลังบรรจุรายวัน & สินค้า | `routes/master.js` |
| 2.1 | CBM/น้ำหนักในตู้ห้ามเกิน 100% → แจ้งเตือนสีแดง | ทุกหน้า | `validation.validateContainer` |
| 2.2 | รวมทุกตู้ในวันเดียวกันแยกตามประเภท → "เกินขีดความสามารถ (Over Capacity)" พร้อมจำนวนที่เกิน | ทุกหน้า | `validation.validateDay` |
| 2.3 | แจ้งเตือนสินค้าหนักวางทับสินค้าเบา (ตามชั้น: 1 = ล่างสุด) + ปุ่มจัดชั้นอัตโนมัติ | แผนโหลดตู้ | `validation.checkWeightDistribution` |
| 3 | ปุ่ม "คำนวณและจัดสรรแผนบรรจุสินค้า" — ดูตัวอย่างก่อน แล้วยืนยันบันทึก | แดชบอร์ด | `services/planner.js` |
| 3 | Timeline รายวัน/สัปดาห์, สถานะตู้, CBM bar, Capacity bar | แดชบอร์ด | `services/dashboard.js` |
| 4 | กรอกยอดจริง, Planned vs Actual, Variance, ไฮไลต์เหลือง/แดง, ติ๊ก Roll Over ไปวันถัดไป | กระทบยอดประจำวัน | `services/reconciliation.js` |

### การตรวจสอบก่อนบันทึก
ทุกการแก้ไขที่กระทบตู้หรือวัน (เพิ่ม/แก้จำนวนในตู้, เปลี่ยนประเภทตู้, ย้ายวันโหลด, แก้ยอดสั่งซื้อ) ทำงานใน transaction:
ระบบคำนวณผลหลังแก้ไข → หากเกิดการเกินพิกัด **ใหม่หรือแย่ลง** จะ rollback และตอบ `422` พร้อมรายการปัญหา
หน้าจอแสดงกล่องยืนยันสีแดง ผู้ใช้เลือก "บันทึกทั้งที่เกินพิกัด" ได้ (ส่ง `force: true`)
ยกเว้นการจัดลงตู้เกินยอดสั่งซื้อ ซึ่งบันทึกไม่ได้ในทุกกรณี — การลดจำนวนในตู้ที่เกินอยู่แล้วบันทึกได้เสมอ

### Planning Engine
1. ดึงคำสั่งซื้อที่ยังจัดลงตู้ไม่ครบ เรียงตาม **EDD** (วันกำหนดส่งเร็วสุดก่อน) หรือ **FCFS** (เข้าระบบก่อนได้ก่อน)
2. เลือกวัน: **JIT** (ค่าเริ่มต้น) เริ่มที่วันกำหนดส่งแล้วถอยหลังทีละวัน ถ้าโควตาเต็มจึงเลื่อนหลังกำหนด (แจ้งว่าล่าช้า) — **ASAP** เริ่มจากวันแรกของการวางแผน
3. จำนวนที่จัดได้ต่อวัน = min(ยอดค้าง, โควตาคงเหลือของประเภทสินค้านั้น, พื้นที่ CBM ว่าง, น้ำหนักว่าง)
4. ใส่ตู้ที่เปิดอยู่ (สถานะ "รอกำลังพล") ของลูกค้าเดียวกันก่อน ไม่พอค่อยเปิดตู้ใหม่ (`TBA-xxxx`); สินค้าประเภท D ใช้ตู้ Reefer
5. จัดชั้นในตู้ใหม่: ของหนักไว้ชั้นล่าง

### Roll Over
- **Short Ship**: แผนเดิมถูกปรับเท่ายอดจริง (เก็บยอดแผนเดิมไว้แสดง) และย้ายยอดค้างไปตู้ของลูกค้าเดียวกันในวันถัดไป หรือสร้างตู้ `<เลขตู้>-RO1`
- **Over Ship**: หักยอดเกินออกจากแผนวันถัดๆ ไปของคำสั่งซื้อเดียวกัน ถ้าไม่มีแผนให้หัก จะบันทึกเป็น "ส่งเกินยอดสั่งซื้อ"
- สถานะตู้อัปเดตอัตโนมัติจากยอดจริง: กรอกบางรายการ → กำลังโหลด, กรอกครบ → โหลดเสร็จสิ้น

## งานตู้ Export แบบ Shipment (KK)

ออกแบบจากไฟล์ **Export Plan** จริง (ชีต *Export Shipment Plan*, *Database*, *Bag Pallet_Master*) เมนูอยู่ด้านบนของแถบซ้าย และเป็นหน้าแรกของระบบ

### แนวคิด: ยังไม่รู้เบอร์ตู้/ซีล รู้แค่ Shipment
| ขั้น | สิ่งที่เกิดขึ้น |
|---|---|
| 1. Shipment | Booking no., สายเรือ, จำนวนตู้ (Conts), MT, ถุง, ETD, Closing, First Return — นำเข้าจาก Excel หรือเพิ่มเอง |
| 2. แผนตู้/วัน | ลง **จำนวนตู้ต่อวัน** ในตาราง Shipment × วันที่ (เหมือน Excel; ใน Excel กรอกเป็น MT → ระบบแปลงเป็นตู้ด้วย MT/ตู้) |
| 3. ช่องตู้ 1..N | ระบบสร้างช่อง "ตู้ที่ 1/21 … 21/21" ตามจำนวนตู้ใน Booking สถานะ **รอตู้ (TBA)** และจับคู่กับวันในแผนอัตโนมัติ |
| 4. รถเข้า (Gate-in) | หน้า "งานโหลดประจำวัน" กรอกเบอร์ตู้ → ตรวจ **ISO 6346 check digit**, เบอร์ซ้ำ, มี Booking แล้ว → สถานะ *ตู้เข้าโรงงาน* |
| 5. โหลด/ปิดซีล | กรอกเวลาเริ่ม → *กำลังโหลด*; ซีล + เวลาเสร็จ + NW จริง → *โหลดเสร็จ*; ตรวจซีลซ้ำ, NW ±0.2 MT, **VGM** (NW + ถุง + พาเลท + Tare ≤ 30,480 กก.) |
| 6. สิ้นวัน | กระทบยอดแผน vs โหลดจริง; ตู้ที่ค้าง **ปัดไปวันทำงานถัดไป** (ตู้ที่เข้าโรงงานแล้วคงเบอร์ตู้ไว้) |

### กฎที่ตรวจ (ก่อนบันทึก — error ใหม่/แย่ลงจะถามยืนยัน)
- **Capacity หน้างาน**: KK ≤ 15 ตู้/วัน (TK 5, PB 10, CK 3, RY 15) — นับ max(แผน, ตู้ที่เข้าโหลดจริง) ของทุก Shipment = แถว *Total Load*
- **Closing**: ห้ามมีแผนหลังวัน Closing; วัน Closing ต้องเหลือเวลาพอวิ่งรถถึงท่า (ค่าเริ่มต้น 3 ชม.) — Closing 02:59 ต้องโหลดวันก่อนหน้า
- **First Return**: โหลดเร็วกว่า First Return เกิน 1 วัน → เตือนค่า Storage
- **Check (Y/N)**: แผนรวมต้องเท่าจำนวนตู้; เกินจำนวนตู้ใน Booking บันทึกไม่ได้
- **Check conts / VGM**: ถุง ≤ 20 ใบ/ตู้ 20'GP, VGM ประมาณการต่อตู้ไม่เกินพิกัด
- **Booking**: ยังเป็น Waiting แต่มีแผนภายใน 3 วัน → error; รับตู้เปล่าไม่ได้

### นำเข้า Export Plan (.xlsx)
อ่านทุกหน้างานในไฟล์ (หัวข้อ "XX - งานตู้คอนเทนเนอร์" + ข้อจำกัดในคอลัมน์ C), แถวสินค้าเพิ่มเติม (A ว่าง), ช่องเวลา **สีแดง = Closing / สีเหลือง = First Return**, ชื่อลูกค้า/POD จากชีต Database, น้ำหนักถุง/พาเลทจาก Bag Pallet_Master
แถว Dump Truck / SCG / หมายเหตุท้ายตาราง ถูกข้ามพร้อมรายงาน — แผนก่อน "วันนี้" ถือว่าโหลดแล้ว (เลือกปิดได้) — แสดงตัวอย่างก่อนบันทึกเสมอ
ทดสอบกับไฟล์จริงแล้ว: จำนวนตู้ต่อวันตรงกับแถว Total Load ใน Excel ทุกวัน (KK 489 ตู้ / TK 25 ตู้ ช่วง 1 ส.ค.–30 พ.ย.)

### จัดแผนอัตโนมัติ
เรียง Shipment ตาม Closing ใกล้สุด (ไม่มี Closing ใช้ ETD − 1, ไม่มีทั้งคู่ = รอข้อมูลสายเรือ) → วางที่ Closing − 1 วัน (เผื่อ) แล้วถอยหลัง → ไม่เกินตู้/วันของหน้างาน, ไม่ก่อน First Return − 1, ข้ามวันหยุดหน้างาน → แสดงตัวอย่างก่อนบันทึก

### API งานตู้ (/api/kk)
| Method | Path | คำอธิบาย |
|---|---|---|
| GET | `/kk/plan?site=KK&from=&days=21` | ตาราง Shipment × วันที่ + Total Load + แจ้งเตือน |
| PUT | `/kk/plans` | `{shipmentId, date, conts, force}` ตั้งจำนวนตู้ของวัน |
| POST | `/kk/autoplan` | `{siteCode, startDate, bufferDays, horizonDays, dryRun}` |
| GET/POST/PATCH/DELETE | `/kk/shipments[/:id]` | Shipment (GET คืนช่องตู้ทั้งหมด) |
| GET | `/kk/loading?site=&date=` | งานโหลดประจำวัน + กระทบยอด |
| PATCH | `/kk/units/:id` | กรอกเบอร์ตู้/ซีล/เวลา/ถุง/NW/Tare (สถานะเปลี่ยนอัตโนมัติ) |
| POST | `/kk/units/pull` | ดึงช่องตู้มาโหลดเพิ่มวันนี้ (นอกแผน) |
| POST | `/kk/rollover` | `{siteCode, date}` ปัดตู้ค้างไปวันทำงานถัดไป |
| POST | `/kk/import?dryRun=&sites=&pastAsLoaded=` | อัปโหลด .xlsx (application/octet-stream) |
| GET | `/kk/export/plan.csv`, `/kk/export/units.csv` | ส่งออกแผน / รายการตู้-ซีล-VGM (UTF-8 BOM เปิดใน Excel ได้) |
| PATCH | `/kk/sites/:code`, `/kk/pack-materials/:id` | ข้อจำกัดหน้างาน / น้ำหนักถุง-พาเลท |

## REST API — โมดูลทั่วไป (ย่อ)

| Method | Path | คำอธิบาย |
|---|---|---|
| GET | `/api/dashboard?from=YYYY-MM-DD&days=7` | Timeline + KPI + การแจ้งเตือน |
| POST | `/api/planner/generate` | `{startDate, strategy: EDD\|FCFS, dateMode: JIT\|ASAP, containerType, reeferContainerType, horizonDays, dryRun}` |
| GET/POST/PATCH/DELETE | `/api/orders[/:id]` | คำสั่งซื้อ (GET คืน assignedQty/remainingQty) |
| GET/POST/PATCH/DELETE | `/api/containers[/:id]` | ตู้ (GET `/:id` คืนรายการในตู้ + issues) |
| POST | `/api/containers/:id/items` | เพิ่มสินค้าเข้าตู้ `{orderId, qty, layer, force}` |
| PATCH/DELETE | `/api/load-items/:id` | แก้จำนวน/ชั้น หรือนำออก |
| POST | `/api/containers/:id/auto-layer` | จัดชั้นตามน้ำหนัก |
| GET/POST/PATCH/DELETE | `/api/capacity-rules`, `/api/products`, `/api/container-types` | ข้อมูลหลัก |
| GET | `/api/reconciliation?date=` | ตารางกระทบยอด |
| PUT | `/api/reconciliation/actuals` | `{date, entries: [{loadItemId, actualQty, note}]}` |
| POST | `/api/reconciliation/rollover` | `{loadItemIds: [...], targetDate?}` |

## การต่อยอดสู่ Production
- **ฐานข้อมูล**: เขียน repository ใหม่ตาม `database/schema.sql` ให้มี method เดียวกับ `db/store.js` (`all/find/get/insert/update/remove/transaction/simulate`) — services ไม่ต้องแก้
- **Express**: `lib/http.js` มี API เดียวกับ Express Router หากต้องการใช้ Express ให้เปลี่ยน import ใน `routes/*` และ `server.js`
- **ผู้ใช้/สิทธิ์**: แยกบทบาท ผู้จัดการคลัง (แก้ข้อ 1.3, รัน Planner) กับ Operator (กรอกยอดจริง)
- **3D Load Plan**: ปัจจุบันตรวจสอบระดับปริมาตร/น้ำหนัก/ชั้น — หากต้องการตำแหน่งจริงในตู้ ต่อยอดด้วยอัลกอริทึม 3D bin packing ใน `services/`
