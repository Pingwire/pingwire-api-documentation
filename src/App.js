import { RedocStandalone } from 'redoc';

function App() {
  return (
    <RedocStandalone specUrl="https://docs.moank.se/brokers.yml"/>
  );
}

export default App;
