import '../css/app.css';
import { createApp } from 'vue';
import 'lux-design-system/dist/style.css';
import { LuxLibraryFooter, LuxLibraryHeader, LuxMenuBar } from 'lux-design-system';
const app = createApp({});
app
  .component('lux-library-footer', LuxLibraryFooter)
  .component('lux-library-header', LuxLibraryHeader)
  .component('lux-menu-bar', LuxMenuBar);
app.mount('#lux');
