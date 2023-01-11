import React, { useState } from 'react';
import Web3 from 'web3';

function ConnectButton() {
  const [isConnected, setIsConnected] = useState(false);

  async function connect() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      try {
        // Request account access if needed
        await window.ethereum.enable();
        // Acccounts now exposed
        setIsConnected(true);
      } catch (error) {
        console.error(error);
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
      setIsConnected(true);
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
  }

  return (
    <button onClick={connect} className="connect-button">
      {isConnected ? 'Connected' : 'Connect'}
    </button>
  );
}

export default ConnectButton;
