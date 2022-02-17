import { RedocStandalone } from 'redoc';
import { createGlobalStyle } from 'styled-components';

const GlobalStyle = createGlobalStyle`
  body {
    margin: 0;
  }
`;

function App() {
  return (
    <>
      <GlobalStyle />
      <RedocStandalone specUrl="open-api.yml"/>
    </>
  );
}

export default App;
