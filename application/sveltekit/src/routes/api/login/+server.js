import { networkProviders } from '$lib/provider'
import { SiweMessage } from 'siwe'
import Application from '$lib/contracts/Application.json'
import { ethers } from 'ethers'
import { JWT_SECRET } from '$env/static/private'
import { PUBLIC_APP_CONTRACT_ADDRESS } from '$env/static/public'
import jwt from "jsonwebtoken";

const applicationContract = new ethers.Contract(PUBLIC_APP_CONTRACT_ADDRESS, Application.abi, networkProviders[0])

export const POST = async ({ request }) => {
    const { message, signature, type } = await request.json()
    const siweMessage = new SiweMessage(message)
    try {
        await siweMessage.validate(signature)
        // console.log({ type, siweMessage, signature });

        switch (type) {
            case 'doctor': {
                let result = await applicationContract.getDoctor(siweMessage.address)
                if (result !== ethers.constants.AddressZero) {
                    return new Response(JSON.stringify({
                        message: "Login success",
                        token: jwt.sign(
                            { type, address: result },
                            JWT_SECRET
                        )
                    }))
                }
                return new Response(JSON.stringify("Profile not found"), { status: 404 })
            }
            case 'patient': {
                let result = await applicationContract.getPatient(siweMessage.address)
                if (result !== ethers.constants.AddressZero) {
                    return new Response(JSON.stringify({
                        message: "Login success",
                        token: jwt.sign(
                            { type, address: result },
                            JWT_SECRET
                        )
                    }))
                }
                return new Response(JSON.stringify({ message: "Profile not found" }), { status: 404, headers: { location: '/new-user/patient' } })
            }
            default:
                return new Response(JSON.stringify({ message: "Profile not found" }), { status: 403 })
        }
    } catch (error) {
        console.log(error);
        return new Response({ message: "Profile not found" }, { status: 403 })
    }
}