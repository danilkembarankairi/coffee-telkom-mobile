require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/user');

async function seed() {
  await mongoose.connect(process.env.MONGO_URI);
  const existing = await User.findOne({ email: 'admin@coffee.com' });
  if (existing) { console.log('Admin sudah ada.'); process.exit(); }

  const hashed = await bcrypt.hash('AdminKuat123!', 10);
  await User.create({ name: 'Admin Coffee', email: 'admin@coffee.com', password: hashed, role: 'admin' });
  console.log('✅ Akun admin berhasil dibuat!');
  process.exit();
}

seed().catch(console.error);