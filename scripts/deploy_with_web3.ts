// This script can be used to deploy the "Market" contract using Web3 library.
// Please make sure to compile "./contracts/Market.sol" file before running this script.
// And use Right click -> "Run" from context menu of the file to run the script. Shortcut: Ctrl+Shift+S

import { deploy } from './web3-lib'

(async () => {
    try {
        const result = await deploy('Market', [])
        console.log(`address: ${result.address}`)
    } catch (e) {
        console.log(e.message)
    }
})()