import mysql from "mysql2";
import dotenv from "dotenv";

dotenv.config();

const dbUrl = new URL(process.env.DATABASE_URL);

const db = mysql.createConnection({
  host: dbUrl.hostname,
  user: dbUrl.username,
  password: dbUrl.password,
  database: dbUrl.pathname.replace("/", ""),
  port: dbUrl.port,

  // ✅ REQUIRED for Aiven
  ssl: {
    rejectUnauthorized: true
  }
});

export default db;