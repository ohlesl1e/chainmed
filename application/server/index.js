const express = require('express')
const session = require('express-session')
const { createClient } = require('redis')
const RedisStore = require('connect-redis')(session)
const mysql = require('mysql2')
const cors = require('cors')
const csrf = require('csurf')
const { generateNonce, SiweMessage } = require('siwe')

const redisClient = createClient({
    legacyMode: true
});

redisClient.connect().catch(console.error)

const app = express()
app.use(express.json())
app.use(cors())
app.use(session({
    secret: 'ssshhhhh',
    store: new RedisStore({ client: redisClient }),
    saveUninitialized: false,
    resave: false,
    cookie: {
        maxAge: 3600000,
        sameSite: 'lax'
    }
}))
app.use(csrf())

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: ''
})

connection.connect(err => {
    if (err) {
        console.error(`error connecting: ${err.stack}`)
        return
    }

    app.get('/nonce', (req, res) => {
        console.log('/nonce hit')
        res.setHeader('Content-Type', 'text/plain')
        res.send({ nonce: generateNonce(), csrfToken: req.csrfToken() })
    })

    app.post('/login', async (req, res) => {
        console.log('/login hit')
        const { message, signature } = req.body
        const siweMessage = new SiweMessage(message)
        try {
            await siweMessage.validate(signature)
            req.session.signature = signature
            res.send(req.session.signature)
        } catch (error) {
            console.log(error)
            res.send(false)
        }
    })

    app.options('*', cors())

    app.listen(4000, () => console.log('Listening on port 4000'))
})