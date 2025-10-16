<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\SensorController;

Route::prefix('mobile')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/profile', [AuthController::class, 'me']);

        // (protected) Keep if needed later

        // (protected) Keep if needed later
    });

    // Public products, transactions & sensor endpoints for demo (no auth)
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::post('/transactions', [TransactionController::class, 'store']);
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::get('/sensors', [SensorController::class, 'index']);
    Route::get('/sensors/latest', [SensorController::class, 'latest']);
    Route::post('/sensors', [SensorController::class, 'store']);
});
