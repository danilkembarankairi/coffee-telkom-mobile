const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  items: [
    {
      menu: { type: mongoose.Schema.Types.ObjectId, ref: 'Menu' },
      quantity: Number,
    },
  ],
});

module.exports = mongoose.model('Cart', cartSchema);