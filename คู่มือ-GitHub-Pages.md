# คู่มือเอา Stuffing Planner ขึ้น GitHub Pages (ฟรี)

ใช้ไฟล์ **github-pages.zip** (ไฟล์เว็บพร้อมใช้ ไม่ต้องติดตั้งอะไร)
ถ้าแก้โค้ดเอง สร้างไฟล์ชุดนี้ใหม่ได้ด้วย `npm run build:pages` → โฟลเดอร์ `dist/github-pages/`

## 1. สมัคร / เข้าสู่ระบบ GitHub
https://github.com → Sign up (แผน Free)

## 2. สร้าง Repository
1. มุมขวาบน **+** → **New repository**
2. Repository name: `stuffing-planner`
3. เลือก **Public** (GitHub Pages ฟรีใช้ได้เฉพาะ Public)
4. ติ๊ก **Add a README file** → **Create repository**

## 3. อัปโหลดไฟล์เว็บ
1. แตกไฟล์ `github-pages.zip` ในเครื่อง
2. ในหน้า Repository กด **Add file → Upload files**
3. เปิดโฟลเดอร์ที่แตกไว้ เลือก **ทุกไฟล์และทุกโฟลเดอร์ข้างใน** (index.html, css, js, backend, shims) แล้วลากมาวาง
   - ต้องเห็น `index.html` อยู่ชั้นนอกสุด ไม่ใช่อยู่ในโฟลเดอร์ย่อยอีกชั้น
4. กด **Commit changes** (จะถามว่าเขียนทับ README ไหม — ทับได้)

## 4. เปิด GitHub Pages
1. แท็บ **Settings** → เมนูซ้าย **Pages**
2. Source: **Deploy from a branch** → Branch: **main** / **(root)** → **Save**
3. รอ 1–2 นาที แล้วรีเฟรชหน้านี้ จะเห็นลิงก์ `https://ชื่อผู้ใช้.github.io/stuffing-planner/`

## 5. ใช้งาน
- เปิดลิงก์ → เมนู **หน้างาน & นำเข้าไฟล์** → **นำเข้า Export Plan (.xlsx)**
- ไฟล์ Excel ถูกอ่านใน Browser ของคุณเท่านั้น **ไม่ได้อัปโหลดขึ้น GitHub**

## ข้อควรรู้
- ข้อมูลเก็บใน Browser ของแต่ละเครื่อง (IndexedDB) — เครื่องอื่นจะไม่เห็นข้อมูลชุดนี้
- ส่งต่อข้อมูล: เมนู **หน้างาน & นำเข้าไฟล์ → ดาวน์โหลดไฟล์สำรอง (.json)** → ส่งให้เพื่อน → เพื่อนกด **กู้คืนจากไฟล์สำรอง**
- อย่าใช้โหมดไม่ระบุตัวตน (Incognito) และอย่ากด Clear site data — ข้อมูลจะหาย ควรสำรองเป็นระยะ
- **ห้ามอัปโหลดไฟล์ Excel หรือไฟล์สำรองข้อมูลจริงขึ้น Repository** (Public = ทุกคนเห็น)
- อัปเดตเวอร์ชันใหม่: อัปโหลดไฟล์ชุดใหม่ทับใน Repository เดิม ข้อมูลใน Browser ยังอยู่
