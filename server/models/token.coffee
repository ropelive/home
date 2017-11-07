mongoose = require 'mongoose'
uuid = require 'uuid'

{ ObjectId } = mongoose.Schema.Types

# for default names
counter = 0

tokenSchema = new mongoose.Schema {
  user: { type: ObjectId, ref: 'User' }
  label: { type: String, default: -> "token-#{counter++}" }
  value: { type: String, default: uuid.v4, index: yes }
}, { timestamps: yes }

Token = mongoose.model 'Token', tokenSchema

module.exports = Token
