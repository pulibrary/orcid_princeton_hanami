import '../css/app.css';
import { createApp } from 'vue';
import 'lux-design-system/dist/style.css';
import lux from 'lux-design-system';
const app = createApp({});
app.use(lux);
app.mount('#lux');
