'use strict'

var app = require('express')(),
    http = require('http').createServer(app),
    io = require('socket.io')(http),
    port = process.env.PORT || 3000,
    publicDir = `${__dirname}/public`


http.listen(port, () => {
    console.log('localhost: ', port);
})

app
    //.use(publicDir)
    .get('/', (req, res) =>{
      res.sendFile(`${publicDir}/client.html`)
    })
    .get('/1111/streaming', (req, res) => {
      res.sendFile(`${publicDir}/server.html`)
      io.on('connection', (socket) =>{
          socket.on('streaming', (image) =>{
              io.emit('play stream 1', image)
              //console.log(image);
          })
      })
    })
    
