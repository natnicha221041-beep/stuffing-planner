#!/bin/bash
cd "$(dirname "$0")"
if ! command -v node >/dev/null; then echo "ยังไม่ได้ติดตั้ง Node.js — ดาวน์โหลดจาก https://nodejs.org"; open https://nodejs.org; read -p "กด Enter เพื่อปิด"; exit 1; fi
echo "กำลังเปิด Stuffing Planner ... (ห้ามปิดหน้าต่างนี้ระหว่างใช้งาน)"
(sleep 2; open http://localhost:3000) &
node backend/src/server.js
