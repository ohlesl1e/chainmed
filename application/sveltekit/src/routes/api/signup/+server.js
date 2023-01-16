import { networkProviders } from '$lib/provider'
import { SiweMessage } from 'siwe'
import Application from '$lib/contracts/Application.json'
import { ethers } from 'ethers'
import { JWT_SECRET } from '$env/static/private'
import { PUBLIC_APP_CONTRACT_ADDRESS } from '$env/static/public'
import jwt from "jsonwebtoken";

const applicationContract = new ethers.Contract(PUBLIC_APP_CONTRACT_ADDRESS, Application.abi, networkProviders[0])

export const POST = async ({ request }) => {
    const { address } = await request.json()
    console.log(address);
    let result = await applicationContract.getPatient(address)
    if (result !== ethers.constants.AddressZero) {
        return new Response(JSON.stringify({
            message: "Registration success",
            token: jwt.sign(
                { type: 'patient', address: result },
                JWT_SECRET
            )
        }))
    }
    return new Response(JSON.stringify({ message: "Profile not found" }), { status: 404, headers: { location: '/new-user/patient' } })
}