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
      <RedocStandalone
        specUrl={process.env.REACT_APP_SPEC_URL}
        options={{
          theme: {
            colors: { primary: { main: '#238061' } },
            sidebar: {
              backgroundColor: '#d3dcda',
            },
            logo: { gutter: '15%' },
          },
        }}
      />
    </>
  );
}

export default App;
