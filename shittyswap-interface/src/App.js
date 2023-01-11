import './App.css';
import Connect from './Connect';
import SwapAssets from './SwapAssets';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <Connect /><h1>ShittySwap Exchange</h1>
      </header>

      <body className="App-body">
        <div className="swap-assets">
        <SwapAssets />
        </div>
      </body>
    </div>
  );
}

export default App;
