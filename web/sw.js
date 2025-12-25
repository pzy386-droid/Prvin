// Prvin AI日历 Service Worker
// 提供离线缓存和PWA功能

const CACHE_NAME = 'prvin-calendar-v1.0.0';
const OFFLINE_URL = '/offline.html';

// 需要缓存的核心资源
const CORE_CACHE_RESOURCES = [
  '/',
  '/main.dart.js',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  OFFLINE_URL
];

// 需要缓存的字体和样式资源
const FONT_CACHE_RESOURCES = [
  'https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap',
  'https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxK.woff2',
  'https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fBBc4.woff2'
];

// 安装事件 - 缓存核心资源
self.addEventListener('install', event => {
  console.log('Service Worker installing...');
  
  event.waitUntil(
    (async () => {
      try {
        const cache = await caches.open(CACHE_NAME);
        
        // 缓存核心资源
        await cache.addAll(CORE_CACHE_RESOURCES);
        console.log('Core resources cached successfully');
        
        // 尝试缓存字体资源（不阻塞安装）
        try {
          await cache.addAll(FONT_CACHE_RESOURCES);
          console.log('Font resources cached successfully');
        } catch (fontError) {
          console.warn('Failed to cache font resources:', fontError);
        }
        
        // 强制激活新的Service Worker
        self.skipWaiting();
      } catch (error) {
        console.error('Failed to cache resources during install:', error);
      }
    })()
  );
});

// 激活事件 - 清理旧缓存
self.addEventListener('activate', event => {
  console.log('Service Worker activating...');
  
  event.waitUntil(
    (async () => {
      try {
        // 获取所有缓存名称
        const cacheNames = await caches.keys();
        
        // 删除旧版本的缓存
        await Promise.all(
          cacheNames
            .filter(cacheName => cacheName !== CACHE_NAME)
            .map(cacheName => {
              console.log('Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            })
        );
        
        // 立即控制所有客户端
        await self.clients.claim();
        console.log('Service Worker activated successfully');
      } catch (error) {
        console.error('Failed to activate Service Worker:', error);
      }
    })()
  );
});

// 获取事件 - 处理网络请求
self.addEventListener('fetch', event => {
  // 只处理GET请求
  if (event.request.method !== 'GET') {
    return;
  }

  // 跳过chrome-extension和其他非http(s)请求
  if (!event.request.url.startsWith('http')) {
    return;
  }

  event.respondWith(
    (async () => {
      try {
        // 尝试从网络获取资源
        const networkResponse = await fetch(event.request);
        
        // 如果网络请求成功，缓存响应（仅对特定资源）
        if (networkResponse.ok && shouldCache(event.request.url)) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(event.request, networkResponse.clone());
        }
        
        return networkResponse;
      } catch (error) {
        console.log('Network request failed, trying cache:', event.request.url);
        
        // 网络请求失败，尝试从缓存获取
        const cachedResponse = await caches.match(event.request);
        
        if (cachedResponse) {
          return cachedResponse;
        }
        
        // 如果是导航请求且缓存中没有，返回离线页面
        if (event.request.mode === 'navigate') {
          const offlineResponse = await caches.match(OFFLINE_URL);
          if (offlineResponse) {
            return offlineResponse;
          }
        }
        
        // 返回基本的离线响应
        return new Response(
          JSON.stringify({
            error: 'Offline',
            message: '当前处于离线状态，请检查网络连接'
          }),
          {
            status: 503,
            statusText: 'Service Unavailable',
            headers: {
              'Content-Type': 'application/json'
            }
          }
        );
      }
    })()
  );
});

// 判断是否应该缓存该资源
function shouldCache(url) {
  // 缓存应用的静态资源
  if (url.includes('/assets/') || 
      url.includes('/icons/') || 
      url.includes('.js') || 
      url.includes('.css') || 
      url.includes('.woff') || 
      url.includes('.woff2')) {
    return true;
  }
  
  // 缓存API响应（可根据需要调整）
  if (url.includes('/api/')) {
    return true;
  }
  
  return false;
}

// 消息事件 - 处理来自主线程的消息
self.addEventListener('message', event => {
  console.log('Service Worker received message:', event.data);
  
  if (event.data && event.data.type) {
    switch (event.data.type) {
      case 'SKIP_WAITING':
        self.skipWaiting();
        break;
        
      case 'GET_VERSION':
        event.ports[0].postMessage({
          type: 'VERSION',
          version: CACHE_NAME
        });
        break;
        
      case 'CLEAR_CACHE':
        clearAllCaches().then(() => {
          event.ports[0].postMessage({
            type: 'CACHE_CLEARED',
            success: true
          });
        }).catch(error => {
          event.ports[0].postMessage({
            type: 'CACHE_CLEARED',
            success: false,
            error: error.message
          });
        });
        break;
        
      case 'CACHE_URLS':
        if (event.data.urls && Array.isArray(event.data.urls)) {
          cacheUrls(event.data.urls).then(() => {
            event.ports[0].postMessage({
              type: 'URLS_CACHED',
              success: true
            });
          }).catch(error => {
            event.ports[0].postMessage({
              type: 'URLS_CACHED',
              success: false,
              error: error.message
            });
          });
        }
        break;
    }
  }
});

// 清理所有缓存
async function clearAllCaches() {
  const cacheNames = await caches.keys();
  await Promise.all(
    cacheNames.map(cacheName => caches.delete(cacheName))
  );
  console.log('All caches cleared');
}

// 缓存指定的URLs
async function cacheUrls(urls) {
  const cache = await caches.open(CACHE_NAME);
  await cache.addAll(urls);
  console.log('URLs cached:', urls);
}

// 推送事件 - 处理推送通知
self.addEventListener('push', event => {
  console.log('Push event received:', event);
  
  let notificationData = {
    title: 'Prvin AI日历',
    body: '您有新的提醒',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'prvin-notification',
    requireInteraction: false,
    actions: [
      {
        action: 'view',
        title: '查看',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'dismiss',
        title: '忽略'
      }
    ]
  };
  
  // 如果推送包含数据，解析并使用
  if (event.data) {
    try {
      const pushData = event.data.json();
      notificationData = { ...notificationData, ...pushData };
    } catch (error) {
      console.error('Failed to parse push data:', error);
    }
  }
  
  event.waitUntil(
    self.registration.showNotification(notificationData.title, notificationData)
  );
});

// 通知点击事件
self.addEventListener('notificationclick', event => {
  console.log('Notification clicked:', event);
  
  event.notification.close();
  
  if (event.action === 'view') {
    // 打开应用
    event.waitUntil(
      clients.openWindow('/')
    );
  } else if (event.action === 'dismiss') {
    // 忽略通知，不执行任何操作
    return;
  } else {
    // 默认行为：打开应用
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// 同步事件 - 处理后台同步
self.addEventListener('sync', event => {
  console.log('Background sync event:', event.tag);
  
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

// 执行后台同步
async function doBackgroundSync() {
  try {
    console.log('Performing background sync...');
    
    // 这里可以执行数据同步逻辑
    // 例如：同步离线时创建的任务、更新日历数据等
    
    // 通知主线程同步完成
    const clients = await self.clients.matchAll();
    clients.forEach(client => {
      client.postMessage({
        type: 'BACKGROUND_SYNC_COMPLETE',
        timestamp: Date.now()
      });
    });
    
    console.log('Background sync completed');
  } catch (error) {
    console.error('Background sync failed:', error);
  }
}

console.log('Prvin Calendar Service Worker loaded successfully');