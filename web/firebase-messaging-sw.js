// Import Firebase scripts for service worker
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Your actual Firebase config from firebase_options.dart
const firebaseConfig = {
  apiKey: 'AIzaSyB7SeVXbeK7eSIlW519xWBQKus7vqwKiyQ',
  appId: '1:42201685589:web:0f3f91ef23bb7d96b77edc',
  messagingSenderId: '42201685589',
  projectId: 'get-inq-3544b',
  authDomain: 'get-inq-3544b.firebaseapp.com',
  storageBucket: 'get-inq-3544b.firebasestorage.app',
  measurementId: 'G-ZVTVDDLZ49'
};

console.log('🔥 Service Worker loaded with Firebase config');

// Initialize Firebase in service worker
firebase.initializeApp(firebaseConfig);
console.log('🔥 Firebase initialized in Service Worker');

// Initialize Firebase Messaging
const messaging = firebase.messaging();
console.log('🔥 Firebase Messaging initialized in Service Worker');

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('🔥 [SW] Background message received:', payload);
  
  const notificationTitle = payload.notification?.title || 'Queue Update';
  const notificationOptions = {
    body: payload.notification?.body || 'Your queue status has changed',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'queue-notification',
    requireInteraction: true,
    data: payload.data || {}
  };

  console.log('🔥 [SW] Showing notification:', notificationTitle, notificationOptions);
  
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Test if messaging is working
console.log('🔥 Service Worker messaging setup complete');

// Handle notification click
self.addEventListener('notificationclick', function(event) {
  console.log('🔥 [SW] Notification click received.');

  event.notification.close();

  // Open or focus the app
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      for (var i = 0; i < clientList.length; i++) {
        var client = clientList[i];
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});

// Add push event listener as backup
self.addEventListener('push', function(event) {
  console.log('🔥 [SW] Push event received:', event);
  
  let title = 'Queue Update';
  let body = 'Your queue status has changed';
  
  if (event.data) {
    try {
      // Try to parse as JSON first
      const data = event.data.json();
      console.log('🔥 [SW] Push data (JSON):', data);
      title = data.notification?.title || title;
      body = data.notification?.body || body;
    } catch (e) {
      // If not JSON, try as text
      try {
        const textData = event.data.text();
        console.log('🔥 [SW] Push data (text):', textData);
        body = textData || body;
      } catch (e2) {
        console.log('🔥 [SW] Could not parse push data:', e2);
      }
    }
  }
  
  const options = {
    body: body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'queue-notification',
    requireInteraction: true
  };
  
  console.log('🔥 [SW] Showing notification via push:', title, options);
  
  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});