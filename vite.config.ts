import { defineConfig } from "vite"
import RubyPlugin from "vite-plugin-ruby"

export default defineConfig({
  plugins: [
    RubyPlugin()
  ],
  esbuild: {
    jsx: 'automatic'
  },
  define: {
    'import.meta.env.REACT_REFRESH': 'false'
  },
  server: {
    port: 5173,
    strictPort: true
  }
})
