<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\ProductAdminController;
use App\Http\Controllers\Admin\AdminAuthController;
use Illuminate\Support\Facades\DB;

Route::get('/', function () {
    return view('welcome');
});

// Admin auth (session)
Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'login'])->name('admin.login.post');
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');

Route::prefix('admin')->name('admin.')->middleware(['auth', 'role:admin'])->group(function () {
    Route::get('/products', [ProductAdminController::class, 'index'])->name('products.index');
    Route::get('/products/create', [ProductAdminController::class, 'create'])->name('products.create');
    Route::post('/products', [ProductAdminController::class, 'store'])->name('products.store');
    Route::get('/products/{product}/edit', [ProductAdminController::class, 'edit'])->name('products.edit');
    Route::put('/products/{product}', [ProductAdminController::class, 'update'])->name('products.update');
    Route::delete('/products/{product}', [ProductAdminController::class, 'destroy'])->name('products.destroy');

    Route::get('/dashboard', function () {
        $totalProducts = DB::table('products')->count();
        $totalTransactions = DB::table('transactions')->count();
        $totalRevenue = DB::table('transactions')->sum('total_price');
        return view('admin.dashboard', compact('totalProducts', 'totalTransactions', 'totalRevenue'));
    })->name('dashboard');

    Route::get('/charts/sales', function () {
        $rows = DB::table('transactions')
            ->selectRaw('DATE(created_at) as date, SUM(total_price) as total')
            ->groupBy('date')
            ->orderBy('date')
            ->get();
        return response()->json($rows);
    })->name('charts.sales');
});
