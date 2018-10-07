express = require 'express'
net     = require 'net'
child   = require 'child_process'

app = express.createServer()

app.get '/stream', (req, res) ->
    res.writeHead 200, {
        'Date': (new Date()).toUTCString()
        'Connection': 'close'
        'Cache-Control': 'private'
        'Content-Type': 'video/webm'
    }

    server = net.createServer (socket) ->
        socket.on 'data', (data) ->
            res.write(data)
        socket.on 'close', (had_error) ->
            res.end()

    server.listen () ->
        args = [
            'v4l2src',
            '!', 'video/x-raw-rgb,framerate=30/1',
            '!', 'ffmpegcolorspace',
            '!', 'vp8enc', 'speed=2',
            '!', 'queue2',
            '!', 'm.', 'autoaudiosrc',
            '!', 'audioconvert',
            '!', 'vorbisenc',
            '!', 'queue2',
            '!', 'm.', 'webmmux', 'name=m', 'streamable=true',
            '!', 'tcpclientsink', 'host=localhost', 'port=' + server.address().port
        ]

        # gst-launch is in Ubuntu package gstreamer-tools
        gst_muxer = child.spawn 'gst-launch', args, null

        gst_muxer.stderr.on 'data', onSpawnError
        gst_muxer.on 'exit', onSpawnExit

        res.connection.on 'close', () ->
            gst_muxer.kill()


app.listen process.env.npm_package_config_port

onSpawnError = (data) ->
    console.log data.toString()

onSpawnExit = (code) ->
    if code?
        console.error 'GStreamer error, exit code ' + code

process.on 'uncaughtException', (err) ->
    console.debug err
