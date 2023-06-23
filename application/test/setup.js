const Application = artifacts.require("Chaindoser");
const Manager = artifacts.require("Manager");
const Patient = artifacts.require("Patient")
const axios = require('axios')
const mysql = require('mysql2')
const moment = require('moment')
const fs = require('fs');
const { Parser } = require('json2csv');
const cliProgress = require('cli-progress');
require('dotenv').config()
const envfile = require('envfile')

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: process.env.DB_PASS,
    database: 'mydb',
})

const paths = ['./.env', './chaindoser/.env', './chaindoser/.env.production', './manager/.env']

const scheduleUnit = ['d', 'w', 'M']
const genders = ['male', 'female', 'non-binary']
const foodAllergy = [
    "Balsam of Peru",
    "Buckwheat",
    "Celery",
    "Egg",
    "Fish",
    "Fruit",
    "Garlic",
    "Oats",
    "Maize",
    "Milk",
    "Mustard",
    "Peanut",
    "Poultry Meat",
    "Rice",
    "Sesame",
    "Shellfish",
    "Tartrazine",
    "Tree nut",
    "Wheat",
];
const medAllergy = [
    "Tetracycline",
    "Dilantin",
    "Tegretol",
    "Penicillin",
    "Cephalosporins",
    "Sulfonamides",
    "Non-steroidal anti-inflammatories",
    "Intravenous contrast dye",
    "Local anesthetics",
];

const usd = 1300
let previousTimestamp = Math.floor(new Date().getTime() / 1000)

const compareArrays = (a, b) => {
    return JSON.stringify(a) === JSON.stringify(b);
};

const getTransaction = async (type, transactionHash) => {
    let trx = await web3.eth.getTransaction(transactionHash)
    let trxReceipt = await web3.eth.getTransactionReceipt(transactionHash)
    let block = await web3.eth.getBlock(trx.blockNumber)
    let gasUsed = trxReceipt.gasUsed * trx.gasPrice;
    let res = {
        'type': type,
        'gasUsed': trxReceipt.gasUsed,
        'gasPrice': web3.utils.fromWei(trx.gasPrice, 'gwei'),
        '1ETH*USD': usd,
        'gasUsed*gasPrice(Ether)': web3.utils.fromWei(gasUsed.toString(), 'ether'),
        'gasUsed*gasPrice(USD)': web3.utils.fromWei(gasUsed.toString(), 'ether') * usd,
        'time(s)': block.timestamp - previousTimestamp
    }
    previousTimestamp = block.timestamp
    // console.log({ trx, trxReceipt, block });
    return res
}

const exportTransaction = (transactions, filename) => {
    // console.log(transactions);
    const output = new Parser({
        fields: ['type',
            'gasUsed',
            'gasPrice',
            '1ETH*USD',
            'gasUsed*gasPrice(Ether)',
            'gasUsed*gasPrice(USD)',
            'time(s)'],
        header: true
    }).parse(transactions)
    fs.writeFileSync(`./log/${filename}.csv`, output)
}

const isValidNonZeroAddress = (address) => {
    if (web3.utils.isAddress(address)) {
        return parseInt(address, 16) !== 0
    }
    return false
}

const getRandomUint = (min, max) => {
    min = Math.ceil(min)
    max = Math.floor(max)
    return Math.floor(Math.random() * (max - min) + min)
}

const timeout = ms => new Promise(resolve => setTimeout(resolve, ms))

const getInfo = async () => {
    const res = (await axios.get('https://api.api-ninjas.com/v1/randomuser', {
        headers: { 'X-Api-Key': '64+omSqijRq2AO8iwDwaoA==VN9F5JioJSciClcN' }
    })).data
    return {
        name: web3.utils.padRight(web3.utils.asciiToHex(res.name), 64),
        gender: web3.utils.padRight(web3.utils.asciiToHex(genders[getRandomUint(0, 3)]), 64),
        dob: new Date(res.birthday),
        height: getRandomUint(150, 200),
        weight: getRandomUint(5000, 10000),
        allergy: [],
        alcohol: getRandomUint(0, 2) === 1 ? true : false,
        smoke: getRandomUint(0, 2) === 1 ? true : false,
        cannabis: getRandomUint(0, 2) === 1 ? true : false
    }
}

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Application", async (accounts) => {
    console.log(accounts);

    it("should assert true", async () => {
        // const application = await Application.at(process.env.PUBLIC_APPLICATION_ADDRESS);
        // const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
        const application = await Application.deployed();
        const manager = await Manager.deployed()
        console.log({
            application: application.address,
            manager: manager.address
        });

        for (const path of paths) {
            fs.readFile(path, 'utf-8', (err, data) => {
                if (err) {
                    console.log(err);
                    return
                }

                const parsedFile = envfile.parse(data)
                parsedFile['PUBLIC_APPLICATION_ADDRESS'] = application.address
                parsedFile['PUBLIC_MANAGER_ADDRESS'] = manager.address

                fs.writeFileSync(path, envfile.stringify(parsedFile))

                // console.log(parsedFile);
            })
        }



        return assert.isTrue(true);
    });

    it('should add 2 doctors', async () => {
        // const application = await Application.at(process.env.PUBLIC_APPLICATION_ADDRESS);
        // const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
        const application = await Application.deployed();
        const manager = await Manager.deployed()
        const transactions = []


        const doc1 = application.addDoctor(accounts[accounts.length - 1], web3.utils.toHex('Dolores Haze'), web3.utils.toHex('Kaiser Permanente'))
        const doc2 = application.addDoctor(accounts[accounts.length - 2], web3.utils.toHex('Jonah Vogelbaum'), web3.utils.toHex('Vought International'))

        transactions.push(await getTransaction('add doctor', (await doc1).tx))
        transactions.push(await getTransaction('add doctor', (await doc2).tx))

        const prof1 = await manager.getDoctor(accounts[accounts.length - 1])
        const prof2 = await manager.getDoctor(accounts[accounts.length - 2])

        console.log({ doc1: prof1, doc2: prof2 })

        // exportTransaction(transactions, 'addDoctor')

        return assert.isTrue(isValidNonZeroAddress(prof1) && isValidNonZeroAddress(prof2))
    })

    it(`should add ${accounts.length - 3} patients`, async () => {
        // const application = await Application.at(process.env.PUBLIC_APPLICATION_ADDRESS);
        // const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
        const application = await Application.deployed()
        const manager = await Manager.deployed()
        const transactions = []
        const trxReceipt = []
        const addresses = []
        const multiBar = new cliProgress.MultiBar({
            clearOnComplete: false,
            hideCursor: false
        }, cliProgress.Presets.shades_classic);
        const bar1 = multiBar.create(3, 0)
        const bar2 = multiBar.create(3, 0)

        for (let i = 0; i < 3; i++) {
            // const res = (await axios.get('https://api.api-ninjas.com/v1/randomuser', {
            //     headers: { 'X-Api-Key': '64+omSqijRq2AO8iwDwaoA==VN9F5JioJSciClcN' }
            // })).data
            // console.log(res);
            const account = accounts[i]
            const { name, gender, dob, height, weight, allergy, alcohol, smoke, cannabis } = await getInfo()

            console.log({ name, gender, dob, height, weight, allergy, alcohol, smoke, cannabis });

            if (i === 1) {
                transactions.push(manager.addPatient(
                    [name, gender],
                    Math.abs(Math.floor(dob.getTime() / 1000)),
                    [height, weight],
                    allergy,
                    [alcohol, smoke, cannabis],
                    [false, account]
                ))
            } else {
                transactions.push(application.addPatient(
                    [name, gender],
                    Math.abs(Math.floor(dob.getTime() / 1000)),
                    [height, weight],
                    allergy,
                    [alcohol, smoke, cannabis],
                    { from: account }
                ))
            }

            // const patient = application.addPatient(
            //   [name,
            //     gender],
            //   Math.abs(Math.floor(dob.getTime() / 1000)),
            //   height,
            //   weight,
            //   allergy,
            //   [alcohol,
            //     smoke,
            //     cannabis],
            //   { from: account }
            // )
            // console.log(patient);


            // const prof = await manager.getPatient(account)
            // console.log({ account, patient, prof });

            // addresses.push(isValidNonZeroAddress(prof))
            bar1.increment()
        };

        bar1.stop()
        for (let trx of transactions) {
            trxReceipt.push(await getTransaction('add patient', (await trx).tx))
            bar2.increment()
        }

        bar2.stop()

        // transactions = transactions.map(async value => (await value).tx)

        // console.log({ trxReceipt });

        for (let i = 0; i < 3; i++) {
            if (i !== 4) {
                addresses.push(await manager.getPatient(accounts[i]))
            }
        }

        // addresses = accounts.map(async (value, index) => index < accounts.length - 2 && isValidNonZeroAddress(await manager.getPatient(value)))

        console.log({ addresses });


        // exportTransaction(trxReceipt, 'addPatient')

        return assert.isTrue(addresses.every(value => isValidNonZeroAddress(value)))
    })

    it(`2 doctors request access`, async () => {
        // const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
        const manager = await Manager.deployed()
        const transactions = []
        const trxReceipt = []
        const multiBar = new cliProgress.MultiBar({
            clearOnComplete: false,
            hideCursor: false
        }, cliProgress.Presets.shades_classic);
        const bar1 = multiBar.create(2 * (accounts.length - 2), 0)
        const bar2 = multiBar.create(2 * (accounts.length - 2), 0)

        // await Promise.all([
        //     transactions.push(manager.doctorRequest(patient, { from: doctor })),
        //     timeout(300)
        // ])

        for (let i = 0; i < 2; i++) {
            const doctor = accounts[accounts.length - i - 1]
            for (let j = 0; j < 3; j++) {
                bar1.increment()
                if (!(i === 2 && j === 2)) {
                    const patient = accounts[j]
                    // console.log({ patient });
                    await Promise.all([
                        transactions.push(manager.doctorRequest(patient, { from: doctor })),
                        timeout(300)
                    ])

                    // console.log({ i, j });
                }
            }
        }

        bar1.stop()
        for (const trx of transactions) {
            trxReceipt.push(await getTransaction('request access', (await trx).tx))
            bar2.increment()
        }

        bar2.stop()
        // exportTransaction(trxReceipt, 'requestAccess')

        return assert.isTrue(true)
    })

    it(`all patients accept doctor requests except patient 2 not accept doctor ${accounts.length - 2}`, async () => {
        // const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
        const manager = await Manager.deployed()
        const transactions = []
        const trxReceipt = []
        const multiBar = new cliProgress.MultiBar({
            clearOnComplete: false,
            hideCursor: false
        }, cliProgress.Presets.shades_classic);
        const bar1 = multiBar.create(2 * (accounts.length - 2), 0)
        const bar2 = multiBar.create(2 * (accounts.length - 2), 0)

        for (let i = 0; i < 3; i++) {
            // console.log({ profile });
            for (let j = 0; j < 2; j++) {
                if ((i === 1 && j === 2)) {
                    continue
                }
                const patient = accounts[i]
                const address = await manager.getPatient(patient)
                const profile = await Patient.at(address)
                const doctor = accounts[accounts.length - j - 1]

                await Promise.all([
                    transactions.push(profile.acceptRequest(doctor, { from: patient })
                        .catch(err => {
                            console.log(`Patient ${i} has no request from doctor ${accounts.length - j - 1}`);
                        })), timeout(300)
                ])

                // transactions.push(profile.acceptRequest(doctor, { from: patient }))
                bar1.increment()
            }
        }

        bar1.stop()
        for (const trx of transactions) {
            if (trx) {
                try {
                    const result = await trx
                    if (result) {
                        trxReceipt.push(await getTransaction('request access', result.tx))
                        bar2.increment()
                    }
                } catch (error) {
                    console.log(error);
                }
            }
        }
        bar2.stop()

        // exportTransaction(trxReceipt, 'acceptRequest')

        return assert.isTrue(true)
    })

    // it(`1 of 2 doctors should have access to patient 2`, async () => {
    //     // const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
    //     const manager = await Manager.deployed()
    //     let readAccessResult = []
    //     let writeAccessResult = []

    //     for (let i = 0; i < 2; i++) {
    //         const doctor = accounts[accounts.length - i - 1]
    //         const patient = await manager.getPatient(accounts[2])
    //         const profile = await Patient.at(patient)

    //         // console.log({ patient, doctor });



    //         try {
    //             let result = await profile.getInfo({ from: doctor })
    //             // console.log(result);
    //             readAccessResult.push(true)
    //         } catch (error) {
    //             // console.log(error);
    //             readAccessResult.push(false)
    //         }
    //         try {
    //             const result = await profile.checkDoctor(doctor, { from: doctor })
    //             // console.log({ result });
    //             writeAccessResult.push(result)
    //         } catch (error) {
    //             writeAccessResult.push(false)
    //         }
    //     }

    //     console.log({ readAccessResult, writeAccessResult });


    //     return assert.isTrue(
    //         compareArrays(readAccessResult, [true, false]) &&
    //         compareArrays(writeAccessResult, [true, false])
    //     )
    // })

    it('Prescrbing stress test', async () => {
        const application = await Application.deployed();
        // const application = await Application.at(process.env.PUBLIC_APPLICATION_ADDRESS)
        const transactions = []
        const trxReceipt = []
        const load = 6
        const con = connection.promise()
        const [results] = await con.execute('SELECT * FROM medicine WHERE ACTIVE_INGRED_UNIT="mg/mL" LIMIT 1000')
        // console.log(results[0]);
        const multiBar = new cliProgress.MultiBar({
            clearOnComplete: false,
            hideCursor: true
        }, cliProgress.Presets.shades_classic);
        const bar1 = multiBar.create(load, 0)
        let doctorCounter = 0
        let patientCounter = 0



        for (let i = 0; i < load; i++) {
            // const [results] = await con.query('SELECT * FROM medicine WHERE medicine_id=?', [i * 2 + 200000])
            const value = results[getRandomUint(0, 1000)]

            const doctor = accounts[accounts.length - doctorCounter - 1]
            const patient = accounts[patientCounter]

            const medicine = value['NONPROPRIETARYNAME']
            const form = web3.utils.padRight(web3.utils.asciiToHex(value['DOSAGEFORMNAME']), 64)
            const dosage = [
                Math.ceil(value['ACTIVE_NUMERATOR_STRENGTH']),
                web3.utils.padRight(web3.utils.asciiToHex(value['ACTIVE_INGRED_UNIT']), 64)
            ]
            const start = moment()
            const end = start.clone().add(getRandomUint(1, 24), scheduleUnit[getRandomUint(0, 3)])
            const frequency = getRandomUint(0, 3)
            const interval = frequency === 0 ? getRandomUint(1, 2) : 0
            const dow = frequency === 1 ? i % 3 === 0 ? ['MON', 'WED', 'FRI'] : ['TUE', 'THU', 'SAT'] : []
            const tod = frequency !== 2 ?
                [parseInt(`${getRandomUint(0, 12)}${getRandomUint(0, 60)}`)] : []
            try {
                // const res = await application.prescribe(
                //   patient,
                //   medicine,
                //   form,
                //   dosage,
                //   [
                //     new Date(start.format("yyyy-MM-DD")).getTime(),
                //     new Date(end.format("yyyy-MM-DD")).getTime(),
                //     frequency,
                //     interval,
                //     dow.map(value => web3.utils.padRight(web3.utils.asciiToHex(value), 64)),
                //     tod
                //   ],
                //   { from: doctor }
                // )
                await Promise.all([
                    transactions.push(application.prescribe(
                        patient,
                        medicine,
                        form,
                        dosage,
                        [
                            new Date(start.format("yyyy-MM-DD")).getTime(),
                            new Date(end.format("yyyy-MM-DD")).getTime(),
                            frequency,
                            interval,
                            dow.map(value => web3.utils.padRight(web3.utils.asciiToHex(value), 64)),
                            tod
                        ],
                        { from: doctor }
                    ).catch((err) => {
                        // console.log({ err });
                    })),
                    timeout(0.0064 * Math.pow(i - 500, 2)
                    )
                ])
            } catch (error) {
                // console.log(`medicine ${totalCount}: ${doctor} doesn't have access to ${patient}`);
                // console.log({ patient, doctor });
                console.log(error);
            }

            patientCounter = (patientCounter + 1) % 3
            doctorCounter = (doctorCounter + 1) % 2
            bar1.increment()
        }


        // const trxResults = (await Promise.all(transactions)).filter(value => value !== undefined)
        bar1.stop()
        const bar2 = multiBar.create(transactions.length, 0)

        for (const trx of transactions) {
            bar2.increment()
            try {
                const result = await trx
                if (result) {
                    // console.log({ trx });
                    trxReceipt.push(await getTransaction('prescribe', result.tx))
                }
                // await timeout(1000)
            } catch (error) {
                console.log(error);
            }
        }


        exportTransaction(trxReceipt, 'prescribingStressTest')
        console.log({ transactions: trxReceipt.length });
        bar2.stop()

        // done()
        return assert.isTrue(true)
    })
});
