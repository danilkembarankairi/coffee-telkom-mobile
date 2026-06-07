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
    // Selalu kirim response sama agar tidak bocorkan info email terdaftar/tidak
    if (!user) return res.json({ msg: 'Jika email terdaftar, link reset akan dikirim' });

    // Hapus token lama jika ada
    await ResetToken.deleteMany({ userId: user._id });

    // Buat token baru
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 jam

    await ResetToken.create({ userId: user._id, token, expiresAt });

    const resetLink = `${process.env.BASE_URL}/reset-password?token=${token}`;

    await transporter.sendMail({
      from: `"Coffee Telkom" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Reset Password - Coffee Telkom',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 32px; background: #faf7f3; border-radius: 12px;">
          <h2 style="color: #7a5e3a; text-align: center;">☕ Coffee Telkom</h2>
          <h3 style="color: #3d2e1e;">Reset Password</h3>
          <p style="color: #6d5c49;">Kami menerima permintaan reset password untuk akun Anda.</p>
          <p style="color: #6d5c49;">Klik tombol di bawah untuk membuat password baru. Link ini berlaku selama <strong>1 jam</strong>.</p>
          <div style="text-align: center; margin: 32px 0;">
            <a href="${resetLink}" style="background: #7a5e3a; color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: bold;">
              Reset Password
            </a>
          </div>
          <p style="color: #9b8b78; font-size: 12px;">Jika Anda tidak meminta reset password, abaikan email ini.</p>
          <p style="color: #9b8b78; font-size: 12px;">Link: <a href="${resetLink}">${resetLink}</a></p>
        </div>
      `,
    });

    res.json({ msg: 'Jika email terdaftar, link reset akan dikirim' });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ msg: 'Gagal mengirim email, coba lagi' });
  }
});

// ─── POST /api/password/reset ──────────────────────────────────────
router.post('/reset', async (req, res) => {
  const { token, newPassword } = req.body;
  if (!token || !newPassword)
    return res.status(400).json({ msg: 'Token dan password baru harus diisi' });

  if (newPassword.length < 6)
    return res.status(400).json({ msg: 'Password minimal 6 karakter' });

  try {
    const resetToken = await ResetToken.findOne({ token, used: false });

    if (!resetToken) return res.status(400).json({ msg: 'Link tidak valid atau sudah digunakan' });
    if (new Date() > resetToken.expiresAt) return res.status(400).json({ msg: 'Link sudah kadaluarsa, minta link baru' });

    const user = await User.findById(resetToken.userId);
    if (!user) return res.status(400).json({ msg: 'User tidak ditemukan' });

    // Cek password baru tidak sama dengan yang lama
    if (user.password) {
      const isSame = await bcrypt.compare(newPassword, user.password);
      if (isSame) return res.status(400).json({ msg: 'Password baru tidak boleh sama dengan password lama' });
    }

    // Update password
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    // Tandai token sudah dipakai
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
    if (!resetToken) return res.json({ valid: false, msg: 'Link tidak valid' });
    if (new Date() > resetToken.expiresAt) return res.json({ valid: false, msg: 'Link sudah kadaluarsa' });
    res.json({ valid: true });
  } catch {
    res.status(500).json({ valid: false });
  }
});

module.exports = router;