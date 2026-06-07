const express = require('express');
const router = express.Router();
const snap = require('midtrans-client').Snap;
const jwt = require('jsonwebtoken');
const Order = require('../models/Order');
const User = require('../models/user');

// Inisialisasi Midtrans
let snapAPI = new snap({
  isProduction: false,
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY
});

// Middleware verifikasi token
const auth = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ msg: 'No token, authorization denied' });
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (err) {
    res.status(401).json({ msg: 'Token is not valid' });
  }
};

// POST /api/payment/midtrans
router.post('/midtrans', auth, async (req, res) => {
  const { orderId } = req.body;

  try {
    // Karena field di Order adalah userId, kita populate dengan userId
    const order = await Order.findById(orderId).populate('userId', 'email name');

    if (!order) return res.status(404).json({ msg: 'Order not found' });

    const parameter = {
      transaction_details: {
        order_id: order._id.toString(),
        gross_amount: order.totalAmount  // Pastikan field ini benar
      },
      customer_details: {
        first_name: order.userId.name,  // Ambil dari populated userId
        email: order.userId.email
      }
    };

    const transaction = await snapAPI.createTransaction(parameter);
    res.json(transaction);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/payment/midtrans/callback
router.post('/midtrans/callback', async (req, res) => {
  const notification = req.body;

  try {
    const statusResponse = await snapAPI.transaction.notification(notification);
    const orderId = statusResponse.order_id;
    const transactionStatus = statusResponse.transaction_status;
    const fraudStatus = statusResponse.fraud_status;

    if (transactionStatus === 'capture' || transactionStatus === 'settlement') {
      if (fraudStatus === 'accept') {
        await Order.findByIdAndUpdate(orderId, { status: 'paid' });
      }
    } else if (transactionStatus === 'cancel' || transactionStatus === 'deny' || transactionStatus === 'expire') {
      await Order.findByIdAndUpdate(orderId, { status: 'cancelled' });
    }

    res.status(200).json({ msg: 'Notification received' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;