const http = require('https')
const fs = require('fs')
const crypto = require('crypto')
const port = 3000
const file = fs.readFileSync('./index.html')
const fileJS = fs.readFileSync('./batchsdk-worker-loader.js')

const privateKey = fs.readFileSync('ssl/server.key');
const certificate = fs.readFileSync('ssl/server.crt');


const requestHandler = (request, response) => {
    console.log(request.url)
    let r = (request.url == "/batchsdk-worker-loader.js") ? fileJS : file
    response.setHeader('content-type', (request.url == "/batchsdk-worker-loader.js") ? 'text/javascript' : 'text/html')
    response.end(r)
}

const server = http.createServer({ key: privateKey, cert: certificate }, requestHandler)
function start() {
    server.listen(port, (err) => {
        if (err) {
            return console.log('something bad happened', err)
        }

        console.log(`server is listening on ${port}`)
    })
}
function stop(cb) {
    server.close(cb)
}

exports.start = start
exports.stop = stop
start()