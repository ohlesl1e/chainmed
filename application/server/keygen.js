const crypto = require('crypto');
const fs = require('fs');

crypto.generateKeyPair('rsa', {
    modulusLength: 4096,
    publicKeyEncoding: {
        type: 'spki',
        format: 'pem'
    },
    privateKeyEncoding: {
        type: 'pkcs8',
        format: 'pem',
        cipher: 'aes-256-cbc',
        passphrase: 'top secret'
    }
}, (err, pub, pri) => {
    console.log({ err, pub, pri });
    fs.writeFileSync('./jwtRS256.key', pri)
    fs.writeFileSync('../client/src/lib/jwtRS256.key.pub', pub)
})