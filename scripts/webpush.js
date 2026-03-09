// send-push.js
import webpush from 'web-push';

// Replace with your VAPID keys
const VAPID_PUBLIC_KEY = 'BCoiBTMpspyt6CyJwixHvr6-urI5HRREh9x7NW_EpiRC-A17HVI6jbhD1P2fQpYU-RzUHi8t1SgAXvQlWCbr3ps';
const VAPID_PRIVATE_KEY = 'KQx9LIsXuAQO0UZB3l0aejMu6Z91Fzkiq87R-FM16TI';

// Example subscription (obtained from the browser)
const subscription = {
  endpoint: 'https://fcm.googleapis.com/fcm/send/cjSQf-z0Po0:APA91bEMWdajgGADgu_rJlTWIgipsmaNOf-GQsK8wt_UY4mMuTRcKYnw66noOh8R5ADiqMlHymDf_t-0Zsfma-bkYx9wVQ0ddzHEV5UZFWh2SdAGQS6O_iy83w52hU5iXk2u2FQa9JX-',
  keys: {
    p256dh: 'BF50zmtOCKyIpbIn-44WoIZNsyk1db9qyDTyb4gDNBlcWIisaTZ6DFM3QiakETWRtvrt8yW2dAo4asMabEuA1Rw',
    auth: 'AKTykzg_tzbWvilehjbSOg'
  }
};

// Set VAPID details
webpush.setVapidDetails(
  'mailto:theneedfuldo@gmail.com',
  VAPID_PUBLIC_KEY,
  VAPID_PRIVATE_KEY
);

// Send notification
const result = await webpush.sendNotification(
  subscription,
  JSON.stringify({
    title: 'Hello from PawnDAO!',
    body: 'Subscribed to notifications',
    url: '/loans'
  })
);

console.log(result);
console.log('Push sent!');
