import { connection, closeConnection } from '$lib/server/db'
import { networkProviders } from '$lib/provider'
import { SiweMessage } from 'siwe'
import { JWT_SECRET } from '$env/static/private'
import Treatment from '$lib/contracts/Treatment.json'
import { ethers } from 'ethers'
import jwt from 'jsonwebtoken'

export const POST = async ({ request }) => {
    // const { message, signature, treatments } = await request.json()
    // console.log(request.headers);
    const { treatments, wallet } = await request.json()
    const token = request.headers.get('token')
    console.log({ treatments, token });
    // const siweMessage = new SiweMessage(message)
    let db = await connection()
    let success = []
    let failed = []
    // console.log({ message, signature, treatments });
    try {
        const session = jwt.verify(token, JWT_SECRET)
        const timestamp = Date.now()
        // console.log({ session, timestamp });
        // await siweMessage.validate(signature)
        if (session && session.exp > Math.floor(timestamp / 1000)) {
            for (const element of treatments) {
                const treatment = new ethers.Contract(element, Treatment.abi, networkProviders[0].getSigner())
                try {
                    let res = await treatment.hasRole('0x72606200fac42b7dc86b75901d61ecfab2a4a1a6eded478b97a428094891abed', wallet)
                    //validate patient
                    if (res) {
                        //add the log to db
                        let [result, error] = await db.execute(`INSERT INTO log (patient_address, treatment_address) VALUES(?, ?)`, [wallet, element])
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
            closeConnection()
            return new Response(JSON.stringify({ success, failed }))
        } else {
            return new Response(JSON.stringify("Invalid token"), { status: 401 })
        }
    } catch (error) {
        console.log(error);
        closeConnection()
        return new Response(JSON.stringify('Reporting failed, failed to validate token'), { status: 401 })
    }
}