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
        specUrl="open-api.yml"
        options={{
          nativeScrollbars: true,
          theme: {
            colors: { primary: { main: '#388e3c' } },
            logo: { gutter: '15%' },
          },
        }}
      />
    </>
  );
}

export default App;
