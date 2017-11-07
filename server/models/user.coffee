mongoose = require 'mongoose'

userSchema = new mongoose.Schema {
  # email: { type: String, unique: yes }
  displayName: String
  username: String
  photo: String

  # provider credential metadata
  provider: String
  providerId: Number
}, { timestamps: yes }

userSchema.index { provider: 1, providerId: 1 }, { unique: yes }

userSchema.plugin require 'mongoose-findorcreate'

User = mongoose.model 'User', userSchema

module.exports = User
