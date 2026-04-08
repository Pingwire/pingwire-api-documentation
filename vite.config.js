import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

function fullReloadOnPublicYamlChange() {
  return {
    name: 'full-reload-on-public-yaml-change',
    handleHotUpdate({ file, server }) {
      const isPublicFile = file.includes('/public/');
      const isYaml = file.endsWith('.yml') || file.endsWith('.yaml');

      if (isPublicFile && isYaml) {
        server.ws.send({ type: 'full-reload', path: '*' });
      }
    },
  };
}

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), fullReloadOnPublicYamlChange()],
  server: {
    port: 3000,
    open: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
  },
  publicDir: 'public',
  define: {
    global: 'globalThis',
  },
});
