<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SensorIngestController;

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

// IoT ingest endpoint (ESP32 MicroPython JSON)
Route::post('/sensor', [SensorIngestController::class, 'store']);

require __DIR__.'/api/mobile.php';
