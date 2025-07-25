import '../css/app.css';
import { createApp } from 'vue';
import 'lux-design-system/dist/style.css';
import lux from 'lux-design-system';
const app = createApp({});
app.use(lux);
app.mount('#lux');

/* eslint-disable no-console */
/* eslint-disable no-undef */
/* eslint-disable func-names */
window.log_plausible_cas_user_login = function () {
  console.log('log_plausible_cas_user_login event logged');
  plausible('Log in to CAS');
};

window.log_plausible_contact_us = function () {
  console.log('log_plausible_contact_us event logged');
  plausible('Contact Us');
};

window.log_plausible_faq = function (section) {
  console.log(`log_plausible_faq event: ${section} logged`);
  plausible('FAQ', { props: { section } });
};

window.log_plausible_connect_orcid = function () {
  console.log('log_plausible_connect_orcid event logged');
  plausible('Connect ORCID');
};
/* eslint-enable no-console */
/* eslint-enable no-undef */
/* eslint-enable func-names */
