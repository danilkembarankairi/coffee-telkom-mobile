const express = require('express');
const Transaction = require('../models/transaction');
const midtrans = require('../config/midtrans');

const router = express.Router();

router.post('/notification', async (req, res) => {
  try {
    const notification = req.body;

    const notificationData = await midtrans.transaction.notification(notification);
    const orderId = notificationData.order_id;
    const transactionStatus = notificationData.transaction_status;
    const fraudStatus = notificationData.fraud_status;

    const transaction = await Transaction.findOne({ _id: orderId });
    if (!transaction) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    if (transactionStatus === 'capture' && fraudStatus === 'accept') {
      transaction.status = 'paid';
    } else if (transactionStatus === 'cancel' || transactionStatus === 'deny' || transactionStatus === 'expire') {
      transaction.status = 'failed';
    } else if (transactionStatus === 'pending') {
      transaction.status = 'pending';
    }

    await transaction.save();

    res.status(200).json({ status: 'success' });

  } catch (error) {
    console.error('Error handling Midtrans notification:', error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;