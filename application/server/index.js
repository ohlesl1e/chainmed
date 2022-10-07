require('dotenv').config()
const fs = require('fs')
const express = require('express')
const session = require('express-session')
const { createClient } = require('redis')
const RedisStore = require('connect-redis')(session)
const mysql = require('mysql2')
const cors = require('cors')
const csrf = require('csurf')
const { generateNonce, SiweMessage } = require('siwe')
const privateKey = fs.readFileSync('./jwtRS256.key')
const jwt = require('jsonwebtoken')

const ethers = require('ethers')
const provider = new ethers.providers.JsonRpcProvider('HTTP://127.0.0.1:7545')
const signer = provider.getSigner()

const CDDoctorManager = require('./contracts/CDDoctorManager.json')
const CDPatientManager = require('./contracts/CDPatientManager.json')

const DoctorManagerContract = new ethers.Contract(process.env.DM_ADDRESS, CDDoctorManager.abi, provider)
const PatientManagerContract = new ethers.Contract(process.env.PM_ADDRESS, CDPatientManager.abi, provider)

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
    password: process.env.DB_PASS,
    database: 'mydb',
})

const USER_TABLE_WHITELIST = ['doctor', 'patient']


const first = async () => {
    let blockNumber = await provider.getBlockNumber()
    let balance = await provider.getBalance(signer.getAddress())
    console.log({ blockNumber, balance: ethers.utils.formatEther(balance) });
}

connection.connect(err => {
    if (err) {
        console.error(`error connecting: ${err.stack}`)
        return
    }

    app.get('/nonce', (req, res) => {
        console.log('/nonce hit')
        //res.setHeader('Content-Type', 'text/plain')
        return res.send({ nonce: generateNonce(), csrfToken: req.csrfToken() })
    })

    app.post('/login', async (req, res) => {
        console.log('/login hit')
        // login process start
        const { message, signature, type } = req.body
        const siweMessage = new SiweMessage(message)
        try {
            // validate signature
            await siweMessage.validate(signature)
            console.log({ type, wallet: siweMessage.address })
            req.session.address = siweMessage.address

            // check user exist
            switch (type) {
                case 'doctor':
                    // connection.execute(`SELECT * FROM ${type} WHERE user_wallet = ?`, [siweMessage.address], (err, results, fields) => {
                    //     if (err) {
                    //         console.log(err);
                    //         return res.status(500).send("Internal error")
                    //     }

                    //     if (results.length !== 0) {
                    //         return res.status(200).send({ message: "Login success", token: jwt.sign({ type }, privateKey, { algorithm: 'RS256' }) })
                    //     }
                    //     return res.status(404).send("Profile not found")
                    // })
                    DoctorManagerContract.getDoctor(siweMessage.address).then(result => {
                        console.log(result);
                        if (result !== ethers.constants.AddressZero) {
                            return res.status(200).send({ message: "Login success", token: jwt.sign({ type }, privateKey, { algorithm: 'RS256' }) })
                        }
                        return res.status(404).send("Profile not found")
                    })
                    break;
                case 'patient':
                    PatientManagerContract.getPatient(siweMessage.address).then(result => {
                        console.log(result);
                        if (result !== ethers.constants.AddressZero) {
                            return res.status(200).send({ message: "Login success", token: jwt.sign({ type }, privateKey, { algorithm: 'RS256' }) })
                        }
                        return res.status(404).header({ location: '/new-patient' }).send("Profile not found")
                    })
                    break
                default:
                    break;
            }

            // if (USER_TABLE_WHITELIST.includes(type)) {
            //     connection.execute(`SELECT * FROM ${type} WHERE user_wallet = ?`, [siweMessage.address], (err, results, fields) => {
            //         if (err) {
            //             console.log(err);
            //             return res.status(500).send("Internal error")
            //         }

            //         if (results.length !== 0) {
            //             if (type == 'patient') {
            //                 req.session.profile = results[0]["patient_profile"]
            //             }
            //             return res.status(200).send({ message: "Login success", type })
            //         }
            //         return res.status(404).header({ location: '/new-patient' }).send("Profile not found")
            //     })
            // } else {
            //     return res.status(403).send("Invalid user type")
            // }
        } catch {
            return res.status(403).send("Invalid signature")
        }
    })

    app.post('/register', (req, res) => {
        const { address } = req.body
        console.log(address);
        PatientManagerContract.getPatient(address).then(result => {
            if (result !== ethers.constants.AddressZero) {
                return res.status(200).send({ message: "Registration success", type: 'patient' })
            }
            return res.status(404).header({ location: '/new-patient' }).send("Profile not found")
        })
    })

    app.get('/search_med', (req, res) => {
        console.log(req.query);
        let query = `%${req.query.search.split(' ').join('%')}%`
        connection.execute('SELECT PROPRIETARYNAME,NONPROPRIETARYNAME,MARKETINGCATEGORYNAME,LABELERNAME,SUBSTANCENAME,ACTIVE_NUMERATOR_STRENGTH,ACTIVE_INGRED_UNIT,PHARM_CLASSES FROM medicine WHERE PROPRIETARYNAME LIKE ? OR NONPROPRIETARYNAME LIKE ?', [query, query], (err, result, fields) => {
            if (err) {
                console.error(err);
            }
            console.log(result.length);
            return res.send(result)
        })
    })

    app.options('*', cors())

    app.listen(4000, () => console.log('Listening on port 4000'))
})