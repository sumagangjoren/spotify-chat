import express from 'express'
import jwt from 'jsonwebtoken'


const router = express.Router()

import { getAllMessages, storeMessage, deleteMessage } from '../controllers/ChatController.js'
import { login, register } from '../controllers/AuthController.js'

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization']
    console.log(authHeader)
    const token = authHeader && authHeader.split(' ')[1]
    console.log("hello ferson from middleware! your token is: " + token)
    if(token == null) return res.sendStatus(401)

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if(err) return res.sendStatus(403)
        req.user = user
        next()
    })
}

router.get('/', authenticateToken, getAllMessages)
router.post('/login', login)
router.post('/register', register)
router.post('/send-message', authenticateToken, storeMessage)
router.delete('/delete-message/:id', authenticateToken, deleteMessage)




export default router