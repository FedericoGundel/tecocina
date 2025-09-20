# Estructura de Modelos Laravel - Burger House

## Modelos Principales

### 1. User (Usuario)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'phone', 'role', 'is_active'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    // Relaciones
    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function defaultAddress()
    {
        return $this->hasOne(Address::class)->where('is_default', true);
    }

    // Scopes
    public function scopeCustomers($query)
    {
        return $query->where('role', 'customer');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
```

### 2. Address (Dirección)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'type', 'street', 'city', 'postal_code',
        'floor', 'apartment', 'notes', 'is_default'
    ];

    protected $casts = [
        'is_default' => 'boolean',
    ];

    // Relaciones
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'delivery_address_id');
    }

    // Accessors
    public function getFullAddressAttribute()
    {
        $address = $this->street;
        if ($this->floor) {
            $address .= ', ' . $this->floor;
        }
        if ($this->apartment) {
            $address .= ', ' . $this->apartment;
        }
        $address .= ', ' . $this->city . ' - ' . $this->postal_code;
        return $address;
    }
}
```

### 3. Category (Categoría)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'slug', 'description', 'image', 'sort_order', 'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Relaciones
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function activeProducts()
    {
        return $this->hasMany(Product::class)->where('is_available', true);
    }

    // Boot method para generar slug automáticamente
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($category) {
            if (empty($category->slug)) {
                $category->slug = Str::slug($category->name);
            }
        });
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order');
    }
}
```

### 4. Product (Producto)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id', 'name', 'slug', 'description', 'price',
        'original_price', 'sku', 'image', 'stock', 'is_available',
        'is_featured', 'preparation_time', 'sort_order'
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'original_price' => 'decimal:2',
        'is_available' => 'boolean',
        'is_featured' => 'boolean',
    ];

    // Relaciones
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function variants()
    {
        return $this->hasMany(ProductVariant::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    // Accessors
    public function getHasDiscountAttribute()
    {
        return $this->original_price && $this->original_price > $this->price;
    }

    public function getDiscountPercentageAttribute()
    {
        if (!$this->has_discount) return 0;
        return round((($this->original_price - $this->price) / $this->original_price) * 100);
    }

    // Scopes
    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeByCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    // Boot method
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($product) {
            if (empty($product->slug)) {
                $product->slug = Str::slug($product->name);
            }
        });
    }
}
```

### 5. ProductVariant (Variante de Producto)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id', 'name', 'type', 'is_required', 'sort_order'
    ];

    protected $casts = [
        'is_required' => 'boolean',
    ];

    // Relaciones
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function options()
    {
        return $this->hasMany(VariantOption::class);
    }

    public function availableOptions()
    {
        return $this->hasMany(VariantOption::class)->where('is_available', true);
    }

    // Scopes
    public function scopeRequired($query)
    {
        return $query->where('is_required', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order');
    }
}
```

### 6. VariantOption (Opción de Variante)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VariantOption extends Model
{
    use HasFactory;

    protected $fillable = [
        'variant_id', 'name', 'price_modifier', 'is_available', 'sort_order'
    ];

    protected $casts = [
        'price_modifier' => 'decimal:2',
        'is_available' => 'boolean',
    ];

    // Relaciones
    public function variant()
    {
        return $this->belongsTo(ProductVariant::class);
    }

    // Scopes
    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order');
    }
}
```

### 7. Coupon (Cupón)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Coupon extends Model
{
    use HasFactory;

    protected $fillable = [
        'code', 'name', 'description', 'type', 'value',
        'minimum_amount', 'maximum_discount', 'usage_limit',
        'used_count', 'is_active', 'starts_at', 'expires_at'
    ];

    protected $casts = [
        'value' => 'decimal:2',
        'minimum_amount' => 'decimal:2',
        'maximum_discount' => 'decimal:2',
        'is_active' => 'boolean',
        'starts_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    // Relaciones
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    // Accessors
    public function getIsValidAttribute()
    {
        $now = Carbon::now();

        return $this->is_active &&
               (!$this->starts_at || $now->gte($this->starts_at)) &&
               (!$this->expires_at || $now->lte($this->expires_at)) &&
               (!$this->usage_limit || $this->used_count < $this->usage_limit);
    }

    public function getRemainingUsesAttribute()
    {
        if (!$this->usage_limit) return null;
        return max(0, $this->usage_limit - $this->used_count);
    }

    // Methods
    public function calculateDiscount($amount)
    {
        if (!$this->is_valid || $amount < $this->minimum_amount) {
            return 0;
        }

        $discount = $this->type === 'percentage'
            ? ($amount * $this->value / 100)
            : $this->value;

        if ($this->maximum_discount && $discount > $this->maximum_discount) {
            $discount = $this->maximum_discount;
        }

        return min($discount, $amount);
    }

    public function incrementUsage()
    {
        $this->increment('used_count');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeValid($query)
    {
        $now = Carbon::now();

        return $query->where('is_active', true)
                    ->where(function($q) use ($now) {
                        $q->whereNull('starts_at')->orWhere('starts_at', '<=', $now);
                    })
                    ->where(function($q) use ($now) {
                        $q->whereNull('expires_at')->orWhere('expires_at', '>=', $now);
                    });
    }
}
```

### 8. Order (Pedido)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number', 'user_id', 'customer_name', 'customer_email',
        'customer_phone', 'delivery_type', 'delivery_address_id',
        'delivery_street', 'delivery_city', 'delivery_postal_code',
        'delivery_floor', 'delivery_notes', 'payment_method',
        'payment_status', 'payment_reference', 'subtotal',
        'delivery_fee', 'service_fee', 'discount_amount',
        'total_amount', 'coupon_id', 'status', 'scheduled_at',
        'preparation_started_at', 'ready_at', 'delivered_at', 'notes'
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'delivery_fee' => 'decimal:2',
        'service_fee' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'scheduled_at' => 'datetime',
        'preparation_started_at' => 'datetime',
        'ready_at' => 'datetime',
        'delivered_at' => 'datetime',
    ];

    // Relaciones
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function deliveryAddress()
    {
        return $this->belongsTo(Address::class, 'delivery_address_id');
    }

    public function coupon()
    {
        return $this->belongsTo(Coupon::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function statusHistory()
    {
        return $this->hasMany(OrderStatusHistory::class);
    }

    // Accessors
    public function getFullDeliveryAddressAttribute()
    {
        if ($this->delivery_type === 'pickup') {
            return 'Retiro en local';
        }

        $address = $this->delivery_street;
        if ($this->delivery_floor) {
            $address .= ', ' . $this->delivery_floor;
        }
        $address .= ', ' . $this->delivery_city . ' - ' . $this->delivery_postal_code;
        return $address;
    }

    public function getEstimatedDeliveryTimeAttribute()
    {
        if ($this->status === 'delivered') {
            return null;
        }

        $baseTime = $this->preparation_started_at ?? $this->created_at;
        $estimatedMinutes = $this->items->sum(function($item) {
            return $item->product->preparation_time * $item->quantity;
        });

        return $baseTime->addMinutes($estimatedMinutes);
    }

    // Methods
    public function updateStatus($status, $notes = null)
    {
        $this->status = $status;

        // Actualizar timestamps según el estado
        switch ($status) {
            case 'preparation':
                $this->preparation_started_at = now();
                break;
            case 'ready':
                $this->ready_at = now();
                break;
            case 'delivered':
                $this->delivered_at = now();
                break;
        }

        $this->save();

        // Registrar en el historial
        $this->statusHistory()->create([
            'status' => $status,
            'notes' => $notes
        ]);
    }

    // Boot method para generar número de pedido
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($order) {
            if (empty($order->order_number)) {
                $order->order_number = 'BH-' . now()->format('YmdHis') . rand(100, 999);
            }
        });
    }

    // Scopes
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByPaymentStatus($query, $status)
    {
        return $query->where('payment_status', $status);
    }

    public function scopeByDeliveryType($query, $type)
    {
        return $query->where('delivery_type', $type);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]);
    }
}
```

### 9. OrderItem (Item del Pedido)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id', 'product_id', 'product_name', 'product_price',
        'quantity', 'unit_price', 'total_price', 'notes'
    ];

    protected $casts = [
        'product_price' => 'decimal:2',
        'unit_price' => 'decimal:2',
        'total_price' => 'decimal:2',
    ];

    // Relaciones
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function options()
    {
        return $this->hasMany(OrderItemOption::class);
    }
}
```

### 10. OrderItemOption (Opción del Item del Pedido)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItemOption extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_item_id', 'variant_name', 'option_name', 'price_modifier'
    ];

    protected $casts = [
        'price_modifier' => 'decimal:2',
    ];

    // Relaciones
    public function orderItem()
    {
        return $this->belongsTo(OrderItem::class);
    }
}
```

### 11. OrderStatusHistory (Historial de Estados)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderStatusHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id', 'status', 'notes'
    ];

    // Relaciones
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    // Scopes
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }
}
```

### 12. BusinessSetting (Configuración del Negocio)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BusinessSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'key', 'value', 'type', 'description'
    ];

    // Methods
    public static function get($key, $default = null)
    {
        $setting = static::where('key', $key)->first();

        if (!$setting) {
            return $default;
        }

        switch ($setting->type) {
            case 'boolean':
                return filter_var($setting->value, FILTER_VALIDATE_BOOLEAN);
            case 'number':
                return is_numeric($setting->value) ? (float) $setting->value : $default;
            case 'json':
                return json_decode($setting->value, true);
            default:
                return $setting->value;
        }
    }

    public static function set($key, $value, $type = 'string', $description = null)
    {
        $setting = static::updateOrCreate(
            ['key' => $key],
            [
                'value' => is_array($value) ? json_encode($value) : $value,
                'type' => $type,
                'description' => $description
            ]
        );

        return $setting;
    }
}
```

## Factories y Seeders

### ProductFactory

```php
<?php

namespace Database\Factories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    public function definition()
    {
        $name = $this->faker->words(3, true);

        return [
            'category_id' => Category::factory(),
            'name' => ucwords($name),
            'slug' => \Illuminate\Support\Str::slug($name),
            'description' => $this->faker->paragraph(),
            'price' => $this->faker->randomFloat(2, 500, 5000),
            'original_price' => $this->faker->optional(0.3)->randomFloat(2, 600, 6000),
            'sku' => 'PROD-' . $this->faker->unique()->numberBetween(1000, 9999),
            'image' => $this->faker->imageUrl(400, 300, 'food'),
            'stock' => $this->faker->numberBetween(0, 100),
            'is_available' => $this->faker->boolean(90),
            'is_featured' => $this->faker->boolean(20),
            'preparation_time' => $this->faker->numberBetween(5, 30),
            'sort_order' => $this->faker->numberBetween(1, 100),
        ];
    }
}
```

### OrderFactory

```php
<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Coupon;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    public function definition()
    {
        $deliveryType = $this->faker->randomElement(['delivery', 'pickup']);
        $subtotal = $this->faker->randomFloat(2, 2000, 15000);
        $deliveryFee = $deliveryType === 'delivery' ? 1500 : 0;
        $serviceFee = $subtotal * 0.03;
        $discountAmount = $this->faker->optional(0.3)->randomFloat(2, 0, $subtotal * 0.2);
        $totalAmount = $subtotal + $deliveryFee + $serviceFee - $discountAmount;

        return [
            'order_number' => 'BH-' . now()->format('YmdHis') . $this->faker->numberBetween(100, 999),
            'user_id' => $this->faker->optional(0.7)->randomElement(User::pluck('id')),
            'customer_name' => $this->faker->name(),
            'customer_email' => $this->faker->email(),
            'customer_phone' => $this->faker->phoneNumber(),
            'delivery_type' => $deliveryType,
            'delivery_street' => $deliveryType === 'delivery' ? $this->faker->streetAddress() : null,
            'delivery_city' => $deliveryType === 'delivery' ? $this->faker->city() : null,
            'delivery_postal_code' => $deliveryType === 'delivery' ? $this->faker->postcode() : null,
            'delivery_floor' => $this->faker->optional(0.3)->randomElement(['1°', '2°', '3°', '4°', '5°']),
            'payment_method' => $this->faker->randomElement(['cash', 'card', 'transfer']),
            'payment_status' => $this->faker->randomElement(['pending', 'paid', 'failed']),
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'service_fee' => $serviceFee,
            'discount_amount' => $discountAmount,
            'total_amount' => $totalAmount,
            'coupon_id' => $discountAmount > 0 ? Coupon::factory() : null,
            'status' => $this->faker->randomElement(['pending', 'preparation', 'ready', 'route', 'delivered']),
            'notes' => $this->faker->optional(0.2)->sentence(),
        ];
    }
}
```

## Migraciones Laravel

### Ejemplo de migración para la tabla orders

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrdersTable extends Migration
{
    public function up()
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('customer_name');
            $table->string('customer_email');
            $table->string('customer_phone');

            // Información de entrega
            $table->enum('delivery_type', ['delivery', 'pickup']);
            $table->foreignId('delivery_address_id')->nullable()->constrained('addresses')->nullOnDelete();
            $table->string('delivery_street')->nullable();
            $table->string('delivery_city')->nullable();
            $table->string('delivery_postal_code')->nullable();
            $table->string('delivery_floor')->nullable();
            $table->text('delivery_notes')->nullable();

            // Información de pago
            $table->enum('payment_method', ['cash', 'card', 'transfer']);
            $table->enum('payment_status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->string('payment_reference')->nullable();

            // Totales
            $table->decimal('subtotal', 10, 2);
            $table->decimal('delivery_fee', 10, 2)->default(0);
            $table->decimal('service_fee', 10, 2)->default(0);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('total_amount', 10, 2);

            // Cupón
            $table->foreignId('coupon_id')->nullable()->constrained()->nullOnDelete();

            // Estado
            $table->enum('status', ['pending', 'preparation', 'ready', 'route', 'delivered', 'cancelled'])->default('pending');

            // Tiempos
            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('preparation_started_at')->nullable();
            $table->timestamp('ready_at')->nullable();
            $table->timestamp('delivered_at')->nullable();

            $table->text('notes')->nullable();
            $table->timestamps();

            // Índices
            $table->index(['status']);
            $table->index(['payment_status']);
            $table->index(['delivery_type']);
            $table->index(['created_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('orders');
    }
}
```

## Controladores Principales

### OrderController

```php
<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Product;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::with(['user', 'items.product', 'coupon']);

        // Filtros
        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->payment_status) {
            $query->where('payment_status', $request->payment_status);
        }

        if ($request->date_from) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->date_to) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $orders = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json($orders);
    }

    public function store(Request $request)
    {
        $request->validate([
            'customer_name' => 'required|string|max:255',
            'customer_email' => 'required|email',
            'customer_phone' => 'required|string',
            'delivery_type' => 'required|in:delivery,pickup',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        DB::beginTransaction();

        try {
            $order = Order::create([
                'customer_name' => $request->customer_name,
                'customer_email' => $request->customer_email,
                'customer_phone' => $request->customer_phone,
                'delivery_type' => $request->delivery_type,
                'delivery_street' => $request->delivery_street,
                'delivery_city' => $request->delivery_city,
                'delivery_postal_code' => $request->delivery_postal_code,
                'delivery_floor' => $request->delivery_floor,
                'delivery_notes' => $request->delivery_notes,
                'payment_method' => $request->payment_method ?? 'cash',
                'notes' => $request->notes,
            ]);

            $subtotal = 0;

            foreach ($request->items as $itemData) {
                $product = Product::findOrFail($itemData['product_id']);
                $unitPrice = $product->price;
                $totalPrice = $unitPrice * $itemData['quantity'];

                $orderItem = $order->items()->create([
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_price' => $product->price,
                    'quantity' => $itemData['quantity'],
                    'unit_price' => $unitPrice,
                    'total_price' => $totalPrice,
                    'notes' => $itemData['notes'] ?? null,
                ]);

                // Guardar opciones seleccionadas
                if (isset($itemData['options'])) {
                    foreach ($itemData['options'] as $option) {
                        $orderItem->options()->create([
                            'variant_name' => $option['variant_name'],
                            'option_name' => $option['option_name'],
                            'price_modifier' => $option['price_modifier'] ?? 0,
                        ]);
                    }
                }

                $subtotal += $totalPrice;
            }

            // Calcular descuentos
            $discountAmount = 0;
            if ($request->coupon_code) {
                $coupon = Coupon::where('code', $request->coupon_code)->first();
                if ($coupon && $coupon->is_valid) {
                    $discountAmount = $coupon->calculateDiscount($subtotal);
                    $order->update(['coupon_id' => $coupon->id]);
                }
            }

            // Calcular totales
            $deliveryFee = $request->delivery_type === 'delivery' ? 1500 : 0;
            $serviceFee = $subtotal * 0.03;
            $totalAmount = $subtotal + $deliveryFee + $serviceFee - $discountAmount;

            $order->update([
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'service_fee' => $serviceFee,
                'discount_amount' => $discountAmount,
                'total_amount' => $totalAmount,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'order' => $order->load(['items.product', 'coupon']),
                'message' => 'Pedido creado exitosamente'
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Error al crear el pedido: ' . $e->getMessage()
            ], 500);
        }
    }

    public function updateStatus(Request $request, Order $order)
    {
        $request->validate([
            'status' => 'required|in:pending,preparation,ready,route,delivered,cancelled',
            'notes' => 'nullable|string'
        ]);

        $order->updateStatus($request->status, $request->notes);

        return response()->json([
            'success' => true,
            'order' => $order->load(['items.product', 'statusHistory']),
            'message' => 'Estado actualizado exitosamente'
        ]);
    }
}
```

Esta estructura proporciona una base sólida para tu aplicación Laravel con todas las funcionalidades identificadas en las plantillas HTML.
