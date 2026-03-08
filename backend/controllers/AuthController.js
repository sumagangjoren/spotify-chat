import db from '../config/database.js'
import jwt from 'jsonwebtoken'
import bcrypt from 'bcrypt'

export const login = (req, res) => {
    console.log(req.body)
    console.log("somone tried to login")
    db.query("SELECT * FROM users WHERE username = ?", req.body.username, async (err, result) => {
        if(err) {
            return res.status(500).json({ message: "Internal Server error" })
        }

        if( result.length === 0) {
            return res.status(401).json({ message: "Invalid credentials" })
        }

        const user = result[0]
        const passwordMatch = await bcrypt.compare(req.body.password, user.password)

        if(!passwordMatch) {
            return res.status(401).json({ message: "Invalid credentials" })
        }

        const token = jwt.sign(result[0], process.env.JWT_SECRET)
        res.status(200).json({ user, token })
    })
}

export const register = async (req, res) => {
    console.log(req.body)
    const { username, name, password } = req.body
    const hashedPassword = await bcrypt.hash(password, 10)

    db.query("INSERT INTO users SET username = ?, name = ?, password = ?", [username, name, hashedPassword], (err, result) => {
        if(err) {
            res.send(err)
        }
        else {
            db.query("SELECT id, username, name FROM users WHERE username = ?", req.body.username, (err, result) => {
                if(err) {
                    console.log(err)
                    return res.status(500).json({ message: "Internal Server error" })
                }
                login(req, res)
                // const token = jwt.sign(result[0], 'secret_key_or_smn')
                // res.status(200).json({ user: result[0], token })
            })
        }
    })
}