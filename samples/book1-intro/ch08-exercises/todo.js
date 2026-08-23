#!/usr/bin/env node
// todo.js — 第一冊第 8 章練習專案
// 用法：
//   node todo.js add "事項"    新增
//   node todo.js list          列出全部
//   node todo.js done <編號>   標記完成
//   node todo.js del <編號>    刪除

const fs = require("fs");
const path = require("path");

const DATA_FILE = path.join(__dirname, "items.json");

function loadItems() {
  try {
    const raw = fs.readFileSync(DATA_FILE, "utf8");
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

function saveItems(items) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(items, null, 2));
}

function addItem(text) {
  if (!text || !text.trim()) {
    console.log('用法：node todo.js add "事項內容"');
    process.exit(1);
  }
  const items = loadItems();
  items.push({ text: text.trim(), done: false, createdAt: new Date().toISOString() });
  saveItems(items);
  console.log(`已新增：${text.trim()}`);
}

function markDone(indexArg) {
  const index = parseInt(indexArg, 10) - 1;
  if (Number.isNaN(index)) {
    console.log("用法：node todo.js done <編號>");
    process.exit(1);
  }
  try {
    const raw = fs.readFileSync(DATA_FILE, "utf8");
    const items = JSON.parse(raw);
    if (!items[index]) {
      console.log(`找不到第 ${indexArg} 筆。`);
      process.exit(1);
    }
    items[index].done = true;
    items[index].doneAt = new Date().toISOString();
    fs.writeFileSync(DATA_FILE, JSON.stringify(items, null, 2));
    console.log(`已完成：${items[index].text}`);
  } catch {
    console.log("沒有任何待辦事項。");
    process.exit(1);
  }
}

function deleteItem(indexArg) {
  const index = parseInt(indexArg, 10);
  if (Number.isNaN(index)) {
    console.log("用法：node todo.js del <編號>");
    process.exit(1);
  }
  const items = loadItems();
  if (!items[index]) {
    console.log(`找不到第 ${indexArg} 筆。`);
    process.exit(1);
  }
  const [removed] = items.splice(index, 1);
  saveItems(items);
  console.log(`已刪除：${removed.text}`);
}

function listItems(args) {
  const items = loadItems();
  if (items.length === 0) return console.log("（空的，加點事情做吧）");
  items.forEach((it, i) => {
    const mark = it.done ? "x" : " ";
    const when = it.done ? `（完成於 ${it.doneAt}）` : "";
    console.log(`${i + 1}. [${mark}] ${it.text}${when}`);
  });
}

function main() {
  const [cmd, arg, ...rest] = process.argv.slice(2);
  switch (cmd) {
    case "add":
      addItem(arg);
      break;
    case "list":
      listItems(rest);
      break;
    case "done":
      markDone(arg);
      break;
    case "del":
      deleteItem(arg);
      break;
    default:
      console.log("用法：node todo.js <add|list|done|del> [...]");
  }
}

main();
