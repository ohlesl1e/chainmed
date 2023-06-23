import { connection, closeConnection } from '$lib/server/db'
import { networkProviders } from '$lib/provider'
import { SiweMessage } from 'siwe'
import Treatment from '$lib/contracts/Treatment.json'
import { ethers } from 'ethers'

export const POST = async ({ request }) => {
    const { message, signature, treatments } = await request.json()
    const siweMessage = new SiweMessage(message)
    let db = await connection()
    let success = []
    let failed = []
    console.log({ message, signature, treatments });
    try {
        await siweMessage.validate(signature)
        for (const element of treatments) {
            const treatment = new ethers.Contract(element, Treatment.abi, networkProviders[0].getSigner())
            try {
                let res = await treatment.hasRole('0x72606200fac42b7dc86b75901d61ecfab2a4a1a6eded478b97a428094891abed', siweMessage.address)
                //validate patient
                if (res) {
                    //add the log to db
                    let [result, error] = await db.execute(`INSERT INTO log (patient_address, treatment_address) VALUES(?, ?)`, [siweMessage.address, element])
                    if (error) {
                        failed.push(element)
                    } else {
                        console.log(result);
                        success.push(element)
                    }
                } else {
                    //add address to failed
                    failed.push(element)
                }
            } catch (error) {
                console.log(error);
                failed.push(element)
            }
        }
        // treatments.forEach(async element => {
        //     //grab the contract
        //     const treatment = new ethers.Contract(element, Treatment.abi, networkProviders[0].getSigner())
        //     try {
        //         let res = await treatment.getPatient()
        //         //validate patient
        //         if (res === siweMessage.address) {
        //             //add the log to db
        //             let [result, error] = await db.execute(`INSERT INTO log (patient_address, treatment_address) VALUES(?, ?)`, [siweMessage.address, element])
        //             if (error) {
        //                 failed.push(element)
        //             } else {
        //                 console.log(result);
        //                 success.push(element)
        //             }
        //         } else {
        //             //add address to failed
        //             failed.push(element)
        //         }
        //     } catch (error) {
        //         console.log(error);
        //         failed.push(element)
        //     }
        // });
        //return success and failed
        closeConnection()
        return new Response(JSON.stringify({ success, failed }))
    } catch (error) {
        console.log(error);
        closeConnection()
        return new Response(JSON.stringify('Reporting failed, failed to validate signature'), { status: 500 })
    }
}