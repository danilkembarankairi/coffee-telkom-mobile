
require("dotenv").config();
const mongoose = require("mongoose");
const Menu = require("./models/menu");

const menuItems = [
  {
    name: "Espresso",
    price: 25000,
    desc: "Pure black coffee with a bold, intense flavor and sharp aroma.",
    image: "/espresso.jpg",
    category: "Hot",
  },
  {
    name: "Cappuccino",
    price: 28000,
    desc: "Classic combination of espresso, steamed milk, and velvety foam.",
    image: "/cappucino.jpeg",
    category: "Hot",
  },
  {
    name: "Latte",
    price: 30000,
    desc: "Smooth espresso blended with creamy steamed milk.",
    image: "/latte.jpg",
    category: "Hot",
  },
  {
    name: "Cold Brew",
    price: 33000,
    desc: "Slow-steeped cold coffee with a smooth, refreshing taste.",
    image: "/coldbrew.jpeg",
    category: "Cold",
  },
  {
    name: "Iced Latte",
    price: 30000,
    desc: "A chilled take on the classic latte — refreshing and creamy.",
    image: "/iced-latte.jpg",
    category: "Cold",
  },
  {
    name: "Matcha Latte",
    price: 33000,
    desc: "Premium Japanese matcha blended with fresh milk — calm & cozy.",
    image: "/matcha-latte.jpg",
    category: "Non-Coffee",
  },
];

mongoose
  .connect(process.env.MONGO_URI)
  .then(async () => {
    console.log("MongoDB Connected");
    await Menu.deleteMany({});
    await Menu.insertMany(menuItems);
    console.log("✅ Menu berhasil di-seed ke MongoDB!");
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
