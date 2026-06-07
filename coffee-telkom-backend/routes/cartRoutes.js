const express = require('express');
const router = express.Router();
const Cart = require('../models/cart');
const auth = require('../middleware/auth');

router.post('/', auth, async (req, res) => {
  const { menuId, quantity } = req.body;
  try {
    let cart = await Cart.findOne({ user: req.user._id });
    if (!cart) {
      cart = new Cart({ user: req.user._id, items: [] });
    }

    const existingItem = cart.items.find(item => item.menu.toString() === menuId);
    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.items.push({ menu: menuId, quantity });
    }

    await cart.save();
    res.json(cart);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;