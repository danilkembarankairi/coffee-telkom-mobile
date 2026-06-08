const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/user');

// ─── Helper buat JWT (include role) ───────────────────────────────
const makeToken = (userId, role) =>
  jwt.sign({ userId, role }, process.env.JWT_SECRET, { expiresIn: '7d' });

// ─── POST /api/auth/register ───────────────────────────────────────
router.post('/register', async (req, res) => {
  const { name, email, phone, password } = req.body;
  if (!name || !email || !phone || !password)
    return res.status(400).json({ msg: 'Semua field harus diisi' });

  try {
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ msg: 'Email sudah terdaftar' });

    const salt = await bcrypt.genSalt(10);
    const hashed = await bcrypt.hash(password, salt);
    user = await User.create({ 
      name, 
      email, 
      phone,
      password: hashed 
    });

    const token = makeToken(user._id, user.role);
    res.json({
      msg: 'Registrasi berhasil',
      token,
      user: { id: user._id, name: user.name, email: user.email, phone: user.phone || '', role: user.role },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// ─── POST /api/auth/login ──────────────────────────────────────────
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ msg: 'Email dan password harus diisi' });

  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ msg: 'Email atau password salah' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ msg: 'Email atau password salah' });

    const token = makeToken(user._id, user.role);
    res.json({
      msg: 'Login berhasil',
      token,
      user: { id: user._id, name: user.name, email: user.email, phone: user.phone || '', role: user.role },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// ─── POST /api/auth/google ─────────────────────────────────────────
router.post('/google', async (req, res) => {
  const { access_token } = req.body;
  if (!access_token)
    return res.status(400).json({ msg: 'Google access_token diperlukan' });

  try {
    const googleRes = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
      headers: { Authorization: `Bearer ${access_token}` },
    });

    if (!googleRes.ok)
      return res.status(401).json({ msg: 'Google token tidak valid' });

    const { sub: verifiedGoogleId, email: verifiedEmail, name: verifiedName, picture } = await googleRes.json();

    let user = await User.findOne({ $or: [{ googleId: verifiedGoogleId }, { email: verifiedEmail }] });
    if (!user) {
      user = await User.create({
        name: verifiedName,
        email: verifiedEmail,
        googleId: verifiedGoogleId,
        avatar: picture,
      });
    } else if (!user.googleId) {
      user.googleId = verifiedGoogleId;
      if (!user.avatar) user.avatar = picture;
      await user.save();
    }

    const token = makeToken(user._id, user.role);
    res.json({
      msg: 'Login Google berhasil',
      token,
      user: { id: user._id, name: user.name, email: user.email, avatar: user.avatar, role: user.role },
    });
  } catch (err) {
    console.error('Google auth error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;