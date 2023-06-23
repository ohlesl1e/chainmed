const Application = artifacts.require("Application");
const Manager = artifacts.require("Manager");
const Patient = artifacts.require("Patient")
const axios = require('axios')
const mysql = require('mysql2')
const moment = require('moment')
const fs = require('fs');
const { Parser } = require('json2csv');
const cliProgress = require('cli-progress');
require('dotenv').config()

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: process.env.DB_PASS,
    database: 'mydb',
})

const gasPrice = 20000000000

const scheduleUnit = ['d', 'w', 'M']
const genders = ['Man', 'Woman', 'Non-binary']
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

    if (block.timestamp > previousTimestamp) previousTimestamp = block.timestamp
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

const getRandomUint = (min, max) => {
    min = Math.ceil(min)
    max = Math.floor(max)
    return Math.floor(Math.random() * (max - min) + min)
}

const timeout = ms => new Promise(resolve => setTimeout(resolve, ms))

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Application", async (accounts) => {
    console.log(accounts);

    it("should assert true", async () => {
        // const application = await Application.deployed();
        // const manager = await Manager.deployed()
        const application = await Application.at(process.env.PUBLIC_APPLICATION_ADDRESS);
        const manager = await Manager.at(process.env.PUBLIC_MANAGER_ADDRESS)
        console.log({
            application: application.address,
            manager: manager.address
        });
        return assert.isTrue(true);
    });


    it('Prescrbing stress test', async () => {
        // const application = await Application.deployed();
        const application = await Application.at(process.env.PUBLIC_APPLICATION_ADDRESS)
        const transactions = []
        const trxReceipt = []
        const load = 16
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

            patientCounter = (patientCounter + 1) % (accounts.length - 2)
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
