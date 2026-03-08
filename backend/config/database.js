// import mysql from 'mysql2'

// console.log(process.env.DB_HOST)
// const db = mysql.createConnection({
//     host: 'localhost',
//     user: 'root',
//     password: '',
//     database: 'spotify-chat'
// })

// export default db

import mysql from 'mysql2'
import dotenv from 'dotenv'
dotenv.config()
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_PASSWORD:', process.env.DB_PASSWORD);
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
})

export default db

