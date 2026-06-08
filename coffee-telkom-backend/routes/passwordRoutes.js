const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const User = require('../models/user');
const ResetToken = require('../models/resetToken');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// ─── POST /api/password/forgot ─────────────────────────────────────
router.post('/forgot', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ msg: 'Email harus diisi' });

  try {
    const user = await User.findOne({ email });
    if (!user) return res.json({ msg: 'Jika email terdaftar, kode reset akan dikirim' });

    await ResetToken.deleteMany({ userId: user._id });

    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 jam

    await ResetToken.create({ userId: user._id, token, expiresAt });

    // Potong token jadi lebih pendek untuk ditampilkan
    // tapi tetap kirim full token untuk verifikasi
    await transporter.sendMail({
      from: `"Coffee Telkom" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Kode Reset Password - Coffee Telkom',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 32px; background: #faf7f3; border-radius: 12px;">
          <div style="text-align: center; margin-bottom: 24px;">
            <h2 style="color: #7a5e3a; margin: 0;">☕ Coffee Telkom</h2>
          </div>
          
          <h3 style="color: #3d2e1e;">Reset Password</h3>
          <p style="color: #6d5c49;">Kami menerima permintaan reset password untuk akun <strong>${email}</strong>.</p>
          <p style="color: #6d5c49;">Salin kode di bawah ini dan masukkan ke aplikasi Coffee Telkom. Kode berlaku selama <strong>1 jam</strong>.</p>
          
          <div style="background: #3d2e1e; border-radius: 10px; padding: 20px; margin: 24px 0; text-align: center;">
            <p style="color: #c8a882; font-size: 12px; margin: 0 0 8px 0; letter-spacing: 1px;">KODE RESET PASSWORD</p>
            <p style="color: #ffffff; font-family: monospace; font-size: 14px; word-break: break-all; margin: 0; line-height: 1.6;">${token}</p>
          </div>

          <div style="background: #fff8f0; border: 1px solid #e8d5b7; border-radius: 8px; padding: 14px; margin-bottom: 20px;">
            <p style="color: #8b6f47; font-size: 13px; margin: 0;">
              📱 <strong>Cara pakai:</strong><br>
              1. Buka aplikasi Coffee Telkom<br>
              2. Pilih "Lupa Password" → masukkan email<br>
              3. Copy kode di atas → paste di kolom "Kode Reset"<br>
              4. Buat password baru
            </p>
          </div>
          
          <p style="color: #9b8b78; font-size: 12px;">Jika Anda tidak meminta reset password, abaikan email ini. Kode akan otomatis kadaluarsa dalam 1 jam.</p>
        </div>
      `,
    });

    res.json({ msg: 'Jika email terdaftar, kode reset akan dikirim' });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ msg: 'Gagal mengirim email, coba lagi' });
  }
});

// ─── POST /api/password/reset ──────────────────────────────────────
router.post('/reset', async (req, res) => {
  const { token, newPassword } = req.body;
  if (!token || !newPassword)
    return res.status(400).json({ msg: 'Kode dan password baru harus diisi' });

  if (newPassword.length < 6)
    return res.status(400).json({ msg: 'Password minimal 6 karakter' });

  try {
    const resetToken = await ResetToken.findOne({ token, used: false });

    if (!resetToken) return res.status(400).json({ msg: 'Kode tidak valid atau sudah digunakan' });
    if (new Date() > resetToken.expiresAt) return res.status(400).json({ msg: 'Kode sudah kadaluarsa, minta kode baru' });

    const user = await User.findById(resetToken.userId);
    if (!user) return res.status(400).json({ msg: 'User tidak ditemukan' });

    if (user.password) {
      const isSame = await bcrypt.compare(newPassword, user.password);
      if (isSame) return res.status(400).json({ msg: 'Password baru tidak boleh sama dengan password lama' });
    }

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    resetToken.used = true;
    await resetToken.save();

    res.json({ msg: 'Password berhasil diubah, silakan login' });
  } catch (err) {
    console.error('Reset password error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// ─── GET /api/password/verify-token ───────────────────────────────
router.get('/verify-token', async (req, res) => {
  const { token } = req.query;
  if (!token) return res.status(400).json({ valid: false });

  try {
    const resetToken = await ResetToken.findOne({ token, used: false });
    if (!resetToken) return res.json({ valid: false, msg: 'Kode tidak valid' });
    if (new Date() > resetToken.expiresAt) return res.json({ valid: false, msg: 'Kode sudah kadaluarsa' });
    res.json({ valid: true });
  } catch {
    res.status(500).json({ valid: false });
  }
});

module.exports = router;
