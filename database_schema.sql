-- =====================================================
-- BURGER HOUSE - ESQUEMA DE BASE DE DATOS
-- Sistema completo de gestión de restaurante
-- =====================================================

-- Tabla de usuarios (clientes y administradores)
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    role ENUM('customer', 'admin', 'kitchen', 'delivery') DEFAULT 'customer',
    is_active BOOLEAN DEFAULT TRUE,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_active (is_active)
);

-- Tabla de direcciones de clientes
CREATE TABLE addresses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('home', 'work', 'other') DEFAULT 'home',
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    floor VARCHAR(50) NULL,
    apartment VARCHAR(50) NULL,
    notes TEXT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_default (is_default)
);

-- Tabla de categorías de productos
CREATE TABLE categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NULL,
    image VARCHAR(255) NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    INDEX idx_slug (slug),
    INDEX idx_active (is_active),
    INDEX idx_sort (sort_order)
);

-- Tabla de productos
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT NULL,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2) NULL,
    sku VARCHAR(100) UNIQUE NULL,
    image VARCHAR(255) NULL,
    stock INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    preparation_time INT DEFAULT 15, -- minutos
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_category_id (category_id),
    INDEX idx_slug (slug),
    INDEX idx_sku (sku),
    INDEX idx_available (is_available),
    INDEX idx_featured (is_featured),
    INDEX idx_price (price)
);

-- Tabla de variantes/opciones de productos
CREATE TABLE product_variants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL, -- ej: "Tamaño", "Extras"
    type ENUM('select', 'checkbox', 'radio') DEFAULT 'select',
    is_required BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_sort (sort_order)
);

-- Tabla de opciones de variantes
CREATE TABLE variant_options (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    variant_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL, -- ej: "Simple", "Doble", "Extra queso"
    price_modifier DECIMAL(10,2) DEFAULT 0.00,
    is_available BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE,
    INDEX idx_variant_id (variant_id),
    INDEX idx_available (is_available),
    INDEX idx_sort (sort_order)
);

-- Tabla de cupones de descuento
CREATE TABLE coupons (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    type ENUM('percentage', 'fixed') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    minimum_amount DECIMAL(10,2) DEFAULT 0.00,
    maximum_discount DECIMAL(10,2) NULL,
    usage_limit INT NULL,
    used_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    INDEX idx_code (code),
    INDEX idx_active (is_active),
    INDEX idx_dates (starts_at, expires_at)
);

-- Tabla de pedidos
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT UNSIGNED NULL, -- NULL para pedidos de invitados
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    
    -- Información de entrega
    delivery_type ENUM('delivery', 'pickup') NOT NULL,
    delivery_address_id BIGINT UNSIGNED NULL,
    delivery_street VARCHAR(255) NULL,
    delivery_city VARCHAR(100) NULL,
    delivery_postal_code VARCHAR(20) NULL,
    delivery_floor VARCHAR(50) NULL,
    delivery_notes TEXT NULL,
    
    -- Información de pago
    payment_method ENUM('cash', 'card', 'transfer') NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_reference VARCHAR(255) NULL,
    
    -- Totales
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) DEFAULT 0.00,
    service_fee DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Cupón aplicado
    coupon_id BIGINT UNSIGNED NULL,
    
    -- Estado del pedido
    status ENUM('pending', 'preparation', 'ready', 'route', 'delivered', 'cancelled') DEFAULT 'pending',
    
    -- Tiempos
    scheduled_at TIMESTAMP NULL,
    preparation_started_at TIMESTAMP NULL,
    ready_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    
    -- Notas adicionales
    notes TEXT NULL,
    
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (delivery_address_id) REFERENCES addresses(id) ON DELETE SET NULL,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE SET NULL,
    
    INDEX idx_order_number (order_number),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_delivery_type (delivery_type),
    INDEX idx_created_at (created_at),
    INDEX idx_scheduled_at (scheduled_at)
);

-- Tabla de items del pedido
CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL, -- Snapshot del nombre
    product_price DECIMAL(10,2) NOT NULL, -- Snapshot del precio
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- Tabla de opciones seleccionadas en items del pedido
CREATE TABLE order_item_options (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_item_id BIGINT UNSIGNED NOT NULL,
    variant_name VARCHAR(100) NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    price_modifier DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE,
    INDEX idx_order_item_id (order_item_id)
);

-- Tabla de historial de estados del pedido
CREATE TABLE order_status_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    status ENUM('pending', 'preparation', 'ready', 'route', 'delivered', 'cancelled') NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- Tabla de configuración del negocio
CREATE TABLE business_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NULL,
    type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    INDEX idx_key (key)
);

-- Tabla de notificaciones
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    notifiable_type VARCHAR(255) NOT NULL,
    notifiable_id BIGINT UNSIGNED NOT NULL,
    data JSON NOT NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    INDEX idx_notifiable (notifiable_type, notifiable_id),
    INDEX idx_type (type),
    INDEX idx_read_at (read_at)
);

-- Tabla de sesiones (para Laravel)
CREATE TABLE sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
);

-- Tabla de cache (para Laravel)
CREATE TABLE cache (
    key VARCHAR(255) PRIMARY KEY,
    value MEDIUMTEXT NOT NULL,
    expiration INT NOT NULL,
    
    INDEX idx_expiration (expiration)
);

-- Tabla de cache de locks (para Laravel)
CREATE TABLE cache_locks (
    key VARCHAR(255) PRIMARY KEY,
    owner VARCHAR(255) NOT NULL,
    expiration INT NOT NULL,
    
    INDEX idx_expiration (expiration)
);

-- Tabla de jobs en cola (para Laravel)
CREATE TABLE jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    queue VARCHAR(255) NOT NULL,
    payload LONGTEXT NOT NULL,
    attempts TINYINT UNSIGNED NOT NULL,
    reserved_at INT UNSIGNED NULL,
    available_at INT UNSIGNED NOT NULL,
    created_at INT UNSIGNED NOT NULL,
    
    INDEX idx_queue (queue),
    INDEX idx_reserved_at (reserved_at),
    INDEX idx_available_at (available_at)
);

-- Tabla de jobs fallidos (para Laravel)
CREATE TABLE failed_jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(255) UNIQUE NOT NULL,
    connection TEXT NOT NULL,
    queue TEXT NOT NULL,
    payload LONGTEXT NOT NULL,
    exception LONGTEXT NOT NULL,
    failed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_uuid (uuid),
    INDEX idx_failed_at (failed_at)
);

-- =====================================================
-- DATOS INICIALES
-- =====================================================

-- Insertar categorías por defecto
INSERT INTO categories (name, slug, description, sort_order) VALUES
('Hamburguesas', 'hamburguesas', 'Deliciosas hamburguesas artesanales', 1),
('Acompañamientos', 'acompañamientos', 'Papas, ensaladas y más', 2),
('Bebidas', 'bebidas', 'Bebidas frías y calientes', 3),
('Postres', 'postres', 'Dulces para terminar tu comida', 4);

-- Insertar usuario administrador por defecto
INSERT INTO users (name, email, password, role) VALUES
('Administrador', 'admin@burgerhouse.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Insertar configuración del negocio
INSERT INTO business_settings (key, value, type, description) VALUES
('business_name', 'Burger House', 'string', 'Nombre del negocio'),
('business_phone', '+54 11 1234-5678', 'string', 'Teléfono de contacto'),
('business_email', 'pedidos@burgerhouse.com.ar', 'string', 'Email de contacto'),
('business_address', 'Av. Corrientes 500, CABA', 'string', 'Dirección del local'),
('delivery_fee', '1500', 'number', 'Costo de envío por defecto'),
('free_delivery_minimum', '20000', 'number', 'Monto mínimo para envío gratis'),
('service_fee_percentage', '3', 'number', 'Porcentaje de cargo por servicio'),
('preparation_time_default', '15', 'number', 'Tiempo de preparación por defecto (minutos)'),
('is_delivery_available', 'true', 'boolean', 'Si el delivery está disponible'),
('is_pickup_available', 'true', 'boolean', 'Si el retiro en local está disponible'),
('business_hours', '{"monday": {"open": "11:00", "close": "23:00"}, "tuesday": {"open": "11:00", "close": "23:00"}, "wednesday": {"open": "11:00", "close": "23:00"}, "thursday": {"open": "11:00", "close": "23:00"}, "friday": {"open": "11:00", "close": "00:00"}, "saturday": {"open": "11:00", "close": "00:00"}, "sunday": {"open": "12:00", "close": "22:00"}}', 'json', 'Horarios de atención');
