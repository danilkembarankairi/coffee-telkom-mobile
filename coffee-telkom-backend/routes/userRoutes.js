const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/user');
const auth = require('../middleware/auth');

// ─── GET /api/user/profile ────────────────────────────────────────
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    if (!user) return res.status(404).json({ msg: 'User tidak ditemukan' });

    res.json({
      msg: 'Profil berhasil diambil',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone || '',
        role: user.role,
        avatar: user.avatar || null,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// ─── PUT /api/user/profile ────────────────────────────────────────
router.put('/profile', auth, async (req, res) => {
  const { name, phone } = req.body;

  if (!name || name.trim() === '') {
    return res.status(400).json({ msg: 'Nama tidak boleh kosong' });
  }

  try {
    // ✅ FIX: Pakai $set eksplisit agar field phone yang belum ada
    // di dokumen lama tetap bisa ditambahkan/diupdate
    // Dan pisahkan .select() dari options object
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: { name: name.trim(), phone: (phone || '').trim() } },
      { new: true }
    ).select('-password');

    if (!user) return res.status(404).json({ msg: 'User tidak ditemukan' });

    console.log('[UPDATE PROFILE] userId:', req.user._id, 'phone:', user.phone);

    res.json({
      msg: 'Profil berhasil diperbarui',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone || '',
        role: user.role,
        avatar: user.avatar || null,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// ─── PUT /api/user/change-password ───────────────────────────────
router.put('/change-password', auth, async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    return res.status(400).json({ msg: 'Semua field harus diisi' });
  }
  if (newPassword.length < 6) {
    return res.status(400).json({ msg: 'Password baru minimal 6 karakter' });
  }

  try {
    const user = await User.findById(req.user._id);

    if (!user.password) {
      return res.status(400).json({
        msg: 'Akun Google tidak bisa ganti password di sini',
      });
    }

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Password lama tidak sesuai' });
    }

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    res.json({ msg: 'Password berhasil diubah' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;