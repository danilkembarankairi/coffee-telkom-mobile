// routes/checkout.js
const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const { protect } = require('../middleware/authMiddleware');
const { body, validationResult } = require('express-validator');

// Checkout (Create Order from Cart)
router.post('/',
    protect,
    [
        body('items').isArray().withMessage('Items must be an array'),
        body('items.*.product').notEmpty().withMessage('Product name is required'),
        body('items.*.price').isNumeric().withMessage('Price must be a number'),
        body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
        body('totalAmount').isNumeric().withMessage('Total amount must be a number')
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { items, totalAmount } = req.body;
        const userId = req.user._id;

        try {
            // Validate totalAmount matches sum of items
            const calculatedTotal = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            if (Math.abs(calculatedTotal - totalAmount) > 0.01) {
                return res.status(400).json({ message: 'Total amount does not match item prices' });
            }

            const order = new Order({
                user: userId,
                items,
                totalAmount,
                status: 'pending'
            });

            await order.save();

            res.status(201).json({
                message: 'Order created successfully',
                order: {
                    id: order._id,
                    totalAmount: order.totalAmount,
                    status: order.status,
                    createdAt: order.createdAt
                }
            });
        } catch (err) {
            res.status(500).json({ message: 'Server error' });
        }
        // routes/checkout.js (tambahkan ini di bawah route checkout)

const axios = require('axios');

// Create Midtrans Payment
router.post('/payment',
    protect,
    async (req, res) => {
        const { orderId } = req.body;

        try {
            const order = await Order.findById(orderId).populate('user');
            if (!order) {
                return res.status(404).json({ message: 'Order not found' });
            }

            if (order.status !== 'pending') {
                return res.status(400).json({ message: 'Order is not pending' });
            }

            // Midtrans API request
            const midtransUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';
            const auth = Buffer.from(process.env.MIDTRANS_SERVER_KEY + ':').toString('base64');

            const payload = {
                transaction_details: {
                    order_id: `ORDER_${orderId}`,
                    gross_amount: order.totalAmount
                },
                customer_details: {
                    first_name: order.user.name || 'Customer',
                    email: order.user.email
                },
                item_details: order.items.map(item => ({
                    id: item.product,
                    price: item.price,
                    quantity: item.quantity,
                    name: item.product
                }))
            };

            const response = await axios.post(midtransUrl, payload, {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Basic ${auth}`
                }
            });

            // Simpan transactionId ke order
            order.transactionId = response.data.token;
            order.status = 'pending'; // atau 'paid' jika sudah dibayar
            await order.save();

            res.json({
                redirect_url: response.data.redirect_url,
                transaction_id: response.data.token
            });

        } catch (err) {
            console.error('Midtrans Error:', err.response?.data || err.message);
            res.status(500).json({ message: 'Payment failed' });
        }
    }
);
    }
);

module.exports = router;