
import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import { createServer } from 'node:http';
import cors from 'cors'
import router from './routes/index.js'
import { Server } from 'socket.io';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL,
  }
})

app.use(express.json())
app.use(cors())
app.use(router)


let users = 0
io.on('connection', (socket) => {
  users++
  console.log('a user connected');
  console.log('active users', users);

  io.emit('active users', users)

  socket.on('disconnect', () => {
    users--
    console.log('user disconnected');
    console.log('active users', users);
    io.emit('active users', users)
  });

  socket.on('connect', () => {
    
  })

  socket.on('chat message', (msg) => {
    io.emit('chat message', msg);
  });

  socket.on('delete message', (msg) => {
    io.emit('delete message', msg);
  });

});

server.listen(process.env.PORT, () => {
  console.log('server running at port:' + process.env.PORT);
});