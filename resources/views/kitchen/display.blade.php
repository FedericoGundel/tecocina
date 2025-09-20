<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Pantalla de Cocina - TecoCina</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }

        .kitchen-header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }

        .kitchen-header h1 {
            font-size: 3rem;
            font-weight: bold;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
            margin-bottom: 10px;
        }

        .kitchen-header .time {
            font-size: 1.5rem;
            opacity: 0.9;
        }

        .order-section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .section-title {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 20px;
            text-align: center;
            padding: 10px;
            border-radius: 10px;
        }

        .confirmed-title {
            background: linear-gradient(135deg, #ffc107, #ff8c00);
            color: white;
        }

        .preparing-title {
            background: linear-gradient(135deg, #17a2b8, #007bff);
            color: white;
        }

        .order-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            border-left: 5px solid #ffc107;
            transition: transform 0.2s;
        }

        .order-card.preparing {
            border-left-color: #17a2b8;
        }

        .order-card:hover {
            transform: translateY(-2px);
        }

        .order-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 15px;
        }

        .order-number {
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
        }

        .order-time {
            font-size: 1.2rem;
            color: #666;
            background: #f8f9fa;
            padding: 5px 10px;
            border-radius: 20px;
        }

        .customer-info {
            color: #666;
            margin-bottom: 15px;
        }

        .order-items {
            margin-bottom: 15px;
        }

        .order-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }

        .order-item:last-child {
            border-bottom: none;
        }

        .item-name {
            font-weight: bold;
            color: #333;
        }

        .item-details {
            font-size: 0.9rem;
            color: #666;
            margin-top: 2px;
        }

        .item-quantity {
            background: #007bff;
            color: white;
            padding: 4px 8px;
            border-radius: 15px;
            font-weight: bold;
        }

        .order-notes {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 5px;
            padding: 10px;
            margin-top: 10px;
        }

        .no-orders {
            text-align: center;
            color: #666;
            font-size: 1.2rem;
            padding: 40px;
        }

        .no-orders i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .status-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: bold;
        }

        .status-confirmed {
            background: #ffc107;
            color: #000;
        }

        .status-preparing {
            background: #17a2b8;
            color: white;
        }
    </style>
</head>

<body>
    <div class="kitchen-header">
        <h1><i class="fas fa-fire me-3"></i>COCINA TECOCOCINA</h1>
        <div class="time" id="current-time"></div>
    </div>

    <div class="container-fluid">
        <div class="row">
            <!-- Confirmed Orders -->
            <div class="col-md-6">
                <div class="order-section">
                    <div class="section-title confirmed-title">
                        <i class="fas fa-clock me-2"></i>PEDIDOS CONFIRMADOS
                    </div>
                    <div id="confirmed-orders">
                        <div class="no-orders">
                            <i class="fas fa-check-circle"></i>
                            <p>No hay pedidos confirmados</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Preparing Orders -->
            <div class="col-md-6">
                <div class="order-section">
                    <div class="section-title preparing-title">
                        <i class="fas fa-fire me-2"></i>EN PREPARACIÓN
                    </div>
                    <div id="preparing-orders">
                        <div class="no-orders">
                            <i class="fas fa-fire"></i>
                            <p>No hay pedidos en preparación</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Update time every second
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('es-ES', {
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
            document.getElementById('current-time').textContent = timeString;
        }

        updateTime();
        setInterval(updateTime, 1000);

        // Load orders
        function loadOrders() {
            fetch('/kitchen/display/orders')
                .then(response => response.json())
                .then(data => {
                    updateOrdersSection('confirmed-orders', data.confirmed || []);
                    updateOrdersSection('preparing-orders', data.preparing || []);
                })
                .catch(error => {
                    console.error('Error loading orders:', error);
                });
        }

        function updateOrdersSection(containerId, orders) {
            const container = document.getElementById(containerId);

            if (orders.length === 0) {
                container.innerHTML = `
                    <div class="no-orders">
                        <i class="fas fa-${containerId === 'confirmed-orders' ? 'check-circle' : 'fire'}"></i>
                        <p>No hay pedidos ${containerId === 'confirmed-orders' ? 'confirmados' : 'en preparación'}</p>
                    </div>
                `;
                return;
            }

            container.innerHTML = orders.map(order => `
                <div class="order-card ${order.status}">
                    <div class="order-header">
                        <div class="order-number">#${order.order_number}</div>
                        <div class="order-time">${formatTime(order.created_at)}</div>
                    </div>
                    
                    <div class="customer-info">
                        <strong>${order.user.name}</strong> - ${order.user.phone}
                    </div>
                    
                    <div class="order-items">
                        ${order.items.map(item => `
                                        <div class="order-item">
                                            <div>
                                                <div class="item-name">${item.quantity}x ${item.product.name}</div>
                                                ${item.selected_variants ? `<div class="item-details">${item.selected_variants.map(v => v.value).join(', ')}</div>` : ''}
                                                ${item.selected_options ? `<div class="item-details text-info">${item.selected_options.map(o => o.value).join(', ')}</div>` : ''}
                                                ${item.special_instructions ? `<div class="item-details text-warning"><i class="fas fa-exclamation-triangle"></i> ${item.special_instructions}</div>` : ''}
                                            </div>
                                            <div class="item-quantity">${item.quantity}</div>
                                        </div>
                                    `).join('')}
                    </div>
                    
                    ${order.notes ? `
                                    <div class="order-notes">
                                        <strong>Notas:</strong> ${order.notes}
                                    </div>
                                ` : ''}

                    <div class="mt-3">
                        ${order.status === 'confirmed' ? `
                                    <button class="btn btn-success w-100" onclick="startPreparation(${order.id})">
                                        <i class="fas fa-play me-1"></i> Iniciar preparación
                                    </button>
                                ` : ''}
                        ${order.status === 'preparing' ? `
                                    <button class="btn btn-primary w-100" onclick="markReady(${order.id})">
                                        <i class="fas fa-check me-1"></i> Marcar listo
                                    </button>
                                ` : ''}
                    </div>
                </div>
            `).join('');
        }

        function formatTime(dateString) {
            const date = new Date(dateString);
            return date.toLocaleTimeString('es-ES', {
                hour: '2-digit',
                minute: '2-digit'
            });
        }

        // Load orders initially and then every 10 seconds
        loadOrders();
        setInterval(loadOrders, 10000);

        // Actions
        function startPreparation(orderId) {
            const tokenMeta = document.querySelector('meta[name="csrf-token"]');
            const csrfToken = tokenMeta ? tokenMeta.getAttribute('content') : '';
            fetch(`/kitchen/orders/${orderId}/start`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest',
                        'X-CSRF-TOKEN': csrfToken
                    },
                    credentials: 'same-origin'
                }).then(res => res.ok ? res.json() : Promise.reject(res))
                .then(() => loadOrders())
                .catch(() => alert('No se pudo iniciar preparación (CSRF o permisos).'));
        }

        function markReady(orderId) {
            const tokenMeta = document.querySelector('meta[name="csrf-token"]');
            const csrfToken = tokenMeta ? tokenMeta.getAttribute('content') : '';
            fetch(`/kitchen/orders/${orderId}/ready`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest',
                        'X-CSRF-TOKEN': csrfToken
                    },
                    credentials: 'same-origin'
                }).then(res => res.ok ? res.json() : Promise.reject(res))
                .then(() => loadOrders())
                .catch(() => alert('No se pudo marcar como listo (CSRF o permisos).'));
        }

        // Fullscreen functionality
        document.addEventListener('keydown', function(e) {
            if (e.key === 'F11') {
                e.preventDefault();
                if (!document.fullscreenElement) {
                    document.documentElement.requestFullscreen();
                } else {
                    document.exitFullscreen();
                }
            }
        });
    </script>
</body>

</html>
