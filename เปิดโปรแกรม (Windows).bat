@echo off
chcp 65001 >nul
title Stuffing Planner
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo [!] ยังไม่ได้ติดตั้ง Node.js - กรุณาดาวน์โหลดจาก https://nodejs.org (เลือก LTS) แล้วเปิดไฟล์นี้อีกครั้ง
  start https://nodejs.org
  pause
  exit /b
)
echo กำลังเปิด Stuffing Planner ... (ห้ามปิดหน้าต่างนี้ระหว่างใช้งาน)
start "" http://localhost:3000
node backend\src\server.js
pause
