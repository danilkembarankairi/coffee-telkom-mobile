const express = require('express');
const router = express.Router();
const Menu = require('../models/menu');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');

// GET semua menu - untuk user/customer
router.get('/', async (req, res) => {
  try {
    const menus = await Menu.find().sort({ createdAt: -1 });
    res.json(menus);
  } catch (err) {
    res.status(500).json({ msg: 'Server error', error: err.message });
  }
});

// POST tambah menu - admin only
router.post('/', auth, admin, async (req, res) => {
  try {
    const { name, desc, price, image, category } = req.body;

    const newMenu = new Menu({
      name,
      desc,
      price: Number(price),
      image,
      category
    });

    const savedMenu = await newMenu.save();
    res.status(201).json(savedMenu);
  } catch (err) {
    res.status(500).json({ msg: 'Server error', error: err.message });
  }
});

// PUT edit menu - admin only
router.put('/:id', auth, admin, async (req, res) => {
  try {
    const { name, desc, price, image, category } = req.body;

    const updatedMenu = await Menu.findByIdAndUpdate(
      req.params.id,
      {
        name,
        desc,
        price: Number(price),
        image,
        category
      },
      { new: true }
    );

    if (!updatedMenu) {
      return res.status(404).json({ msg: 'Menu tidak ditemukan' });
    }

    res.json(updatedMenu);
  } catch (err) {
    res.status(500).json({ msg: 'Server error', error: err.message });
  }
});

// DELETE hapus menu - admin only
router.delete('/:id', auth, admin, async (req, res) => {
  try {
    const deletedMenu = await Menu.findByIdAndDelete(req.params.id);

    if (!deletedMenu) {
      return res.status(404).json({ msg: 'Menu tidak ditemukan' });
    }

    res.json({ msg: 'Menu berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ msg: 'Server error', error: err.message });
  }
});

module.exports = router;