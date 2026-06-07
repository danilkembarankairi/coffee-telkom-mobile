const mongoose = require('mongoose');

const menuSchema = new mongoose.Schema({
  name: { type: String, required: true },
  desc: { type: String },
  price: { type: Number, required: true },
  image: { type: String },
  category: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Menu', menuSchema);