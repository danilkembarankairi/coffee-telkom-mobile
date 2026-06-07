const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name:     String,
  email:    { type: String, unique: true, sparse: true },
  password: String,
  phone:    { type: String, default: '' },

  role: {
    type: String,
    enum: ["user", "admin"],
    default: "user"
  },

  googleId: { type: String, sparse: true },
  avatar:   String,
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);