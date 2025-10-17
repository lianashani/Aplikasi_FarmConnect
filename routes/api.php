<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\IoTController;
use App\Http\Controllers\Api\AdminUserController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| This file registers API routes for the application. We separate mobile
| specific routes into routes/api/mobile.php which is included below.
|
*/

Route::get('/health', fn () => response()->json(['status' => 'ok']));

// Public auth
Route::get('/register', fn () => response()->json([
    'message' => 'Use POST /api/register with JSON {name,email,password,role}',
    'allowed_methods' => ['POST']
], 405));
Route::get('/login', fn () => response()->json([
    'message' => 'Use POST /api/login with JSON {email,password}',
    'allowed_methods' => ['POST']
], 405));
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user/profile', [AuthController::class, 'me']);

    // products
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::post('/products', [ProductController::class, 'store'])->middleware('role:admin,petani');
    Route::put('/products/{id}', [ProductController::class, 'update'])->middleware('role:admin,petani');
    Route::delete('/products/{id}', [ProductController::class, 'destroy'])->middleware('role:admin,petani');

    // transactions
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store'])->middleware('role:pembeli');
    Route::patch('/transactions/{id}/status', [TransactionController::class, 'updateStatus'])->middleware('role:admin,petani');

    // IoT data
    Route::get('/iot', [IoTController::class, 'index'])->middleware('role:admin,petani');
    Route::post('/iot', [IoTController::class, 'store'])->middleware('role:admin,petani');

    // Admin user management
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('/users', [AdminUserController::class, 'index']);
        Route::post('/users', [AdminUserController::class, 'store']);
        Route::put('/users/{id}', [AdminUserController::class, 'update']);
        Route::delete('/users/{id}', [AdminUserController::class, 'destroy']);
        Route::post('/users/{id}/toggle-active', [AdminUserController::class, 'toggleActive']);
    });
});
